package RAID::Info::Controller::Areca;

use 5.014;
use namespace::autoclean;

use Moo;
use Types::Standard qw(Str);

with 'RAID::Info::Controller';

use IPC::System::Simple qw(capturex EXIT_ANY);

has _hw_raw   => ( is => 'rw', isa => Str );
has _disk_raw => ( is => 'rw', isa => Str );
has _vsf_raw  => ( is => 'rw', isa => Str );

sub _load_data_from_controller {
  my ($self) = @_;
  return if defined $self->_hw_raw;

  my $hw_raw   = capturex(qw(cli64 hw info));
  my $disk_raw = capturex(qw(cli64 disk info));
  my $vsf_raw  = capturex(qw(cli64 vsf info));
  $self->_hw_raw($hw_raw);
  $self->_disk_raw($disk_raw);
  $self->_vsf_raw($vsf_raw);
}

sub _build_name {
  return "areca/0";
}

sub _build_physical_disks {
  my ($self) = @_;

  $self->_load_data_from_controller;

  my %virtual_names = map { $_->raid_name => 1 } @{$self->virtual_disks};

  state $state_map = {
    Online => sub { RAID::Info::PhysicalDisk::State::Online->new },
    Failed => sub { RAID::Info::PhysicalDisk::State::Failed->new },
  };

  my @disks = map {
    if (my ($id, $enc, $slot, $model, $capacity, $usage) =
          m{^\s+(\d+)\s+(\d+)\s+(?i:slot)[\s#]*(\d+)\s+(.+?)\s+([\d\.]+.B)\s+(.+?)\s*$}) {
      if ($usage eq 'N.A.') {
        ()
      }
      else {
        my $state = $virtual_names{$usage} ? 'Online' : $usage;
        RAID::Info::PhysicalDisk->new(
          id       => $id,
          slot     => $slot,
          model    => $model,
          capacity => $capacity,
          state    => eval { $state_map->{$state}->() } // $state,
        )
      }
    }
    else {
      ()
    }
  } split '\n', $self->_disk_raw;

  return \@disks;
}

sub _build_virtual_disks {
  my ($self) = @_;

  $self->_load_data_from_controller;

  state $state_map = {
    Normal     => sub { RAID::Info::VirtualDisk::State::Normal->new },
    Rebuilding => sub { RAID::Info::VirtualDisk::State::Rebuilding->new(progress => shift) },
  };

  my @virtual = map {
    if (my ($id, $name, $raid_name, $level, $capacity, $lun, $state, $progress) =
          m{^\s+(\d+)\s+(\S+)\s+(.+?)\s+(\S+)\s+([\d\.]+.B)\s+([\d/]+)\s+([^\s\(]+)(?:\(([\d\.]+)\%\))?\s*}) {
      RAID::Info::Controller::Areca::VirtualDisk->new(
        id        => $id,
        name      => $name,
        raid_name => $raid_name,
        level     => lc $level,
        capacity  => $capacity,
        state     => eval { $state_map->{$state}->($progress) } // $state,
      )
    }
    else {
      ()
    }
  } split '\n', $self->_vsf_raw;

  return \@virtual;
}

sub detect {
  my ($class) = @_;

  my $main_raw = capturex(EXIT_ANY, qw(cli64 main));
  my @ids = $main_raw =~ m/^.{3}\s(\d+)\s+/smg;

  die "no support for multiple Areca controllers; please contact the RAID-Info authors"
    if @ids >= 2;

  return map { $class->new } @ids;
}

package RAID::Info::Controller::Areca::VirtualDisk;

use namespace::autoclean;

use Moo;
use Types::Standard qw(Str);

extends 'RAID::Info::VirtualDisk';

has raid_name => ( is => 'ro', isa => Str, required => 1 );

1;

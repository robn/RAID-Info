package RAID::Info::Controller::Areca;

use 5.014;
use namespace::autoclean;

use Moo;
use Types::Standard qw(Str);

with 'RAID::Info::Controller';

use IPC::System::Simple qw(capturex EXIT_ANY);
use Try::Tiny;

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

  state $state_map = {
    Online => sub { RAID::Info::PhysicalDisk::State::Online->new },
    Free   => sub { RAID::Info::PhysicalDisk::State::Unallocated->new },
    Failed => sub { RAID::Info::PhysicalDisk::State::Failed->new },
  };

  my %virtual_names = map { $_->[2] => 1 } @{$self->_split_vsf_raw};

  my @disks = map {
    my ($id, $enc, $slot, $model, $capacity, $usage) = @$_;
    my $state = $virtual_names{$usage} ? 'Online' : (exists $state_map->{$usage} ? $usage : 'Free');
    RAID::Info::Controller::Areca::PhysicalDisk->new(
      id        => $id,
      slot      => $slot,
      model     => $model,
      capacity  => $capacity,
      state     => eval { $state_map->{$state}->() } // $state,
      raid_name => $state eq 'Online' ? $usage : '',
    )
  } @{$self->_split_disk_raw};

  return \@disks;
}

sub _build_virtual_disks {
  my ($self) = @_;

  $self->_load_data_from_controller;

  state $state_map = {
    Normal         => sub { RAID::Info::VirtualDisk::State::Normal->new },
    Degraded       => sub { RAID::Info::VirtualDisk::State::Degraded->new },
    Rebuilding     => sub { RAID::Info::VirtualDisk::State::Rebuilding->new(progress => shift) },
    'Need Rebuild' => sub { RAID::Info::VirtualDisk::State::Rebuilding->new(progress => 0) },
  };

  my %phys;
  push @{$phys{$_->raid_name}}, $_ for @{$self->physical_disks};

  my @virtual = map {
    my ($id, $name, $raid_name, $level, $capacity, $lun, $state, $progress) = @$_;
    $level =~ s/\+//; # Raid1+0 -> Raid10
    RAID::Info::Controller::Areca::VirtualDisk->new(
      id             => $id,
      name           => $name,
      raid_name      => $raid_name,
      level          => lc $level,
      capacity       => $capacity,
      state          => eval { $state_map->{$state}->($progress) } // $state,
      physical_disks => $phys{$raid_name} // [],
    )
  } @{$self->_split_vsf_raw};

  return \@virtual;
}

has _split_disk_raw => ( is => 'lazy' );
sub _build__split_disk_raw {
  my ($self) = @_;

  [
    map {
      if (my @row =
            m{^\s+(\d+)\s+(\d+)\s+(?i:slot)[\s#]*(\d+)\s+(.+?)\s+([\d\.]+.B)\s+(.+?)\s*(\s+<<)?$}) {
        $row[5] eq 'N.A.' ? () : \@row
      }
      else {
        ()
      }
    } split '\n', $self->_disk_raw
  ]
}

has _split_vsf_raw  => ( is => 'lazy' );
sub _build__split_vsf_raw {
  my ($self) = @_;

  [
    map {
      if (my @row =
            m{^\s+(\d+)\s+(\S+)\s+(.+?)\s+(\S+)\s+([\d\.]+.B)\s+([\d/]+)\s+([^\(]+)(?:\(([\d\.]+)\%\))?\s*}) {
        \@row
      }
      else {
        ()
      }
    } split '\n', $self->_vsf_raw
  ]
}


sub detect {
  my ($class) = @_;

  my $main_raw = try { capturex(EXIT_ANY, qw(cli64 main)) };
  return unless $main_raw;

  my @ids = $main_raw =~ m/^.{3}\s(\d+)\s+/smg;

  die "no support for multiple Areca controllers; please contact the RAID-Info authors"
    if @ids >= 2;

  return map { $class->new } @ids;
}

package RAID::Info::Controller::Areca::PhysicalDisk {

use namespace::autoclean;

use Moo;
use Types::Standard qw(Str);

extends 'RAID::Info::PhysicalDisk';

has raid_name => ( is => 'ro', isa => Str, required => 1 );

with 'RAID::Info::Role::HasPhysicalDisks';

sub _build_physical_disks {
  # no op; we prove the list of disks in the constructor
  []
}

}

package RAID::Info::Controller::Areca::VirtualDisk {

use namespace::autoclean;

use Moo;
use Types::Standard qw(Str);

extends 'RAID::Info::VirtualDisk';

has raid_name => ( is => 'ro', isa => Str, required => 1 );

with 'RAID::Info::Role::HasPhysicalDisks';

sub _build_physical_disks {
  # no op; we prove the list of disks in the constructor
  []
}

}

1;

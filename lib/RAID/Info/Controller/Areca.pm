package RAID::Info::Controller::Areca;

use 5.014;
use namespace::autoclean;

use Moo;
use Type::Params qw(compile);
use Types::Standard qw(slurpy ClassName Dict Str);

with 'RAID::Info::Controller';

has _hw_raw   => ( is => 'rw', isa => Str );
has _disk_raw => ( is => 'rw', isa => Str );
has _vsf_raw  => ( is => 'rw', isa => Str );

sub _new_for_test {
  state $check = compile(
    ClassName,
    slurpy Dict[
      hw   => Str,
      disk => Str,
      vsf  => Str,
    ],
  );
  my ($class, $args) = $check->(@_);

  my $self = $class->new;
  $self->_hw_raw($args->{hw});
  $self->_disk_raw($args->{disk});
  $self->_vsf_raw($args->{vsf});

  return $self;
}

sub _load_data_from_controller {
}

sub _build_physical_disks {
  my ($self) = @_;

  $self->_load_data_from_controller;

  my %virtual_names = map { $_->raid_name => 1 } @{$self->virtual_disks};

  state $state_map = {
    Failed => 'failed',
  };

  my @disks = map {
    if (my ($id, $enc, $slot, $model, $capacity, $usage) =
          m{^\s+(\d+)\s+(\d+)\s+Slot[\s#]*(\d+)\s+(.+?)\s+([\d\.]+.B)\s+(.+?)\s*$}) {
      if ($usage eq 'N.A.') {
        ()
      }
      else {
        my $state = $virtual_names{$usage} ? 'online' : ($state_map->{$usage} // $usage);
        RAID::Info::PhysicalDisk->new(
          id       => $id,
          slot     => $slot,
          model    => $model,
          capacity => $capacity,
          state    => $state,
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

package RAID::Info::Controller::Areca::VirtualDisk;

use namespace::autoclean;

use Moo;
use Types::Standard qw(Str);

extends 'RAID::Info::VirtualDisk';

has raid_name => ( is => 'ro', isa => Str, required => 1 );

1;

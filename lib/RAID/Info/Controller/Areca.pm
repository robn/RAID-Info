package RAID::Info::Controller::Areca;

use 5.014;
use warnings;
use strict;

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
        my $state = $state_map->{$usage} // "online";
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
    Normal     => 'normal',
    Rebuilding => 'rebuilding',
  };

  my @virtual = map {
    if (my ($id, $name, $raid_name, $level, $capacity, $lun, $state) =
          m{^\s+(\d+)\s+(\S+)\s+(.+)\s+(\S+)\s+([\d\.]+.B)\s+([\d/]+)\s+(\S+)\s*}) {
      $state =~ s/\(.*//;
      RAID::Info::VirtualDisk->new(
        id       => $id,
        name     => $name,
        level    => lc $level,
        capacity => $capacity,
        state    => $state_map->{$state} // $state,
      )
    }
    else {
      ()
    }
  } split '\n', $self->_vsf_raw;

  return \@virtual;
}

1;
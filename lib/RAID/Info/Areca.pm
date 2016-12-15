package RAID::Info::Areca;

use 5.014;
use warnings;
use strict;

use Moo;
use Type::Params qw(compile);
use Type::Utils qw(class_type);
use Types::Standard qw(slurpy ClassName Dict Str ArrayRef);

use RAID::Info::PhysicalDisk;
use RAID::Info::VirtualDisk;

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

has physical_disks => ( is => 'lazy', isa => ArrayRef[class_type('RAID::Info::PhysicalDisk')] );
sub _build_physical_disks {
  my ($self) = @_;

  $self->_load_data_from_controller;

  my @disks = map {
    if (my ($id, $enc, $slot, $model, $capacity, $usage) =
          m{^\s+(\d+)\s+(\d+)\s+Slot(\d+)\s+(.+?)\s+([\d\.]+.B)\s+(.+)\s*$}) {
      RAID::Info::PhysicalDisk->new(
        id       => $id,
        slot     => $slot =~ s/Slot//r,
        model    => $model,
        capacity => $capacity,
      )
    }
    else {
      ()
    }
  } split '\n', $self->_disk_raw;

  return \@disks;
}

has virtual_disks => ( is => 'lazy', isa => ArrayRef[class_type('RAID::Info::VirtualDisk')] );
sub _build_virtual_disks {
  my ($self) = @_;

  $self->_load_data_from_controller;

  state $state_map = {
    Normal     => 'normal',
    Rebuilding => 'rebuilding',
  };

  my @virtual = map {
    if (my ($id, $name, $raid_name, $level, $capacity, $lun, $state) =
          m{^\s+(\d+)\s+(\S+)\s+(\S+)\s+(\S+)\s+([\d\.]+.B)\s+([\d/]+)\s+(\S+)\s*}) {
      $state =~ s/\(.*//;
      RAID::Info::VirtualDisk->new(
        id       => $id,
        name     => $name,
        level    => $level,
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

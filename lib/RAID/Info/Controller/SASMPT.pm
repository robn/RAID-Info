package RAID::Info::Controller::SASMPT;

use 5.014;
use warnings;
use strict;

use Moo;
use Type::Params qw(compile);
use Type::Utils qw(class_type);
use Types::Standard qw(slurpy ClassName Dict Str ArrayRef);

use RAID::Info::PhysicalDisk;
use RAID::Info::VirtualDisk;

has _lsiutil_raw => ( is => 'rw', isa => Str );

sub _new_for_test {
  state $check = compile(
    ClassName,
    slurpy Dict[
      lsiutil => Str,
    ],
  );
  my ($class, $args) = $check->(@_);

  my $self = $class->new;
  $self->_lsiutil_raw($args->{lsiutil});

  return $self;
}

sub _load_data_from_controller {
  # echo -e '1\n21\n1\n2' | lsiutil
}

has physical_disks => ( is => 'lazy', isa => ArrayRef[class_type('RAID::Info::PhysicalDisk')] );
sub _build_physical_disks {
  my ($self) = @_;

  $self->_load_data_from_controller;

  my @disks = map {
    my ($id) = m/^(\d+) is Bus \d+ Target \d+/;
    if (defined $id) {
      my ($state) = m/PhysDisk State:\s+(.+?)\s*$/m;
      my ($capacity, $model) = m/PhysDisk Size (\d+ MB), Inquiry Data:\s*(.+?)\s*$/m;
      RAID::Info::PhysicalDisk->new(
        id       => $id,
        slot     => $id,
        model    => $model,
        capacity => $capacity,
        state    => $state,
      )
    }
    else {
      ()
    }
  } split /\n+PhysDisk /, $self->_lsiutil_raw;

  return \@disks;
}

has virtual_disks => ( is => 'lazy', isa => ArrayRef[class_type('RAID::Info::VirtualDisk')] );
sub _build_virtual_disks {
  my ($self) = @_;

  $self->_load_data_from_controller;

  state $state_map = {
    'optimal, enabled' => 'normal',
  };

  my @virtual = map {
    my ($id) = m/^(\d+) is Bus \d+ Target \d+/;
    if (defined $id) {
      my ($name) = m/Volume Name:\s+(.*?)\s*$/m;
      my $level = m/Type IM/ ? 'raid1' : undef;
      my ($state) = m/Volume State:\s+(.+?)\s*$/m;
      my ($capacity) = m/Volume Size (\d+ MB)/m;
      RAID::Info::VirtualDisk->new(
        id       => $id,
        name     => $name,
        level    => $level,
        capacity => $capacity,
        state    => $state_map->{$state},
      )
    }
    else {
      ()
    }
  } split /\n+Volume /, $self->_lsiutil_raw;

  return \@virtual;
}

1;

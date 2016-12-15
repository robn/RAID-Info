package RAID::Info::Adaptec;

use 5.014;
use warnings;
use strict;

use Moo;
use Type::Params qw(compile);
use Type::Utils qw(class_type);
use Types::Standard qw(slurpy ClassName Dict Str ArrayRef);

use RAID::Info::PhysicalDisk;
use RAID::Info::VirtualDisk;

has _getconfig_raw => ( is => 'rw', isa => Str );

sub _new_for_test {
  state $check = compile(
    ClassName,
    slurpy Dict[
      getconfig => Str,
    ],
  );
  my ($class, $args) = $check->(@_);

  my $self = $class->new;
  $self->_getconfig_raw($args->{getconfig});

  return $self;
}

sub _load_data_from_controller {
}

has physical_disks => ( is => 'lazy', isa => ArrayRef[class_type('RAID::Info::PhysicalDisk')] );
sub _build_physical_disks {
  my ($self) = @_;

  $self->_load_data_from_controller;

  state $state_map = {
    Online => 'online',
  };

  my ($physdev) = $self->_getconfig_raw =~ m{Physical Device information\s*\n-+\n\s{6}(.+)}msg;
  my @disks = map {
    my ($id, $typeline, @lines) = map { m/^\s*(.+)\s*$/ } split /[\r\n]+/, $_;
    if ($typeline && $typeline =~ m/Device is a Hard drive/) {
      my %vars = map { split '\s+:\s+', $_ } @lines;
      my ($slot) = $vars{'Reported Location'} =~ m/Enclosure \d+, Slot (\d+)/;
      my $state = $vars{'State'};
      RAID::Info::PhysicalDisk->new(
        id       => $id,
        slot     => $slot,
        model    => $vars{'Model'},
        capacity => $vars{'Total Size'},
        state    => $state_map->{$state} // $state,
      )
    }
    else {
      ()
    }
  } split /\s*Device #/, $physdev;
  return \@disks;
}

has virtual_disks => ( is => 'lazy', isa => ArrayRef[class_type('RAID::Info::VirtualDisk')] );
sub _build_virtual_disks {
  my ($self) = @_;

  $self->_load_data_from_controller;

  state $state_map = {
    Optimal => 'normal',
  };

  my ($logidev) = $self->_getconfig_raw =~ m{Logical device information\s*\n-+\n(.+?)\n   -+}msg;
  my @virtual = map {
    my ($id, @lines) = map { m/^\s*(.+)\s*$/ } split /[\r\n]+/, $_;
    if (defined $id) {
      my %vars = map { split '\s+:\s+', $_ } @lines;
      my $state = $vars{'Status of logical device'};
      RAID::Info::VirtualDisk->new(
        id       => $id,
        name     => $vars{'Logical device name'},
        level    => $vars{'RAID level'},
        capacity => $vars{'Size'},
        state    => $state_map->{$state} // $state,
      )
    }
    else {
      ()
    }
  } split /Logical device number /, $logidev;

  return \@virtual;
}

1;

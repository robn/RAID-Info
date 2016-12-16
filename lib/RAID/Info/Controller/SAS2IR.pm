package RAID::Info::Controller::SAS2IR;

use 5.014;
use warnings;
use strict;

use Moo;
use Type::Params qw(compile);
use Type::Utils qw(class_type);
use Types::Standard qw(slurpy ClassName Dict Str ArrayRef);

use RAID::Info::PhysicalDisk;
use RAID::Info::VirtualDisk;

has _display_raw => ( is => 'rw', isa => Str );

sub _new_for_test {
  state $check = compile(
    ClassName,
    slurpy Dict[
      display => Str,
    ],
  );
  my ($class, $args) = $check->(@_);

  my $self = $class->new;
  $self->_display_raw($args->{display});

  return $self;
}

sub _load_data_from_controller {
}

has physical_disks => ( is => 'lazy', isa => ArrayRef[class_type('RAID::Info::PhysicalDisk')] );
sub _build_physical_disks {
  my ($self) = @_;

  $self->_load_data_from_controller;

  state $state_map = {
    RDY => 'online',
  };

  my @disks = map {
    my ($device, @lines) = map { m/^\s*(.+)\s*$/ } split /\n+/, $_;
    if ($device eq 'Hard disk') {
      my %vars = map { m/:\s/ ? split '\s*:\s+', $_, 2 : () } @lines;
      my $id = "$vars{'Enclosure #'}/$vars{'Slot #'}";
      my $capacity = [$vars{'Size (in MB)/(in sectors)'} =~ m/^([\d\.]+)/]->[0];
      my ($state) = $vars{'State'} =~ m/\(([A-Z]+)\)$/;
      RAID::Info::PhysicalDisk->new(
        id       => $id,
        slot     => $vars{'Slot #'},
        model    => $vars{'Model Number'} =~ s/\s+/ /gr,
        capacity => "$capacity MB",
        state    => $state_map->{$state} // $state,
      )
    }
    else {
      ()
    }
  } split /\n+Device is a /, $self->_display_raw;

  return \@disks;
}

has virtual_disks => ( is => 'lazy', isa => ArrayRef[class_type('RAID::Info::VirtualDisk')] );
sub _build_virtual_disks {
  my ($self) = @_;

  return [];
}

1;

package RAID::Info::MegaRAID;

use 5.014;
use warnings;
use strict;

use Moo;
use Type::Params qw(compile);
use Type::Utils qw(class_type);
use Types::Standard qw(slurpy ClassName Dict Str ArrayRef);

use RAID::Info::PhysicalDisk;
use RAID::Info::VirtualDisk;

has _ldpdinfo_raw => ( is => 'rw', isa => Str );

sub _new_for_test {
  state $check = compile(
    ClassName,
    slurpy Dict[
      ldpdinfo => Str,
    ],
  );
  my ($class, $args) = $check->(@_);

  my $self = $class->new;
  $self->_ldpdinfo_raw($args->{ldpdinfo});

  return $self;
}

sub _load_data_from_controller {
}

has physical_disks => ( is => 'lazy', isa => ArrayRef[class_type('RAID::Info::PhysicalDisk')] );
sub _build_physical_disks {
  my ($self) = @_;

  $self->_load_data_from_controller;

  state $state_map = {
    'Online, Spun Up' => 'online',
  };

  my %disks = map {
    my @lines = split /\n+/, $_;
    my %vars = map { m/:\s/ ? split '\s*:\s+', $_, 2 : () } @lines;
    if (exists $vars{'Device Id'}) {
      my $id = $vars{'Device Id'};
      my $capacity = [$vars{'Raw Size'} =~ m/^([\d\.]+ .B)/]->[0];
      my $state = $vars{'Firmware state'};
      ($id => RAID::Info::PhysicalDisk->new(
        id       => $id,
        slot     => $vars{'Slot Number'},
        model    => $vars{'Inquiry Data'} =~ s/\s+/ /gr,
        capacity => $capacity,
        state    => $state_map->{$state} // $state,
      ))
    }
    else {
      ()
    }
  } split /\n+PD: \d+ Information\n+/, $self->_ldpdinfo_raw;

  return [ map { $disks{$_} } sort keys %disks ];
}

has virtual_disks => ( is => 'lazy', isa => ArrayRef[class_type('RAID::Info::VirtualDisk')] );
sub _build_virtual_disks {
  my ($self) = @_;

  $self->_load_data_from_controller;

  state $state_map = {
    Optimal => 'normal',
  };

  state $level_map = {
    'Primary-0, Secondary-0, RAID Level Qualifier-0' => 'raid0',
    'Primary-1, Secondary-0, RAID Level Qualifier-0' => 'raid1',
    'Primary-5, Secondary-0, RAID Level Qualifier-3' => 'raid5',
    'Primary-6, Secondary-0, RAID Level Qualifier-3' => 'raid6',
    'Primary-1, Secondary-3, RAID Level Qualifier-0' => 'raid10',
  };

  my @virtual = map {
    my ($idline, @lines) = split /\n+/;
    my ($id) = $idline =~ m/^(\d+)/;
    if (defined $id) {
      my %vars = map { m/:\s/ ? split '\s*:\s+', $_, 2 : () } @lines;
      my $name  = $vars{Name} // '';
      my $level = $vars{'RAID Level'};
      RAID::Info::VirtualDisk->new(
        id       => $id,
        name     => $name,
        level    => $level_map->{$level} // $level,
        capacity => $vars{'Size'},
        state    => $state_map->{$vars{'State'}} // $vars{'State'},
      )
    }
    else {
      ()
    }
  } split /Virtual Drive: /, $self->_ldpdinfo_raw;

  return \@virtual;
}

1;

package RAID::Info::Controller::SASxIR;

use 5.014;
use namespace::autoclean;

use Moo::Role;
use Types::Standard qw(Str Int);

with 'RAID::Info::Controller';

has id => ( is => 'ro', isa => Int, required => 1 );

has _display_raw => ( is => 'rw', isa => Str );

requires qw(_load_data_from_controller);

sub _build_physical_disks {
  my ($self) = @_;

  $self->_load_data_from_controller;

  state $state_map = {
    RDY => sub { RAID::Info::PhysicalDisk::State::Online->new },
    AVL => sub { RAID::Info::PhysicalDisk::State::Online->new },
  };

  my @disks = map {
    my ($device, @lines) = map { m/^\s*(.+)\s*$/ } split /\n+/, $_;
    if ($device eq 'Hard disk') {
      my %vars = map { m/:\s/ ? split '\s*:\s+', $_, 2 : () } @lines;
      my $id = "$vars{'Enclosure #'}/$vars{'Slot #'}";
      my ($state) = $vars{'State'} =~ m/\(([A-Z]+)\)$/;
      my $capacity =
        $state eq 'AVL' ? 0 # XXX AVL is usable, but not reported fully, this will do for now
                        : [$vars{'Size (in MB)/(in sectors)'} =~ m/^([\d\.]+)/]->[0];
      RAID::Info::PhysicalDisk->new(
        id       => $id,
        slot     => 0+$vars{'Slot #'},
        model    => $vars{'Model Number'} =~ s/\s+/ /gr,
        capacity => "$capacity MB",
        state    => eval { $state_map->{$state}->() } // $state,
      )
    }
    else {
      ()
    }
  } split /\n+Device is a /, $self->_display_raw;

  return \@disks;
}

sub _build_virtual_disks {
  my ($self) = @_;

  return [];
}

requires qw(_get_controller_list_raw);

sub detect {
  my ($class) = @_;

  my $list_raw = $class->_get_controller_list_raw;
  return unless $list_raw;

  my @ids = $list_raw =~ m/^\s+(\d+)\s+.+/mg;

  return map { $class->new(id => $_) } @ids;
}

1;

package RAID::Info::Controller::SAS3IR;

use 5.014;
use namespace::autoclean;

use Moo;
use Type::Params qw(compile);
use Types::Standard qw(slurpy ClassName Dict Str);

with 'RAID::Info::Controller';

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

sub _build_virtual_disks {
  my ($self) = @_;

  return [];
}

1;

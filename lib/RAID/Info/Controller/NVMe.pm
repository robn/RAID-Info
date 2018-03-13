package RAID::Info::Controller::NVMe;

use 5.014;
use namespace::autoclean;

use Moo;
use Types::Standard qw(Str Int);

with 'RAID::Info::Controller';

use IPC::System::Simple qw(capturex EXIT_ANY);
use Try::Tiny;

has _list_raw => ( is => 'rw', isa => Str );

sub _load_data_from_controller {
  my ($self) = @_;

  my $list_raw = capturex(EXIT_ANY, qw(nvme list));
  $self->_list_raw($list_raw);
}

sub _build_name {
  return "nvme/0";
}

sub _build_physical_disks {
  my ($self) = @_;

  $self->_load_data_from_controller unless $self->_list_raw;

  my $slot = 1;

  my @disks = map {
    if (my ($dev, $serial, $model, $namespace, $capacity) =
      m{^/dev/(\S+)\s*(\w+)\s+([\w\s]+\w)\s+(\d)\s+(?:[\d\.]+\s+[MGT]B)\s+/\s+([\d\.]+\s+[MGT]B)}) {
      RAID::Info::PhysicalDisk->new(
        id       => $dev,
        slot     => $slot,
        model    => $model,
        capacity => $capacity,
        state    => RAID::Info::PhysicalDisk::State::Online->new,
      )
    }
    else {
      ()
    }
  } split '\n', $self->_list_raw;

  return \@disks;
}

sub _build_virtual_disks {
  my ($self) = @_;

  return [];
}

sub detect {
  my ($class) = @_;

  my $list_raw = try { capturex(EXIT_ANY, qw(nvme list)) };
  return unless $list_raw;

  return ($class->new);
}

1;

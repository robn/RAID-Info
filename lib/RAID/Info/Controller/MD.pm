package RAID::Info::Controller::MD;

use 5.014;

use Moo;
use Type::Params qw(compile);
use Types::Standard qw(slurpy ClassName Dict Optional Str ArrayRef);

with 'RAID::Info::Controller';

use IPC::System::Simple qw(capturex);
use Try::Tiny;

# hook for test suite
our $_PROC_MDSTAT = '/proc/mdstat';

has _mdstat_raw => ( is => 'rw', isa => Str );
has _detail_raw => ( is => 'rw', isa => ArrayRef[Str] );

sub _load_data_from_controller {
  my ($self) = @_;
  return if defined $self->_detail_raw;

  unless ($self->_mdstat_raw) {
    my $mdstat_raw = do { local (@ARGV, $/) = ($_PROC_MDSTAT); <> };
    $self->_mdstat_raw($mdstat_raw);
  }

  my $detail_raw = [
    map {
      scalar capturex(qw(mdadm --detail), "/dev/$_")
    } ($self->_mdstat_raw =~ m/^(md\w+)\s+:.+?/mg)
  ];
  $self->_detail_raw($detail_raw);
}

sub _build_name {
  return "md/0";
}

sub _build_physical_disks {
  my ($self) = @_;

  return [];
}

sub _build_virtual_disks {
  my ($self) = @_;

  $self->_load_data_from_controller;

  my %details = map {
    my ($device, @lines) = map { m/^\s*(.+?)\s*$/ } split /\n+/, $_;
    my ($md) = $device =~ m{(md\w+)};
    my %vars = map { m/:/ ? split '\s*:\s+', $_, 2 : () } @lines;
    $md => \%vars
  } @{$self->_detail_raw};

  state $state_map = {
    active                         => sub { RAID::Info::VirtualDisk::State::Normal->new },
    clean                          => sub { RAID::Info::VirtualDisk::State::Normal->new },
    inactive                       => sub { RAID::Info::VirtualDisk::State::Degraded->new },
    'clean, degraded'              => sub { RAID::Info::VirtualDisk::State::Degraded->new },
    'active, degraded'             => sub { RAID::Info::VirtualDisk::State::Degraded->new },
    'active, resyncing'            => sub { RAID::Info::VirtualDisk::State::Rebuilding->new(progress => shift) },
    'clean, resyncing'             => sub { RAID::Info::VirtualDisk::State::Rebuilding->new(progress => shift) },
    'active, degraded, recovering' => sub { RAID::Info::VirtualDisk::State::Rebuilding->new(progress => shift) },
    'clean, degraded, recovering'  => sub { RAID::Info::VirtualDisk::State::Rebuilding->new(progress => shift) },
    'active, resyncing (DELAYED)'  => sub { RAID::Info::VirtualDisk::State::Rebuilding->new(progress => 0) },
  };

  my @virtual = map {
    my $detail = $details{$_};
    my $state = $detail->{State};
    my ($progress) = ($detail->{'Resync Status'} // $detail->{'Rebuild Status'} // '') =~ m/^(\d+)\%/;
    RAID::Info::VirtualDisk->new(
      id       => $_,
      name     => $_,
      level    => $detail->{'Raid Level'},
      capacity => $detail->{'Array Size'} ? [$detail->{'Array Size'} =~ m/([\d\.]+ .B)/]->[0] : 0,
      state    => eval { $state_map->{$state}->($progress) } // $state,
    )
  } $self->_mdstat_raw =~ m/^(md\w+)\s*:/smg;

  return \@virtual;
}

sub detect {
  my ($class, %args) = @_;

  my $mdstat_raw = $args{_mdstat_raw} // try {
    -r $_PROC_MDSTAT ? do { local (@ARGV, $/) = ($_PROC_MDSTAT); <> } : ''
  };
  return unless $mdstat_raw;

  my $absent = $mdstat_raw ? $mdstat_raw =~ m/^Personalities\s+:\s*$/m : 1;

  return $absent ? () : ($class->new);
}

1;

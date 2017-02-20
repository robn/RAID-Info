package RAID::Info::Controller::MD;

use 5.014;
use namespace::autoclean;

use Moo;
use Type::Params qw(compile);
use Types::Standard qw(slurpy ClassName Dict Optional Str ArrayRef);

with 'RAID::Info::Controller';

use IPC::System::Simple qw(capturex);

has _mdstat_raw => ( is => 'rw', isa => Str );
has _detail_raw => ( is => 'rw', isa => ArrayRef[Str] );

sub _new_for_test {
  state $check = compile(
    ClassName,
    slurpy Dict[
      mdstat => Str,
      detail => ArrayRef[Str],
    ],
  );
  my ($class, $args) = $check->(@_);

  my $self = $class->new;
  $self->_mdstat_raw($args->{mdstat});
  $self->_detail_raw($args->{detail});

  return $self;
}

sub _load_data_from_controller {
  my ($self) = @_;
  return if defined $self->_mdstat_raw;

  my $mdstat_raw = do { local (@ARGV, $/) = ('/proc/mdstat.txt'); <> };
  my $detail_raw = [
    map {
      scalar capturex(qw(mdadm --detail), "/dev/$_")
    } ($mdstat_raw =~ m/^(md\w+)\s+:.+?/mg)
  ];

  $self->_mdstat_raw($mdstat_raw);
  $self->_detail_raw($detail_raw);
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
    active                        => sub { RAID::Info::VirtualDisk::State::Normal->new },
    clean                         => sub { RAID::Info::VirtualDisk::State::Normal->new },
    'active, resyncing'           => sub { RAID::Info::VirtualDisk::State::Rebuilding->new(progress => shift) },
    'active, resyncing (DELAYED)' => sub { RAID::Info::VirtualDisk::State::Rebuilding->new(progress => 0) },
  };

  my @virtual = map {
    my $detail = $details{$_};
    my $state = $detail->{State};
    my ($progress) = ($detail->{'Resync Status'} // '') =~ m/^(\d+)\%/;
    RAID::Info::VirtualDisk->new(
      id       => $_,
      name     => $_,
      level    => $detail->{'Raid Level'},
      capacity => [$detail->{'Array Size'} =~ m/([\d\.]+ .B)/]->[0],
      state    => eval { $state_map->{$state}->($progress) } // $state,
    )
  } $self->_mdstat_raw =~ m/^(md\w+)\s*:/smg;

  return \@virtual;
}

sub detect {
  state $check = compile(
    ClassName,
    slurpy Dict[
      _test => Optional[Str],
    ],
  );
  my ($class, $args) = $check->(@_);

  my $mdstat_raw = $args->{_test} // do {
    1 # cat /proc/mdstat
  };
  my $absent = $mdstat_raw =~ m/^Personalities\s+:\s*$/m;

  return $absent ? () : ($class->new);
}

1;

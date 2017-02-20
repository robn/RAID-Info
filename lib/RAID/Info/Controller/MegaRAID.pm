package RAID::Info::Controller::MegaRAID;

use 5.014;
use namespace::autoclean;

use Moo;
use Type::Params qw(compile);
use Types::Standard qw(slurpy ClassName Dict Optional Str Int);

with 'RAID::Info::Controller';

use IPC::System::Simple qw(capturex);

has id => ( is => 'ro', isa => Int, required => 1 );

has _ldpdinfo_raw => ( is => 'rw', isa => Str );

sub _new_for_test {
  state $check = compile(
    ClassName,
    slurpy Dict[
      ldpdinfo => Str,
    ],
  );
  my ($class, $args) = $check->(@_);

  my $self = $class->new(id => 0);
  $self->_ldpdinfo_raw($args->{ldpdinfo});

  return $self;
}

sub _load_data_from_controller {
  my ($self) = @_;
  return if defined $self->_ldpdinfo_raw;

  my $raw = capturex(qw(megacli -ldpdinfo), '-a'.$self->id);
  $self->_ldpdinfo_raw($raw);
}

sub _build_physical_disks {
  my ($self) = @_;

  $self->_load_data_from_controller;

  state $state_map = {
    'Online, Spun Up' => sub { RAID::Info::PhysicalDisk::State::Online->new },
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
        state    => eval { $state_map->{$state}->() } // $state,
      ))
    }
    else {
      ()
    }
  } split /\n+PD: \d+ Information\n+/, $self->_ldpdinfo_raw;

  return [ map { $disks{$_} } sort keys %disks ];
}

sub _build_virtual_disks {
  my ($self) = @_;

  $self->_load_data_from_controller;

  state $state_map = {
    Optimal => sub { RAID::Info::VirtualDisk::State::Normal->new },
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
      my $state = $vars{'State'};
      RAID::Info::VirtualDisk->new(
        id       => $id,
        name     => $name,
        level    => $level_map->{$level} // $level,
        capacity => $vars{'Size'},
        state    => eval { $state_map->{$state}->() } // $state,
      )
    }
    else {
      ()
    }
  } split /Virtual Drive: /, $self->_ldpdinfo_raw;

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

  my $adpallinfo_raw = $args->{_test} // do {
    1 # megacli -adpallinfo -aall
  };
  my @ids = $adpallinfo_raw =~ m/^Adapter\s+#(\d+).+/smg;

  return map { $class->new(id => $_) } @ids;
}

1;

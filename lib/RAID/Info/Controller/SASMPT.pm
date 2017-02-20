package RAID::Info::Controller::SASMPT;

use 5.014;
use namespace::autoclean;

use Moo;
use Type::Params qw(compile);
use Types::Standard qw(slurpy ClassName Dict Optional Str);

with 'RAID::Info::Controller';

use IPC::Open2;

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
  my ($self) = @_;
  return if defined $self->_lsiutil_raw;

  open2(my $out, my $in, 'lsiutil')
    or die "couldn't run 'lsiutil': $!";
  print $in "1\n21\n1\n2\n";
  close $in;
  my $raw = do { local $/; <$out> };
  close $out;

  $self->_lsiutil_raw($raw);
}

sub _build_physical_disks {
  my ($self) = @_;

  $self->_load_data_from_controller;

  state $state_map = {
    online => sub { RAID::Info::PhysicalDisk::State::Online->new },
  };

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
        state    => eval { $state_map->{$state}->() } // $state,
      )
    }
    else {
      ()
    }
  } split /\n+PhysDisk /, $self->_lsiutil_raw;

  return \@disks;
}

sub _build_virtual_disks {
  my ($self) = @_;

  $self->_load_data_from_controller;

  state $state_map = {
    'optimal, enabled' => sub { RAID::Info::VirtualDisk::State::Normal->new },
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
        state    => eval { $state_map->{$state}->() } // $state,
      )
    }
    else {
      ()
    }
  } split /\n+Volume /, $self->_lsiutil_raw;

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

  my $lsiutil_raw = $args->{_test} // do {
    open2(my $out, my $in, 'lsiutil')
      or return ();

    print $in "1\n21\n1\n2\n";
    close $in;
    my $raw = do { local $/; <$out> };
    close $out;

    $raw;
  };

  my @ids = $lsiutil_raw =~ m/^\s+(\d+)\.\s+\/.+/smg;

  die "no support for multiple SAS-MPT controllers; please contact the RAID-Info authors"
    if @ids >= 2;

  return map { $class->new } @ids;
}

1;

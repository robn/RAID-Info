package RAID::Info::Controller::Adaptec;

use 5.014;
use namespace::autoclean;

use Moo;
use Type::Params qw(compile);
use Types::Standard qw(slurpy ClassName Dict Optional Str Int);

with 'RAID::Info::Controller';

use IPC::System::Simple qw(capturex);

has id => ( is => 'ro', isa => Int, required => 1 );

has _getconfig_raw => ( is => 'rw', isa => Str );

sub _new_for_test {
  state $check = compile(
    ClassName,
    slurpy Dict[
      getconfig => Str,
    ],
  );
  my ($class, $args) = $check->(@_);

  my $self = $class->new(id => 1);
  $self->_getconfig_raw($args->{getconfig});

  return $self;
}

sub _load_data_from_controller {
  my ($self) = @_;
  return if defined $self->_getconfig_raw;

  my $raw = capturex(qw(arcconf getconfig), $self->id);
  $self->_getconfig_raw($raw);
}

sub _build_physical_disks {
  my ($self) = @_;

  $self->_load_data_from_controller;

  state $state_map = {
    Online => sub { RAID::Info::PhysicalDisk::State::Online->new },
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
        state    => eval { $state_map->{$state}->() } // $state,
      )
    }
    else {
      ()
    }
  } split /\s*Device #/, $physdev;
  return \@disks;
}

sub _build_virtual_disks {
  my ($self) = @_;

  $self->_load_data_from_controller;

  state $state_map = {
    Optimal => sub { RAID::Info::VirtualDisk::State::Normal->new },
  };

  my ($logidev) = $self->_getconfig_raw =~ m{Logical device information\s*\n-+\n(.+?)\n   -+}msg;
  my @virtual = map {
    my ($id, @lines) = map { m/^\s*(.+)\s*$/ } split /[\r\n]+/, $_;
    if (defined $id) {
      my %vars = map { split '\s+:\s+', $_ } @lines;
      my $level = $vars{'RAID level'},
      my $state = $vars{'Status of logical device'};
      RAID::Info::VirtualDisk->new(
        id       => $id,
        name     => $vars{'Logical device name'},
        level    => "raid$level",
        capacity => $vars{'Size'},
        state    => eval { $state_map->{$state}->() } // $state,
      )
    }
    else {
      ()
    }
  } split /Logical device number /, $logidev;

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

  my $version_raw = $args->{_test} // do {
    1 # arcconf getversion
  };
  my @ids = $version_raw =~ m/^Controller\s+#(\d+).+/smg;

  return map { $class->new(id => $_) } @ids;
}

1;

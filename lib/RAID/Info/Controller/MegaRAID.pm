package RAID::Info::Controller::MegaRAID;

use 5.014;
use namespace::autoclean;

use Moo;
use Types::Standard qw(Str Int);

with 'RAID::Info::Controller';

use IPC::System::Simple qw(capturex EXIT_ANY);
use Try::Tiny;

has id => ( is => 'ro', isa => Int, required => 1 );

has _ldpdinfo_raw => ( is => 'rw', isa => Str );

sub _load_data_from_controller {
  my ($self) = @_;
  return if defined $self->_ldpdinfo_raw;

  my $raw = capturex(qw(megacli -ldpdinfo), '-a'.$self->id);
  $self->_ldpdinfo_raw($raw);
}

sub _build_name {
  return "megaraid/".shift->id;
}

sub _build_physical_disks {
  my ($self) = @_;

  $self->_load_data_from_controller;

  state $state_map = {
    'Online, Spun Up' => sub { RAID::Info::PhysicalDisk::State::Online->new },
    'Failed'          => sub { RAID::Info::PhysicalDisk::State::Failed->new },
    'Rebuild'         => sub { RAID::Info::PhysicalDisk::State::Rebuilding->new(progress => shift) },
  };

  my %disks = map {
    my @lines = split /\n+/, $_;
    my %vars = map { m/:\s/ ? split '\s*:\s+', $_, 2 : () } @lines;
    if (exists $vars{'Device Id'}) {
      my $id = $vars{'Device Id'};
      my $capacity = [$vars{'Raw Size'} =~ m/^([\d\.]+ .B)/]->[0];
      my $state = $vars{'Firmware state'};
      my $progress;
      if ($state eq 'Rebuild') {
        my $enc = $vars{'Enclosure Device ID'};
        my $slot = $vars{'Slot Number'};
        # megacli -pdrbld -showprog -physdrv[32:10] -aall
        my $pdrbld_raw = capturex(EXIT_ANY, qw(megacli -pdrbld -showprog), "-physdrv[$enc:$slot]", qw(-aall));
        ($progress) = $pdrbld_raw =~ m/Completed (\d+)%/;
      }
      ($id => RAID::Info::PhysicalDisk->new(
        id       => $id,
        slot     => $vars{'Slot Number'},
        model    => $vars{'Inquiry Data'} =~ s/\s+/ /gr,
        capacity => $capacity,
        state    => eval { $state_map->{$state}->($progress) } // $state,
      ))
    }
    else {
      ()
    }
  } split /\n+PD: \d+ Information\n+/, $self->_ldpdinfo_raw;

  return [ map { $disks{$_} } sort { $a <=> $b } keys %disks ];
}

sub _build_virtual_disks {
  my ($self) = @_;

  $self->_load_data_from_controller;

  state $state_map = {
    Optimal              => sub { RAID::Info::VirtualDisk::State::Normal->new },
    'Partially Degraded' => sub { RAID::Info::VirtualDisk::State::Degraded->new },
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
      my @slots;
      my %vars = map {
        my ($k, $v) = m/:\s/ ? split '\s*:\s+', $_, 2 : ();
        if (defined $k && defined $v) {
          push @slots, $v if $k eq 'Slot Number';
          ($k, $v);
        }
        else {
          ()
        }
      } @lines;
      my $name  = $vars{Name} // '';
      my $level = $vars{'RAID Level'};
      my $state = $vars{'State'};
      my @phys = @{{ map { $_->{slot} => $_ } @{$self->physical_disks} }}{@slots};
      RAID::Info::Controller::MegaRAID::VirtualDisk->new(
        id             => $id,
        name           => $name,
        level          => $level_map->{$level} // $level,
        capacity       => $vars{'Size'},
        state          => eval { $state_map->{$state}->() } // $state,
        physical_disks => \@phys,
      )
    }
    else {
      ()
    }
  } split /Virtual Drive: /, $self->_ldpdinfo_raw;

  return \@virtual;
}

sub detect {
  my ($class) = @_;

  my $adpallinfo_raw = try { capturex(EXIT_ANY, qw(megacli -adpallinfo -aall)) };
  return unless $adpallinfo_raw;

  my @ids = $adpallinfo_raw =~ m/^Adapter\s+#(\d+).+/smg;

  return map { $class->new(id => $_) } @ids;
}


package RAID::Info::Controller::MegaRAID::VirtualDisk {

use namespace::autoclean;

use Moo;

extends 'RAID::Info::VirtualDisk';
with 'RAID::Info::Role::HasPhysicalDisks';

sub _build_physical_disks {
  # no op; we prove the list of disks in the constructor
  []
}

}

1;

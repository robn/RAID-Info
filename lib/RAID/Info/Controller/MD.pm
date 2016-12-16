package RAID::Info::Controller::MD;

use 5.014;
use namespace::autoclean;

use Moo;
use Type::Params qw(compile);
use Types::Standard qw(slurpy ClassName Dict Str ArrayRef);

with 'RAID::Info::Controller';

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
    clean => 'normal',
  };

  my @virtual = map {
    my $detail = $details{$_};

    RAID::Info::VirtualDisk->new(
      id       => $_,
      name     => $_,
      level    => $detail->{'Raid Level'},
      capacity => [$detail->{'Array Size'} =~ m/([\d\.]+ .B)/]->[0],
      state    => $state_map->{$detail->{State}} // $detail->{State},
    )
  } $self->_mdstat_raw =~ m/^(md\w+)\s*:/smg;

  return \@virtual;
}

1;

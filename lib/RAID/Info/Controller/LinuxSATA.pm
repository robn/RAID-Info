package RAID::Info::Controller::LinuxSATA;

use 5.014;
use namespace::autoclean;

use Moo::Role;
use Types::Standard qw(ArrayRef);

with 'RAID::Info::Controller';

use Path::Tiny;

requires qw(_sys_path);

has _sys_raw => ( is => 'rw', isa => ArrayRef[] );

sub _load_data_from_controller {
  my ($self) = @_;
  return if $self->_sys_raw;

  my @_raw_data;

  my $sys_path = $self->_sys_path;

  my @sys_dirs = <"$sys_path/*:*/ata*/host*/target*/*:*">;
  for my $base_path (map { path($_) } @sys_dirs) {
    my ($block_path) = $base_path->child("block")->children;
    next unless $block_path;

    my $block = $block_path->basename;
    my ($size) = $block_path->child("size")->lines({ chomp => 1, count => 1 });

    my %attrs = map {
      $_ => $base_path->child($_)->lines({ chomp => 1, count => 1 });
    } qw(state model);

    $attrs{block} = $block;
    $attrs{size}  = $size;

    push @_raw_data, \%attrs;
  }

  $self->_sys_raw(\@_raw_data);
}

sub _build_physical_disks {
  my ($self) = @_;

  $self->_load_data_from_controller;

  state $state_map = {
    running => sub { RAID::Info::PhysicalDisk::State::Online->new },
  };

  my $slot = 1;

  my @disks = map {
    RAID::Info::PhysicalDisk->new(
      id       => $_->{block},
      slot     => $slot++,
      model    => $_->{model},
      capacity => $_->{size} * 512,
      state    => eval { $state_map->{$_->{state}}->() } // $_->{state},
    )
  } @{$self->_sys_raw};

  return \@disks;
}

sub _build_virtual_disks {
  my ($self) = @_;
  return [];
}

sub detect {
  my ($class, %args) = @_;

  return path($class->_sys_path)->is_dir ? ($class->new) : ();
}

1;

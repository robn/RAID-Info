#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

use RAID::Info::Controller::MD;

use FindBin;
$ENV{PATH} = "$FindBin::Bin/bin:$ENV{PATH}";

# first test set
{
  $ENV{RI_MDADM_DATA_ID} = '1';
  my $c = RAID::Info::Controller::MD->new(
    _mdstat_raw => do { local (@ARGV, $/) = ('t/data/mdstat-1.txt'); <> },
  );
  is $c->name, "md/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 0, '0 physical disks';

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 4, '4 virtual disks';
  is ref($virtual->[$_]->state), [
    ('RAID::Info::VirtualDisk::State::Normal') x 4
  ]->[$_], "virtual disk $_ has correct state" for (0..3);
  is $virtual->[$_]->state->as_string, [
    ('normal') x 4,
  ]->[$_], "virtual disk $_ has correct state string" for (0..3);
  is int($virtual->[$_]->capacity), [
    399950000000,
    399940000000,
    981200000000,
    16770000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..3);
  is $virtual->[$_]->level, [qw(
    raid1
    raid1
    raid1
    raid1
  )]->[$_], "virtual disk $_ has correct raid level" for (0..3);
  is !!$virtual->[$_]->state->is_abnormal, !![
    0,
    0,
    0,
    0,
  ]->[$_], "virtual disk $_ has correct abnormal state" for (0..3);
}

# second test set
{
  $ENV{RI_MDADM_DATA_ID} = '2';
  my $c = RAID::Info::Controller::MD->new(
    _mdstat_raw => do { local (@ARGV, $/) = ('t/data/mdstat-2.txt'); <> },
  );
  is $c->name, "md/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 0, '0 physical disks';

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 4, '4 virtual disks';
  is ref($virtual->[$_]->state), [
    'RAID::Info::VirtualDisk::State::Rebuilding',
    'RAID::Info::VirtualDisk::State::Rebuilding',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
  ]->[$_], "virtual disk $_ has correct state" for (0..3);
  is $virtual->[$_]->state->as_string, [
    'rebuilding (0%)',
    'rebuilding (35%)',
    ('normal') x 2,
  ]->[$_], "virtual disk $_ has correct state string" for (0..3);
  is int($virtual->[$_]->capacity), [
    399950000000,
    399940000000,
    981200000000,
    16770000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..3);
  is $virtual->[$_]->level, [qw(
    raid1
    raid1
    raid1
    raid1
  )]->[$_], "virtual disk $_ has correct raid level" for (0..3);
  is !!$virtual->[$_]->state->is_abnormal, !![
    1,
    1,
    0,
    0,
  ]->[$_], "virtual disk $_ has correct abnormal state" for (0..3);
  is $virtual->[0]->state->progress, 0,  "virtual disk 0 is in rebuild with correct progress";
  is $virtual->[1]->state->progress, 35, "virtual disk 1 is in rebuild with correct progress";
}

# third test set
{
  $ENV{RI_MDADM_DATA_ID} = '3';
  my $c = RAID::Info::Controller::MD->new(
    _mdstat_raw => do { local (@ARGV, $/) = ('t/data/mdstat-3.txt'); <> },
  );
  is $c->name, "md/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 0, '0 physical disks';

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 4, '4 virtual disks';
  is ref($virtual->[$_]->state), [
    'RAID::Info::VirtualDisk::State::Rebuilding',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
  ]->[$_], "virtual disk $_ has correct state" for (0..3);
  is int($virtual->[$_]->capacity), [
    3000400000000,
    3000400000000,
    399950000000,
    399950000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..3);
  is $virtual->[$_]->level, [qw(
    raid10
    raid10
    raid1
    raid1
  )]->[$_], "virtual disk $_ has correct raid level" for (0..3);
  is !!$virtual->[$_]->state->is_abnormal, !![
    1,
    0,
    0,
    0,
  ]->[$_], "virtual disk $_ has correct abnormal state" for (0..3);
  is $virtual->[0]->state->progress, 81,  "virtual disk 0 is in rebuild with correct progress";
}

# detect test
{
  my @controllers = RAID::Info::Controller::MD->detect(
    _mdstat_raw => do { local (@ARGV, $/) = ('t/data/mdstat-1.txt'); <> },
  );
  is scalar @controllers, 1, '1 controller';

  my ($c) = @controllers;
  is $c->name, "md/0", "controller has correct name";
}

# detect test 2, no devices
{
  my @controllers = RAID::Info::Controller::MD->detect(
    _mdstat_raw => do { local (@ARGV, $/) = ('t/data/mdstat-empty.txt'); <> },
  );
  is scalar @controllers, 0, '0 controllers';
}


done_testing;

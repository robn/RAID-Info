#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

use RAID::Info::Controller::Areca;

# first test set
{
  my $c = RAID::Info::Controller::Areca->_new_for_test(
    hw   => do { local (@ARGV, $/) = ('t/data/cli64-hw-info.txt'); <> },
    disk => do { local (@ARGV, $/) = ('t/data/cli64-disk-info.txt'); <> },
    vsf  => do { local (@ARGV, $/) = ('t/data/cli64-vsf-info.txt'); <> },
  );

  my $physical = $c->physical_disks;
  is scalar @$physical, 24, '24 physical disks';
  is int($physical->[$_]->capacity), [
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
  ]->[$_], "physical disk $_ has correct capacity" for (0..23);
  is !!$physical->[$_]->state->is_abnormal, !![
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..23);

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 2, '2 virtual disks';
  is int($virtual->[$_]->capacity), [
    40000000000000,
    40000000000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..1);
  is $virtual->[$_]->level, [qw(
    raid6
    raid6
  )]->[$_], "virtual disk $_ has correct raid level" for (0..1);
  is $virtual->[$_]->raid_name, [
    'i21r1',
    'i21r2',
  ]->[$_], "virtual disk $_ has correct raid name" for (0..1);
  is !!$virtual->[$_]->state->is_abnormal, !![
    0,
    0,
  ]->[$_], "virtual disk $_ has correct abnormal state" for (0..1);
}

# second test set
{
  my $c = RAID::Info::Controller::Areca->_new_for_test(
    hw   => do { local (@ARGV, $/) = ('t/data/cli64-hw-info-2.txt'); <> },
    disk => do { local (@ARGV, $/) = ('t/data/cli64-disk-info-2.txt'); <> },
    vsf  => do { local (@ARGV, $/) = ('t/data/cli64-vsf-info-2.txt'); <> },
  );

  my $physical = $c->physical_disks;
  is scalar @$physical, 24, '24 physical disks';
  is int($physical->[$_]->capacity), [
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
  ]->[$_], "physical disk $_ has correct capacity" for (0..23);
  is !!$physical->[$_]->state->is_abnormal, !![
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..23);

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 2, '2 virtual disks';
  is int($virtual->[$_]->capacity), [
    40000000000000,
    40000000000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..1);
  is $virtual->[$_]->level, [qw(
    raid6
    raid6
  )]->[$_], "virtual disk $_ has correct raid level" for (0..1);
  is $virtual->[$_]->raid_name, [
    'Raid Set # 000',
    'Raid Set # 001',
  ]->[$_], "virtual disk $_ has correct raid name" for (0..1);
  is !!$virtual->[$_]->state->is_abnormal, !![
    0,
    1,
  ]->[$_], "virtual disk $_ has correct abnormal state" for (0..1);
  is $virtual->[1]->state->progress, 35.3, "virtual disk 1 is in rebuild with correct progress";
}

# third test set
{
  my $c = RAID::Info::Controller::Areca->_new_for_test(
    hw   => do { local (@ARGV, $/) = ('t/data/cli64-hw-info-3.txt'); <> },
    disk => do { local (@ARGV, $/) = ('t/data/cli64-disk-info-3.txt'); <> },
    vsf  => do { local (@ARGV, $/) = ('t/data/cli64-vsf-info-3.txt'); <> },
  );

  my $physical = $c->physical_disks;
  is scalar @$physical, 12, '24 physical disks';
  is int($physical->[$_]->capacity), [
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
  ]->[$_], "physical disk $_ has correct capacity" for (0..11);
  is !!$physical->[$_]->state->is_abnormal, !![
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..11);

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 2, '2 virtual disks';
  is int($virtual->[$_]->capacity), [
    1000000000000,
    19000000000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..1);
  is $virtual->[$_]->level, [qw(
    raid6
    raid6
  )]->[$_], "virtual disk $_ has correct raid level" for (0..1);
  is $virtual->[$_]->raid_name, [
    'Raid Set # 000',
    'Raid Set # 000',
  ]->[$_], "virtual disk $_ has correct raid name" for (0..1);
  is !!$virtual->[$_]->state->is_abnormal, !![
    0,
    0,
  ]->[$_], "virtual disk $_ has correct abnormal state" for (0..1);
}

# detect test
{
  my @controllers = RAID::Info::Controller::Areca->detect(
    _test => do { local (@ARGV, $/) = ('t/data/cli64-main.txt'); <> },
  );
  is scalar @controllers, 1, '1 controller';
}

done_testing;

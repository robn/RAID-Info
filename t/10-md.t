#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

use RAID::Info::Controller::MD;

# first test set
{
  my $c = RAID::Info::Controller::MD->_new_for_test(
    mdstat => do { local (@ARGV, $/) = ('t/data/mdstat.txt'); <> },
    detail => [
      map {
        do { local (@ARGV, $/) = ("t/data/mdadm-detail-$_.txt"); <> }
      } qw(md0 md1 md2 md3)
    ],
  );

  my $physical = $c->physical_disks;
  is scalar @$physical, 0, '0 physical disks';

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 4, '4 virtual disks';
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
  my $c = RAID::Info::Controller::MD->_new_for_test(
    mdstat => do { local (@ARGV, $/) = ('t/data/mdstat-rebuild.txt'); <> },
    detail => [
      map {
        do { local (@ARGV, $/) = ("t/data/mdadm-detail-$_-rebuild.txt"); <> }
      } qw(md0 md1 md2 md3)
    ],
  );

  my $physical = $c->physical_disks;
  is scalar @$physical, 0, '0 physical disks';

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 4, '4 virtual disks';
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

# detect test
{
  my @controllers = RAID::Info::Controller::MD->detect(
    _test => do { local (@ARGV, $/) = ('t/data/mdstat.txt'); <> },
  );
  is scalar @controllers, 1, '1 controller';
}

# detect test 2, no devices
{
  my @controllers = RAID::Info::Controller::MD->detect(
    _test => do { local (@ARGV, $/) = ('t/data/mdstat-empty.txt'); <> },
  );
  is scalar @controllers, 0, '0 controllers';
}


done_testing;

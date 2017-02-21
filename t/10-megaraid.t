#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

use RAID::Info::Controller::MegaRAID;

# first test set
{
  my $c = RAID::Info::Controller::MegaRAID->_new_for_test(
    ldpdinfo => do { local (@ARGV, $/) = ('t/data/megacli-ldpdinfo.txt'); <> },
  );

  my $physical = $c->physical_disks;
  is scalar @$physical, 14, '14 physical disks';
  is int($physical->[$_]->capacity), [
    1819000000000,
    1819000000000,
    1819000000000,
    1819000000000,
    372611000000,
    372611000000,
    1819000000000,
    1819000000000,
    1819000000000,
    1819000000000,
    1819000000000,
    1819000000000,
    1819000000000,
    1819000000000,
  ]->[$_], "physical disk $_ has correct capacity" for (0..13);
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
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..13);

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 4, '4 virtual disks';
  is int($virtual->[$_]->capacity), [
    466000000000,
    1363000000000,
    14550000000000,
    372000000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..3);
  is $virtual->[$_]->level, [qw(
    raid1
    raid1
    raid6
    raid1
  )]->[$_], "virtual disk $_ has correct raid level" for (0..3);
  is !!$virtual->[$_]->state->is_abnormal, !![
    0,
    0,
    0,
    0,
  ]->[$_], "virtual disk $_ has correct abnormal state" for (0..3);
}

# detect test
{
  my @controllers = RAID::Info::Controller::MegaRAID->detect(
    _test => do { local (@ARGV, $/) = ('t/data/megacli-adpallinfo.txt'); <> },
  );
  is scalar @controllers, 1, '1 controller';
}

done_testing;
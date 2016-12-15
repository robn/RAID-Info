#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

use RAID::Info::Areca;

# first test set
{
  my $c = RAID::Info::Areca->_new_for_test(
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

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 2, '2 virtual disks';
  is int($virtual->[$_]->capacity), [
    40000000000000,
    40000000000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..1);
}

# second test set
{
  my $c = RAID::Info::Areca->_new_for_test(
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

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 2, '2 virtual disks';
  is int($virtual->[$_]->capacity), [
    40000000000000,
    40000000000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..1);
}

done_testing;

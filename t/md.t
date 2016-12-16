#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

use RAID::Info::MD;

my $c = RAID::Info::MD->_new_for_test(
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

done_testing;

#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

use RAID::Info::MegaRAID;

my $c = RAID::Info::MegaRAID->_new_for_test(
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

done_testing;

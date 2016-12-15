#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

use RAID::Info::SASMPT;

my $c = RAID::Info::SASMPT->_new_for_test(
  lsiutil => do { local (@ARGV, $/) = ('t/data/lsiutil.txt'); <> },
);

my $physical = $c->physical_disks;
is scalar @$physical, 2, '2 physical disks';
is int($physical->[$_]->{capacity}), [
  238,
  238,
]->[$_], "physical disk $_ has correct capacity" for (0..1);

my $virtual = $c->virtual_disks;
is scalar @$virtual, 1, '1 virtual disks';
is int($virtual->[$_]->{capacity}), [
  237,
]->[$_], "virtual disk $_ has correct capacity" for (0);

done_testing;

#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

use RAID::Info::SAS2IR;

my $c = RAID::Info::SAS2IR->_new_for_test(
  display => do { local (@ARGV, $/) = ('t/data/sas2ircu-display.txt'); <> },
);

my $physical = $c->physical_disks;
is scalar @$physical, 12, '12 physical disks';
is int($physical->[$_]->{capacity}), [
  465,
  465,
  372,
  1863,
  1863,
  372,
  1863,
  1863,
  372,
  1863,
  1863,
  372,
]->[$_], "physical disk $_ has correct capacity" for (0..11);

my $virtual = $c->virtual_disks;
is scalar @$virtual, 0, '0 virtual disks';

done_testing;

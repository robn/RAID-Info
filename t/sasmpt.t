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

my $virtual = $c->virtual_disks;
is scalar @$virtual, 1, '1 virtual disks';

done_testing;

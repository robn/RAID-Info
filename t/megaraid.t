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

my $virtual = $c->virtual_disks;
is scalar @$virtual, 4, '4 virtual disks';

done_testing;

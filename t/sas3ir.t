#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

use RAID::Info::SAS3IR;

my $c = RAID::Info::SAS3IR->_new_for_test(
  display => do { local (@ARGV, $/) = ('t/data/sas3ircu-display.txt'); <> },
);

my $physical = $c->physical_disks;
is scalar @$physical, 11, '11 physical disks';

my $virtual = $c->virtual_disks;
is scalar @$virtual, 0, '0 virtual disks';

done_testing;

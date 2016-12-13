#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

use RAID::Info::Adaptec;

my $c = RAID::Info::Adaptec->_new_for_test(
  getconfig => do { local (@ARGV, $/) = ('t/data/arcconf-getconfig.txt'); <> },
);

my $physical = $c->physical_disks;
is scalar @$physical, 2, '2 physical disks';

my $virtual = $c->virtual_disks;
is scalar @$virtual, 1, '1 virtual disk';

done_testing;

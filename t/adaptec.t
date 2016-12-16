#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use Test::Deep;

use RAID::Info::Controller::Adaptec;

my $c = RAID::Info::Controller::Adaptec->_new_for_test(
  getconfig => do { local (@ARGV, $/) = ('t/data/arcconf-getconfig.txt'); <> },
);

my $physical = $c->physical_disks;
is scalar @$physical, 2, '2 physical disks';
is int($physical->[$_]->capacity), [
  152627000000,
  152627000000,
]->[$_], "physical disk $_ has correct capacity" for (0..1);
is $physical->[$_]->state, [qw(
  online
  online
)]->[$_], "physical disk $_ has correct state" for (0..1);


my $virtual = $c->virtual_disks;
is scalar @$virtual, 1, '1 virtual disk';
is int($virtual->[$_]->capacity), [
  152500000000,
]->[$_], "virtual disk $_ has correct capacity" for (0);
is $virtual->[$_]->level, [qw(
  raid1
)]->[$_], "virtual disk $_ has correct raid level" for (0);
is $virtual->[$_]->state, [qw(
  normal
)]->[$_], "virtual disk $_ has correct state" for (0);

done_testing;

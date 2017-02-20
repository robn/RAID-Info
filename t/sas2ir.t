#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

use RAID::Info::Controller::SAS2IR;

# disk test
{
  my $c = RAID::Info::Controller::SAS2IR->_new_for_test(
    display => do { local (@ARGV, $/) = ('t/data/sas2ircu-display.txt'); <> },
  );

  my $physical = $c->physical_disks;
  is scalar @$physical, 12, '12 physical disks';
  is int($physical->[$_]->capacity), [
    476940000000,
    476940000000,
    381554000000,
    1907729000000,
    1907729000000,
    381554000000,
    1907729000000,
    1907729000000,
    381554000000,
    1907729000000,
    1907729000000,
    381554000000,
  ]->[$_], "physical disk $_ has correct capacity" for (0..11);
  is !!$physical->[$_]->state->is_abnormal, !![
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..11);

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 0, '0 virtual disks';
}

# detect test
{
  my @controllers = RAID::Info::Controller::SAS2IR->detect(
    _test => do { local (@ARGV, $/) = ('t/data/sas2ircu-list.txt'); <> },
  );
  is scalar @controllers, 1, '1 controller';
}

done_testing;

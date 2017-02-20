#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

use RAID::Info::Controller::SAS3IR;

use FindBin;
$ENV{PATH} = "$FindBin::Bin/bin:$ENV{PATH}";

# disk test
{
  my $c = RAID::Info::Controller::SAS3IR->new(id => 0);

  my $physical = $c->physical_disks;
  is scalar @$physical, 11, '11 physical disks';
  is int($physical->[$_]->capacity), [
    1907729000000,
    763097000000,
    3815447000000,
    3815447000000,
    763097000000,
    3815447000000,
    3815447000000,
    763097000000,
    3815447000000,
    3815447000000,
    763097000000,
  ]->[$_], "physical disk $_ has correct capacity" for (0..10);
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
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..10);

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 0, '0 virtual disks';
}

# detect test
{
  my @controllers = RAID::Info::Controller::SAS3IR->detect;
  is scalar @controllers, 1, '1 controller';
}

done_testing;

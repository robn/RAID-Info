#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

use RAID::Info::Controller::SAS3IR;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::RAID::Info::Mock;

# disk test
{
  my $c = RAID::Info::Controller::SAS3IR->new(id => 0);
  is $c->name, "sas3ir/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 11, '11 physical disks';
  is ref($physical->[$_]->state), [
    ('RAID::Info::PhysicalDisk::State::Online') x 11
  ]->[$_], "physical disk $_ has correct state" for (0..10);
  is $physical->[$_]->state->as_string, [
    ('online') x 11,
  ]->[$_], "physical disk $_ has correct state string" for (0..10);
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
    (0) x 11,
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..10);

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 0, '0 virtual disks';
}

# detect test
{
  my @controllers = RAID::Info::Controller::SAS3IR->detect;
  is scalar @controllers, 1, '1 controller';

  my ($c) = @controllers;
  is $c->name, "sas3ir/0", "controller has correct name";
}

done_testing;

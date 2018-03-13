#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

use RAID::Info::Controller::NVMe;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::RAID::Info::Mock;

# disk test
{
  my $c = RAID::Info::Controller::NVMe->new(id => 0);
  is $c->name, "nvme/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 2, '2 physical disks';
  is ref($physical->[$_]->state), [
    ('RAID::Info::PhysicalDisk::State::Online') x 2
  ]->[$_], "physical disk $_ has correct state" for (0..1);
  is $physical->[$_]->state->as_string, [
    ('online') x 2,
  ]->[$_], "physical disk $_ has correct state string" for (0..1);
  is int($physical->[$_]->capacity), [
    (1600000000000) x 2,
  ]->[$_], "physical disk $_ has correct capacity" for (0..1);
  is !!$physical->[$_]->state->is_abnormal, !![
    (0) x 2,
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..1);

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 0, '0 virtual disks';
}

# detect test
{
  my @controllers = RAID::Info::Controller::NVMe->detect;
  is scalar @controllers, 1, '1 controller';

  my ($c) = @controllers;
  is $c->name, "nvme/0", "controller has correct name";
}

done_testing;

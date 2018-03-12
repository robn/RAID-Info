#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use Test::Deep;

use RAID::Info::Controller::LinuxAHCI;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::RAID::Info::Mock;

# set 1, vagrant
{
  my $c = RAID::Info::Controller::LinuxAHCI->new;
  is $c->name, "linuxahci/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 1, '1 physical disk';
  is ref($physical->[$_]->state), [
    'RAID::Info::PhysicalDisk::State::Online',
  ]->[$_], "physical disk $_ has correct state" for (0);
  is $physical->[$_]->state->as_string, [
    'online',
  ]->[$_], "physical disk $_ has correct state string" for (0);
  is int($physical->[$_]->capacity), [
    42949672960,
  ]->[$_], "physical disk $_ has correct capacity" for (0);
  is !!$physical->[$_]->state->is_abnormal, !![
    0,
  ]->[$_], "physical disk $_ has correct abnormal state" for (0);


  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 0, '0 virtual disks';
}

# detect test
{
  my @controllers = RAID::Info::Controller::LinuxAHCI->detect;
  is scalar @controllers, 1, '1 controller';

  my ($c) = @controllers;
  is $c->name, "linuxahci/0", "controller has correct name";
}

done_testing;

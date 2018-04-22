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
  Test::RAID::Info::Mock->import(linuxahci => 1);

  my $c = RAID::Info::Controller::LinuxAHCI->new;
  is $c->name, "linuxahci/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 1, '1 physical disk';
  is $physical->[$_]->slot, [
    1,
  ]->[$_], "physical disk $_ has correct slot" for (0);
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

# set 2, two SSDs
{
  Test::RAID::Info::Mock->import(linuxahci => 2);

  my $c = RAID::Info::Controller::LinuxAHCI->new;
  is $c->name, "linuxahci/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 2, '2 physical disks';
  is $physical->[$_]->slot, [
    1, 2,
  ]->[$_], "physical disk $_ has correct slot" for (0..1);
  is ref($physical->[$_]->state), [
    ('RAID::Info::PhysicalDisk::State::Online') x 2,
  ]->[$_], "physical disk $_ has correct state" for (0..1);
  is $physical->[$_]->state->as_string, [
    ('online') x 2,
  ]->[$_], "physical disk $_ has correct state string" for (0..1);
  is int($physical->[$_]->capacity), [
    (480103981056) x 2,
  ]->[$_], "physical disk $_ has correct capacity" for (0..1);
  is !!$physical->[$_]->state->is_abnormal, !![
    (0) x 2,
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..1);

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

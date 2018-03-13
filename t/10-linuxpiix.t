#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use Test::Deep;

use RAID::Info::Controller::LinuxPIIX;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::RAID::Info::Mock;

# set 1, old ICH10
{
  Test::RAID::Info::Mock->import(linuxpiix => 1);

  my $c = RAID::Info::Controller::LinuxPIIX->new;
  is $c->name, "linuxpiix/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 3, '3 physical disks';
  is ref($physical->[$_]->state), [
    ('RAID::Info::PhysicalDisk::State::Online') x 3,
  ]->[$_], "physical disk $_ has correct state" for (0..2);
  is $physical->[$_]->state->as_string, [
    ('online') x 3,
  ]->[$_], "physical disk $_ has correct state string" for (0..2);
  is int($physical->[$_]->capacity), [
    1073741312,
    (400088457216) x 2,
  ]->[$_], "physical disk $_ has correct capacity" for (0..2);
  is !!$physical->[$_]->state->is_abnormal, !![
    (0) x 3,
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..2);


  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 0, '0 virtual disks';
}

# detect test
{
  my @controllers = RAID::Info::Controller::LinuxPIIX->detect;
  is scalar @controllers, 1, '1 controller';

  my ($c) = @controllers;
  is $c->name, "linuxpiix/0", "controller has correct name";
}

done_testing;

#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

use RAID::Info::Controller::MegaRAID;

use FindBin;
$ENV{PATH} = "$FindBin::Bin/bin:$ENV{PATH}";

# first test set
{
  $ENV{RI_MEGACLI_DATA_ID} = "1";
  my $c = RAID::Info::Controller::MegaRAID->new(id => 0);
  is $c->name, "megaraid/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 14, '14 physical disks';
  is int($physical->[$_]->capacity), [
    1819000000000,
    1819000000000,
    1819000000000,
    1819000000000,
    372611000000,
    372611000000,
    1819000000000,
    1819000000000,
    1819000000000,
    1819000000000,
    1819000000000,
    1819000000000,
    1819000000000,
    1819000000000,
  ]->[$_], "physical disk $_ has correct capacity" for (0..13);
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
    0,
    0,
    0,
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..13);

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 4, '4 virtual disks';
  is int($virtual->[$_]->capacity), [
    466000000000,
    1363000000000,
    14550000000000,
    372000000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..3);
  is $virtual->[$_]->level, [qw(
    raid1
    raid1
    raid6
    raid1
  )]->[$_], "virtual disk $_ has correct raid level" for (0..3);
  is !!$virtual->[$_]->state->is_abnormal, !![
    0,
    0,
    0,
    0,
  ]->[$_], "virtual disk $_ has correct abnormal state" for (0..3);
}

# detect test
{
  $ENV{RI_MEGACLI_DATA_ID} = "1";
  my @controllers = RAID::Info::Controller::MegaRAID->detect;
  is scalar @controllers, 1, '1 controller';

  my ($c) = @controllers;
  is $c->name, "megaraid/0", "controller has correct name";
}

done_testing;

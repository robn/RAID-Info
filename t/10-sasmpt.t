#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

use RAID::Info::Controller::SASMPT;

use FindBin;
$ENV{PATH} = "$FindBin::Bin/bin:$ENV{PATH}";

# disk test
{
  $ENV{RI_LSIUTIL_DATA_ID} = '1';
  my $c = RAID::Info::Controller::SASMPT->new;
  is $c->name, "sasmpt/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 2, '2 physical disks';
  is int($physical->[$_]->capacity), [
    238475000000,
    238475000000,
  ]->[$_], "physical disk $_ has correct capacity" for (0..1);
  is !!$physical->[$_]->state->is_abnormal, !![
    0,
    0,
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..1);

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 1, '1 virtual disks';
  is int($virtual->[$_]->capacity), [
    237952000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0);
  is $virtual->[$_]->level, [qw(
    raid1
  )]->[$_], "virtual disk $_ has correct raid level" for (0);
  is !!$virtual->[$_]->state->is_abnormal, !![
    0,
  ]->[$_], "virtual disk $_ has correct abnormal state" for (0);
}

# detect test
{
  $ENV{RI_LSIUTIL_DATA_ID} = '2';
  my @controllers = RAID::Info::Controller::SASMPT->detect;
  is scalar @controllers, 1, '1 controller';

  my ($c) = @controllers;
  is $c->name, "sasmpt/0", "controller has correct name";
}

done_testing;

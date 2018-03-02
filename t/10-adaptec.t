#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use Test::Deep;

use RAID::Info::Controller::Adaptec;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::RAID::Info::Mock;

# disk test
{
  my $c = RAID::Info::Controller::Adaptec->new(id => 1);
  is $c->name, "adaptec/1", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 2, '2 physical disks';
  is ref($physical->[$_]->state), [
    ('RAID::Info::PhysicalDisk::State::Online') x 2
  ]->[$_], "physical disk $_ has correct state" for (0..1);
  is $physical->[$_]->state->as_string, [
    ('online') x 2
  ]->[$_], "physical disk $_ has correct state string" for (0..1);
  is int($physical->[$_]->capacity), [
    152627000000,
    152627000000,
  ]->[$_], "physical disk $_ has correct capacity" for (0..1);
  is !!$physical->[$_]->state->is_abnormal, !![
    0,
    0,
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..1);


  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 1, '1 virtual disk';
  is ref($virtual->[$_]->state), [
    'RAID::Info::VirtualDisk::State::Normal'
  ]->[$_], "virtual disk $_ has correct state" for (0);
  is $virtual->[$_]->state->as_string, [qw(
    normal
  )]->[$_], "virtual disk $_ has correct state string" for (0);
  is int($virtual->[$_]->capacity), [
    152500000000,
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
  my @controllers = RAID::Info::Controller::Adaptec->detect;
  is scalar @controllers, 1, '1 controller';

  my ($c) = @controllers;
  is $c->name, "adaptec/1", "controller has correct name";
}

done_testing;

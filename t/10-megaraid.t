#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

use RAID::Info::Controller::MegaRAID;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::RAID::Info::Mock;

# first test set
{
  Test::RAID::Info::Mock->import(megacli => 1);

  my $c = RAID::Info::Controller::MegaRAID->new(id => 0);
  is $c->name, "megaraid/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 14, '14 physical disks';
  is ref($physical->[$_]->state), [
    ('RAID::Info::PhysicalDisk::State::Online') x 14
  ]->[$_], "physical disk $_ has correct state" for (0..13);
  is $physical->[$_]->state->as_string, [
    ('online') x 14
  ]->[$_], "physical disk $_ has correct state string" for (0..13);
  is int($physical->[$_]->capacity), [
    (1819000000000) x 4,
    (372611000000) x 2,
    (1819000000000) x 8,
  ]->[$_], "physical disk $_ has correct capacity" for (0..13);
  is !!$physical->[$_]->state->is_abnormal, !![
    (0) x 14,
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..13);

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 4, '4 virtual disks';
  is ref($virtual->[$_]->state), [
    ('RAID::Info::VirtualDisk::State::Normal') x 4
  ]->[$_], "virtual disk $_ has correct state" for (0..3);
  is $virtual->[$_]->state->as_string, [
    ('normal') x 4,
  ]->[$_], "virtual disk $_ has correct state string" for (0..3);
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


# second test set
{
  Test::RAID::Info::Mock->import(megacli => 2);

  my $c = RAID::Info::Controller::MegaRAID->new(id => 0);
  is $c->name, "megaraid/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 14, '14 physical disks';
  is ref($physical->[$_]->state), [
    ('RAID::Info::PhysicalDisk::State::Online') x 2,
    'RAID::Info::PhysicalDisk::State::Failed',
    ('RAID::Info::PhysicalDisk::State::Online') x 11,
  ]->[$_], "physical disk $_ has correct state" for (0..13);
  is $physical->[$_]->state->as_string, [
    ('online') x 2,
    'failed',
    ('online') x 11,
  ]->[$_], "physical disk $_ has correct state string" for (0..13);
  is int($physical->[$_]->capacity), [
    (1819000000000) x 4,
    (372611000000)  x 2,
    (1819000000000) x 8,
  ]->[$_], "physical disk $_ has correct capacity" for (0..13);
  is !!$physical->[$_]->state->is_abnormal, !![
    0, 0, 1, 0,
    (0) x 2,
    (0) x 8,
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..13);

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 4, '4 virtual disks';
  is ref($virtual->[$_]->state), [
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Degraded',
    'RAID::Info::VirtualDisk::State::Normal',
  ]->[$_], "virtual disk $_ has correct state" for (0..3);
  is $virtual->[$_]->state->as_string, [
    ('normal') x 2,
    'degraded',
    'normal',
  ]->[$_], "virtual disk $_ has correct state string" for (0..3);
  is int($virtual->[$_]->capacity), [
    415000000000,
    1413000000000,
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
    1,
    0,
  ]->[$_], "virtual disk $_ has correct abnormal state" for (0..3);
}

# third test set
{
  Test::RAID::Info::Mock->import(megacli => 3);

  my $c = RAID::Info::Controller::MegaRAID->new(id => 0);
  is $c->name, "megaraid/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 14, '14 physical disks';
  is ref($physical->[$_]->state), [
    ('RAID::Info::PhysicalDisk::State::Online') x 2,
    'RAID::Info::PhysicalDisk::State::Rebuilding',
    ('RAID::Info::PhysicalDisk::State::Online') x 11,
  ]->[$_], "physical disk $_ has correct state" for (0..13);
  is $physical->[$_]->state->as_string, [
    ('online') x 2,
    'rebuilding (3%)',
    ('online') x 11,
  ]->[$_], "physical disk $_ has correct state string" for (0..13);
  is int($physical->[$_]->capacity), [
    (1819000000000) x 4,
    (372611000000)  x 2,
    (1819000000000) x 8,
  ]->[$_], "physical disk $_ has correct capacity" for (0..13);
  is !!$physical->[$_]->state->is_abnormal, !![
    0, 0, 1, 0,
    (0) x 2,
    (0) x 8,
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..13);
  is $physical->[2]->state->progress, 3, "physical disk 2 is in rebuild with correct progress";

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 4, '4 virtual disks';
  is ref($virtual->[$_]->state), [
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Degraded',
    'RAID::Info::VirtualDisk::State::Normal',
  ]->[$_], "virtual disk $_ has correct state" for (0..3);
  is $virtual->[$_]->state->as_string, [
    ('normal') x 2,
    'degraded',
    'normal',
  ]->[$_], "virtual disk $_ has correct state string" for (0..3);
  is int($virtual->[$_]->capacity), [
    415000000000,
    1413000000000,
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
    1,
    0,
  ]->[$_], "virtual disk $_ has correct abnormal state" for (0..3);
}

# detect test
{
  Test::RAID::Info::Mock->import(megacli => 1);

  my @controllers = RAID::Info::Controller::MegaRAID->detect;
  is scalar @controllers, 1, '1 controller';

  my ($c) = @controllers;
  is $c->name, "megaraid/0", "controller has correct name";
}

done_testing;

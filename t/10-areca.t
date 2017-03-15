#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

use RAID::Info::Controller::Areca;

use FindBin;
$ENV{PATH} = "$FindBin::Bin/bin:$ENV{PATH}";

# first test set
{
  $ENV{RI_CLI64_DATA_ID} = '1';
  my $c = RAID::Info::Controller::Areca->new;
  is $c->name, "areca/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 24, '24 physical disks';
  is int($physical->[$_]->capacity), [
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
  ]->[$_], "physical disk $_ has correct capacity" for (0..23);
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
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..23);

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 2, '2 virtual disks';
  is int($virtual->[$_]->capacity), [
    40000000000000,
    40000000000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..1);
  is $virtual->[$_]->level, [qw(
    raid6
    raid6
  )]->[$_], "virtual disk $_ has correct raid level" for (0..1);
  is $virtual->[$_]->raid_name, [
    'i21r1',
    'i21r2',
  ]->[$_], "virtual disk $_ has correct raid name" for (0..1);
  is !!$virtual->[$_]->state->is_abnormal, !![
    0,
    0,
  ]->[$_], "virtual disk $_ has correct abnormal state" for (0..1);
}

# second test set
{
  $ENV{RI_CLI64_DATA_ID} = '2';
  my $c = RAID::Info::Controller::Areca->new;
  is $c->name, "areca/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 24, '24 physical disks';
  is int($physical->[$_]->capacity), [
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
  ]->[$_], "physical disk $_ has correct capacity" for (0..23);
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
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..23);

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 2, '2 virtual disks';
  is int($virtual->[$_]->capacity), [
    40000000000000,
    40000000000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..1);
  is $virtual->[$_]->level, [qw(
    raid6
    raid6
  )]->[$_], "virtual disk $_ has correct raid level" for (0..1);
  is $virtual->[$_]->raid_name, [
    'Raid Set # 000',
    'Raid Set # 001',
  ]->[$_], "virtual disk $_ has correct raid name" for (0..1);
  is !!$virtual->[$_]->state->is_abnormal, !![
    0,
    1,
  ]->[$_], "virtual disk $_ has correct abnormal state" for (0..1);
  is $virtual->[1]->state->progress, 35.3, "virtual disk 1 is in rebuild with correct progress";
}

# third test set
{
  $ENV{RI_CLI64_DATA_ID} = '3';
  my $c = RAID::Info::Controller::Areca->new;
  is $c->name, "areca/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 12, '24 physical disks';
  is int($physical->[$_]->capacity), [
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
  ]->[$_], "physical disk $_ has correct capacity" for (0..11);
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
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..11);

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 2, '2 virtual disks';
  is int($virtual->[$_]->capacity), [
    1000000000000,
    19000000000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..1);
  is $virtual->[$_]->level, [qw(
    raid6
    raid6
  )]->[$_], "virtual disk $_ has correct raid level" for (0..1);
  is $virtual->[$_]->raid_name, [
    'Raid Set # 000',
    'Raid Set # 000',
  ]->[$_], "virtual disk $_ has correct raid name" for (0..1);
  is !!$virtual->[$_]->state->is_abnormal, !![
    0,
    0,
  ]->[$_], "virtual disk $_ has correct abnormal state" for (0..1);
}

# fourth test set
{
  $ENV{RI_CLI64_DATA_ID} = '4';
  my $c = RAID::Info::Controller::Areca->new;
  is $c->name, "areca/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 12, '24 physical disks';
  is int($physical->[$_]->capacity), [
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
  ]->[$_], "physical disk $_ has correct capacity" for (0..11);
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
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..11);

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 1, '1 virtual disk';
  is int($virtual->[$_]->capacity), [
    20000000000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0);
  is $virtual->[$_]->level, [qw(
    raid6
  )]->[$_], "virtual disk $_ has correct raid level" for (0);
  is $virtual->[$_]->raid_name, [
    'i34d1spool',
  ]->[$_], "virtual disk $_ has correct raid name" for (0);
  is !!$virtual->[$_]->state->is_abnormal, !![
    0,
  ]->[$_], "virtual disk $_ has correct abnormal state" for (0);
}

# fifth test set
{
  $ENV{RI_CLI64_DATA_ID} = '5';
  my $c = RAID::Info::Controller::Areca->new;
  is $c->name, "areca/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 24, '24 physical disks';
  is int($physical->[$_]->capacity), [
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    2000400000000,
    8001600000000,
    8001600000000,
    8001600000000,
    8001600000000,
    8001600000000,
    8001600000000,
    8001600000000,
    8001600000000,
    8001600000000,
    8001600000000,
    8001600000000,
    8001600000000,
  ]->[$_], "physical disk $_ has correct capacity" for (0..23);
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
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..23);

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 1, '1 virtual disk';
  is int($virtual->[$_]->capacity), [
    20000000000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0);
  is $virtual->[$_]->level, [qw(
    raid6
  )]->[$_], "virtual disk $_ has correct raid level" for (0);
  is $virtual->[$_]->raid_name, [
    'i34d1spool',
  ]->[$_], "virtual disk $_ has correct raid name" for (0);
  is !!$virtual->[$_]->state->is_abnormal, !![
    0,
  ]->[$_], "virtual disk $_ has correct abnormal state" for (0);
}

# sixth test set
{
  $ENV{RI_CLI64_DATA_ID} = '6';
  my $c = RAID::Info::Controller::Areca->new;
  is $c->name, "areca/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 80, '80 physical disks';
  is int($physical->[$_]->capacity), [
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
    4000800000000,
  ]->[$_], "physical disk $_ has correct capacity" for (0..79);
  is !!$physical->[$_]->state->is_abnormal, !![
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    1,
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
    0,
    0,
    0,
    0,
    0,
    0,
    1,
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
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..79);

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 8, '8 virtual disks';
  is int($virtual->[$_]->capacity), [
    32000000000000,
    32000000000000,
    32000000000000,
    32000000000000,
    32000000000000,
    32000000000000,
    32000000000000,
    32000000000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..7);
  is $virtual->[$_]->level, [qw(
    raid6
    raid6
    raid6
    raid6
    raid6
    raid6
    raid6
    raid6
  )]->[$_], "virtual disk $_ has correct raid level" for (0..7);
  is $virtual->[$_]->raid_name, [
    'Raid Set # 000',
    'Raid Set # 001',
    'Raid Set # 002',
    'Raid Set # 003',
    'Raid Set # 004',
    'Raid Set # 005',
    'Raid Set # 006',
    'Raid Set # 007',
  ]->[$_], "virtual disk $_ has correct raid name" for (0..7);
  is !!$virtual->[$_]->state->is_abnormal, !![
    1,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
  ]->[$_], "virtual disk $_ has correct abnormal state" for (0..7);
}

# detect test
{
  $ENV{RI_CLI64_DATA_ID} = '1';
  my @controllers = RAID::Info::Controller::Areca->detect;
  is scalar @controllers, 1, '1 controller';

  my ($c) = @controllers;
  is $c->name, "areca/0", "controller has correct name";
}

done_testing;

#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

use RAID::Info::Controller::MD;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::RAID::Info::Mock;

# first test set
{
  Test::RAID::Info::Mock->import(mdadm => 1);

  my $c = RAID::Info::Controller::MD->new;
  is $c->name, "md/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 0, '0 physical disks';

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 4, '4 virtual disks';
  is ref($virtual->[$_]->state), [
    ('RAID::Info::VirtualDisk::State::Normal') x 4
  ]->[$_], "virtual disk $_ has correct state" for (0..3);
  is $virtual->[$_]->state->as_string, [
    ('normal') x 4,
  ]->[$_], "virtual disk $_ has correct state string" for (0..3);
  is int($virtual->[$_]->capacity), [
    399950000000,
    399940000000,
    981200000000,
    16770000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..3);
  is $virtual->[$_]->level, [qw(
    raid1
    raid1
    raid1
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
  Test::RAID::Info::Mock->import(mdadm => 2);

  my $c = RAID::Info::Controller::MD->new;
  is $c->name, "md/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 0, '0 physical disks';

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 4, '4 virtual disks';
  is ref($virtual->[$_]->state), [
    'RAID::Info::VirtualDisk::State::Rebuilding',
    'RAID::Info::VirtualDisk::State::Rebuilding',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
  ]->[$_], "virtual disk $_ has correct state" for (0..3);
  is $virtual->[$_]->state->as_string, [
    'rebuilding (0%)',
    'rebuilding (35%)',
    ('normal') x 2,
  ]->[$_], "virtual disk $_ has correct state string" for (0..3);
  is int($virtual->[$_]->capacity), [
    399950000000,
    399940000000,
    981200000000,
    16770000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..3);
  is $virtual->[$_]->level, [qw(
    raid1
    raid1
    raid1
    raid1
  )]->[$_], "virtual disk $_ has correct raid level" for (0..3);
  is !!$virtual->[$_]->state->is_abnormal, !![
    1,
    1,
    0,
    0,
  ]->[$_], "virtual disk $_ has correct abnormal state" for (0..3);
  is $virtual->[0]->state->progress, 0,  "virtual disk 0 is in rebuild with correct progress";
  is $virtual->[1]->state->progress, 35, "virtual disk 1 is in rebuild with correct progress";
}

# third test set
{
  Test::RAID::Info::Mock->import(mdadm => 3);

  my $c = RAID::Info::Controller::MD->new;
  is $c->name, "md/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 0, '0 physical disks';

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 4, '4 virtual disks';
  is ref($virtual->[$_]->state), [
    'RAID::Info::VirtualDisk::State::Rebuilding',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
  ]->[$_], "virtual disk $_ has correct state" for (0..3);
  is int($virtual->[$_]->capacity), [
    3000400000000,
    3000400000000,
    399950000000,
    399950000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..3);
  is $virtual->[$_]->level, [qw(
    raid10
    raid10
    raid1
    raid1
  )]->[$_], "virtual disk $_ has correct raid level" for (0..3);
  is !!$virtual->[$_]->state->is_abnormal, !![
    1,
    0,
    0,
    0,
  ]->[$_], "virtual disk $_ has correct abnormal state" for (0..3);
  is $virtual->[0]->state->progress, 81,  "virtual disk 0 is in rebuild with correct progress";
}

# fourth test set
{
  Test::RAID::Info::Mock->import(mdadm => 4);

  my $c = RAID::Info::Controller::MD->new;
  is $c->name, "md/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 0, '0 physical disks';

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 8, '4 virtual disks';
  is ref($virtual->[$_]->state), [
    'RAID::Info::VirtualDisk::State::Rebuilding',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Rebuilding',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
  ]->[$_], "virtual disk $_ has correct state" for (0..7);
  is int($virtual->[$_]->capacity), [
    8001430000000,
    16770000000,
    493100000000,
    8001430000000,
    8001430000000,
    1200110000000,
    1200110000000,
    1200110000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..7);
  is $virtual->[$_]->level, [qw(
    raid1
    raid1
    raid1
    raid1
    raid1
    raid1
    raid1
    raid1
  )]->[$_], "virtual disk $_ has correct raid level" for (0..7);
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
  is $virtual->[0]->state->progress, 61,  "virtual disk 0 is in rebuild with correct progress";
  is $virtual->[3]->state->progress, 72,  "virtual disk 3 is in rebuild with correct progress";
}

# fifth test set
{
  Test::RAID::Info::Mock->import(mdadm => 5);

  my $c = RAID::Info::Controller::MD->new;
  is $c->name, "md/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 0, '0 physical disks';

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 4, '4 virtual disks';
  is ref($virtual->[$_]->state), [
    'RAID::Info::VirtualDisk::State::Degraded',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
  ]->[$_], "virtual disk $_ has correct state" for (0..3);
  is int($virtual->[$_]->capacity), [
    6000980000000,
    6000980000000,
    800030000000,
    800030000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..3);
  is $virtual->[$_]->level, [qw(
    raid10
    raid10
    raid1
    raid1
  )]->[$_], "virtual disk $_ has correct raid level" for (0..3);
  is !!$virtual->[$_]->state->is_abnormal, !![
    1,
    0,
    0,
    0,
  ]->[$_], "virtual disk $_ has correct abnormal state" for (0..3);
}

# sixth test set
{
  Test::RAID::Info::Mock->import(mdadm => 6);

  my $c = RAID::Info::Controller::MD->new;
  is $c->name, "md/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 0, '0 physical disks';

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 4, '4 virtual disks';
  is ref($virtual->[$_]->state), [
    'RAID::Info::VirtualDisk::State::Degraded',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
  ]->[$_], "virtual disk $_ has correct state" for (0..3);
  is int($virtual->[$_]->capacity), [
    6000980000000,
    6000980000000,
    800030000000,
    800030000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..3);
  is $virtual->[$_]->level, [qw(
    raid10
    raid10
    raid1
    raid1
  )]->[$_], "virtual disk $_ has correct raid level" for (0..3);
  is !!$virtual->[$_]->state->is_abnormal, !![
    1,
    0,
    0,
    0,
  ]->[$_], "virtual disk $_ has correct abnormal state" for (0..3);
}

# seventh test set
{
  Test::RAID::Info::Mock->import(mdadm => 7);

  my $c = RAID::Info::Controller::MD->new;
  is $c->name, "md/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 0, '0 physical disks';

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 8, '8 virtual disks';
  is ref($virtual->[$_]->state), [
    'RAID::Info::VirtualDisk::State::Degraded',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Degraded',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
  ]->[$_], "virtual disk $_ has correct state" for (0..7);
  is int($virtual->[$_]->capacity), [
    0,
    493100000000,
    16770000000,
    0,
    8001430000000,
    1200110000000,
    1200110000000,
    1200110000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..7);
  is $virtual->[$_]->level, [qw(
    raid0
    raid1
    raid1
    raid0
    raid1
    raid1
    raid1
    raid1
  )]->[$_], "virtual disk $_ has correct raid level" for (0..7);
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

# eighth test set
{
  Test::RAID::Info::Mock->import(mdadm => 8);

  my $c = RAID::Info::Controller::MD->new;
  is $c->name, "md/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 0, '0 physical disks';

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 8, '8 virtual disks';
  is ref($virtual->[$_]->state), [
    'RAID::Info::VirtualDisk::State::Rebuilding',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Rebuilding',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Rebuilding',
    'RAID::Info::VirtualDisk::State::Rebuilding',
    'RAID::Info::VirtualDisk::State::Rebuilding',
  ]->[$_], "virtual disk $_ has correct state" for (0..7);
  is int($virtual->[$_]->capacity), [
    8001430000000,
    493100000000,
    16770000000,
    8001430000000,
    8001430000000,
    1200110000000,
    1200110000000,
    1200110000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..7);
  is $virtual->[$_]->level, [qw(
    raid1
    raid1
    raid1
    raid1
    raid1
    raid1
    raid1
    raid1
  )]->[$_], "virtual disk $_ has correct raid level" for (0..7);
  is !!$virtual->[$_]->state->is_abnormal, !![
    1,
    0,
    0,
    1,
    0,
    1,
    1,
    1,
  ]->[$_], "virtual disk $_ has correct abnormal state" for (0..7);
  is $virtual->[0]->state->progress, 1,  "virtual disk 0 is in rebuild with correct progress";
  is $virtual->[3]->state->progress, 16, "virtual disk 3 is in rebuild with correct progress";
  is $virtual->[5]->state->progress, 36, "virtual disk 5 is in rebuild with correct progress";
  is $virtual->[6]->state->progress, 36, "virtual disk 6 is in rebuild with correct progress";
  is $virtual->[7]->state->progress, 36, "virtual disk 7 is in rebuild with correct progress";
}

# ninth test set
{
  Test::RAID::Info::Mock->import(mdadm => 9);

  my $c = RAID::Info::Controller::MD->new;
  is $c->name, "md/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 0, '0 physical disks';

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 8, '8 virtual disks';
  is ref($virtual->[$_]->state), [
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Rebuilding',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
  ]->[$_], "virtual disk $_ has correct state" for (0..7);
  is int($virtual->[$_]->capacity), [
    493100000000,
    16770000000,
    8001430000000,
    8001430000000,
    8001430000000,
    1200110000000,
    1200110000000,
    1200110000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..7);
  is $virtual->[$_]->level, [qw(
    raid1
    raid1
    raid1
    raid1
    raid1
    raid1
    raid1
    raid1
  )]->[$_], "virtual disk $_ has correct raid level" for (0..7);
  is !!$virtual->[$_]->state->is_abnormal, !![
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
  ]->[$_], "virtual disk $_ has correct abnormal state" for (0..7);
  is $virtual->[4]->state->progress, 65,  "virtual disk 4 has correct progress";
}

# tenth test set
{
  Test::RAID::Info::Mock->import(mdadm => 10);

  my $c = RAID::Info::Controller::MD->new;
  is $c->name, "md/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 0, '0 physical disks';

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 8, '8 virtual disks';
  is ref($virtual->[$_]->state), [
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Rebuilding',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
  ]->[$_], "virtual disk $_ has correct state" for (0..7);
  is int($virtual->[$_]->capacity), [
    493100000000,
    16770000000,
    8001430000000,
    8001430000000,
    8001430000000,
    1200110000000,
    1200110000000,
    1200110000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..7);
  is $virtual->[$_]->level, [qw(
    raid1
    raid1
    raid1
    raid1
    raid1
    raid1
    raid1
    raid1
  )]->[$_], "virtual disk $_ has correct raid level" for (0..7);
  is !!$virtual->[$_]->state->is_abnormal, !![
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
  ]->[$_], "virtual disk $_ has correct abnormal state" for (0..7);
  is $virtual->[4]->state->progress, 82, "virtual disk 4 has correct progress";
}

{
  Test::RAID::Info::Mock->import(mdadm => 11);

  my $c = RAID::Info::Controller::MD->new;
  is $c->name, "md/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 0, '0 physical disks';

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 3, '3 virtual disks';
  is ref($virtual->[$_]->state), [
    'RAID::Info::VirtualDisk::State::Rebuilding',
    'RAID::Info::VirtualDisk::State::Rebuilding',
    'RAID::Info::VirtualDisk::State::Rebuilding',
  ]->[$_], "virtual disk $_ has correct state" for (0..2);
  is int($virtual->[$_]->capacity), [
    104790000000,
    1076380000000,
    16770000000,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..2);
  is $virtual->[$_]->level, [qw(
    raid1
    raid1
    raid1
  )]->[$_], "virtual disk $_ has correct raid level" for (0..2);
  is !!$virtual->[$_]->state->is_abnormal, !![
    1,
    1,
    1,
  ]->[$_], "virtual disk $_ has correct abnormal state" for (0..2);
}

# detect test
{
  Test::RAID::Info::Mock->import(mdadm => 1);

  my @controllers = RAID::Info::Controller::MD->detect(
    _mdstat_raw => do { local (@ARGV, $/) = ('t/data/mdstat-1.txt'); <> },
  );
  is scalar @controllers, 1, '1 controller';

  my ($c) = @controllers;
  is $c->name, "md/0", "controller has correct name";
}

# detect test 2, no devices
{
  my @controllers = RAID::Info::Controller::MD->detect(
    _mdstat_raw => do { local (@ARGV, $/) = ('t/data/mdstat-empty.txt'); <> },
  );
  is scalar @controllers, 0, '0 controllers';
}


done_testing;

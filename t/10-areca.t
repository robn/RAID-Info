#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use Test::Deep;

use RAID::Info::Controller::Areca;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::RAID::Info::Mock;

# first test set
{
  Test::RAID::Info::Mock->import(cli64 => 1);

  my $c = RAID::Info::Controller::Areca->new;
  is $c->name, "areca/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 24, '24 physical disks';
  is ref($physical->[$_]->state), [
    ('RAID::Info::PhysicalDisk::State::Online') x 24
  ]->[$_], "physical disk $_ has correct state" for (0..23);
  is $physical->[$_]->state->as_string, [
    ('online') x 24
  ]->[$_], "physical disk $_ has correct state string" for (0..23);
  is int($physical->[$_]->capacity), [
    (4000800000000) x 24
  ]->[$_], "physical disk $_ has correct capacity" for (0..23);
  is !!$physical->[$_]->state->is_abnormal, !![
    (0) x 24,
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..23);

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 2, '2 virtual disks';
  is ref($virtual->[$_]->state), [
    ('RAID::Info::VirtualDisk::State::Normal') x 2
  ]->[$_], "virtual disk $_ has correct state" for (0..1);
  is $virtual->[$_]->state->as_string, [
    ('normal') x 2,
  ]->[$_], "virtual disk $_ has correct state string" for (0..1);
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
  cmp_deeply [ map { $_->slot } @{$virtual->[$_]->physical_disks} ], [
    ['00'..'11'],
    ['12'..'23'],
  ]->[$_], "virtual disk $_ has correct physical disks" for (0..1);
}

# second test set
{
  Test::RAID::Info::Mock->import(cli64 => 2);

  my $c = RAID::Info::Controller::Areca->new;
  is $c->name, "areca/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 24, '24 physical disks';
  is ref($physical->[$_]->state), [
    ('RAID::Info::PhysicalDisk::State::Online') x 24
  ]->[$_], "physical disk $_ has correct state" for (0..23);
  is $physical->[$_]->state->as_string, [
    ('online') x 24
  ]->[$_], "physical disk $_ has correct state string" for (0..23);
  is int($physical->[$_]->capacity), [
    (4000800000000) x 24,
  ]->[$_], "physical disk $_ has correct capacity" for (0..23);
  is !!$physical->[$_]->state->is_abnormal, !![
    (0) x 24,
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..23);

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 2, '2 virtual disks';
  is ref($virtual->[$_]->state), [
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Rebuilding',
  ]->[$_], "virtual disk $_ has correct state" for (0..1);
  is $virtual->[$_]->state->as_string, [
    'normal',
    'rebuilding (35.3%)',
  ]->[$_], "virtual disk $_ has correct state string" for (0..1);
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
  cmp_deeply [ map { $_->slot } @{$virtual->[$_]->physical_disks} ], [
    ['01'..'12'],
    ['13'..'24'],
  ]->[$_], "virtual disk $_ has correct physical disks" for (0..1);
}

# third test set
{
  Test::RAID::Info::Mock->import(cli64 => 3);

  my $c = RAID::Info::Controller::Areca->new;
  is $c->name, "areca/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 12, '12 physical disks';
  is ref($physical->[$_]->state), [
    ('RAID::Info::PhysicalDisk::State::Online') x 12
  ]->[$_], "physical disk $_ has correct state" for (0..11);
  is $physical->[$_]->state->as_string, [
    ('online') x 12
  ]->[$_], "physical disk $_ has correct state string" for (0..11);
  is int($physical->[$_]->capacity), [
    (2000400000000) x 12,
  ]->[$_], "physical disk $_ has correct capacity" for (0..11);
  is !!$physical->[$_]->state->is_abnormal, !![
    (0) x 12,
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..11);

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 2, '2 virtual disks';
  is ref($virtual->[$_]->state), [
    ('RAID::Info::VirtualDisk::State::Normal') x 2
  ]->[$_], "virtual disk $_ has correct state" for (0..1);
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
  cmp_deeply [ map { $_->slot } @{$virtual->[$_]->physical_disks} ], [
    ['001'..'012'],
    ['001'..'012'],
  ]->[$_], "virtual disk $_ has correct physical disks" for (0..1);
}

# fourth test set
{
  Test::RAID::Info::Mock->import(cli64 => 4);

  my $c = RAID::Info::Controller::Areca->new;
  is $c->name, "areca/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 12, '12 physical disks';
  is ref($physical->[$_]->state), [
    ('RAID::Info::PhysicalDisk::State::Online') x 12
  ]->[$_], "physical disk $_ has correct state" for (0..11);
  is $physical->[$_]->state->as_string, [
    ('online') x 12
  ]->[$_], "physical disk $_ has correct state string" for (0..11);
  is int($physical->[$_]->capacity), [
    (2000400000000) x 12,
  ]->[$_], "physical disk $_ has correct capacity" for (0..11);
  is !!$physical->[$_]->state->is_abnormal, !![
    (0) x 12,
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..11);

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 1, '1 virtual disk';
  is ref($virtual->[$_]->state), [
    'RAID::Info::VirtualDisk::State::Normal',
  ]->[$_], "virtual disk $_ has correct state" for (0);
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
  cmp_deeply [ map { $_->slot } @{$virtual->[$_]->physical_disks} ], [
    ['01'..'12'],
  ]->[$_], "virtual disk $_ has correct physical disks" for (0);
}

# fifth test set
{
  Test::RAID::Info::Mock->import(cli64 => 5);

  my $c = RAID::Info::Controller::Areca->new;
  is $c->name, "areca/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 24, '24 physical disks';
  is ref($physical->[$_]->state), [
    ('RAID::Info::PhysicalDisk::State::Online')      x 12,
    ('RAID::Info::PhysicalDisk::State::Unallocated') x 12,
  ]->[$_], "physical disk $_ has correct state" for (0..23);
  is $physical->[$_]->state->as_string, [
    ('online')      x 12,
    ('unallocated') x 12,
  ]->[$_], "physical disk $_ has correct state string" for (0..23);
  is int($physical->[$_]->capacity), [
    (2000400000000) x 12,
    (8001600000000) x 12,
  ]->[$_], "physical disk $_ has correct capacity" for (0..23);
  is !!$physical->[$_]->state->is_abnormal, !![
    (0) x 24,
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..23);

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 1, '1 virtual disk';
  is ref($virtual->[$_]->state), [
    'RAID::Info::VirtualDisk::State::Normal',
  ]->[$_], "virtual disk $_ has correct state" for (0);
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
  cmp_deeply [ map { $_->slot } @{$virtual->[$_]->physical_disks} ], [
    ['01'..'12'],
  ]->[$_], "virtual disk $_ has correct physical disks" for (0);
}

# sixth test set
{
  Test::RAID::Info::Mock->import(cli64 => 6);

  my $c = RAID::Info::Controller::Areca->new;
  is $c->name, "areca/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 80, '80 physical disks';
  is ref($physical->[$_]->state), [
    ('RAID::Info::PhysicalDisk::State::Online') x 7,
    'RAID::Info::PhysicalDisk::State::Failed', # 7
    ('RAID::Info::PhysicalDisk::State::Online') x 48,
    'RAID::Info::PhysicalDisk::State::Failed', # 56
    ('RAID::Info::PhysicalDisk::State::Online') x 23,
  ]->[$_], "physical disk $_ has correct state" for (0..79);
  is $physical->[$_]->state->as_string, [
    ('online') x 7,
    'failed', # 7
    ('online') x 48,
    'failed', # 56
    ('online') x 23,
  ]->[$_], "physical disk $_ has correct state string" for (0..79);
  is int($physical->[$_]->capacity), [
    (4000800000000) x 80,
  ]->[$_], "physical disk $_ has correct capacity" for (0..79);
  is !!$physical->[$_]->state->is_abnormal, !![
    (0) x 7,
    1, # 7
    (0) x 48,
    1, # 56
    (0) x 23,
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..79);

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
    (32000000000000) x 8,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..7);
  is $virtual->[$_]->level, [
    ('raid6') x 8,
  ]->[$_], "virtual disk $_ has correct raid level" for (0..7);
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
  cmp_deeply [ map { $_->slot } @{$virtual->[$_]->physical_disks} ], [
    ['01'..'07','09','10'],
    ['11'..'20'],
    ['21'..'30'],
    ['31'..'36','38','39','40'],
    ['41'..'50'],
    ['51'..'60'],
    ['61'..'70'],
    ['71'..'80'],
  ]->[$_], "virtual disk $_ has correct physical disks" for (0..7);
}

# seventh test set
{
  Test::RAID::Info::Mock->import(cli64 => 7);

  my $c = RAID::Info::Controller::Areca->new;
  is $c->name, "areca/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 74, '74 physical disks';
  is ref($physical->[$_]->state), [
    ('RAID::Info::PhysicalDisk::State::Online') x 8,
    'RAID::Info::PhysicalDisk::State::Unallocated', # 8
    ('RAID::Info::PhysicalDisk::State::Online') x 29,
    ('RAID::Info::PhysicalDisk::State::Unallocated') x 16,
    ('RAID::Info::PhysicalDisk::State::Online') x 20,
  ]->[$_], "physical disk $_ has correct state" for (0..73);
  is $physical->[$_]->state->as_string, [
    ('online') x 8,
    'unallocated', # 8
    ('online') x 29,
    ('unallocated') x 16,
    ('online') x 20,
  ]->[$_], "physical disk $_ has correct state string" for (0..73);
  is int($physical->[$_]->capacity), [
    (4000800000000) x 74,
  ]->[$_], "physical disk $_ has correct capacity" for (0..73);
  is !!$physical->[$_]->state->is_abnormal, !![
    (0) x 74,
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..73);

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 6, '6 virtual disks';
  is ref($virtual->[$_]->state), [
    'RAID::Info::VirtualDisk::State::Degraded',
    'RAID::Info::VirtualDisk::State::Rebuilding',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Degraded',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
  ]->[$_], "virtual disk $_ has correct state" for (0..5);
  is int($virtual->[$_]->capacity), [
    (32000000000000) x 6,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..5);
  is $virtual->[$_]->level, [
    ('raid6') x 6,
  ]->[$_], "virtual disk $_ has correct raid level" for (0..5);
  is $virtual->[$_]->raid_name, [
    'Raid Set # 000',
    'Raid Set # 001',
    'Raid Set # 004',
    'Raid Set # 005',
    'Raid Set # 006',
    'Raid Set # 007',
  ]->[$_], "virtual disk $_ has correct raid name" for (0..5);
  is !!$virtual->[$_]->state->is_abnormal, !![
    1,
    1,
    0,
    1,
    0,
    0,
  ]->[$_], "virtual disk $_ has correct abnormal state" for (0..5);
  cmp_deeply [ map { $_->slot } @{$virtual->[$_]->physical_disks} ], [
    ['01'..'07','10'],
    ['08','11','12','13','15'..'20'],
    #['21'..'23','25'..'27','29','30'],
    #['31','33'..'37','39','40'],
    ['41'..'50'],
    ['51','52','54'..'60'],
    ['61'..'70'],
    ['71'..'80'],
  ]->[$_], "virtual disk $_ has correct physical disks" for (0..5);
}

# eighth test set
{
  Test::RAID::Info::Mock->import(cli64 => 8);

  my $c = RAID::Info::Controller::Areca->new;
  is $c->name, "areca/0", "controller has correct name";

  my $physical = $c->physical_disks;
  is scalar @$physical, 80, '80 physical disks';
  is ref($physical->[$_]->state), [
    ('RAID::Info::PhysicalDisk::State::Online') x 80
  ]->[$_], "physical disk $_ has correct state" for (0..79);
  is $physical->[$_]->state->as_string, [
    ('online') x 24
  ]->[$_], "physical disk $_ has correct state string" for (0..23);
  is int($physical->[$_]->capacity), [
    (4000800000000) x 80,
  ]->[$_], "physical disk $_ has correct capacity" for (0..79);
  is !!$physical->[$_]->state->is_abnormal, !![
    (0) x 74,
  ]->[$_], "physical disk $_ has correct abnormal state" for (0..79);

  my $virtual = $c->virtual_disks;
  is scalar @$virtual, 8, '8 virtual disks';
  is ref($virtual->[$_]->state), [
    ('RAID::Info::VirtualDisk::State::Rebuilding') x 4,
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Rebuilding',
    'RAID::Info::VirtualDisk::State::Normal',
    'RAID::Info::VirtualDisk::State::Normal',
  ]->[$_], "virtual disk $_ has correct state" for (0..7);
  is int($virtual->[$_]->capacity), [
    (32000000000000) x 8,
  ]->[$_], "virtual disk $_ has correct capacity" for (0..7);
  is $virtual->[$_]->level, [
    ('raid6') x 8,
  ]->[$_], "virtual disk $_ has correct raid level" for (0..7);
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
    (1) x 4,
    0, 1, 0, 0,
  ]->[$_], "virtual disk $_ has correct abnormal state" for (0..7);
  cmp_deeply [ map { $_->slot } @{$virtual->[$_]->physical_disks} ], [
    ['01'..'07','09','10','14'],
    ['08','11'..'13','15'..'20'],
    ['53','21','22','23','25'..'30'],
    ['31'..'40'],
    ['41'..'50'],
    ['51','52','54'..'60','24'],
    ['61'..'70'],
    ['71'..'80'],
  ]->[$_], "virtual disk $_ has correct physical disks" for (0..7);
}


# detect test
{
  Test::RAID::Info::Mock->import(cli64 => 1);

  my @controllers = RAID::Info::Controller::Areca->detect;
  is scalar @controllers, 1, '1 controller';

  my ($c) = @controllers;
  is $c->name, "areca/0", "controller has correct name";
}

done_testing;

#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

use RAID::Info::Controller::SASMPT;

# disk test
{
  my $c = RAID::Info::Controller::SASMPT->_new_for_test(
    lsiutil => do { local (@ARGV, $/) = ('t/data/lsiutil.txt'); <> },
  );

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
  my @controllers = RAID::Info::Controller::SASMPT->detect(
    _test => do { local (@ARGV, $/) = ('t/data/lsiutil-detect.txt'); <> },
  );
  is scalar @controllers, 1, '1 controller';
}

done_testing;

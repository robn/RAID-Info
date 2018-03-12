#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

use RAID::Info;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::RAID::Info::Mock;

# detect all controllers
{
  my @controllers = RAID::Info->detect;
  is scalar @controllers, 8, '8 controllers';

  is ref($controllers[$_]), [qw(
    RAID::Info::Controller::Adaptec
    RAID::Info::Controller::Areca
    RAID::Info::Controller::LinuxAHCI
    RAID::Info::Controller::MD
    RAID::Info::Controller::MegaRAID
    RAID::Info::Controller::SAS2IR
    RAID::Info::Controller::SAS3IR
    RAID::Info::Controller::SASMPT
  )]->[$_], "correctly detected controller $_" for (0..7);
}

done_testing;

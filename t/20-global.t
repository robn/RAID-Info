#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

use RAID::Info;

use FindBin;
$ENV{PATH} = "$FindBin::Bin/bin:$ENV{PATH}";

$ENV{RI_CLI64_DATA_ID} = '1';
$ENV{RI_LSIUTIL_DATA_ID} = '1';
$ENV{RI_MEGACLI_DATA_ID} = '1';

# MD uses a program and a procfile. We can't preload the controller object with
# procfile data because we're not in control of its construction, so we have to
# modify an internal constant placed there special for this purpose. Ugh. 
$ENV{RI_MDADM_DATA_ID} = '1';
use RAID::Info::Controller::MD;
local $RAID::Info::Controller::MD::_PROC_MDSTAT =
  "$FindBin::Bin/data/mdstat-$ENV{RI_MDADM_DATA_ID}.txt";

# detect all controllers
{
  my @controllers = RAID::Info->detect;
  is scalar @controllers, 7, '7 controllers';

  # XXX one of each
}

done_testing;

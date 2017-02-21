#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

use RAID::Info;

use FindBin;
$ENV{PATH} = "$FindBin::Bin/bin:$ENV{PATH}";

$ENV{RI_CLI64_DATA_ID} = '1';
$ENV{RI_MDADM_DATA_ID} = '1';
$ENV{RI_LSIUTIL_DATA_ID} = '1';

# detect all controllers
{
  my @controllers = RAID::Info->detect;
  is scalar @controllers, 6, '6 controllers';

  # XXX one of each
}

done_testing;

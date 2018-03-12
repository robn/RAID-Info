package Test::RAID::Info::Mock;

use 5.010;
use warnings;
use strict;

# set up environment for test

use FindBin;
my $bin_path = $FindBin::Bin;

# look for the package root
my $package_root =
  -d "$bin_path/../t/data" && -d "$bin_path/data" ? "$bin_path/.." : # running under t/, probably tests
  -d "$bin_path/../t/data" ? "$bin_path/.." : # running under bin/ probably
  -d "$bin_path/t/data"    ? $bin_path : # running from the root
  die "couldn't determine package root for $bin_path";

$ENV{PATH} = "$package_root/t/bin:$ENV{PATH}";

sub import {
  my ($class, %args) = @_;

  $ENV{RI_CLI64_DATA_ID}    = $args{cli64}    // '1';
  $ENV{RI_LSIUTIL_DATA_ID}  = $args{lsiutil}  // '1';
  $ENV{RI_MEGACLI_DATA_ID}  = $args{megacli}  // '1';
  $ENV{RI_SAS2IRCU_DATA_ID} = $args{sas2ircu} // '1';
  $ENV{RI_SAS3IRCU_DATA_ID} = $args{sas3ircu} // '1';

  # MD uses a program and a procfile. We can't preload the controller object
  # with procfile data because we're not in control of its construction, so we
  # have to modify an internal constant placed there special for this purpose.
  $ENV{RI_MDADM_DATA_ID} = $args{mdadm} // '1';
  use RAID::Info::Controller::MD;
  $RAID::Info::Controller::MD::_PROC_MDSTAT =
    "$package_root/t/data/mdstat-$ENV{RI_MDADM_DATA_ID}.txt";
}

1;

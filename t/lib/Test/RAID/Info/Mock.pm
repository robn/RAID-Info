package Test::RAID::Info::Mock;

use 5.010;
use warnings;
use strict;

# set up environment for test

use FindBin;
my $BinPath = $FindBin::Bin;

# look for the package root
my $PackageRoot =
  -d "$BinPath/../t/data" && -d "$BinPath/data" ? "$BinPath/.." : # running under t/, probably tests
  -d "$BinPath/../t/data" ? "$BinPath/.." : # running under bin/ probably
  -d "$BinPath/t/data"   ? $BinPath : # running from the root
  die "couldn't determine package root for $BinPath";

$ENV{PATH} = "$PackageRoot/t/bin:$ENV{PATH}";

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
    "$PackageRoot/t/data/mdstat-$ENV{RI_MDADM_DATA_ID}.txt";
}

1;

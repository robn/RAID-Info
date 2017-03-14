package RAID::Info;

# ABSTRACT: See how your RAID controllers/volumes/disks are doing without sacrificing your firstborn 

use strict;
use warnings;

my @drivers = qw(
  Adaptec
  Areca
  MD
  MegaRAID
  SAS2IR
  SAS3IR
  SASMPT
);

sub detect {
  my ($class) = @_;

  my @controllers;

  for my $driver (@drivers) {
    my $package = "RAID::Info::Controller::$driver";
    eval "use $package";
    push @controllers, $package->detect;
  }

  return @controllers;
}

1;

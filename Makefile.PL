# This file was automatically generated by Dist::Zilla::Plugin::MakeMaker v6.011.
use strict;
use warnings;

use 5.014;

use ExtUtils::MakeMaker;

my %WriteMakefileArgs = (
  "ABSTRACT" => "See how your RAID controllers/volumes/disks are doing without sacrificing your firstborn ",
  "AUTHOR" => "Rob N \x{2605} <robn\@robn.io>",
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => 0
  },
  "DISTNAME" => "RAID-Info",
  "EXE_FILES" => [
    "bin/ri-dump"
  ],
  "LICENSE" => "perl",
  "MIN_PERL_VERSION" => "5.014",
  "NAME" => "RAID::Info",
  "PREREQ_PM" => {
    "File::Spec" => 0,
    "IPC::Open2" => 0,
    "IPC::System::Simple" => 0,
    "Moo" => 0,
    "Moo::Role" => 0,
    "Number::Bytes::Human" => 0,
    "Scalar::Util" => 0,
    "Try::Tiny" => 0,
    "Type::Params" => 0,
    "Type::Utils" => 0,
    "Types::Standard" => 0,
    "namespace::autoclean" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "TEST_REQUIRES" => {
    "FindBin" => 0,
    "Test::Deep" => 0,
    "Test::More" => 0,
    "lib" => 0
  },
  "VERSION" => "0.001",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


my %FallbackPrereqs = (
  "File::Spec" => 0,
  "FindBin" => 0,
  "IPC::Open2" => 0,
  "IPC::System::Simple" => 0,
  "Moo" => 0,
  "Moo::Role" => 0,
  "Number::Bytes::Human" => 0,
  "Scalar::Util" => 0,
  "Test::Deep" => 0,
  "Test::More" => 0,
  "Try::Tiny" => 0,
  "Type::Params" => 0,
  "Type::Utils" => 0,
  "Types::Standard" => 0,
  "lib" => 0,
  "namespace::autoclean" => 0,
  "strict" => 0,
  "warnings" => 0
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);

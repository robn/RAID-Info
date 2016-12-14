package RAID::Info::PhysicalDisk;

use 5.014;
use warnings;
use strict;

use Moo;
use Types::Standard qw(Str Int Num);

has id       => ( is => 'ro', isa => Str, required => 1 );
has slot     => ( is => 'ro', isa => Int, required => 1 );
has model    => ( is => 'ro', isa => Str, required => 1 );
has capacity => ( is => 'ro', isa => Num, required => 1 );

1;

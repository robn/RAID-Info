package RAID::Info::Disk;

use 5.014;
use warnings;
use strict;

use Moo::Role;
use Types::Standard qw(Str Num);

has id       => ( is => 'ro', isa => Str, required => 1 );
has capacity => ( is => 'ro', isa => Num, required => 1 );

1;

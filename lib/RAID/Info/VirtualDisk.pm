package RAID::Info::VirtualDisk;

use 5.014;
use warnings;
use strict;

use Moo;
use Types::Standard qw(Str Int Num);
use Type::Utils qw(enum);

has id       => ( is => 'ro', isa => Str,                        required => 1 );
has name     => ( is => 'ro', isa => Str,                        required => 1 );
has level    => ( is => 'ro', isa => Str,                        required => 1 );
has capacity => ( is => 'ro', isa => Num,                        required => 1 );
has state    => ( is => 'ro', isa => enum [qw(normal degraded)], required => 1 );

1;


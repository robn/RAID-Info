package RAID::Info::VirtualDisk;

use 5.014;
use warnings;
use strict;

use Moo;
use Types::Standard qw(Str);
use Type::Utils qw(enum);

with 'RAID::Info::Disk';

has name  => ( is => 'ro', isa => Str,                                        required => 1 );
has level => ( is => 'ro', isa => enum([qw(raid0 raid1 raid5 raid6 raid10)]), required => 1 );
has state => ( is => 'ro', isa => enum([qw(normal degraded rebuilding)]),     required => 1 );

1;


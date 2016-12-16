package RAID::Info::PhysicalDisk;

use 5.014;
use namespace::autoclean;

use Moo;
use Types::Standard qw(Str Int);
use Type::Utils qw(enum);

with 'RAID::Info::Disk';

has slot  => ( is => 'ro', isa => Int,                       required => 1 );
has model => ( is => 'ro', isa => Str,                       required => 1 );
has state => ( is => 'ro', isa => enum([qw(online failed)]), required => 1 );

1;

package RAID::Info::Controller;

use 5.014;
use warnings;
use strict;

use Moo::Role;
use Type::Utils qw(class_type);
use Types::Standard qw(ArrayRef);

use RAID::Info::PhysicalDisk;
use RAID::Info::VirtualDisk;

has physical_disks => ( is => 'lazy', isa => ArrayRef[class_type('RAID::Info::PhysicalDisk')] );
has virtual_disks  => ( is => 'lazy', isa => ArrayRef[class_type('RAID::Info::VirtualDisk')] );

requires qw(_build_physical_disks _build_virtual_disks);

1;

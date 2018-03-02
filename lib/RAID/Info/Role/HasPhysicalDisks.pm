package RAID::Info::Role::HasPhysicalDisks;

use 5.014;
use namespace::autoclean;

use Moo::Role;
use Type::Utils qw(class_type);
use Types::Standard qw(ArrayRef);

has physical_disks => ( is => 'lazy', isa => ArrayRef[class_type('RAID::Info::PhysicalDisk')] );

requires qw(_build_physical_disks);

1

package RAID::Info::Controller;

use 5.014;
use namespace::autoclean;

use Moo::Role;
use Type::Utils qw(class_type);
use Types::Standard qw(Str ArrayRef);

use RAID::Info::PhysicalDisk;
use RAID::Info::VirtualDisk;

has name => ( is => 'lazy', isa => Str );

has virtual_disks => ( is => 'lazy', isa => ArrayRef[class_type('RAID::Info::VirtualDisk')] );

requires qw(_build_name _build_virtual_disks detect);

with 'RAID::Info::Role::HasPhysicalDisks';

1;

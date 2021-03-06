package RAID::Info::PhysicalDisk {

use 5.014;
use namespace::autoclean;

use Moo;
use Types::Standard qw(Str Int);
use Type::Utils qw(role_type);

with 'RAID::Info::Disk';

has slot  => ( is => 'ro', isa => Int,                                          required => 1 );
has model => ( is => 'ro', isa => Str,                                          required => 1 );
has state => ( is => 'ro', isa => role_type('RAID::Info::PhysicalDisk::State'), required => 1 );

}


package RAID::Info::PhysicalDisk::State {

use Moo::Role;

requires qw(is_abnormal as_string);
}


package RAID::Info::PhysicalDisk::State::Online {

use Moo;
with 'RAID::Info::PhysicalDisk::State';

sub is_abnormal { 0 };
sub as_string { "online" };
}

package RAID::Info::PhysicalDisk::State::Unallocated {

use Moo;
with 'RAID::Info::PhysicalDisk::State';

sub is_abnormal { 0 };
sub as_string { "unallocated" };
}


package RAID::Info::PhysicalDisk::State::Failed {

use Moo;
with 'RAID::Info::PhysicalDisk::State';

sub is_abnormal { 1 };
sub as_string { "failed" };
}


package RAID::Info::PhysicalDisk::State::Rebuilding {

use namespace::autoclean;

use Moo;
with 'RAID::Info::PhysicalDisk::State';
with 'RAID::Info::Role::HasRebuildProgress';

sub is_abnormal { 1 };
sub as_string { "rebuilding (" . shift->progress . "%)" };
}

1;

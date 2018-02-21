package RAID::Info::VirtualDisk {

use 5.014;
use namespace::autoclean;

use Moo;
use Types::Standard qw(Str Num);
use Type::Utils qw(enum role_type);

with 'RAID::Info::Disk';

has name     => ( is => 'ro', isa => Str,                                         required => 1 );
has level    => ( is => 'ro', isa => enum([qw(raid0 raid1 raid5 raid6 raid10)]),  required => 1 );
has state    => ( is => 'ro', isa => role_type('RAID::Info::VirtualDisk::State'), required => 1 );

}


package RAID::Info::VirtualDisk::State {

use Moo::Role;

requires qw(is_abnormal as_string);
}


package RAID::Info::VirtualDisk::State::Normal {

use Moo;
with 'RAID::Info::VirtualDisk::State';

sub is_abnormal { 0 };
sub as_string { "normal" };
}


package RAID::Info::VirtualDisk::State::Degraded {

use Moo;
with 'RAID::Info::VirtualDisk::State';

sub is_abnormal { 1 };
sub as_string { "degraded" };
}


package RAID::Info::VirtualDisk::State::Rebuilding {

use namespace::autoclean;

use Moo;
with 'RAID::Info::VirtualDisk::State';
with 'RAID::Info::Disk::RebuildProgress';

sub is_abnormal { 1 };
sub as_string { "rebuilding (" . shift->progress . "%)" };
}

1;

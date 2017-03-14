package RAID::Info::Disk;

use 5.014;
use namespace::autoclean;

use Moo::Role;
use Types::Standard qw(Str Num);

use Number::Bytes::Human qw(parse_bytes);
use File::Spec;

has id => ( is => 'ro', isa => Str, required => 1 );

has capacity => (
  is => 'ro',
  isa => Num,
  required => 1,
  coerce => sub {
    # working around Number::Bytes::Human debug output, see RT#119241
    open state $nullfh, '>', File::Spec->devnull;
    local *STDERR = $nullfh;
    parse_bytes($_[0])
  }
);

package RAID::Info::Disk::RebuildProgress {

use namespace::autoclean;

use Moo::Role;

use Scalar::Util qw(looks_like_number);

has progress => (
  is  => 'ro',
  isa => Type::Tiny->new(
    name       => 'Percent',
    constraint => sub { looks_like_number($_) && $_ >= 0 && $_ <= 100 },
    message    => sub { "$_ must be a number 0 <= n <= 100" },
  ),
  required => 1,
);

}

1;

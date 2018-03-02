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

1;

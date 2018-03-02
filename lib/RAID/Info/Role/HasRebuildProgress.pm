package RAID::Info::Role::HasRebuildProgress;

use 5.014;
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

1;

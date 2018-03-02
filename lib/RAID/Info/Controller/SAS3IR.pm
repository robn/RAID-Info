package RAID::Info::Controller::SAS3IR;

use 5.014;
use namespace::autoclean;

use Moo;

with 'RAID::Info::Controller::SASxIR';

use IPC::System::Simple qw(capturex EXIT_ANY);
use Try::Tiny;

sub _load_data_from_controller {
  my ($self) = @_;
  return if defined $self->_display_raw;

  my $raw = capturex('sas3ircu', $self->id, 'display');
  $self->_display_raw($raw);
}

sub _build_name {
  return "sas3ir/".shift->id;
}

sub _get_controller_list_raw {
  my $raw = try { capturex(EXIT_ANY, qw(sas3ircu list)) };
  return unless $raw;
  return $raw;
}

1;

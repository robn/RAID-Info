package RAID::Info::Controller::SAS3IR;

use 5.014;
use namespace::autoclean;

use Moo;

with 'RAID::Info::Controller::SASxIR';

use IPC::System::Simple qw(capturex EXIT_ANY);

sub _load_data_from_controller {
  my ($self) = @_;
  return if defined $self->_display_raw;

  my $raw = capturex('sas3ircu', $self->id, 'display');
  $self->_display_raw($raw);
}

sub _get_controller_list_raw {
  return scalar capturex(EXIT_ANY, qw(sas3ircu list));
  # XXX sas3ircu list
}

1;

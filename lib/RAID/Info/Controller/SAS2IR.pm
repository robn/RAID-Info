package RAID::Info::Controller::SAS2IR;

use 5.014;
use namespace::autoclean;

use Moo;

with 'RAID::Info::Controller::SASxIR';

use IPC::System::Simple qw(capturex EXIT_ANY);

sub _load_data_from_controller {
  my ($self) = @_;
  return if defined $self->_display_raw;

  my $raw = capturex('sas2ircu', $self->id, 'display');
  $self->_display_raw($raw);
}

sub _build_name {
  return "sas2ir/".shift->id;
}

sub _get_controller_list_raw {
  return scalar capturex(EXIT_ANY, qw(sas2ircu list));
}

1;

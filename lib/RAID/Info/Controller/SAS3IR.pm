package RAID::Info::Controller::SAS3IR;

use 5.014;
use namespace::autoclean;

use Moo;

with 'RAID::Info::Controller::SASxIR';

use IPC::System::Simple qw(capturex);

sub _load_data_from_controller {
  my ($self) = @_;
  return if defined $self->_display_raw;

  my $raw = capturex('sas3ircu', $self->id, 'display');
  $self->_display_raw($raw);
}

1;

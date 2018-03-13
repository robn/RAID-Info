package RAID::Info::Controller::LinuxPIIX;

use 5.014;
use namespace::autoclean;

use Moo;

with 'RAID::Info::Controller::LinuxSATA';

# hook for test suite
our $_SYS_PATH = '/sys/module/ata_piix/drivers/pci:ata_piix';

sub _sys_path { $_SYS_PATH };

sub _build_name {
  return "linuxpiix/0";
}

1;

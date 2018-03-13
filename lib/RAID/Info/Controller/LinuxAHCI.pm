package RAID::Info::Controller::LinuxAHCI;

use 5.014;
use namespace::autoclean;

use Moo;

with 'RAID::Info::Controller::LinuxSATA';

# hook for test suite
our $_SYS_PATH = '/sys/module/ahci/drivers/pci:ahci';

sub _sys_path { $_SYS_PATH };

sub _build_name {
  return "linuxahci/0";
}

1;

# Skunkworks in a Hyper-V Linux virtual machine
This document describes the steps needed to get skunkworks running on
Linux in a virtual machine. Hyper-V is a hypervisor included in Pro
editions of Windows and above. This guide assumes that the reader is
already able to create VMs with the Hyper-V Manager application.

This guide covers installing skunkworks on Ubuntu 20.04. The version
of Windows running on the host machine in this guide is 21H2.

## Installing Ubuntu as a VM
### Creating a bridged network adapter
In order for UPnP to work, a bridged network must be used instead of
the default NAT network.

In the Hyper-V Manager, ensure that your machine is selected on the
left pane and click `Virtual Switch Manager...`.

In the window that appears, make sure `External` is selected and click
on the `Create Virtual Switch` button. Give it a name and change the
network adapter under `Connection type` to the one connected to the
Internet. Finally, click `Ok` and accept the warning that is
displayed.

### Creating the virtual machine
You should be back at the main window. To create a VM click on the
`Quick Create...` button. A window will appear offering to set up an
operating system. Select Ubuntu 20.04 and give the machine an
alternate name if desired.

Before continuing, click the `More options` arrow and change the
network device to the bridged one made earlier.

### Edit settings (Optional)
Click `Edit settings...` to add more RAM, storage, and change the
number of virtual processors allocated. The default configuration
creates a virtual hard disk of only 12GB, so this may need to be
changed depending on your situation.

## Finalizing the installation
Upon starting and connecting to the VM you will be guided through a
number of configuration options involving localization and account
creation. This is fairly standard so it won't be covered.

It's recommended to install any updates that may have been released
after the release of Ubuntu. This can be done by issuing `sudo apt
update && sudo apt upgrade` and rebooting.

Upon rebooting, outdated packages should be removed with `sudo apt
autoremove`.

### Enable enhanced session mode (Optional)
This mode allows you to share clipboards and resize the display. This
requires that the auto-login feature is disabled. To upgrade to an
[enhanced session](https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/learn-more/use-local-resources-on-hyper-v-virtual-machine-with-vmconnect)
, run the following. This command will download a short installation script to setup XRDP.
```
wget https://raw.githubusercontent.com/Hinara/linux-vm-tools/ubuntu20-04/ubuntu/20.04/install.sh
sudo sh install.sh
```

Once that is completed, shut down the VM and run this command in an elevated PowerShell on the host machine.
```
Set-VM -VMName <your_vm_name> -EnhancedSessionTransportType HvSocket
```

**Troubleshooting**: This wasn't enough in my case, I had to click the
orange `Save` button at the login screen and reboot. As explained
[here](https://github.com/microsoft/linux-vm-tools/pull/106#issuecomment-674158083).

---

For some reason, by default XRDP doesn't source the users `.profile`.
This is remedied by adding the following to `/etc/xrdp/startwm.sh`
before the X session is launched, around line 32.

```shell
if [ -r $HOME/.profile ]; then
        . $HOME/.profile
fi
```

## Installing skunkworks
Head to the
[Getting started (Docker)](../README.md#getting-started-docker)
section of the README to start the containers and connect with wireguard.

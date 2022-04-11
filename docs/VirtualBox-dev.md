# Skunkworks in a VirtualBox balenaOS virtual machine
This document will guide you through the process of virtualizing a
balena device. This provides an effective method for rapid iteration
and local development.

This guide was adapted from an existing
[article](https://www.balena.io/blog/no-hardware-use-virtualbox/) on
balena's website. It assumes that you already have a balena account.

## Quick start
1. Create a x86_64 fleet
2. Add a device and download balenaOS
3. Convert the image to a VDI
4. Add it to a virtual machine
5. Start it!

## On balenaCloud
### Creating a fleet
Head to the balena [dashboard](https://dashboard.balena-cloud.com) and
sign in if you haven't already. First, click on the `Create fleet`
button and in the subsequent window, enter a name for the fleet and
choose "Generic x86_64" as the device type.

### Adding a device
Next, we must add a device. This can be done by clicking `Add device`
on the page of the fleet you just created. The options for the image
are fairly situational, but you should select the development edition.

Beside the `Flash` button there is a downward arrow. Click this and
select `Download balenaOS`. This image can be used for all future
devices, so you shouldn't need to re-download it.

## On the host machine
### Converting the image to a VirtualBox disk
On the command line, run this command. In Windows the `VBoxManage`
executable can be found in the VirtualBox installation directory, so
prefix that path to the command first (it's usually "C:\Program
Files\Oracle\VirtualBox").

```
VBoxManage convertfromraw <balena-cloud-app>.img <balena-cloud-app>.vdi
```

### Creating the virtual machine
In VirtualBox create a VM like normal with type "Other Linux
(64-bit)". There are some configurations that must be applied before
starting the VM. Open the settings for the VM and:

- Under the `System` submenu, enable EFI.
- Under `Storage`,
  - Remove the disk from the IDE controller. (Select the device and
    click the rightmost icon on the bottom.)
  - Add a SATA controller. (Click the leftmost icon)
  - Attach the disk removed earlier, this time to the SATA
    controller. (Click the hard drive icon next to "Controller:
    ACHI".)
  - Attach the balenaOS image created earlier to the same interface.
- Under `Network`, change the network adapter from `NAT` to `Bridged
  Adapter` and select the proper network card.

### Provisioning the VM
You may now start the VM and it will begin provisioning. This can
take some time but the VM will shutdown once it's finished. Being
shown a login screen is normal.

### Finallizing
With any luck you should now have a virtual balenaOS device and it
should appear on the balenaCloud dashboard. Before starting, you must
remove the balenaOS image otherwise it will begin provisioning again.

*Tip*: When starting the VM select `Headless Start` from the dropdown.

## Installing skunkworks
Head to the
[Getting started (Docker)](../README.md#getting-started-docker)
section of the README to start the containers and connect with wireguard.

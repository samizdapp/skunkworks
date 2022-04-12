# Skunkworks in a Hyper-V balenaOS virtual machine
This document will guide you through the process of virtualizing a
balena device. This provides an effective method for rapid iteration
and local development.

This guide assumes that you already have a balena account.

## Quick start
1. Create a x86_64 fleet
2. Add a device and download balenaOS
3. Convert the image to a VHDX
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
### Converting the image to a Hyper-V disk
Unfortunately, Hyper-V doesn't include a method to convert raw disk
images into the VHDX format. There are various utilities available
online to do this. The tool used in this guide is the `qemu-img`
utility available [here](https://cloudbase.it/qemu-img-windows/).

On the command line, run this command. This command shouldn't need to
be edited if you extracted qemu-img into the same folder as the
balenaOS image.

```
.\qemu-img.exe convert <balena-cloud-app>.img -O vhdx -o subformat=dynamic <balena-cloud-app>.vhdx
```

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
You should be back at the main window. To create a VM click `New` ->
`Virtual Machine...`. Configure the machine to your liking but make
sure to configure the following:

- Specify `Generation 2` when asked.
- When asked to configure networking, choose the bridged adapted made
  earlier.
- Leave the default `Install an operating system later` option
  selected.

Once you are back at the main window, select the virtual machine and
on the right side click on `Settings...`. You must disable Secure
Boot, and add a new hard disk. Specify the location to the balenaOS
image created earlier for that hard disk.

### Provisioning the VM
You may now start the VM and it will begin provisioning. This can take
some time but the VM will shutdown once it's finished. Booting can
take a while and it might look like it isn't doing anything. Being
shown a login screen is normal.

### Finallizing
With any luck you should now have a virtual balenaOS device and it
should appear on the balenaCloud dashboard. You may remove the
balenaOS image if you want.

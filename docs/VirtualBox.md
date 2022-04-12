# Skunkworks in a VirtualBox Linux virtual machine
This document describes the steps needed to get skunkworks running on
Linux in a virtual machine. This guide assumes that the reader is
already familiar with creating VMs with VirtualBox.

This guide covers installing skunkworks on Debian 11.

## Quick start
1. Create a new virtual machine
2. Change network type to bridged
3. Install Debian
4. Upgrade the system
5. Install skunkworks!

## Installing Ubuntu as a VM
### Creating the virtual machine
Create the virtual machine normally for your distro of choice and
attach a new disk. 

### Edit settings
Most settings can be left at their defaults. Download the Debian
installation ISO if you haven't already and attach it. You may want to
add more RAM, storage, and processors.

You are recommended to enable EFI.

### Begin installing Debian
Configure and install Debian to your liking. You will be guided
through a number of configuration options involving localization,
account creation and storage. This is fairly standard so it won't be
covered.

## Finalizing the installation
It's recommended to install any updates that may have been released
after the release of Debian. This can be done by issuing `sudo apt
update && sudo apt upgrade` and rebooting.

Upon rebooting, outdated packages should be removed with `sudo apt
autoremove`.

## Installing skunkworks
Head to the
[Getting started (Docker)](../README.md#getting-started-docker)
section of the README to start the containers and connect with wireguard.

# Nikita Arch

## Steps

There are 3 main steps:

1. Preparation: prepare a bootable disk and open an SSH access
2. Bootstrap: Encrypt and partition the drive and finally install a minimal OS
3. System install: Deploy all configurations, tools and services

## Step 1: preparation

For now, the preparation process is manual.

### Download

First, [download the arch distribution](https://www.archlinux.org/download/) as an ISO image.

Create a bootable USB stick:

The easiest way to create a bootable Arch Linux on USB is by using the [Etcher GUI tool](https://www.balena.io/etcher/) available on Linux, Windows and MacOS. Ubuntu also provide some good instructions such as the one for [MacOS](https://tutorials.ubuntu.com/tutorial/tutorial-create-a-usb-stick-on-macos).

Alternatively, if you favor CLI commands, you can use the dd command to create a live USB. You can refer to the Arch Linux documentation on how to use [`dd` for Linux, Windows and MacOS](https://wiki.archlinux.org/index.php/USB_flash_installation_media).

### Boot

Ensure the target host can boot over USB and that the disks are discoverable. For Dell Precision, press F2 to enter the BIOS, and modify:

1. General: Advanced Boot Options: Enable Legacy Option ROMs
2. Secure Boot: Secure Boot Enable: Disabled
3. System Configuration: SATA Operation : AHCI
4. Save the BIOS settings and reboot while pressing F12

Boot the computer over the USB system. On startup, select "Boot Arch Linux (x86_64)".

### Network activation

From the drive containing the Arch installation media:

```bash
# Connect to the internet (see: https://wiki.archlinux.org/index.php/Iwd#iwctl)
iwctl
device list
station {device} scan
station {device} get-networks
station {device} connect {my_device}
```

The following procedure will setup an SSH server and is only required if you wish to execute the bootstrap procedure of step 2 through SSH from an external host which is recommended. Note, the `openssh` package shall already be installed.

```bash
# Create new password, root user is passwordless by default (cf. `cat etc/shadow`)
passwd
# Start ssh daemon
systemctl start sshd
# Print IP address
ip a
```

## Step 2: bootstrap

The bootstrap process can be executed either from the bootable system or from a remote location through SSH. From your host machine

1. Clone this repository
2. Set your target IP address in `./conf/bootstrap.coffee`
3. Edit any other configuration of interest
4. Run `npm run bootstrap`
  - Here you'll be prompted to select the installation target (_Local_ or _Remote SSH_).
    If you choose the **_recommended_** _Remote SSH_, you'll be prompted for target machine's below details, which will be written to conf/user.yaml:
    - _hostname_
    - _username_
    - _password_
    - _disk encryption password_

Reboot into the BIOS and create a new UEFI entry, for example set "EFI/systemd/systemd-bootx64.efi"  in "Settings/General/Boot Sequence".

## System (Optional)

From your host machine

1. Clone this repository: `git clone https://github.com/adaltas/node-nikita-arch.git`
2. Run `ssh-keygen` to create key pairs for SSH with no password
3. Edit any other configuration of interest
4. Run `npm run system` (The first time the command is run, your user configuration is created in user.yaml)

> Note, system may also be executed from a remote location
1. Edit the configuration "./conf/user.yaml" and add your SSH connection settings
2. Enable sudo passwordless eg `sudo su -; echo '<username> ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers`



## Complementary documentations

* [Troubleshooting](./doc/troubleshooting.md)
* [Dell Precision 5520 specifics](./doc/dell.md)
* [GDM service autostart (fixed)](./doc/gdm_autostart_issue.md)
* [Virtualbox](./doc/virtualbox.md)


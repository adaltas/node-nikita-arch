
# Nikita Arch

## Steps

There are 3 main steps:

1. Preparation: prepare a bootable disk and open an SSH access
2. Bootstrap: Encrypt and partition the drive and finally install a minimal OS
3. System install: Deploy all configurations, tools and services

## Step 1: preparation

For now, the preparation process is manual.

First, [download the arch distribution](https://www.archlinux.org/download/) as an ISO image.

Create a bootable USB stick:

* [`dd` for Linux, Windows and MacOS](https://wiki.archlinux.org/index.php/USB_flash_installation_media)
* [OSX graphical instructions](https://tutorials.ubuntu.com/tutorial/tutorial-create-a-usb-stick-on-macos)

Ensure the target host can boot over USB. For Dell Precision, press F2 to enter the BIOS, en modify:

1. General: Advanced Boot Options: Enable Legacy Option ROMs
2. Secure Boot: Secure Boot Enable: Disabled
3. Save the BIOS settings and reboot while pressing F12

Boot the computer over the USB system. On startup, select "Boot Arch Linux (x86_64)".

From the drive containing the Arch installation media

```
# Start the computer
# Select "Boot Arch Linux"
# Connect to the internet
wifi-menu
```

The following procedure will setup an SSH server and is only required if you wish to execute the bootstrap procedure of step 2 through SSH from an external host which is recommended.

```
# Change root password
passwd
# Install ssh
pacman -Sy openssh
# Start ssh daemon
systemctl start sshd
# Print IP address
ip a
```

Copy the file 'conf/base.yaml' to 'conf/user.yaml' and modify the connection information, such as "hostname" and "password", and the user information. By default, a "nikita" user is created as sudoer with the "secret" password.

## Step 2: bootstrap

The bootstrap process can be executed either from the bootable system or from a remote location through SSH. From your host machine

1. Clone this repository
2. Set your target IP address in "./conf/bootstrap.coffee"
3. Edit any other configuration of interest
4. Run `npm run bootstrap`

Reboot into the BIOS and create a new UEFI entry, for example set "EFI/systemd/systemd-bootx64.efi"  in "Settings/General/Boot Sequence".

## System

From your host machine

1. Clone this repository
2. Create and modify your user configuration in "user.yaml"
3. Edit any other configuration of interest
4. Run `npm run system`

Note, system may also be executed from a remote location
1. Edit the configuration "./conf/user.yaml" and add your SSH connection settings
2. Enable sudo passwordless eg `sudo su -; echo '<username> ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers`


## Troubleshooting

### Disk Timeout

Symtoms: The disks time out, do not show up in initramfs. 

Check the RAID parameters in BIOS and switch back to AHCI.


# Nikita Arch

## Steps

There are 3 main steps:

1. Preparation: prepare a bootable disk and open an SSH access
2. Bootstrap: Encrypt and partition the drive and finally install a minimal OS
3. System install: Deploy all configurations, tools and services

## Step 1: preparation

For now, the preparation process is manual.

Create a bootable USB stick
* [`dd` for Linux, Windows and MacOS](https://wiki.archlinux.org/index.php/USB_flash_installation_media)
* [OSX graphical instructions](https://tutorials.ubuntu.com/tutorial/tutorial-create-a-usb-stick-on-macos#0)

Ensure the target host can boot over USB
For Dell Precision, press F2 to enter the BIOS, en modify
1. Secure Boot: Secure Boot Enable: Enabled
2. Advanced Boot Options: Enable Legacyf Option ROMs
Optional and not sure, activate UEFI from the BIOS, path is "/loader/entries/archiso-x86_64.conf"

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
ip addr show
```

Copy the file 'conf/base.yaml' to 'conf/user.yaml' and modify the connection information, such as "hostname" and "password", and the user information. By default, a "nikita" user is created with the "secret" password.

## Step 2: bootstrap

The bootstrap process can be executed either from the bootable system or from a remote location through SSH. From your host machine

1. Clone this repository
2. Set your target IP address in "./conf/bootstrap.coffee"
3. Edit any other configuration of interest
4. Run `npm run bootstrap`

Reboot, update the bios UEFI entry, for exemple set "EFI/systemd/systemd-bootx64.efi"  in "Settings/General/Boot Sequence".

## System

From your host machine

1. Clone this repository
2. Create and modify your user configuration in "user.yaml"
3. Edit any other configuration of interest
4. Run `npm run system`

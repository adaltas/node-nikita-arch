
# Nikita Arch

## Bootstrap

Create a bootable USB stick
* [`dd` for Linux, Windows and MacOS](https://wiki.archlinux.org/index.php/USB_flash_installation_media)
* [OSX graphical instructions](https://tutorials.ubuntu.com/tutorial/tutorial-create-a-usb-stick-on-macos#0)

Optional and not sure, activate UEFI from the BIOS, path is "/loader/entries/archiso-x86_64.conf"

From the drive containing the Arch installation media

```
# Start the computer
# Select "Boot Arch Linux"
# Connect to the internet
wifi-menu
# Change root password
passwd
# Install ssh
pacman -Sy
pacman -S openssh
# Start ssh daemon
systemctl start sshd
# Print IP address
ip addr show
```

From your host machine

1. Clone this repository
2. Set your target IP address in "./conf/bootstrap.coffee"
3. Edit any other configuration of interest
4. Run `npm run bootstrap`

Reboot, update the bios UEFI entry

## System

From your host machine

1. Clone this repository
2. Set your target IP address in "./conf/bootstrap.coffee"
3. Edit any other configuration of interest
4. Run `npm run system`

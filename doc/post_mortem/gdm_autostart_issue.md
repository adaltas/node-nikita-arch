# **gdm.service autostart issue**

The display manager service is not started at boot and needs to be restarted at boot manually with the command `systemctl restart gdm.service`.

the command `systemctl list-unit-files --state=enabled` shows that gdm.service is started but `VENDOR PRESET` is disabled. It means when the service first installs it will be disabled on start up and will have to be manually started.

**UPDATE:** This issue does not seem to appear in a consistent manner; gdm would occasionally display a proper boot screen to the GNOME desktop after multiple reboots.
\
\
It can be surmised from this behaviour that the issue is related to race conditions: gdm executes itself before the nvidia module is properly loaded. Thus, gdm locks up and displays a black screen instead of the normally expected login screen.
<br/><br/>

## **Force nvidia module to load first**

Hardware used: Dell Precision 5520 (Nvidia Quadro M1200 Mobile)
\
\
The idea is to force the nvidia module to load before gdm does anything; gdm will then display the proper graphical login interface instead of the terminal.

To do this, we can edit "/etc/mkinitcpio.conf" in the following way:

```
sudo nano /etc/mkinitcpio.conf
```

```
/etc/mkinitcpio.conf

MODULES=(... nvidia ...)
```

'mkinitcpio' is used to generate an initial working environment within which necessary kernel modules will be loaded ***before*** anything else is executed. Therefore, by including the nvidia module in this file, we can be assured that it will be loaded before gdm can execute anything.

<br/><br/>
<br/><br/>

## Former methods to fix this issue are detailed below for posterity.

---------------------------------------------

## "Dirty" fix

Still have terminal as login screen but no need to restart `gdm.service`.

**Display manager symlink**

Check if a symlink `display-manager.service` is set in `/etc/systemd/system/`. If not run the followind command

```bash
file /etc/systemd/system/display-manager.service
```

**Starting a Wayland session**

To start on login to tty1 append the following to your .bash_profile

> Make sure to set the right `tty` in my case it is `tty4`

```bash
# ~/.bash_profile
if [[ -z $DISPLAY && $(tty) == /dev/tty1 && $XDG_SESSION_TYPE == tty ]]; then
  MOZ_ENABLE_WAYLAND=1 QT_QPA_PLATFORM=wayland XDG_SESSION_TYPE=wayland exec dbus-run-session gnome-session
fi
```

Append the following in your `/usr/lib/systemd/system-preset/90-systemd.preset` file

```bash
sudo sh -c 'echo enable gdm.service >> /usr/lib/systemd/system-preset/90-systemd.preset'
```

Reboot.

---------------------------------------------
<br/><br/>

**Root causes**:
Configuration failure due to the lack of a configuration in the bootstrap part of Arch Linux's installation. In gdm rules, a rule defined by default in 'lib/udev/rules.d/61-gdm.rules', disables the use of Wayland with intel and nvidia graphics cards:

```
# disable Wayland on Hi1710 chipsets
#ATTR{vendor}=="0x19e5", ATTR{device}=="0x1711", RUN+="/usr/lib/gdm-disable-wayland"
# disable Wayland when using the proprietary nvidia driver
#DRIVER=="nvidia", RUN+="/usr/lib/gdm-disable-wayland"
# disable Wayland if modesetting is disabled
#IMPORT{cmdline}="nomodeset", RUN+="/usr/lib/gdm-disable-wayland"
```

Thus, when starting for the first time, the usage of Wayland is disabled by gdm rules. Wayland is set to false in custom.conf :

``` 
[daemon]
WaylandEnable=false
```

**Observations**: The configuration problem causes a black screen at startup. To work around this problem and force the gdm to launch, you must type **ctrl + alt + f5** to access the terminal. After logging in, you have to edit the custom.conf file by setting the wayland to true then restart the gdm with the command: 

```
systemctl restart gdm.service
```

This way of launching the gdm is only temporary because once the computer is turned on the wayland will be disabled again

**Resolution**: Changing configuration of gdm rules and forcing the usage of Wayland in custom.conf by changing the bootstrap part of Arch Linux's installation.

* Gdm rules are commented out in '61-gdm.rules' file in order to use Wayland
* Usage of Wayland in Gdm configuration is forced by changing configuration to true:
``` 
[daemon]
WaylandEnable=true
```



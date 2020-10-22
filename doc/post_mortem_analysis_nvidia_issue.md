# Nvidia with Wayland Post-Mortem Analysis

**Status**: Complete

**Summary**: Nvidia graphic card not usable with wayland due to a problem with the gdm configuration in bootstrap installation

**Root causes**:
Configuration failure due to the lack of a configuration in the bootstrap part of Arch Linux's installation. In gdm rules, a rule defined by default in 'lib/udev/rules.d/61-gdm.rules', disables the usable of Wayland with intel and nvidia graphics cards:
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

**Observations**: The configuration problem causes a black screen at startup. To work around this problem and force the gdm to launch, you must type ctrl + alt + f5 to access the terminal. After logging in, you have to edit the custom.conf file by setting the wayland to true then restart the gdm with the command: 
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

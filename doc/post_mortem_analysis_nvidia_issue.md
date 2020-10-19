# Post-Mortem Analysis of Nvidia use with Wayland issue

The nvidia graphics card can be used with Wayland on condition that it is correctly configured in the installation of Arch Linux.

The custom.conf file of gdm must enable the use of wayland:
``` 
[daemon]
WaylandEnable=true
```

The default gdm rules in 'lib/udev/rules.d/61-gdm.rules' disable the use of Wayland by setting Wayland at boot to false in custom.conf. We put in comments its lines in order to use it:

``` 
# disable Wayland on Hi1710 chipsets
#ATTR{vendor}=="0x19e5", ATTR{device}=="0x1711", RUN+="/usr/lib/gdm-disable-wayland"
# disable Wayland when using the proprietary nvidia driver
#DRIVER=="nvidia", RUN+="/usr/lib/gdm-disable-wayland"
# disable Wayland if modesetting is disabled
#IMPORT{cmdline}="nomodeset", RUN+="/usr/lib/gdm-disable-wayland"
```

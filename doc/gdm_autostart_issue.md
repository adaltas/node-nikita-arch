# gdm.service autostart issue

The display manager service is not started at boot and is restarted at boot manually with the command `systemctl restart gdm.service`.

the command `systemctl list-unit-files --state=enabled` shows that gdm.service is started but `VENDOR PRESET` is disabled. It means when the service first installs it will be disabled on start up and will have to be manually started

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



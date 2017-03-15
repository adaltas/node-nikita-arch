
# Nikita Arch

## Bootstrap

From the drive containing the Arch installation media 

```
# Internet Connection
3
# Change root password
passwd
# Install ssh
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

## System

From your host machine

1. Clone this repository
2. Set your target IP address in "./conf/bootstrap.coffee"
3. Edit any other configuration of interest
4. Run `npm run system`

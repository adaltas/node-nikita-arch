
require '@nikitajs/filetypes/lib/register'

module.exports = header: "System", handler: ({options}) ->
  options.locale ?= 'en_US.UTF-8'
  for username, user of options.users
    user.name ?= username
    user.group ?= user.name
    user.home ?= "/home/#{username}"
  # `umount --recursive /mnt` to exit and enter with `arch-chroot /mnt /bin/bash`
  @system.execute
    header: 'Mount'
    cmd: """
    if \
      df | grep /dev/mapper/volume-root && \
      df | grep /dev/mapper/volume-home ;
      then exit 3; fi
    # Mount
    mount /dev/mapper/volume-root /mnt
    mkdir /mnt/home
    mount /dev/mapper/volume-home /mnt/home
    swapon /dev/mapper/volume-swap
    mkdir /mnt/boot
    mount #{options.boot_partition} /mnt/boot
    """
    code_skipped: 3
  @system.execute
    header: 'Fstab'
    cmd: """
    echo '\\n\\n1\\n' | pacstrap -i /mnt base base-devel net-tools
    genfstab -U -p /mnt > /mnt/etc/fstab
    """
    shy: true # Status not handled for now
  @file.types.pacman_conf
    header: 'Pacman conf'
    target: '/mnt/etc/pacman.conf'
    content:
      'archlinuxfr':
        'SigLevel': 'Never'
        'Server': 'http://repo.archlinux.fr/$arch'
      'multilib':
        'Include': '/etc/pacman.d/mirrorlist'
    merge: true
    backup: true
  @system.execute
    header: 'Pacman update'
    arch_chroot: true
    rootdir: '/mnt'
    cmd: """
    pacman -Syy
    """
    shy: true
  @service.install
    header: 'Linux headers'
    arch_chroot: true
    rootdir: '/mnt'
    name: 'linux-headers'
  # Installing Linux because mkinitcpio alone is not enough as it create
  # "/etc/mkinitcpio.conf" and "/etc/mkinitcpio.d"
  # but there is no "/etc/mkinitcpio.d/linux.preset"
  @service.install
    header: 'Linux'
    arch_chroot: true
    rootdir: '/mnt'
    name: 'linux'
    # Installing linux-firmware because otherwise the network card is not
    # activated with `dmesg | grep firmware` printing a message such as
    # "iwlwifi no suitable firmare found"
  @service.install
    header: 'Linux'
    arch_chroot: true
    rootdir: '/mnt'
    name: 'linux-firmare'
  @file.types.locale_gen
    header: 'Locale gen'
    arch_chroot: true
    rootdir: '/mnt'
    locales: options.locales
    locale: options.locale
    generate: true
  @file
    header: 'Locale conf'
    target: '/mnt/etc/locale.conf'
    content: "LANG=#{options.locale}"
  @system.execute
    header: 'Timezone'
    arch_chroot: true
    rootdir: '/mnt'
    cmd: """
    [ "$(readlink /etc/localtime)" = "/usr/share/zoneinfo/#{options.timezone}" ] && exit 3
    [ -f /usr/share/zoneinfo/#{options.timezone} ] || exit 1
    ln -sf /usr/share/zoneinfo/#{options.timezone} /etc/localtime
    hwclock --systohc --utc
    exit
    """
    code_skipped: 3
  @service.install
    header: "Package nvidia"
    arch_chroot: true
    rootdir: '/mnt'
    name: 'nvidia-dkms'
  # mkinitcpio is a Bash script used to create an initial ramdisk environment.
  # The initial ramdisk is in essence a very small environment (early userspace)
  # which loads various kernel modules and sets up necessary things before
  # handing over control to init. This makes it possible to have, for example,
  # encrypted root file systems and root file systems on a software RAID array.
  # mkinitcpio allows for easy extension with custom hooks, has autodetection at
  # runtime, and many other features.
  @call (_, callback) ->
    @fs.readFile
      target: "/mnt/etc/mkinitcpio.conf"
      encoding: 'ascii'
    , (err, {data}) ->
      return callback err if err
      data = data.split '\n'
      for line, i in data
        status = true
        if /^MODULES=/.test line
          # Was `"..."`, is now `(...)`
          modules = original = line.replace /MODULES=["\(](.*)["\)]/, "$1"
          modules = modules.split ' '
          # place = modules.indexOf 'keyboard'
          for module in ["nvidia"]
            modules.push module unless module in modules
          modules = modules.join ' '
          status = false if modules is original
          data[i] = "MODULES=(#{modules})"
        if /^HOOKS=/.test line
          # Was `"..."`, is now `(...)`
          hooks = original = line.replace /HOOKS=["\(](.*)["\)]/, "$1"
          hooks = hooks.split ' '
          place = hooks.indexOf 'keyboard'
          for hook in ["encrypt", "lvm2", "resume"].reverse()
            hooks.splice place+1, 0, hook unless hook in hooks
          hooks = hooks.join ' '
          status = false if hooks is original
          data[i] = "HOOKS=(#{hooks})"
      return callback null, false unless status
      data = data.join '\n'
      @fs.writeFile
        target: '/mnt/etc/mkinitcpio.conf'
        content: data
      @next (err) -> callback err, true
  @system.execute
    header: 'mkinitcpio'
    arch_chroot: true
    rootdir: '/mnt'
    cmd: """
    [ -f /boot/vmlinuz-linux ] && exit 3
    mkinitcpio -p linux
    # Note, called a second time just below for no good reason
    #bootctl install # on 2nd attemp: Failed to open loader.conf for writing: File exists
    exit
    """
    code_skipped: 3
  @system.execute
    header: 'Boot loader'
    arch_chroot: true
    rootdir: '/mnt'
    cmd: """
    [ -f /boot/loader/loader.conf ] && exit 3
    bootctl install
    exit
    """
    code_skipped: 3
  @system.execute
    header: 'Boot arch loader'
    arch_chroot: true
    rootdir: '/mnt'
    cmd: """
    [ -f /boot/loader/entries/arch.conf ] && exit 3
    # Get UUID of /boot, root, and swap partition
    uuid_boot=`blkid -s UUID -o value /dev/nvme0n1p2`
    uuid_root=`blkid -s UUID -o value /dev/mapper/volume-root`
    uuid_swap=`blkid -s UUID -o value /dev/mapper/volume-swap`
    cat >/boot/loader/entries/arch.conf <<CONF
    title Archy ## Replace the name as you want
    linux /vmlinuz-linux
    initrd /intel-ucode.img
    initrd /initramfs-linux.img
    # i915.preliminary_hw_support=1 Remove ACPI error at boot time, no longer required after latest BIOS update (march 2017c)
    options cryptdevice=UUID=$uuid_boot:volume root=UUID=$uuid_root resume=UUID=$uuid_swap quiet rw pcie_port_pm=off rcutree.rcu_idle_gp_delay=1 intel_idle.max_cstate=1 acpi_osi=! acpi_osi="Windows 2009" acpi_backlight=native i8042.noloop i8042.nomux i8042.nopnp i8042.reset
    CONF
    """
    code_skipped: 3
  for username, user of options.users
    @system.user user,
      no_home_ownership: true
      arch_chroot: true
      rootdir: '/mnt'
    @system.execute
      header: 'User Sudoer'
      arch_chroot: true
      rootdir: '/mnt'
      cmd: """
      sudoer=#{if user.sudoer then '1' else ''}
      ([ -z $sudoer ] || cat /etc/sudoers | grep "#{username}") && exit 3
      echo "#{username} ALL=(ALL) ALL" >> /etc/sudoers
      """
      code_skipped: 3
  (
    @service.install
      header: "Package #{pck}"
      arch_chroot: true
      rootdir: '/mnt'
    , pck
  ) for pck in [ # , "nvme-cli"
    "xf86-video-intel", "intel-ucode", "bbswitch"
    "primus", "lib32-primus", "lib32-virtualgl", "lib32-nvidia-utils"
  ]
  @service.install
    header: 'Package mesa'
    arch_chroot: true
    rootdir: '/mnt'
    name: 'lib32-mesa'
  @service.install
    header: 'Package vulkan-intel'
    arch_chroot: true
    rootdir: '/mnt'
    name: 'vulkan-intel'
  (
    @service.install
      header: "Package #{pck}"
      arch_chroot: true
      rootdir: '/mnt'
    , pck
  ) for pck in [ # , "nvme-cli"
    "acpi", "gnome", "gdm", "gnome-extra", "system-config-printer", "networkmanager",
    "rhythmbox", "xorg-server", "xorg-xinit", "xorg-apps", "xorg-twm",
    "xorg-xclock", "xterm"
  ]
  for username, user of options.users
    @call header: 'xinit', ->
      @file
        target: "/mnt/#{user.home}/.xinitrc"
        content: """
        xrandr --setprovideroutputsource modesetting NVIDIA-0
        xrandr --auto
        """
        eof: true
      @system.execute
        if: -> @status -1
        arch_chroot: true
        rootdir: '/mnt'
        cmd: """
        chown #{user.username}:#{user.group} #{user.home}/.xinitrc
        chmod 644 #{user.home}/.xinitrc
        """
        code_skipped: 3
  @system.execute
    header: "Video Card"
    arch_chroot: true
    rootdir: '/mnt'
    cmd: 'lspci | grep -E "VGA|3D"'
  @file
    target: '/mnt/etc/X11/xorg.conf'
    content: """
    # nvidia-xconfig: X configuration file generated by nvidia-xconfig
    # nvidia-xconfig:  version 378.13  (buildmeister@swio-display-x86-rhel47-05)  Tue Feb  7 19:37:00 PST 2017

    Section "ServerLayout"
        Identifier     "layout"
        Screen      0  "nvidia"
        Inactive	   "intel"
        InputDevice    "Keyboard0" "CoreKeyboard"
        InputDevice    "Mouse0" "CorePointer"
    EndSection

    Section "Files"
    EndSection

    Section "InputDevice"
        # generated from default
        Identifier     "Mouse0"
        Driver         "mouse"
        Option         "Protocol" "auto"
        Option         "Device" "/dev/psaux"
        Option         "Emulate3Buttons" "no"
        Option         "ZAxisMapping" "4 5"
    EndSection

    Section "InputDevice"
        # generated from default
        Identifier     "Keyboard0"
        Driver         "kbd"
    EndSection

    Section "Monitor"
        Identifier     "Monitor0"
        VendorName     "Unknown"
        ModelName      "Unknown"
        HorizSync       28.0 - 33.0
        VertRefresh     43.0 - 72.0
        Option         "DPMS"
    EndSection

    Section "Device"
    #    Identifier     "Device0"
        Identifier     "nvidia"
        Driver         "nvidia"
        VendorName     "NVIDIA Corporation"
        BusID	   "PCI:1:0:0"
    EndSection

    Section "Screen"
        Identifier     "nvidia"
        Device         "nvidia"
        Option         "AllowEmptyInitialConfiguration" "Yes"
    EndSection

    Section "Device"
        Identifier "intel"
        Driver "modesetting"
        BusID "PCI:0:2:0"
        Option "AccelMethod"  "none"
    EndSection

    Section "Screen"
        Identifier "intel"
        Device "intel"
    EndSection
    """
  @service.startup
    header: 'Startup gdm'
    arch_chroot: true
    rootdir: '/mnt'
    name: 'gdm'
  @service.startup
    header: 'Startup NetworkManager'
    arch_chroot: true
    rootdir: '/mnt'
    name: 'NetworkManager'
  # TODO: configure this and bbswitch
  @call
    header: 'Bumblebee'
    if: options.install_bumblebee
  , ->
    @service.install
      header: "Package"
      arch_chroot: true
      rootdir: '/mnt'
      name: 'bumblebee'
    @file
      header: 'Bumblebee Configuration'
      target: "/mnt/etc/bumblebee/bumblebee.conf"
      match: /^Bridge=.*$/m
      replace: "Bridge=primus"
      backup: true
    for username, user of options.users
      @system.execute
        header: "Bumblebee for #{username}"
        arch_chroot: true
        rootdir: '/mnt'
        cmd: """
        id #{username} | grep \\(bumblebee\\) && exit 3
        gpasswd -a #{username} bumblebee
        """
        code_skipped: 3
    @service.startup
      header: 'Startup bumblebeed'
      arch_chroot: true
      rootdir: '/mnt'
      name: 'bumblebeed'
  @service
    name: 'openssh'
    srv_name: 'sshd'
    startup: true

## Dependencies

fs = require 'ssh2-fs'

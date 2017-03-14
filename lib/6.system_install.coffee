
module.exports = header: "System Install", handler: (options) ->
  options.locale ?= 'en_US.UTF-8'
  # `umount --recursive /mnt` to exit and enter with `arch-chroot /mnt /bin/bash`
  @system.execute
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
    mount /dev/nvme0n1p1 /mnt/boot
    """
    code_skipped: 3
  @system.execute
    cmd: """
    echo '\\n\\n' | pacstrap -i /mnt base base-devel net-tools
    genfstab -U -p /mnt >> /mnt/etc/fstab
    """
    shy: true # Status not handled for now
  @system.execute
    header: 'Locale'
    arch_chroot: true
    chroot_dir: '/mnt'
    cmd: """
    cat /etc/locale.conf | grep 'LANG=#{options.locale}' && exit 3
    if ! cat /etc/locale.gen | grep "#{options.locale}"; then exit 1; fi
    locale-gen
    echo 'LANG=#{options.locale}' >> /etc/locale.conf
    exit
    """
    code_skipped: 3
  @system.execute
    header: 'Timezone'
    arch_chroot: true
    chroot_dir: '/mnt'
    cmd: """
    [ "$(readlink /etc/localtime)" = "/usr/share/zoneinfo/#{options.timezone}" ] && exit 3
    [ -f /usr/share/zoneinfo/#{options.timezone} ] || exit 1
    ln -sf /usr/share/zoneinfo/#{options.timezone} /etc/localtime
    hwclock --systohc --utc
    exit
    """
    code_skipped: 3
  @call (_, callback) ->
    fs.readFile options.ssh, "/mnt/etc/mkinitcpio.conf", 'ascii', (err, content) ->
      return callback err if err
      content = content.split '\n'
      for line, i in content
        continue unless /^HOOKS=/.test line
        hooks = original = line.replace /.*"(.*)"/, "$1"
        hooks = hooks.split ' '
        place = hooks.indexOf 'keyboard'
        for hook in ["encrypt", "lvm2", "resume"].reverse()
          hooks.splice place+1, 0, hook unless hook in hooks
        hooks = hooks.join ' '
        return callback null, false if hooks is original
        content[i] = "HOOKS=\"#{hooks}\""
        content = content.join '\n'
        fs.writeFile options.ssh, "/mnt/etc/mkinitcpio.conf", content, (err) ->
          callback err, true
  @system.execute
    header: 'mkinitcpio'
    arch_chroot: true
    chroot_dir: '/mnt'
    cmd: """
    [ -f /boot/vmlinuz-linux ] && exit 3
    mkinitcpio -p linux
    bootctl install # on 2nd attemp: Failed to open loader.conf for writing: File exists
    exit
    """
    code_skipped: 3
  @system.execute
    header: 'Boot loader'
    arch_chroot: true
    chroot_dir: '/mnt'
    cmd: """
    [ -f /boot/loader/loader.conf ] && exit 3
    bootctl install
    exit
    """
    code_skipped: 3
  @system.execute
    header: 'Boot arch loader'
    arch_chroot: true
    chroot_dir: '/mnt'
    cmd: """
    [ -f /boot/loader/entries/arch.conf ] && exit 3
    # Get UUID of /boot partition
    uuid=`blkid -s UUID -o value /dev/nvme0n1p2`
    echo >/boot/loader/entries/arch.conf <<CONF
    title Archy ## Replace the name as you want
    linux /vmlinuz-linux
    initrd /intel-ucode.img
    initrd /initramfs-linux.img
    options cryptdevice=UUID=$uid:volume root=/dev/mapper/volume-root resume=/dev/mapper/volume-swap quiet rw pcie_port_pm=off rcutree.rcu_idle_gp_delay=1 intel_idle.max_cstate=1 pcie_port_pm=off
    CONF
    """
    code_skipped: 3
  for username, user of options.users
    useradd = 'useradd'
    useradd += " -d #{user.home}" if user.home
    useradd += " -s #{user.shell}" if user.shell
    useradd += " -c #{string.escapeshellarg user.comment}" if user.comment?
    useradd += " -g #{user.gid}" if user.gid
    useradd += " -G #{user.groups.join ','}" if user.groups
    useradd += " -u #{user.uid}" if user.uid
    useradd += " #{username}"
    @system.execute
      header: 'User Entry'
      arch_chroot: true
      chroot_dir: '/mnt'
      cmd: """
      id "#{username}" >/dev/null && exit 3
      #{useradd}
      """
      code_skipped: 3 # Status not based on full diff
    @system.execute
      header: 'User Password'
      arch_chroot: true
      chroot_dir: '/mnt'
      cmd: """
      id "#{username}" >/dev/null || #{useradd}
      digest=`openssl passwd -1 #{user.password}`
      echo "#{username}:$digest" | chpasswd -e
      """
      shy: true # Status not implemented
    @system.execute
      header: 'User Sudoer'
      arch_chroot: true
      chroot_dir: '/mnt'
      cmd: """
      sudoer=#{user.sudoer or ''}
      [ ! -n $sudoer ] || ! cat /etc/sudoers | grep "#{username}" exit 3
      echo "#{username} ALL=(ALL) ALL" >> /etc/sudoers
      """
      code_skipped: 3
  @file.types.pacman_conf
    target: '/mnt/etc/pacman.conf'
    content: 'archlinuxfr':
      'SigLevel': 'Never'
      'Server': 'http://repo.archlinux.fr/$arch'
    merge: true
    backup: true
  @system.execute
    header: 'User'
    arch_chroot: true
    chroot_dir: '/mnt'
    cmd: """
    # Update database
    pacman -Syy
    """
    shy: true
  @service.install
    header: "Package yaourt"
    arch_chroot: true
    chroot_dir: '/mnt'
    name: 'yaourt'
  (
    @service.install
      header: "Packages Graphic"
      arch_chroot: true
      chroot_dir: '/mnt'
    , pck
  ) for pck in [ # , "nvme-cli"
    "nvidia", "xf86-video-intel", "intel-ucode", "bumblebee", "bbswitch"
  ]
  @system.arch_chroot
    header: 'mkinitcpio'
    if: -> @status -1
    chroot_dir: '/mnt'
    cmd: """
    mkinitcpio -p linux
    """
    code_skipped: 3
  (
    @service.install
      header: "Package #{pck}"
      arch_chroot: true
      chroot_dir: '/mnt'
    , pck
  ) for pck in [ # , "nvme-cli"
    "acpi", "atom", "gnome", "gdm", "gnome-extra", "system-config-printer", "networkmanager", 
    "rhythmbox", "xorg-server", "xorg-xinit", "xorg-utils", "xorg-server-utils", "xorg-twm", 
    "xorg-xclock", "xterm", "firefox", "thunderbird"
  ]
  # @file
  #   header: 'xinit'
  #   target: '/mnt/root/.xinitrc'
  #   content: """
  #   xrandr --setprovideroutputsource modesetting NVIDIA-0
  #   xrandr --auto
  #   """
  #   eof: true
  # @system.execute
  #   header: 'GDM'
  #   arch_chroot: true
  #   chroot_dir: '/mnt'
  #   cmd: """
  #   systemctl enable gdm
  #   """
  # @file
  #   header: 'Bumblebee Configuration'
  #   target: "/mnt/etc/bumblebee/bumblebee.conf"
  #   match: /^Bridge=auto$/m
  #   replace: "Bridge=virtualgl"
  # for username, user of options.users
  #   @system.execute
  #     header: "Bumblebee for #{username}"
  #     arch_chroot: true
  #     chroot_dir: '/mnt'
  #     cmd: """
  #     id wdavidw | grep \\(bumblebee\\) && exit 3
  #     gpasswd -a #{username} bumblebee
  #     """
  #     code_skipped: 3
  # @system.execute
  #   header: "Video Card"
  #   arch_chroot: true
  #   chroot_dir: '/mnt'
  #   cmd: 'lspci | grep -E "VGA|3D"'
  
  


## Dependencies

fs = require 'ssh2-fs'
    

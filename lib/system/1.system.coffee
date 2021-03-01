
###

* `locale` (string)
  System locale, default to the first locale in "locales" config.
* `locales` (string)
  List of supported locales, required.

Interesting commands

* `yaourt -Ssq ${name}`
  Search packages by name
* `pacman -Rns ${name}`
  Remove a package
* `pacman -Qdtq | pacman -Rcsn -`
  Remove all the packages that were installed as a dependency and are no longer needed

###

module.exports = ({config}) ->
  throw Error "Required option: locales" unless config.locales
  ssh = @ssh config.ssh
  home = if ssh then "/home/#{ssh.config.username}" else '~'
  config.locale ?= config.locales[0]
  @call
    metadata: header: 'Maintenance'
    if: config.upgrade
  , ->
    @execute
      metadata: header: 'Upgrade'
      command: """
      pacman --noconfirm -Syyu
      """
    @execute
      metadata: header: 'Cleanup Orphan'
      command: """
      pacman --noconfirm -Rns $(pacman -Qtdq)
      """
  @call metadata: header: 'System Configuration', ->
    for group in config.groups or []
      @system.group
        metadata: header: "Group #{group.name}"
        sudo: true
      , group
    @system.user config.user,
      name: process.env.USER
      sudo: true
    @execute
      metadata: header: "Journalctl access"
      command: """
      id `whoami` | grep \\(systemd-journal\\) && exit 3
      gpasswd -a `whoami` systemd-journal
      """
      code_skipped: 3
      sudo: true
    @file.types.locale_gen
      metadata: header: 'Locale gen'
      locales: config.locales
      locale: config.locale
      generate: true
      sudo : true
    @file
      metadata: header: 'Locale conf'
      target: '/etc/locale.conf'
      content: "LANG=#{config.locale}"
      sudo: true
    @service
      metadata: header: 'SSH'
      name: 'openssh'
      srv_name: 'sshd'
      startup: true
      sudo: true
    @service.install
      name: 'rsync'
      sudo: true
    @file
      target: "/lib/udev/rules.d/39-usbmuxd.rules"
      content: """
      # systemd should receive all events relating to device
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ENV{PRODUCT}=="5ac/12[9a][0-9a-f]/*", TAG+="systemd"
      # Initialize iOS devices into "deactivated" USB configuration state and activate usbmuxd
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ENV{PRODUCT}=="5ac/12[9a][0-9a-f]/*", ACTION=="add", ENV{USBMUX_SUPPORTED}="1", ATTR{bConfigurationValue}="0", OWNER="usbmux", ENV{SYSTEMD_WANTS}="usbmuxd.service"
      # Exit usbmuxd when the last device is removed
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ENV{PRODUCT}=="5ac/12[9a][0-9a-f]/*", ACTION=="remove", RUN+="/usr/bin/usbmuxd -x"
      """
      sudo: true
      uid: 'root'
      gid: 'root'
      mode: 0o0551
    @tools.sysctl
      metadata: header: 'Sysctl'
      target: '/etc/sysctl.d/99-sysctl.conf'
      properties:
        # Fix bug with node.js exiting with "ENOSPC" error
        'fs.inotify.max_user_watches': '524288'
      sudo: true
    # Fix bug with node.js exiting with "EMFILE" error
    # No working for unkown reasons, temp solution: `ulimit -n 4096`
    @system.limits
      metadata: header: 'File descriptors'
      system: true
      nofile: 64000
      sudo: true
  @call metadata: header: 'File System', ->
    @service
      metadata: header: 'NTFS'
      name: 'ntfs-3g'
      sudo: true
  @service.install
    # Note, yay requires git soon after
    name: 'git'
    sudo: true
  @execute
    metadata: header: 'YAY'
    cwd: '/tmp'
    command: """
    [ -f /usr/bin/yay ] && exit 42
    [ -d /tmp/yay_build_git ] && rm -rf /tmp/yay_build_git
    git clone https://aur.archlinux.org/yay.git /tmp/yay_build_git
    cd /tmp/yay_build_git
    makepkg --noconfirm -s
    for file in `cd pkg/yay/usr && find -type f`; do
      sudo cp -p pkg/yay/usr/$file /usr/$file;
    done
    cd ..
    rm -rf /tmp/yay_build_git
    """
    code_skipped: 42
    # Virtio modules are not loaded, can't find a solution for now
    # @execute
    #   command: "lsmod | grep virtio"
  @call metadata: header: 'Environnment', ->
    @service.install
      metadata: header: 'zsh'
      name: 'zsh'
      sudo: true
    @service.install
      metadata: header: 'oh-my-zsh Install'
      name: 'oh-my-zsh-git'
    @system.copy
      metadata: header: 'oh-my-zsh Init'
      unless_exists: true
      source: "/usr/share/oh-my-zsh/zshrc"
      target: "#{home}/.zshrc"
    @file
      metadata: header: 'Bash Profile'
      if_exists: true
      target: "#{home}/.bashrc"
      match: /^\. ~\/.profile$/m
      replace: '. ~/.profile'
      append: true
      backup: true
      eof: true
    @file
      metadata: header: 'ZSH Profile'
      if_exists: true
      target: "#{home}/.zshrc"
      match: /^source ~\/.profile$/m
      replace: 'source ~/.profile'
      append: true
      backup: true
      eof: true
    @file
      metadata: header: "Profile CWD"
      target: "#{home}/.profile"
      from: '#START TERM CWD'
      to: '#END TERM CWD'
      replace: """
      # make new terminals start in the working directory of the current terminal?
      # https://wiki.gnome.org/Apps/Terminal/FAQ#How_can_I_make_new_terminals_start_in_the_working_directory_of_the_current_terminal.3F
      . /etc/profile.d/vte.sh
      """
      append: true
      eof: true
      backup: true
    @file
      metadata: header: "Profile Alias"
      if: !!config.aliases
      replace: Object.keys(config.aliases).map((k) -> "alias #{k}='#{config.aliases[k]}'").join '\n'
      target: "#{home}/.profile"
      from: '#START ALIAS'
      to: '#END ALIAS'
      append: true
      eof: true
      backup: true
    @call metadata: header: 'Java', ->
      # Oracle JDK is no longer valid. I didn't have to investigate but
      # probably due to the licence agreement. Disabling for now.
      @service.install
        metadata: header: 'Oracle JDK 7'
        disabled: true
        name: 'jdk7'
      @service.install
        metadata: header: 'Oracle JDK 8'
        disabled: true
        name: 'jdk8'
      @service.install
        metadata: header: 'Oracle JDK 9'
        disabled: true
        name: 'jdk9'
      @execute
        metadata: header: 'Java Default'
        if: -> @status -1
        command: 'archlinux-java set java-9-jdk'
        sudo: true
    # There is a bug in file init where `color: ui: "true"` is written without a value:
    # ```
    # [color]
    # ui
    # ```
    # @file.ini
    #   target: "#{home}/.gitconfig"
    #   merge: true
    #   content: color: ui: 'true'
    @file.ini
      target: "#{home}/.gitconfig"
      merge: true
      content: alias: lgb: "log --graph --abbrev-commit --oneline --date=relative --branches --pretty=format:'%C(bold green)%h %d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"
  @call metadata: header: 'System Utilities', ->
    @service
      name: 'wine'
      sudo: true
    @service.install
      name: 'dosfstools'
      sudo: true
    # Brother brother-mfc-l2720dw
    @service
      metadata: header: 'Printer',
      name: 'cups'
      srv_name: 'org.cups.cupsd.service'
      chk_name: 'org.cups.cupsd.service'
      startup: true
      action: 'start'
      sudo: true
    @call metadata: header: 'bluetooth', ->
      @service.install
        name: 'bluez'
      @service.install
        name: 'bluez-utils'
      @service.start
        name: 'bluetooth'
        sudo: true
      @service.startup
        name: 'bluetooth'
        sudo: true
    @service
      name: 'ntp'
      srv_name: 'ntpd'
      startup: true
      sudo: true

## Dependencies

path = require 'path'
season = require 'season'
# {merge} = require '@nikitajs/core/lib/misc'

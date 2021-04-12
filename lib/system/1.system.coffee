
###

* `locale` (string)
  System locale, default to the first locale in "locales" options.
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

module.exports =
  metadata: header: 'System'
  handler: ({config, ssh}) ->
    throw Error "Required option: locales" unless config.locales
    home = if ssh then "/home/#{ssh.config.username}" else os.homedir()
    config.locale ?= config.locales[0]
    await @call
      $header: 'Maintenance'
      $if: config.upgrade
    , ->
      await @execute
        $header: 'Upgrade'
        command: """
        pacman --noconfirm -Syyu
        """
      await @execute
        $header: 'Cleanup Orphan'
        command: """
        pacman --noconfirm -Rns $(pacman -Qtdq)
        """
    await @call $header: 'System Configuration', ->
      for group in config.groups or []
        await @system.group
          $header: "Group #{group.name}"
          $sudo: true
        , group
      await @system.user config.user,
        $sudo: true
        name: process.env.USER
      await @execute
        $header: "Journalctl access"
        $sudo: true
        command: """
        id `whoami` | grep \\(systemd-journal\\) && exit 3
        gpasswd -a `whoami` systemd-journal
        """
        code_skipped: 3
      await @file.types.locale_gen
        $sudo : true
        $header: 'Locale gen'
        locales: config.locales
        locale: config.locale
        generate: true
      await @file
        $header: 'Locale conf'
        $sudo: true
        target: '/etc/locale.conf'
        content: "LANG=#{config.locale}"
      await @service
        $header: 'SSH'
        $sudo: true
        name: 'openssh'
        srv_name: 'sshd'
        startup: true
      await @service.install
        $sudo: true
        name: 'rsync'
      await @file
        $sudo: true
        target: "/lib/udev/rules.d/39-usbmuxd.rules"
        content: """
        # systemd should receive all events relating to device
        SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ENV{PRODUCT}=="5ac/12[9a][0-9a-f]/*", TAG+="systemd"
        # Initialize iOS devices into "deactivated" USB configuration state and activate usbmuxd
        SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ENV{PRODUCT}=="5ac/12[9a][0-9a-f]/*", ACTION=="add", ENV{USBMUX_SUPPORTED}="1", ATTR{bConfigurationValue}="0", OWNER="usbmux", ENV{SYSTEMD_WANTS}="usbmuxd.service"
        # Exit usbmuxd when the last device is removed
        SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ENV{PRODUCT}=="5ac/12[9a][0-9a-f]/*", ACTION=="remove", RUN+="/usr/bin/usbmuxd -x"
        """
        uid: 'root'
        gid: 'root'
        mode: 0o0551
      await @tools.sysctl
        $header: 'Sysctl'
        $sudo: true
        target: '/etc/sysctl.d/99-sysctl.conf'
        properties:
          # Fix bug with node.js exiting with "ENOSPC" error
          'fs.inotify.max_user_watches': '524288'
      # Fix bug with node.js exiting with "EMFILE" error
      # No working for unkown reasons, temp solution: `ulimit -n 4096`
      await @system.limits
        $header: 'File descriptors'
        $sudo: true
        system: true
        nofile: 64000
    await @call $header: 'File System', ->
      await @service
        $header: 'NTFS'
        $sudo: true
        name: 'ntfs-3g'
    await @service.install
      $sudo: true
      # Note, yay requires git soon after
      name: 'git'
    await @execute
      $header: 'YAY'
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
    await @call $header: 'Environnment', ->
      await @service.install
        $header: 'zsh'
        $sudo: true
        name: 'zsh'
      await @service.install
        $header: 'oh-my-zsh Install'
        name: 'oh-my-zsh-git'
      await @fs.copy
        $header: 'oh-my-zsh Init'
        $unless_exists: true
        source: "/usr/share/oh-my-zsh/zshrc"
        target: "#{home}/.zshrc"
      await @file
        $header: 'Bash Profile'
        $if_exists: true
        target: "#{home}/.bashrc"
        match: /^\. ~\/.profile$/m
        replace: '. ~/.profile'
        append: true
        backup: true
        eof: true
      await @file
        $header: 'ZSH Profile'
        $if_exists: true
        target: "#{home}/.zshrc"
        match: /^source ~\/.profile$/m
        replace: 'source ~/.profile'
        append: true
        backup: true
        eof: true
      await @file
        $header: "Profile CWD"
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
      await @file
        $header: "Profile Alias"
        $if: !!config.aliases
        replace: Object.keys(config.aliases).map((k) -> "alias #{k}='#{config.aliases[k]}'").join '\n'
        target: "#{home}/.profile"
        from: '#START ALIAS'
        to: '#END ALIAS'
        append: true
        eof: true
        backup: true
      await @call $header: 'Java', ->
        # Oracle JDK is no longer valid. I didn't have to investigate but
        # probably due to the licence agreement. Disabling for now.
        await @service.install
          $header: 'Oracle JDK 7'
          disabled: true
          name: 'jdk7'
        await @service.install
          $header: 'Oracle JDK 8'
          disabled: true
          name: 'jdk8'
        {$status} = await @service.install
          $header: 'Oracle JDK 9'
          disabled: true
          name: 'jdk9'
        await @execute
          $header: 'Java Default'
          $if: $status
          command: 'archlinux-java set java-9-jdk'
          $sudo: true
      # There is a bug in file init where `color: ui: "true"` is written without a value:
      # ```
      # [color]
      # ui
      # ```
      # await @file.ini
      #   target: "#{home}/.gitconfig"
      #   merge: true
      #   content: color: ui: 'true'
      await @file.ini
        target: "#{home}/.gitconfig"
        merge: true
        content: alias: lgb: "log --graph --abbrev-commit --oneline --date=relative --branches --pretty=format:'%C(bold green)%h %d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"
    await @call $header: 'System Utilities', ->
      await @service
        name: 'wine'
        $sudo: true
      await @service.install
        name: 'dosfstools'
        $sudo: true
      # Brother brother-mfc-l2720dw
      await @service
        $header: 'Printer'
        $sudo: true
        name: 'cups'
        startup: true
        action: 'start'
      await @call $header: 'bluetooth', ->
        await @service.install
          name: 'bluez'
        await @service.install
          name: 'bluez-utils'
        await @service.start
          name: 'bluetooth'
          $sudo: true
        await @service.startup
          name: 'bluetooth'
          $sudo: true
      await @service
        name: 'ntp'
        srv_name: 'ntpd'
        startup: true
        $sudo: true

## Dependencies

os = require 'os'
{merge} = require 'mixme'

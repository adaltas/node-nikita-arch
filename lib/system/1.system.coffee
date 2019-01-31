
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

module.exports = ({options}) ->
  throw Error "Required option: locales" unless options.locales
  options.locale ?= options.locales[0]
  @call
    header: 'System'
    if: options.upgrade
  , ->
    @system.execute
      header: 'Upgrade'
      cmd: """
      pacman --noconfirm -Syyu
      """
    @system.execute
      header: 'Cleanup Orphan'
      cmd: """
      pacman --noconfirm -Rns $(pacman -Qtdq)
      """
  @call header: 'System', ->
    @system.group group for group in options.groups or []
    @system.user options.user,
      name: process.env.USER
      sudo: true
    @system.execute
      header: "Journalctl access"
      cmd: """
      id `whoami` | grep \\(systemd-journal\\) && exit 3
      gpasswd -a `whoami` systemd-journal
      """
      code_skipped: 3
      sudo: true
    @file.types.locale_gen
      header: 'Locale gen'
      locales: options.locales
      locale: options.locale
      generate: true
    @file
      header: 'Locale conf'
      target: '/etc/locale.conf'
      content: "LANG=#{options.locale}"
    @service
      header: 'SSH'
      name: 'openssh'
      srv_name: 'sshd'
    @service
      name: 'wine'
    @service.install 'rsync'
    @service.install 'dosfstools'
    # Brother brother-mfc-l2720dw
    @service
      header: 'Printer',
      name: 'cups'
      srv_name: 'org.cups.cupsd.service'
      chk_name: 'org.cups.cupsd.service'
      startup: true
      action: 'start'
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
      header: 'Sysctl'
      target: '/etc/sysctl.d/99-sysctl.conf'
      properties:
        # Fix bug with node.js exiting with "ENOSPC" error
        'fs.inotify.max_user_watches': '524288'
      sudo: true
    # Fix bug with node.js exiting with "EMFILE" error
    # No working for unkown reasons, temp solution: `ulimit -n 4096`
    @system.limits
      header: 'File descriptors'
      system: true
      nofile: 64000
      sudo: true
  @call header: 'File System', ->
    @service
      header: 'NTFS',
      name: 'ntfs-3g'
  @call header: 'system', ->
    @call header: 'bluetooth', ->
      @service.install
        name: 'bluez'
      @service.install
        name: 'bluez-utils'
      @service.start
        name: 'bluetooth'
      @service.startup
        name: 'bluetooth'
  @call header: 'Virtualization', ->
    # ebtables dnsmasq firewalld vde2
    @service.install
      header: 'qemu'
      name: ' qemu'
    @service.install
      header: 'libvirt'
      name: 'libvirt'
      started: true
      action: 'start'
    @service.install
      header: 'libvirt manager'
      name: ' virt-manager'
    # Virtio modules are not loaded, can't find a solution for now
    # @system.execute
    #   cmd: "lsmod | grep virtio"
  @call header: 'Environnment', ->
    @service.install
      header: 'oh-my-zsh Install'
      name: 'oh-my-zsh-git'
    @system.copy
      header: 'oh-my-zsh Init'
      unless_exists: true
      source: "/usr/share/oh-my-zsh/zshrc"
      target: "~/.zshrc"
    @file
      header: 'Bash Profile'
      if_exists: true
      target: "~/.bashrc"
      match: /^\. ~\/.profile$/m
      replace: '. ~/.profile'
      append: true
      backup: true
      eof: true
    @file
      header: 'ZSH Profile'
      if_exists: true
      target: "~/.zshrc"
      match: /^source ~\/.profile$/m
      replace: 'source ~/.profile'
      append: true
      backup: true
      eof: true
    @file
      header: "Profile CWD"
      target: "~/.profile"
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
      header: "Profile Alias"
      if: !!options.aliases
      replace: Object.keys(options.aliases).map((k) -> "alias #{k}='#{options.aliases[k]}'").join '\n'
      target: "~/.profile"
      from: '#START ALIAS'
      to: '#END ALIAS'
      append: true
      eof: true
      backup: true
    @service.install
     header: 'Oracle JDK 7'
     name: 'jdk7'
    @service.install
     header: 'Oracle JDK 8'
     name: 'jdk8'
    @service.install
     header: 'Oracle JDK 9'
     name: 'jdk9'
    @system.execute
     header: 'Java Default'
     if: -> @status -1
     cmd: 'archlinux-java set java-9-jdk'
     sudo: true
    @file.yaml
      target: '~/.gitconfig'
      merge: true
      content: color: ui: 'true'
    @file.yaml
      target: '~/.gitconfig'
      merge: true
      content: alias: lgb: "log --graph --abbrev-commit --oneline --date=relative --branches --pretty=format:'%C(bold green)%h %d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"
  @call header: 'Gnome', ->
    @service.install 'gnome-session-properties'
    @service.install 'dconf-editor'
    @service.install 'arc-gtk-theme'
    @system.dconf
      header: 'Gnome Session Save'
      properties: '/org/gnome/gnome-session/auto-save-session': 'false'
    @system.dconf
      header: 'Gnome Session LANG'
      properties: '/org/gnome/desktop/input-sources/sources': '[(\'xkb\', \'us\'), (\'xkb\', \'fr\')]'
    @system.dconf
      header: 'Gnome Session Invert Alt/CTL'
      properties: '/org/gnome/desktop/input-sources/xkb-options': '[\'ctrl:swap_lalt_lctl\']'
    @system.dconf
      header: 'Gnome Session TouchPad'
      properties: '/org/gnome/desktop/peripherals/touchpad/click-method': '\'fingers\''
    @system.dconf
      header: 'Gnome Terminal Menu'
      properties: '/org/gnome/terminal/legacy/default-show-menubar': 'false'
    @system.dconf
      header: 'Gnome Terminal KeyBinding'
      properties:
        '/org/gnome/terminal/legacy/keybindings/close-tab': '\'<Primary>w\''
        '/org/gnome/terminal/legacy/keybindings/close-window': '\'<Primary>q\''
        '/org/gnome/terminal/legacy/keybindings/copy': '\'<Primary>c\''
        '/org/gnome/terminal/legacy/keybindings/new-tab': '\'<Primary>t\''
        '/org/gnome/terminal/legacy/keybindings/new-window': '\'<Primary>n\''
        '/org/gnome/terminal/legacy/keybindings/next-tab': '\'<Primary><Shift>Right\''
        '/org/gnome/terminal/legacy/keybindings/paste': '\'<Primary>v\''
        '/org/gnome/terminal/legacy/keybindings/prev-tab': '\'<Primary><Shift>Left\''
        '/org/gnome/terminal/legacy/keybindings/reset-and-clear': '\'<Primary>k\''
    # Note, could not find the property for "> settings > Date & Time > Automatic Date & Time"
    @system.dconf
      header: 'Automatic update timezone'
      properties: '/org/gnome/desktop/datetime/automatic-timezone': '\'true\''
    @service.install 'networkmanager-openvpn'
    @service.install 'chrome-gnome-shell-git'
    @service.install 'gnome-shell-extension-battery-percentage-git'
    @service.install 'gnome-shell-extension-simple-net-speed-git'
    # @service.install 'gnome-shell-extension-refresh-wifi-git'
    @service.install 'gnome-system-monitor'
  @call header: 'Nodejs', ->
    @system.execute
      cmd: """
      [[ `npm config get prefix` == "/usr/local" ]] && exit 3
      chown -R `whoami`. /usr/local
      npm config set prefix /usr/local
      """
      code_skipped: 3
    @system.npm
      header: 'Global Packages'
      name: ['n', 'coffee-script', 'mocha']
      global: true
      sudo: true
    @file
      header: "N"
      target: "~/.profile"
      from: '#START N'
      to: '#END N'
      replace: """
      n 10.0.0
      """
      append: true
      eof: true
      backup: true
  @call header: 'Atom', ->
    @service.install
      header: 'Package'
      name: 'atom'
    @system.apm
      header: 'APM Packages'
      name: [
        'stylus', 'sublime-style-column-selection', 'atom-monokai-dark',
        'atom-typescript', 'chester-atom-syntax', 'color-picker', 'git-plus',
        'git-time-machine', 'highlight-selected', 'indent-guide-improved',
        'language-coffee-script', 'language-docker', 'language-jade',
        'language-jade', 'language-log', 'language-scala', 'linter', 'markdown-toc',
        'material-syntax', 'minimap', 'minimap-find-and-replace', 'minimap-highlight-selected',
        'minimap-selection', 'monokai', 'pretty-json', 'project-manager', 'react',
        'tail', 'teletype']
      upgrade: true
    @file.cson
      header: 'Configuration'
      target: "~/.atom/config.cson"
      content: options.atom_config
      merge: true
    @file.cson
      header: 'Keymap'
      target: "~/.atom/keymap.cson"
      content:
        'atom-workspace':
          "alt-f7": "find-and-replace:select-all"
          "ctrl-f7": "find-and-replace:find-next-selected"
          "ctrl-shift-f7": "find-and-replace:find-previous-selected"
          "shift-f7": "find-and-replace:find-previous"
          "f7": "find-and-replace:find-next"
          "ctrl-g": "find-and-replace:find-next"
          "ctrl-shift-G": "find-and-replace:find-previous"
      merge: true
  @call header: 'Programming', ->
    @service.install
      header: 'Dart'
      name: 'dart'
    @service.install
      header: 'GIT Crypt'
      name: 'git-crypt'
    @call
      header: 'SublimeText'
    , ->
      @system.execute
        header: 'GPG keys'
        sudo: true
        cmd: """
        curl -O https://download.sublimetext.com/sublimehq-pub.gpg
        pacman-key --add sublimehq-pub.gpg
        pacman-key --lsign-key 8A8F901A
        rm sublimehq-pub.gpg
        """
        trap: true
        shy: true # todo: add status discovery
      @file.types.pacman_conf
        header: 'Stable channel'
        sudo: true
        # target: '/etc/pacman.conf'
        content: 'sublime-text': 'Server': 'https://download.sublimetext.com/arch/stable/x86_64'
        merge: true
        backup: true
      # @system.execute
      #   if: -> @status -1
      #   cmd: 'pacman -Syu sublime-text'
      #   sudo: true
      @service.install
        header: 'Package'
        name: 'sublime-text'
        pacman_flags: ['u', 'y']
    # @system.execute
    #   header: 'K8S kubectl'
    #   cmd: """
    #   version=`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`
    #   if [ -f /usr/local/bin/kubectl ]; then
    #     current_version=`kubectl version --client -o=json | grep gitVersion | sed 's/.*"\\(.*\\)".*/\\1/'`
    #     [[ $version == $current_version ]] && exit 3
    #   fi
    #   curl -L https://storage.googleapis.com/kubernetes-release/release/${version}/bin/linux/amd64/kubectl -o /tmp/kubectl
    #   chmod +x /tmp/kubectl
    #   sudo mv ./kubectl /usr/local/bin/kubectl
    #   kubectl cluster-info
    #   kubectl completion -h
    #   """
    #   code_skipped: 3
    # @file
    #   target: '~/.zshrc'
    #   from: '#START KUBECTL'
    #   to: '#END KUBECTL'
    #   replace: """
    #   if [ $commands[kubectl] ]; then
    #     source <(kubectl completion zsh)
    #   fi
    #   """
    # @system.execute
    #   cmd: """
    #   version=`curl -s https://raw.githubusercontent.com/kubernetes/minikube/master/Makefile | grep '^ISO_VERSION ' | sed 's/.* \\(.*\\)/\\1/'`
    #   if [ -f /usr/local/bin/minikube ]; then
    #     current_version=`minikube version | sed 's/.* \\(.*\\)/\\1/'`
    #     [[ $version == $current_version ]] && exit 3
    #   fi
    #   curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.23.0/minikube-linux-amd64
    #   chmod +x minikube
    #   sudo mv minikube /usr/local/bin/
    #   """
    #   trap: true
    #   code_skipped: 3
    @call header: 'K8S Helm', ->
      @service.install
        name: 'kubernetes-helm'
      @system.execute
        if: -> @status -1
        cmd: 'helm init'
      @system.execute
        cmd: 'helm repo update'
  @call header: 'Productivity', ->
    # @service.install
    #   header: 'Package gitkraken'
    #   name: 'gitkraken'
    @service.install
      header: 'Package chromium'
      name: 'chromium'
    @service.install
      header: 'Package opera'
      name: 'opera'
    # @service.install
    #   header: 'Package pantheon-files-plugin-dropbox-bzr'
    #   name: 'pantheon-files-plugin-dropbox-bzr'
    # @system.gsettings
    #   header: 'Pantheon Single Click',
    #   properties:
    #     'org.pantheon.files.preferences': 'single-click': 'false'
    @service.install
      header: 'Package Skype'
      name: 'skypeforlinux-bin'
    @service.install
      header: 'Package libreoffice-fresh'
      name: 'libreoffice-fresh'
    @service.install
      header: 'Package libreoffice-fresh-fr'
      name: 'libreoffice-fresh-fr'
    @service.install
      header: 'Package typora'
      name: 'typora'
    @service.install
      header: 'SFTP client gftp'
      name: 'gftp'
    @service.install
      header: 'SFTP client filezilla'
      name: 'filezilla'
    @service.install
      header: 'Package sqlectron-gui'
      name: 'sqlectron-gui'
    @service.install
      header: 'Package Apache Directory Studio'
      name: 'apachedirectorystudio'
    @service.install
      header: 'tcpdump'
      name: 'tcpdump'
    @service.install
      header: 'Gravit'
      name: 'gravit-designer-bin'
  @call header: 'Font', ->
    @service.install
      header: 'Liberation'
      name: 'ttf-liberation'
    @service.install
      header: 'Dejavu'
      name: 'ttf-dejavu'
    @service.install
      header: 'Roboto'
      name: 'ttf-roboto'
    @service.install
      header: 'Noto'
      name: 'noto-fonts'
    @service.install
      header: 'ttf-ms-fonts (Arial, Courier New, Georgia, Verdana, ...)'
      name: 'ttf-ms-fonts'
  @call header: 'Office', ->
    @service.install
      header: 'Master PDF Editor'
      name: 'masterpdfeditor'
    @service.install
      header: 'Package firefox'
      name: 'firefox'
    @service.install
      header: 'Package thunderbird'
      name: 'thunderbird'
    @service.install
      header: 'Package mailspring'
      name: 'mailspring'
  @call header: 'Docker', ->
    @service
      header: 'Package docker'
      name: 'docker'
      action: 'start'
      startup: true
    @service.install
      header: 'Package docker-compose'
      name: 'docker-compose'
    # Installation is based on  the official documentation
    # [Deploying a registry server](https://docs.docker.com/registry/deploying/)
    # @system.execute
    #   cmd: """
    #   docker run -d -p 5000:5000 --restart=always --name registry \
    #     -v `pwd`/data:/var/lib/registry \
    #     registry:2
    #   """
    #   code_skipped: 3
    # @system.execute (
    #   header: "Push #{image}"
    #   cmd: """
    #   # Get any image from the hub and tag it to point to your registry
    #   docker pull #{image}
    #   docker tag #{image} localhost:5000/#{image}
    #   # then push it to your registry
    #   docker push localhost:5000/ubuntu
    #   """
    # ) for image in ['centos']
  @call header: 'VirtualBox', ->
    @service.install 'linux-headers'
    @service.install 'virtualbox'
    @service.install 'virtualbox-guest-iso'
    # Note, virtualbox-host-dkms doesnt work for david but is ok for younes
    @service.install 'virtualbox-host-modules-arch'
    @system.mod 'vboxnetadp'
    @system.mod 'vboxnetflt'
    @system.mod 'vboxpci'
  @service
    header: 'Vagrant'
    name: 'vagrant'


## Dependencies

path = require 'path'
season = require 'season'
{merge} = require '@nikitajs/core/lib/misc'

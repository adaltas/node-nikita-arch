
###

* `locale` (string)
  System locale, default to the first locale in "locales" options.
* `locales` (string)
  List of supported locales, required.

###

module.exports = ({options}) ->
  ssh = @ssh options.ssh
  home = if ssh then "/home/#{ssh.config.username}" else '~'
  @call
    header: 'Gnome'
    if: options.gnome
  , ->
    @service.install 'gnome-session-properties'
    @service.install 'dconf-editor'
    @service.install 'arc-gtk-theme'
    @tools.dconf
      header: 'Gnome Session Save'
      properties: '/org/gnome/desktop/datetime/automatic-timezone': 'true'
    @tools.dconf
      header: 'Gnome Session Save'
      properties: '/org/gnome/gnome-session/auto-save-session': 'false'
    @tools.dconf
      header: 'Gnome Session LANG'
      properties: '/org/gnome/desktop/input-sources/sources': '[(\'xkb\', \'us\'), (\'xkb\', \'fr\')]'
    @tools.dconf
      header: 'Gnome Session Invert Alt/CTL'
      properties: '/org/gnome/desktop/input-sources/xkb-options': '[\'ctrl:swap_lalt_lctl\']'
    @tools.dconf
      header: 'Gnome Session TouchPad'
      properties: '/org/gnome/desktop/peripherals/touchpad/click-method': '\'fingers\''
    @tools.dconf
      header: 'Gnome Terminal Menu'
      properties: '/org/gnome/terminal/legacy/default-show-menubar': 'false'
    @tools.dconf
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
    @tools.dconf
      header: 'Automatic update timezone'
      properties: '/org/gnome/desktop/datetime/automatic-timezone': '\'true\''
    @service.install 'networkmanager-openvpn'
    @service.install 'chrome-gnome-shell-git'
    # @service.install 'gnome-shell-extension-battery-percentage-git'
    @service.install 'gnome-shell-extension-simple-net-speed-git'
    @service.install 'gnome-shell-extension-refresh-wifi-git'
    @service.install 'gnome-system-monitor'

  @call
    header: 'Virtualization'
    if: options.virtualization
  , ->
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

  @call
    header: 'NPM Global'
    if: options.npm_global
  , ->
    @system.mkdir
      target: "#{home}/.npm-global"
    @system.execute
      cmd: """
      [[ `npm config get prefix` == "~/.npm-global" ]] && exit 42
      npm config set prefix ~/.npm-global
      """
      code_skipped: 42
    @file
      replace: """
      export PATH=~/.npm-global/bin:$PATH
      """
      target: "#{home}/.profile"
      from: '#START NPM GLOBAL'
      to: '#END NPM GLOBAL'
      append: true
      eof: true
      backup: true

  @call
    header: 'Nodejs'
    if: options.nodejs
  , ->
    @service.install
      header: 'Package nodejs'
      name: 'nodejs'
    @service.install
      header: 'Package npm'
      name: 'npm'
    @system.npm
      header: 'Global Packages'
      name: ['n', 'coffee-script', 'mocha']
      global: true
      sudo: true
    @file
      header: "N"
      target: "#{home}/.profile"
      from: '#START N'
      to: '#END N'
      replace: """
      export N_PREFIX=~/.n
      n 10.0.0
      """
      append: true
      eof: true
      backup: true

  @call
    header: 'Atom'
    if: options.atom
  , ->
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
        'tail', 'teletype', 'linter-coffeelint']
      upgrade: true
    @file.cson
      header: 'Configuration'
      target: "#{home}/.atom/config.cson"
      content: options.atom_config
      merge: true
    @file.cson
      header: 'Keymap'
      target: "#{home}/.atom/keymap.cson"
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

  @call
    header: 'Programming'
    if: options.programming
  , ->
    @service.install
      header: 'Neovim'
      name: 'python-neovim'
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
      @system.execute
        if: -> @status -1
        cmd: 'pacman --noconfirm -Syu sublime-text'
        sudo: true
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
    #   target: "#{home}/.zshrc"
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
    # @call header: 'K8S Helm', ->
    #   @service.install
    #     name: 'kubernetes-helm'
    #   @system.execute
    #     if: -> @status -1
    #     cmd: 'helm init'
    #   @system.execute
    #     cmd: 'helm repo update'

  @call
    header: 'Docker'
    if: options.docker
  , ->
    @service
      header: 'Package docker'
      name: 'docker'
      action: 'start'
      startup: true
      sudo: true
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
  # Module vboxpci used to work but I can't activate it as of feb 2020,
  # command `modprob vboxpci` fail with message "Module vboxpci not found in
  # directory /lib/modules/`uname -r`"
  # command `modprob vboxdrv vboxpci` work but with `lsmod` doesn't print the module.
  @call
    header: 'VirtualBox'
    if: options.virtualbox
  , ->
    @service.install 'linux-headers'
    @service.install 'virtualbox'
    # for linux kernel choose virtualbox-host-modules-arch
    @service.install 'virtualbox-host-modules-arch'
    # for other kernels choose virtualbox-host-dkms
    # @service.install 'virtualbox-host-dkms'
    @service.install 'virtualbox-guest-modules-arch'
    @service.install 'virtualbox-guest-utils'
    @system.mod 'vboxdrv'    # Mandatory
    @system.mod 'vboxnetadp' # Optional, needed to create the host interface in the VirtualBox global preferences
    @system.mod 'vboxnetflt' # Optional, needed to launch a virtual machine using that network interface
    @system.mod 'vboxpci', disabled: true # Optional, needed when your virtual machine needs to pass through a PCI device on your host.
  @service
    header: 'Vagrant'
    name: 'vagrant'


###

* `locale` (string)
  System locale, default to the first locale in "locales" config.
* `locales` (string)
  List of supported locales, required.

###

module.exports = ({config}) ->
  ssh = @ssh config.ssh
  home = if ssh then "/home/#{ssh.config.username}" else '~'
  @call
    metadata: header: 'Gnome'
    if: config.gnome
  , ->
    @service.install 'gnome-session-properties'
    @service.install 'dconf-editor'
    @service.install 'arc-gtk-theme'
    @tools.dconf
      metadata: header: 'Gnome Session Save'
      properties: '/org/gnome/desktop/datetime/automatic-timezone': 'true'
    @tools.dconf
      metadata: header: 'Gnome Session Save'
      properties: '/org/gnome/gnome-session/auto-save-session': 'false'
    @tools.dconf
      metadata: header: 'Gnome Session LANG'
      properties: '/org/gnome/desktop/input-sources/sources': '[(\'xkb\', \'us\'), (\'xkb\', \'fr\')]'
    @tools.dconf
      metadata: header: 'Gnome Session Invert Alt/CTL'
      properties: '/org/gnome/desktop/input-sources/xkb-config': '[\'ctrl:swap_lalt_lctl\']'
    @tools.dconf
      metadata: header: 'Gnome Session TouchPad'
      properties: '/org/gnome/desktop/peripherals/touchpad/click-method': '\'fingers\''
    @tools.dconf
      metadata: header: 'Gnome Terminal Menu'
      properties: '/org/gnome/terminal/legacy/default-show-menubar': 'false'
    @tools.dconf
      metadata: header: 'Gnome Terminal KeyBinding'
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
      metadata: header: 'Automatic update timezone'
      properties: '/org/gnome/desktop/datetime/automatic-timezone': '\'true\''
    @service.install 'networkmanager-openvpn'
    @service.install 'chrome-gnome-shell-git'
    # @service.install 'gnome-shell-extension-battery-percentage-git'
    @service.install 'gnome-shell-extension-simple-net-speed-git'
    @service.install 'gnome-shell-extension-refresh-wifi-git'
    @service.install 'gnome-system-monitor'
  @call
    metadata: header: 'Virtualization'
    if: config.virtualization
  , ->
    # ebtables dnsmasq firewalld vde2
    @service.install
      metadata: header: 'qemu'
      name: ' qemu'
    @service.install
      metadata: header: 'libvirt'
      name: 'libvirt'
      started: true
      action: 'start'
    @service.install
      metadata: header: 'libvirt manager'
      name: ' virt-manager'
  @call
    metadata: header: 'NPM Global'
    if: config.npm_global
  , ->
    @system.mkdir
      target: "#{home}/.npm-global"
    @execute
      command: """
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
    metadata: header: 'Nodejs'
    if: config.nodejs
  , ->
    @service.install
      metadata: header: 'Package nodejs'
      name: 'nodejs'
    @service.install
      metadata: header: 'Package npm'
      name: 'npm'
    @tools.npm
      metadata: header: 'Global Packages'
      name: ['n', 'coffeescript', 'mocha']
      global: true
      sudo: true
    @file
      metadata: header: "N"
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
    metadata: header: 'Atom'
    if: config.atom
  , ->
    @service.install
      metadata: header: 'Package'
      name: 'atom'
    @tools.apm
      metadata: header: 'APM Packages'
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
      metadata: header: 'Configuration'
      target: "#{home}/.atom/config.cson"
      content: config.atom_config
      merge: true
    @file.cson
      metadata: header: 'Keymap'
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
    metadata: header: 'Programming'
    if: config.programming
  , ->
    @service.install
      metadata: header: 'Neovim'
      name: 'python-neovim'
    @service.install
      metadata: header: 'Dart'
      name: 'dart'
    @service.install
      metadata: header: 'GIT Crypt'
      name: 'git-crypt'
    @call
      metadata: header: 'SublimeText'
    , ->
      @execute
        metadata: header: 'GPG keys'
        sudo: true
        command: """
        curl -O https://download.sublimetext.com/sublimehq-pub.gpg
        pacman-key --add sublimehq-pub.gpg
        pacman-key --lsign-key 8A8F901A
        rm sublimehq-pub.gpg
        """
        trap: true
        shy: true # todo: add status discovery
      @file.types.pacman_conf
        metadata: header: 'Stable channel'
        sudo: true
        # target: '/etc/pacman.conf'
        content: 'sublime-text': 'Server': 'https://download.sublimetext.com/arch/stable/x86_64'
        merge: true
        backup: true
      @execute
        if: -> @status -1
        command: 'pacman --noconfirm -Syu sublime-text'
        sudo: true
      @service.install
        metadata: header: 'Package'
        name: 'sublime-text'
        pacman_flags: ['u', 'y']
    # @execute
    #   metadata: header: 'K8S kubectl'
    #   command: """
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
    # @execute
    #   command: """
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
    # @call metadata: header: 'K8S Helm', ->
    #   @service.install
    #     name: 'kubernetes-helm'
    #   @execute
    #     if: -> @status -1
    #     command: 'helm init'
    #   @execute
    #     command: 'helm repo update'
  @call
    metadata: header: 'Docker'
    if: config.docker
  , ->
    @service
      metadata: header: 'Package docker'
      name: 'docker'
      action: 'start'
      startup: true
      # sudo: true
    @service.install
      metadata: header: 'Package docker-compose'
      name: 'docker-compose'
    # Installation is based on  the official documentation
    # [Deploying a registry server](https://docs.docker.com/registry/deploying/)
    # @execute
    #   command: """
    #   docker run -d -p 5000:5000 --restart=always --name registry \
    #     -v `pwd`/data:/var/lib/registry \
    #     registry:2
    #   """
    #   code_skipped: 3
    # @execute (
    #   metadata: header: "Push #{image}"
    #   command: """
    #   # Get any image from the hub and tag it to point to your registry
    #   docker pull #{image}
    #   docker tag #{image} localhost:5000/#{image}
    #   # then push it to your registry
    #   docker push localhost:5000/ubuntu
    #   """
    # ) for image in ['centos']
  @call
    metadata: header: 'VirtualBox'
    if: config.virtualbox
  , ->
    @service.install 'linux-headers'
    # Note 02/2020: The `virtualbox` package ask to choose between;
    # 1. virtualbox-host-dkms                   2. virtualbox-host-modules-arch
    # Since the first option (virtualbox-host-dkms) is selected, it create a
    # conflict if we later try to install the second one (virtualbox-host-modules-arch)
    # The current fix is to install the second option before the `virtualbox`
    # package.
    # for linux kernel choose virtualbox-host-modules-arch
    @service.install 'virtualbox-host-modules-arch'
    # for other kernels choose virtualbox-host-dkms
    # @service.install 'virtualbox-host-dkms'
    @service.install 'virtualbox'
    #@service.install 'virtualbox-guest-modules-arch' module dosen't exist anymore
    @service.install 'virtualbox-guest-utils'
    # Module vboxpci used to work but I can't activate it as of feb 2020,
    # command `modprob vboxpci` fail with message "Module vboxpci not found in
    # directory /lib/modules/`uname -r`"
    # command `modprob vboxdrv vboxpci` work but with `lsmod` doesn't print the module.
    @system.mod 'vboxdrv', sudo: true    # Mandatory
    @system.mod 'vboxnetadp', sudo: true # Optional, needed to create the host interface in the VirtualBox global preferences
    @system.mod 'vboxnetflt', sudo: true # Optional, needed to launch a virtual machine using that network interface
    @system.mod 'vboxpci', sudo: true, disabled: true # Optional, needed when your virtual machine needs to pass through a PCI device on your host.
  @service
    metadata: header: 'Vagrant'
    name: 'vagrant'

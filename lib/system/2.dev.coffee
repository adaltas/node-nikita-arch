
###

* `locale` (string)
  System locale, default to the first locale in "locales" options.
* `locales` (string)
  List of supported locales, required.

###

module.exports =
  metadata: header: 'Development'
  handler: ({config, ssh}) ->
    home = if ssh then "/home/#{ssh.config.username}" else os.homedir()
    await @call
      $header: 'Gnome'
      $if: config.gnome
    , ->
      await @service.install 'gnome-session-properties'
      await @service.install 'dconf-editor'
      await @service.install 'arc-gtk-theme'
      await @tools.dconf
        $header: 'Gnome Session Save'
        properties: '/org/gnome/desktop/datetime/automatic-timezone': 'true'
      await @tools.dconf
        $header: 'Gnome Session Save'
        properties: '/org/gnome/gnome-session/auto-save-session': 'false'
      await @tools.dconf
        $header: 'Gnome Session LANG'
        properties: '/org/gnome/desktop/input-sources/sources': '[(\'xkb\', \'us\'), (\'xkb\', \'fr\')]'
      await @tools.dconf
        $header: 'Gnome Session Invert Alt/CTL'
        properties: '/org/gnome/desktop/input-sources/xkb-options': '[\'ctrl:swap_lalt_lctl\']'
      await @tools.dconf
        $header: 'Gnome Session TouchPad'
        properties: '/org/gnome/desktop/peripherals/touchpad/click-method': '\'fingers\''
      await @tools.dconf
        $header: 'Gnome Terminal Menu'
        properties: '/org/gnome/terminal/legacy/default-show-menubar': 'false'
      await @tools.dconf
        $header: 'Gnome Terminal KeyBinding'
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
      await @tools.dconf
        $header: 'Automatic update timezone'
        properties: '/org/gnome/desktop/datetime/automatic-timezone': '\'true\''
      await @service.install 'networkmanager-openvpn'
      await @service.install 'chrome-gnome-shell-git'
      # await @service.install 'gnome-shell-extension-battery-percentage-git'
      await @service.install 'gnome-shell-extension-simple-net-speed-git'
      await @service.install 'gnome-shell-extension-refresh-wifi-git'
      await @service.install 'gnome-system-monitor'
    await @call
      $header: 'Virtualization'
      $if: config.virtualization
    , ->
      # ebtables dnsmasq firewalld vde2
      await @service.install
        $header: 'qemu'
        name: ' qemu'
      await @service.install
        $header: 'libvirt'
        name: 'libvirt'
        started: true
        action: 'start'
      await @service.install
        $header: 'libvirt manager'
        name: ' virt-manager'
    await @call
      $header: 'NPM Global'
      $if: config.npm_global
    , ->
      await @fs.mkdir
        target: "#{home}/.npm-global"
      await @execute
        command: """
        [[ `npm config get prefix` == "~/.npm-global" ]] && exit 42
        npm config set prefix ~/.npm-global
        """
        code_skipped: 42
      await @file
        replace: """
        export PATH=~/.npm-global/bin:$PATH
        """
        target: "#{home}/.profile"
        from: '#START NPM GLOBAL'
        to: '#END NPM GLOBAL'
        append: true
        eof: true
        backup: true
    await @call
      $header: 'Nodejs'
      $if: config.nodejs
    , ->
      await @service.install
        $header: 'Package nodejs'
        name: 'nodejs'
      await @service.install
        $header: 'Package npm'
        name: 'npm'
      # Note 210312: npm -ig complains that the dir does not exists
      # and exit `254` 
      await @fs.mkdir
        target: "#{home}/.npm-global"
      await @fs.mkdir
        target: "#{home}/.npm-global/bin"
      await @fs.mkdir
        target: "#{home}/.npm-global/lib"
      await @tools.npm
        $header: 'Global Packages'
        $sudo: true
        name: ['n', 'coffeescript', 'mocha']
        global: true
      await @file
        $header: "N"
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
    await @call
      $header: 'Atom'
      $if: config.atom
    , ->
      await @service.install
        $header: 'Package'
        name: 'atom'
      await @tools.apm
        $header: 'APM Packages'
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
      await @file.cson
        $header: 'Configuration'
        target: "#{home}/.atom/config.cson"
        content: config.atom_config
        merge: true
      await @file.cson
        $header: 'Keymap'
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
    await @call
      $header: 'Programming'
      $if: config.programming
    , ->
      await @service.install
        $header: 'Neovim'
        name: 'python-neovim'
      await @service.install
        $header: 'Dart'
        name: 'dart'
      await @service.install
        $header: 'GIT Crypt'
        name: 'git-crypt'
      await @call
        $header: 'SublimeText'
      , ->
        await @execute
          $header: 'GPG keys'
          $sudo: true
          command: """
          curl -O https://download.sublimetext.com/sublimehq-pub.gpg
          pacman-key --add sublimehq-pub.gpg
          pacman-key --lsign-key 8A8F901A
          rm sublimehq-pub.gpg
          """
          trap: true
          shy: true # todo: add status discovery
        {$status} = await @file.types.pacman_conf
          $header: 'Stable channel'
          $sudo: true
          content: 'sublime-text': 'Server': 'https://download.sublimetext.com/arch/stable/x86_64'
          merge: true
          backup: true
        # Note 2103101, commenting next action as it seems redundant
        # with the one just after
        # await @execute
        #   $if: $status
        #   command: 'pacman --noconfirm -Syu sublime-text'
        #   $sudo: true
        # Install the package (from official Sublime documentation)
        # -u, --sysupgrade     upgrade installed packages
        # -y, --refresh        download fresh package databases from the server
        # Running `yay -Suy` is required or error is thrown when running Yay:
        # "database file for 'sublime-text' does not exist (use '-Syu' to download)"
        await @service.install
          $header: 'Package'
          $if: $status
          name: 'sublime-text'
          yay_flags: ['u', 'y']
          pacman_flags: ['u', 'y']
      # await @execute
      #   $header: 'K8S kubectl'
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
      # await @file
      #   target: "#{home}/.zshrc"
      #   from: '#START KUBECTL'
      #   to: '#END KUBECTL'
      #   replace: """
      #   if [ $commands[kubectl] ]; then
      #     source <(kubectl completion zsh)
      #   fi
      #   """
      # await @execute
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
      # await @call $header: 'K8S Helm', ->
      #   {$status} = await @service.install
      #     name: 'kubernetes-helm'
      #   @execute
      #     $if: $status
      #     command: 'helm init'
      #   @execute
      #     command: 'helm repo update'
    await @call
      $header: 'Docker'
      $if: config.docker
    , ->
      await @service
        $header: 'Package docker'
        $sudo: true
        name: 'docker'
        action: 'start'
        startup: true
      await @service.install
        $header: 'Package docker-compose'
        name: 'docker-compose'
      # Installation is based on  the official documentation
      # [Deploying a registry server](https://docs.docker.com/registry/deploying/)
      # await @execute
      #   command: """
      #   docker run -d -p 5000:5000 --restart=always --name registry \
      #     -v `pwd`/data:/var/lib/registry \
      #     registry:2
      #   """
      #   code_skipped: 3
      # await @execute (
      #   $header: "Push #{image}"
      #   command: """
      #   # Get any image from the hub and tag it to point to your registry
      #   docker pull #{image}
      #   docker tag #{image} localhost:5000/#{image}
      #   # then push it to your registry
      #   docker push localhost:5000/ubuntu
      #   """
      # ) for image in ['centos']
    await @call
      $header: 'VirtualBox'
      $if: config.virtualbox
    , ->
      await @service.install 'linux-headers'
      # Note 02/2020: The `virtualbox` package ask to choose between;
      # 1. virtualbox-host-dkms                   2. virtualbox-host-modules-arch
      # Since the first option (virtualbox-host-dkms) is selected, it create a
      # conflict if we later try to install the second one (virtualbox-host-modules-arch)
      # The current fix is to install the second option before the `virtualbox`
      # package.
      # for linux kernel choose virtualbox-host-modules-arch
      await @service.install 'virtualbox-host-modules-arch'
      # for other kernels choose virtualbox-host-dkms
      # @service.install 'virtualbox-host-dkms'
      await @service.install 'virtualbox'
      #@service.install 'virtualbox-guest-modules-arch' module dosen't exist anymore
      await @service.install 'virtualbox-guest-utils'
      # Module vboxpci used to work but I can't activate it as of feb 2020,
      # command `modprob vboxpci` fail with message "Module vboxpci not found in
      # directory /lib/modules/`uname -r`"
      # command `modprob vboxdrv vboxpci` work but with `lsmod` doesn't print the module.
      await @system.mod 'vboxdrv', $sudo: true    # Mandatory
      await @system.mod 'vboxnetadp', $sudo: true # Optional, needed to create the host interface in the VirtualBox global preferences
      await @system.mod 'vboxnetflt', $sudo: true # Optional, needed to launch a virtual machine using that network interface
      await @system.mod 'vboxpci', $sudo: true, disabled: true # Optional, needed when your virtual machine needs to pass through a PCI device on your host.
    await @service
      $header: 'Vagrant'
      name: 'vagrant'

# Dependencies

os = require 'os'

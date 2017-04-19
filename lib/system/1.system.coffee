
###

*   `locale` (string)
    System locale, default to the first locale in "locales" options.
*   `locales` (string)
    List of supported locales, required.

###

module.exports = (options) ->
  throw Error "Required option: locales" unless options.locales
  options.locale ?= options.locales[0]
  @system.execute
    cmd: """
    yaourt --noconfirm -Syyu
    """
    if: options.upgrade
  @system.user options.user, name: process.env.USER, sudo: true
  @call header: 'System', ->
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
      name: 'openssh'
      srv_name: 'sshd'
    @service.install 'rsync'
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
      header: "Profile Alias"
      if: !!options.aliases
      replace: Object.keys(options.aliases).map((k) -> "alias #{k}='#{options.aliases[k]}'").join '\n'
      target: "~.profile"
      from: '#START ALIAS'
      to: '#END ALIAS'
      append: true
      eof: true
      backup: true
  @call header: 'Gnome', ->
    @service.install 'gnome-session-properties'
    @service.install 'dconf-editor'
    @service.install 'gtk-theme-arc-git'
    @system.dconf
      header: 'Gnome Session Save'
      properties: '/org/gnome/gnome-session/auto-save-session': 'true'
    @system.dconf
      header: 'Gnome Session LANG'
      properties: '/org/gnome/desktop/input-sources/sources': '[(\'xkb\', \'us\'), (\'xkb\', \'fr\')]'
    @system.dconf
      header: 'Gnome Session Invert Alt/CTL'
      properties: '/org/gnome/desktop/input-sources/xkb-options': '[\'ctrl:swap_lalt_lctl\']'
    @system.dconf
      header: 'Gnome Session TouchPad'
      properties: '/org/gnome/desktop/peripherals/touchpad/click-method': '\'fingers\''
    @service.install 'networkmanager-openvpn'
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
      name: ['coffee-script', 'mocha']
      global: true
      sudo: true
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
        'minimap-selection', 'monokai', 'pretty-json', 'project-manager', 'react', 'tail']
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
  @call header: 'Productivity', ->
    @service.install
      header: 'Package gitkraken'
      name: 'gitkraken'
    @service.install
      header: 'Package chromium'
      name: 'chromium'
    @service.install
      header: 'Package opera'
      name: 'opera'
    @service.install
      header: 'Package pantheon-files-plugin-dropbox-bzr'
      name: 'pantheon-files-plugin-dropbox-bzr'
    @service.install
      header: 'Package libreoffice-fresh'
      name: 'libreoffice-fresh'
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
  @call header: 'Office', ->
    @service.install
      header: 'Package firefox'
      name: 'firefox'
    @service.install
      header: 'Package thunderbird'
      name: 'thunderbird'
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

season = require 'season'
{merge} = require 'nikita/lib/misc'

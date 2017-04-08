
###

*   `locale` (string)
    System locale, default to the first locale in "locales" options.
*   `locales` (string)
    List of supported locales, required.

###

module.exports = (options) ->
  throw Error "Required option: locales" unless options.locales
  options.locale ?= options.locales[0]
  for username, user of options.users
    user.name ?= username
    user.home ?= "/home/#{username}"
    user.aliases ?= {}
    user.atom_default ?= {}
    user.atom_config ?= {}
  @system.execute
    cmd: """
    yaourt --noconfirm -Syyu
    """
    if: options.upgrade
  @system.user user, sudo: true
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
    @service.install
      header: 'oh-my-zsh Install'
      name: 'oh-my-zsh-git'
    @system.copy
      header: 'oh-my-zsh Init'
      unless_exists: true
      source: "/usr/share/oh-my-zsh/zshrc"
      target: "~/.zshrc"
  for username, user of options.users
    @system.user user, sudo: true
    @file
      header: 'Profile in Bash'
      if_exists: true
      target: "#{user.home}/.bashrc"
      match: /^\. ~\/.profile$/m
      replace: '. ~/.profile'
      chown: "#{username}"
      append: true
      backup: true
      eof: true
    @file
      header: "Profile Alias"
      if: !!user.aliases
      replace: Object.keys(user.aliases).map((k) -> "alias #{k}='#{user.aliases[k]}'").join '\n'
      target: "#{user.home}/.profile"
      from: '#START ALIAS'
      to: '#END ALIAS'
      append: true
      eof: true
      backup: true
  @call header: 'Productivity', ->
    @service.install
      header: 'Package atom'
      name: 'atom'
    for username, user of options.users
      @file.cson
        target: "#{user.home}/.atom/keymap.cson"
        content:
          'atom-workspace':
            "alt-f7": "find-and-replace:select-all"
            "ctrl-f7": "find-and-replace:find-next-selected"
            "ctrl-shift-f7": "find-and-replace:find-previous-selected"
            "f7": "find-and-replace:find-next"
            "shift-f7": "find-and-replace:find-previous"
      merge: true
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
      header: 'SFTP client filezilla'
      name: 'filezilla'
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
  @system.npm
    header: 'Node.js Global Packages'
    name: ['coffee-script', 'mocha']
    global: true
    sudo: true
  @system.apm
    header: 'Atom Packages'
    name: [
      'stylus', 'sublime-style-column-selection', 'atom-monokai-dark',
      'atom-typescript', 'chester-atom-syntax', 'color-picker', 'git-plus',
      'git-time-machine', 'highlight-selected', 'indent-guide-improved',
      'language-coffee-script', 'language-docker', 'language-jade',
      'language-jade', 'language-log', 'language-scala', 'linter', 'markdown-toc',
      'material-syntax', 'minimap', 'minimap-find-and-replace', 'minimap-highlight-selected',
      'minimap-selection', 'monokai', 'pretty-json', 'project-manager', 'react', 'tail']
    upgrade: true
  @call (_, callback) ->
    for username, user of options.users then do (user) =>
      season.readFile "#{user.home}/.atom/config.cson", (err, config) =>
        config = merge {}, user.atom_default, config, user.atom_config
        @file
          header: 'Atom Configuration'
          target: "#{user.home}/.atom/config.cson"
          content: season.stringify config

## Dependencies

season = require 'season'
{merge} = require 'nikita/lib/misc'

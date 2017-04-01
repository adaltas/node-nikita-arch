
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
    @service.install 'gnome-session-properties'
    @system.dconf
      header: 'Gnome Session Save'
      properties: '/org/gnome/gnome-session/auto-save-session': 'true'
  for username, user of options.users
    @system.user user, sudo: true
    @service.install
      header: 'oh-my-zsh Install'
      name: 'oh-my-zsh-git'
    @system.copy
      header: 'oh-my-zsh Init'
      unless_exists: true
      source: "/usr/share/oh-my-zsh/zshrc"
      target: "#{user.home}/.zshrc"
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
  # @call header: 'Pantheon', ->
  #   # Pantheon is the default desktop environment originally created for the elementary OS distribution. It is written from scratch using Vala and the GTK3 toolkit. With regards to usability and appearance, the desktop has some similarities with GNOME Shell and macOS.
  #   @service.install (
  #     header: "Required Package #{name}"
  #     name: name
  #   ) for name in ['cerbere-bzr', 'gala-bzr', 'wingpanel-bzr', 'switchboard', 'slingshot-launcher-bzr', 'plank-bzr']
  #   pcks =
  #     'audience-bzr': false # Video player
  #     'contractor-bzr': false # Service for sharing data between apps
  #     'dexter-contacts-bzr': false # Contacts manager (does not build)
  #     'eidete-bzr': false # Simple screencaster
  #     'elementary-icon-theme-bzr': true
  #     'elementary-scan-bzr': false
  #     'elementary-wallpapers-bzr': true
  #     'gtk-theme-elementary-bzr': true
  #     'feedler-bzr': false
  #     'footnote-bzr': false
  #     'geary': false
  #     'indicator-pantheon-session-bzr': false
  #     'lightdm-pantheon-greeter-bzr': false
  #     'maya-calendar-bzr': false
  #     'midori-granite-bzr': false
  #     'noise-player-bzr': false
  #     'pantheon-backgrounds-bzr': true
  #     'pantheon-calculator-bzr': false
  #     'pantheon-default-settings-bzr': true
  #     'pantheon-files-bzr': true
  #     'pantheon-notify-bzr': true
  #     'pantheon-print-bzr': false
  #     'pantheon-terminal-bzr': true
  #     'plank-theme-pantheon-bzr': true
  #     'scratch-text-editor-bzr': true
  #     'snap-photobooth-bzr': true
  #     'switchboard-bzr': true
  #   @service.install (
  #     header: "Outils Package #{name}"
  #     name: name
  #   ) for name in Object.keys(pcks).filter (pck) -> pcks[pck]
  #   pcks =
  #     'ttf-opensans': true
  #     'ttf-raleway-font-family': true
  #     'ttf-dejavu': true
  #     'ttf-droid': true
  #     'ttf-freefont': true
  #     'ttf-liberation': true
  #   @service.install (
  #     header: "Font Package #{name}"
  #     name: name
  #   ) for name in Object.keys(pcks).filter (pck) -> pcks[pck]
  #   @service.install 'pantheon-session-bzr'
  #   @service.install 'contractor-bzr'
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

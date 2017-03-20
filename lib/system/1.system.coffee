
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
  @system.execute
    cmd: """
    yaourt --noconfirm -Syyu
    """
    unless: options.no_upgrade
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
    @service.install
      header: 'Package gitkraken'
      name: 'gitkraken'
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
  #   ) for name in ['cerbere-bzr', 'gala-bzrA', 'wingpanel-bzr', 'slingshot-launcher-bzr', 'plank-bzr']
  #   pcks =
  #     'audience-bzr': false
  #     'contractor-bzr': false
  #     'dexter-contacts-bzr': false
  #     'eidete-bzr': false
  #     'elementary-icon-theme-bzr': true
  #     'elementary-scan-bzr': true
  #     'elementary-wallpapers-bzr'
  #     'gtk-theme-elementary-bzr'
  #     'feedler-bzr'
  #     'footnote-bzr'
  #     'geary'
  #     'indicator-pantheon-session-bzr'
  #     'lightdm-pantheon-greeter-bzr'
  #     'maya-calendar-bzr'
  #     'midori-granite-bzr'
  #     'noise-player-bzr'
  #     'pantheon-backgrounds-bzr'
  #     'pantheon-calculator-bzr'
  #     'pantheon-default-settings-bzr'
  #     'pantheon-files-bzr'
  #     'pantheon-notify-bzr'
  #     'pantheon-print-bzr'
  #     'pantheon-terminal-bzr'
  #     'plank-theme-pantheon-bzr'
  #     'scratch-text-editor-bzr'
  #     'snap-photobooth-bzr'
  #     'switchboard-bzr'
  #   @service.install (
  #     header: "Outils Package #{name}"
  #     name: name
  #   ) for name in Object.keys(pcks).filter (pck) -> pcks[pck]
  #   pcks =
  #     'ttf-opensansA'
  #     'ttf-raleway-font-family'
  #     'ttf-dejavu'
  #     'ttf-droid'
  #     'ttf-freefont'
  #     'ttf-liberation'
  #   @service.install (
  #     header: "Font Package #{name}"
  #     name: name
  #   ) for name in Object.keys(pcks).filter (pck) -> pcks[pck]
  #   @service.install 'pantheon-session-bzr'
  #   @service.install 'contractor-bzr'

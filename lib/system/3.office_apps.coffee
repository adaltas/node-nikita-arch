
###

* `locale` (string)
  System locale, default to the first locale in "locales" options.
* `locales` (string)
  List of supported locales, required.

###

module.exports = ({options}) ->
  throw Error "Required option: locales" unless options.locales
  ssh = @ssh options.ssh
  home = if ssh then "/home/#{ssh.config.username}" else '~'
  options.locale ?= options.locales[0]
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
    # @service.install
    #   header: 'Package Skype'
    #   name: 'skypeforlinux-bin'
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
      header: 'Package Apache Directory Studio'
      name: 'apachedirectorystudio'
    @service.install
      header: 'tcpdump'
      name: 'tcpdump'
    @service.install
      header: 'Gravit'
      name: 'gravit-designer-bin'
    @service.install
      header: 'Keybase'
      name: 'keybase-bin'
      unless_exists: '/usr/bin/keybase'

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
    # @service.install
    #   header: 'Master PDF Editor'
    #   name: 'masterpdfeditor'
    @service.install
      header: 'Package firefox'
      name: 'firefox'
    @service.install
      header: 'Package thunderbird'
      name: 'thunderbird'
    # @service.install
    #   header: 'Package mailspring'
    #   name: 'mailspring'

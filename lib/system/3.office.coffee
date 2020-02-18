
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
    header: 'Web'
    if: options.office
  , ->
    @service.install
      header: 'Package firefox'
      name: 'firefox'
    @service.install
      header: 'Package chromium'
      name: 'chromium'
    @service.install
      header: 'Package opera'
      name: 'opera'
  @call
    header: 'Productivity'
    if: options.productivity
  , ->
    @service.install
      header: 'Package thunderbird'
      name: 'thunderbird'
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
    # Install fail:
    # gravit-designer-bin-2019_2.7.zip ... FAILED
    # Seems to be related with an invalid checksum
    @service.install
      header: 'Gravit'
      name: 'gravit-designer-bin'
      disabled: true
    @service.install
      header: 'Keybase'
      name: 'keybase-gui'
  @call
    header: 'Font'
    if: options.font
  , ->
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

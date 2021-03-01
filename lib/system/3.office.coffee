
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
    metadata: header: 'Web'
    if: config.office
  , ->
    @service.install
      metadata: header: 'Package firefox'
      name: 'firefox'
    @service.install
      metadata: header: 'Package chromium'
      name: 'chromium'
    @service.install
      metadata: header: 'Package opera'
      name: 'opera'
  @call
    metadata: header: 'Productivity'
    if: config.productivity
  , ->
    @service.install
      metadata: header: 'Package thunderbird'
      name: 'thunderbird'
    @service.install
      metadata: header: 'Package libreoffice-fresh'
      name: 'libreoffice-fresh'
    @service.install
      metadata: header: 'Package libreoffice-fresh-fr'
      name: 'libreoffice-fresh-fr'
    @service.install
      metadata: header: 'Package typora'
      name: 'typora'
    @service.install
      metadata: header: 'SFTP client gftp'
      name: 'gftp'
    @service.install
      metadata: header: 'SFTP client filezilla'
      name: 'filezilla'
    @service.install
      metadata: header: 'Package Apache Directory Studio'
      name: 'apachedirectorystudio'
    @service.install
      metadata: header: 'tcpdump'
      name: 'tcpdump'
    # Install fail:
    # gravit-designer-bin-2019_2.7.zip ... FAILED
    # Seems to be related with an invalid checksum
    @service.install
      metadata: header: 'Gravit'
      name: 'gravit-designer-bin'
      disabled: true
    @service.install
      metadata: header: 'Keybase'
      name: 'keybase-gui'
  @call
    metadata: header: 'Font'
    if: config.font
  , ->
    @service.install
      metadata: header: 'Liberation'
      name: 'ttf-liberation'
    @service.install
      metadata: header: 'Dejavu'
      name: 'ttf-dejavu'
    @service.install
      metadata: header: 'Roboto'
      name: 'ttf-roboto'
    @service.install
      metadata: header: 'Noto'
      name: 'noto-fonts'
    @service.install
      metadata: header: 'ttf-ms-fonts (Arial, Courier New, Georgia, Verdana, ...)'
      name: 'ttf-ms-fonts'

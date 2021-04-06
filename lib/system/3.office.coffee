
###

* `locale` (string)
  System locale, default to the first locale in "locales" config.
* `locales` (string)
  List of supported locales, required.

###

module.exports =
  metadata: header: 'Office'
  handler: ({config}) ->
    await @call
      $header: 'Web'
      $if: config.office
    , ->
      await @service.install
        $header: 'Package firefox'
        name: 'firefox'
      await @service.install
        $header: 'Package chromium'
        name: 'chromium'
      await @service.install
        $header: 'Package opera'
        name: 'opera'
    await @call
      $header: 'Productivity'
      $if: config.productivity
    , ->
      await @service.install
        $header: 'Package thunderbird'
        name: 'thunderbird'
      await @service.install
        $header: 'Package libreoffice-fresh'
        name: 'libreoffice-fresh'
      await @service.install
        $header: 'Package libreoffice-fresh-fr'
        name: 'libreoffice-fresh-fr'
      await @service.install
        $header: 'Package typora'
        name: 'typora'
      await @service.install
        $header: 'SFTP client gftp'
        name: 'gftp'
      await @service.install
        $header: 'SFTP client filezilla'
        name: 'filezilla'
      await @service.install
        $header: 'Package Apache Directory Studio'
        name: 'apachedirectorystudio'
      await @service.install
        $header: 'tcpdump'
        name: 'tcpdump'
      # Install fail:
      # gravit-designer-bin-2019_2.7.zip ... FAILED
      # Seems to be related with an invalid checksum
      await @service.install
        $header: 'Gravit'
        name: 'gravit-designer-bin'
        disabled: true
      await @service.install
        $header: 'Keybase'
        name: 'keybase-gui'
    await @call
      $header: 'Font'
      $if: config.font
    , ->
      await @service.install
        $header: 'Liberation'
        name: 'ttf-liberation'
      await @service.install
        $header: 'Dejavu'
        name: 'ttf-dejavu'
      await @service.install
        $header: 'Roboto'
        name: 'ttf-roboto'
      await @service.install
        $header: 'Noto'
        name: 'noto-fonts'
      await @service.install
        $header: 'ttf-ms-fonts (Arial, Courier New, Georgia, Verdana, ...)'
        name: 'ttf-ms-fonts'

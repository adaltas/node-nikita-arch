
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
    unless: options.no_upgrade
  @file.types.locale_gen
    header: 'Locale gen'
    locales: options.locales
    locale: options.locale
    generate: true
  @file
    header: 'Locale conf'
    target: '/etc/locale.conf'
    content: "LANG=#{options.locale}"
  @service.install
    header: 'Package atom'
    name: 'atom'
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
    @service.install ' virtualbox-host-modules-arch'
    @system.execute
      cmd: """
      lsmod | grep vboxnetadp && exit 3
      sudo modprobe vboxnetadp
      """
      code_skipped: 3
      debug: true
    @system.execute
      cmd: """
      lsmod | grep vboxnetflt && exit 3
      sudo modprobe vboxnetflt
      """
      code_skipped: 3
      debug: true
    @system.execute
      cmd: """
      lsmod | grep vboxpci && exit 3
      sudo modprobe vboxpci
      """
      code_skipped: 3

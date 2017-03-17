
###

*   `locale` (string)   
    System locale, default to the first locale in "locales" options.
*   `locales` (string)   
    List of supported locales, required.   

###

module.exports = (options) ->
  throw Error "Required option: locales" unless options.locales
  options.locale ?= options.locales[0]
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
    header: "Package atom"
    name: 'atom'
  

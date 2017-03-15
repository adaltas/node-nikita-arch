
`nikita.file.types.locale`

Update the locale definition file located in "/etc/locale.gen".

## Options

*   `chroot_dir` (string)   
    Path to the mount point corresponding to the root directory, optional.   
*   `target` (string)   
    File to write, default to "/etc/locale.gen".   
*   `locale` (string)   
    System locale, default to the first locale in "locales" options.
*   `locales` (string)   
    List of supported locales, required.   

## Example

require('nikita').file.types.locale({
  target: '/etc/locale.gen',
  chroot_dir: '/mnt',
  locales: ['fr_FR.UTF-8', 'en_US.UTF-8'],
  locale: 'en_US.UTF-8'
})

    module.exports = (options) ->
      options.target ?= '/etc/locale.gen'
      options.target = "#{path.join options.chroot_dir, options.target}" if options.chroot_dir
      @call (options, callback) ->
        fs.readFile options.ssh, '/mnt', 'ascii', (err, data) ->
          return callbak err if err
          status = false
          locales = data.split '\n'
          for locale, i in locales
            if match = /^#(\w+)($| .+$)/.exec locale
              if match[1] in options.locales
                locales[i] = match[1]+match[2]
                status = true
            if match = /^(\w+)($| .+$)/.exec locale
              if match[1] not in options.locales
                locales[i] = '#'+match[1]+match[2]
                status = true
          return callback() unless status
          data = locales.join '\n'
          console.log data

## Dependecies

    path = require 'path'

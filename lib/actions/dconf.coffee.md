
`nikita.system.dconf`

dconf is a low-level configuration system and settings management used by Gnome.

## Options

*   `properties` (object)
    Name of the module.

## Example

require('nikita').system.dconf({
  properties: {
    '/org/gnome/gnome-session/auto-save-session': 'true'
  }
})

    module.exports = (options) ->
      options.properties = options.argument if options.argument?
      options.properties ?= {}
      for key, value of options.properties
        @system.execute """
        dconf read #{key} | grep -x "#{value}" && exit 3
        dconf write /org/gnome/gnome-session/auto-save-session "#{value}"
        """, code_skipped: 3

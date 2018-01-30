
nikita = require 'nikita'
nikita.registry.register ['system', 'apm'], require './lib/actions/apm'
nikita.registry.register ['system', 'dconf'], require './lib/actions/dconf'
nikita.registry.register ['system', 'gsettings'], require './lib/actions/gsettings'
nikita.registry.register ['system', 'mod'], require './lib/actions/mod'
nikita.registry.register ['system', 'npm'], require './lib/actions/npm'

config = require process.argv[2]

nikita().call (Object.assign handler: k, v for k, v of config)

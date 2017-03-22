
nikita = require 'nikita'
nikita.register ['system', 'mod'], require './lib/actions/mod'
nikita.register ['system', 'apm'], require './lib/actions/apm'
nikita.register ['system', 'npm'], require './lib/actions/npm'

config = require process.argv[2]

nikita().call (Object.assign handler: k, v for k, v of config)

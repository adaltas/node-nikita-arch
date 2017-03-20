
nikita = require 'nikita'
nikita.register ['system', 'mod'], require './lib/actions/mod'

config = require process.argv[2]

nikita().call (Object.assign handler: k, v for k, v of config)

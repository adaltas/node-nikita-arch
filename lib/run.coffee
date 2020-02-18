
{merge} = require 'mixme'
path = require 'path'
fs = require 'fs'
yaml = require 'js-yaml'
nikita = require 'nikita'
# Local actions
nikita.registry.register ['system', 'apm'], require './actions/apm'
# nikita.registry.register ['system', 'dconf'], require './lib/actions/dconf'
nikita.registry.register ['system', 'gsettings'], require './actions/gsettings'
# nikita.registry.register ['system', 'mod'], require './lib/actions/mod'
nikita.registry.register ['system', 'npm'], require './actions/npm'

module.exports = ->
  target = path.resolve __dirname, '../conf/user.yaml'
  config = yaml.safeLoad fs.readFileSync target
  # Merge user and default configurations
  action = process.argv[2]
  config = merge require(path.join "#{__dirname}/../conf", action), config[action]
  # Execute Nikita
  n = nikita()
  n.call k, v for k, v of config
  n.promise()

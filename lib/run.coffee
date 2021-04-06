
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
  user_config = yaml.load fs.readFileSync target
  # Merge user and default configurations
  action = process.argv[2]
  base_config = require(path.join "#{__dirname}/../conf", action)
  config = merge base_config, user_config[action]
  # Execute Nikita
  n = nikita()
  await n.call k, v for k, v of config


# Create a user configuration
fs = require 'fs'
path = require 'path'
yaml = require 'js-yaml'
source = path.resolve __dirname, './conf/base.yaml'
target = path.resolve __dirname, './conf/user.yaml'
fs.copyFileSync source, target unless fs.existsSync target
config = yaml.safeLoad fs.readFileSync target

# Initialize Nikita
mixme = require 'mixme'
nikita = require 'nikita'
nikita.registry.register ['system', 'apm'], require './lib/actions/apm'
nikita.registry.register ['system', 'dconf'], require './lib/actions/dconf'
nikita.registry.register ['system', 'gsettings'], require './lib/actions/gsettings'
nikita.registry.register ['system', 'mod'], require './lib/actions/mod'
nikita.registry.register ['system', 'npm'], require './lib/actions/npm'

# Merge user and default configurations
action = process.argv[2]
config = mixme require(path.join "#{__dirname}/conf", action), config[action]

# Execute Nikita
n = nikita()
n.call k, v for k, v of config

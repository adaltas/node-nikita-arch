
nikita = require 'nikita'

config = require process.argv[2]
 
nikita().call (Object.assign handler: k, v for k, v of config)

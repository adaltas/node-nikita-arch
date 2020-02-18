# Create a user configuration
fs = require 'fs'
prompts = require 'prompts'
{merge} = require 'mixme'
path = require 'path'
yaml = require 'js-yaml'

module.exports = ->
  source = path.resolve __dirname, '../conf/base.yaml'
  target = path.resolve __dirname, '../conf/user.yaml'
  unless fs.existsSync target
    # fs.copyFileSync source, target
    response = await prompts [
      type: 'text',
      name: 'ssh_ip',
      message: 'SSH target IP',
    ,
      type: 'text',
      name: 'ssh_password',
      message: 'SSH target password',
    ,
      type: 'text',
      name: 'disk_password',
      message: 'Disk encryption password',
    ,
      type: 'text'
      name: 'user_username'
      message: 'Username'
    ,
      type: 'text'
      name: 'user_password'
      message: 'Password'
    ]
    config = yaml.safeLoad fs.readFileSync source
    unless response.user_username is 'nikita'
      {users} = config.bootstrap['./lib/bootstrap/3.system']
      users[response.user_username] = users.nikita
      delete users.nikita
    config = merge config,
      bootstrap:
        '@nikitajs/core/lib/ssh/open':
          disabled: false
          host: response.ssh_ip
          password: response.ssh_password
        './lib/bootstrap/2.disk':
          passphrase: response.disk_password
        './lib/bootstrap/3.system':
          locales: ['fr_FR.UTF-8', 'en_US.UTF-8']
          timezone: 'Europe/Paris'
          users:
            [response.user_username]:
              password: response.user_password
      system:
        '@nikitajs/core/lib/ssh/open':
          disabled: false
          host: response.ssh_ip
          username: response.user_username
          password: response.user_password
    fs.writeFileSync target, yaml.safeDump config

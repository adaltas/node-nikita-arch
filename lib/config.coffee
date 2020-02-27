# Create a user configuration
fs = require 'fs'
prompts = require 'prompts'
path = require 'path'
yaml = require 'js-yaml'

module.exports = ->
  target = path.resolve __dirname, '../conf/user.yaml'
  unless fs.existsSync target
    response = await prompts [
      type: 'select',
      name: 'connection',
      message: 'Connection',
      choices: [
        title: 'Remote SSH',
        value: 'remote'
      ,
        title: 'Local',
        value: 'local'
      ]
    ,
      type: (prev) -> if prev is 'remote' then 'text' else null,
      name: 'ssh_ip',
      message: 'SSH target IP',
    ,
      type: (prev) -> if prev is 'remote' then 'text' else null,
      name: 'ssh_password',
      message: 'SSH target password',
    ,
      type: (prev) -> if prev is 'remote' then 'text' else null,
      name: 'ssh_port',
      message: 'SSH target port',
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
    config =
      bootstrap:
        '@nikitajs/core/lib/ssh/open':
          disabled: response.connection is 'local'
          host: response.ssh_ip or null
          password: response.ssh_password or null
          port: response.ssh_port or null
        './lib/bootstrap/2.disk':
          lvm:
            passphrase: response.disk_password
        './lib/bootstrap/3.system':
          locales: ['fr_FR.UTF-8', 'en_US.UTF-8']
          timezone: 'Europe/Paris'
          users:
            [response.user_username]:
              password: response.user_password
              sudoer: true
          install_bumblebee: false
      system:
        '@nikitajs/core/lib/ssh/open':
          disabled: response.connection is 'local'
          host: response.ssh_ip
          username: response.user_username
          password: response.user_password or null
          port: response.ssh_port or null
        './lib/system/2.dev':
          gnome: true
          virtualization: true
          docker: true
          virtualbox: true
          npm_global: true
          atom: true
          nodejs: true
          programming: true
        './lib/system/3.office_apps':
          productivity: true
          font: true
          office: true
    fs.writeFileSync target, yaml.safeDump config

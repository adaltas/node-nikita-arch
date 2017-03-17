
module.exports =
  'nikita/lib/log/cli':
     pad: host: 20, header: 60
  'nikita/lib/log/md':
    basedir: "#{__dirname}/log"
  'nikita/lib/ssh/open':
    disabled: true
    host: '192.168.0.17'
    port: 22
    password: 'secret'
  './lib/system/1.system':
    disabled: false
    no_upgrade: true
    locales: ['fr_FR.UTF-8', 'en_US.UTF-8']
    locale: 'en_US.UTF-8'
  'nikita/lib/ssh/close':
    disabled: true

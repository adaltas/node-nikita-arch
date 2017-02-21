
module.exports =
  ssh:
    host: '192.168.0.20'
    port: 22
    password: 'mysecret'
  log:
    md:
      basedir: "#{__dirname}/log"
  actions:
    './lib/crypt': skip: true

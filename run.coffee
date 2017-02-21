
mecano = require 'mecano'
config = require './config'

mecano()
# .log.cli config.log?.cli, pad: host: 20, header: 60
# .log.md config.log?.md
# .ssh.open config.ssh #, host: context.config.ip or context.config.host
.call (Object.assign handler: k, v for k, v of config)
# .ssh.close()

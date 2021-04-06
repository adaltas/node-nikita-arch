
module.exports =
  '@nikitajs/core/lib/actions/log/cli':
    pad: host: 20, header: 60
  '@nikitajs/core/lib/actions/log/md':
    basedir: "#{__dirname}/../log"
  '@nikitajs/core/lib/actions/ssh/open':
    $disabled: true
    host: 'XXX.XXX.XXX.XXX'
    port: 22
    password: 'XXXXXX'
  './lib/bootstrap/1.welcome': {}
  './lib/bootstrap/2.disk':
    disk: '/dev/nvme0n1'
    format: true
    wipe: false
    partitions:
      '/dev/nvme0n1p1': type: 'f32'
      '/dev/nvme0n1p2': type: 'ext4'
    crypt:
      passphrase: 'XXXXXX'
      device: '/dev/nvme0n1p2'
  './lib/bootstrap/3.system':
    locales: ['fr_FR.UTF-8', 'en_US.UTF-8']
    boot_partition: '/dev/nvme0n1p1'
    # locale: 'fr_FR.UTF-8' # Default to en_US.UTF-8
    crypt:
      device: '/dev/nvme0n1p2'
    timezone: 'Europe/Paris'
    users: {}
  '@nikitajs/core/lib/actions/ssh/close': {}

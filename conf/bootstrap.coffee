
module.exports =
  '@nikitajs/core/lib/log/cli':
    pad: host: 20, header: 60
  '@nikitajs/core/lib/log/md':
    basedir: "#{__dirname}/../log"
  '@nikitajs/core/lib/ssh/open':
    disabled: true
    host: 'XXX.XXX.XXX.XXX'
    port: 22
    password: 'XXXXXX'
  './lib/bootstrap/1.welcome': {}
  './lib/bootstrap/2.disk':
    disk: '/dev/nvme0n1'
    wipe: false
    partitions:
      '/dev/nvme0n1p1': 'f32'
      '/dev/nvme0n1p2': 'ext4'
    lvm:
      passphrase: 'XXXXXX'
      partition: '/dev/nvme0n1p2'
  './lib/bootstrap/3.system':
    locales: ['fr_FR.UTF-8', 'en_US.UTF-8']
    boot_partition: '/dev/nvme0n1p1'
    # locale: 'fr_FR.UTF-8' # Default to en_US.UTF-8
    timezone: 'Europe/Paris'
    users: {}
  '@nikitajs/core/lib/ssh/close': {}

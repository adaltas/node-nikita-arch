
module.exports =
  '@nikita/core/lib/log/cli':
     pad: host: 20, header: 60
  '@nikita/core/lib/log/md':
    basedir: "#{__dirname}/../log"
  '@nikita/core/lib/ssh/open':
    host: '192.168.1.39'
    port: 22
    password: 'secret'
  './lib/bootstrap/1.welcome': {}
  './lib/bootstrap/2.disk_crypt':
    disk: '/dev/nvme0n1'
  './lib/bootstrap/3.partitions_create':
    disk: '/dev/nvme0n1'
    partitions: ['/dev/nvme0n1p1', '/dev/nvme0n1p2']
  './lib/bootstrap/4.partitions_format':
    partitions:
      '/dev/nvme0n1p1': 'f32'
      '/dev/nvme0n1p2': 'ext4'
  './lib/bootstrap/5.partitions_lvm':
    passphrase: 'GdansK007'
    partition: '/dev/nvme0n1p2'
  './lib/bootstrap/6.system_install':
    locales: ['fr_FR.UTF-8', 'en_US.UTF-8']
    # locale: 'fr_FR.UTF-8' # Default to en_US.UTF-8
    timezone: 'Europe/Paris'
    users: oskarryn: uid: 1000, password: 'secret', sudoer: true
  '@nikita/core/lib/ssh/close': {}

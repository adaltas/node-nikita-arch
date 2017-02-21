
module.exports =
  'mecano/lib/log/cli': 
     pad: host: 20, header: 60
  'mecano/lib/log/md':
    basedir: "#{__dirname}/log"
  'mecano/lib/ssh/open':
    host: '192.168.1.41'
    port: 22
    password: 'secret'
  './lib/1.welcome': {}
  './lib/2.disk_crypt':
    disabled: true
    disk: '/dev/nvme0n1'
  './lib/3.partitions_create':
    disabled: true
    disk: '/dev/nvme0n1'
  './lib/4.partitions_format':
    disabled: true
    partitions:
      '/dev/nvme0n1p1': 'f32'
      '/dev/nvme0n1p2': 'ext4'
  './lib/5.partitions_lvm':
    disabled: false
    partition: '/dev/nvme0n1p2'
  'mecano/lib/ssh/close': {}

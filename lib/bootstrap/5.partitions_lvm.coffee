
###

options:

* partition (string)
  Partition to crypt and used to create LVM physical volume.

###

module.exports = header: "Partitions LVM", handler: ({options}) ->
  @system.execute
    cmd: """
    echo '#{options.passphrase}' | \
      cryptsetup open --type luks #{options.partition} lvm \
      || exit 3
    echo '#{options.passphrase}' | \
      cryptsetup luksFormat #{options.partition}
    echo '#{options.passphrase}' | \
      cryptsetup open --type luks #{options.partition} lvm
    """
    code_skipped: 3
  @system.execute
    cmd: """
    info=#{options.info or ''}
    pvcreate /dev/mapper/lvm
    vgcreate volume /dev/mapper/lvm
    lvcreate -L 4G volume -n swap
    lvcreate -L 100G volume -n root
    lvcreate -l 100%FREE volume -n home
    mkfs.ext4 /dev/mapper/volume-root
    mkfs.ext4 /dev/mapper/volume-home
    mkswap /dev/mapper/volume-swap
    if [ -n $info ]; then lvs; fi
    """
    if: -> @status -1

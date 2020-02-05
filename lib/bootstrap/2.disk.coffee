
module.exports = header: "Disk", handler: ({options}) ->
  # Need to check, this was used in previous versions of nikita-arch,
  # probably to ensure the disk is erased from any previous data
  # @system.execute
  #   cmd: """
  #   cryptsetup open --type plain #{options.disk} container --key-file /dev/random
  #   dd if=/dev/zero of=/dev/mapper/container status=progress bs=1M
  #   cryptsetup close container
  #   """
  @call
    header: "Partitions Creation"
  , ->
    [partition_1, partition_2] = Object.keys options.partitions
    @file
      target: '/root/layout.sfdisk'
      content: """
      label: gpt
      device: #{options.disk}
      unit: sectors

      #{partition_1} : start=     2048, size=   2097152, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B
      #{partition_2} : start=  2099200, type=E6D6D379-F507-44C2-A23C-238F2A3DF928
      """
    @system.execute """
    sfdisk #{options.disk} < /root/layout.sfdisk
    """
  @call
    header: "Partitions Formating"
  , ->
    for mount, type of options.partitions
      @system.execute switch type
        when 'f32'
          "mkfs.vfat -F32 -nESP #{mount}"
        when 'ext4'
          "mkfs.ext4 #{mount}"
        else throw Error "Invalid partition type"
  @call
    header: "Partitions LVM"
  , ->
    @system.execute
      header: 'Crypsetup'
      cmd: """
      echo '#{options.lvm.passphrase}' | \
        cryptsetup luksFormat #{options.lvm.partition}
      echo '#{options.lvm.passphrase}' | \
        cryptsetup open --type luks #{options.lvm.partition} lvm
      """
      code_skipped: 3
    @system.execute
      header: 'Format'
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


module.exports =
  metadata: header: "Disk"
  handler: ({config}) ->
    # Format the disk into partitions
    config.format ?= true
    # Ensure the disk is erased from any previous data
    config.wipe ?= false
    return unless config.format
    @execute
      $if: config.wipe
      command: """
      cryptsetup open --type plain #{config.disk} container --key-file /dev/random
      dd if=/dev/zero of=/dev/mapper/container status=progress bs=1M
      cryptsetup close container
      """
    # Split the disk into 2 partitions, first to boot, second to store data
    @call
      $header: "Partitions Creation"
    , ->
      [partition_1, partition_2] = Object.keys config.partitions
      @file
        target: '/root/layout.sfdisk'
        content: """
        label: gpt
        device: #{config.disk}
        unit: sectors
        #{partition_1} : start=     2048, size=   2097152, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B
        #{partition_2} : start=  2099200, type=E6D6D379-F507-44C2-A23C-238F2A3DF928
        """
      @execute """
      sfdisk #{config.disk} < /root/layout.sfdisk
      """
    @call
      $header: "Partitions Formating"
    , ->
      for partition, info of config.partitions
        @execute switch info.type
          when 'f32'
            "mkfs.vfat -F32 -nESP #{partition}"
          when 'ext4'
            "mkfs.ext4 #{partition}"
          else throw Error "Invalid partition type"
    @call
      $header: "Partitions LVM"
    , ->
      {$status} = await @execute
        $header: 'Crypsetup'
        command: """
        echo '#{config.crypt.passphrase}' | \
          cryptsetup luksFormat #{config.crypt.device}
        echo '#{config.crypt.passphrase}' | \
          cryptsetup open --type luks #{config.crypt.device} lvm
        """
        code_skipped: 3
      @execute
        $header: 'Format'
        $if: $status
        command: """
        info=#{config.info or ''}
        pvcreate /dev/mapper/lvm
        vgcreate volume /dev/mapper/lvm
        lvcreate -L 2G volume -n swap
        lvcreate -L 18G volume -n root
        # VirtualBox sizing
        # lvcreate -L 2G volume -n swap
        # lvcreate -L 18G volume -n root
        lvcreate -l 100%FREE volume -n home
        mkfs.ext4 /dev/mapper/volume-root
        mkfs.ext4 /dev/mapper/volume-home
        mkswap /dev/mapper/volume-swap
        if [ -n $info ]; then lvs; fi
        """

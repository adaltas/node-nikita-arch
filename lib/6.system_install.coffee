
module.exports = header: "Partitions Encryption", handler: (options) ->
  @execute """
  # Mount
  mkdir /mnt/boot
  mount /dev/nvme0n1p1 /mnt/boot
  echo '\\n\\n' | pacstrap -i /mnt base base-devel net-tools
  genfstab -U -p /mnt >> /mnt/etc/fstab
  arch-chroot /mnt /bin/bash
  """
    

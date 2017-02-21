
module.exports = header: "Partitions Encryption", handler: (options) ->
  @execute """
  # Encryption
  echo 'secret' | cryptsetup luksFormat #{options.partition}
  echo 'secret' | cryptsetup open --type luks #{options.partition} lvm
  # Partioning LVM
  pvcreate /dev/mapper/lvm
  vgcreate volume /dev/mapper/lvm
  lvcreate -L 4G volume -n swap
  lvcreate -L 100G volume -n root
  lvcreate -l 100%FREE volume -n home
  mkfs.ext4 /dev/mapper/volume-root
  mkfs.ext4 /dev/mapper/volume-home
  mkswap /dev/mapper/volume-swap
  mount /dev/mapper/volume-root /mnt
  mkdir /mnt/home
  mount /dev/mapper/volume-home /mnt/home
  swapon /dev/mapper/volume-swap
  """
    

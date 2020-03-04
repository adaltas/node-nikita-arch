
# Troubleshooting

## Mount LVM partition encrypted with LUKS

```
lsblk
# NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
# loop0         7:0    0 541.5M  1 loop /run/archiso/sfs/airootfs
# sda           8:0    1  57.3G  0 disk 
# ├─sda1        8:1    1   656M  0 part /run/archiso/bootmnt
# └─sda2        8:2    1    64M  0 part 
# nvme0n1     259:0    0 953.9G  0 disk 
# ├─nvme0n1p1 259:1    0     1G  0 part 
# └─nvme0n1p2 259:2    0 952.9G  0 part
# Print information
file -s /dev/nvme0n1p2
# /dev/nvme0n1p2: LUKS encrypted file, ver 2 [, , sha256] UUID: f3fbeeaa-f3a0-4de1-a9b4-8f755b981122
cryptsetup luksOpen /dev/nvme0n1p2 encrypted_device
# cryptsetup luksOpen /dev/nvme0n1p2 encrypted_device  17.19s user 0.82s system 106% cpu 16.877 total
vgdisplay --short
# "volume" 952.85 GiB [952.85 GiB used / 0    free]
lvs -o lv_name,lv_size -S vg_name=volume
lvchange -ay volume/root
# or just `volume` for every logical volume
mount /dev/volume/root
# Detach the encrypted file system.
umount /dev/volume/root
# List active logical volumes on specified volume group using the following command
lvs -S "lv_active=active && vg_name=volume"
# Deactivate active volume group
lvchange -an volume/root
# or just `volume` for every logical volume
# Remove the encrypted_device mapping and wipe the key from kernel memory
cryptsetup luksClose encrypted_device
```

## Disk Timeout

Symtoms: The disks time out, do not show up in initramfs. 

Check the RAID parameters in BIOS and switch back to AHCI.

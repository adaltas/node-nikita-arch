
# VirtualBox install instructions

This procedure tests nikita-arch inside VirtualBox.

## Manual installation

1. Create a new Virtual Machine "Machine > New"
  1. Name and operating system
     Name: "nikita-arch"
     Type: "Linux"
     Version: "Arch Linux (64-bit)"
  2. Memory size
     For example "10240MB" for 10GB of RAM
  3. Hard disk
     Create a virtual hard disk now
     Choose "VDI" type then "Dynamically allocated"
     Set a size of around 30GB
2. Attach a new disk iso
   From the VM settings, in "Storage", select "Controller IDE" > "Empty" and click on the disk icon next to "Optical drive". Choose the Arch Linux iso file
3. Set the network
   From the VM settings, in "Network", choose "Bridge Adapter"
4. Start the VM
5. Follow the instuctions present in the README to execute `bootstrap`.

## Automated installation

```bash
VM_NAME=nikita-arch
VBoxManage createvm \
  --name $VM_NAME --ostype 'Arch Linux (64-bit)' --register --basefolder `pwd`
# Advanced Programmable Interrupt Controllers (APICs) , required for 64-guest OS
VBoxManage modifyvm $VM_NAME --ioapic on
# RAM memory and vvideo memory
VBoxManage modifyvm $VM_NAME --memory 10240 --vram 128
# Network
VBoxManage modifyvm $VM_NAME --nic1 bridged # not required: --bridgeadapter 'en0: Wi-Fi (Wireless)'
# EFI
VBoxManage modifyvm $VM_NAME --firmware efi # instead of bios
# Create HDD
VBoxManage createhd --filename `pwd`/$VM_NAME/${VM_NAME}_DISK.vdi --size 30000 --format VDI
VBoxManage storagectl $VM_NAME --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach $VM_NAME --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  `pwd`/$VM_NAME/${VM_NAME}_DISK.vdi
# Create CD-ROM
VBoxManage storagectl $VM_NAME --name "IDE Controller" --add ide --controller PIIX4
VBoxManage storageattach $VM_NAME --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium `pwd`/archlinux-2020.04.01-x86_64.iso
VBoxManage modifyvm $VM_NAME --boot1 dvd --boot2 disk --boot3 none --boot4 none 
# Startup
VBoxHeadless --startvm $VM_NAME
# Final information
VBoxManage showvminfo $VM_NAME
```

Once the VM starts, select "Arch Linux archiso x86_64 UEFI CD" from the screen. It will boot arch from the disk. Once you enter the shell prompt, follow the instuctions present in the README to execute `bootstrap`.

## After bootsraping

Next activate EFI from the VM settings. Go in "System", "Motherboard" and check "Activate EFI (special OSes only)". Do not forget to unplug the mounted ISO from virtual box so that the system boots direclty on your 
arch installation. If you encrypted your disk during the process you should be prompted to enter the password you chose for the encryption. Check your `conf/users.yaml` if you have any doubts.

## Important notes regarding disk settings for the bootstrap

To make it work with the disk of VirtualBox, a few tweaks are needed in the source code. They involve dealing with a much smaller disk as well as changing the disk name:

- in `conf/bootstrap`, replace all occurence of `/dev/nvme0n1` with `/dev/sda`
- in `lib/bootstrap/2.disk.coffee`: replace `lvcreate -L 4G volume -n swap` by `lvcreate -L 2G volume -n swap` and `lvcreate -L 100G volume -n root` by `lvcreate -L 18G volume -n root`

Moreover the default settings don't suit the VirtualBox requirements and you need to update them. For that go to `./lib/bootstrap/disk.coffee` and uncomment the lines preceeded by `VirtualBox sizing`.

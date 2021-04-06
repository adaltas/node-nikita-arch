#!/bin/bash
set -e

cd `pwd`/`dirname ${BASH_SOURCE}`/..

VM_NAME=nikita-arch
ARCH_MIRROR=http://archlinux.mirrors.ovh.net/archlinux/iso/latest
ARCH_ISO=`curl -s $ARCH_MIRROR/ | egrep '>.*\.iso<' | sed -E 's/^.*>(.*)<.*/\1/'`
ARCH_ISO_URL=$ARCH_MIRROR/$ARCH_ISO
BASE_DIR=`pwd`/assets
ARCH_ISO_FILE=$BASE_DIR/$ARCH_ISO
echo $ARCH_ISO_URL
echo $ARCH_ISO_FILE
# Download the system ISO file
mkdir -p $BASE_DIR
if [ ! -f $ARCH_ISO_FILE  ]; then
  curl -s $ARCH_ISO_URL -o $ARCH_ISO_FILE
fi
# Create a new VM
OSTYPE='Linux_64' # or Linux26_64, ArchLinux_64
VBoxManage list ostypes | grep $OSTYPE
# VBoxManage list extpacks
# VBoxManage list usbhost
VBoxManage createvm \
  --name $VM_NAME --ostype $OSTYPE --register --basefolder $BASE_DIR
# Advanced Programmable Interrupt Controllers (APICs) , required for 64-guest OS
VBoxManage modifyvm $VM_NAME --ioapic on
# System acceleration
VBoxManage modifyvm $VM_NAME --paravirtprovider kvm
# RAM memory and vvideo memory
VBoxManage modifyvm $VM_NAME --memory 20000 --vram 16
# Processors
VBoxManage modifyvm $VM_NAME --cpuhotplug on
VBoxManage modifyvm $VM_NAME --cpus 4
# Network
VBoxManage modifyvm $VM_NAME --nic1 'Nat'
VBoxManage modifyvm $VM_NAME --natpf1 "guestssh,tcp,,2222,,22"
# VBoxManage modifyvm $VM_NAME --nic1 bridged # not required: --bridgeadapter1 'en0: Wi-Fi (Wireless)'
# EFI
VBoxManage modifyvm $VM_NAME --firmware efi # instead of bios
# Create HDD
VBoxManage createhd --filename $BASE_DIR/${VM_NAME}_DISK.vdi --size 30000 --format VDI
VBoxManage storagectl $VM_NAME --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach $VM_NAME --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  $BASE_DIR/${VM_NAME}_DISK.vdi
# Create CD-ROM
VBoxManage storagectl $VM_NAME --name "IDE Controller" --add ide --controller PIIX4
VBoxManage storageattach $VM_NAME --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium $ARCH_ISO_FILE
VBoxManage modifyvm $VM_NAME --boot1 dvd --boot2 disk --boot3 none --boot4 none
# Device (obtained with diff from a manually created vm with arch on it)
VBoxManage modifyvm $VM_NAME --mouse usbtablet
VBoxManage modifyvm $VM_NAME --usbehci on
VBoxManage modifyvm $VM_NAME --graphicscontroller vboxsvga
# VBoxManage modifyvm $VM_NAME --videocapopts vc_enabled=true,ac_enabled=false,ac_profile=med
# Attempt to remove the screen blinking behavior
# from https://wiki.archlinux.org/index.php/VirtualBox/Install_Arch_Linux_as_a_guest
# Also set the kernel parameter `video=resolution`, but it doesnt not seem to work
# note, `hwinfo --framebuffer` print nothing
VBoxManage setextradata $VM_NAME "CustomVideoMode1" "1360x768x24"
# Startup
VBoxHeadless --startvm $VM_NAME
# Final information
VBoxManage showvminfo $VM_NAME

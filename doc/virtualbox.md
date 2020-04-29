
# VirtualBox install instructions

This procedure test nikita-arch inside VirtualBox.

1. Create a new Virtual Machine "Machine > New"
  1. Name and operating system
     Name: "nikita-arch"
     Type: "Linux"
     Version: "Arch Linux (64-bit)"
  2. Memory size
     For example "10136MB" for 10GB of RAM
  3. Hard disk
     Create a virtual hard disk now
     Choose "VDI" type then "Dynamically allocated"
     Set a size of around 20GB
2. Attach a new disk iso
   rom the VM settings, in "Storage", select "Controller IDE" > "Empty" and choose the Arch Linux iso file
3. Set the network
   From the VM settings, in "Network", choose "Bridge Adapter"
4. Start the VM
5. Follow the instuctions present in the README.

To make it work with the disk of VirtualBox, I had to make a few tweacks in the source code. They involve dealing with a much small disk as well as changing the disk name:

- "conf/bootstrap":
  replace all occurence of '/dev/nvme0n1' with '/dev/sda'
- "lib/bootstrap/2.disk.coffee":
  replace `lvcreate -L 100G volume -n root` by `lvcreate -L 5G volume -n root`

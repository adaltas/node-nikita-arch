
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
./virtualbox.sh
```

Once the VM starts, select "Arch Linux archiso x86_64 UEFI CD" from the screen. It will boot arch from the disk. Once you enter the shell prompt, follow the instuctions present in the README to execute `bootstrap`.

## After bootsraping

Next activate EFI from the VM settings. Go in "System", "Motherboard" and check "Activate EFI (special OSes only)". Do not forget to unplug the mounted ISO from virtual box so that the system boots direclty on your 
arch installation. If you encrypted your disk during the process you should be prompted to enter the password you chose for the encryption. Check your `conf/users.yaml` if you have any doubts.

## Important notes

### Disk settings for the bootstrap

To make it work with the disk of VirtualBox, a few tweaks are needed in the source code. They involve dealing with a much smaller disk as well as changing the disk name:

- in `conf/bootstrap`, replace all occurence of `/dev/nvme0n1` with `/dev/sda`
- in `lib/bootstrap/2.disk.coffee`: replace `lvcreate -L 4G volume -n swap` by `lvcreate -L 2G volume -n swap` and `lvcreate -L 100G volume -n root` by `lvcreate -L 18G volume -n root`

Moreover the default settings don't suit the VirtualBox requirements and you need to update them. For that go to `./lib/bootstrap/disk.coffee` and uncomment the lines preceeded by `VirtualBox sizing`.

### Keyboard debounce in MacOS

If multiple key are printed on keypress, under MacOS settings, remove VirtualBox from "Settings > Security & Privacy > Privacy > Input Monitoring".

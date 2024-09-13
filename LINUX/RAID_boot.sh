#!/bin/bash
sfdisk -d /dev/sda | sfdisk -f /dev/sdb ; dd if=/dev/sda1 of=/dev/sdb1 bs=512 ; sync ; sync ; mdadm --create /dev/md0 --level=1 --raid-disks=2 missing /dev/sdb2 ; mdadm --create /dev/md1 --level=1 --raid-disks=2 missing /dev/sdb3 ; mkfs.vfat /dev/md0 ; mkdir /mnt/1 /mnt/2 ; mount /dev/sda2 /mnt/1/ ; mount /dev/md0 /mnt/2/ ; rsync --progress -av /mnt/1/ /mnt/2/ ; umount /mnt/1 ; umount /mnt/2 ; rmdir /mnt/1 /mnt/2 ; pvcreate /dev/md1 ; vgextend pve /dev/md1 ; pvmove /dev/sda3 /dev/md1 ; vgreduce pve /dev/sda3 ; pvremove /dev/sda3 ; mdadm --examine --scan >> /etc/mdadm/mdadm.conf 


# Don't forget to modify /etc/fstab

echo raid1 >> /etc/modules ; echo raid1 >> /etc/initramfs-tools/modules ; grub-install /dev/sda --recheck ; grub-install /dev/sdb --recheck ; update-grub ; update-initramfs -u
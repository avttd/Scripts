#!/bin/bash

# однострочник для вставки в shell
#sfdisk -d /dev/sda | sfdisk -f /dev/sdb ; dd if=/dev/sda1 of=/dev/sdb1 bs=512 ; sync ; sync ; mdadm --create /dev/md0 --level=1 --raid-disks=2 missing /dev/sdb2 ; mdadm --create /dev/md1 --level=1 --raid-disks=2 missing /dev/sdb3 ; mkfs.vfat /dev/md0 ; mkdir /mnt/1 /mnt/2 ; mount /dev/sda2 /mnt/1/ ; mount /dev/md0 /mnt/2/ ; rsync --progress -av /mnt/1/ /mnt/2/ ; umount /mnt/1 ; umount /mnt/2 ; rmdir /mnt/1 /mnt/2 ; pvcreate /dev/md1 ; vgextend pve /dev/md1 ; pvmove /dev/sda3 /dev/md1 ; vgreduce pve /dev/sda3 ; pvremove /dev/sda3 ; mdadm --examine --scan >> /etc/mdadm/mdadm.conf 

##
## или нормальный читаемый скрипт
##

# 1. Клонируем таблицу разделов с /dev/sda на /dev/sdb
sfdisk -d /dev/sda | sfdisk -f /dev/sdb

# 2. Копируем загрузочный раздел (sda1 → sdb1)
dd if=/dev/sda1 of=/dev/sdb1 bs=512

# 3. Синхронизируем диски
sync
sync

# 4. Создаём RAID1 (degraded) для второго и третьего раздела
mdadm --create /dev/md0 --level=1 --raid-disks=2 missing /dev/sdb2
mdadm --create /dev/md1 --level=1 --raid-disks=2 missing /dev/sdb3

# 5. Форматируем /dev/md0 как FAT (ESP)
mkfs.vfat /dev/md0

# 6. Монтируем разделы
mkdir -p /mnt/1 /mnt/2
mount /dev/sda2 /mnt/1/
mount /dev/md0 /mnt/2/

# 7. Копируем содержимое /boot/efi (или аналогичного)
rsync --progress -av /mnt/1/ /mnt/2/

# 8. Отмонтируем и удалим временные точки монтирования
umount /mnt/1
umount /mnt/2
rmdir /mnt/1 /mnt/2

# 9. Подготавливаем PV, расширяем VG, переносим данные
pvcreate /dev/md1
vgextend pve /dev/md1
pvmove /dev/sda3 /dev/md1
vgreduce pve /dev/sda3
pvremove /dev/sda3

# 10. Добавляем RAID в конфигурацию
mdadm --examine --scan >> /etc/mdadm/mdadm.conf

# Don't forget to modify /etc/fstab

echo raid1 >> /etc/modules ; echo raid1 >> /etc/initramfs-tools/modules ; grub-install /dev/sda --recheck ; grub-install /dev/sdb --recheck ; update-grub ; update-initramfs -u

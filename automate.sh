#!/bin/bash
pacstrap /mnt base base-devel linux linux-firmware linux-headers vim networkmanager	amd-ucode lvm2 grub efibootmgr cryptsetup

genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

arch-chroot /mnt

ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us-acentos" > /etc/vconsole.conf
echo "Arch" > /etc/hostname

mkinitcpio_file="/etc/mkinitcpio.conf"

updated_hook="HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt lvm2 filesystems fsck)"

sed -i "s/^HOOKS=.*/$updated_hook/" "$mkinitcpio_file"

mkinitcpio -P

read -p "cryptsetup container ex: /dev/sda2 :" cryptcontainer
if [[ -z "$cryptcontainer" ]]; then
    echo "Erro: Nenhum caminho fornecido!"
    exit 1
fi
read -p "root location ex: /dev/vg0/root :" rootlocation
if [[ -z "$rootlocation" ]]; then
    echo "Erro: Nenhum caminho fornecido!"
    exit 1
fi

container_uuid=$(blkid -s UUID -o value "$cryptcontainer")

root_uuid=$(blkid -s UUID -o value "$rootlocation")

grub_file="/etc/default/grub"

updated_grub_cmd="GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet cryptdevice=UUID=${container_uuid}:cryptlvm root=UUID=${root_uuid}\""

sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=.*/${updated_grub_cmd}/" "$grub_file"

read -p "efi directory :" efi_dir

grub-install --target=x86_64-efi --efi-directory=${efi_dir} --bootloader-id=GRUB

grub-mkconfig -o /boot/grub/grub.cfg

echo "root password"
passwd

read -p "user name :" username

useradd -m -G wheel -s /bin/bash $username

echo "user password"
passwd $username

echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

systemctl enable NetworkManager
systemctl enable systemd-timesyncd

exit

umount -R /mnt
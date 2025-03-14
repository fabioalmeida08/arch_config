#!/bin/bash

# configuração de timezone e idioma
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us-acentos" > /etc/vconsole.conf
echo "Arch" > /etc/hostname

# configuração mkinitcpio com hooks para criptografia luks
mkinitcpio_file="/etc/mkinitcpio.conf"
updated_hook="HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt lvm2 filesystems fsck)"
sed -i "s/^HOOKS=.*/$updated_hook/" "$mkinitcpio_file"
mkinitcpio -P

# configuração para pegar uuid do container criptografado e root para o grub
while true; do
    lsblk
    read -p "Cryptsetup container (ex.: /dev/<luks-container>): " cryptcontainer
    if [[ -z "$cryptcontainer" ]]; then
        echo "Aviso: Nenhum caminho fornecido. Por favor, tente novamente."
    elif [[ ! -b "$cryptcontainer" ]]; then
        echo "Aviso: $cryptcontainer não é um dispositivo de bloco válido. Tente novamente."
    else
        break  
    fi
done

while true; do
    lsblk
    read -p "Root location (ex.: /dev/vg0/root): " rootlocation
    if [[ -z "$rootlocation" ]]; then
        echo "Aviso: Nenhum caminho fornecido. Por favor, tente novamente."
    elif [[ ! -b "$rootlocation" ]]; then
        echo "Aviso: $rootlocation não é um dispositivo de bloco válido. Tente novamente."
    else
        break 
    fi
done

luks_container_uuid=$(blkid -s UUID -o value "$cryptcontainer")
root_uuid=$(blkid -s UUID -o value "$rootlocation")

grub_file="/etc/default/grub"
updated_grub_cmd="GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet cryptdevice=UUID=${luks_container_uuid}:cryptlvm root=UUID=${root_uuid}\""
sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=.*/${updated_grub_cmd}/" "$grub_file"

read -p "efi directory :" efi_dir
echo "installing grub"
grub-install --target=x86_64-efi --efi-directory=${efi_dir} --bootloader-id=GRUB
echo "creating grub config"
grub-mkconfig -o /boot/grub/grub.cfg

echo "Root password :"
passwd

read -p "Username :" username

useradd -m -G wheel -s /bin/bash $username

echo "User password :"
passwd $username

echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

systemctl enable NetworkManager
systemctl enable systemd-timesyncd

# Arch Linux Installation Guide

This document provides a comprehensive guide for installing and configuring Arch Linux as a professional development environment. The guide follows a methodical approach, starting with basic installation and progressively building a complete system.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Pre-Installation Preparation](#pre-installation-preparation)
3. [Installation Process](#installation-process)
4. [Post-Installation Configuration](#post-installation-configuration)
5. [Development Environment Setup](#development-environment-setup)
6. [System Maintenance](#system-maintenance)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

### Hardware Requirements
- 64-bit x86_64 CPU (Intel or AMD)
- Minimum 4GB RAM (8GB+ recommended for development)
- At least 20GB free disk space (50GB+ recommended)
- Internet connection

### Knowledge Requirements
- Basic command-line familiarity
- Understanding of partitioning and file systems
- Familiarity with text editors (vim, nano)

### Preparation Materials
1. Create a bootable USB drive with Arch Linux ISO
   ```bash
   # On Linux
   dd bs=4M if=path/to/archlinux.iso of=/dev/sdx status=progress oflag=sync
   
   # On macOS
   dd if=path/to/archlinux.iso of=/dev/rdiskX bs=1m
   ```

2. Back up all important data from your current system
3. Document your hardware specifications for reference
4. Download this guide for offline reference

## Pre-Installation Preparation

### 1. Boot from the Arch Linux USB

Boot your computer from the Arch Linux USB drive. You may need to:
- Enter your BIOS/UEFI settings (often F2, F12, Del, or Esc during startup)
- Set the boot priority to the USB drive
- Disable Secure Boot if necessary

### 2. Verify Boot Mode

Check if you're booted in UEFI mode:
```bash
ls /sys/firmware/efi/efivars
```
If this directory exists, you're in UEFI mode. If not, you're in BIOS mode.

### 3. Connect to the Internet

For wired connection:
```bash
# Verify connection
ping -c 3 archlinux.org
```

For wireless connection:
```bash
iwctl
station wlan0 scan
station wlan0 get-networks
station wlan0 connect SSID
# Enter password when prompted
exit

# Verify connection
ping -c 3 archlinux.org
```

### 4. Update System Clock

```bash
timedatectl set-ntp true
```

## Installation Process

### 1. Partition Disks

Identify your disk:
```bash
lsblk
```

For a modern system with UEFI, use gdisk:
```bash
gdisk /dev/nvme0n1  # Replace with your disk identifier
```

Create a GPT partition table with:
- 550MB EFI System Partition (ESP)
- 8GB Swap partition (adjust based on RAM)
- Remainder for root partition

Example partition layout:
```
/dev/nvme0n1p1: 550MB (EFI)
/dev/nvme0n1p2: 8GB (swap)
/dev/nvme0n1p3: Remainder (root)
```

### 2. Format Partitions

Format the EFI partition:
```bash
mkfs.fat -F32 /dev/nvme0n1p1
```

Create and enable swap:
```bash
mkswap /dev/nvme0n1p2
swapon /dev/nvme0n1p2
```

Format the root partition (ext4 or btrfs):
```bash
# For ext4
mkfs.ext4 /dev/nvme0n1p3

# For btrfs (recommended for snapshots and advanced features)
mkfs.btrfs /dev/nvme0n1p3
```

### 3. Mount Partitions

Mount the root partition:
```bash
mount /dev/nvme0n1p3 /mnt
```

Create and mount the ESP:
```bash
mkdir -p /mnt/boot/efi
mount /dev/nvme0n1p1 /mnt/boot/efi
```

### 4. Install Base System

```bash
pacstrap /mnt base base-devel linux linux-firmware linux-headers
```

Additionally, install essential packages:
```bash
pacstrap /mnt vim intel-ucode  # or amd-ucode for AMD CPUs
pacstrap /mnt networkmanager dhcpcd wpa_supplicant
pacstrap /mnt git zsh tmux
```

### 5. Generate Fstab

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

Verify the generated fstab:
```bash
cat /mnt/etc/fstab
```

### 6. Chroot into the System

```bash
arch-chroot /mnt
```

### 7. Configure Basic System Settings

Set the time zone:
```bash
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
hwclock --systohc
```

Configure localization:
```bash
vim /etc/locale.gen  # Uncomment en_US.UTF-8 UTF-8 or your preferred locale
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

Set hostname:
```bash
echo "myhostname" > /etc/hostname
```

Configure hosts file:
```bash
vim /etc/hosts
```
Add the following lines:
```
127.0.0.1    localhost
::1          localhost
127.0.1.1    myhostname.localdomain    myhostname
```

Set root password:
```bash
passwd
```

### 8. Install Bootloader

Install systemd-boot for UEFI systems:
```bash
bootctl install
```

Create a boot entry:
```bash
vim /boot/loader/entries/arch.conf
```
Add the following content:
```
title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img  # or amd-ucode.img for AMD CPUs
initrd  /initramfs-linux.img
options root=UUID=YOUR_ROOT_PARTITION_UUID rw
```

Get your root partition UUID:
```bash
blkid -s UUID -o value /dev/nvme0n1p3
```

Configure the bootloader:
```bash
vim /boot/loader/loader.conf
```
Add the following content:
```
default arch
timeout 3
editor 0
```

### 9. Network Configuration

Enable NetworkManager service:
```bash
systemctl enable NetworkManager
```

### 10. Create User Account

Create a new user and add to wheel group:
```bash
useradd -m -G wheel -s /bin/zsh yourusername
passwd yourusername
```

Configure sudo access:
```bash
EDITOR=vim visudo
```
Uncomment the line:
```
%wheel ALL=(ALL) ALL
```

### 11. Final Steps

Exit chroot, unmount partitions, and reboot:
```bash
exit
umount -R /mnt
reboot
```

## Post-Installation Configuration

### 1. Connect to Network

Connect to wired or wireless network using NetworkManager:
```bash
# List available connections
nmcli device wifi list

# Connect to WiFi
nmcli device wifi connect SSID password YOURPASSWORD
```

### 2. Install Graphics Drivers

For Intel:
```bash
sudo pacman -S xf86-video-intel mesa
```

For NVIDIA:
```bash
sudo pacman -S nvidia nvidia-utils nvidia-settings
```

For AMD:
```bash
sudo pacman -S xf86-video-amdgpu mesa
```

### 3. Install Desktop Environment or Window Manager

For i3 window manager (recommended for productivity):
```bash
sudo pacman -S i3-gaps i3status i3lock dmenu
```

For GNOME (more user-friendly):
```bash
sudo pacman -S gnome gnome-extra
sudo systemctl enable gdm
```

### 4. Install Display Server and Login Manager

For Xorg (traditional):
```bash
sudo pacman -S xorg xorg-xinit
```

For Wayland (modern, for compatible hardware):
```bash
sudo pacman -S wayland sway
```

For a login manager with Xorg:
```bash
sudo pacman -S lightdm lightdm-gtk-greeter
sudo systemctl enable lightdm
```

### 5. Install Common Utilities

```bash
sudo pacman -S firefox alacritty kitty rofi thunar ranger feh picom
sudo pacman -S pulseaudio pavucontrol bluez bluez-utils
sudo pacman -S ttf-dejavu ttf-liberation noto-fonts
```

### 6. Configure AUR Helper

Install Paru (modern AUR helper):
```bash
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```

### 7. Install Development Tools

```bash
sudo pacman -S base-devel cmake clang
sudo pacman -S python python-pip python-virtualenv
sudo pacman -S nodejs npm
sudo pacman -S docker docker-compose
```

Enable Docker service:
```bash
sudo systemctl enable docker
sudo usermod -aG docker yourusername
```

## Development Environment Setup

### 1. Clone Your Dotfiles Repository

```bash
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
```

### 2. Install Enhanced Terminal Environment

```bash
git clone https://github.com/yourusername/enhanced-terminal-environment.git
cd enhanced-terminal-environment
./install.sh
```

### 3. Configure Neovim

```bash
git clone https://github.com/neovim/neovim
cd neovim
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
```

Install your Neovim configuration:
```bash
mkdir -p ~/.config/nvim
cp ~/.dotfiles/nvim/* ~/.config/nvim/
```

### 4. Setup Language-Specific Environments

For Python:
```bash
pip install poetry black flake8 pylint pytest
```

For Node.js:
```bash
npm install -g typescript eslint prettier jest
```

For Ruby:
```bash
sudo pacman -S ruby rubygems
gem install bundler rspec rubocop pry
```

### 5. Set Up Git Configuration

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global core.editor nvim
```

## System Maintenance

### 1. System Updates

Regular system updates:
```bash
sudo pacman -Syu
paru -Syu  # For AUR packages
```

### 2. System Cleanup

Remove unused packages and cached packages:
```bash
sudo pacman -Rns $(pacman -Qtdq)  # Remove orphaned packages
sudo pacman -Sc                   # Clear package cache
```

### 3. Backup Strategy

Install and configure timeshift for system snapshots (with btrfs):
```bash
paru -S timeshift
```

Configure automatic backups of home directory:
```bash
sudo pacman -S rsync
# Set up automated rsync backup script
```

## Troubleshooting

### 1. Boot Issues

If you can't boot into your system:
1. Boot from the Arch installation USB
2. Mount your partitions
   ```bash
   mount /dev/nvme0n1p3 /mnt
   mount /dev/nvme0n1p1 /mnt/boot/efi
   ```
3. Chroot into your system
   ```bash
   arch-chroot /mnt
   ```
4. Fix the issue (reinstall kernel, fix bootloader, etc.)

### 2. Graphics Issues

If X11 or Wayland fails to start:
1. Check for errors in the logs:
   ```bash
   journalctl -xe
   ```
2. Verify graphics drivers:
   ```bash
   lspci -v | grep -A10 VGA
   ```
3. Reinstall or update graphics drivers

### 3. Network Connectivity

If network is down:
1. Check network interfaces:
   ```bash
   ip link
   ```
2. Restart NetworkManager:
   ```bash
   sudo systemctl restart NetworkManager
   ```
3. Manually connect to WiFi with iwctl if needed

### 4. Package Management Issues

If pacman is locked:
```bash
sudo rm /var/lib/pacman/db.lck
```

If a package is corrupted:
```bash
sudo pacman -S --overwrite '*' package-name
```

## Next Steps

After completing this installation guide, proceed to the following:

1. [Month 1 Learning Guide](../learning_guides/month-01-base-system.md) for deepening your understanding of the base system
2. [Desktop Environment Setup](../configuration/desktop/README.md) for customizing your desktop experience
3. [Development Workflow Guide](../configuration/development/README.md) for optimizing your development environment

---

This installation guide is part of the Linux Mastery Journey project, documenting the transition to and mastery of Arch Linux for professional software development.

## Acknowledgements

This guide was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Documentation organization
- Installation step sequencing
- Troubleshooting guidance

Claude was used as a development aid while all final implementation decisions and verification were performed by Joshua Michael Hall.

## Disclaimer

This guide is provided "as is", without warranty of any kind. Always back up important data before system installations or major changes.

# NixOS Installation Guide

This document provides a comprehensive guide for installing and configuring NixOS as a professional development environment. The guide follows a methodical approach, emphasizing the declarative and reproducible nature of NixOS.

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
- Basic understanding of functional programming concepts (helpful but not required)

### Preparation Materials
1. Create a bootable USB drive with NixOS ISO
   ```bash
   # On Linux
   dd bs=4M if=path/to/nixos.iso of=/dev/sdx status=progress oflag=sync
   
   # On macOS
   dd if=path/to/nixos.iso of=/dev/rdiskX bs=1m
   ```

2. Back up all important data from your current system
3. Document your hardware specifications for reference
4. Download this guide for offline reference

## Pre-Installation Preparation

### 1. Boot from the NixOS USB

Boot your computer from the NixOS USB drive. You may need to:
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
ping -c 3 nixos.org
```

For wireless connection:
```bash
# Start wpa_supplicant
sudo systemctl start wpa_supplicant

# Generate configuration file
wpa_passphrase "SSID" "password" > /etc/wpa_supplicant.conf

# Connect to network
sudo wpa_supplicant -B -i wlp3s0 -c /etc/wpa_supplicant.conf

# Get IP address
sudo dhcpcd wlp3s0

# Verify connection
ping -c 3 nixos.org
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

Format the root partition:
```bash
mkfs.ext4 /dev/nvme0n1p3
```

### 3. Mount Partitions

Mount the root partition:
```bash
mount /dev/nvme0n1p3 /mnt
```

Create and mount the ESP:
```bash
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
```

### 4. Generate NixOS Configuration

Generate the initial configuration:
```bash
nixos-generate-config --root /mnt
```

### 5. Edit Configuration

Edit the configuration.nix file:
```bash
nano /mnt/etc/nixos/configuration.nix
```

Basic configuration example:
```nix
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan
      ./hardware-configuration.nix
    ];

  # Use systemd-boot EFI boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone
  time.timeZone = "America/New_York";

  # The global useDHCP flag is deprecated, set explicitly per interface
  networking.useDHCP = false;
  networking.interfaces.enp0s3.useDHCP = true;
  networking.hostName = "nixos-dev";

  # Enable NetworkManager
  networking.networkmanager.enable = true;

  # Select internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable the X11 windowing system
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.windowManager.i3.enable = true;

  # Configure keymap in X11
  services.xserver.layout = "us";

  # Enable sound
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Define user accounts
  users.users.yourusername = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    shell = pkgs.zsh;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    # Basics
    vim
    wget
    git
    curl

    # Development
    gcc
    gnumake
    python3
    nodejs

    # Utilities
    htop
    tmux
    unzip
    firefox

    # Terminal
    alacritty
    zsh
    oh-my-zsh
  ];

  # Enable Docker
  virtualisation.docker.enable = true;

  # Enable OpenSSH
  services.openssh.enable = true;

  # This value determines the NixOS release with which your system is compatible
  system.stateVersion = "23.11";
}
```

### 6. Install NixOS

Install the system:
```bash
nixos-install
```

Set the root password when prompted:
```bash
setting root password...
Enter new UNIX password:
Retype new UNIX password:
```

### 7. Reboot

Reboot into your newly installed NixOS system:
```bash
reboot
```

## Post-Installation Configuration

### 1. First Login

Log in with the root user and password you set during installation.

### 2. Create Your User Account

If you didn't define a user in configuration.nix:
```bash
sudo nix-channel --update
sudo nixos-rebuild switch

# Set password for your user
passwd yourusername
```

### 3. Update System Configuration

Edit the configuration file:
```bash
sudo nano /etc/nixos/configuration.nix
```

After any changes, rebuild the system:
```bash
sudo nixos-rebuild switch
```

### 4. Install Home Manager (Optional but Recommended)

Add the Home Manager channel:
```bash
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
```

Edit configuration.nix to include Home Manager:
```nix
{ config, pkgs, ... }:

{
  imports = [
    # ...
    <home-manager/nixos>
  ];

  # ...

  home-manager.users.yourusername = { pkgs, ... }: {
    home.packages = with pkgs; [
      ripgrep
      fd
      exa
      bat
    ];

    programs.git = {
      enable = true;
      userName = "Your Name";
      userEmail = "your.email@example.com";
    };

    programs.neovim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        vim-nix
        nvim-lspconfig
        telescope-nvim
      ];
    };
  };
}
```

Apply the changes:
```bash
sudo nixos-rebuild switch
```

## Development Environment Setup

### 1. Development Tools Configuration

Create a separate file for development tools:
```bash
sudo nano /etc/nixos/development.nix
```

Add the following content:
```nix
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Languages
    python310
    python310Packages.pip
    python310Packages.virtualenv
    nodejs_20
    ruby_3_2

    # Development Tools
    vscode
    neovim
    git
    gh
    docker
    docker-compose

    # Build Tools
    cmake
    gnumake
    gcc
    clang

    # Debugging Tools
    gdb
    lldb
  ];

  # Enable services
  virtualisation.docker.enable = true;
  programs.git.enable = true;
}
```

Include this file in your main configuration.nix:
```nix
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan
      ./hardware-configuration.nix
      ./development.nix
    ];
  
  # The rest of your configuration...
}
```

Apply the changes:
```bash
sudo nixos-rebuild switch
```

### 2. Language-Specific Development Environments

For Python development using Nix shells:
```bash
# Create a shell.nix file
cat > ~/projects/python-project/shell.nix << EOF
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python310
    python310Packages.pip
    python310Packages.virtualenv
    python310Packages.numpy
    python310Packages.pandas
    python310Packages.pytest
  ];
}
EOF

# Enter the development environment
cd ~/projects/python-project
nix-shell
```

For Node.js development:
```bash
# Create a shell.nix file
cat > ~/projects/node-project/shell.nix << EOF
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    nodejs_20
    nodePackages.npm
    nodePackages.yarn
    nodePackages.typescript
    nodePackages.eslint
  ];
}
EOF

# Enter the development environment
cd ~/projects/node-project
nix-shell
```

## System Maintenance

### 1. System Updates

Update NixOS:
```bash
sudo nix-channel --update
sudo nixos-rebuild switch
```

Update Home Manager:
```bash
nix-channel --update
sudo nixos-rebuild switch
```

### 2. System Cleanup

Remove old generations:
```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Delete old generations
sudo nix-collect-garbage -d
```

Optimize store:
```bash
nix-store --optimize
```

### 3. Backup NixOS Configuration

Create a Git repository for your configuration:
```bash
mkdir -p ~/nixos-config
cd ~/nixos-config
git init

# Copy configuration files
cp /etc/nixos/*.nix .

# Commit changes
git add .
git commit -m "Initial NixOS configuration"
```

## Troubleshooting

### 1. Boot Issues

If you can't boot into your system:
1. Boot from the NixOS installation USB
2. Mount your partitions
   ```bash
   mount /dev/nvme0n1p3 /mnt
   mount /dev/nvme0n1p1 /mnt/boot
   ```
3. Chroot into your system
   ```bash
   nixos-enter --root /mnt
   ```
4. Fix the configuration and rebuild
   ```bash
   nixos-rebuild switch
   ```

### 2. Package Issues

If a package is causing problems:
1. Try rolling back to a previous generation:
   ```bash
   sudo nix-env --rollback --profile /nix/var/nix/profiles/system
   ```

2. Boot into a previous generation from the boot menu

### 3. Configuration Errors

If your configuration has errors:
1. Check the syntax:
   ```bash
   nix-instantiate --parse /etc/nixos/configuration.nix
   ```

2. Test the configuration before applying:
   ```bash
   nixos-rebuild test
   ```

## Next Steps

After completing this installation guide, proceed to the following:

1. [Month 1 Learning Guide](../learning_guides/month-01-base-system.md) for deepening your understanding of the base system
2. [Desktop Environment Setup](../configuration/desktop/README.md) for customizing your desktop experience
3. [Development Workflow Guide](../configuration/development/README.md) for optimizing your development environment

---

This installation guide is part of the Linux Mastery Journey project, documenting the transition to and mastery of NixOS for professional software development.

## Acknowledgements

This guide was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Documentation organization
- Installation step sequencing
- Troubleshooting guidance

Claude was used as a development aid while all final implementation decisions and verification were performed by Joshua Michael Hall.

## Disclaimer

This guide is provided "as is", without warranty of any kind. Always back up important data before system installations or major changes.

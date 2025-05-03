# Linux Troubleshooting Guide

This directory contains comprehensive troubleshooting guides for common issues encountered during installation, configuration, and daily use of Arch Linux and NixOS for professional software development.

## Structure

The troubleshooting documentation is organized by system components:

- [**Boot Issues**](boot.md): Problems with bootloaders, kernels, and startup
- [**Graphics**](graphics.md): Graphics driver problems, display issues, and X11/Wayland configuration
- [**Networking**](networking.md): Connectivity issues, DNS problems, and VPN configuration
- [**Audio**](audio.md): Sound issues and audio device configuration
- [**Package Management**](package-management.md): Problems with pacman, Nix, AUR helpers
- [**Development Environment**](development.md): Issues with language runtimes, editors, and tools

## Troubleshooting Methodology

All guides follow a structured approach to problem-solving:

1. **Identifying Symptoms**: How to accurately diagnose the issue
2. **Gathering Information**: Commands to collect relevant system information
3. **Common Causes**: Typical sources of the problem
4. **Step-by-Step Solutions**: Clear, actionable steps to resolve the issue
5. **Prevention Strategies**: How to avoid the problem in the future

## System Recovery Tools

For serious system issues, these essential recovery tools are covered:

- **Arch Live USB**: Using the installation media for system recovery
- **NixOS Generations**: Rolling back problematic NixOS configurations
- **Chroot Environment**: Accessing and repairing a non-booting system
- **Backup Restoration**: Recovering from system backups
- **Emergency Shell**: Using the emergency shell when normal boot fails

## Logging and Diagnostics

### Key Log Files

Important log files and how to interpret them:

- **Systemd Journal**: `journalctl` for systemd service logs
- **Xorg Logs**: `/var/log/Xorg.0.log` for display server issues
- **Kernel Messages**: `dmesg` for hardware and kernel-related issues
- **Application Logs**: Located in `/var/log/` or `~/.local/share/`

### Diagnostic Commands

Essential diagnostic commands for different subsystems:

#### System Information
```bash
# General system information
inxi -Fxxxz
uname -a
hostnamectl

# Hardware information
lspci -v
lsusb -v
lshw
```

#### Boot Issues
```bash
# Boot information
bootctl status
efibootmgr -v
systemctl status systemd-boot-update

# Kernel and initramfs
journalctl -k
ls -la /boot
```

#### Graphics
```bash
# Display information
xrandr
glxinfo | grep "OpenGL renderer"
lspci -v | grep -A10 VGA
```

#### Networking
```bash
# Network diagnostics
ip addr
ip route
ping -c 3 archlinux.org
dig archlinux.org
nmcli device show
```

#### Package Management
```bash
# Arch Linux
pacman -Qk
pacman -Qs
pacman -Qdt

# NixOS
nix-env --list-generations
nix-store --verify --check-contents
nixos-rebuild --dry-run switch
```

## Common Issues and Quick Fixes

### Boot Problems

- **System doesn't boot after update**: Boot from previous kernel or use a live USB
- **GRUB rescue prompt**: Use rescue commands to find and boot partition
- **Missing initramfs**: Rebuild initramfs from live environment

### Graphics Issues

- **Black screen after driver installation**: Boot with nomodeset and reconfigure
- **Screen tearing**: Enable compositor or driver-specific settings
- **Multi-monitor setup problems**: Use xrandr or wayland-specific tools

### Network Problems

- **No network connection after installation**: Enable and start NetworkManager
- **Intermittent Wi-Fi connectivity**: Check wireless drivers and power management
- **DNS resolution issues**: Configure proper nameservers

### Package Management Issues

- **Broken dependencies**: Follow package database restoration steps
- **Failed upgrades**: Restore from backup or fix partial upgrades
- **AUR build failures**: Check for outdated packages or incompatible dependencies

## Documentation Conventions

For consistency across all troubleshooting guides:

1. **Command Formatting**: All commands appear in code blocks
2. **File Paths**: Always use absolute paths
3. **Placeholders**: Indicated by `<angle brackets>`
4. **Warnings**: Critical actions prefaced with WARNING in bold
5. **Verification**: Each solution includes a verification step
6. **Alternatives**: Multiple solutions provided when available

## Contributing to the Documentation

These troubleshooting guides are maintained as living documents. To contribute:

1. Create an issue describing the problem and solution
2. Follow the established format for consistency
3. Include command output showing both the problem and the solution
4. Submit a pull request with your changes

## Emergency Resources

When these guides don't resolve your issue:

- [Arch Linux Forums](https://bbs.archlinux.org/)
- [NixOS Discourse](https://discourse.nixos.org/)
- [Stack Exchange - Unix & Linux](https://unix.stackexchange.com/)
- IRC: #archlinux, #nixos (on Libera.Chat)

## Acknowledgements

This troubleshooting guide was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Documentation organization
- Troubleshooting methodology
- Common issue identification

Claude was used as a development aid while all final implementation decisions and verification were performed by Joshua Michael Hall.

## Disclaimer

This guide is provided "as is", without warranty of any kind. Always back up important data before making system changes.

---

> "Master the basics. Then practice them every day without fail." - John C. Maxwell

# Graphics Troubleshooting Guide

This document addresses common graphics-related issues encountered when using Arch Linux or NixOS with various desktop environments and window managers. The solutions provided focus on practical troubleshooting steps for professional software development environments.

## Table of Contents

1. [Identifying Your Graphics Hardware](#identifying-your-graphics-hardware)
2. [Driver Installation Issues](#driver-installation-issues)
3. [Display Manager Problems](#display-manager-problems)
4. [Window Manager Issues](#window-manager-issues)
5. [Multi-Monitor Setup](#multi-monitor-setup)
6. [GPU Performance Optimization](#gpu-performance-optimization)
7. [Hardware Acceleration](#hardware-acceleration)
8. [Wayland-Specific Issues](#wayland-specific-issues)

## Identifying Your Graphics Hardware

Before troubleshooting, identify your graphics hardware:

```bash
# List PCI devices with detailed graphics card information
lspci -v | grep -A10 VGA

# Check loaded kernel modules related to graphics
lsmod | grep -i 'nvidia\|nouveau\|amdgpu\|radeon\|intel\|i915'

# Show current display server and renderer information
glxinfo | grep "OpenGL renderer"
```

## Driver Installation Issues

### NVIDIA Drivers

#### Problem: Black screen after NVIDIA driver installation

**Symptoms:**
- System boots to black screen after installing NVIDIA drivers
- Unable to access TTY terminals

**Solutions:**

1. Boot into recovery mode or from installation media and mount your system

2. Check for kernel module conflicts:
   ```bash
   cat /etc/modprobe.d/*.conf | grep -i nouveau
   ```

3. Ensure nouveau is properly blacklisted:
   ```bash
   echo "blacklist nouveau" > /etc/modprobe.d/blacklist-nouveau.conf
   echo "options nouveau modeset=0" >> /etc/modprobe.d/blacklist-nouveau.conf
   ```

4. Rebuild your initramfs:
   ```bash
   # Arch Linux
   mkinitcpio -P
   
   # NixOS
   nixos-rebuild boot
   ```

5. Verify Xorg configuration:
   ```bash
   # Check for issues in the Xorg log
   cat /var/log/Xorg.0.log | grep -i -E "EE|WW"
   ```

#### Problem: Screen tearing with NVIDIA

**Solutions:**

1. Enable ForceCompositionPipeline:
   ```bash
   sudo nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 { ForceCompositionPipeline = On }"
   ```

2. Create persistent configuration:
   ```bash
   # Create or edit 20-nvidia.conf
   sudo nano /etc/X11/xorg.conf.d/20-nvidia.conf
   ```
   
   Add:
   ```
   Section "Device"
       Identifier "NVIDIA Card"
       Driver "nvidia"
       Option "ForceCompositionPipeline" "On"
   EndSection
   ```

### AMD Drivers

#### Problem: System freezes with AMD GPU

**Symptoms:**
- Random system freezes
- Graphics artifacts

**Solutions:**

1. Check for firmware issues:
   ```bash
   dmesg | grep -i amdgpu
   ```

2. Update firmware packages:
   ```bash
   # Arch Linux
   sudo pacman -S linux-firmware
   
   # NixOS
   # Edit configuration.nix
   hardware.enableRedistributableFirmware = true;
   ```

3. Try different kernel parameters:
   ```bash
   # Add to bootloader config
   amdgpu.ppfeaturemask=0xffffffff
   ```

## Display Manager Problems

#### Problem: Display manager fails to start

**Symptoms:**
- System boots to TTY instead of graphical login
- Error messages in display manager logs

**Solutions:**

1. Check the status of the display manager service:
   ```bash
   systemctl status display-manager
   ```

2. Check for permission issues:
   ```bash
   ls -la /tmp/.X11-unix/
   ```

3. Verify Xorg can start properly:
   ```bash
   startx
   ```

4. Check for disk space issues:
   ```bash
   df -h
   ```

5. Check Xauthority file permissions:
   ```bash
   ls -la ~/.Xauthority
   # If needed:
   chown yourusername:yourusername ~/.Xauthority
   ```

## Window Manager Issues

#### Problem: i3/Sway window manager doesn't start properly

**Symptoms:**
- Black or blank screen after login
- Window manager crashes immediately

**Solutions:**

1. Check for syntax errors in the config:
   ```bash
   # For i3
   i3 -C
   
   # For Sway
   sway -C
   ```

2. Start with a default configuration:
   ```bash
   # Backup existing config
   cp ~/.config/i3/config ~/.config/i3/config.bak
   
   # Create default config
   cp /etc/i3/config ~/.config/i3/config
   ```

3. Check system logs:
   ```bash
   journalctl -b -p err
   ```

## Multi-Monitor Setup

#### Problem: External monitors not detected

**Solutions:**

1. List available displays:
   ```bash
   # For Xorg
   xrandr
   
   # For Wayland
   wlr-randr  # For Sway
   ```

2. Force detection of monitors:
   ```bash
   # For Xorg
   xrandr --auto
   ```

3. Manually configure external monitor:
   ```bash
   # Example for setting external monitor to the right of internal
   xrandr --output HDMI-1 --auto --right-of eDP-1
   ```

4. Create a persistent configuration:
   ```bash
   # For Xorg
   sudo nano /etc/X11/xorg.conf.d/10-monitor.conf
   ```
   
   Add:
   ```
   Section "Monitor"
       Identifier "HDMI-1"
       Option "Primary" "true"
       Option "PreferredMode" "1920x1080"
   EndSection
   ```

#### Problem: Wrong resolution on HiDPI displays

**Solutions:**

1. Set appropriate scaling:
   ```bash
   # For Xorg
   xrandr --output eDP-1 --scale 1.5x1.5
   
   # For i3
   # Add to ~/.config/i3/config
   exec --no-startup-id xrandr --output eDP-1 --scale 1.5x1.5
   ```

2. Set DPI in Xresources:
   ```bash
   echo "Xft.dpi: 144" >> ~/.Xresources
   xrdb -merge ~/.Xresources
   ```

## GPU Performance Optimization

#### Problem: Poor GPU performance for development tasks

**Solutions:**

1. Monitor GPU usage and temperature:
   ```bash
   # For NVIDIA
   nvidia-smi
   
   # For AMD
   radeontop
   ```

2. Adjust power management:
   ```bash
   # For NVIDIA
   sudo nvidia-settings -a "[gpu:0]/GPUPowerMizerMode=0"  # 0 for max performance
   
   # For AMD
   echo "high" | sudo tee /sys/class/drm/card0/device/power_dpm_force_performance_level
   ```

3. Set GPU for specific applications:
   ```bash
   # For NVIDIA with Optimus
   __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia application
   ```

## Hardware Acceleration

#### Problem: Video playback or browser is not using hardware acceleration

**Solutions:**

1. Check current hardware acceleration status:
   ```bash
   # For video playback
   mpv --hwdec=auto file.mp4
   
   # For Firefox, check about:support
   ```

2. Install VA-API drivers:
   ```bash
   # For Intel
   sudo pacman -S intel-media-driver libva-intel-driver
   
   # For AMD
   sudo pacman -S libva-mesa-driver mesa-vdpau
   ```

3. Enable hardware acceleration for Firefox:
   ```bash
   # In about:config, set:
   media.ffmpeg.vaapi.enabled = true
   ```

## Wayland-Specific Issues

#### Problem: Applications not working properly under Wayland

**Symptoms:**
- Screen sharing doesn't work
- Some applications display incorrectly

**Solutions:**

1. Force applications to use Wayland:
   ```bash
   # For Firefox
   MOZ_ENABLE_WAYLAND=1 firefox
   ```

2. For screen sharing, install required packages:
   ```bash
   # For Sway
   sudo pacman -S xdg-desktop-portal xdg-desktop-portal-wlr
   ```

3. For Electron apps (like VS Code):
   ```bash
   # Launch with these flags
   app --enable-features=UseOzonePlatform --ozone-platform=wayland
   ```

4. Fall back to Xwayland for incompatible applications:
   ```bash
   # Force an application to use Xwayland
   env GDK_BACKEND=x11 application
   ```

---

## General Troubleshooting Workflow

When encountering graphics issues, follow this systematic approach:

1. **Identify the issue scope**: Is it affecting all applications or just specific ones?
2. **Check system logs**: `journalctl -b | grep -i -E "error|warning"`
3. **Check specific component logs**: Xorg, GPU driver, compositor
4. **Test with minimal configuration**: Disable customizations to isolate issues
5. **Research hardware-specific issues**: Your GPU may have known issues/workarounds
6. **Update drivers and firmware**: Always ensure you're running the latest versions
7. **Test with different kernel versions**: Some issues are kernel-specific

Remember to document the steps you've taken and their outcomes for future reference.

## Acknowledgements

This troubleshooting guide was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Documentation organization
- Troubleshooting methodology
- Common issue identification

Claude was used as a development aid while all final implementation decisions and verification were performed by Joshua Michael Hall.

## Disclaimer

This guide is provided "as is", without warranty of any kind. Always back up important data before making system changes.

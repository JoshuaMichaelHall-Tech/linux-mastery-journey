# Month 2: System Configuration and Package Management

This month builds on your base Arch Linux installation by diving deeper into system configuration and advanced package management. You'll learn how to effectively manage your system, configure services, and handle more complex package management scenarios.

## Time Commitment: ~10 hours/week for 4 weeks

## Learning Objectives

By the end of this month, you should be able to:

1. Configure and manage systemd services
2. Understand and edit key system configuration files
3. Effectively use advanced pacman features
4. Set up and use the Arch User Repository (AUR)
5. Manage logs and troubleshoot basic system issues
6. Apply system-wide customizations

## Week 1: Systemd and Service Management

### Core Learning Activities

1. **Understanding Systemd** (2 hours)
   - Learn about init systems and systemd's role
   - Understand units, targets, and dependencies
   - Study the systemctl command and its uses
   - Explore the systemd architecture and components

2. **Service Management** (3 hours)
   - Enable, disable, start, and stop services
   - View service status and logs
   - Create a basic custom service
   - Configure service options
   - Learn about service dependencies

3. **Boot Process and Targets** (2 hours)
   - Understand the Linux boot process
   - Learn about systemd targets (formerly runlevels)
   - Configure the default target
   - Practice switching between targets
   - Study emergency and rescue targets

4. **Timer Units** (3 hours)
   - Understand systemd timers vs. traditional cron
   - Create and manage timer units
   - Configure recurring tasks
   - Monitor timer execution
   - Implement timer triggers for services

### Practical Exercises

#### Basic Systemd Commands

Practice these essential systemd commands:

```bash
# View system status
systemctl status

# List all running services
systemctl list-units --type=service

# Start, stop, and restart a service
sudo systemctl start sshd.service
sudo systemctl stop sshd.service
sudo systemctl restart sshd.service

# Enable and disable a service
sudo systemctl enable sshd.service
sudo systemctl disable sshd.service

# Check if a service is enabled
systemctl is-enabled sshd.service

# View logs for a specific service
journalctl -u sshd.service

# View boot logs
journalctl -b

# View recent logs
journalctl -n 50
```

#### Create a Custom Service

1. Create a simple service file:

```bash
sudo nano /etc/systemd/system/myservice.service
```

2. Add the following content:

```ini
[Unit]
Description=My Custom Service
After=network.target

[Service]
Type=simple
User=yourusername
WorkingDirectory=/home/yourusername
ExecStart=/home/yourusername/scripts/my-script.sh
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

3. Create the script:

```bash
mkdir -p ~/scripts
nano ~/scripts/my-script.sh
```

Add content:
```bash
#!/bin/bash
while true; do
    echo "Service running at $(date)" >> ~/service-log.txt
    sleep 60
done
```

4. Make the script executable:
```bash
chmod +x ~/scripts/my-script.sh
```

5. Reload systemd, enable and start the service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable myservice.service
sudo systemctl start myservice.service
```

#### Create a Systemd Timer

1. Create a timer file:

```bash
sudo nano /etc/systemd/system/daily-backup.timer
```

2. Add the following content:

```ini
[Unit]
Description=Daily Backup Timer

[Timer]
OnCalendar=*-*-* 02:00:00
Persistent=true
RandomizedDelaySec=300

[Install]
WantedBy=timers.target
```

3. Create the corresponding service file:

```bash
sudo nano /etc/systemd/system/daily-backup.service
```

4. Add the following content:

```ini
[Unit]
Description=Daily Backup Service
After=network.target

[Service]
Type=oneshot
ExecStart=/home/yourusername/scripts/backup.sh
User=yourusername

[Install]
WantedBy=multi-user.target
```

5. Create a simple backup script:

```bash
nano ~/scripts/backup.sh
```

Add content:
```bash
#!/bin/bash
BACKUP_DIR=~/backups/$(date +%Y%m%d)
mkdir -p $BACKUP_DIR
cp -r ~/documents $BACKUP_DIR
echo "Backup completed at $(date)" >> ~/backup-log.txt
```

6. Make the script executable:
```bash
chmod +x ~/scripts/backup.sh
```

7. Enable and start the timer:
```bash
sudo systemctl daemon-reload
sudo systemctl enable daily-backup.timer
sudo systemctl start daily-backup.timer
```

### Resources

- [ArchWiki - Systemd](https://wiki.archlinux.org/title/Systemd)
- [Digital Ocean - Systemd Essentials](https://www.digitalocean.com/community/tutorials/systemd-essentials-working-with-services-units-and-the-journal)
- [Linux Journal - Understanding Systemd](https://www.linuxjournal.com/content/understanding-and-using-systemd)
- [Systemd Unit File Documentation](https://www.freedesktop.org/software/systemd/man/systemd.unit.html)
- [Systemd Timer Documentation](https://www.freedesktop.org/software/systemd/man/systemd.timer.html)

## Week 2: System Configuration Files

### Core Learning Activities

1. **Configuration File Organization** (2 hours)
   - Understand the organization of /etc
   - Learn standard configuration file formats
   - Study version control for configuration files
   - Explore configuration file syntax and conventions
   - Implement backup strategies for configuration files

2. **Network Configuration** (3 hours)
   - Configure wired and wireless networking
   - Set up static IP addresses
   - Configure DNS settings
   - Learn about NetworkManager
   - Implement network profiles for different environments
   - Set up hostnames and /etc/hosts

3. **File System Configuration** (2 hours)
   - Understand /etc/fstab and mount options
   - Configure automounting
   - Explore file system attributes and optimization
   - Learn about disk quotas and access control lists
   - Set up encrypted filesystems

4. **Localization and Time Settings** (2 hours)
   - Configure locale settings
   - Set up time zone and NTP synchronization
   - Configure keyboard layouts
   - Set system-wide language preferences
   - Implement locale-specific formats

5. **Security Configuration** (1 hour)
   - Configure basic firewall rules
   - Set up SSH server securely
   - Understand password policies
   - Implement user and group restrictions
   - Configure file permissions for security

### Practical Exercises

#### Network Configuration with NetworkManager

1. Install NetworkManager if not already installed:

```bash
sudo pacman -S networkmanager
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager
```

2. Configure a static IP connection:

```bash
# Create a new connection
sudo nmcli connection add type ethernet con-name "static-eth" ifname eth0 \
  ipv4.method manual ipv4.addresses 192.168.1.100/24 \
  ipv4.gateway 192.168.1.1 ipv4.dns "8.8.8.8,8.8.4.4"

# Enable the connection
sudo nmcli connection up static-eth
```

3. Configure a wireless connection:

```bash
# Scan for networks
nmcli device wifi list

# Connect to a WiFi network
sudo nmcli device wifi connect SSID-Name password wireless-password

# Create a hidden wireless connection
sudo nmcli connection add type wifi con-name "hidden-wifi" ifname wlan0 \
  ssid HIDDEN-SSID wifi.hidden yes wifi-sec.key-mgmt wpa-psk \
  wifi-sec.psk "wireless-password"
```

#### File System Configuration with fstab

1. Edit the fstab file:

```bash
sudo nano /etc/fstab
```

2. Add a standard entry for a new disk partition:

```
# <file system>  <mount point>  <type>  <options>                  <dump>  <pass>
/dev/sdb1        /data          ext4    defaults,noatime           0       2
```

3. Add an entry for a network share:

```
# NFS share
server:/share    /mnt/nfs       nfs     rw,noatime,rsize=8192,wsize=8192  0   0

# SMB/CIFS share
//server/share    /mnt/smb      cifs    username=user,password=pass,workgroup=workgroup,iocharset=utf8  0  0
```

4. Add an entry for a RAM disk (tmpfs):

```
# RAM disk for temporary files
tmpfs            /tmp           tmpfs   defaults,size=2G,mode=1777   0     0
```

#### Locale and Time Configuration

1. Edit locale.gen:

```bash
sudo nano /etc/locale.gen
```

2. Uncomment desired locales, for example:

```
en_US.UTF-8 UTF-8
en_GB.UTF-8 UTF-8
de_DE.UTF-8 UTF-8
```

3. Generate locales and set the default:

```bash
sudo locale-gen
sudo localectl set-locale LANG=en_US.UTF-8
```

4. Configure the time zone:

```bash
# List available time zones
timedatectl list-timezones | grep America

# Set time zone
sudo timedatectl set-timezone America/New_York

# Enable NTP synchronization
sudo timedatectl set-ntp true
```

#### Security Configuration with SSH

1. Edit the SSH configuration file:

```bash
sudo nano /etc/ssh/sshd_config
```

2. Implement security recommendations:

```
# Disable root login
PermitRootLogin no

# Disable password authentication (use key-based authentication)
PasswordAuthentication no

# Limit SSH access to specific users
AllowUsers yourusername

# Change default port (optional)
Port 2222

# Restrict to SSH Protocol 2
Protocol 2

# Set idle timeout (5 minutes)
ClientAliveInterval 300
ClientAliveCountMax 0
```

3. Reload SSH service:

```bash
sudo systemctl reload sshd
```

### Resources

- [ArchWiki - Network Configuration](https://wiki.archlinux.org/title/Network_configuration)
- [ArchWiki - Fstab](https://wiki.archlinux.org/title/Fstab)
- [Linux Journey - Network Configuration](https://linuxjourney.com/lesson/network-basics)
- [ArchWiki - Security](https://wiki.archlinux.org/title/Security)
- [ArchWiki - NetworkManager](https://wiki.archlinux.org/title/NetworkManager)
- [Linux File System Hierarchy](https://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/)

## Week 3: Advanced Package Management

### Core Learning Activities

1. **Advanced Pacman Usage** (3 hours)
   - Query and search capabilities
   - Package verification and database maintenance
   - Downgrading packages
   - Handle package conflicts
   - Configure pacman hooks
   - Create and use package groups
   - Learn about package signing and verification

2. **Arch User Repository (AUR)** (3 hours)
   - Understand the purpose and risks of the AUR
   - Manually build and install packages from the AUR
   - Set up an AUR helper (yay, paru)
   - Manage AUR packages effectively
   - Learn how to update and maintain AUR packages
   - Troubleshoot common AUR issues

3. **Package Dependency Management** (2 hours)
   - Understand dependency resolution
   - Identify orphaned packages
   - Troubleshoot dependency conflicts
   - Create and use virtual packages
   - Learn about package groups
   - Manage optional dependencies

4. **Creating Simple Packages** (2 hours)
   - Learn the PKGBUILD format
   - Create a basic package
   - Build and install your custom package
   - Share your package on the AUR (optional)
   - Understand package versioning
   - Implement package signing

### Practical Exercises

#### Advanced Pacman Commands

Practice these advanced pacman commands:

```bash
# Update package database and upgrade all packages
sudo pacman -Syu

# Install a specific package
sudo pacman -S package-name

# Search for packages
pacman -Ss search-term

# Get information about a package
pacman -Si package-name

# List installed packages
pacman -Q

# List explicitly installed packages
pacman -Qe

# List packages installed from AUR
pacman -Qm

# Find the package that owns a specific file
pacman -Qo /path/to/file

# List all files owned by a package
pacman -Ql package-name

# Clean the package cache
sudo pacman -Sc

# More aggressive cache cleaning
sudo pacman -Scc

# Remove a package
sudo pacman -R package-name

# Remove a package and its dependencies
sudo pacman -Rs package-name

# Remove a package, its dependencies and all packages that depend on it
sudo pacman -Rsc package-name

# Check for orphaned packages
pacman -Qtdq

# Remove all orphaned packages
sudo pacman -Rns $(pacman -Qtdq)

# Download a package without installing it
pacman -Sw package-name

# Install a local package file
sudo pacman -U /path/to/package.pkg.tar.zst
```

#### Setting Up AUR Access with Paru

1. Install base development tools:

```bash
sudo pacman -S --needed base-devel git
```

2. Clone and build paru:

```bash
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```

3. Use paru to install AUR packages:

```bash
# Search for packages including AUR
paru -Ss search-term

# Install a package (from repos or AUR)
paru -S package-name

# Update all packages including AUR
paru -Syu

# Clean build directory
paru -Sc

# Show AUR packages needing update
paru -Qua
```

#### Creating a Custom Pacman Hook

1. Create a directory for hooks if it doesn't exist:

```bash
sudo mkdir -p /etc/pacman.d/hooks
```

2. Create a hook to update the GRUB configuration after a kernel update:

```bash
sudo nano /etc/pacman.d/hooks/100-grub-update.hook
```

3. Add the following content:

```ini
[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Operation = Remove
Target = linux
Target = linux-lts
Target = linux-zen

[Action]
Description = Updating GRUB configuration...
When = PostTransaction
Exec = /usr/bin/grub-mkconfig -o /boot/grub/grub.cfg
```

4. Create a hook to clean the pacman cache:

```bash
sudo nano /etc/pacman.d/hooks/clean-pacman-cache.hook
```

5. Add the following content:

```ini
[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Package
Target = *

[Action]
Description = Cleaning pacman cache...
When = PostTransaction
Exec = /usr/bin/paccache -r
```

#### Creating a Simple Package with PKGBUILD

1. Create a new directory for your package:

```bash
mkdir -p ~/packages/simple-script
cd ~/packages/simple-script
```

2. Create a PKGBUILD file:

```bash
nano PKGBUILD
```

3. Add the following content:

```bash
# Maintainer: Your Name <your.email@example.com>

pkgname=simple-script
pkgver=1.0.0
pkgrel=1
pkgdesc="A simple script that displays system information"
arch=('any')
url="https://github.com/yourusername/simple-script"
license=('MIT')
depends=('bash')
source=("${pkgname}-${pkgver}.sh")
sha256sums=('SKIP')

package() {
  install -Dm755 "${srcdir}/${pkgname}-${pkgver}.sh" "${pkgdir}/usr/bin/${pkgname}"
}
```

4. Create the script:

```bash
nano simple-script-1.0.0.sh
```

5. Add the following content:

```bash
#!/bin/bash

echo "Simple System Info Script v1.0.0"
echo "--------------------------------"
echo "Hostname: $(hostname)"
echo "Kernel: $(uname -r)"
echo "CPU: $(grep 'model name' /proc/cpuinfo | head -n1 | cut -d: -f2 | sed 's/^ *//')"
echo "Memory: $(free -h | grep Mem | awk '{print $3 " used out of " $2}')"
echo "Disk usage: $(df -h / | tail -n1 | awk '{print $3 " used out of " $2 " (" $5 ")"}')"
echo "Uptime: $(uptime -p)"
```

6. Build and install the package:

```bash
makepkg -si
```

7. Test the installed package:

```bash
simple-script
```

### Resources

- [ArchWiki - Pacman Tips and Tricks](https://wiki.archlinux.org/title/Pacman/Tips_and_tricks)
- [ArchWiki - AUR](https://wiki.archlinux.org/title/Arch_User_Repository)
- [ArchWiki - Creating Packages](https://wiki.archlinux.org/title/Creating_packages)
- [ArchWiki - Pacman Hooks](https://wiki.archlinux.org/title/Pacman#Hooks)
- [AUR Web Interface](https://aur.archlinux.org/)
- [Paru GitHub Repository](https://github.com/Morganamilo/paru)

## Week 4: System Logs, Backup, and Maintenance

### Core Learning Activities

1. **System Logging** (3 hours)
   - Understand journal logs and traditional syslog
   - Query the journal with journalctl
   - Configure log rotation and storage
   - Filter and analyze log messages
   - Set up persistent journal storage
   - Learn about log severity levels and priorities

2. **System Backup Strategies** (3 hours)
   - Explore different backup approaches
   - Set up automated backups using rsync
   - Configure snapshot-based backups
   - Test backup restoration
   - Implement offsite backup solutions
   - Learn about incremental vs. full backups

3. **System Maintenance Procedures** (2 hours)
   - Implement regular maintenance routines
   - Manage disk space and cleanup
   - Monitor system health
   - Automate maintenance tasks
   - Learn about system resource monitoring
   - Implement preventative maintenance

4. **Troubleshooting Methodology** (2 hours)
   - Develop a systematic approach to problems
   - Identify common issue patterns
   - Use logs effectively for troubleshooting
   - Document solutions for future reference
   - Build a personal knowledge base
   - Practice problem isolation techniques

### Practical Exercises

#### Journal Log Management

1. View and filter logs with journalctl:

```bash
# View all logs
journalctl

# View logs for the current boot
journalctl -b

# View kernel messages
journalctl -k

# View logs for a specific service
journalctl -u sshd.service

# View logs for a specific time period
journalctl --since "2023-01-01 00:00:00" --until "2023-01-02 00:00:00"

# View logs with specific priority (0-7, emergency to debug)
journalctl -p err

# Follow logs in real-time
journalctl -f

# View logs for a specific executable
journalctl /usr/bin/firefox

# Show logs related to hardware
journalctl --dmesg
```

2. Configure persistent journal storage:

```bash
# Create directory for persistent storage
sudo mkdir -p /var/log/journal

# Edit journal configuration
sudo nano /etc/systemd/journald.conf
```

Add or modify:
```ini
[Journal]
Storage=persistent
SystemMaxUse=2G
SystemKeepFree=1G
```

3. Apply changes:

```bash
sudo systemctl restart systemd-journald
```

#### Setting Up Automatic Backups with Rsync

1. Install rsync if not already installed:

```bash
sudo pacman -S rsync
```

2. Create a backup script:

```bash
mkdir -p ~/scripts
nano ~/scripts/backup.sh
```

3. Add the following content:

```bash
#!/bin/bash

# Configuration
BACKUP_SRC="$HOME/documents $HOME/projects"
BACKUP_DEST="/mnt/backup"
DATETIME=$(date "+%Y-%m-%d_%H-%M-%S")
BACKUP_LOG="$HOME/logs/backup-$DATETIME.log"

# Create directories if they don't exist
mkdir -p "$BACKUP_DEST"
mkdir -p "$(dirname "$BACKUP_LOG")"

# Start logging
echo "Backup started at $(date)" | tee -a "$BACKUP_LOG"

# Check if destination is available
if [ ! -d "$BACKUP_DEST" ]; then
    echo "Error: Backup destination is not available." | tee -a "$BACKUP_LOG"
    exit 1
fi

# Run backup
echo "Running backup..." | tee -a "$BACKUP_LOG"

for src in $BACKUP_SRC; do
    if [ -d "$src" ] || [ -f "$src" ]; then
        echo "Backing up $src..." | tee -a "$BACKUP_LOG"
        rsync -avh --delete "$src" "$BACKUP_DEST/" >> "$BACKUP_LOG" 2>&1
    else
        echo "Warning: Source $src does not exist, skipping." | tee -a "$BACKUP_LOG"
    fi
done

# Create a dated backup for archiving
echo "Creating dated archive copy..." | tee -a "$BACKUP_LOG"
ARCHIVE_DIR="$BACKUP_DEST/archive/$DATETIME"
mkdir -p "$ARCHIVE_DIR"

for src in $BACKUP_SRC; do
    base_name=$(basename "$src")
    rsync -avh "$BACKUP_DEST/$base_name" "$ARCHIVE_DIR/" >> "$BACKUP_LOG" 2>&1
done

# Keep only the last 5 archive copies
find "$BACKUP_DEST/archive" -maxdepth 1 -type d -name "20*" | sort -r | tail -n +6 | xargs rm -rf

# Finish logging
echo "Backup completed at $(date)" | tee -a "$BACKUP_LOG"
```

4. Make the script executable:

```bash
chmod +x ~/scripts/backup.sh
```

5. Create a systemd service and timer for automated backups:

```bash
sudo nano /etc/systemd/system/backup.service
```

Add:
```ini
[Unit]
Description=Backup Service
After=network.target

[Service]
Type=oneshot
ExecStart=/home/yourusername/scripts/backup.sh
User=yourusername

[Install]
WantedBy=multi-user.target
```

Create a timer:
```bash
sudo nano /etc/systemd/system/backup.timer
```

Add:
```ini
[Unit]
Description=Daily Backup Timer

[Timer]
OnCalendar=*-*-* 01:00:00
Persistent=true
RandomizedDelaySec=900

[Install]
WantedBy=timers.target
```

6. Enable and start the timer:

```bash
sudo systemctl daemon-reload
sudo systemctl enable backup.timer
sudo systemctl start backup.timer
```

#### System Maintenance Script

1. Create a comprehensive system maintenance script:

```bash
nano ~/scripts/system-maintenance.sh
```

2. Add the following content:

```bash
#!/bin/bash

# System Maintenance Script
# Run this script weekly to keep your system in good shape

LOG_FILE="$HOME/logs/maintenance-$(date +%Y-%m-%d).log"
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date +%H:%M:%S)] $1" | tee -a "$LOG_FILE"
}

# Start maintenance
log "Starting system maintenance..."

# Update packages
log "Updating system packages..."
sudo pacman -Syu --noconfirm >> "$LOG_FILE" 2>&1
if command -v paru &> /dev/null; then
    log "Updating AUR packages..."
    paru -Sua --noconfirm >> "$LOG_FILE" 2>&1
fi

# Clean package cache
log "Cleaning package cache..."
sudo paccache -r >> "$LOG_FILE" 2>&1

# Remove orphaned packages
log "Checking for orphaned packages..."
ORPHANS=$(pacman -Qtdq)
if [ -n "$ORPHANS" ]; then
    log "Removing orphaned packages..."
    sudo pacman -Rns $(pacman -Qtdq) --noconfirm >> "$LOG_FILE" 2>&1
else
    log "No orphaned packages found."
fi

# Check disk space
log "Checking disk space..."
df -h | grep -v "tmpfs\|devtmpfs" | tee -a "$LOG_FILE"

# Cleanup user cache
log "Cleaning user cache..."
find ~/.cache -type f -atime +30 -delete
journalctl --vacuum-time=2weeks >> "$LOG_FILE" 2>&1

# Check for failed services
log "Checking for failed services..."
systemctl --failed | tee -a "$LOG_FILE"

# Check for system errors
log "Checking for system errors..."
journalctl -p 3 -xb | tail -n 50 | tee -a "$LOG_FILE"

# Update man database
log "Updating man database..."
sudo mandb >> "$LOG_FILE" 2>&1

# Run updatedb for locate command
log "Updating locate database..."
sudo updatedb >> "$LOG_FILE" 2>&1

# Check for available system updates
log "Checking for available updates..."
checkupdates | tee -a "$LOG_FILE"

# Maintenance complete
log "System maintenance completed."
```

3. Make the script executable:

```bash
chmod +x ~/scripts/system-maintenance.sh
```

4. Set up a weekly cron job:

```bash
crontab -e
```

Add:
```
# Run maintenance script every Sunday at 3:00 AM
0 3 * * 0 /home/yourusername/scripts/system-maintenance.sh
```

#### Troubleshooting Practice

1. Create a troubleshooting template document:

```bash
mkdir -p ~/troubleshooting
nano ~/troubleshooting/template.md
```

2. Add the following content:

```markdown
# Issue Troubleshooting: [Brief Description]

## Date
[Date of issue]

## Symptoms
[Detailed description of the problem]

## System Environment
- OS Version: [output of `uname -a`]
- Kernel: [output of `uname -r`]
- Desktop Environment: [if applicable]
- Related Package Versions: [list relevant packages]

## Diagnostic Steps

1. [Step 1 - Commands run and their output]
2. [Step 2 - Further investigation]
3. [Step 3 - Log files checked]
4. [Step 4 - Additional diagnostics]

## Root Cause
[Identified cause of the issue]

## Solution
[Steps taken to resolve the issue]

## Prevention
[How to prevent this issue in the future]

## References
[Links to documentation, forum posts, or other resources]

## Notes
[Any additional information]
```

3. Start building a troubleshooting portfolio by documenting issues you encounter

### Resources

- [ArchWiki - System Maintenance](https://wiki.archlinux.org/title/System_maintenance)
- [ArchWiki - Rsync](https://wiki.archlinux.org/title/Rsync)
- [Linux Journey - Logging](https://linuxjourney.com/lesson/system-logging)
- [DigitalOcean - Linux Logs Guide](https://www.digitalocean.com/community/tutorials/how-to-view-and-configure-linux-logs-on-ubuntu-and-centos)
- [Journalctl Documentation](https://www.freedesktop.org/software/systemd/man/journalctl.html)
- [Arch Linux Forums - Troubleshooting Guide](https://bbs.archlinux.org/viewtopic.php?id=215640)

## Projects and Exercises

1. **Custom Services Project**
   - Create a service that performs a useful task (e.g., backup, monitoring)
   - Add a timer to run it on a schedule
   - Implement proper logging
   - Create a status check command
   - Document your implementation

2. **Network Configuration Challenge**
   - Configure multiple network profiles
   - Set up a secure SSH server
   - Implement basic firewall rules
   - Test connectivity and security
   - Document your network setup

3. **Package Management Exercise**
   - Create a script to install a personalized set of packages
   - Include both repository and AUR packages
   - Add configuration for the installed packages
   - Document the installation process
   - Test on a fresh installation or virtual machine

4. **System Maintenance Automation**
   - Create a comprehensive maintenance script
   - Include package updates, log cleanup, and backups
   - Add error handling and reporting
   - Set it up with systemd timers
   - Create a status dashboard or report

## Cross-References

- **Previous Month**: [Month 1: Base System Installation and Core Concepts](month-01-base-system.md) - Foundation for this month's advanced configuration
- **Next Month**: [Month 3: Desktop Environment and Workflow Setup](month-03-desktop-setup.md) - Will build on system configuration to create a desktop environment
- **Related Guides**: 
  - [Troubleshooting Guide](/troubleshooting/README.md) - For resolving system issues
  - [Graphics Troubleshooting](/troubleshooting/graphics.md) - For graphics-related problems
  - [Networking Guide](/troubleshooting/networking.md) - For network configuration issues
- **Reference Resources**:
  - [Linux Shortcuts & Commands Reference](linux-shortcuts.md) - For command-line shortcuts
  - [Linux Mastery Journey - Glossary](linux-glossary.md) - For terminology

## Assessment

You should now be able to:

1. Manage and create systemd services and timers
2. Confidently edit and understand key system configuration files
3. Use advanced pacman features effectively
4. Install and manage packages from the AUR
5. Interpret system logs for troubleshooting
6. Implement systematic backup and maintenance procedures

## Next Steps

In Month 3, we'll focus on:
- Setting up a complete desktop environment
- Configuring a window manager (i3, Sway, or Hyprland)
- Customizing the desktop experience
- Optimizing workflows with keyboard shortcuts
- Creating an efficient desktop configuration

## Acknowledgements

This learning guide was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Learning path structure and organization
- Resource recommendations
- Project suggestions

Claude was used as a development aid while all final implementation decisions and verification were performed by Joshua Michael Hall.

## Disclaimer

This guide is provided "as is", without warranty of any kind. Follow all instructions carefully and always make backups before making system changes.

# Month 2: System Configuration and Package Management

This month builds on your base Arch Linux installation by diving deeper into system configuration and advanced package management. You'll learn how to effectively manage your system, configure services, and handle more complex package management scenarios.

## Time Commitment: ~10 hours/week for 4 weeks

## Month 2 Learning Path

```
Week 1                 Week 2                 Week 3                 Week 4
┌─────────────┐       ┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│   Systemd   │       │   System    │       │  Advanced   │       │ System Logs │
│  Services   │──────▶│Configuration│──────▶│   Package   │──────▶│  Backup &   │
│  & Units    │       │    Files    │       │ Management  │       │ Maintenance │
└─────────────┘       └─────────────┘       └─────────────┘       └─────────────┘
```

## Learning Objectives

By the end of this month, you should be able to:

1. Configure and create systemd services and timers from scratch
2. Troubleshoot service failures using journalctl and systemd tools
3. Customize key system configuration files for networking, filesystem, and localization
4. Implement effective network management with NetworkManager
5. Master advanced pacman operations for system maintenance
6. Set up and use the AUR with helper tools like yay
7. Create, build, and install custom packages using PKGBUILD files
8. Implement comprehensive backup and system maintenance strategies
9. Configure logging and monitor system health effectively
10. Automate routine system administration tasks

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

### Systemd Architecture Overview

```
                      ┌─────────────────┐
                      │     systemd     │
                      │   (PID 1/init)  │
                      └─────────────────┘
                               │
         ┌──────────┬──────────┼──────────┬──────────┐
         │          │          │          │          │
         ▼          ▼          ▼          ▼          ▼
┌─────────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
│    Units    │ │ Targets │ │ Scopes  │ │ Slices  │ │ Sockets │
└─────────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘
         │
┌────────┼────────┐
│        │        │
▼        ▼        ▼
┌─────────┐ ┌─────────┐ ┌─────────┐
│Services │ │ Timers  │ │ Paths   │
└─────────┘ └─────────┘ └─────────┘
```

### Example Service Dependency Chain

```
               ┌───────────────┐
               │   network.target   │
               └───────────────┘
                        │
                        │ (After)
                        ▼
               ┌───────────────┐
               │ NetworkManager.service │
               └───────────────┘
                        │
                        │ (Requires/After)
                        ▼
               ┌───────────────┐
               │  dbus.service  │
               └───────────────┘
                 │           │
     (After) ┌───┘           └───┐ (After)
             ▼                   ▼
      ┌───────────────┐   ┌───────────────┐
      │ sshd.service  │   │ httpd.service │
      └───────────────┘   └───────────────┘
```

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

### Complex Service Example: Multi-User Web Application

Here's a more sophisticated example of a systemd service for a web application that requires a database:

```ini
[Unit]
Description=My Web Application
Documentation=https://example.com/docs
After=network.target postgresql.service redis.service
Requires=postgresql.service redis.service

[Service]
Type=notify
User=webuser
Group=webgroup
WorkingDirectory=/opt/mywebapp
ExecStartPre=/opt/mywebapp/bin/check-db.sh
ExecStart=/opt/mywebapp/bin/start-server.sh
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=5s
TimeoutStartSec=30s
TimeoutStopSec=30s
Environment=NODE_ENV=production
Environment=PORT=3000
LimitNOFILE=65536
ProtectSystem=full
ReadWritePaths=/opt/mywebapp/data
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
```

Key features:
- **Dependencies**: Requires database services
- **Security**: Runs as non-root user, protects system files
- **Robustness**: Automatically restarts on failure
- **Performance**: Sets resource limits and timeouts
- **Environment**: Sets production variables

### Service Troubleshooting Decision Tree

```
           ┌──────────────────────┐
           │ Service fails to start │
           └──────────────────────┘
                      │
                      ▼
         ┌─────────────────────────┐
         │ systemctl status service │
         └─────────────────────────┘
                      │
          ┌───────────┴───────────┐
          │                       │
          ▼                       ▼
┌──────────────────┐     ┌──────────────────┐
│  ExecStart error  │     │ Dependency failure │
└──────────────────┘     └──────────────────┘
          │                       │
          ▼                       ▼
┌──────────────────┐     ┌──────────────────┐
│ Check executable │     │ systemctl status  │
│      path        │     │   dependency     │
└──────────────────┘     └──────────────────┘
          │                       │
          ▼                       ▼
┌──────────────────┐     ┌──────────────────┐
│ Check file perms │     │   Fix dependency │
└──────────────────┘     └──────────────────┘
          │                       │
          ▼                       ▼
┌──────────────────┐     ┌──────────────────┐
│  journalctl -u   │     │ systemctl restart │
│    service       │     │     service      │
└──────────────────┘     └──────────────────┘
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

### Key System Configuration Files

```
/etc
├── fstab                # Filesystem mounts
├── hosts                # Host-to-IP mappings
├── locale.conf          # System locale settings
├── pacman.conf          # Pacman configuration
├── pacman.d
│   └── mirrorlist       # Pacman mirror list
├── systemd
│   ├── system           # System service units
│   └── user             # User service units
├── X11
│   └── xorg.conf.d      # X11 config files
└── NetworkManager
    └── system-connections # Network profiles
```

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

### Resources

- [ArchWiki - System Maintenance](https://wiki.archlinux.org/title/System_maintenance)
- [ArchWiki - Rsync](https://wiki.archlinux.org/title/Rsync)
- [Linux Journey - Logging](https://linuxjourney.com/lesson/system-logging)
- [DigitalOcean - Linux Logs Guide](https://www.digitalocean.com/community/tutorials/how-to-view-and-configure-linux-logs-on-ubuntu-and-centos)
- [Journalctl Documentation](https://www.freedesktop.org/software/systemd/man/journalctl.html)
- [Arch Linux Forums - Troubleshooting Guide](https://bbs.archlinux.org/viewtopic.php?id=215640)

## Projects and Exercises

1. **Custom Services Project** [Intermediate]
   - Create a service that performs a useful task (e.g., backup, monitoring)
   - Add a timer to run it on a schedule
   - Implement proper logging
   - Create a status check command
   - Document your implementation

2. **Network Configuration Challenge** [Intermediate]
   - Configure multiple network profiles
   - Set up a secure SSH server
   - Implement basic firewall rules
   - Test connectivity and security
   - Document your network setup

3. **Package Management Exercise** [Beginner-Intermediate]
   - Create a script to install a personalized set of packages
   - Include both repository and AUR packages
   - Add configuration for the installed packages
   - Document the installation process
   - Test on a fresh installation or virtual machine

4. **System Maintenance Automation** [Advanced]
   - Create a comprehensive maintenance script
   - Include package updates, log cleanup, and backups
   - Add error handling and reporting
   - Set it up with systemd timers
   - Create a status dashboard or report

## Real-World Applications

The skills you're learning this month have direct applications in professional IT environments:

- **Systemd Service Management**: Used for deploying web applications, databases, and custom business services
- **Network Configuration**: Essential for setting up servers, workstations, and network security
- **Package Management**: Key to system administration, software deployment, and environment consistency
- **System Maintenance**: Critical for production system reliability, backup strategies, and disaster recovery

By mastering these skills, you're building capabilities that translate directly to roles in:
- DevOps Engineering
- System Administration
- Site Reliability Engineering
- Cloud Infrastructure Management

## Self-Assessment Quiz

Test your knowledge of Month 2 concepts:

1. What command would you use to check if a service is enabled to start at boot?
2. How would you view the last 100 lines of logs for a specific service?
3. What file would you edit to configure filesystem mounts?
4. What is the configuration directive in pacman.conf to enable a custom repository?
5. What command creates a new NetworkManager connection profile?
6. How would you search for a package in the AUR using an AUR helper?
7. What is the main file needed to build a custom package?
8. How would you configure a systemd timer to run daily at 3:00 AM?
9. What command shows all active timers on the system?
10. How would you rotate systemd journal logs to limit disk usage?

## Connections to Your Learning Journey

- **Previous Month**: The command line skills and package management basics from Month 1 are now being expanded with advanced techniques and automation
- **Next Month**: The system configuration knowledge you're gaining will be essential for creating a customized desktop environment in Month 3
- **Future Applications**: The service management concepts covered here will be expanded in Month 6 (Containerization) and Month 10 (Cloud Integration)

Skills from this month that will be particularly important later:
1. Service configuration (for containerization)
2. Network management (for remote development)
3. Package build systems (for development tools)
4. System maintenance strategies (for automation)

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
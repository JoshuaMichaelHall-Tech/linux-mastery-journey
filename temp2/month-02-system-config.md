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

1. **Understanding Systemd** (3 hours)
   - Learn about init systems and systemd's role
   - Understand units, targets, and dependencies
   - Study the systemctl command and its uses

2. **Service Management** (3 hours)
   - Enable, disable, start, and stop services
   - View service status and logs
   - Create a basic custom service
   - Configure service options

3. **Boot Process and Targets** (2 hours)
   - Understand the Linux boot process
   - Learn about systemd targets (formerly runlevels)
   - Configure the default target
   - Practice switching between targets

4. **Timer Units** (2 hours)
   - Understand systemd timers vs. traditional cron
   - Create and manage timer units
   - Configure recurring tasks

### Resources

- [ArchWiki - Systemd](https://wiki.archlinux.org/title/Systemd)
- [Digital Ocean - Systemd Essentials](https://www.digitalocean.com/community/tutorials/systemd-essentials-working-with-services-units-and-the-journal)
- [Linux Journal - Understanding Systemd](https://www.linuxjournal.com/content/understanding-and-using-systemd)

## Week 2: System Configuration Files

### Core Learning Activities

1. **Configuration File Organization** (2 hours)
   - Understand the organization of /etc
   - Learn standard configuration file formats
   - Study version control for configuration files

2. **Network Configuration** (3 hours)
   - Configure wired and wireless networking
   - Set up static IP addresses
   - Configure DNS settings
   - Learn about NetworkManager

3. **File System Configuration** (2 hours)
   - Understand /etc/fstab and mount options
   - Configure automounting
   - Explore file system attributes and optimization

4. **Localization and Time Settings** (2 hours)
   - Configure locale settings
   - Set up time zone and NTP synchronization
   - Configure keyboard layouts
   - Set system-wide language preferences

5. **Security Configuration** (1 hour)
   - Configure basic firewall rules
   - Set up SSH server securely
   - Understand password policies

### Resources

- [ArchWiki - Network Configuration](https://wiki.archlinux.org/title/Network_configuration)
- [ArchWiki - Fstab](https://wiki.archlinux.org/title/Fstab)
- [Linux Journey - Network Configuration](https://linuxjourney.com/lesson/network-basics)
- The Linux Command Line (TLCL) - Chapter 13 (Customizing the Prompt)

## Week 3: Advanced Package Management

### Core Learning Activities

1. **Advanced Pacman Usage** (3 hours)
   - Query and search capabilities
   - Package verification and database maintenance
   - Downgrading packages
   - Handle package conflicts
   - Configure pacman hooks

2. **Arch User Repository (AUR)** (3 hours)
   - Understand the purpose and risks of the AUR
   - Manually build and install packages from the AUR
   - Set up an AUR helper (yay, paru)
   - Manage AUR packages effectively

3. **Package Dependency Management** (2 hours)
   - Understand dependency resolution
   - Identify orphaned packages
   - Troubleshoot dependency conflicts
   - Create and use virtual packages

4. **Creating Simple Packages** (2 hours)
   - Learn the PKGBUILD format
   - Create a basic package
   - Build and install your custom package
   - Share your package on the AUR (optional)

### Resources

- [ArchWiki - Pacman Tips and Tricks](https://wiki.archlinux.org/title/Pacman/Tips_and_tricks)
- [ArchWiki - AUR](https://wiki.archlinux.org/title/Arch_User_Repository)
- [ArchWiki - Creating Packages](https://wiki.archlinux.org/title/Creating_packages)

## Week 4: System Logs, Backup, and Maintenance

### Core Learning Activities

1. **System Logging** (3 hours)
   - Understand journal logs and traditional syslog
   - Query the journal with journalctl
   - Configure log rotation and storage
   - Filter and analyze log messages

2. **System Backup Strategies** (3 hours)
   - Explore different backup approaches
   - Set up automated backups using rsync
   - Configure snapshot-based backups
   - Test backup restoration

3. **System Maintenance Procedures** (2 hours)
   - Implement regular maintenance routines
   - Manage disk space and cleanup
   - Monitor system health
   - Automate maintenance tasks

4. **Troubleshooting Methodology** (2 hours)
   - Develop a systematic approach to problems
   - Identify common issue patterns
   - Use logs effectively for troubleshooting
   - Document solutions for future reference

### Resources

- [ArchWiki - System Maintenance](https://wiki.archlinux.org/title/System_maintenance)
- [ArchWiki - Rsync](https://wiki.archlinux.org/title/Rsync)
- [Linux Journey - Logging](https://linuxjourney.com/lesson/system-logging)
- [DigitalOcean - Linux Logs Guide](https://www.digitalocean.com/community/tutorials/how-to-view-and-configure-linux-logs-on-ubuntu-and-centos)

## Projects and Exercises

1. **Custom Services Project**
   - Create a service that performs a useful task (e.g., backup, monitoring)
   - Add a timer to run it on a schedule
   - Implement proper logging
   - Create a status check command

2. **Network Configuration Challenge**
   - Configure multiple network profiles
   - Set up a secure SSH server
   - Implement basic firewall rules
   - Test connectivity and security

3. **Package Management Exercise**
   - Create a script to install a personalized set of packages
   - Include both repository and AUR packages
   - Add configuration for the installed packages
   - Document the installation process

4. **System Maintenance Automation**
   - Create a comprehensive maintenance script
   - Include package updates, log cleanup, and backups
   - Add error handling and reporting
   - Set it up with systemd timers

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

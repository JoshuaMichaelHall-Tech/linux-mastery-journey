# Month 7: System Maintenance and Performance Tuning

This month focuses on maintaining a healthy Linux system through regular maintenance, performance optimization, and effective monitoring. You'll learn to keep your system running smoothly, identify and resolve performance bottlenecks, implement automated maintenance routines, and establish backup strategies that protect your data.

## Time Commitment: ~10 hours/week for 4 weeks

## Month 7 Learning Path

```
Week 1                 Week 2                 Week 3                 Week 4
┌─────────────┐       ┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│  System     │       │  Performance │       │  Backup     │       │  Log        │
│  Maintenance│──────▶│  Monitoring │──────▶│  Strategies │──────▶│  Management │
│  Basics     │       │  & Analysis │       │  & Recovery │       │  & Automation│
└─────────────┘       └─────────────┘       └─────────────┘       └─────────────┘
```

## Learning Objectives

By the end of this month, you should be able to:

1. Implement a comprehensive system maintenance strategy for both Arch Linux and NixOS
2. Configure and use system monitoring tools to identify performance bottlenecks
3. Analyze system metrics to make data-driven optimization decisions
4. Optimize CPU, memory, disk, and network performance for specific workloads
5. Design and implement effective backup and recovery systems with verification procedures
6. Configure secure and efficient log management with retention policies
7. Create automated maintenance scripts with proper error handling and reporting
8. Develop alerting systems for critical system events
9. Implement disaster recovery procedures and test them effectively
10. Create a long-term maintenance plan with appropriate scheduling

## Week 1: System Maintenance Fundamentals

### Core Learning Activities

1. **Maintenance Strategy Overview** (2 hours)
   - Understand the components requiring maintenance:
     - Package management
     - Filesystem health
     - System logs
     - User accounts
     - Application configurations
   - Learn about maintenance frequency and scheduling
   - Differentiate between proactive and reactive maintenance
   - Create a maintenance checklist for your system:
     ```
     # System Maintenance Checklist
     [ ] System updates
     [ ] Package cache cleanup
     [ ] Disk space check
     [ ] Log rotation check
     [ ] Backup verification
     [ ] User account audit
     [ ] Service status check
     [ ] Security scan
     ```

2. **Package Management Maintenance** (3 hours)
   - Implement safe system update procedures:
     ```bash
     # Arch Linux - System update
     sudo pacman -Syu
     
     # NixOS - System update
     sudo nixos-rebuild switch --upgrade
     ```
   - Manage package caches:
     ```bash
     # Arch Linux - Clear package cache
     sudo pacman -Sc              # Remove unused packages
     sudo pacman -Scc             # Remove all cached packages
     
     # Arch Linux - Keep only the most recent versions
     sudo paccache -r
     
     # NixOS - Clean old generations
     sudo nix-collect-garbage -d
     ```
   - Handle orphaned and unnecessary packages:
     ```bash
     # Arch Linux - Find orphaned packages
     pacman -Qtdq
     
     # Arch Linux - Remove orphaned packages
     sudo pacman -Rns $(pacman -Qtdq)
     
     # NixOS - Optimize the store
     sudo nix-store --optimize
     ```
   - Troubleshoot package conflicts:
     ```bash
     # Arch Linux - Check for package conflicts
     pacman -Qk
     
     # Arch Linux - Re-install a package
     sudo pacman -S --overwrite '*' package-name
     ```
   - Configure pacman hooks for automated tasks:
     ```bash
     # /etc/pacman.d/hooks/clean-cache.hook
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

3. **Filesystem Maintenance** (3 hours)
   - Learn about filesystem health checks:
     ```bash
     # Check ext4 filesystem (run on unmounted filesystems)
     sudo fsck.ext4 -f /dev/sdaX
     
     # Check btrfs filesystem
     sudo btrfs check /dev/sdaX
     
     # Force filesystem check on next boot
     sudo touch /forcefsck
     ```
   - Manage disk space effectively:
     ```bash
     # Find large files
     sudo find / -type f -size +100M -exec ls -lh {} \;
     
     # Find large directories
     du -h --max-depth=1 /path | sort -hr
     
     # Clean journal logs
     sudo journalctl --vacuum-size=100M
     ```
   - Configure TRIM for SSDs:
     ```bash
     # Check if TRIM is enabled
     lsblk --discard
     
     # Enable TRIM timer
     sudo systemctl enable fstrim.timer
     sudo systemctl start fstrim.timer
     
     # Manual TRIM
     sudo fstrim -av
     ```
   - Set up journaling and recovery options:
     ```bash
     # Configure ext4 journal
     sudo tune2fs -O has_journal /dev/sdaX
     
     # Btrfs scrub for data integrity
     sudo btrfs scrub start /
     ```
   - Implement disk cleanup routines:
     ```bash
     # Remove temporary files
     sudo rm -rf /tmp/*
     
     # Clean user cache
     rm -rf ~/.cache/*
     
     # Remove old logs
     sudo find /var/log -type f -name "*.gz" -delete
     ```

4. **User and Permission Audits** (2 hours)
   - Review user accounts and groups:
     ```bash
     # List all users
     cat /etc/passwd
     
     # List all groups
     cat /etc/group
     
     # List users in specific group
     getent group wheel
     ```
   - Audit file permissions:
     ```bash
     # Find files with incorrect permissions
     sudo find /etc -type f -perm /o+w
     
     # Find SUID/SGID files
     sudo find / -type f \( -perm -4000 -o -perm -2000 \) -exec ls -l {} \;
     ```
   - Check for security vulnerabilities:
     ```bash
     # Install and run lynis
     sudo pacman -S lynis
     sudo lynis audit system
     ```
   - Implement principle of least privilege:
     ```bash
     # Review sudo permissions
     sudo visudo
     
     # Restrict access to sensitive files
     sudo chmod 600 /path/to/sensitive/file
     ```

### System Maintenance Approaches Comparison

| Aspect | Proactive Maintenance | Reactive Maintenance |
|--------|----------------------|---------------------|
| Timing | Regular scheduled intervals | After issues occur |
| Resource Usage | Moderate, planned usage | Often high, emergency usage |
| Downtime | Minimal, planned | Potentially extended, unplanned |
| User Impact | Minor, predictable | Often significant, unpredictable |
| Cost Efficiency | Higher long-term efficiency | Lower short-term, higher long-term costs |
| Problem Detection | Early detection of potential issues | Issues already affecting system |
| Documentation | Comprehensive, evolving | Often hastily created during crisis |
| Stress Level | Lower, manageable | Higher, crisis-driven |

### Package Management System Comparison

| Feature | Pacman (Arch) | Nix (NixOS) | APT (Debian/Ubuntu) |
|---------|---------------|-------------|---------------------|
| Package Format | .pkg.tar.zst | .drv (derivation) | .deb |
| Dependency Resolution | Dependency-based | Functional, exact | Dependency-based |
| Rollback Support | Limited (through hooks) | Comprehensive | Limited (through snapshots) |
| Configuration Management | Manual | Declarative | Manual with some tools |
| Atomic Updates | Partial | Yes | Partial |
| Binary vs Source | Binary-focused | Both with preference for binary | Binary-focused |
| Package Building | PKGBUILD (AUR) | Nix expressions | Debian packaging |
| Local Repository | Pacman cache | Nix store | APT cache |

### Filesystem Hierarchy Visual Reference

```
/
├── bin    Essential user commands
├── boot   Boot loader files
├── dev    Device files
├── etc    System configuration
├── home   User home directories
│   └── user
│       ├── .cache        User cache files
│       ├── .config       User configuration
│       └── Documents     User documents
├── lib    Essential shared libraries
├── media  Mount points for removable media
├── mnt    Mount points for filesystems
├── opt    Optional application software
├── proc   Virtual filesystem for processes
├── root   Root user's home directory
├── run    Run-time variable data
├── sbin   Essential system binaries
├── srv    Data for services provided by system
├── sys    Virtual filesystem for kernel
├── tmp    Temporary files
├── usr    Secondary hierarchy
└── var    Variable data
    ├── cache  Application cache data
    ├── lib    Variable state information
    ├── log    Log files and directories
    ├── spool  Spool for tasks awaiting processing
    └── tmp    Temporary files preserved between reboots
```

### Resources

- [ArchWiki - System Maintenance](https://wiki.archlinux.org/title/System_maintenance)
- [ArchWiki - Pacman/Tips and Tricks](https://wiki.archlinux.org/title/Pacman/Tips_and_tricks)
- [Linux Filesystem Hierarchy](https://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/index.html)
- [Linux Security Best Practices](https://www.linux.com/training-tutorials/linux-security-basics/)

## Week 2: System Monitoring and Performance Analysis

### Core Learning Activities

1. **System Monitoring Tools** (3 hours)
   - Configure htop/btop for resource monitoring:
     ```bash
     # Install monitoring tools
     sudo pacman -S htop btop
     
     # Configure htop preferences
     mkdir -p ~/.config/htop
     cp /etc/htop/htoprc ~/.config/htop/
     ```
   - Set up Glances for comprehensive system view:
     ```bash
     # Install Glances
     sudo pacman -S glances
     
     # Run with advanced features
     glances --enable-process-extended --enable-history
     
     # Run in web server mode
     glances -w
     ```
   - Use iotop for disk activity monitoring:
     ```bash
     # Install iotop
     sudo pacman -S iotop
     
     # Monitor disk I/O
     sudo iotop -ao
     ```
   - Implement iftop for network monitoring:
     ```bash
     # Install iftop
     sudo pacman -S iftop
     
     # Monitor network traffic
     sudo iftop -i eth0
     ```
   - Learn about specialized monitoring tools:
     ```bash
     # Install additional tools
     sudo pacman -S sysstat nmon dstat
     
     # Use sysstat tools
     iostat -x 2
     mpstat -P ALL 2
     sar -n DEV 2
     ```

2. **Performance Metrics Collection** (2 hours)
   - Understand key performance indicators:
     - CPU usage and load average
     - Memory usage and swap activity
     - Disk I/O and throughput
     - Network bandwidth and latency
     - Process resource consumption
   - Learn to use vmstat, iostat, and mpstat:
     ```bash
     # Install sysstat package
     sudo pacman -S sysstat
     
     # Memory and swap statistics
     vmstat 2 10
     
     # CPU statistics
     mpstat -P ALL 2 5
     
     # Disk I/O statistics
     iostat -xz 2 5
     ```
   - Configure collectd or similar for metrics collection:
     ```bash
     # Install collectd
     sudo pacman -S collectd
     
     # Edit configuration
     sudo nano /etc/collectd.conf
     
     # Enable and start service
     sudo systemctl enable collectd
     sudo systemctl start collectd
     ```
   - Set up basic visualization with tools like Prometheus and Grafana:
     ```bash
     # Install Prometheus
     sudo pacman -S prometheus
     
     # Install Grafana
     sudo pacman -S grafana
     
     # Enable and start services
     sudo systemctl enable prometheus
     sudo systemctl start prometheus
     sudo systemctl enable grafana
     sudo systemctl start grafana
     ```

3. **CPU and Memory Optimization** (3 hours)
   - Learn about CPU governors and frequency scaling:
     ```bash
     # Install cpupower
     sudo pacman -S cpupower
     
     # Check available governors
     cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
     
     # Set performance governor
     sudo cpupower frequency-set -g performance
     
     # Set powersave governor
     sudo cpupower frequency-set -g powersave
     ```
   - Understand memory management and swap configuration:
     ```bash
     # Check memory information
     free -h
     
     # Set swappiness (lower value = less swapping)
     sudo sysctl vm.swappiness=10
     
     # Make swappiness persistent
     echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.d/99-swappiness.conf
     ```
   - Configure process priorities with nice and ionice:
     ```bash
     # Run process with lower priority
     nice -n 19 command
     
     # Change priority of running process
     renice +10 -p PID
     
     # Set I/O priority
     ionice -c 2 -n 7 command
     ```
   - Manage OOM (Out of Memory) killer settings:
     ```bash
     # Adjust OOM score for a process
     echo -500 > /proc/PID/oom_score_adj
     
     # Protect process from OOM killer
     echo -1000 > /proc/PID/oom_score_adj
     ```
   - Implement memory usage limits:
     ```bash
     # Create systemd slice for limiting memory
     sudo mkdir -p /etc/systemd/system/limit-memory.slice.d/
     sudo nano /etc/systemd/system/limit-memory.slice.d/memory.conf
     
     # Add memory limits
     [Slice]
     MemoryMax=4G
     ```

4. **Disk and I/O Performance** (2 hours)
   - Configure I/O schedulers:
     ```bash
     # Check current I/O scheduler
     cat /sys/block/sda/queue/scheduler
     
     # Temporarily change scheduler
     echo mq-deadline > /sys/block/sda/queue/scheduler
     
     # Change scheduler persistently (kernel parameter)
     sudo nano /etc/default/grub
     # Add to GRUB_CMDLINE_LINUX: elevator=mq-deadline
     sudo grub-mkconfig -o /boot/grub/grub.cfg
     ```
   - Understand and adjust swappiness:
     ```bash
     # Check current swappiness
     cat /proc/sys/vm/swappiness
     
     # Set swappiness temporarily
     sudo sysctl vm.swappiness=10
     
     # Set swappiness permanently
     echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.d/99-swappiness.conf
     ```
   - Implement noatime mount options:
     ```bash
     # Edit fstab
     sudo nano /etc/fstab
     
     # Add noatime option
     UUID=xxx / ext4 defaults,noatime 0 1
     ```
   - Set up disk usage analysis tools:
     ```bash
     # Install tools
     sudo pacman -S ncdu agedu
     
     # Analyze disk usage
     ncdu /
     
     # Analyze by file age
     agedu -s /home/user
     agedu -w
     ```
   - Learn about filesystem optimization techniques:
     ```bash
     # Optimize ext4 filesystem
     sudo e4defrag /home
     
     # Set up btrfs autodefrag
     sudo mount -o remount,autodefrag /
     ```

### Monitoring Tools Comparison

| Tool | Primary Focus | Visual Interface | Resource Usage | Real-time Updates | Remote Monitoring |
|------|--------------|-----------------|---------------|-------------------|-------------------|
| htop | Process management | TUI with color | Very low | Yes | SSH only |
| btop | System resources | Enhanced TUI | Low | Yes | SSH only |
| Glances | Comprehensive monitoring | TUI + Web | Low-medium | Yes | Web interface |
| Prometheus | Metrics collection | None (backend) | Medium | Collection interval | HTTP API |
| Grafana | Visualization | Web dashboard | Medium | Configurable | Web interface |
| collectd | Metrics collection | None (backend) | Low | Collection interval | Network protocol |
| iotop | Disk I/O | TUI | Low | Yes | SSH only |
| iftop | Network traffic | TUI | Low | Yes | SSH only |
| nethogs | Per-process network | TUI | Low | Yes | SSH only |
| sysstat (sar) | Historical stats | Text reports | Very low | Configurable | Files only |

### Performance Bottleneck Decision Tree

```
Start
 │
 ├─ System feels slow
 │   │
 │   ├─ High CPU usage? ──Yes──► Check `htop` for CPU-intensive processes
 │   │   │                        │
 │   │   │                        └─ Process using >80% CPU? ──Yes──► Optimize application or adjust nice level
 │   │   │                                                     │
 │   │   │                                                     └─ No ──► Check if IO-bound with `iotop`
 │   │   │
 │   │   └─ No ──► Check memory usage with `free -h`
 │   │              │
 │   │              └─ Memory usage >90%? ──Yes──► Check swap activity with `vmstat`
 │   │                                      │      │
 │   │                                      │      └─ High swap activity? ──Yes──► Increase RAM or reduce memory usage
 │   │                                      │                             │
 │   │                                      │                             └─ No ──► Adjust vm.swappiness
 │   │                                      │
 │   │                                      └─ No ──► Check disk I/O with `iostat`
 │   │
 │   └─ High disk activity? ──Yes──► Check `iotop` for I/O-intensive processes
 │       │                           │
 │       │                           └─ Process using high I/O? ──Yes──► Optimize application I/O or use ionice
 │       │                                                        │
 │       │                                                        └─ No ──► Check disk health with `smartctl`
 │       │
 │       └─ No ──► Check network with `iftop`
 │                  │
 │                  └─ High network activity? ──Yes──► Identify processes with `nethogs`
 │                                             │
 │                                             └─ No ──► Check for system services with `systemd-analyze`
 │
 └─ Specific application is slow
     │
     ├─ Check application logs
     │
     ├─ Profile application (if source available)
     │
     └─ Monitor resource usage during operation
```

### CPU Governors and Workload Types

| Governor | Power Usage | Performance | Best For |
|----------|-------------|------------|----------|
| performance | High | Maximum | Gaming, video encoding, compilation |
| powersave | Lowest | Minimum | Battery conservation, low demand tasks |
| ondemand | Variable | Dynamic scaling | General desktop use, variable workloads |
| conservative | Variable | Gradual scaling | Battery-powered with moderate demands |
| schedutil | Variable | Kernel scheduler based | Modern workloads, good balance |

### Resources

- [Linux Performance](https://www.brendangregg.com/linuxperf.html)
- [ArchWiki - Improving Performance](https://wiki.archlinux.org/title/Improving_performance)
- [Understanding Linux Load Average](https://www.brendangregg.com/blog/2017-08-08/linux-load-averages.html)
- [Linux Performance Tools Tutorial](https://netflixtechblog.com/linux-performance-analysis-in-60-000-milliseconds-accc10403c55)

## Week 3: Backup Strategies and Disaster Recovery

### Core Learning Activities

1. **Backup Fundamentals** (2 hours)
   - Understand backup types (full, incremental, differential):
     - Full backup: Complete copy of all data
     - Incremental backup: Changes since last backup
     - Differential backup: Changes since last full backup
   - Learn about backup storage options:
     - Local storage (external drives)
     - Network storage (NAS, Samba)
     - Cloud storage (S3, Backblaze)
     - Offsite backups
   - Develop a backup strategy:
     - Critical data identification
     - Backup frequency determination
     - Retention policy planning
     - Verification procedures
   - Create a backup schedule:
     ```
     # Backup Schedule Example
     Daily: Incremental backup of home directory
     Weekly: Full backup of home directory
     Monthly: Full system backup
     Quarterly: Offsite backup copy
     ```

2. **Backup Tools and Configuration** (3 hours)
   - Set up rsync for file synchronization:
     ```bash
     # Install rsync
     sudo pacman -S rsync
     
     # Basic rsync backup
     rsync -avP --delete ~/Documents /mnt/backup/
     
     # Rsync with exclusions
     rsync -avP --delete --exclude='*.tmp' --exclude='.cache/' ~/Documents /mnt/backup/
     ```
   - Configure borg/restic for encrypted backups:
     ```bash
     # Install borg
     sudo pacman -S borg
     
     # Initialize repository
     borg init --encryption=repokey /mnt/backup/borg-repo
     
     # Create backup
     borg create --stats --progress /mnt/backup/borg-repo::backup-{now:%Y-%m-%d} ~/Documents
     
     # List backups
     borg list /mnt/backup/borg-repo
     ```
   - Implement system snapshots with timeshift:
     ```bash
     # Install timeshift (from AUR on Arch)
     yay -S timeshift
     
     # Configure through GUI or CLI
     sudo timeshift --create --comments "Before system update"
     ```
   - Set up automated backup scheduling:
     ```bash
     # Create systemd timer for backups
     sudo nano /etc/systemd/system/backup.service
     
     [Unit]
     Description=Backup Service
     
     [Service]
     Type=oneshot
     ExecStart=/path/to/backup-script.sh
     
     [Install]
     WantedBy=multi-user.target
     ```
     
     ```bash
     # Create timer
     sudo nano /etc/systemd/system/backup.timer
     
     [Unit]
     Description=Run backup daily
     
     [Timer]
     OnCalendar=*-*-* 02:00:00
     Persistent=true
     
     [Install]
     WantedBy=timers.target
     ```
     
     ```bash
     # Enable and start timer
     sudo systemctl enable backup.timer
     sudo systemctl start backup.timer
     ```

3. **System Recovery Preparation** (3 hours)
   - Create a recovery USB drive:
     ```bash
     # Download Arch ISO
     
     # Create bootable USB
     sudo dd bs=4M if=archlinux.iso of=/dev/sdX status=progress oflag=sync
     ```
   - Configure system rescue tools:
     ```bash
     # Install arch-install-scripts (for arch-chroot)
     sudo pacman -S arch-install-scripts
     
     # Create recovery script
     nano ~/recovery.sh
     
     #!/bin/bash
     # Mount partitions
     mount /dev/sdaX /mnt
     mount /dev/sdaY /mnt/boot
     
     # Chroot into system
     arch-chroot /mnt
     ```
   - Learn about chroot environments for repairs:
     ```bash
     # Boot from live USB
     
     # Mount root partition
     mount /dev/sdaX /mnt
     
     # Mount other necessary partitions
     mount /dev/sdaY /mnt/boot
     
     # Bind system directories
     mount --bind /dev /mnt/dev
     mount --bind /proc /mnt/proc
     mount --bind /sys /mnt/sys
     
     # Chroot
     chroot /mnt
     ```
   - Document recovery procedures:
     - Create step-by-step recovery guide
     - Include common repair commands
     - Document system-specific information
     - Store guide in accessible location

4. **Data Integrity and Verification** (2 hours)
   - Implement backup verification procedures:
     ```bash
     # Verify borg backup
     borg check /mnt/backup/borg-repo
     
     # List and verify files in backup
     borg list /mnt/backup/borg-repo::backup-2025-05-01
     
     # Extract and compare selected files
     borg extract --dry-run /mnt/backup/borg-repo::backup-2025-05-01 home/user/important.txt
     ```
   - Set up data integrity checks:
     ```bash
     # Create checksums
     find ~/Documents -type f -exec sha256sum {} \; > documents_checksums.txt
     
     # Verify checksums
     sha256sum -c documents_checksums.txt
     ```
   - Practice recovery scenarios:
     - Simulate file recovery
     - Test complete system restoration
     - Practice partial recovery
     - Verify bootloader recovery
   - Create a disaster recovery plan:
     - Document hardware inventory
     - List recovery priorities
     - Define maximum acceptable downtime
     - Include contact information
     - Store plan securely and accessibly

### Backup Types Comparison

| Feature | Full Backup | Incremental Backup | Differential Backup | System Snapshot |
|---------|------------|-------------------|---------------------|-----------------|
| Storage Space | Highest | Lowest | Medium | Medium-high |
| Backup Time | Longest | Shortest | Medium | Medium |
| Recovery Simplicity | Simple (1 backup) | Complex (multiple backups) | Medium (2 backups) | Simple |
| Recovery Speed | Fast | Slow | Medium | Fast |
| Recovery Dependency | Independent | Depends on full + all incrementals | Depends on latest full | Independent |
| Backup Corruption Risk | Low per backup, affects one backup | Low per backup, but can affect all dependent backups | Low per backup, affects recoveries using the differential | Medium |
| Ideal Frequency | Weekly/Monthly | Daily | Weekly | Before major changes |
| Example Tools | rsync, tar | rdiff-backup, borg | duplicity | timeshift, snapper |

### Backup Tools Feature Matrix

| Feature | rsync | borg | restic | timeshift | rclone |
|---------|-------|------|--------|-----------|--------|
| Encryption | No (requires external) | Yes | Yes | No | Yes (external) |
| Deduplication | No | Yes | Yes | Partial | No |
| Compression | No | Yes | Yes | Optional | No |
| Incremental | Basic | Yes | Yes | Yes | Basic |
| Remote Storage | SSH/rsync | SSH/SFTP | Multiple | No | Multiple cloud services |
| File Versioning | No | Yes | Yes | Yes | No |
| Access Control | Unix permissions | Password/key | Password/key | Unix permissions | Service-dependent |
| License | GPL | BSD | BSD | GPL | MIT |
| Web UI | No | No | No | No | No |

### Disaster Recovery Flowchart

```
System Failure
      │
      ▼
Identify Failure Type
      │
      ├── File Corruption/Deletion
      │   │
      │   ├── Single File ─────► Restore from backup
      │   │                      │
      │   │                      └──► borg extract repo::archive path/to/file
      │   │
      │   └── Multiple Files ───► Restore directory
      │                           │
      │                           └──► borg extract repo::archive path/to/dir
      │
      ├── System Won't Boot
      │   │
      │   ├── Bootloader Issue ─► Boot from USB and repair bootloader
      │   │                        │
      │   │                        └──► arch-chroot and reinstall bootloader
      │   │
      │   └── Filesystem Issue ──► Run fsck from recovery media
      │                             │
      │                             └──► fsck /dev/sdaX
      │
      ├── Package System Broken
      │   │
      │   ├── Broken Dependencies ──► Fix package database
      │   │                            │
      │   │                            └──► pacman -Syyu
      │   │
      │   └── Corrupt Packages ──────► Reinstall affected packages
      │                                 │
      │                                 └──► pacman -S --force package
      │
      └── Complete System Failure
          │
          └── Restore from full backup
              │
              ├── Boot from USB
              │
              ├── Prepare Partitions
              │
              ├── Restore System Backup
              │
              └── Reinstall Bootloader
```

### Resources

- [ArchWiki - System Backup](https://wiki.archlinux.org/title/System_backup)
- [Rsync Documentation](https://rsync.samba.org/documentation.html)
- [Borg Backup Documentation](https://borgbackup.readthedocs.io/)
- [Arch Linux Recovery Guide](https://wiki.archlinux.org/title/General_troubleshooting)

## Week 4: Log Management and Automated Maintenance

### Core Learning Activities

1. **System Logging** (3 hours)
   - Understand systemd journal and traditional syslog:
     ```bash
     # View journal logs
     journalctl
     
     # View kernel messages
     journalctl -k
     
     # View logs for specific unit
     journalctl -u nginx.service
     
     # View logs since boot
     journalctl -b
     ```
   - Configure log rotation and retention:
     ```bash
     # Configure journal size and retention
     sudo nano /etc/systemd/journald.conf
     
     # Set maximum disk usage
     SystemMaxUse=500M
     
     # Restart journal
     sudo systemctl restart systemd-journald
     ```
   - Learn to search and filter logs effectively:
     ```bash
     # Filter by priority
     journalctl -p err
     
     # Filter by time
     journalctl --since "2025-05-01" --until "2025-05-02 12:00"
     
     # Follow new entries
     journalctl -f
     
     # Search for text
     journalctl -g "error"
     ```
   - Set up log analysis tools:
     ```bash
     # Install lnav (log file navigator)
     sudo pacman -S lnav
     
     # View multiple logs
     lnav /var/log/syslog /var/log/auth.log
     
     # Install logwatch
     sudo pacman -S logwatch
     
     # Run logwatch
     sudo logwatch --output stdout --format html --range yesterday
     ```

2. **Alert and Notification Systems** (2 hours)
   - Configure email notifications for critical events:
     ```bash
     # Install mail utilities
     sudo pacman -S msmtp mailx
     
     # Configure msmtp
     nano ~/.msmtprc
     
     # Create alert script
     nano ~/alert.sh
     
     #!/bin/bash
     echo "System alert: $1" | mail -s "System Alert" your-email@example.com
     ```
   - Set up monitoring alerts:
     ```bash
     # Install monit
     sudo pacman -S monit
     
     # Configure monit
     sudo nano /etc/monitrc
     
     # Example configuration
     check system localhost
       if loadavg (5min) > 3 then alert
       if memory usage > 80% then alert
       if cpu usage (user) > 70% for 5 cycles then alert
     
     # Enable and start monit
     sudo systemctl enable monit
     sudo systemctl start monit
     ```
   - Implement custom alerting scripts:
     ```bash
     #!/bin/bash
     # disk-space-alert.sh
     
     THRESHOLD=90
     CURRENT=$(df -h / | grep / | awk '{print $5}' | sed 's/%//')
     
     if [ "$CURRENT" -gt "$THRESHOLD" ]; then
       echo "Disk space alert: ${CURRENT}% used" | mail -s "Disk Space Alert" your-email@example.com
     fi
     ```
   - Create dashboard for system status:
     ```bash
     # Install Netdata for real-time monitoring
     sudo pacman -S netdata
     
     # Enable and start Netdata
     sudo systemctl enable netdata
     sudo systemctl start netdata
     
     # Access dashboard at http://localhost:19999
     ```

3. **Automated Maintenance Scripts** (3 hours)
   - Create comprehensive maintenance scripts:
     ```bash
     #!/bin/bash
     # system-maintenance.sh
     
     # Update system
     echo "Updating system packages..."
     sudo pacman -Syu --noconfirm
     
     # Clean package cache
     echo "Cleaning package cache..."
     sudo paccache -r
     
     # Remove orphaned packages
     echo "Removing orphaned packages..."
     sudo pacman -Rns $(pacman -Qtdq) --noconfirm
     
     # Clean journal logs
     echo "Cleaning journal logs..."
     sudo journalctl --vacuum-size=100M
     
     # Check disk space
     echo "Checking disk space..."
     df -h
     
     # Check for failed services
     echo "Checking failed services..."
     systemctl --failed
     
     # Create backup
     echo "Creating backup..."
     borg create --stats --progress /mnt/backup/borg-repo::backup-{now:%Y-%m-%d} ~/Documents
     
     echo "Maintenance completed!"
     ```
   - Configure systemd timers or cron jobs:
     ```bash
     # Create systemd timer
     sudo nano /etc/systemd/system/maintenance.service
     
     [Unit]
     Description=System Maintenance
     
     [Service]
     Type=oneshot
     ExecStart=/path/to/system-maintenance.sh
     
     [Install]
     WantedBy=multi-user.target
     ```
     
     ```bash
     # Create systemd timer
     sudo nano /etc/systemd/system/maintenance.timer
     
     [Unit]
     Description=Run maintenance weekly
     
     [Timer]
     OnCalendar=Sun 02:00:00
     Persistent=true
     
     [Install]
     WantedBy=timers.target
     ```
     
     ```bash
     # Enable and start timer
     sudo systemctl enable maintenance.timer
     sudo systemctl start maintenance.timer
     ```
   - Implement error handling and reporting:
     ```bash
     #!/bin/bash
     # Enhanced error handling
     
     # Log file
     LOG_FILE="/var/log/maintenance.log"
     
     # Error handling function
     handle_error() {
       echo "[ERROR] $(date +"%Y-%m-%d %H:%M:%S"): $1" | tee -a "$LOG_FILE"
       echo "[ERROR] $(date +"%Y-%m-%d %H:%M:%S"): $1" | mail -s "Maintenance Error" your-email@example.com
     }
     
     # Run command with error checking
     run_cmd() {
       echo "[INFO] Running: $1" | tee -a "$LOG_FILE"
       eval "$1"
       if [ $? -ne 0 ]; then
         handle_error "Command failed: $1"
         return 1
       fi
       return 0
     }
     
     # Example usage
     run_cmd "sudo pacman -Syu --noconfirm" || exit 1
     ```
   - Set up logging for automated tasks:
     ```bash
     #!/bin/bash
     # Logging setup
     
     # Create log directory
     LOG_DIR="/var/log/maintenance"
     mkdir -p "$LOG_DIR"
     
     # Log file with timestamp
     LOG_FILE="$LOG_DIR/maintenance-$(date +%Y%m%d-%H%M%S).log"
     
     # Redirect all output to log
     exec > >(tee -a "$LOG_FILE") 2>&1
     
     echo "Starting maintenance at $(date)"
     
     # Run maintenance tasks
     # ...
     
     echo "Maintenance completed at $(date)"
     ```

4. **Long-term Maintenance Planning** (2 hours)
   - Create a annual maintenance schedule:
     ```
     # Annual Maintenance Schedule
     
     Weekly:
     - System updates
     - Package cache cleanup
     - Disk space check
     - Incremental backups
     
     Monthly:
     - Full system backup
     - User account audit
     - Security scan
     - Service review
     
     Quarterly:
     - Hardware diagnostics
     - Filesystem check
     - Performance assessment
     - Backup verification
     
     Annually:
     - Complete system audit
     - Hardware inventory update
     - Recovery plan testing
     - Maintenance strategy review
     ```
   - Plan for major system upgrades:
     - Research new release features
     - Test upgrades in virtual machine
     - Create pre-upgrade backup
     - Schedule maintenance window
     - Document upgrade procedures
   - Document maintenance procedures:
     - Create detailed guides for each task
     - Include troubleshooting steps
     - Document expected outcomes
     - Maintain change log
   - Implement policy for system lifecycle:
     - Define system lifecycle stages
     - Set upgrade criteria
     - Establish end-of-support deadlines
     - Plan migration strategies
     - Document retirement procedures

### Log Management Tools Comparison

| Tool | Format | Rotation | Search | Analysis | Visualization | Storage Requirements | Real-time Access |
|------|--------|----------|--------|----------|---------------|---------------------|------------------|
| systemd-journal | Binary | Built-in | Good | Basic | None | Medium | Yes |
| rsyslog | Text | Via logrotate | Basic | No | No | Low-Medium | Yes |
| syslog-ng | Text | Via logrotate | Basic | Limited | No | Low-Medium | Yes |
| lnav | Text | Read-only | Excellent | Good | Text-based | None (reader) | Yes |
| ELK Stack | Database | Configurable | Excellent | Excellent | Web UI | High | Yes |
| Graylog | Database | Configurable | Excellent | Good | Web UI | High | Yes |
| Logwatch | Text | No | No | Summary reports | Text reports | Low | No |

### Automation Tool Scheduling Comparison

| Feature | Cron | Systemd Timers | Anacron | At |
|---------|------|---------------|---------|---|
| Syntax | Cron expression | Calendar/Monotonic | Similar to cron | One-time execution |
| Missed Executions | Ignored | Configurable | Runs when system available | Runs next boot |
| Minimum Interval | 1 minute | 1 microsecond | 1 day | N/A |
| Dependencies | No | Yes | No | No |
| Logging | syslog/email | journald | syslog | syslog |
| System Integration | Separate | Native to systemd | Separate | Separate |
| Random Delay | No | Yes | No | No |
| Persistent Timestamp | No | Optional | Yes | N/A |

### Shell Script Error Handling Patterns

```bash
# Pattern 1: Basic error checking
command || { echo "Command failed"; exit 1; }

# Pattern 2: Error function
error() {
  echo "[ERROR] $1" >&2
  exit 1
}
command || error "Command failed"

# Pattern 3: Trap for cleanup
cleanup() {
  # Cleanup actions
  rm -f "$TEMP_FILE"
}
trap cleanup EXIT
trap 'error "Script interrupted"' INT TERM

# Pattern 4: Set error options
set -e  # Exit immediately on error
set -u  # Treat unset variables as errors
set -o pipefail  # Exit if any command in pipeline fails

# Pattern 5: Comprehensive logging and error handling
LOG_FILE="/var/log/script.log"
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }
error() { log "ERROR: $*" >&2; exit 1; }
run_cmd() {
  log "Running: $*"
  "$@" || error "Command failed: $*"
}
run_cmd pacman -Syu
```

### Resources

- [ArchWiki - Systemd/Journal](https://wiki.archlinux.org/title/Systemd/Journal)
- [Linux System Administration Basics](https://www.linode.com/docs/guides/linux-system-administration-basics/)
- [Automated Tasks with systemd Timers](https://wiki.archlinux.org/title/Systemd/Timers)
- [Shell Scripting for System Administration](https://tldp.org/LDP/abs/html/)

## Real-World Applications

The system maintenance and performance tuning skills you're learning this month have direct applications in:

1. **DevOps and Site Reliability Engineering (SRE)**
   - Implementing automated maintenance pipelines
   - Building self-healing systems with monitoring and alerting
   - Managing system resources for optimal application performance

2. **System Administration**
   - Creating enterprise-wide backup strategies
   - Ensuring high availability of critical services
   - Implementing disaster recovery plans
   - Configuring centralized log management

3. **Cloud Infrastructure Management**
   - Optimizing cloud resource allocation and costs
   - Implementing automated scaling based on performance metrics
   - Setting up multi-region data backup and redundancy
   - Configuring log aggregation across distributed systems

4. **Software Development**
   - Creating robust CI/CD pipelines with proper error handling
   - Developing performance optimization strategies for applications
   - Implementing automated testing with performance benchmarks
   - Building self-documenting system maintenance scripts

5. **Security Operations**
   - Implementing secure backup strategies with encryption
   - Configuring log monitoring for security incidents
   - Setting up integrity verification systems
   - Creating automated security scanning and remediation

## Projects and Exercises

1. **Comprehensive Maintenance Script** [Intermediate] (6-8 hours)
   - Create a complete system maintenance script that includes:
     - System updates and cleanup
     - Disk space management
     - Log rotation
     - Temporary file cleanup
     - Backup creation
     - Security checks
   - Implement error handling and reporting
   - Set up email notifications for issues
   - Configure automatic execution with systemd timers
   - Document the script's functionality

2. **System Monitoring Dashboard** [Advanced] (10-12 hours)
   - Set up a monitoring system using Prometheus and Grafana:
     - Configure metrics collection for CPU, memory, disk, and network
     - Set up node_exporter for system metrics
     - Configure Prometheus for data collection
     - Create Grafana dashboards for visualization
   - Implement alerting for critical thresholds
   - Set up persistent storage for metrics
   - Document the system and its configuration

3. **Automated Backup Solution** [Intermediate] (6-8 hours)
   - Configure an encrypted backup system with borg or restic:
     - Set up local and remote repositories
     - Configure encryption and compression
     - Create include/exclude lists
     - Set backup retention policies
   - Implement scheduled incremental backups
   - Set up backup verification and integrity checks
   - Create disaster recovery documentation
   - Test the recovery process

4. **Performance Optimization Project** [Advanced] (8-10 hours)
   - Analyze your system's performance with appropriate tools:
     - Identify CPU, memory, disk, and network bottlenecks
     - Benchmark baseline performance
     - Document resource usage patterns
   - Implement improvements for at least three bottlenecks
   - Document the changes and performance improvements
   - Create a tuning guide specific to your workloads
   - Set up ongoing performance monitoring

## Self-Assessment Quiz

Test your knowledge of the concepts covered this month:

1. What is the primary difference between proactive and reactive maintenance approaches?
2. How would you clear the package cache in Arch Linux while retaining the most recent version of each package?
3. What systemd command would you use to check for failed services on your system?
4. What is swappiness in Linux, and how does adjusting it affect system performance?
5. Name three key metrics you should monitor to evaluate system performance.
6. What is the difference between incremental and differential backups?
7. Which filesystem option can improve SSD performance and longevity?
8. How can you effectively search the systemd journal for error messages that occurred in the last hour?
9. What is the purpose of the OOM killer, and how can you adjust its behavior for critical processes?
10. Explain the advantages of using systemd timers over traditional cron jobs for scheduling maintenance tasks.

## Connections to Your Learning Journey

- **Previous Month**: In Month 6, you learned about containerization and virtual environments. These skills serve as a foundation for isolating applications and creating reproducible environments, which complements the maintenance and performance tuning knowledge in this month.

- **Next Month**: In Month 8, you'll focus on networking and security fundamentals. The maintenance and monitoring skills from this month will help you manage and secure your network configurations more effectively.

- **Future Applications**: The performance tuning, monitoring, and automation skills from this month will be essential when building and maintaining cloud-integrated systems in Month 10 and for your career portfolio development in Month 12.

## Assessment

You should now be able to:

1. Implement a proactive system maintenance strategy
2. Monitor and analyze system performance effectively
3. Configure optimized system settings for your workloads
4. Set up and manage comprehensive backup solutions
5. Analyze logs and troubleshoot system issues
6. Automate routine maintenance tasks
7. Create effective error handling in maintenance scripts
8. Develop and test disaster recovery procedures
9. Implement alerting for critical system events
10. Plan and document long-term system maintenance

## Next Steps

In [Month 8: Networking and Security Fundamentals](month-08-networking.md), we'll focus on:
- Advanced networking configuration
- Security hardening for Linux
- VPN and SSH tunneling
- Firewall configuration
- Network monitoring and troubleshooting

## Acknowledgements

This learning guide was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Learning path structure and organization
- Resource recommendations
- Project suggestions

Claude was used as a development aid while all final implementation decisions and verification were performed by Joshua Michael Hall.

## Disclaimer

This guide is provided "as is", without warranty of any kind. Follow all instructions carefully and always make backups before making system changes.

---

> "Master the basics. Then practice them every day without fail." - John C. Maxwell
# Month 2: System Configuration and Package Management - Exercises

This document contains practical exercises and projects to accompany the Month 2 learning guide. Complete these exercises to solidify your understanding of system configuration, systemd, package management, and system maintenance.

## Exercise 1: Systemd Service Management

### Basic Systemd Exploration

1. **List and analyze running services**:
   ```bash
   # List all running services
   systemctl list-units --type=service --state=running
   
   # Identify the 5 services that started most recently
   journalctl -b -u "*.service" | grep "Started" | tail -n 5
   
   # Find services that failed to start
   systemctl --failed
   ```

2. **Analyze service dependencies**:
   ```bash
   # Choose an important service and examine its dependencies
   systemctl list-dependencies NetworkManager.service
   
   # Reverse dependencies (what depends on this service)
   systemctl list-dependencies --reverse NetworkManager.service
   ```

3. **Investigate service logs**:
   ```bash
   # View logs for a specific service
   journalctl -u sshd.service -n 50
   
   # View logs for service startups
   journalctl -b -u "*.service" | grep "Starting"
   
   # View logs for a service with filtering
   journalctl -u NetworkManager.service --since today | grep -i "error\|warn\|fail"
   ```

### Create a Custom Service

1. **Create a system monitoring service**:

   Create a script that collects system information:
   ```bash
   mkdir -p ~/scripts
   nano ~/scripts/system-monitor.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   
   LOG_DIR="/var/log/system-monitor"
   LOG_FILE="$LOG_DIR/$(date +%Y-%m-%d).log"
   
   # Create log directory if it doesn't exist
   sudo mkdir -p "$LOG_DIR"
   sudo chown $USER:$USER "$LOG_DIR"
   
   # Log timestamp
   echo "=== System Status at $(date) ===" >> "$LOG_FILE"
   
   # Log CPU usage
   echo "--- CPU Usage ---" >> "$LOG_FILE"
   top -bn1 | head -n 12 >> "$LOG_FILE"
   
   # Log memory usage
   echo -e "\n--- Memory Usage ---" >> "$LOG_FILE"
   free -h >> "$LOG_FILE"
   
   # Log disk usage
   echo -e "\n--- Disk Usage ---" >> "$LOG_FILE"
   df -h | grep -v tmpfs >> "$LOG_FILE"
   
   # Log active connections
   echo -e "\n--- Network Connections ---" >> "$LOG_FILE"
   ss -tuln >> "$LOG_FILE"
   
   # Log recent auth attempts
   echo -e "\n--- Recent Auth Attempts ---" >> "$LOG_FILE"
   grep "Failed\|Accepted" /var/log/auth.log 2>/dev/null | tail -n 10 >> "$LOG_FILE"
   
   echo -e "\n" >> "$LOG_FILE"
   ```

   Make the script executable:
   ```bash
   chmod +x ~/scripts/system-monitor.sh
   ```

2. **Create a systemd service file**:
   ```bash
   sudo nano /etc/systemd/system/system-monitor.service
   ```

   Add the following content:
   ```ini
   [Unit]
   Description=System Monitoring Service
   After=network.target
   
   [Service]
   Type=oneshot
   ExecStart=/home/yourusername/scripts/system-monitor.sh
   User=yourusername
   
   [Install]
   WantedBy=multi-user.target
   ```

   Replace "yourusername" with your actual username.

3. **Create a systemd timer**:
   ```bash
   sudo nano /etc/systemd/system/system-monitor.timer
   ```

   Add the following content:
   ```ini
   [Unit]
   Description=Run System Monitoring Service
   
   [Timer]
   OnBootSec=5min
   OnUnitActiveSec=15min
   AccuracySec=1s
   
   [Install]
   WantedBy=timers.target
   ```

4. **Enable and start the timer**:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable system-monitor.timer
   sudo systemctl start system-monitor.timer
   ```

5. **Verify the timer and service**:
   ```bash
   # Check timer status
   systemctl status system-monitor.timer
   
   # List all timers
   systemctl list-timers
   
   # Manually run the service once
   sudo systemctl start system-monitor.service
   
   # Check service status
   systemctl status system-monitor.service
   
   # View the log file
   less /var/log/system-monitor/$(date +%Y-%m-%d).log
   ```

## Exercise 2: System Configuration Files

### Network Configuration

1. **Analyze your current network configuration**:
   ```bash
   # Network interface details
   ip addr show
   
   # Routing table
   ip route show
   
   # DNS configuration
   cat /etc/resolv.conf
   
   # Active connections
   ss -tuln
   ```

2. **Configure a static IP with NetworkManager**:
   ```bash
   # Show current connections
   nmcli connection show
   
   # Create a new connection (replace eth0 with your interface name)
   sudo nmcli connection add type ethernet con-name "static-home" ifname eth0 \
     ipv4.method manual ipv4.addresses "192.168.1.100/24" \
     ipv4.gateway "192.168.1.1" ipv4.dns "1.1.1.1,8.8.8.8"
   
   # Enable the connection
   sudo nmcli connection up static-home
   ```

3. **Create a backup connection for failover**:
   ```bash
   # Create a secondary connection with lower priority
   sudo nmcli connection add type ethernet con-name "backup-home" ifname eth0 \
     ipv4.method manual ipv4.addresses "192.168.1.101/24" \
     ipv4.gateway "192.168.1.1" ipv4.dns "8.8.8.8,8.8.4.4" \
     connection.autoconnect-priority 50
   ```

4. **Create a NetworkManager connection script**:
   ```bash
   nano ~/scripts/network-profile.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   
   # Network Profile Switcher
   # Usage: ./network-profile.sh [home|work|public]
   
   PROFILE=$1
   
   if [ -z "$PROFILE" ]; then
       echo "Usage: $0 [home|work|public]"
       exit 1
   fi
   
   case "$PROFILE" in
       home)
           echo "Switching to home network profile..."
           sudo nmcli connection down backup-home 2>/dev/null
           sudo nmcli connection down work 2>/dev/null
           sudo nmcli connection up static-home
           ;;
       work)
           echo "Switching to work network profile..."
           sudo nmcli connection down static-home 2>/dev/null
           sudo nmcli connection down backup-home 2>/dev/null
           sudo nmcli connection up work 2>/dev/null || \
             sudo nmcli connection add type ethernet con-name "work" ifname eth0 \
             ipv4.method manual ipv4.addresses "10.0.0.100/24" \
             ipv4.gateway "10.0.0.1" ipv4.dns "10.0.0.2,1.1.1.1" && \
             sudo nmcli connection up work
           ;;
       public)
           echo "Switching to public network profile (DHCP)..."
           sudo nmcli connection down static-home 2>/dev/null
           sudo nmcli connection down backup-home 2>/dev/null
           sudo nmcli connection down work 2>/dev/null
           sudo nmcli connection up public 2>/dev/null || \
             sudo nmcli connection add type ethernet con-name "public" ifname eth0 \
             ipv4.method auto connection.autoconnect-priority 10 \
             ipv6.method auto && \
             sudo nmcli connection up public
           ;;
       *)
           echo "Unknown profile: $PROFILE"
           echo "Available profiles: home, work, public"
           exit 1
           ;;
   esac
   
   echo "Current network configuration:"
   ip addr show eth0
   echo "DNS configuration:"
   cat /etc/resolv.conf
   ```

   Make the script executable:
   ```bash
   chmod +x ~/scripts/network-profile.sh
   ```

### File System Configuration

1. **Analyze your current filesystem**:
   ```bash
   # Show mounted filesystems
   df -h
   
   # Show filesystem types
   lsblk -f
   
   # Examine fstab entries
   cat /etc/fstab
   ```

2. **Create and mount a RAM disk**:
   ```bash
   # Create mount point
   sudo mkdir -p /mnt/ramdisk
   
   # Mount a 512MB RAM disk
   sudo mount -t tmpfs -o size=512m tmpfs /mnt/ramdisk
   
   # Verify mount
   df -h /mnt/ramdisk
   
   # Make it permanent by adding to fstab
   echo "tmpfs /mnt/ramdisk tmpfs size=512m,mode=1777 0 0" | sudo tee -a /etc/fstab
   ```

3. **Configure automatic mounting of a USB drive**:
   ```bash
   # Create a directory for the USB drive
   sudo mkdir -p /media/usbdrive
   
   # Get the UUID of your USB drive (plug it in first)
   sudo blkid | grep -i usb
   
   # Add entry to fstab (replace UUID with your drive's UUID)
   echo "UUID=your-drive-uuid /media/usbdrive auto nosuid,nodev,nofail,x-gvfs-show 0 0" | sudo tee -a /etc/fstab
   
   # Test the mount
   sudo mount -a
   ```

### System Localization

1. **Configure system locale**:
   ```bash
   # View current locale settings
   locale
   
   # List available locales
   locale -a
   
   # Edit locale configuration
   sudo nano /etc/locale.gen
   
   # Uncomment or add desired locales, e.g.:
   # en_US.UTF-8 UTF-8
   # es_ES.UTF-8 UTF-8
   # fr_FR.UTF-8 UTF-8
   
   # Generate locales
   sudo locale-gen
   
   # Set system-wide locale
   sudo localectl set-locale LANG=en_US.UTF-8
   ```

2. **Configure time zone and NTP**:
   ```bash
   # View current time zone
   timedatectl
   
   # List available time zones
   timedatectl list-timezones | grep America
   
   # Set time zone
   sudo timedatectl set-timezone America/New_York
   
   # Enable NTP synchronization
   sudo timedatectl set-ntp true
   
   # Verify settings
   timedatectl status
   ```

## Exercise 3: Advanced Package Management

### Pacman Mastery

1. **Query and analyze installed packages**:
   ```bash
   # List explicitly installed packages
   pacman -Qe
   
   # List all foreign packages (e.g., AUR packages)
   pacman -Qm
   
   # List all native packages
   pacman -Qn
   
   # Find orphaned packages
   pacman -Qdt
   
   # Find the package that owns a specific file
   pacman -Qo /usr/bin/python
   
   # List all files owned by a package
   pacman -Ql pacman
   ```

2. **Search and information retrieval**:
   ```bash
   # Search for packages
   pacman -Ss text editor
   
   # Get detailed information about a package
   pacman -Si neovim
   
   # List all packages in a group
   pacman -Sg base-devel
   
   # Check for modified config files
   pacman -Qii | grep MODIFIED
   ```

3. **Create a package backup list**:
   ```bash
   # Output list of explicitly installed packages
   pacman -Qe | awk '{print $1}' > ~/pkglist.txt
   
   # Create a backup script for packages
   nano ~/scripts/backup-packages.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   
   BACKUP_DIR="$HOME/system-backups/packages"
   mkdir -p "$BACKUP_DIR"
   
   DATE=$(date +%Y-%m-%d)
   
   # Backup package lists
   echo "Backing up package lists..."
   pacman -Qe | awk '{print $1}' > "$BACKUP_DIR/pkglist-explicit-$DATE.txt"
   pacman -Qm | awk '{print $1}' > "$BACKUP_DIR/pkglist-foreign-$DATE.txt"
   pacman -Qn | awk '{print $1}' > "$BACKUP_DIR/pkglist-native-$DATE.txt"
   
   # Create restore script
   cat > "$BACKUP_DIR/restore-packages.sh" << 'EOF'
   #!/bin/bash
   
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   LATEST_EXPLICIT=$(ls -t "$SCRIPT_DIR"/pkglist-explicit-*.txt | head -n1)
   
   if [ -z "$LATEST_EXPLICIT" ]; then
       echo "No package lists found!"
       exit 1
   fi
   
   echo "Using package list: $LATEST_EXPLICIT"
   echo "This will install all packages from the list."
   read -p "Continue? (y/n): " -n 1 -r
   echo
   
   if [[ $REPLY =~ ^[Yy]$ ]]; then
       sudo pacman -S --needed - < "$LATEST_EXPLICIT"
   fi
   EOF
   
   chmod +x "$BACKUP_DIR/restore-packages.sh"
   
   echo "Package lists backed up to $BACKUP_DIR"
   echo "Use $BACKUP_DIR/restore-packages.sh to restore packages"
   ```

   Make the script executable:
   ```bash
   chmod +x ~/scripts/backup-packages.sh
   ```

### AUR Helpers

1. **Install and configure an AUR helper (yay)**:
   ```bash
   # Install dependencies
   sudo pacman -S --needed git base-devel
   
   # Clone yay repository
   git clone https://aur.archlinux.org/yay.git
   cd yay
   makepkg -si
   cd ..
   rm -rf yay
   
   # Verify installation
   yay --version
   ```

2. **Configure yay**:
   ```bash
   # Set preferences
   yay --save --combinedupgrade --sudoloop --cleanafter
   
   # Check configuration
   cat ~/.config/yay/config.json
   ```

3. **Practice AUR management**:
   ```bash
   # Search for packages in AUR
   yay -Ss brave browser
   
   # Install a package from AUR
   yay -S brave-bin
   
   # Check for updates including AUR
   yay -Syu
   
   # Update only AUR packages
   yay -Sua
   ```

### Create a PKGBUILD

1. **Create a simple PKGBUILD for a script package**:
   ```bash
   # Create package directory
   mkdir -p ~/packages/system-tools
   cd ~/packages/system-tools
   
   # Create PKGBUILD
   nano PKGBUILD
   ```

   Add the following content:
   ```bash
   # Maintainer: Your Name <your.email@example.com>
   pkgname=system-tools
   pkgver=1.0.0
   pkgrel=1
   pkgdesc="A collection of useful system administration scripts"
   arch=('any')
   url="https://github.com/yourusername/system-tools"
   license=('MIT')
   depends=('bash' 'coreutils' 'grep' 'iproute2')
   source=()
   
   package() {
     cd "$srcdir"
     
     # Create the installation directory
     install -dm755 "$pkgdir/usr/bin"
     install -dm755 "$pkgdir/usr/share/licenses/$pkgname"
     
     # Create a license file
     cat > "$pkgdir/usr/share/licenses/$pkgname/LICENSE" << EOF
   MIT License
   
   Copyright (c) $(date +%Y) Your Name
   
   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:
   
   The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.
   
   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.
   EOF
     
     # Create system-info script
     cat > "$pkgdir/usr/bin/system-info" << EOF
   #!/bin/bash
   
   echo "System Information"
   echo "================="
   echo
   echo "Hostname: \$(hostname)"
   echo "Kernel version: \$(uname -r)"
   echo "Architecture: \$(uname -m)"
   echo "CPU: \$(grep "model name" /proc/cpuinfo | head -n1 | cut -d ":" -f2 | sed 's/^ *//')"
   echo "Memory: \$(free -h | grep "Mem:" | awk '{print \$2}')"
   echo "Disk usage: \$(df -h / | tail -n1 | awk '{print \$3 " / " \$2 " (" \$5 ")"}')"
   echo "IP address: \$(ip -4 addr show scope global | grep inet | awk '{print \$2}' | cut -d/ -f1 | head -n1)"
   echo "Uptime: \$(uptime -p)"
   EOF
     
     # Create disk-usage script
     cat > "$pkgdir/usr/bin/disk-usage" << EOF
   #!/bin/bash
   
   if [ "\$1" = "-h" ] || [ "\$1" = "--help" ]; then
     echo "Usage: disk-usage [directory]"
     echo "Shows disk usage of directories, sorted by size"
     exit 0
   fi
   
   TARGET_DIR="\${1:-.}"
   
   du -h --max-depth=1 "\$TARGET_DIR" | sort -hr
   EOF
     
     # Create process-monitor script
     cat > "$pkgdir/usr/bin/process-monitor" << EOF
   #!/bin/bash
   
   if [ "\$1" = "-h" ] || [ "\$1" = "--help" ]; then
     echo "Usage: process-monitor [name]"
     echo "Monitors processes matching the given name"
     echo "If no name is provided, shows top CPU and memory consuming processes"
     exit 0
   fi
   
   if [ -z "\$1" ]; then
     echo "Top CPU-consuming processes:"
     ps aux --sort=-%cpu | head -n 6
     
     echo -e "\nTop memory-consuming processes:"
     ps aux --sort=-%mem | head -n 6
   else
     echo "Monitoring processes matching: \$1"
     ps aux | grep "\$1" | grep -v "grep" || echo "No matching processes found"
   fi
   EOF
     
     # Make scripts executable
     chmod 755 "$pkgdir/usr/bin/system-info"
     chmod 755 "$pkgdir/usr/bin/disk-usage"
     chmod 755 "$pkgdir/usr/bin/process-monitor"
   }
   ```

2. **Build and install the package**:
   ```bash
   # Build the package
   makepkg -s
   
   # Install the package
   sudo pacman -U system-tools-1.0.0-1-any.pkg.tar.zst
   
   # Test the installed scripts
   system-info
   disk-usage
   process-monitor
   ```

## Exercise 4: System Logs, Backup, and Maintenance

### Journal Log Management

1. **Practice journal querying**:
   ```bash
   # View logs for the current boot
   journalctl -b
   
   # View logs for the previous boot
   journalctl -b -1
   
   # View kernel messages
   journalctl -k
   
   # View logs by priority (error and higher)
   journalctl -p err
   
   # View logs for a specific time period
   journalctl --since "2023-01-01 00:00:00" --until "2023-01-02 00:00:00"
   
   # Follow logs as they come in
   journalctl -f
   ```

2. **Create a log analysis script**:
   ```bash
   nano ~/scripts/analyze-journal.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   
   # A script to analyze systemd journal logs
   
   OUTPUT_DIR="$HOME/log-analysis"
   mkdir -p "$OUTPUT_DIR"
   
   TODAY=$(date +%Y-%m-%d)
   REPORT_FILE="$OUTPUT_DIR/journal-analysis-$TODAY.txt"
   
   echo "Systemd Journal Analysis Report" > "$REPORT_FILE"
   echo "Date: $TODAY" >> "$REPORT_FILE"
   echo "===================================" >> "$REPORT_FILE"
   
   # Count entries by priority
   echo -e "\nLog Entries by Priority:" >> "$REPORT_FILE"
   echo "----------------------------------" >> "$REPORT_FILE"
   for PRIO in emerg alert crit err warning notice info debug; do
       COUNT=$(journalctl -p "$PRIO" --since today | grep -v "-- No entries --" | wc -l)
       echo "$PRIO: $COUNT" >> "$REPORT_FILE"
   done
   
   # Most frequent services with errors
   echo -e "\nServices with Most Errors:" >> "$REPORT_FILE"
   echo "----------------------------------" >> "$REPORT_FILE"
   journalctl -p err --since today | grep "]: " | sed 's/.*\[//g' | sed 's/\].*//g' | sort | uniq -c | sort -nr | head -10 >> "$REPORT_FILE"
   
   # Most recent errors
   echo -e "\nMost Recent Errors:" >> "$REPORT_FILE"
   echo "----------------------------------" >> "$REPORT_FILE"
   journalctl -p err --since today | tail -10 >> "$REPORT_FILE"
   
   # Boot statistics
   echo -e "\nBoot Statistics:" >> "$REPORT_FILE"
   echo "----------------------------------" >> "$REPORT_FILE"
   journalctl --list-boots | head -5 >> "$REPORT_FILE"
   
   echo -e "\nBoot Times:" >> "$REPORT_FILE"
   echo "----------------------------------" >> "$REPORT_FILE"
   systemd-analyze >> "$REPORT_FILE"
   
   # Service statistics
   echo -e "\nSlowest Services to Start:" >> "$REPORT_FILE"
   echo "----------------------------------" >> "$REPORT_FILE"
   systemd-analyze blame | head -10 >> "$REPORT_FILE"
   
   echo -e "\nFailed Services:" >> "$REPORT_FILE"
   echo "----------------------------------" >> "$REPORT_FILE"
   systemctl --failed >> "$REPORT_FILE"
   
   echo "Journal analysis report generated at $REPORT_FILE"
   ```

   Make the script executable:
   ```bash
   chmod +x ~/scripts/analyze-journal.sh
   ```

### System Backup Solution

1. **Create a comprehensive backup script using rsync**:
   ```bash
   nano ~/scripts/backup.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   
   # Comprehensive backup script using rsync
   
   # Configuration
   BACKUP_DIR="/mnt/backup"
   LOG_DIR="$HOME/logs/backup"
   EXCLUDE_FILE="$HOME/.backup-exclude"
   SOURCES=(
       "$HOME/Documents"
       "$HOME/Pictures"
       "$HOME/Projects"
       "$HOME/.config"
   )
   
   # Create directories if they don't exist
   mkdir -p "$BACKUP_DIR"
   mkdir -p "$LOG_DIR"
   
   # Create exclude file if it doesn't exist
   if [ ! -f "$EXCLUDE_FILE" ]; then
       cat > "$EXCLUDE_FILE" << EOF
   *.tmp
   *.temp
   *.log
   *.cache
   .git/
   node_modules/
   __pycache__/
   venv/
   .venv/
   .env/
   EOF
   fi
   
   # Set date variables
   DATE=$(date +%Y-%m-%d)
   DATE_TIME=$(date +%Y-%m-%d_%H-%M-%S)
   LOG_FILE="$LOG_DIR/backup_$DATE_TIME.log"
   
   # Function to log messages
   log() {
       echo "[$(date +%H:%M:%S)] $1" | tee -a "$LOG_FILE"
   }
   
   # Start backup
   log "Starting backup..."
   log "Backup sources: ${SOURCES[@]}"
   log "Backup destination: $BACKUP_DIR"
   
   # Check if backup directory is available
   if [ ! -d "$BACKUP_DIR" ]; then
       log "ERROR: Backup directory $BACKUP_DIR does not exist. Aborting."
       exit 1
   fi
   
   # Check if destination has enough space
   SRC_SIZE=$(du -sbc "${SOURCES[@]}" 2>/dev/null | tail -n1 | cut -f1)
   DEST_AVAIL=$(df -B1 "$BACKUP_DIR" | awk 'NR==2 {print $4}')
   
   log "Source size: $(numfmt --to=iec-i --suffix=B $SRC_SIZE)"
   log "Destination space: $(numfmt --to=iec-i --suffix=B $DEST_AVAIL)"
   
   if [ "$DEST_AVAIL" -lt "$SRC_SIZE" ]; then
       log "WARNING: Destination may not have enough space."
       read -p "Continue anyway? (y/n): " -n 1 -r
       echo
       if [[ ! $REPLY =~ ^[Yy]$ ]]; then
           log "Backup aborted by user."
           exit 1
       fi
   fi
   
   # Create daily snapshot directory
   DAILY_DIR="$BACKUP_DIR/daily/$DATE"
   LATEST_LINK="$BACKUP_DIR/latest"
   
   # Create incremental backup
   for SRC in "${SOURCES[@]}"; do
       SRC_NAME=$(basename "$SRC")
       log "Backing up $SRC_NAME..."
       
       # Use rsync for backup
       rsync -avh --delete --exclude-from="$EXCLUDE_FILE" \
           --link-dest="$LATEST_LINK/$SRC_NAME" \
           "$SRC" "$DAILY_DIR/" >> "$LOG_FILE" 2>&1
       
       # Check rsync result
       if [ $? -eq 0 ]; then
           log "Backup of $SRC_NAME completed successfully."
       else
           log "ERROR: Backup of $SRC_NAME failed."
       fi
   done
   
   # Update latest link
   rm -f "$LATEST_LINK"
   ln -s "$DAILY_DIR" "$LATEST_LINK"
   
   # Rotate backups (keep last 7 daily backups)
   log "Rotating backups..."
   ls -1d "$BACKUP_DIR/daily/20"* | sort -r | tail -n +8 | xargs rm -rf
   
   # Create weekly backup (on Sundays)
   DAY_OF_WEEK=$(date +%u)
   if [ "$DAY_OF_WEEK" -eq 7 ]; then
       WEEK_NUM=$(date +%U)
       WEEKLY_DIR="$BACKUP_DIR/weekly/week$WEEK_NUM"
       log "Creating weekly backup..."
       
       mkdir -p "$WEEKLY_DIR"
       cp -al "$DAILY_DIR"/* "$WEEKLY_DIR"/ >> "$LOG_FILE" 2>&1
       
       # Rotate weekly backups (keep last 4 weeks)
       ls -1d "$BACKUP_DIR/weekly/week"* | sort -r | tail -n +5 | xargs rm -rf
   fi
   
   # Create monthly backup (on 1st day of month)
   DAY_OF_MONTH=$(date +%d)
   if [ "$DAY_OF_MONTH" -eq 01 ]; then
       MONTH=$(date +%Y-%m)
       MONTHLY_DIR="$BACKUP_DIR/monthly/$MONTH"
       log "Creating monthly backup..."
       
       mkdir -p "$MONTHLY_DIR"
       cp -al "$DAILY_DIR"/* "$MONTHLY_DIR"/ >> "$LOG_FILE" 2>&1
       
       # Rotate monthly backups (keep last 12 months)
       ls -1d "$BACKUP_DIR/monthly/20"* | sort -r | tail -n +13 | xargs rm -rf
   fi
   
   # Backup system configuration files
   CONFIG_BACKUP="$BACKUP_DIR/system-config/$DATE"
   mkdir -p "$CONFIG_BACKUP"
   
   log "Backing up system configuration files..."
   sudo cp -a /etc/fstab "$CONFIG_BACKUP/"
   sudo cp -a /etc/pacman.conf "$CONFIG_BACKUP/"
   sudo cp -a /etc/default "$CONFIG_BACKUP/"
   sudo cp -a /etc/NetworkManager/system-connections "$CONFIG_BACKUP/"
   
   # Fix permissions
   sudo chown -R $USER:$USER "$CONFIG_BACKUP"
   
   # Backup installed packages list
   log "Backing up package lists..."
   pacman -Qe > "$CONFIG_BACKUP/pkglist-explicit.txt"
   pacman -Qm > "$CONFIG_BACKUP/pkglist-foreign.txt"
   
   # Report backup size
   BACKUP_SIZE=$(du -sh "$DAILY_DIR" | cut -f1)
   log "Backup complete. Size: $BACKUP_SIZE"
   log "Backup log saved to $LOG_FILE"
   ```

   Make the script executable:
   ```bash
   chmod +x ~/scripts/backup.sh
   ```

2. **Create a backup verification script**:
   ```bash
   nano ~/scripts/verify-backup.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   
   # Script to verify backup integrity
   
   BACKUP_DIR="/mnt/backup"
   LATEST_LINK="$BACKUP_DIR/latest"
   LOG_FILE="$HOME/logs/backup/verify_$(date +%Y-%m-%d_%H-%M-%S).log"
   
   # Create log directory if it doesn't exist
   mkdir -p "$(dirname "$LOG_FILE")"
   
   # Function to log messages
   log() {
       echo "[$(date +%H:%M:%S)] $1" | tee -a "$LOG_FILE"
   }
   
   # Start verification
   log "Starting backup verification..."
   
   # Check if backup directory exists
   if [ ! -d "$BACKUP_DIR" ]; then
       log "ERROR: Backup directory $BACKUP_DIR does not exist. Aborting."
       exit 1
   fi
   
   # Check if latest link exists
   if [ ! -L "$LATEST_LINK" ]; then
       log "ERROR: Latest link $LATEST_LINK does not exist. Aborting."
       exit 1
   fi
   
   # Get latest backup date
   LATEST_DATE=$(basename "$(readlink -f "$LATEST_LINK")")
   log "Verifying backup from $LATEST_DATE"
   
   # Verify directories exist
   DIRS_TO_CHECK=(
       "Documents"
       "Pictures"
       "Projects"
       ".config"
   )
   
   for DIR in "${DIRS_TO_CHECK[@]}"; do
       if [ ! -d "$LATEST_LINK/$DIR" ]; then
           log "ERROR: Directory $DIR is missing from backup."
       else
           # Count files
           FILE_COUNT=$(find "$LATEST_LINK/$DIR" -type f | wc -l)
           log "Directory $DIR has $FILE_COUNT files."
           
           # Verify random files (up to 5 per directory)
           log "Verifying random files in $DIR..."
           RANDOM_FILES=$(find "$LATEST_LINK/$DIR" -type f | sort -R | head -5)
           
           for FILE in $RANDOM_FILES; do
               REL_PATH=$(echo "$FILE" | sed "s|$LATEST_LINK/||")
               SRC_FILE="$HOME/$REL_PATH"
               
               if [ -f "$SRC_FILE" ]; then
                   # Compare file sizes
                   SRC_SIZE=$(stat -c %s "$SRC_FILE")
                   BACKUP_SIZE=$(stat -c %s "$FILE")
                   
                   if [ "$SRC_SIZE" -eq "$BACKUP_SIZE" ]; then
                       log "✅ File $REL_PATH verified (size: $SRC_SIZE bytes)"
                   else
                       log "❌ File $REL_PATH size mismatch: Source=$SRC_SIZE, Backup=$BACKUP_SIZE"
                   fi
               else
                   log "⚠️  Source file $SRC_FILE not found. Can't verify."
               fi
           done
       fi
   done
   
   # Verify system configuration backups
   CONFIG_BACKUP="$BACKUP_DIR/system-config/$LATEST_DATE"
   
   if [ -d "$CONFIG_BACKUP" ]; then
       log "Verifying system configuration backups..."
       
       CONFIG_FILES=(
           "fstab"
           "pacman.conf"
       )
       
       for FILE in "${CONFIG_FILES[@]}"; do
           if [ -f "$CONFIG_BACKUP/$FILE" ]; then
               log "✅ System configuration file $FILE exists in backup."
           else
               log "❌ System configuration file $FILE is missing from backup."
           fi
       done
       
       # Verify package lists
       if [ -f "$CONFIG_BACKUP/pkglist-explicit.txt" ]; then
           PKG_COUNT=$(wc -l < "$CONFIG_BACKUP/pkglist-explicit.txt")
           log "✅ Package list exists with $PKG_COUNT explicitly installed packages."
       else
           log "❌ Package list is missing from backup."
       fi
   else
       log "❌ System configuration backup directory does not exist."
   fi
   
   log "Backup verification completed."
   ```

   Make the script executable:
   ```bash
   chmod +x ~/scripts/verify-backup.sh
   ```

3. **Set up a systemd timer for automated backups**:
   ```bash
   sudo nano /etc/systemd/system/backup.service
   ```

   Add the following content:
   ```ini
   [Unit]
   Description=System Backup Service
   After=network.target
   
   [Service]
   Type=oneshot
   ExecStart=/home/yourusername/scripts/backup.sh
   ExecStartPost=/home/yourusername/scripts/verify-backup.sh
   User=yourusername
   
   [Install]
   WantedBy=multi-user.target
   ```

   Create a timer:
   ```bash
   sudo nano /etc/systemd/system/backup.timer
   ```

   Add the following content:
   ```ini
   [Unit]
   Description=Run System Backup Daily
   
   [Timer]
   OnCalendar=*-*-* 02:00:00
   Persistent=true
   
   [Install]
   WantedBy=timers.target
   ```

   Enable and start the timer:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable backup.timer
   sudo systemctl start backup.timer
   ```

### System Maintenance Procedures

1. **Create a comprehensive system maintenance script**:
   ```bash
   nano ~/scripts/system-maintenance.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   
   # Comprehensive system maintenance script
   
   LOG_FILE="$HOME/logs/maintenance_$(date +%Y-%m-%d_%H-%M-%S).log"
   
   # Create log directory if it doesn't exist
   mkdir -p "$(dirname "$LOG_FILE")"
   
   # Function to log messages
   log() {
       echo "[$(date +%H:%M:%S)] $1" | tee -a "$LOG_FILE"
   }
   
   # Check if running as root
   if [ "$(id -u)" -ne 0 ]; then
       log "This script must be run as root. Switching..."
       exec sudo "$0" "$@"
       exit $?
   fi
   
   # Start maintenance
   log "Starting system maintenance..."
   
   # Update package databases and upgrade packages
   log "Updating package databases and upgrading packages..."
   pacman -Syu --noconfirm >> "$LOG_FILE" 2>&1
   
   # Update AUR packages if yay is installed
   if command -v yay &> /dev/null; then
       log "Updating AUR packages..."
       sudo -u "$SUDO_USER" yay -Sua --noconfirm >> "$LOG_FILE" 2>&1
   fi
   
   # Clean package cache
   log "Cleaning package cache..."
   paccache -r >> "$LOG_FILE" 2>&1
   
   # Remove orphaned packages
   log "Checking for orphaned packages..."
   ORPHANS=$(pacman -Qtdq)
   if [ -n "$ORPHANS" ]; then
       log "Removing orphaned packages..."
       pacman -Rns $(pacman -Qtdq) --noconfirm >> "$LOG_FILE" 2>&1
   else
       log "No orphaned packages found."
   fi
   
   # Check for failed services
   log "Checking for failed services..."
   FAILED_SERVICES=$(systemctl --failed --no-legend | awk '{print $1}')
   if [ -n "$FAILED_SERVICES" ]; then
       log "Failed services found:"
       systemctl --failed >> "$LOG_FILE"
   else
       log "No failed services found."
   fi
   
   # Check disk space
   log "Checking disk space..."
   df -h >> "$LOG_FILE"
   
   # Check for nearly full filesystems
   FULL_FS=$(df -h | awk 'NR>1 {gsub(/%/,""); if ($5 > 85) print $6, $5"%"}')
   if [ -n "$FULL_FS" ]; then
       log "WARNING: Some filesystems are nearly full:"
       echo "$FULL_FS" | while read fs usage; do
           log "  $fs: $usage"
       done
   fi
   
   # Clean journal logs
   log "Cleaning journal logs..."
   journalctl --vacuum-time=14d >> "$LOG_FILE" 2>&1
   
   # Update man database
   log "Updating man database..."
   mandb >> "$LOG_FILE" 2>&1
   
   # Update locate database
   log "Updating locate database..."
   updatedb >> "$LOG_FILE" 2>&1
   
   # Check for disk errors
   log "Checking for disk errors..."
   ROOT_DEVICE=$(df / | awk 'NR==2 {print $1}' | sed 's/[0-9]*$//')
   
   if [[ $ROOT_DEVICE == /dev/sd* || $ROOT_DEVICE == /dev/nvme* ]]; then
       log "Running SMART checks on $ROOT_DEVICE..."
       smartctl -H "$ROOT_DEVICE" >> "$LOG_FILE" 2>&1
       smartctl -A "$ROOT_DEVICE" >> "$LOG_FILE" 2>&1
   fi
   
   # Check for old log files
   log "Checking for old log files..."
   find /var/log -type f -name "*.gz" -o -name "*.old" -o -name "*.1" -mtime +30 -exec rm {} \; 2>> "$LOG_FILE"
   
   # Clean temporary files
   log "Cleaning temporary files..."
   find /tmp -type f -atime +10 -delete 2>> "$LOG_FILE"
   find /var/tmp -type f -atime +10 -delete 2>> "$LOG_FILE"
   
   # Clean user cache (run as the original user)
   log "Cleaning user cache..."
   if [ -n "$SUDO_USER" ]; then
       sudo -u "$SUDO_USER" find /home/"$SUDO_USER"/.cache -type f -atime +60 -delete 2>> "$LOG_FILE"
   fi
   
   # Report system status
   log "Reporting system status..."
   log "Memory usage:"
   free -h >> "$LOG_FILE"
   
   log "Top processes by CPU:"
   ps aux --sort=-%cpu | head -6 >> "$LOG_FILE"
   
   log "Top processes by memory:"
   ps aux --sort=-%mem | head -6 >> "$LOG_FILE"
   
   log "System load:"
   uptime >> "$LOG_FILE"
   
   # Notify completion
   log "System maintenance completed."
   
   if [ -n "$SUDO_USER" ]; then
       sudo -u "$SUDO_USER" notify-send "System Maintenance" "System maintenance completed successfully."
   fi
   ```

   Make the script executable:
   ```bash
   chmod +x ~/scripts/system-maintenance.sh
   ```

2. **Create a systemd timer for regular maintenance**:
   ```bash
   sudo nano /etc/systemd/system/maintenance.service
   ```

   Add the following content:
   ```ini
   [Unit]
   Description=System Maintenance Service
   After=network.target
   
   [Service]
   Type=oneshot
   ExecStart=/home/yourusername/scripts/system-maintenance.sh
   
   [Install]
   WantedBy=multi-user.target
   ```

   Create a timer:
   ```bash
   sudo nano /etc/systemd/system/maintenance.timer
   ```

   Add the following content:
   ```ini
   [Unit]
   Description=Weekly System Maintenance
   
   [Timer]
   OnCalendar=Sun 03:00:00
   Persistent=true
   
   [Install]
   WantedBy=timers.target
   ```

   Enable and start the timer:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable maintenance.timer
   sudo systemctl start maintenance.timer
   ```

## Projects

### Project 1: Custom Services Manager

Create a comprehensive service management dashboard and toolkit for your system.

1. **Create a services information collector**:
   ```bash
   nano ~/projects/service-manager/collect-services.sh
   ```

   Add content to collect information about running services, their dependencies, and resource usage.

2. **Create a service control dashboard**:
   ```bash
   nano ~/projects/service-manager/service-dashboard.sh
   ```

   Add content to display an interactive menu for service management, allowing you to start, stop, and monitor services.

3. **Implement service optimization recommendations**:
   ```bash
   nano ~/projects/service-manager/optimize-services.sh
   ```

   Add content to analyze your services and provide recommendations for performance optimization.

### Project 2: Network Configuration Manager

Create a toolkit for managing multiple network profiles and configurations.

1. **Implement a profile creator**:
   ```bash
   nano ~/projects/network-manager/create-profile.sh
   ```

   Add content to guide the user through creating network profiles for different environments.

2. **Create a profile switcher**:
   ```bash
   nano ~/projects/network-manager/switch-profile.sh
   ```

   Add content to enable quick switching between network profiles.

3. **Implement network monitoring**:
   ```bash
   nano ~/projects/network-manager/monitor-network.sh
   ```

   Add content to monitor network performance, detect issues, and provide troubleshooting steps.

### Project 3: Package Management Toolkit

Create a comprehensive package management toolkit.

1. **Implement a package auditor**:
   ```bash
   nano ~/projects/pkg-toolkit/audit-packages.sh
   ```

   Add content to analyze installed packages, their dependencies, and usage patterns.

2. **Create a package cleanup tool**:
   ```bash
   nano ~/projects/pkg-toolkit/cleanup-packages.sh
   ```

   Add content to identify and safely remove unnecessary packages.

3. **Implement a package recommendation system**:
   ```bash
   nano ~/projects/pkg-toolkit/recommend-packages.sh
   ```

   Add content to recommend useful packages based on the user's installed software and usage patterns.

### Project 4: System Maintenance Framework

Create a comprehensive maintenance framework for your system.

1. **Implement a maintenance scheduler**:
   ```bash
   nano ~/projects/maintenance-framework/schedule-maintenance.sh
   ```

   Add content to schedule and customize maintenance tasks.

2. **Create a health check tool**:
   ```bash
   nano ~/projects/maintenance-framework/health-check.sh
   ```

   Add content to perform a detailed system health check and identify potential issues.

3. **Implement a maintenance dashboard**:
   ```bash
   nano ~/projects/maintenance-framework/maintenance-dashboard.sh
   ```

   Add content to provide an interactive dashboard for monitoring system health and maintenance status.

## Additional Resources

### System Configuration References

- **Common systemd commands**:
  ```
  systemctl status <service>       # Check service status
  systemctl start <service>        # Start a service
  systemctl stop <service>         # Stop a service
  systemctl enable <service>       # Enable service at boot
  systemctl disable <service>      # Disable service at boot
  systemctl restart <service>      # Restart a service
  systemctl reload <service>       # Reload service config
  systemctl mask <service>         # Completely disable a service
  systemctl list-units --type=service  # List all services
  systemctl list-dependencies <service>  # Show dependencies
  ```

- **Common NetworkManager commands**:
  ```
  nmcli device status             # Show all network interfaces
  nmcli connection show           # Show all connections
  nmcli connection up <name>      # Activate a connection
  nmcli connection down <name>    # Deactivate a connection
  nmcli device wifi list          # List available WiFi networks
  nmcli device wifi connect <SSID> password <password>  # Connect to WiFi
  ```

- **Pacman commands cheatsheet**:
  ```
  pacman -S <package>             # Install package
  pacman -Ss <keyword>            # Search for package
  pacman -Syu                     # Update system
  pacman -R <package>             # Remove package
  pacman -Rs <package>            # Remove package with dependencies
  pacman -Qe                      # List explicitly installed packages
  pacman -Qdt                     # List orphaned packages
  pacman -Sc                      # Clean package cache
  pacman -Ql <package>            # List files in package
  pacman -Qo <file>               # Find which package owns a file
  ```

### Troubleshooting Flowcharts

- **Service fails to start**:
  1. Check service status: `systemctl status service-name`
  2. View logs: `journalctl -u service-name`
  3. Check configuration file syntax
  4. Check for missing dependencies
  5. Verify permissions on service files
  6. Try running the service manually

- **Network troubleshooting**:
  1. Check physical connection
  2. Verify interface is up: `ip link show`
  3. Check IP address: `ip addr show`
  4. Check routing: `ip route show`
  5. Test DNS: `ping 8.8.8.8` then `ping google.com`
  6. Check firewall rules
  7. Examine logs: `journalctl -u NetworkManager`

- **Package management troubleshooting**:
  1. Update database: `pacman -Syy`
  2. Check for lock files: `/var/lib/pacman/db.lck`
  3. Verify repository configuration in `/etc/pacman.conf`
  4. Check for corrupted packages: `pacman -Qk`
  5. Reinstall package database: `pacman -Syu pacman`
  6. Check disk space: `df -h`

## Reflection Questions

After completing the exercises and projects, reflect on these questions:

1. How does systemd's service management compare to other init systems you may have used?

2. What are the strengths and limitations of Arch Linux's package management system compared to other distributions?

3. How would you design an effective backup strategy for a production server?

4. How might you automate system maintenance tasks for a fleet of Linux servers?

5. What security considerations should be taken into account when configuring system services?

6. How would you approach troubleshooting a complex service dependency issue?

7. What strategies could you use to minimize downtime during system updates?

8. How would you ensure consistency across multiple system configurations?

## Answers to Self-Assessment Quiz

1. `systemctl is-enabled service-name`
2. `journalctl -u service-name -n 100`
3. `/etc/fstab`
4. `[custom-repo-name]` followed by `Server = repo-url`
5. `nmcli connection add`
6. `yay -Ss search-term` or `paru -Ss search-term`
7. `PKGBUILD`
8. `OnCalendar=*-*-* 03:00:00` in a timer unit
9. `systemctl list-timers`
10. `journalctl --vacuum-time=2weeks` or `journalctl --vacuum-size=1G`

## Next Steps

After completing Month 2 exercises, consider these activities to further cement your learning:

1. **Create a git repository for your system configuration files**

2. **Experiment with different service configurations**

3. **Build a custom Arch Linux package for a tool you use frequently**

4. **Set up monitoring for your system using Prometheus and Grafana**

5. **Practice recovery scenarios from system failures**

6. **Document your system configuration in a personal wiki**

7. **Join community discussions on the Arch Linux forums**

Remember that mastering system configuration is an iterative process. Keep experimenting, documenting, and refining your setup!

## Acknowledgements

These exercises were developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Exercise structure and organization
- Resource recommendations
- Project suggestions

Claude was used as a development aid while all final implementation decisions and verification were performed by Joshua Michael Hall.

## Disclaimer

These exercises are provided "as is", without warranty of any kind. Always back up important data before making system changes.
# Month 7: System Maintenance and Performance Tuning - Exercises

This document contains practical exercises to accompany the Month 7 learning guide. Complete these exercises to solidify your understanding of system maintenance, performance monitoring, backup strategies, and automated maintenance.

## Maintenance Strategy Exercise

Create a comprehensive maintenance strategy for your Linux system that can be implemented with scripts and scheduled tasks.

### Tasks:

1. **System Analysis and Documentation**:
   ```bash
   # Create a documentation directory
   mkdir -p ~/system-maintenance/docs
   
   # Document your system specifications
   lscpu > ~/system-maintenance/docs/cpu-info.txt
   lsblk > ~/system-maintenance/docs/disk-info.txt
   free -h > ~/system-maintenance/docs/memory-info.txt
   cat /proc/meminfo > ~/system-maintenance/docs/meminfo-detailed.txt
   
   # Document installed packages
   pacman -Q > ~/system-maintenance/docs/installed-packages.txt
   pacman -Qe > ~/system-maintenance/docs/explicitly-installed.txt
   pacman -Qm > ~/system-maintenance/docs/aur-packages.txt
   
   # Document active services
   systemctl list-units --type=service --state=active > ~/system-maintenance/docs/active-services.txt
   
   # Document mounted filesystems
   findmnt > ~/system-maintenance/docs/mounted-filesystems.txt
   
   # Document network configuration
   ip addr > ~/system-maintenance/docs/network-config.txt
   ```

2. **Create a Comprehensive Maintenance Script**:
   ```bash
   #!/bin/bash
   # ~/system-maintenance/maintenance.sh
   
   # Set up logging
   LOG_DIR="$HOME/system-maintenance/logs"
   mkdir -p "$LOG_DIR"
   LOG_FILE="$LOG_DIR/maintenance-$(date +%Y%m%d-%H%M%S).log"
   
   # Function to log messages
   log() {
     echo "[$(date +%Y-%m-%d\ %H:%M:%S)] $1" | tee -a "$LOG_FILE"
   }
   
   # Function to handle errors
   handle_error() {
     log "ERROR: $1"
     if [ -x "$(command -v mail)" ]; then
       echo "Maintenance error: $1" | mail -s "System Maintenance Error" your-email@example.com
     fi
   }
   
   # Run a command with error handling
   run_cmd() {
     log "Running: $1"
     eval "$1"
     if [ $? -ne 0 ]; then
       handle_error "Command failed: $1"
       return 1
     fi
     return 0
   }
   
   # Begin maintenance
   log "Starting system maintenance"
   
   # Update package database
   log "Updating package database..."
   run_cmd "sudo pacman -Sy" || log "Warning: Package database update failed"
   
   # System update
   log "Updating system packages..."
   run_cmd "sudo pacman -Su --noconfirm" || handle_error "System update failed"
   
   # Clean package cache
   log "Cleaning package cache..."
   run_cmd "sudo paccache -r" || log "Warning: Package cache cleanup failed"
   
   # Remove orphaned packages
   log "Checking for orphaned packages..."
   ORPHANS=$(pacman -Qtdq | wc -l)
   if [ "$ORPHANS" -gt 0 ]; then
     log "Found $ORPHANS orphaned packages. Removing..."
     run_cmd "sudo pacman -Rns $(pacman -Qtdq) --noconfirm" || log "Warning: Failed to remove orphaned packages"
   else
     log "No orphaned packages found."
   fi
   
   # Clean journal logs
   log "Cleaning journal logs..."
   run_cmd "sudo journalctl --vacuum-size=500M" || log "Warning: Journal cleanup failed"
   
   # Check disk space
   log "Checking disk space..."
   df -h | grep -v tmpfs | tee -a "$LOG_FILE"
   
   # Check for failed services
   log "Checking for failed services..."
   FAILED_SERVICES=$(systemctl --failed)
   echo "$FAILED_SERVICES" | tee -a "$LOG_FILE"
   if [ "$(echo "$FAILED_SERVICES" | grep -c "0 loaded units listed")" -eq 0 ]; then
     handle_error "Failed services detected"
   fi
   
   # Check for high memory usage processes
   log "Checking for high memory usage processes..."
   ps aux --sort=-%mem | head -n 11 | tee -a "$LOG_FILE"
   
   # Check for file systems with low free space
   log "Checking for file systems with low free space..."
   df -h | awk '$5 > 80 {print}' | tee -a "$LOG_FILE"
   if [ "$(df -h | awk '$5 > 90 {print}' | wc -l)" -gt 0 ]; then
     handle_error "File systems with critically low free space detected"
   fi
   
   # Run fstrim for SSDs
   if [ -x "$(command -v fstrim)" ]; then
     log "Running fstrim on supported file systems..."
     run_cmd "sudo fstrim -av" || log "Warning: fstrim operation failed"
   fi
   
   # Backup config directory
   CONFIG_BACKUP_DIR="$HOME/system-maintenance/backups/configs-$(date +%Y%m%d)"
   log "Backing up configuration files to $CONFIG_BACKUP_DIR..."
   mkdir -p "$CONFIG_BACKUP_DIR"
   run_cmd "cp -r /etc/fstab $CONFIG_BACKUP_DIR/" || log "Warning: Failed to backup fstab"
   run_cmd "cp -r /etc/pacman.conf $CONFIG_BACKUP_DIR/" || log "Warning: Failed to backup pacman.conf"
   run_cmd "cp -r /etc/pacman.d/mirrorlist $CONFIG_BACKUP_DIR/" || log "Warning: Failed to backup mirrorlist"
   run_cmd "sudo cp -r /etc/systemd/system/maintenance* $CONFIG_BACKUP_DIR/" || log "Warning: Failed to backup systemd units"
   
   # Create a file system inventory
   FS_INVENTORY="$HOME/system-maintenance/docs/filesystem-inventory-$(date +%Y%m%d).txt"
   log "Creating file system inventory at $FS_INVENTORY..."
   echo "File System Inventory ($(date))" > "$FS_INVENTORY"
   echo "---------------------------------" >> "$FS_INVENTORY"
   echo -e "\nMounted File Systems:" >> "$FS_INVENTORY"
   findmnt -t ext4,btrfs,xfs,vfat >> "$FS_INVENTORY"
   echo -e "\nDisk Usage:" >> "$FS_INVENTORY"
   df -h >> "$FS_INVENTORY"
   echo -e "\nLargest Directories:" >> "$FS_INVENTORY"
   du -h /home --max-depth=2 2>/dev/null | sort -hr | head -20 >> "$FS_INVENTORY"
   
   log "Maintenance completed successfully"
   
   # Compress logs older than 30 days
   find "$LOG_DIR" -name "*.log" -type f -mtime +30 -exec gzip {} \;
   
   exit 0
   ```

3. **Set up Automated Maintenance with Systemd**:
   ```bash
   # Create systemd service file
   cat > ~/system-maintenance/maintenance.service << EOF
   [Unit]
   Description=System Maintenance Service
   After=network.target
   
   [Service]
   Type=oneshot
   ExecStart=/bin/bash /home/$(whoami)/system-maintenance/maintenance.sh
   
   [Install]
   WantedBy=multi-user.target
   EOF
   
   # Create systemd timer file
   cat > ~/system-maintenance/maintenance.timer << EOF
   [Unit]
   Description=Run system maintenance weekly
   
   [Timer]
   OnCalendar=Sun 03:00:00
   RandomizedDelaySec=900
   Persistent=true
   
   [Install]
   WantedBy=timers.target
   EOF
   
   # Install service and timer files
   mkdir -p ~/.config/systemd/user/
   cp ~/system-maintenance/maintenance.service ~/.config/systemd/user/
   cp ~/system-maintenance/maintenance.timer ~/.config/systemd/user/
   
   # Enable and start the timer
   systemctl --user daemon-reload
   systemctl --user enable maintenance.timer
   systemctl --user start maintenance.timer
   
   # Check timer status
   systemctl --user list-timers --all
   ```

4. **Create a Maintenance Documentation Template**:
   ```markdown
   # System Maintenance Documentation
   
   ## System Overview
   
   - **Hostname**: $(hostname)
   - **Operating System**: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)
   - **Kernel Version**: $(uname -r)
   - **Last Update**: $(date)
   
   ## Maintenance Schedule
   
   | Task | Frequency | Last Performed | Next Scheduled |
   |------|-----------|---------------|----------------|
   | System Updates | Weekly | YYYY-MM-DD | YYYY-MM-DD |
   | Full System Backup | Monthly | YYYY-MM-DD | YYYY-MM-DD |
   | Configuration Backup | Weekly | YYYY-MM-DD | YYYY-MM-DD |
   | Filesystem Check | Quarterly | YYYY-MM-DD | YYYY-MM-DD |
   | Security Audit | Monthly | YYYY-MM-DD | YYYY-MM-DD |
   
   ## Critical Services
   
   | Service | Purpose | Status | Recovery Procedure |
   |---------|---------|--------|-------------------|
   | sshd | Remote access | Active | `systemctl restart sshd` |
   | nginx | Web server | Active | `systemctl restart nginx` |
   | postgresql | Database | Active | `systemctl restart postgresql` |
   
   ## Backup Strategy
   
   - **User Data**: Daily incremental, weekly full
   - **System Configuration**: Weekly
   - **Databases**: Daily with transaction logs
   - **Backup Storage**: Local + Offsite
   - **Retention Policy**: Daily (7 days), Weekly (4 weeks), Monthly (6 months)
   
   ## Maintenance Procedures
   
   ### System Update Procedure
   1. Create pre-update snapshot
   2. Update package database
   3. Apply updates
   4. Verify system functionality
   5. Document changes
   
   ### Emergency Recovery Procedures
   
   #### Boot Failure Recovery
   1. Boot from installation media
   2. Mount partitions
   3. Chroot into system
   4. Repair bootloader
   
   #### Data Recovery
   1. Identify backup source
   2. Verify backup integrity
   3. Restore from backup
   4. Verify restored data
   
   ## Contact Information
   
   - **Primary Administrator**: [Name] ([Email])
   - **Secondary Administrator**: [Name] ([Email])
   - **Emergency Contact**: [Phone Number]
   ```

## Performance Monitoring and Analysis Exercise

Create a comprehensive system for monitoring and analyzing performance on your Linux system.

### Tasks:

1. **Set up Prometheus and Node Exporter**:
   ```bash
   # Install Prometheus and Node Exporter
   sudo pacman -S prometheus prometheus-node-exporter
   
   # Configure Prometheus
   sudo mkdir -p /etc/prometheus
   
   # Create Prometheus configuration
   sudo tee /etc/prometheus/prometheus.yml > /dev/null << EOF
   global:
     scrape_interval: 15s
     evaluation_interval: 15s
   
   scrape_configs:
     - job_name: "prometheus"
       static_configs:
         - targets: ["localhost:9090"]
     
     - job_name: "node"
       static_configs:
         - targets: ["localhost:9100"]
   EOF
   
   # Create systemd service directory
   sudo mkdir -p /etc/systemd/system/prometheus.service.d/
   
   # Create override file for prometheus service
   sudo tee /etc/systemd/system/prometheus.service.d/override.conf > /dev/null << EOF
   [Service]
   ExecStart=
   ExecStart=/usr/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus/data
   EOF
   
   # Start and enable services
   sudo systemctl daemon-reload
   sudo systemctl enable prometheus
   sudo systemctl start prometheus
   sudo systemctl enable prometheus-node-exporter
   sudo systemctl start prometheus-node-exporter
   
   # Install Grafana
   sudo pacman -S grafana
   
   # Start and enable Grafana
   sudo systemctl enable grafana
   sudo systemctl start grafana
   ```

2. **Create a Performance Baseline Script**:
   ```bash
   #!/bin/bash
   # ~/performance-baseline.sh
   
   # Create directory for performance data
   PERF_DIR="$HOME/performance-data"
   mkdir -p "$PERF_DIR"
   
   # Date for file naming
   DATE=$(date +%Y%m%d-%H%M%S)
   
   echo "Creating performance baseline on $(date)"
   echo "======================================="
   
   # System information
   echo "System Information:" > "$PERF_DIR/system-info-$DATE.txt"
   uname -a >> "$PERF_DIR/system-info-$DATE.txt"
   cat /proc/cpuinfo | grep "model name" | head -1 >> "$PERF_DIR/system-info-$DATE.txt"
   echo "Total Memory: $(free -h | grep Mem | awk '{print $2}')" >> "$PERF_DIR/system-info-$DATE.txt"
   
   # CPU baseline
   echo "CPU Baseline:" > "$PERF_DIR/cpu-baseline-$DATE.txt"
   echo "Current CPU frequency:" >> "$PERF_DIR/cpu-baseline-$DATE.txt"
   cat /proc/cpuinfo | grep "cpu MHz" >> "$PERF_DIR/cpu-baseline-$DATE.txt"
   echo "CPU governor:" >> "$PERF_DIR/cpu-baseline-$DATE.txt"
   cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >> "$PERF_DIR/cpu-baseline-$DATE.txt"
   echo "CPU load average (1, 5, 15 min):" >> "$PERF_DIR/cpu-baseline-$DATE.txt"
   cat /proc/loadavg >> "$PERF_DIR/cpu-baseline-$DATE.txt"
   echo "Top CPU-using processes:" >> "$PERF_DIR/cpu-baseline-$DATE.txt"
   ps aux --sort=-%cpu | head -11 >> "$PERF_DIR/cpu-baseline-$DATE.txt"
   
   # Memory baseline
   echo "Memory Baseline:" > "$PERF_DIR/memory-baseline-$DATE.txt"
   echo "Memory usage:" >> "$PERF_DIR/memory-baseline-$DATE.txt"
   free -h >> "$PERF_DIR/memory-baseline-$DATE.txt"
   echo "Swappiness: $(cat /proc/sys/vm/swappiness)" >> "$PERF_DIR/memory-baseline-$DATE.txt"
   echo "Top memory-using processes:" >> "$PERF_DIR/memory-baseline-$DATE.txt"
   ps aux --sort=-%mem | head -11 >> "$PERF_DIR/memory-baseline-$DATE.txt"
   
   # Disk baseline
   echo "Disk Baseline:" > "$PERF_DIR/disk-baseline-$DATE.txt"
   echo "Disk usage:" >> "$PERF_DIR/disk-baseline-$DATE.txt"
   df -h >> "$PERF_DIR/disk-baseline-$DATE.txt"
   echo "I/O scheduler per disk:" >> "$PERF_DIR/disk-baseline-$DATE.txt"
   for disk in $(lsblk -d -o name | grep -v NAME); do
     echo "$disk: $(cat /sys/block/$disk/queue/scheduler 2>/dev/null || echo "N/A")" >> "$PERF_DIR/disk-baseline-$DATE.txt"
   done
   echo "Current disk I/O:" >> "$PERF_DIR/disk-baseline-$DATE.txt"
   iostat -x >> "$PERF_DIR/disk-baseline-$DATE.txt"
   
   # Network baseline
   echo "Network Baseline:" > "$PERF_DIR/network-baseline-$DATE.txt"
   echo "Network interfaces:" >> "$PERF_DIR/network-baseline-$DATE.txt"
   ip -br addr >> "$PERF_DIR/network-baseline-$DATE.txt"
   echo "Network statistics:" >> "$PERF_DIR/network-baseline-$DATE.txt"
   netstat -tuln >> "$PERF_DIR/network-baseline-$DATE.txt"
   echo "Current network throughput:" >> "$PERF_DIR/network-baseline-$DATE.txt"
   sar -n DEV 1 5 >> "$PERF_DIR/network-baseline-$DATE.txt"
   
   # Benchmark tests
   echo "Running basic benchmarks..."
   
   # CPU benchmark
   echo "CPU Benchmark:" > "$PERF_DIR/cpu-benchmark-$DATE.txt"
   echo "Running dd to test CPU..." >> "$PERF_DIR/cpu-benchmark-$DATE.txt"
   dd if=/dev/zero bs=1M count=1024 | md5sum > /dev/null 2>> "$PERF_DIR/cpu-benchmark-$DATE.txt"
   
   # Memory benchmark
   echo "Memory Benchmark:" > "$PERF_DIR/memory-benchmark-$DATE.txt"
   echo "Running dd to test memory read/write..." >> "$PERF_DIR/memory-benchmark-$DATE.txt"
   dd if=/dev/zero of=/dev/shm/test bs=1M count=1024 conv=fdatasync > /dev/null 2>> "$PERF_DIR/memory-benchmark-$DATE.txt"
   rm -f /dev/shm/test
   
   # Disk benchmark
   echo "Disk Benchmark:" > "$PERF_DIR/disk-benchmark-$DATE.txt"
   echo "Running dd to test disk write speed..." >> "$PERF_DIR/disk-benchmark-$DATE.txt"
   dd if=/dev/zero of=/tmp/test bs=1M count=1024 conv=fdatasync > /dev/null 2>> "$PERF_DIR/disk-benchmark-$DATE.txt"
   echo "Running dd to test disk read speed..." >> "$PERF_DIR/disk-benchmark-$DATE.txt"
   dd if=/tmp/test of=/dev/null bs=1M > /dev/null 2>> "$PERF_DIR/disk-benchmark-$DATE.txt"
   rm -f /tmp/test
   
   echo "Performance baseline completed"
   echo "Results saved to $PERF_DIR"
   
   # Create summary report
   cat > "$PERF_DIR/summary-$DATE.txt" << EOF
   Performance Baseline Summary
   ============================
   Date: $(date)
   Hostname: $(hostname)
   
   CPU: $(cat /proc/cpuinfo | grep "model name" | head -1 | cut -d: -f2 | xargs)
   Memory: $(free -h | grep Mem | awk '{print $2}')
   Load Average: $(cat /proc/loadavg | cut -d' ' -f1-3)
   Swappiness: $(cat /proc/sys/vm/swappiness)
   
   Disk Space:
   $(df -h / | grep -v Filesystem)
   
   Top CPU Process:
   $(ps aux --sort=-%cpu | head -2 | tail -1)
   
   Top Memory Process:
   $(ps aux --sort=-%mem | head -2 | tail -1)
   
   See individual files for detailed information.
   EOF
   
   echo "Summary report created at $PERF_DIR/summary-$DATE.txt"
   ```

3. **Create Stress Testing Script for Performance Analysis**:
   ```bash
   #!/bin/bash
   # ~/performance-stress-test.sh
   
   # Function to check if tool is installed
   check_tool() {
     if ! command -v $1 &> /dev/null; then
       echo "Error: $1 is not installed. Install it with 'sudo pacman -S $2'"
       exit 1
     fi
   }
   
   # Check for required tools
   check_tool "stress" "stress"
   check_tool "mpstat" "sysstat"
   check_tool "sar" "sysstat"
   
   # Create output directory
   OUTDIR="$HOME/stress-test-results"
   mkdir -p "$OUTDIR"
   DATE=$(date +%Y%m%d-%H%M%S)
   
   echo "Starting stress tests at $(date)"
   echo "Results will be saved to $OUTDIR"
   
   # Function to monitor system during test
   monitor_system() {
     local TEST_NAME=$1
     local DURATION=$2
     local OUTPUT_FILE="$OUTDIR/$TEST_NAME-$DATE.txt"
     
     echo "Running $TEST_NAME test for $DURATION seconds"
     echo "$TEST_NAME Test Results ($(date))" > "$OUTPUT_FILE"
     echo "Duration: $DURATION seconds" >> "$OUTPUT_FILE"
     echo "-----------------------------------" >> "$OUTPUT_FILE"
     
     # Start monitoring in background
     echo "CPU Utilization:" >> "$OUTPUT_FILE"
     mpstat 5 $((DURATION/5)) >> "$OUTPUT_FILE" &
     MPSTAT_PID=$!
     
     echo "Memory Usage:" >> "$OUTPUT_FILE"
     MEMORY_FILE="$OUTDIR/$TEST_NAME-memory-$DATE.txt"
     (for i in $(seq 1 $((DURATION/5))); do
        free -m >> "$MEMORY_FILE"
        echo "---------" >> "$MEMORY_FILE"
        sleep 5
     done) &
     MEMORY_PID=$!
     
     echo "Disk I/O:" >> "$OUTPUT_FILE"
     sar -d 5 $((DURATION/5)) >> "$OUTPUT_FILE" &
     DISK_PID=$!
     
     # Let monitors run to completion
     wait $MPSTAT_PID
     wait $MEMORY_PID
     wait $DISK_PID
     
     cat "$MEMORY_FILE" >> "$OUTPUT_FILE"
     rm "$MEMORY_FILE"
     
     echo "Test completed at $(date)" >> "$OUTPUT_FILE"
     echo "===============================" >> "$OUTPUT_FILE"
   }
   
   # Create baseline before testing
   echo "Creating baseline measurements..."
   ~/performance-baseline.sh
   
   # CPU Stress Test
   echo "Starting CPU stress test..."
   DURATION=60
   monitor_system "cpu-stress" $DURATION &
   MONITOR_PID=$!
   # Start stress on all CPU cores
   NUM_CPUS=$(nproc)
   stress --cpu $NUM_CPUS --timeout ${DURATION}s
   wait $MONITOR_PID
   
   # Memory Stress Test
   echo "Starting memory stress test..."
   DURATION=60
   monitor_system "memory-stress" $DURATION &
   MONITOR_PID=$!
   # Calculate memory to use (80% of available)
   MEM_BYTES=$(free -b | grep Mem | awk '{print int($7 * 0.8)}')
   MEM_MB=$((MEM_BYTES / 1024 / 1024))
   VM_WORKERS=2
   MEM_PER_WORKER=$((MEM_MB / VM_WORKERS))
   stress --vm $VM_WORKERS --vm-bytes ${MEM_PER_WORKER}M --timeout ${DURATION}s
   wait $MONITOR_PID
   
   # I/O Stress Test
   echo "Starting I/O stress test..."
   DURATION=60
   monitor_system "io-stress" $DURATION &
   MONITOR_PID=$!
   stress --io 4 --timeout ${DURATION}s
   wait $MONITOR_PID
   
   # Combined Stress Test
   echo "Starting combined stress test..."
   DURATION=120
   monitor_system "combined-stress" $DURATION &
   MONITOR_PID=$!
   stress --cpu $((NUM_CPUS/2)) --vm 2 --vm-bytes ${MEM_PER_WORKER}M --io 2 --timeout ${DURATION}s
   wait $MONITOR_PID
   
   # Create baseline after testing to compare
   echo "Creating post-test baseline measurements..."
   ~/performance-baseline.sh
   
   echo "All stress tests completed. Results saved to $OUTDIR"
   ```

4. **Performance Tuning Exercise**:
   ```bash
   # Create a directory for performance tuning tests
   mkdir -p ~/performance-tuning
   cd ~/performance-tuning
   
   # Create a script to adjust CPU governor
   cat > adjust-cpu-governor.sh << 'EOF'
   #!/bin/bash
   
   # Save current settings
   echo "Current CPU Governor Settings:"
   for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
     echo "$cpu: $(cat $cpu)"
   done
   
   # Check if a governor was provided
   if [ $# -ne 1 ]; then
     echo "Usage: $0 [performance|powersave|ondemand|conservative|schedutil]"
     exit 1
   fi
   
   GOVERNOR=$1
   VALID_GOVERNORS="performance powersave ondemand conservative schedutil"
   
   # Validate governor
   if [[ ! $VALID_GOVERNORS =~ $GOVERNOR ]]; then
     echo "Error: Invalid governor specified."
     echo "Valid options: $VALID_GOVERNORS"
     exit 1
   fi
   
   # Set the governor
   echo "Setting CPU governor to $GOVERNOR..."
   for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
     echo -n "Setting $cpu to $GOVERNOR... "
     if sudo sh -c "echo $GOVERNOR > $cpu"; then
       echo "Success"
     else
       echo "Failed"
     fi
   done
   
   # Verify the change
   echo "New CPU Governor Settings:"
   for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
     echo "$cpu: $(cat $cpu)"
   done
   EOF
   
   chmod +x adjust-cpu-governor.sh
   
   # Create a script to adjust swappiness
   cat > adjust-swappiness.sh << 'EOF'
   #!/bin/bash
   
   # Save current setting
   CURRENT_SWAPPINESS=$(cat /proc/sys/vm/swappiness)
   echo "Current swappiness: $CURRENT_SWAPPINESS"
   
   # Check if a value was provided
   if [ $# -ne 1 ]; then
     echo "Usage: $0 [0-100]"
     echo "Recommended values:"
     echo "  Desktop system: 10-30"
     echo "  Server: 10-20"
     echo "  Database server: 1-10"
     exit 1
   fi
   
   NEW_SWAPPINESS=$1
   
   # Validate input
   if ! [[ "$NEW_SWAPPINESS" =~ ^[0-9]+$ ]] || [ "$NEW_SWAPPINESS" -gt 100 ]; then
     echo "Error: Swappiness must be a number between 0 and 100"
     exit 1
   fi
   
   # Set the swappiness
   echo "Setting swappiness to $NEW_SWAPPINESS..."
   if sudo sysctl -w vm.swappiness=$NEW_SWAPPINESS; then
     echo "Successfully set temporary swappiness value."
     
     # Make the change permanent
     echo -n "Making change permanent... "
     if echo "vm.swappiness=$NEW_SWAPPINESS" | sudo tee /etc/sysctl.d/99-swappiness.conf > /dev/null; then
       echo "Success"
     else
       echo "Failed to make change permanent"
     fi
   else
     echo "Failed to set swappiness"
     exit 1
   fi
   
   # Verify the change
   NEW_SETTING=$(cat /proc/sys/vm/swappiness)
   echo "New swappiness: $NEW_SETTING"
   EOF
   
   chmod +x adjust-swappiness.sh
   
   # Create a script to adjust I/O scheduler
   cat > adjust-io-scheduler.sh << 'EOF'
   #!/bin/bash
   
   # Save current settings
   echo "Current I/O Scheduler Settings:"
   for disk in $(lsblk -d -o name | grep -v NAME); do
     if [ -f /sys/block/$disk/queue/scheduler ]; then
       echo "$disk: $(cat /sys/block/$disk/queue/scheduler)"
     fi
   done
   
   # Check if arguments were provided
   if [ $# -lt 1 ]; then
     echo "Usage: $0 [scheduler] [disk1] [disk2] ..."
     echo "If no disks are specified, applies to all disks."
     echo "Available schedulers may include: mq-deadline, kyber, bfq, none"
     exit 1
   fi
   
   SCHEDULER=$1
   shift
   
   if [ $# -eq 0 ]; then
     # Apply to all disks
     DISKS=$(lsblk -d -o name | grep -v NAME)
   else
     # Apply to specified disks
     DISKS="$@"
   fi
   
   # Set the scheduler
   for disk in $DISKS; do
     if [ -f /sys/block/$disk/queue/scheduler ]; then
       echo -n "Setting $disk scheduler to $SCHEDULER... "
       if sudo sh -c "echo $SCHEDULER > /sys/block/$disk/queue/scheduler"; then
         echo "Success"
       else
         echo "Failed (scheduler may not be available for this disk)"
       fi
     else
       echo "Disk $disk not found or does not support scheduler changes"
     fi
   done
   
   # Verify the changes
   echo "New I/O Scheduler Settings:"
   for disk in $DISKS; do
     if [ -f /sys/block/$disk/queue/scheduler ]; then
       echo "$disk: $(cat /sys/block/$disk/queue/scheduler)"
     fi
   done
   
   # Make changes persistent
   echo -n "Making changes persistent across reboots... "
   
   # Check if GRUB is being used
   if [ -f /etc/default/grub ]; then
     # Create a backup
     sudo cp /etc/default/grub /etc/default/grub.bak
     
     # Update GRUB parameters
     GRUB_CMDLINE=$(sudo grep GRUB_CMDLINE_LINUX /etc/default/grub | grep -v GRUB_CMDLINE_LINUX_DEFAULT)
     
     if [ -z "$GRUB_CMDLINE" ]; then
       echo "Could not find GRUB_CMDLINE_LINUX in /etc/default/grub"
       echo "Manual configuration required for persistence"
     else
       # Remove existing elevator parameter if present
       NEW_CMDLINE=$(echo $GRUB_CMDLINE | sed 's/elevator=[^ "]*//g')
       
       # Add our scheduler parameter
       NEW_CMDLINE=$(echo $NEW_CMDLINE | sed "s/GRUB_CMDLINE_LINUX=\"/GRUB_CMDLINE_LINUX=\"elevator=$SCHEDULER /g")
       
       # Update the configuration
       sudo sed -i "s|$GRUB_CMDLINE|$NEW_CMDLINE|g" /etc/default/grub
       
       # Update GRUB
       if sudo grub-mkconfig -o /boot/grub/grub.cfg; then
         echo "Success (changes will apply after reboot)"
       else
         echo "Failed to update GRUB"
       fi
     fi
   else
     echo "GRUB configuration not found. Manual configuration required for persistence."
   fi
   EOF
   
   chmod +x adjust-io-scheduler.sh
   ```

## Backup and Recovery Exercise

Create and test a comprehensive backup system for your Linux installation.

### Tasks:

1. **Set up Borg Backup**:
   ```bash
   # Install borg
   sudo pacman -S borg
   
   # Create a directory for our backup repository
   sudo mkdir -p /mnt/backup/borg-repo
   sudo chown $USER:$USER /mnt/backup/borg-repo
   
   # Initialize the repository with encryption
   borg init --encryption=repokey-blake2 /mnt/backup/borg-repo
   
   # Create a backup script
   mkdir -p ~/backup-scripts
   cat > ~/backup-scripts/borg-backup.sh << 'EOF'
   #!/bin/bash
   
   # Backup configuration
   REPOSITORY="/mnt/backup/borg-repo"
   BACKUP_NAME="backup-$(date +%Y-%m-%d)"
   
   # Paths to backup
   BACKUP_PATHS="/home /etc /var/www /var/mail /root"
   
   # Paths to exclude
   EXCLUDES="--exclude /home/*/.cache \
            --exclude /home/*/.local/share/Trash \
            --exclude /home/*/.thumbnails \
            --exclude /home/*/.mozilla/firefox/*/Cache \
            --exclude /home/*/.config/google-chrome/*/Cache \
            --exclude /home/*/.config/chromium/*/Cache \
            --exclude /home/*/.npm \
            --exclude /home/*/.yarn/cache \
            --exclude /home/*/.cargo/registry \
            --exclude /home/*/.config/Code/CachedData \
            --exclude /home/*/.gradle \
            --exclude /home/*/.m2 \
            --exclude '*.pyc'"
   
   # Retention policy
   RETENTION="--keep-daily 7 --keep-weekly 4 --keep-monthly 6"
   
   # Log file
   LOG_FILE="/var/log/borg/backup-$(date +%Y-%m-%d).log"
   mkdir -p $(dirname $LOG_FILE)
   
   # Function to log messages
   log() {
     echo "$(date +%Y-%m-%d\ %H:%M:%S) $1" | tee -a "$LOG_FILE"
   }
   
   # Start backup
   log "Starting backup to $REPOSITORY::$BACKUP_NAME"
   log "Backing up: $BACKUP_PATHS"
   
   # Set environment variables for Borg
   export BORG_RELOCATED_REPO_ACCESS_IS_OK=yes
   export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes
   
   # Create the backup
   log "Creating backup..."
   borg create --verbose --stats --compression zstd,3 \
     $EXCLUDES \
     $REPOSITORY::$BACKUP_NAME \
     $BACKUP_PATHS 2>&1 | tee -a "$LOG_FILE"
   
   # Check for errors
   if [ ${PIPESTATUS[0]} -ne 0 ]; then
     log "Error creating backup!"
     exit 1
   fi
   
   # Prune old backups
   log "Pruning old backups according to retention policy..."
   borg prune --verbose --list $RETENTION $REPOSITORY 2>&1 | tee -a "$LOG_FILE"
   
   # Check the repository
   log "Running integrity check on repository..."
   borg check --verbose $REPOSITORY 2>&1 | tee -a "$LOG_FILE"
   
   # Backup completed
   log "Backup completed successfully!"
   EOF
   
   chmod +x ~/backup-scripts/borg-backup.sh
   
   # Create a systemd service for the backup
   sudo tee /etc/systemd/system/borg-backup.service > /dev/null << EOF
   [Unit]
   Description=Borg Backup Service
   After=network.target
   
   [Service]
   Type=oneshot
   ExecStart=/home/$USER/backup-scripts/borg-backup.sh
   User=$USER
   
   [Install]
   WantedBy=multi-user.target
   EOF
   
   # Create a systemd timer for daily backups
   sudo tee /etc/systemd/system/borg-backup.timer > /dev/null << EOF
   [Unit]
   Description=Borg Backup Timer
   
   [Timer]
   OnCalendar=*-*-* 01:00:00
   RandomizedDelaySec=1800
   Persistent=true
   
   [Install]
   WantedBy=timers.target
   EOF
   
   # Enable and start the timer
   sudo systemctl daemon-reload
   sudo systemctl enable borg-backup.timer
   sudo systemctl start borg-backup.timer
   ```

2. **Create Recovery Documentation and Test Script**:
   ```bash
   # Create recovery documentation
   mkdir -p ~/backup-scripts/docs
   cat > ~/backup-scripts/docs/recovery-guide.md << 'EOF'
   # Borg Backup Recovery Guide
   
   This guide provides instructions for recovering your data from Borg backups.
   
   ## Prerequisites
   
   - A working Linux system with Borg installed
   - Access to your Borg repository
   - The passphrase for your encrypted repository (if applicable)
   
   ## Basic Recovery Steps
   
   ### 1. List Available Archives
   
   First, you need to see what backups (archives) are available:
   
   ```bash
   borg list /path/to/repository
   ```
   
   ### 2. Extracting Files
   
   #### Restore a Single File
   
   ```bash
   borg extract /path/to/repository::archive-name path/to/file
   ```
   
   #### Restore a Directory
   
   ```bash
   borg extract /path/to/repository::archive-name path/to/directory
   ```
   
   #### Restore to a Different Location
   
   ```bash
   cd /path/to/extract/to
   borg extract /path/to/repository::archive-name
   ```
   
   #### Restore Specific Files
   
   ```bash
   borg extract /path/to/repository::archive-name home/user/Documents/important.txt etc/ssh/sshd_config
   ```
   
   ### 3. Mounting a Backup (Browse Without Extracting)
   
   ```bash
   mkdir -p /mnt/borgmount
   borg mount /path/to/repository::archive-name /mnt/borgmount
   
   # Browse files
   ls -la /mnt/borgmount
   
   # When done
   borg umount /mnt/borgmount
   ```
   
   ## Complete System Recovery
   
   For a complete system recovery, follow these steps:
   
   1. Boot from a live Linux system
   2. Install Borg: `sudo pacman -S borg` (on Arch-based systems)
   3. Mount your target partitions:
      ```bash
      mount /dev/sdaX /mnt       # Root partition
      mount /dev/sdaY /mnt/boot  # Boot partition (if separate)
      ```
   4. Extract the most recent backup:
      ```bash
      cd /mnt
      borg extract /path/to/repository::latest
      ```
   5. Ensure the boot loader is correctly configured:
      ```bash
      arch-chroot /mnt
      grub-install /dev/sda
      grub-mkconfig -o /boot/grub/grub.cfg
      exit
      ```
   6. Reboot into the recovered system
   
   ## Troubleshooting
   
   ### Repository Lock Issues
   
   If a backup was interrupted, the repository might be locked. Unlock it with:
   
   ```bash
   borg break-lock /path/to/repository
   ```
   
   ### Forgotten Passphrase
   
   If you used the `repokey` encryption mode, the key is stored in the repository but still requires your passphrase. There is no way to recover a lost passphrase.
   
   ### Corrupted Repository
   
   If your repository is corrupted, try to repair it:
   
   ```bash
   borg check --repair /path/to/repository
   ```
   
   ## Regular Recovery Testing
   
   It's important to regularly test your recovery process to ensure it works when needed:
   
   1. Schedule monthly recovery tests
   2. Document each test and its results
   3. Update your recovery procedures based on test findings
   
   Remember: An untested backup is not a reliable backup!
   EOF
   
   # Create backup verification script
   cat > ~/backup-scripts/verify-backup.sh << 'EOF'
   #!/bin/bash
   
   # Configuration
   REPOSITORY="/mnt/backup/borg-repo"
   TEST_EXTRACT_DIR="/tmp/borg-test-extract"
   LOG_FILE="/var/log/borg/verify-$(date +%Y-%m-%d).log"
   mkdir -p $(dirname $LOG_FILE)
   
   # Important files to test restore
   TEST_FILES=(
     "/etc/passwd"
     "/etc/fstab"
     "/etc/ssh/sshd_config"
     "/home/$USER/.bashrc"
   )
   
   # Function to log messages
   log() {
     echo "$(date +%Y-%m-%d\ %H:%M:%S) $1" | tee -a "$LOG_FILE"
   }
   
   # Start verification
   log "Starting backup verification"
   
   # Check if repository exists
   if [ ! -d "$REPOSITORY" ]; then
     log "Error: Repository not found at $REPOSITORY"
     exit 1
   fi
   
   # List backups
   log "Listing available backups:"
   borg list $REPOSITORY | tee -a "$LOG_FILE"
   
   # Get the most recent backup
   LATEST_BACKUP=$(borg list --short $REPOSITORY | tail -n1)
   if [ -z "$LATEST_BACKUP" ]; then
     log "Error: No backups found in repository"
     exit 1
   fi
   log "Latest backup: $LATEST_BACKUP"
   
   # Verify repository integrity
   log "Verifying repository integrity..."
   borg check $REPOSITORY::$LATEST_BACKUP | tee -a "$LOG_FILE"
   if [ ${PIPESTATUS[0]} -ne 0 ]; then
     log "Error: Repository integrity check failed!"
     exit 1
   fi
   
   # Create test extract directory
   log "Creating test extraction directory..."
   rm -rf "$TEST_EXTRACT_DIR"
   mkdir -p "$TEST_EXTRACT_DIR"
   
   # Mount the backup for browsing
   log "Mounting backup for browsing..."
   mkdir -p "$TEST_EXTRACT_DIR/mount"
   borg mount $REPOSITORY::$LATEST_BACKUP "$TEST_EXTRACT_DIR/mount"
   if [ $? -ne 0 ]; then
     log "Error: Failed to mount backup"
     exit 1
   fi
   
   # Test browsing mounted backup
   log "Checking mounted backup content..."
   ls -la "$TEST_EXTRACT_DIR/mount" | tee -a "$LOG_FILE"
   ls -la "$TEST_EXTRACT_DIR/mount/home" | tee -a "$LOG_FILE"
   
   # Unmount backup
   log "Unmounting backup..."
   borg umount "$TEST_EXTRACT_DIR/mount"
   
   # Test extracting specific files
   log "Testing extraction of specific files..."
   for file in "${TEST_FILES[@]}"; do
     log "Extracting $file..."
     mkdir -p "$TEST_EXTRACT_DIR$(dirname "$file")"
     borg extract --stdout $REPOSITORY::$LATEST_BACKUP "${file#/}" > "$TEST_EXTRACT_DIR$file"
     if [ $? -eq 0 ]; then
       log "Successfully extracted $file"
       log "File content verification (first 5 lines):"
       head -5 "$TEST_EXTRACT_DIR$file" | tee -a "$LOG_FILE"
     else
       log "Error: Failed to extract $file"
     fi
   done
   
   # Test a simulated recovery
   log "Testing simulated partial recovery..."
   mkdir -p "$TEST_EXTRACT_DIR/recovery"
   cd "$TEST_EXTRACT_DIR/recovery"
   borg extract $REPOSITORY::$LATEST_BACKUP home/$(whoami)/Documents --strip-components 2
   if [ $? -eq 0 ]; then
     log "Simulated recovery successful"
     log "Recovered files:"
     find . -type f | head -10 | tee -a "$LOG_FILE"
   else
     log "Error: Simulated recovery failed"
   fi
   
   # Clean up
   log "Cleaning up..."
   rm -rf "$TEST_EXTRACT_DIR"
   
   # Final assessment
   log "Backup verification completed"
   log "Overall assessment: Backup appears to be valid and recoverable"
   
   echo "Verification complete. See $LOG_FILE for details."
   EOF
   
   chmod +x ~/backup-scripts/verify-backup.sh
   ```

3. **Create an Offsite Backup Script**:
   ```bash
   # Create a script for offsite backup to a remote server
   cat > ~/backup-scripts/offsite-backup.sh << 'EOF'
   #!/bin/bash
   
   # Configuration
   LOCAL_REPO="/mnt/backup/borg-repo"
   REMOTE_USER="your-username"
   REMOTE_HOST="your-remote-server"
   REMOTE_PATH="/path/to/remote/backup"
   REMOTE_REPO="$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH"
   LOG_FILE="/var/log/borg/offsite-$(date +%Y-%m-%d).log"
   
   mkdir -p $(dirname $LOG_FILE)
   
   # Function to log messages
   log() {
     echo "$(date +%Y-%m-%d\ %H:%M:%S) $1" | tee -a "$LOG_FILE"
   }
   
   # Start offsite backup
   log "Starting offsite backup to $REMOTE_REPO"
   
   # Check if local repository exists
   if [ ! -d "$LOCAL_REPO" ]; then
     log "Error: Local repository not found at $LOCAL_REPO"
     exit 1
   fi
   
   # Check SSH connection
   log "Testing SSH connection to remote host..."
   ssh -q "$REMOTE_USER@$REMOTE_HOST" exit
   if [ $? -ne 0 ]; then
     log "Error: Could not connect to remote host"
     exit 1
   fi
   
   # Ensure remote directory exists
   log "Ensuring remote directory exists..."
   ssh "$REMOTE_USER@$REMOTE_HOST" "mkdir -p $REMOTE_PATH"
   
   # Transfer the repository
   log "Transferring repository to remote host..."
   rsync -avz --delete --progress "$LOCAL_REPO/" "$REMOTE_REPO/" 2>&1 | tee -a "$LOG_FILE"
   
   # Check for errors
   if [ ${PIPESTATUS[0]} -ne 0 ]; then
     log "Error: Repository transfer failed!"
     exit 1
   fi
   
   # Verify remote repository
   log "Verifying remote repository..."
   ssh "$REMOTE_USER@$REMOTE_HOST" "borg check $REMOTE_PATH" 2>&1 | tee -a "$LOG_FILE"
   
   # Backup completed
   log "Offsite backup completed successfully!"
   EOF
   
   chmod +x ~/backup-scripts/offsite-backup.sh
   ```

4. **Create a Disaster Recovery Test Plan**:
   ```markdown
   # Disaster Recovery Test Plan
   
   This document outlines the procedure for testing the disaster recovery process, which should be performed quarterly.
   
   ## Preparation
   
   1. Schedule a maintenance window for the test
   2. Notify all stakeholders about the test
   3. Create a current backup before starting
   4. Prepare a test environment (virtual machine or spare hardware)
   
   ## Testing Procedure
   
   ### Basic Recovery Test
   
   1. **Setup Test Environment**
      - Boot from Arch Linux live media
      - Verify network connectivity
      - Install required tools: `pacman -Sy borg rsync arch-install-scripts`
   
   2. **Prepare Storage**
      - Create/format partitions similar to production
      - Mount partitions to /mnt
   
   3. **Recover from Backup**
      - Retrieve the Borg repository
      - Extract the latest backup: `cd /mnt && borg extract /path/to/repo::latest`
      - Verify all critical files were restored
   
   4. **Configure Bootloader**
      - Chroot into the recovered system: `arch-chroot /mnt`
      - Install and configure bootloader: `grub-install && grub-mkconfig -o /boot/grub/grub.cfg`
      - Exit chroot: `exit`
   
   5. **Boot and Verify**
      - Reboot into the recovered system
      - Verify all services start correctly
      - Validate file integrity
      - Test application functionality
   
   ### Advanced Recovery Scenarios
   
   For each test, document:
   - Time taken to recover
   - Any issues encountered
   - Solutions implemented
   
   #### Scenario 1: Partial File Recovery
   - Simulate accidental deletion of important files
   - Recover only those files from backup
   - Verify file integrity and functionality
   
   #### Scenario 2: System Configuration Recovery
   - Simulate configuration corruption
   - Recover system configuration files
   - Verify system functionality
   
   #### Scenario 3: Complete System Failure
   - Simulate complete system failure
   - Perform full system recovery
   - Measure time to restore operation
   
   #### Scenario 4: Remote Site Recovery
   - Simulate primary site unavailability
   - Recover using offsite backups
   - Verify recovery process works with offsite data
   
   ## Documentation
   
   For each test, create a detailed report including:
   
   1. **Executive Summary**
      - Overall success/failure
      - Key metrics (recovery time, data integrity)
      - Major issues encountered
   
   2. **Detailed Procedure Log**
      - Step-by-step actions taken
      - Commands used
      - Output/results
   
   3. **Issue Tracking**
      - Problems encountered
      - Solutions implemented
      - Unresolved issues
   
   4. **Recommendations**
      - Process improvements
      - Tool/script enhancements
      - Training requirements
   
   ## Follow-up Actions
   
   After each test:
   
   1. Update recovery documentation based on findings
   2. Address any issues discovered
   3. Implement recommended improvements
   4. Schedule next test
   
   Remember: Regular testing is essential to ensure your recovery process works when needed!
   ```

## Automated Maintenance and Log Management Exercise

Create a comprehensive system for managing logs and automating maintenance tasks.

### Tasks:

1. **Set up Advanced Log Management**:
   ```bash
   # Install necessary tools
   sudo pacman -S lnav logrotate

   # Create a central log directory for analysis
   mkdir -p ~/log-analysis
   
   # Create a log analysis script
   cat > ~/log-analysis/analyze-logs.sh << 'EOF'
   #!/bin/bash
   
   # Configuration
   OUTPUT_DIR=~/log-analysis/reports
   DATE=$(date +%Y%m%d)
   LOG_SOURCES=(
     /var/log/syslog
     /var/log/auth.log
     /var/log/kern.log
     /var/log/dmesg
     /var/log/httpd
     /var/log/nginx
     ~/.local/share/systemd/user
   )
   
   # Create output directory
   mkdir -p $OUTPUT_DIR
   
   # Colorization function
   colorize() {
     local text=$1
     local color=$2
     case $color in
       red)    echo -e "\e[31m$text\e[0m" ;;
       green)  echo -e "\e[32m$text\e[0m" ;;
       yellow) echo -e "\e[33m$text\e[0m" ;;
       blue)   echo -e "\e[34m$text\e[0m" ;;
       *)      echo "$text" ;;
     esac
   }
   
   # Create report header
   cat > $OUTPUT_DIR/log-report-$DATE.txt << EOH
   =======================================
      System Log Analysis Report
      Generated: $(date)
      Hostname: $(hostname)
   =======================================
   
   EOH
   
   # Function to check if a log file exists and is readable
   check_log() {
     if [ -r "$1" ]; then
       return 0
     elif [ -d "$1" ]; then
       # It's a directory, check if there are log files inside
       if [ -n "$(find "$1" -name "*.log" -type f -readable 2>/dev/null)" ]; then
         return 0
       else
         return 1
       fi
     else
       return 1
     fi
   }
   
   # Analyze logs for errors
   echo "Analyzing logs for errors and warnings..."
   
   echo -e "\n== ERROR SUMMARY ==" >> $OUTPUT_DIR/log-report-$DATE.txt
   
   for source in "${LOG_SOURCES[@]}"; do
     if check_log "$source"; then
       echo -e "\n=== Errors in $source ===\n" >> $OUTPUT_DIR/log-report-$DATE.txt
       
       if [ -d "$source" ]; then
         # Process all log files in directory
         for log_file in $(find "$source" -name "*.log" -type f -readable 2>/dev/null); do
           # Count errors and warnings
           ERROR_COUNT=$(grep -i "error" "$log_file" | wc -l)
           WARNING_COUNT=$(grep -i "warn" "$log_file" | wc -l)
           FAIL_COUNT=$(grep -i "fail" "$log_file" | wc -l)
           
           echo "File: $(basename "$log_file")" >> $OUTPUT_DIR/log-report-$DATE.txt
           echo "- Errors: $ERROR_COUNT" >> $OUTPUT_DIR/log-report-$DATE.txt
           echo "- Warnings: $WARNING_COUNT" >> $OUTPUT_DIR/log-report-$DATE.txt
           echo "- Failures: $FAIL_COUNT" >> $OUTPUT_DIR/log-report-$DATE.txt
           
           # Report most recent errors
           if [ $ERROR_COUNT -gt 0 ]; then
             echo -e "\nMost recent errors:" >> $OUTPUT_DIR/log-report-$DATE.txt
             grep -i "error" "$log_file" | tail -5 >> $OUTPUT_DIR/log-report-$DATE.txt
           fi
         done
       else
         # Process single log file
         ERROR_COUNT=$(grep -i "error" "$source" | wc -l)
         WARNING_COUNT=$(grep -i "warn" "$source" | wc -l)
         FAIL_COUNT=$(grep -i "fail" "$source" | wc -l)
         
         echo "- Errors: $ERROR_COUNT" >> $OUTPUT_DIR/log-report-$DATE.txt
         echo "- Warnings: $WARNING_COUNT" >> $OUTPUT_DIR/log-report-$DATE.txt
         echo "- Failures: $FAIL_COUNT" >> $OUTPUT_DIR/log-report-$DATE.txt
         
         # Report most recent errors
         if [ $ERROR_COUNT -gt 0 ]; then
           echo -e "\nMost recent errors:" >> $OUTPUT_DIR/log-report-$DATE.txt
           grep -i "error" "$source" | tail -5 >> $OUTPUT_DIR/log-report-$DATE.txt
         fi
       fi
     else
       echo -e "\n=== Could not access $source ===\n" >> $OUTPUT_DIR/log-report-$DATE.txt
     fi
   done
   
   # Check for login failures
   echo -e "\n== LOGIN FAILURES ==" >> $OUTPUT_DIR/log-report-$DATE.txt
   if [ -r /var/log/auth.log ]; then
     FAILURE_COUNT=$(grep -i "failed" /var/log/auth.log | wc -l)
     echo "Failed login attempts: $FAILURE_COUNT" >> $OUTPUT_DIR/log-report-$DATE.txt
     
     if [ $FAILURE_COUNT -gt 0 ]; then
       echo -e "\nMost recent failures:" >> $OUTPUT_DIR/log-report-$DATE.txt
       grep -i "failed" /var/log/auth.log | tail -5 >> $OUTPUT_DIR/log-report-$DATE.txt
     fi
   else
     echo "Could not access auth log" >> $OUTPUT_DIR/log-report-$DATE.txt
   fi
   
   # Check for system reboots
   echo -e "\n== SYSTEM REBOOTS ==" >> $OUTPUT_DIR/log-report-$DATE.txt
   last reboot | head -5 >> $OUTPUT_DIR/log-report-$DATE.txt
   
   # Check for disk space issues
   echo -e "\n== DISK SPACE ==" >> $OUTPUT_DIR/log-report-$DATE.txt
   df -h | grep -v tmpfs >> $OUTPUT_DIR/log-report-$DATE.txt
   
   # Check for high CPU/memory usage events
   echo -e "\n== RESOURCE USAGE EVENTS ==" >> $OUTPUT_DIR/log-report-$DATE.txt
   if [ -r /var/log/syslog ]; then
     grep -i "out of memory" /var/log/syslog >> $OUTPUT_DIR/log-report-$DATE.txt || echo "No OOM events found" >> $OUTPUT_DIR/log-report-$DATE.txt
   fi
   
   # Check systemd journal for errors
   echo -e "\n== SYSTEMD JOURNAL ERRORS ==" >> $OUTPUT_DIR/log-report-$DATE.txt
   journalctl -p 3 -S "24 hours ago" --no-pager | tail -20 >> $OUTPUT_DIR/log-report-$DATE.txt
   
   # Create symlink to latest report
   ln -sf $OUTPUT_DIR/log-report-$DATE.txt $OUTPUT_DIR/log-report-latest.txt
   
   echo "Log analysis completed. Report saved to $OUTPUT_DIR/log-report-$DATE.txt"
   
   # Option to view in lnav if it's installed
   if command -v lnav &> /dev/null && [ -t 1 ]; then
     read -p "Would you like to view logs interactively with lnav? (y/n) " -n 1 -r
     echo
     if [[ $REPLY =~ ^[Yy]$ ]]; then
       # Create a list of readable log files
       READABLE_LOGS=()
       for source in "${LOG_SOURCES[@]}"; do
         if [ -r "$source" ] && [ -f "$source" ]; then
           READABLE_LOGS+=("$source")
         elif [ -d "$source" ]; then
           # Add all readable log files in directory
           while IFS= read -r file; do
             READABLE_LOGS+=("$file")
           done < <(find "$source" -name "*.log" -type f -readable 2>/dev/null)
         fi
       done
       
       # Launch lnav with readable logs
       if [ ${#READABLE_LOGS[@]} -gt 0 ]; then
         lnav "${READABLE_LOGS[@]}"
       else
         echo "No readable log files found"
       fi
     fi
   fi
   EOF
   
   chmod +x ~/log-analysis/analyze-logs.sh
   
   # Create a custom logrotate configuration
   sudo tee /etc/logrotate.d/custom-logs > /dev/null << EOF
   # Custom log rotation configuration
   
   /home/$USER/logs/*.log {
     weekly
     rotate 4
     compress
     delaycompress
     missingok
     notifempty
     create 640 $USER users
   }
   
   /var/log/custom/*.log {
     daily
     rotate 7
     compress
     delaycompress
     missingok
     notifempty
     create 640 root adm
     postrotate
       systemctl reload rsyslog >/dev/null 2>&1 || true
     endscript
   }
   EOF
   ```

2. **Create a Comprehensive System Maintenance Dashboard**:
   ```bash
   mkdir -p ~/maintenance-dashboard
   
   # Create the dashboard script
   cat > ~/maintenance-dashboard/system-dashboard.sh << 'EOF'
   #!/bin/bash
   
   # Terminal colors
   RED='\033[0;31m'
   GREEN='\033[0;32m'
   YELLOW='\033[0;33m'
   BLUE='\033[0;34m'
   MAGENTA='\033[0;35m'
   CYAN='\033[0;36m'
   CLEAR='\033[0m'
   
   # Title display function
   title() {
     local text="$1"
     local width=$(tput cols)
     local padding=$(( (width - ${#text} - 4) / 2 ))
     
     printf "\n${BLUE}%${padding}s %s %${padding}s${CLEAR}\n" "==" "$text" "=="
   }
   
   # Section display function
   section() {
     local text="$1"
     printf "\n${CYAN}=== %s ===${CLEAR}\n" "$text"
   }
   
   # OK/WARNING/ERROR status function
   status() {
     local state=$1
     case $state in
       0) echo -e "[${GREEN}OK${CLEAR}]" ;;
       1) echo -e "[${YELLOW}WARNING${CLEAR}]" ;;
       2) echo -e "[${RED}ERROR${CLEAR}]" ;;
       *) echo -e "[${BLUE}UNKNOWN${CLEAR}]" ;;
     esac
   }
   
   # Percentage bar function
   percentage_bar() {
     local value=$1
     local max_width=30
     local bar_width=$((value * max_width / 100))
     
     if [ $value -lt 70 ]; then
       local color=$GREEN
     elif [ $value -lt 90 ]; then
       local color=$YELLOW
     else
       local color=$RED
     fi
     
     printf "["
     printf "${color}"
     for ((i=0; i<bar_width; i++)); do
       printf "#"
     done
     printf "${CLEAR}"
     for ((i=bar_width; i<max_width; i++)); do
       printf " "
     done
     printf "] %3d%%\n" $value
   }
   
   # Main dashboard display
   clear
   title "SYSTEM MAINTENANCE DASHBOARD"
   echo -e "Hostname: $(hostname)"
   echo -e "Kernel: $(uname -r)"
   echo -e "Uptime: $(uptime -p)"
   echo -e "Last Update: $(date -r /var/log/pacman.log '+%Y-%m-%d %H:%M:%S')"
   
   # System update status
   section "System Updates"
   if sudo pacman -Sy > /dev/null; then
     UPDATES=$(pacman -Qu | wc -l)
     if [ $UPDATES -eq 0 ]; then
       echo -e "System is up to date. $(status 0)"
     else
       echo -e "Available updates: $UPDATES $(status 1)"
       echo "Most recent packages that need updating:"
       pacman -Qu | head -5
     fi
   else
     echo -e "Failed to check for updates. $(status 2)"
   fi
   
   # Disk space
   section "Disk Space"
   df -h | grep -v tmpfs | grep -v devtmpfs | (
     read header
     echo "$header"
     while read line; do
       # Extract usage percentage
       usage=$(echo $line | awk '{print $5}' | sed 's/%//')
       if [ $usage -lt 70 ]; then
         status_code=0
       elif [ $usage -lt 90 ]; then
         status_code=1
       else
         status_code=2
       fi
       echo -e "$line $(status $status_code)"
     done
   )
   
   # Memory usage
   section "Memory Usage"
   memory_info=$(free -m)
   total_mem=$(echo "$memory_info" | grep Mem | awk '{print $2}')
   used_mem=$(echo "$memory_info" | grep Mem | awk '{print $3}')
   usage_percent=$((used_mem * 100 / total_mem))
   
   echo -e "Memory Usage (${used_mem}M / ${total_mem}M):"
   percentage_bar $usage_percent
   
   # Show swap usage
   swap_total=$(echo "$memory_info" | grep Swap | awk '{print $2}')
   if [ $swap_total -gt 0 ]; then
     swap_used=$(echo "$memory_info" | grep Swap | awk '{print $3}')
     swap_percent=$((swap_used * 100 / swap_total))
     echo -e "Swap Usage (${swap_used}M / ${swap_total}M):"
     percentage_bar $swap_percent
   else
     echo -e "Swap: Not configured"
   fi
   
   # CPU Load
   section "CPU Load"
   load_avg=$(cat /proc/loadavg | cut -d' ' -f1-3)
   cpu_count=$(nproc)
   load_1=$(echo $load_avg | cut -d' ' -f1)
   load_1_percent=$(echo "$load_1 $cpu_count" | awk '{printf "%d", $1 * 100 / $2}')
   
   echo -e "Load Average (1, 5, 15 min): $load_avg"
   echo -e "Current CPU Usage (${load_1}/${cpu_count}):"
   percentage_bar $load_1_percent
   
   # Top processes
   section "Top Processes"
   echo -e "Top CPU processes:"
   ps -eo pid,ppid,%cpu,%mem,cmd --sort=-%cpu | head -6
   
   echo -e "\nTop memory processes:"
   ps -eo pid,ppid,%cpu,%mem,cmd --sort=-%mem | head -6
   
   # Service health
   section "Service Health"
   failed_services=$(systemctl --failed --no-legend | wc -l)
   if [ $failed_services -eq 0 ]; then
     echo -e "All services are running. $(status 0)"
   else
     echo -e "Failed services: $failed_services $(status 2)"
     systemctl --failed --no-legend
   fi
   
   # System logs
   section "System Logs"
   echo -e "Recent errors from journal:"
   journalctl -p 3 -S "1 hour ago" --no-pager | tail -5
   
   # Recent user logins
   section "Recent Logins"
   last | head -5
   
   # Backup status
   section "Backup Status"
   last_backup_file=$(find /mnt/backup -type d -name "borg-repo" -exec ls -t {}/data/0/@@@ \; 2>/dev/null | head -1)
   if [ -n "$last_backup_file" ]; then
     last_backup_time=$(date -r "$last_backup_file" '+%Y-%m-%d %H:%M:%S')
     seconds_since=$(($(date +%s) - $(date -r "$last_backup_file" +%s)))
     days_since=$((seconds_since / 86400))
     
     if [ $days_since -lt 1 ]; then
       echo -e "Last backup: $last_backup_time (< 1 day ago) $(status 0)"
     elif [ $days_since -lt 7 ]; then
       echo -e "Last backup: $last_backup_time ($days_since days ago) $(status 0)"
     elif [ $days_since -lt 14 ]; then
       echo -e "Last backup: $last_backup_time ($days_since days ago) $(status 1)"
     else
       echo -e "Last backup: $last_backup_time ($days_since days ago) $(status 2)"
     fi
   else
     echo -e "No backup information found. $(status 2)"
   fi
   
   # Maintenance recommendations
   section "Maintenance Recommendations"
   
   # Check for old logs
   old_logs=$(find /var/log -type f -name "*.gz" -mtime +30 | wc -l)
   if [ $old_logs -gt 10 ]; then
     echo -e "- $(status 1) Clear old logs: $old_logs compressed log files older than 30 days"
   fi
   
   # Check for orphaned packages
   orphans=$(pacman -Qtdq 2>/dev/null | wc -l)
   if [ $orphans -gt 0 ]; then
     echo -e "- $(status 1) Remove orphaned packages: $orphans packages no longer required"
   fi
   
   # Check package cache size
   cache_size=$(du -sh /var/cache/pacman/pkg/ | cut -f1)
   echo -e "- Package cache size: $cache_size"
   
   # Check for large files in home
   large_files=$(find $HOME -type f -size +100M | wc -l)
   if [ $large_files -gt 10 ]; then
     echo -e "- $(status 1) Review large files: $large_files files larger than 100MB in home directory"
   fi
   
   # Check for disk health if smartctl is available
   if command -v smartctl &> /dev/null; then
     failed_disks=0
     for disk in $(lsblk -d -o name | grep -v NAME | grep -v loop); do
       if sudo smartctl -H /dev/$disk | grep -q "FAILED"; then
         failed_disks=$((failed_disks + 1))
       fi
     done
     if [ $failed_disks -gt 0 ]; then
       echo -e "- $(status 2) Check disk health: $failed_disks disks reported SMART failures"
     fi
   fi
   
   # Check swappiness value
   swappiness=$(cat /proc/sys/vm/swappiness)
   if [ $swappiness -gt 60 ] && [ $swap_percent -gt 50 ]; then
     echo -e "- $(status 1) Consider reducing swappiness: Current value is $swappiness with heavy swap usage"
   fi
   
   echo -e "\n${MAGENTA}Press any key to exit${CLEAR}"
   read -n 1
   EOF
   
   chmod +x ~/maintenance-dashboard/system-dashboard.sh
   
   # Create a desktop entry
   mkdir -p ~/.local/share/applications
   cat > ~/.local/share/applications/system-dashboard.desktop << EOF
   [Desktop Entry]
   Type=Application
   Name=System Maintenance Dashboard
   Exec=gnome-terminal -- /home/$USER/maintenance-dashboard/system-dashboard.sh
   Icon=utilities-system-monitor
   Categories=System;
   Comment=Display system maintenance information
   Terminal=false
   EOF
   ```

3. **Create a Complete Automated Maintenance System**:
   ```bash
   mkdir -p ~/maintenance-system/{scripts,logs,reports}
   
   # Create the main maintenance script
   cat > ~/maintenance-system/scripts/auto-maintenance.sh << 'EOF'
   #!/bin/bash
   
   # Configuration
   MAINTENANCE_DIR=$(dirname "$(dirname "$(readlink -f "$0")")")
   LOG_DIR="$MAINTENANCE_DIR/logs"
   REPORT_DIR="$MAINTENANCE_DIR/reports"
   LOG_FILE="$LOG_DIR/maintenance-$(date +%Y%m%d-%H%M%S).log"
   
   # Create directories if they don't exist
   mkdir -p "$LOG_DIR" "$REPORT_DIR"
   
   # Function to log messages
   log() {
     local level=$1
     shift
     local message="$*"
     echo "[$(date +%Y-%m-%d\ %H:%M:%S)] [$level] $message" | tee -a "$LOG_FILE"
   }
   
   # Function to run a task with logging
   run_task() {
     local task_name=$1
     local command=$2
     
     log "INFO" "Starting task: $task_name"
     eval "$command" >> "$LOG_FILE" 2>&1
     local result=$?
     
     if [ $result -eq 0 ]; then
       log "SUCCESS" "Task completed successfully: $task_name"
     else
       log "ERROR" "Task failed: $task_name (Exit code: $result)"
     fi
     
     return $result
   }
   
   # Function to send notification
   send_notification() {
     local level=$1
     local message=$2
     
     # Send desktop notification if running in GUI
     if [ -n "$DISPLAY" ] && command -v notify-send &> /dev/null; then
       notify-send "System Maintenance" "$message" --urgency=$level
     fi
     
     # Send email notification if configured
     if [ -x "$(command -v mail)" ]; then
       echo "$message" | mail -s "System Maintenance Alert [$level]" your-email@example.com
     fi
   }
   
   # Start maintenance
   log "INFO" "Starting automated maintenance"
   
   # Check if already running
   if pidof -o %PPID -x "$(basename "$0")" > /dev/null; then
     log "WARNING" "Another instance of this script is already running. Exiting."
     exit 1
   fi
   
   # Create maintenance report
   REPORT_FILE="$REPORT_DIR/maintenance-report-$(date +%Y%m%d).txt"
   log "INFO" "Creating maintenance report at $REPORT_FILE"
   
   {
     echo "======================================"
     echo "  System Maintenance Report"
     echo "  $(date)"
     echo "  $(hostname)"
     echo "======================================"
     echo
   } > "$REPORT_FILE"
   
   # System updates
   if [ "$(id -u)" -eq 0 ]; then
     log "INFO" "Checking for system updates"
     pacman -Sy >> "$LOG_FILE" 2>&1
     UPDATES=$(pacman -Qu | wc -l)
     
     echo "System Updates:" >> "$REPORT_FILE"
     if [ $UPDATES -eq 0 ]; then
       echo "- No updates available" >> "$REPORT_FILE"
       log "INFO" "No updates available"
     else
       echo "- $UPDATES updates available" >> "$REPORT_FILE"
       echo "- Available updates:" >> "$REPORT_FILE"
       pacman -Qu >> "$REPORT_FILE"
       
       log "INFO" "Found $UPDATES updates. Applying..."
       if run_task "System update" "pacman -Su --noconfirm"; then
         echo "- Updates applied successfully" >> "$REPORT_FILE"
       else
         echo "- Update process failed. See logs for details." >> "$REPORT_FILE"
         send_notification "critical" "System update failed"
       fi
     fi
   else
     log "WARNING" "Not running as root. Skipping system updates."
     echo "System Updates: SKIPPED (not running as root)" >> "$REPORT_FILE"
   fi
   
   # Clean package cache
   if [ "$(id -u)" -eq 0 ]; then
     log "INFO" "Cleaning package cache"
     
     # Get initial size
     INITIAL_SIZE=$(du -sh /var/cache/pacman/pkg/ | cut -f1)
     echo "Package Cache:" >> "$REPORT_FILE"
     echo "- Initial size: $INITIAL_SIZE" >> "$REPORT_FILE"
     
     if run_task "Package cache cleanup" "paccache -r"; then
       # Get new size
       NEW_SIZE=$(du -sh /var/cache/pacman/pkg/ | cut -f1)
       echo "- Final size: $NEW_SIZE" >> "$REPORT_FILE"
       echo "- Cleanup successful" >> "$REPORT_FILE"
     else
       echo "- Cleanup failed. See logs for details." >> "$REPORT_FILE"
     fi
   else
     log "WARNING" "Not running as root. Skipping package cache cleanup."
     echo "Package Cache Cleanup: SKIPPED (not running as root)" >> "$REPORT_FILE"
   fi
   
   # Check for orphaned packages
   log "INFO" "Checking for orphaned packages"
   ORPHANS=$(pacman -Qtdq 2>/dev/null | wc -l)
   
   echo "Orphaned Packages:" >> "$REPORT_FILE"
   if [ $ORPHANS -eq 0 ]; then
     echo "- No orphaned packages found" >> "$REPORT_FILE"
     log "INFO" "No orphaned packages found"
   else
     echo "- Found $ORPHANS orphaned packages" >> "$REPORT_FILE"
     pacman -Qtdq >> "$REPORT_FILE" 2>/dev/null
     
     if [ "$(id -u)" -eq 0 ]; then
       log "INFO" "Removing orphaned packages"
       if run_task "Remove orphaned packages" "pacman -Rns \$(pacman -Qtdq) --noconfirm"; then
         echo "- Orphaned packages removed successfully" >> "$REPORT_FILE"
       else
         echo "- Failed to remove orphaned packages. See logs for details." >> "$REPORT_FILE"
       fi
     else
       echo "- Removal SKIPPED (not running as root)" >> "$REPORT_FILE"
     fi
   fi
   
   # Clean journal logs
   if [ "$(id -u)" -eq 0 ]; then
     log "INFO" "Cleaning journal logs"
     
     # Get initial size
     INITIAL_SIZE=$(journalctl --disk-usage | cut -d' ' -f7-)
     echo "Journal Logs:" >> "$REPORT_FILE"
     echo "- Initial size: $INITIAL_SIZE" >> "$REPORT_FILE"
     
     if run_task "Journal cleanup" "journalctl --vacuum-size=500M"; then
       # Get new size
       NEW_SIZE=$(journalctl --disk-usage | cut -d' ' -f7-)
       echo "- Final size: $NEW_SIZE" >> "$REPORT_FILE"
       echo "- Cleanup successful" >> "$REPORT_FILE"
     else
       echo "- Cleanup failed. See logs for details." >> "$REPORT_FILE"
     fi
   else
     log "WARNING" "Not running as root. Skipping journal cleanup."
     echo "Journal Cleanup: SKIPPED (not running as root)" >> "$REPORT_FILE"
   fi
   
   # Check disk space
   log "INFO" "Checking disk space"
   echo "Disk Space:" >> "$REPORT_FILE"
   df -h | grep -v tmpfs >> "$REPORT_FILE"
   
   # Check for critical disk usage
   CRITICAL_DISKS=$(df -h | awk '$5 > 90 {print $6}')
   if [ -n "$CRITICAL_DISKS" ]; then
     log "WARNING" "Critical disk usage detected"
     echo "- CRITICAL: The following filesystems are over 90% full:" >> "$REPORT_FILE"
     echo "$CRITICAL_DISKS" >> "$REPORT_FILE"
     send_notification "critical" "Critical disk usage detected: $CRITICAL_DISKS"
   fi
   
   # Check for failed services
   log "INFO" "Checking for failed services"
   echo "Failed Services:" >> "$REPORT_FILE"
   FAILED_SERVICES=$(systemctl --failed --no-legend)
   if [ -z "$FAILED_SERVICES" ]; then
     echo "- No failed services found" >> "$REPORT_FILE"
   else
     log "WARNING" "Failed services detected"
     echo "- The following services have failed:" >> "$REPORT_FILE"
     echo "$FAILED_SERVICES" >> "$REPORT_FILE"
     send_notification "normal" "Failed services detected. Check maintenance report."
   fi
   
   # Run fstrim for SSDs
   if [ "$(id -u)" -eq 0 ] && command -v fstrim &> /dev/null; then
     log "INFO" "Running fstrim on supported filesystems"
     echo "FSTRIM:" >> "$REPORT_FILE"
     if run_task "FSTRIM" "fstrim -av"; then
       echo "- FSTRIM completed successfully" >> "$REPORT_FILE"
     else
       echo "- FSTRIM failed. See logs for details." >> "$REPORT_FILE"
     fi
   else
     log "WARNING" "Not running as root or fstrim not available. Skipping fstrim."
     echo "FSTRIM: SKIPPED (not running as root or not available)" >> "$REPORT_FILE"
   fi
   
   # Check SMART status if available
   if [ "$(id -u)" -eq 0 ] && command -v smartctl &> /dev/null; then
     log "INFO" "Checking disk health via SMART"
     echo "Disk Health:" >> "$REPORT_FILE"
     
     for disk in $(lsblk -d -o name | grep -E '^sd|^nvme|^hd' | grep -v NAME); do
       echo "- $disk:" >> "$REPORT_FILE"
       if run_task "SMART check for $disk" "smartctl -H /dev/$disk"; then
         HEALTH=$(smartctl -H /dev/$disk | grep -E 'overall-health|SMART Health Status')
         echo "  $HEALTH" >> "$REPORT_FILE"
         
         if echo "$HEALTH" | grep -q "FAILED"; then
           log "CRITICAL" "Disk $disk has FAILED SMART health check"
           send_notification "critical" "Disk $disk has FAILED SMART health check"
         fi
       else
         echo "  SMART check failed or not supported" >> "$REPORT_FILE"
       fi
     done
   else
     log "WARNING" "Not running as root or smartctl not available. Skipping SMART checks."
     echo "Disk Health: SKIPPED (not running as root or smartctl not available)" >> "$REPORT_FILE"
   fi
   
   # Check for large files in home directories
   log "INFO" "Checking for large files in home directories"
   echo "Large Files:" >> "$REPORT_FILE"
   
   LARGE_FILES=$(find /home -type f -size +100M -exec ls -lh {} \; 2>/dev/null | sort -k5hr | head -10)
   if [ -n "$LARGE_FILES" ]; then
     echo "- Top 10 largest files in home directories:" >> "$REPORT_FILE"
     echo "$LARGE_FILES" >> "$REPORT_FILE"
   else
     echo "- No files larger than 100MB found" >> "$REPORT_FILE"
   fi
   
   # Check for old logs
   log "INFO" "Checking for old logs"
   echo "Old Logs:" >> "$REPORT_FILE"
   
   OLD_LOGS=$(find /var/log -type f -name "*.gz" -mtime +30 | wc -l)
   if [ $OLD_LOGS -gt 0 ]; then
     echo "- Found $OLD_LOGS compressed log files older than 30 days" >> "$REPORT_FILE"
     
     if [ "$(id -u)" -eq 0 ]; then
       log "INFO" "Removing old logs"
       if run_task "Remove old logs" "find /var/log -type f -name \"*.gz\" -mtime +30 -delete"; then
         echo "- Old logs removed successfully" >> "$REPORT_FILE"
       else
         echo "- Failed to remove old logs. See logs for details." >> "$REPORT_FILE"
       fi
     else
       echo "- Removal SKIPPED (not running as root)" >> "$REPORT_FILE"
     fi
   else
     echo "- No old compressed logs found" >> "$REPORT_FILE"
   fi
   
   # Check backup status
   log "INFO" "Checking backup status"
   echo "Backup Status:" >> "$REPORT_FILE"
   
   # This assumes you're using borg backup as configured in previous exercises
   BORG_REPO="/mnt/backup/borg-repo"
   if [ -d "$BORG_REPO" ]; then
     if command -v borg &> /dev/null; then
       # List backups
       if run_task "List backups" "borg list --short $BORG_REPO"; then
         LATEST_BACKUP=$(borg list --short "$BORG_REPO" | tail -1)
         echo "- Latest backup: $LATEST_BACKUP" >> "$REPORT_FILE"
         
         # Check how old is the latest backup
         BACKUP_DATE=$(echo "$LATEST_BACKUP" | cut -d'-' -f1-3)
         DAYS_SINCE=$(( ( $(date +%s) - $(date -d "$BACKUP_DATE" +%s) ) / 86400 ))
         
         if [ $DAYS_SINCE -gt 7 ]; then
           log "WARNING" "Latest backup is $DAYS_SINCE days old"
           echo "- WARNING: Latest backup is $DAYS_SINCE days old" >> "$REPORT_FILE"
           send_notification "normal" "Backup is $DAYS_SINCE days old. Consider creating a new backup."
         else
           echo "- Backup is $DAYS_SINCE days old" >> "$REPORT_FILE"
         fi
       else
         echo "- Failed to list backups. See logs for details." >> "$REPORT_FILE"
       fi
     else
       echo "- Borg backup not available" >> "$REPORT_FILE"
     fi
   else
     echo "- Backup repository not found at $BORG_REPO" >> "$REPORT_FILE"
     log "WARNING" "Backup repository not found at $BORG_REPO"
   fi
   
   # Generate maintenance summary
   log "INFO" "Generating maintenance summary"
   echo >> "$REPORT_FILE"
   echo "=====================================" >> "$REPORT_FILE"
   echo "Maintenance Summary" >> "$REPORT_FILE"
   echo "=====================================" >> "$REPORT_FILE"
   echo "Maintenance completed at $(date)" >> "$REPORT_FILE"
   echo >> "$REPORT_FILE"
   
   # Create a symbolic link to the latest report
   ln -sf "$REPORT_FILE" "$REPORT_DIR/latest-report.txt"
   
   # Check for warnings or errors in the log
   WARNINGS=$(grep -c WARNING "$LOG_FILE")
   ERRORS=$(grep -c ERROR "$LOG_FILE")
   
   echo "Log Summary:" >> "$REPORT_FILE"
   echo "- Warnings: $WARNINGS" >> "$REPORT_FILE"
   echo "- Errors: $ERRORS" >> "$REPORT_FILE"
   echo "- Log file: $LOG_FILE" >> "$REPORT_FILE"
   
   # Send notification if there were errors
   if [ $ERRORS -gt 0 ]; then
     send_notification "critical" "Maintenance completed with $ERRORS errors. Check the maintenance report."
   elif [ $WARNINGS -gt 0 ]; then
     send_notification "normal" "Maintenance completed with $WARNINGS warnings. Check the maintenance report."
   else
     send_notification "low" "Maintenance completed successfully."
   fi
   
   log "INFO" "Maintenance completed"
   
   # Open the report if in GUI
   if [ -n "$DISPLAY" ] && command -v xdg-open &> /dev/null; then
     xdg-open "$REPORT_FILE" &
   fi
   
   exit 0
   EOF
   
   chmod +x ~/maintenance-system/scripts/auto-maintenance.sh
   
   # Create systemd user service and timer
   mkdir -p ~/.config/systemd/user/
   
   cat > ~/.config/systemd/user/maintenance.service << EOF
   [Unit]
   Description=System Maintenance Service
   After=network.target
   
   [Service]
   Type=oneshot
   ExecStart=/home/$USER/maintenance-system/scripts/auto-maintenance.sh
   
   [Install]
   WantedBy=default.target
   EOF
   
   cat > ~/.config/systemd/user/maintenance.timer << EOF
   [Unit]
   Description=Weekly System Maintenance
   
   [Timer]
   OnCalendar=Sun 01:00:00
   RandomizedDelaySec=1800
   Persistent=true
   
   [Install]
   WantedBy=timers.target
   EOF
   
   # Enable and start the timer
   systemctl --user daemon-reload
   systemctl --user enable maintenance.timer
   systemctl --user start maintenance.timer
   ```

4. **Create an Advanced Log Analysis and Alerting Script**:
   ```bash
   # Create the log monitoring script
   mkdir -p ~/log-monitoring
   
   cat > ~/log-monitoring/log-monitor.sh << 'EOF'
   #!/bin/bash
   
   # Configuration
   MONITOR_DIR=~/log-monitoring
   LOG_DIR=$MONITOR_DIR/logs
   ALERT_DIR=$MONITOR_DIR/alerts
   CONFIG_FILE=$MONITOR_DIR/config.json
   STATE_FILE=$MONITOR_DIR/monitor-state.json
   
   # Create necessary directories
   mkdir -p "$LOG_DIR" "$ALERT_DIR"
   
   # Default config if none exists
   if [ ! -f "$CONFIG_FILE" ]; then
     cat > "$CONFIG_FILE" << 'CONFEND'
   {
     "log_files": [
       {
         "path": "/var/log/syslog",
         "patterns": [
           {
             "name": "critical_errors",
             "regex": "(critical|emergency|alert|failed|failure)",
             "ignore_case": true,
             "severity": "high",
             "notify": true
           },
           {
             "name": "warnings",
             "regex": "(warning|warn)",
             "ignore_case": true,
             "severity": "medium",
             "notify": false
           }
         ]
       },
       {
         "path": "/var/log/auth.log",
         "patterns": [
           {
             "name": "failed_logins",
             "regex": "Failed password|authentication failure",
             "ignore_case": true,
             "severity": "high",
             "notify": true,
             "threshold": 5,
             "window": 300
           }
         ]
       },
       {
         "path": "/var/log/kern.log",
         "patterns": [
           {
             "name": "disk_errors",
             "regex": "(I/O error|read-only file system|corrupt|bad sector)",
             "ignore_case": true,
             "severity": "high",
             "notify": true
           }
         ]
       }
     ],
     "notify_settings": {
       "email": "your-email@example.com",
       "desktop_notification": true,
       "log": true
     }
   }
   CONFEND
   fi
   
   # Default state file if none exists
   if [ ! -f "$STATE_FILE" ]; then
     cat > "$STATE_FILE" << 'STATEEND'
   {
     "last_run": 0,
     "file_positions": {},
     "pattern_counts": {}
   }
   STATEEND
   fi
   
   # Function to parse and get value from JSON
   get_json_value() {
     local json="$1"
     local path="$2"
     echo "$json" | grep -o "\"$path\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | sed -e 's/.*: "\(.*\)"/\1/'
   }
   
   # Function to send notifications
   send_notification() {
     local severity="$1"
     local message="$2"
     
     # Log the alert
     local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
     local alert_file="$ALERT_DIR/alerts-$(date +%Y%m%d).log"
     echo "[$timestamp] [$severity] $message" >> "$alert_file"
     
     # Desktop notification
     if [ -n "$DISPLAY" ] && command -v notify-send &> /dev/null; then
       case "$severity" in
         "high") urgency="critical" ;;
         "medium") urgency="normal" ;;
         *) urgency="low" ;;
       esac
       
       notify-send "Log Monitor Alert" "$message" --urgency="$urgency"
     fi
     
     # Email notification
     if [ -x "$(command -v mail)" ]; then
       echo "$message" | mail -s "Log Monitor Alert [$severity]" your-email@example.com
     fi
   }
   
   # Main monitoring function
   monitor_logs() {
     local config=$(cat "$CONFIG_FILE")
     local state=$(cat "$STATE_FILE")
     local current_time=$(date +%s)
     
     # Update last run time
     state=$(echo "$state" | sed "s/\"last_run\":[[:space:]]*[0-9]*/\"last_run\": $current_time/")
     
     # Process each log file
     for log_file in $(echo "$config" | grep -o '"path"[[:space:]]*:[[:space:]]*"[^"]*"' | sed -e 's/.*: "\(.*\)"/\1/'); do
       # Skip if file doesn't exist or isn't readable
       if [ ! -r "$log_file" ]; then
         continue
       fi
       
       # Get last position for this file
       local file_key=$(echo "$log_file" | sed 's/\//\\\//g')
       local last_pos=$(echo "$state" | grep -o "\"$file_key\"[[:space:]]*:[[:space:]]*[0-9]*" | sed -e 's/.*: \([0-9]*\)/\1/')
       
       # Default to start of file if no position is saved
       if [ -z "$last_pos" ]; then
         last_pos=0
       fi
       
       # Get current file size
       local current_size=$(stat -c %s "$log_file")
       
       # If file is smaller than last position, it was probably rotated
       if [ "$current_size" -lt "$last_pos" ]; then
         last_pos=0
       fi
       
       # Extract new lines and process patterns
       if [ "$current_size" -gt "$last_pos" ]; then
         # Use tail to get new lines
         local new_lines=$(tail -c +"$((last_pos + 1))" "$log_file")
         
         # Process each pattern for this file
         for pattern_block in $(echo "$config" | grep -o "{[^{]*\"path\"[[:space:]]*:[[:space:]]*\"$file_key\"[^}]*}" | grep -o '"patterns"[[:space:]]*:[[:space:]]*\[[^]]*\]' | grep -o '{[^}]*}'); do
           local pattern_name=$(echo "$pattern_block" | grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed -e 's/.*: "\(.*\)"/\1/')
           local pattern_regex=$(echo "$pattern_block" | grep -o '"regex"[[:space:]]*:[[:space:]]*"[^"]*"' | sed -e 's/.*: "\(.*\)"/\1/')
           local ignore_case=$(echo "$pattern_block" | grep -o '"ignore_case"[[:space:]]*:[[:space:]]*[a-z]*' | sed -e 's/.*: \(.*\)/\1/')
           local severity=$(echo "$pattern_block" | grep -o '"severity"[[:space:]]*:[[:space:]]*"[^"]*"' | sed -e 's/.*: "\(.*\)"/\1/')
           local do_notify=$(echo "$pattern_block" | grep -o '"notify"[[:space:]]*:[[:space:]]*[a-z]*' | sed -e 's/.*: \(.*\)/\1/')
           local threshold=$(echo "$pattern_block" | grep -o '"threshold"[[:space:]]*:[[:space:]]*[0-9]*' | sed -e 's/.*: \([0-9]*\)/\1/')
           local window=$(echo "$pattern_block" | grep -o '"window"[[:space:]]*:[[:space:]]*[0-9]*' | sed -e 's/.*: \([0-9]*\)/\1/')
           
           # Set defaults if not specified
           if [ -z "$threshold" ]; then threshold=1; fi
           if [ -z "$window" ]; then window=3600; fi  # 1 hour default window
           
           # Set up grep options
           local grep_opts=""
           if [ "$ignore_case" = "true" ]; then
             grep_opts="-i"
           fi
           
           # Count matches in new content
           local matches=$(echo "$new_lines" | grep $grep_opts -c "$pattern_regex")
           
           if [ "$matches" -gt 0 ]; then
             # Save matched lines to log file
             local match_log="$LOG_DIR/matched-${pattern_name}-$(date +%Y%m%d).log"
             echo "$new_lines" | grep $grep_opts "$pattern_regex" >> "$match_log"
             
             # Get previous count for this pattern
             local count_key="${file_key}:${pattern_name}"
             local count_key_safe=$(echo "$count_key" | sed 's/\//\\\//g')
             local prev_count=$(echo "$state" | grep -o "\"$count_key_safe\"[[:space:]]*:[[:space:]]*{[^}]*}" | grep -o '"count"[[:space:]]*:[[:space:]]*[0-9]*' | sed -e 's/.*: \([0-9]*\)/\1/')
             local prev_time=$(echo "$state" | grep -o "\"$count_key_safe\"[[:space:]]*:[[:space:]]*{[^}]*}" | grep -o '"time"[[:space:]]*:[[:space:]]*[0-9]*' | sed -e 's/.*: \([0-9]*\)/\1/')
             
             # Default to 0 if no previous count
             if [ -z "$prev_count" ]; then prev_count=0; fi
             if [ -z "$prev_time" ]; then prev_time=$current_time; fi
             
             # Calculate time window
             local time_diff=$((current_time - prev_time))
             
             # If outside window, reset count
             if [ "$time_diff" -gt "$window" ]; then
               prev_count=0
               prev_time=$current_time
             fi
             
             # Update count
             local new_count=$((prev_count + matches))
             
             # Check if threshold is reached
             if [ "$new_count" -ge "$threshold" ] && [ "$do_notify" = "true" ]; then
               # Get a sample of matching lines
               local sample=$(echo "$new_lines" | grep $grep_opts "$pattern_regex" | head -3)
               local message="Detected $new_count occurrences of '$pattern_name' in $log_file within the last $time_diff seconds. Sample: $sample"
               
               send_notification "$severity" "$message"
               
               # Reset count after notification
               new_count=0
             fi
             
             # Update state with new count
             if echo "$state" | grep -q "\"$count_key_safe\""; then
               state=$(echo "$state" | sed "s/\"$count_key_safe\"[[:space:]]*:[[:space:]]*{[^}]*}/\"$count_key_safe\": {\"count\": $new_count, \"time\": $current_time}/")
             else
               # Add new entry to pattern_counts
               local new_entry="\"$count_key_safe\": {\"count\": $new_count, \"time\": $current_time}"
               state=$(echo "$state" | sed "s/\"pattern_counts\"[[:space:]]*:[[:space:]]*{/\"pattern_counts\": {$new_entry, /")
             fi
           fi
         done
         
         # Update file position
         if echo "$state" | grep -q "\"$file_key\""; then
           state=$(echo "$state" | sed "s/\"$file_key\"[[:space:]]*:[[:space:]]*[0-9]*/\"$file_key\": $current_size/")
         else
           # Add new entry to file_positions
           local new_entry="\"$file_key\": $current_size"
           state=$(echo "$state" | sed "s/\"file_positions\"[[:space:]]*:[[:space:]]*{/\"file_positions\": {$new_entry, /")
         fi
       fi
     done
     
     # Write updated state back to file
     echo "$state" > "$STATE_FILE"
   }
   
   # Run the monitoring function
   monitor_logs
   
   exit 0
   EOF
   
   chmod +x ~/log-monitoring/log-monitor.sh
   
   # Create a systemd user service and timer for log monitoring
   cat > ~/.config/systemd/user/log-monitor.service << EOF
   [Unit]
   Description=Log Monitoring Service
   
   [Service]
   Type=oneshot
   ExecStart=/home/$USER/log-monitoring/log-monitor.sh
   
   [Install]
   WantedBy=default.target
   EOF
   
   cat > ~/.config/systemd/user/log-monitor.timer << EOF
   [Unit]
   Description=Run Log Monitoring Periodically
   
   [Timer]
   OnBootSec=1min
   OnUnitActiveSec=5min
   
   [Install]
   WantedBy=timers.target
   EOF
   
   # Enable and start the timer
   systemctl --user daemon-reload
   systemctl --user enable log-monitor.timer
   systemctl --user start log-monitor.timer
   ```

## Comprehensive Projects

### Project 1: Complete System Maintenance Framework [Advanced] (12-14 hours)

Create a comprehensive maintenance framework that integrates monitoring, maintenance, backup, and reporting into a single system.

#### Components:

1. **Central Configuration System**:
   - Create a JSON or YAML configuration file for all maintenance settings
   - Include customizable thresholds, schedules, and notification preferences
   - Implement a validation tool to check configuration syntax

2. **Modular Script Architecture**:
   - Develop a plugin-based system with modules for different maintenance tasks
   - Create a core engine that loads and executes modules based on the configuration
   - Implement proper error handling and recovery for each module

3. **Advanced Reporting System**:
   - Generate HTML reports with charts and tables using tools like gnuplot
   - Implement historical trend analysis for system metrics
   - Create an interactive dashboard for viewing reports

4. **Multi-system Management**:
   - Extend the framework to manage multiple systems (if you have them)
   - Implement SSH-based remote execution capabilities
   - Create a centralized report aggregation system

5. **Documentation**:
   - Create comprehensive documentation for your framework
   - Include installation instructions, configuration reference, and customization guide
   - Document the architecture and design decisions

### Project 2: Performance Analysis and Tuning System [Intermediate] (8-10 hours)

Build a comprehensive system for analyzing performance and automatically implementing tuning recommendations based on workload patterns.

#### Components:

1. **Workload Detection**:
   - Create a script that analyzes system usage patterns to detect the primary workload type
   - Implement classification for different workloads (desktop, development, server, database)
   - Store and analyze historical workload patterns

2. **Automated Performance Testing**:
   - Develop benchmark scripts for CPU, memory, disk, and network
   - Implement tools to measure application response times
   - Create a system to compare performance metrics before and after tuning

3. **Tuning Recommendation Engine**:
   - Create a knowledge base of performance tuning recommendations
   - Develop an engine that generates tuning suggestions based on detected workloads
   - Implement a risk assessment system for each recommendation

4. **Configuration Management**:
   - Create tools to apply tuning recommendations automatically
   - Implement backup and rollback functionality for configuration changes
   - Build a system to track performance improvements over time

5. **Documentation and Reporting**:
   - Generate detailed reports of performance analysis
   - Document all tuning recommendations with explanations
   - Create a log of all applied changes and their effects

### Project 3: Disaster Recovery System [Intermediate] (6-8 hours)

Develop a comprehensive disaster recovery system with automated testing and verification.

#### Components:

1. **Backup Strategy Implementation**:
   - Implement a multi-tiered backup strategy with borg or restic
   - Configure local, network, and optional offsite backup locations
   - Implement different retention policies for different data types

2. **Recovery Automation**:
   - Create scripts to automate the recovery process
   - Implement a bootable recovery USB with custom scripts
   - Develop tools to restore different components of the system

3. **Verification System**:
   - Create automated backup verification tools
   - Implement data integrity checks for backed-up files
   - Develop a system to periodically test restore procedures

4. **Documentation System**:
   - Create comprehensive recovery documentation
   - Implement a way to automatically update documentation when system changes occur
   - Develop checklists and flowcharts for different recovery scenarios

5. **Training Mode**:
   - Create a "simulation" mode for practicing recovery procedures
   - Implement scenarios for different types of failures
   - Develop a scoring system to evaluate recovery performance

### Project 4: Security Monitoring and Maintenance [Advanced] (10-12 hours)

Develop a comprehensive security monitoring and maintenance system focused on keeping your Linux system secure.

#### Components:

1. **Security Scanning Framework**:
   - Integrate tools like Lynis, rkhunter, and ClamAV
   - Create a centralized scanning and reporting system
   - Implement scheduled security audits

2. **Vulnerability Management**:
   - Develop a system to track known vulnerabilities in installed software
   - Create a notification system for security updates
   - Implement a risk assessment framework for vulnerabilities

3. **Log Analysis for Security**:
   - Enhance the log monitoring system for security-focused alerts
   - Implement pattern detection for potential security incidents
   - Create visualization tools for security events

4. **Hardening Automation**:
   - Develop scripts to automatically apply security best practices
   - Create a system to track deviations from hardening guidelines
   - Implement regular security configuration checks

5. **Documentation and Reporting**:
   - Generate comprehensive security reports
   - Create an incident response documentation system
   - Develop security maintenance procedures and checklists

## Additional Resources

### System Maintenance Reference

- **Regular Maintenance Tasks**:
  ```
  Daily:
  - Check system logs for errors
  - Monitor disk space
  - Verify critical services
  
  Weekly:
  - Apply system updates
  - Clean package cache
  - Backup user data
  - Check for failed services
  
  Monthly:
  - Full system backup
  - Check for orphaned packages
  - Perform security audit
  - Clean old logs
  
  Quarterly:
  - Filesystem check
  - Verify backup integrity
  - Test disaster recovery
  - Review user accounts
  ```

- **Common Maintenance Commands**:
  ```bash
  # System Update
  sudo pacman -Syu                       # Update system
  sudo pacman -Sc                        # Clean package cache
  sudo pacman -Rns $(pacman -Qtdq)       # Remove orphaned packages
  
  # Disk Management
  sudo fstrim -av                        # TRIM SSD filesystems
  sudo fsck.ext4 -f /dev/sdX             # Check filesystem
  sudo e4defrag /home                    # Defragment ext4 filesystem
  sudo btrfs scrub start /               # Scrub btrfs filesystem
  
  # Log Management
  sudo journalctl --vacuum-time=2weeks   # Retain logs for two weeks
  sudo journalctl --vacuum-size=1G       # Limit journal to 1GB
  sudo find /var/log -name "*.gz" -delete # Remove compressed logs
  
  # Performance Management
  sudo cpupower frequency-set -g performance  # Set CPU governor
  echo 10 | sudo tee /proc/sys/vm/swappiness  # Adjust swappiness
  nice -n 19 command                     # Run with lower priority
  
  # Backup Commands
  borg create ::backup-$(date +%Y-%m-%d) ~/Documents  # Create backup
  borg check repository                  # Verify backup integrity
  borg extract ::backup-name path/to/file # Extract from backup
  ```

### Performance Tuning Reference

- **CPU Performance Settings**:
  ```
  CPU Governors:
  - performance: Maximum performance, highest power usage
  - powersave: Power saving mode, lowest performance
  - ondemand: Dynamic frequency scaling based on load
  - conservative: Gradual frequency scaling
  - schedutil: Scheduler-driven frequency selection
  
  CPU Optimization:
  - Use taskset to bind processes to specific CPUs
  - Adjust nice levels for process priorities
  - Consider CPU isolation for critical tasks
  ```

- **Memory Optimization**:
  ```
  Swappiness Settings:
  - 0-10: Minimize swapping, good for databases
  - 10-60: Balanced for desktop systems
  - 60-100: Favor swapping over dropping caches
  
  Memory Management:
  - Use cgroups to limit memory usage
  - Monitor and adjust OOM killer settings
  - Consider zram for RAM compression
  ```

- **Disk I/O Optimization**:
  ```
  I/O Schedulers:
  - mq-deadline: Good balance for most systems
  - kyber: Good for mixed workloads on fast devices
  - bfq: Good for desktop responsiveness
  - none: Best for NVMe and fast SSDs
  
  Mount Options:
  - noatime: Disable access time updates
  - nodiratime: Disable directory access time updates
  - discard/fstrim: SSD TRIM support
  - data=ordered|writeback: Journal modes for ext4
  ```

### Monitoring Tools Command Reference

- **Process Monitoring**:
  ```bash
  # htop - interactive process viewer
  htop -d 5                  # Refresh every 5 seconds
  htop -p PID1,PID2          # Monitor specific PIDs
  htop -s PERCENT_CPU        # Sort by CPU usage
  
  # ps - process status
  ps -aux --sort=-%cpu       # Sort by CPU usage
  ps -aux --sort=-%mem       # Sort by memory usage
  ps -eo pid,ppid,cmd,pcpu   # Custom format
  ```

- **Resource Monitoring**:
  ```bash
  # free - memory usage
  free -h                    # Human-readable sizes
  free -s 5                  # Update every 5 seconds
  
  # vmstat - system statistics
  vmstat 5 10                # 10 updates, 5 sec interval
  
  # iostat - I/O statistics
  iostat -x 5                # Extended info, 5 sec interval
  
  # mpstat - CPU statistics
  mpstat -P ALL 5            # All CPUs, 5 sec interval
  ```

- **Network Monitoring**:
  ```bash
  # iftop - bandwidth usage monitor
  iftop -i eth0              # Monitor specific interface
  
  # ss - socket statistics
  ss -tuln                   # TCP, UDP, listening, numeric
  
  # iptraf-ng - interactive network monitor
  iptraf-ng -i all           # Monitor all interfaces
  ```

### Backup Strategy Guide

- **Backup Types**:
  ```
  Full Backup:
  - Complete copy of all data
  - Highest storage requirements
  - Simplest to restore from
  
  Incremental Backup:
  - Only changes since last backup
  - Minimal storage requirements
  - Requires all backups for restore
  
  Differential Backup:
  - Changes since last full backup
  - Medium storage requirements
  - Requires full + one differential for restore
  
  Snapshot Backup:
  - Point-in-time image of system state
  - Uses filesystem features (LVM, Btrfs)
  - Fast creation and restoration
  ```

- **Backup Storage Options**:
  ```
  Local Storage:
  - External hard drives
  - Network attached storage (NAS)
  - Advantages: Fast, convenient
  - Disadvantages: Vulnerable to local disasters
  
  Cloud Storage:
  - Services like Backblaze, S3, Google Drive
  - Advantages: Off-site, scalable
  - Disadvantages: Bandwidth limitations, privacy concerns
  
  Offline Storage:
  - Removable media stored securely
  - Advantages: Air-gapped security
  - Disadvantages: Manual process, limited capacity
  ```

## Reflection Questions

After completing the exercises and projects, reflect on these questions:

1. How does implementing a proactive maintenance strategy compare to a reactive approach in terms of system reliability and administrative workload?

2. What performance optimization techniques had the most significant impact on your system's responsiveness or throughput?

3. How would you adapt your backup strategy for different types of systems (personal workstation, development server, production database server)?

4. What were the biggest challenges you encountered when setting up automated monitoring and alerting, and how did you overcome them?

5. How would you scale your maintenance and monitoring system to handle dozens or hundreds of machines in an enterprise environment?

6. What security considerations are important when implementing automated maintenance systems with root privileges?

7. How would you balance the thoroughness of system maintenance with resource consumption and potential disruption to users?

8. How do the various Linux filesystem types (ext4, XFS, Btrfs, ZFS) affect your maintenance strategy and tools?

## Answers to Self-Assessment Quiz

1. **What is the primary difference between proactive and reactive maintenance approaches?**
   Proactive maintenance is performed on a regular schedule to prevent problems before they occur, while reactive maintenance is performed in response to issues that have already manifested. Proactive maintenance generally results in less downtime and more predictable system behavior.

2. **How would you clear the package cache in Arch Linux while retaining the most recent version of each package?**
   You would use the command `sudo paccache -r`, which removes all cached versions of packages except for the most recent three versions by default.

3. **What systemd command would you use to check for failed services on your system?**
   The command `systemctl --failed` will show all systemd services that have failed to start or have crashed.

4. **What is swappiness in Linux, and how does adjusting it affect system performance?**
   Swappiness is a kernel parameter that controls how aggressively the system will swap memory pages from RAM to disk. A lower value (e.g., 10) reduces swapping, keeping more in RAM, which can improve responsiveness for desktop systems. A higher value (e.g., 60-100) favors more swapping, which may benefit systems with memory-intensive background tasks.

5. **Name three key metrics you should monitor to evaluate system performance.**
   CPU usage (load average), memory utilization (including swap usage), and disk I/O throughput are three key metrics. Additional important metrics include network bandwidth usage, process counts, and context switch rates.

6. **What is the difference between incremental and differential backups?**
   Incremental backups store only the changes since the last backup (full or incremental), requiring all previous backups in the chain for a full restore. Differential backups store all changes since the last full backup, requiring only the full backup and the most recent differential backup for a complete restore.

7. **Which filesystem option can improve SSD performance and longevity?**
   The `noatime` mount option improves SSD performance and longevity by preventing the system from updating the access time attribute of files when they are read, reducing write operations. Additionally, enabling TRIM with the `discard` mount option or using `fstrim` regularly helps maintain SSD performance.

8. **How can you effectively search the systemd journal for error messages that occurred in the last hour?**
   Use the command `journalctl -p err -S "1 hour ago"` to search for error-level messages that occurred within the last hour.

9. **What is the purpose of the OOM killer, and how can you adjust its behavior for critical processes?**
   The OOM (Out Of Memory) killer is a Linux kernel mechanism that terminates processes when the system is critically low on memory. You can adjust its behavior for critical processes by modifying the `/proc/[pid]/oom_score_adj` value. Setting it to -1000 makes a process immune to the OOM killer, while higher values make it more likely to be killed.

10. **Explain the advantages of using systemd timers over traditional cron jobs for scheduling maintenance tasks.**
    Systemd timers offer several advantages: they provide better logging and integration with the systemd ecosystem, support for complex timing expressions, the ability to set dependencies between services, options for randomized delays to prevent resource contention, handling of missed executions with `Persistent=true`, and more sophisticated error handling.

## Next Steps

After completing Month 7 exercises, consider these activities to further enhance your skills:

1. **Create a custom monitoring solution** for a specific application or service

2. **Develop a comprehensive security maintenance routine** that includes intrusion detection

3. **Explore containerized monitoring solutions** like Prometheus and Grafana

4. **Implement database-specific performance tuning** for PostgreSQL or MySQL

5. **Design a multi-tier backup solution** with off-site components

6. **Create a benchmarking system** to quantify your performance improvements

7. **Develop a centralized log analysis system** using the ELK stack (Elasticsearch, Logstash, Kibana)

8. **Explore cluster management tools** like Ansible for managing multiple systems

Remember: Regular practice and continuous improvement of your maintenance routines are essential for maintaining robust and performant Linux systems!

## Acknowledgements

This exercise guide was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Exercise structure and organization
- Script development suggestions
- Resource recommendations

Claude was used as a development aid while all final implementation decisions and review were performed by Joshua Michael Hall.

## Disclaimer

These exercises are provided "as is", without warranty of any kind. Always make backups before making system changes. Use these scripts with caution, especially those requiring root privileges.
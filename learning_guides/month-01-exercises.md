# Document bootloader configuration
   cat /boot/loader/loader.conf > bootloader-config.txt
   ls -la /boot/loader/entries/ >> bootloader-config.txt
   cat /boot/loader/entries/* >> bootloader-config.txt
   ```

5. **Create a step-by-step guide**:
   Create a markdown document with screenshots combining all your findings into a reproducible installation guide.

### Project 2: Command Line Scavenger Hunt

Create a script that solves several challenges in one automated process:

1. **Create the script file**:
   ```bash
   touch ~/scavenger-hunt.sh
   chmod +x ~/scavenger-hunt.sh
   ```

2. **Add the script content**:
   ```bash
   #!/bin/bash
   
   # Create a results directory
   mkdir -p ~/scavenger-hunt-results
   cd ~/scavenger-hunt-results
   
   echo "Starting scavenger hunt at $(date)" > results.txt
   echo "==================================" >> results.txt
   
   # Challenge 1: Find all running processes owned by your user
   echo -e "\nCHALLENGE 1: Processes owned by $(whoami)" >> results.txt
   ps -u $(whoami) -o pid,ppid,%cpu,%mem,cmd >> results.txt
   
   # Challenge 2: Find all files in /etc modified in the last week
   echo -e "\nCHALLENGE 2: Files in /etc modified in the last week" >> results.txt
   find /etc -type f -mtime -7 2>/dev/null | sort >> results.txt
   
   # Challenge 3: Display disk usage sorted by size
   echo -e "\nCHALLENGE 3: Directory sizes in /home" >> results.txt
   du -h --max-depth=2 /home | sort -rh >> results.txt
   
   # Challenge 4: Find all executable files in your PATH
   echo -e "\nCHALLENGE 4: Counting executables in each PATH directory" >> results.txt
   IFS=":"
   for dir in $PATH; do
     count=$(find "$dir" -type f -executable 2>/dev/null | wc -l)
     echo "$dir: $count executables" >> results.txt
   done
   
   # Challenge 5: Find the 10 largest packages installed
   echo -e "\nCHALLENGE 5: 10 largest installed packages" >> results.txt
   expac -H M '%m\t%n' | sort -rh | head -10 >> results.txt
   
   echo -e "\nScavenger hunt completed at $(date)" >> results.txt
   echo "Results saved to ~/scavenger-hunt-results/results.txt"
   ```

3. **Run the script**:
   ```bash
   ./scavenger-hunt.sh
   ```

4. **Analyze the results** and create a summary of what you've learned about your system.

### Project 3: User Management Exercise

Create a complete user and group management scenario:

1. **Create a project management scenario script**:
   ```bash
   #!/bin/bash
   
   # Create project groups
   sudo groupadd developers
   sudo groupadd designers
   sudo groupadd managers
   
   # Create project directory
   sudo mkdir -p /opt/project
   
   # Create subdirectories
   sudo mkdir -p /opt/project/{code,design,docs,shared}
   
   # Create users
   sudo useradd -m -G developers developer1
   sudo useradd -m -G developers developer2
   sudo useradd -m -G designers designer1
   sudo useradd -m -G managers manager1
   
   # Set passwords
   echo "Setting passwords for new users..."
   for user in developer1 developer2 designer1 manager1; do
     sudo passwd $user
   done
   
   # Set directory permissions
   sudo chown -R root:developers /opt/project/code
   sudo chown -R root:designers /opt/project/design
   sudo chown -R root:managers /opt/project/docs
   sudo chown -R root:root /opt/project/shared
   
   # Set directory permissions
   sudo chmod 770 /opt/project/code
   sudo chmod 770 /opt/project/design
   sudo chmod 770 /opt/project/docs
   sudo chmod 775 /opt/project/shared
   
   # Create welcome files
   for dir in /opt/project/*/; do
     echo "Welcome to $(basename $dir) directory!" | sudo tee "$dir/welcome.txt" > /dev/null
   done
   
   echo "Project environment setup complete!"
   ```

2. **Test the permission setup**:
   ```bash
   # Switch to developer user
   su - developer1
   
   # Try to access different directories
   ls -la /opt/project/code/  # Should work
   ls -la /opt/project/design/  # Should fail
   touch /opt/project/code/test.c  # Should work
   touch /opt/project/design/test.svg  # Should fail
   ```

3. **Create sudo configuration**:
   ```bash
   # Create a sudoers file for managers
   echo "# Project managers can restart services
   %managers ALL=(ALL) /bin/systemctl restart apache2, /bin/systemctl restart nginx" | sudo tee /etc/sudoers.d/project-managers
   
   # Test the sudo access as manager
   su - manager1
   sudo systemctl status nginx  # Should fail
   sudo systemctl restart nginx  # Should work
   ```

4. **Document the setup** with a diagram of permissions and capabilities.

### Project 4: Package Management Script

Create a comprehensive system management script:

1. **Create the script file**:
   ```bash
   touch ~/system-manager.sh
   chmod +x ~/system-manager.sh
   ```

2. **Add the script content**:
   ```bash
   #!/bin/bash
   
   # System Management Script
   # Usage: ./system-manager.sh [option]
   # Options:
   #   update    - Update system packages
   #   clean     - Clean package cache
   #   backup    - Backup important configs
   #   stats     - Show system statistics
   #   health    - Check system health
   #   help      - Show this help message
   
   # Log file setup
   LOG_DIR="$HOME/system-logs"
   mkdir -p "$LOG_DIR"
   LOG_FILE="$LOG_DIR/system-$(date +%Y%m%d).log"
   
   # Function to log messages
   log() {
     echo "[$(date +%H:%M:%S)] $1" | tee -a "$LOG_FILE"
   }
   
   # Function to update the system
   update_system() {
     log "Starting system update..."
     sudo pacman -Sy
     log "Checking for updates..."
     UPDATES=$(pacman -Qu | wc -l)
     log "Found $UPDATES updates available."
     
     if [ $UPDATES -gt 0 ]; then
       log "Performing system upgrade..."
       sudo pacman -Syu
       RESULT=$?
       if [ $RESULT -eq 0 ]; then
         log "System update completed successfully."
       else
         log "ERROR: System update failed with exit code $RESULT."
       fi
     else
       log "System is already up to date."
     fi
   }
   
   # Function to clean package cache
   clean_system() {
     log "Starting system cleanup..."
     
     # Get initial cache size
     CACHE_SIZE=$(du -sh /var/cache/pacman/pkg/ | cut -f1)
     log "Current package cache size: $CACHE_SIZE"
     
     # Clean unused packages
     log "Removing unused packages..."
     sudo pacman -Sc --noconfirm
     
     # Remove orphaned packages
     log "Checking for orphaned packages..."
     ORPHANS=$(pacman -Qtdq | wc -l)
     if [ $ORPHANS -gt 0 ]; then
       log "Found $ORPHANS orphaned packages, removing..."
       sudo pacman -Rns $(pacman -Qtdq) --noconfirm
     else
       log "No orphaned packages found."
     fi
     
     # Get final cache size
     NEW_CACHE_SIZE=$(du -sh /var/cache/pacman/pkg/ | cut -f1)
     log "New package cache size: $NEW_CACHE_SIZE"
     
     log "System cleanup completed."
   }
   
   # Function to backup configs
   backup_configs() {
     log "Starting configuration backup..."
     BACKUP_DIR="$HOME/config-backups/backup-$(date +%Y%m%d-%H%M%S)"
     mkdir -p "$BACKUP_DIR"
     
     # Backup important configuration files
     log "Backing up pacman configuration..."
     cp /etc/pacman.conf "$BACKUP_DIR/"
     
     log "Backing up network configuration..."
     cp -r /etc/NetworkManager/system-connections "$BACKUP_DIR/"
     
     log "Backing up bootloader configuration..."
     cp -r /boot/loader "$BACKUP_DIR/"
     
     log "Backing up user dotfiles..."
     cp ~/.bashrc ~/.zshrc ~/.xinitrc "$BACKUP_DIR/" 2>/dev/null
     
     # Compress the backup
     log "Compressing backup..."
     tar -czf "$BACKUP_DIR.tar.gz" -C "$(dirname "$BACKUP_DIR")" "$(basename "$BACKUP_DIR")"
     rm -rf "$BACKUP_DIR"
     
     log "Backup completed: $BACKUP_DIR.tar.gz"
   }
   
   # Function to show system statistics
   show_stats() {
     log "Gathering system statistics..."
     
     echo -e "\n==== SYSTEM INFORMATION ===="
     hostnamectl
     
     echo -e "\n==== CPU INFORMATION ===="
     lscpu | grep -E "Model name|Socket|Core|Thread"
     
     echo -e "\n==== MEMORY USAGE ===="
     free -h
     
     echo -e "\n==== DISK USAGE ===="
     df -h | grep -v tmpfs
     
     echo -e "\n==== PACKAGE STATISTICS ===="
     echo "Total packages installed: $(pacman -Q | wc -l)"
     echo "Explicitly installed packages: $(pacman -Qe | wc -l)"
     echo "AUR packages installed: $(pacman -Qm | wc -l)"
     
     log "System statistics displayed."
   }
   
   # Function to check system health
   check_health() {
     log "Starting system health check..."
     
     echo -e "\n==== SYSTEM HEALTH CHECK ===="
     
     echo -e "\n=== DISK HEALTH ==="
     for disk in $(lsblk -d -o name | grep -E '^sd|^nvme' | grep -v 'loop'); do
       echo "Checking disk $disk..."
       sudo smartctl -H /dev/$disk 2>/dev/null || echo "SMART not available for $disk"
     done
     
     echo -e "\n=== SYSTEM SERVICES ==="
     echo "Failed services:"
     systemctl --failed
     
     echo -e "\n=== JOURNAL ERRORS ==="
     journalctl -p 3 -b | tail -n 10
     
     echo -e "\n=== FILESYSTEM CHECK ==="
     for fs in $(df -h --output=target | grep -v 'Mounted' | grep '^/'); do
       echo "Checking free inodes on $fs"
       df -i $fs | grep -v 'Filesystem'
     done
     
     log "System health check completed."
   }
   
   # Main script logic
   case "$1" in
     update)
       update_system
       ;;
     clean)
       clean_system
       ;;
     backup)
       backup_configs
       ;;
     stats)
       show_stats
       ;;
     health)
       check_health
       ;;
     help|"")
       echo "Usage: $0 [option]"
       echo "Options:"
       echo "  update    - Update system packages"
       echo "  clean     - Clean package cache"
       echo "  backup    - Backup important configs"
       echo "  stats     - Show system statistics"
       echo "  health    - Check system health"
       echo "  help      - Show this help message"
       ;;
     *)
       echo "Error: Unknown option '$1'"
       echo "Try '$0 help' for a list of valid options."
       exit 1
       ;;
   esac
   
   exit 0
   ```

3. **Test each function**:
   ```bash
   # Show help
   ./system-manager.sh help
   
   # Check system statistics
   ./system-manager.sh stats
   
   # Create a backup
   ./system-manager.sh backup
   
   # Clean the system (if you have sudo access)
   ./system-manager.sh clean
   ```

4. **Set up a scheduled task**:
   ```bash
   # Create a systemd timer for weekly updates
   cat > ~/.config/systemd/user/system-update.service << EOF
   [Unit]
   Description=Weekly System Update
   
   [Service]
   Type=oneshot
   ExecStart=%h/system-manager.sh update
   
   [Install]
   WantedBy=default.target
   EOF
   
   cat > ~/.config/systemd/user/system-update.timer << EOF
   [Unit]
   Description=Run Weekly System Update
   
   [Timer]
   OnCalendar=Sun 02:00:00
   Persistent=true
   
   [Install]
   WantedBy=timers.target
   EOF
   
   # Enable the timer
   systemctl --user enable system-update.timer
   systemctl --user start system-update.timer
   ```

## Additional Resources

### Command Line References

- **Navigation Cheatsheet**:
  ```
  pwd           # Print working directory
  ls            # List files
  ls -la        # List all files with details
  cd dir        # Change to directory
  cd ..         # Go up one directory
  cd ~          # Go to home directory
  cd -          # Go to previous directory
  ```

- **File Operation Cheatsheet**:
  ```
  touch file    # Create empty file
  mkdir dir     # Create directory
  cp src dst    # Copy file/directory
  mv src dst    # Move/rename file/directory
  rm file       # Remove file
  rm -r dir     # Remove directory recursively
  ln -s src dst # Create symbolic link
  ```

- **Text Processing Cheatsheet**:
  ```
  cat file      # Display file content
  less file     # View file with paging
  head file     # Show first 10 lines
  tail file     # Show last 10 lines
  grep pattern  # Search for pattern
  sed 's/a/b/'  # Replace text
  awk '{print}' # Process text by fields
  ```

### Linux Filesystem Hierarchy

```
/             # Root directory
├── bin       # Essential user binaries
├── boot      # Boot loader files
├── dev       # Device files
├── etc       # System configuration files
├── home      # User home directories
├── lib       # Essential shared libraries
├── media     # Mount point for removable media
├── mnt       # Mount point for temporary filesystems
├── opt       # Optional application software
├── proc      # Virtual filesystem for process info
├── root      # Root user's home directory
├── run       # Runtime variable data
├── sbin      # Essential system binaries
├── srv       # Data for services provided by the system
├── sys       # Virtual filesystem for system info
├── tmp       # Temporary files
├── usr       # Secondary hierarchy for user data
└── var       # Variable data (logs, etc.)
```

### Permissions Reference

```
Permission Types:
r (read)    = 4
w (write)   = 2
x (execute) = 1

Common chmod values:
777 - rwxrwxrwx - Everyone can read/write/execute
755 - rwxr-xr-x - Owner can read/write/execute, others can read/execute
644 - rw-r--r-- - Owner can read/write, others can read
700 - rwx------ - Owner can read/write/execute, others have no permissions
```

## Reflection Questions

After completing the exercises and projects, reflect on these questions:

1. What aspects of the Linux filesystem hierarchy do you find most logical? Which parts seem counterintuitive?

2. How does the permission system in Linux compare to other operating systems you've used? What are its strengths and limitations?

3. What challenges did you encounter during the Arch Linux installation process? How did you solve them?

4. How does the package management approach in Arch Linux (with pacman and AUR) compare to other package managers you may be familiar with?

5. Which command line tools do you find most useful for your typical workflows? Which ones do you want to explore further?

6. How comfortable are you with the concept of everything being a file in Linux? How does this philosophy affect system administration?

7. What scripts or automations could you create to make your daily Linux usage more efficient?

8. What Linux skills do you think will be most valuable for your professional development path?

## Next Steps

After completing the Month 1 exercises, consider these activities to further cement your learning:

1. **Install an Arch Linux system on physical hardware** (if you've only used a VM so far)

2. **Create a custom installation script** that automates your preferred setup

3. **Learn to use more advanced text editors** like Vim or Emacs

4. **Set up SSH keys** for password-less login to remote systems

5. **Explore more terminal utilities** like `tmux`, `ranger`, and `fzf`

6. **Document your learnings** in a personal wiki or knowledge base

7. **Join Linux communities** like the Arch Linux forums or Reddit's r/archlinux

Remember: The key to mastering Linux is regular practice and exploration. Keep experimenting with the command line and system configuration to build confidence and fluency!

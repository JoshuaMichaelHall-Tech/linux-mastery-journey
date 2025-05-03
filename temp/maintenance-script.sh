#!/bin/bash
#
# system-maintenance.sh - System maintenance utility for Linux
# Part of the Linux Mastery Journey project
#
# This script performs various system maintenance tasks including:
# - System updates
# - Cleanup of unused packages and cached files
# - Log rotation and cleanup
# - Disk space analysis
# - System health check
# - Backup reminder
#
# The script adapts its behavior based on the detected distribution (Arch or NixOS).

set -e # Exit immediately if a command exits with a non-zero status

# Print with colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display usage information
show_usage() {
    echo -e "${BLUE}System Maintenance Utility${NC}"
    echo
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -u, --update            Perform system update"
    echo "  -c, --cleanup           Clean up unused packages and cache"
    echo "  -l, --logs              Rotate and clean up logs"
    echo "  -d, --disk              Analyze disk space usage"
    echo "  -s, --status            Show system health status"
    echo "  -b, --backup            Perform backup (if configured)"
    echo "  -a, --all               Perform all maintenance tasks"
    echo "  -y, --yes               Answer yes to all prompts"
    echo
    echo "Example:"
    echo "  $0 --update --cleanup"
    echo
    exit 1
}

# Default values
DO_UPDATE=false
DO_CLEANUP=false
DO_LOGS=false
DO_DISK=false
DO_STATUS=false
DO_BACKUP=false
ASSUME_YES=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            ;;
        -u|--update)
            DO_UPDATE=true
            shift
            ;;
        -c|--cleanup)
            DO_CLEANUP=true
            shift
            ;;
        -l|--logs)
            DO_LOGS=true
            shift
            ;;
        -d|--disk)
            DO_DISK=true
            shift
            ;;
        -s|--status)
            DO_STATUS=true
            shift
            ;;
        -b|--backup)
            DO_BACKUP=true
            shift
            ;;
        -a|--all)
            DO_UPDATE=true
            DO_CLEANUP=true
            DO_LOGS=true
            DO_DISK=true
            DO_STATUS=true
            DO_BACKUP=true
            shift
            ;;
        -y|--yes)
            ASSUME_YES=true
            shift
            ;;
        *)
            echo -e "${RED}Error: Unknown option: $1${NC}"
            show_usage
            ;;
    esac
done

# If no options provided, show status
if ! $DO_UPDATE && ! $DO_CLEANUP && ! $DO_LOGS && ! $DO_DISK && ! $DO_STATUS && ! $DO_BACKUP; then
    DO_STATUS=true
fi

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Error: This script must be run as root.${NC}"
    exit 1
fi

# Detect distribution
if [ -f /etc/arch-release ]; then
    DISTRO="arch"
    echo -e "${BLUE}Detected distribution: Arch Linux${NC}"
elif [ -f /etc/nixos/configuration.nix ]; then
    DISTRO="nixos"
    echo -e "${BLUE}Detected distribution: NixOS${NC}"
else
    echo -e "${YELLOW}Warning: Unable to detect distribution. Defaulting to Arch Linux.${NC}"
    DISTRO="arch"
fi

# Function to ask for confirmation
confirm() {
    if $ASSUME_YES; then
        return 0
    fi
    
    read -p "$1 (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# System Update
system_update() {
    echo -e "${YELLOW}Performing system update...${NC}"
    
    if [ "$DISTRO" = "arch" ]; then
        if command_exists paru; then
            echo -e "${BLUE}Using paru for AUR updates...${NC}"
            paru -Syu --noconfirm
        elif command_exists yay; then
            echo -e "${BLUE}Using yay for AUR updates...${NC}"
            yay -Syu --noconfirm
        else
            echo -e "${BLUE}Updating system packages...${NC}"
            pacman -Syu --noconfirm
        fi
    elif [ "$DISTRO" = "nixos" ]; then
        echo -e "${BLUE}Updating NixOS channels...${NC}"
        nix-channel --update
        
        echo -e "${BLUE}Rebuilding NixOS...${NC}"
        nixos-rebuild switch
    fi
    
    echo -e "${GREEN}System update completed.${NC}"
}

# Clean up unused packages and cache
system_cleanup() {
    echo -e "${YELLOW}Cleaning up system...${NC}"
    
    if [ "$DISTRO" = "arch" ]; then
        # Remove orphaned packages
        echo -e "${BLUE}Checking for orphaned packages...${NC}"
        ORPHANS=$(pacman -Qtdq)
        if [ -n "$ORPHANS" ]; then
            echo -e "${BLUE}Found orphaned packages:${NC}"
            echo "$ORPHANS"
            if confirm "Do you want to remove these packages?"; then
                pacman -Rns $(pacman -Qtdq) --noconfirm
            fi
        else
            echo -e "${BLUE}No orphaned packages found.${NC}"
        fi
        
        # Clean package cache
        echo -e "${BLUE}Cleaning package cache...${NC}"
        if command_exists paccache; then
            paccache -r
        else
            if confirm "paccache not found. Do you want to clean the entire package cache?"; then
                pacman -Sc --noconfirm
            fi
        fi
        
        # Clean pacman database
        echo -e "${BLUE}Checking pacman database...${NC}"
        pacman -Dk
        
    elif [ "$DISTRO" = "nixos" ]; then
        # Clean old generations
        echo -e "${BLUE}Cleaning up old system generations...${NC}"
        nix-collect-garbage -d
        
        # Optimize store
        echo -e "${BLUE}Optimizing Nix store...${NC}"
        nix-store --optimize
        
        # Clean builder cache
        echo -e "${BLUE}Cleaning builder cache...${NC}"
        nix-store --gc
    fi
    
    # Common cleanup tasks
    echo -e "${BLUE}Cleaning temporary files...${NC}"
    find /tmp -type f -atime +10 -delete 2>/dev/null
    find /var/tmp -type f -atime +10 -delete 2>/dev/null
    
    echo -e "${GREEN}System cleanup completed.${NC}"
}

# Rotate and clean up logs
log_maintenance() {
    echo -e "${YELLOW}Performing log maintenance...${NC}"
    
    # Journal cleanup
    if command_exists journalctl; then
        echo -e "${BLUE}Rotating and vacuuming journal logs...${NC}"
        journalctl --rotate
        journalctl --vacuum-time=30d  # Keep logs for 30 days
    fi
    
    # Rotate logs
    if command_exists logrotate; then
        echo -e "${BLUE}Running logrotate...${NC}"
        logrotate -f /etc/logrotate.conf
    fi
    
    # Clean old log files
    echo -e "${BLUE}Cleaning old log files...${NC}"
    find /var/log -type f -name "*.gz" -o -name "*.old" -o -name "*.1" -mtime +30 -delete 2>/dev/null
    
    echo -e "${GREEN}Log maintenance completed.${NC}"
}

# Analyze disk space usage
disk_analysis() {
    echo -e "${YELLOW}Analyzing disk space usage...${NC}"
    
    # Check overall disk usage
    echo -e "${BLUE}Overall disk usage:${NC}"
    df -h | grep -v tmpfs | grep -v "loop"
    
    # Find large directories
    echo -e "\n${BLUE}Large directories in /home:${NC}"
    if command_exists du; then
        du -h --max-depth=2 /home 2>/dev/null | sort -hr | head -n 10
    fi
    
    echo -e "\n${BLUE}Large directories in /var:${NC}"
    if command_exists du; then
        du -h --max-depth=2 /var 2>/dev/null | sort -hr | head -n 10
    fi
    
    # Find large files
    echo -e "\n${BLUE}Largest files in system:${NC}"
    if command_exists find; then
        find / -type f -size +100M -not -path "/proc/*" -not -path "/sys/*" -not -path "/dev/*" 2>/dev/null | xargs ls -lh | sort -k5 -hr | head -n 10
    fi
    
    echo -e "${GREEN}Disk space analysis completed.${NC}"
}

# Show system health status
system_status() {
    echo -e "${YELLOW}Checking system health...${NC}"
    
    # Check system uptime
    echo -e "${BLUE}System uptime:${NC}"
    uptime
    
    # Check CPU usage
    echo -e "\n${BLUE}CPU usage:${NC}"
    if command_exists mpstat; then
        mpstat 1 5
    elif command_exists top; then
        top -bn1 | head -n 20
    fi
    
    # Check memory usage
    echo -e "\n${BLUE}Memory usage:${NC}"
    free -h
    
    # Check disk usage
    echo -e "\n${BLUE}Disk usage:${NC}"
    df -h | grep -v tmpfs | grep -v "loop"
    
    # Check for system errors
    echo -e "\n${BLUE}Recent system errors:${NC}"
    if command_exists journalctl; then
        journalctl -p 3 -xb --no-pager | tail -n 20
    fi
    
    # Check service status
    echo -e "\n${BLUE}Failed services:${NC}"
    if command_exists systemctl; then
        systemctl --failed
    fi
    
    # Check for package issues
    if [ "$DISTRO" = "arch" ]; then
        echo -e "\n${BLUE}Package integrity check:${NC}"
        pacman -Qk | grep -v "0 altered files"
    fi
    
    echo -e "${GREEN}System health check completed.${NC}"
}

# Perform backup
perform_backup() {
    echo -e "${YELLOW}Checking backup configuration...${NC}"
    
    # Check if backup script exists
    BACKUP_SCRIPT="/usr/local/bin/backup.sh"
    if [ -f "$BACKUP_SCRIPT" ] && [ -x "$BACKUP_SCRIPT" ]; then
        echo -e "${BLUE}Found backup script: $BACKUP_SCRIPT${NC}"
        if confirm "Do you want to run the backup now?"; then
            $BACKUP_SCRIPT
        fi
    else
        echo -e "${YELLOW}No backup script found at $BACKUP_SCRIPT${NC}"
        echo -e "${BLUE}Checking for other backup utilities...${NC}"
        
        if command_exists restic; then
            echo -e "${BLUE}Restic backup tool found.${NC}"
            if confirm "Do you want to run a restic backup (requires configuration)?"; then
                # This is a simple example, a real backup would need more configuration
                if [ -f ~/.restic-credentials ]; then
                    source ~/.restic-credentials
                    restic -r $RESTIC_REPOSITORY backup /home
                else
                    echo -e "${RED}No restic configuration found.${NC}"
                fi
            fi
        elif command_exists timeshift; then
            echo -e "${BLUE}Timeshift found.${NC}"
            if confirm "Do you want to create a Timeshift snapshot?"; then
                timeshift --create --comments "Manual snapshot from maintenance script"
            fi
        elif command_exists rsync; then
            echo -e "${BLUE}rsync found.${NC}"
            if confirm "Do you want to run a basic rsync backup of your home directory?"; then
                BACKUP_DIR="/mnt/backup/$(date +%Y-%m-%d)"
                if [ ! -d "$BACKUP_DIR" ]; then
                    mkdir -p "$BACKUP_DIR"
                fi
                rsync -avz --exclude='.cache' /home "$BACKUP_DIR"
            fi
        else
            echo -e "${RED}No backup tools found. Please install a backup solution.${NC}"
        fi
    fi
    
    echo -e "${GREEN}Backup process completed.${NC}"
}

# Perform maintenance operations

if $DO_STATUS; then
    system_status
    echo
fi

if $DO_UPDATE; then
    if confirm "Do you want to update the system?"; then
        system_update
    fi
    echo
fi

if $DO_CLEANUP; then
    if confirm "Do you want to clean up the system?"; then
        system_cleanup
    fi
    echo
fi

if $DO_LOGS; then
    if confirm "Do you want to perform log maintenance?"; then
        log_maintenance
    fi
    echo
fi

if $DO_DISK; then
    if confirm "Do you want to analyze disk space usage?"; then
        disk_analysis
    fi
    echo
fi

if $DO_BACKUP; then
    if confirm "Do you want to check backup status?"; then
        perform_backup
    fi
    echo
fi

echo -e "${GREEN}Maintenance tasks completed!${NC}"
echo
echo -e "${BLUE}System Summary:${NC}"
echo "Hostname: $(hostname)"
echo "Kernel: $(uname -r)"
if [ "$DISTRO" = "arch" ]; then
    echo "Arch Linux version: $(pacman -Q linux | awk '{print $2}')"
elif [ "$DISTRO" = "nixos" ]; then
    echo "NixOS version: $(nixos-version)"
fi
echo "Last boot: $(who -b | awk '{print $3,$4}')"
echo

exit 0

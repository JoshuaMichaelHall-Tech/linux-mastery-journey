#!/bin/bash
#
# partition-setup.sh - Automated disk partitioning for Arch Linux installation
# Part of the Linux Mastery Journey project
#
# This script automates the disk partitioning process for an Arch Linux installation.
# It creates a standard layout with EFI, swap, and root partitions using GPT.
#
# WARNING: This script will erase all data on the specified disk!
# Make sure to back up important data before running this script.

set -e # Exit immediately if a command exits with a non-zero status

# Print with colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display usage information
show_usage() {
    echo -e "${BLUE}Disk Partitioning Script for Arch Linux${NC}"
    echo
    echo "Usage: $0 [options] DISK"
    echo
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -s, --swap SIZE         Swap partition size in GB (default: 8)"
    echo "  -e, --efi SIZE          EFI partition size in MB (default: 550)"
    echo "  -b, --btrfs             Use Btrfs for root partition (default: ext4)"
    echo "  -l, --luks              Encrypt root partition with LUKS"
    echo "  -f, --force             Skip confirmation prompt"
    echo
    echo "Example:"
    echo "  $0 --swap 16 --btrfs /dev/nvme0n1"
    echo
    exit 1
}

# Default values
SWAP_SIZE=8  # in GB
EFI_SIZE=550  # in MB
USE_BTRFS=false
USE_LUKS=false
FORCE=false
DISK=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            ;;
        -s|--swap)
            SWAP_SIZE="$2"
            shift 2
            ;;
        -e|--efi)
            EFI_SIZE="$2"
            shift 2
            ;;
        -b|--btrfs)
            USE_BTRFS=true
            shift
            ;;
        -l|--luks)
            USE_LUKS=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        *)
            if [[ -z "$DISK" ]]; then
                DISK="$1"
                shift
            else
                echo -e "${RED}Error: Unknown option or multiple disks specified.${NC}"
                show_usage
            fi
            ;;
    esac
done

# Validate inputs
if [[ -z "$DISK" ]]; then
    echo -e "${RED}Error: No disk specified.${NC}"
    show_usage
fi

if [[ ! -b "$DISK" ]]; then
    echo -e "${RED}Error: $DISK is not a valid block device.${NC}"
    exit 1
fi

if ! [[ "$SWAP_SIZE" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Error: Swap size must be a positive integer.${NC}"
    exit 1
fi

if ! [[ "$EFI_SIZE" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Error: EFI size must be a positive integer.${NC}"
    exit 1
fi

# Display disk information
echo -e "${BLUE}Disk information:${NC}"
lsblk "$DISK"
echo

# Display partitioning plan
echo -e "${BLUE}Partitioning plan:${NC}"
echo "Disk: $DISK"
echo "EFI partition size: ${EFI_SIZE}MB"
echo "Swap partition size: ${SWAP_SIZE}GB"
if $USE_BTRFS; then
    echo "Root filesystem: Btrfs"
else
    echo "Root filesystem: ext4"
fi
if $USE_LUKS; then
    echo "Root encryption: Yes (LUKS)"
else
    echo "Root encryption: No"
fi
echo

# Confirm before proceeding
if ! $FORCE; then
    echo -e "${RED}WARNING: This will erase all data on ${DISK}!${NC}"
    read -p "Are you sure you want to proceed? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        exit 1
    fi
fi

echo -e "${YELLOW}Creating partition table...${NC}"

# Create a new GPT partition table
sgdisk -Z "$DISK"
sgdisk -o "$DISK"

# Create EFI partition
echo -e "${YELLOW}Creating EFI partition...${NC}"
sgdisk -n 1:0:+"$EFI_SIZE"M -t 1:ef00 -c 1:"EFI System Partition" "$DISK"

# Create swap partition
echo -e "${YELLOW}Creating swap partition...${NC}"
sgdisk -n 2:0:+"$SWAP_SIZE"G -t 2:8200 -c 2:"Linux swap" "$DISK"

# Create root partition
echo -e "${YELLOW}Creating root partition...${NC}"
sgdisk -n 3:0:0 -t 3:8300 -c 3:"Linux filesystem" "$DISK"

# Wait for kernel to update partition table
echo -e "${YELLOW}Waiting for partition table update...${NC}"
sleep 2

# Determine partition names based on disk name
if [[ "$DISK" == *"nvme"* || "$DISK" == *"mmcblk"* ]]; then
    DISK_PREFIX="${DISK}p"
else
    DISK_PREFIX="${DISK}"
fi

EFI_PART="${DISK_PREFIX}1"
SWAP_PART="${DISK_PREFIX}2"
ROOT_PART="${DISK_PREFIX}3"

# Format EFI partition
echo -e "${YELLOW}Formatting EFI partition...${NC}"
mkfs.fat -F32 "$EFI_PART"

# Format swap partition
echo -e "${YELLOW}Formatting swap partition...${NC}"
mkswap "$SWAP_PART"
swapon "$SWAP_PART"

# Setup root partition
if $USE_LUKS; then
    echo -e "${YELLOW}Encrypting root partition...${NC}"
    cryptsetup luksFormat --type luks2 "$ROOT_PART"
    cryptsetup open "$ROOT_PART" cryptroot
    ROOT_DEVICE="/dev/mapper/cryptroot"
else
    ROOT_DEVICE="$ROOT_PART"
fi

# Format root partition
if $USE_BTRFS; then
    echo -e "${YELLOW}Formatting root partition with Btrfs...${NC}"
    mkfs.btrfs "$ROOT_DEVICE"
    
    # Mount and create subvolumes
    echo -e "${YELLOW}Creating Btrfs subvolumes...${NC}"
    mount "$ROOT_DEVICE" /mnt
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    btrfs subvolume create /mnt/@var
    btrfs subvolume create /mnt/@snapshots
    umount /mnt
    
    # Mount subvolumes
    echo -e "${YELLOW}Mounting Btrfs subvolumes...${NC}"
    mount -o noatime,compress=zstd,space_cache=v2,subvol=@ "$ROOT_DEVICE" /mnt
    mkdir -p /mnt/{boot/efi,home,var,snapshots}
    mount -o noatime,compress=zstd,space_cache=v2,subvol=@home "$ROOT_DEVICE" /mnt/home
    mount -o noatime,compress=zstd,space_cache=v2,subvol=@var "$ROOT_DEVICE" /mnt/var
    mount -o noatime,compress=zstd,space_cache=v2,subvol=@snapshots "$ROOT_DEVICE" /mnt/snapshots
else
    echo -e "${YELLOW}Formatting root partition with ext4...${NC}"
    mkfs.ext4 "$ROOT_DEVICE"
    
    # Mount root partition
    echo -e "${YELLOW}Mounting partitions...${NC}"
    mount "$ROOT_DEVICE" /mnt
fi

# Mount EFI partition
mkdir -p /mnt/boot/efi
mount "$EFI_PART" /mnt/boot/efi

# Display mounted filesystems
echo -e "${GREEN}Partitioning and formatting completed successfully.${NC}"
echo -e "${BLUE}Mounted filesystems:${NC}"
df -h | grep /mnt

# Save partition information for post-install
mkdir -p /mnt/root
cat > /mnt/root/partition_info.txt << EOF
Disk: $DISK
EFI partition: $EFI_PART
Swap partition: $SWAP_PART
Root partition: $ROOT_PART
Filesystem: $(if $USE_BTRFS; then echo "Btrfs"; else echo "ext4"; fi)
Encryption: $(if $USE_LUKS; then echo "LUKS"; else echo "None"; fi)
EOF

# Print next steps
echo
echo -e "${GREEN}Partitioning completed successfully!${NC}"
echo
echo -e "${BLUE}Next steps:${NC}"
echo "1. Install the base system:"
echo "   pacstrap /mnt base base-devel linux linux-firmware"
echo
echo "2. Generate fstab:"
echo "   genfstab -U /mnt >> /mnt/etc/fstab"
echo
echo "3. Chroot into the new system:"
echo "   arch-chroot /mnt"
echo

exit 0

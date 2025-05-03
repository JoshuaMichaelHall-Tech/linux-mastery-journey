#!/bin/bash
#
# reorganize-repo.sh - Script to organize the Linux Mastery Journey repository
#
# This script moves files from the temp directory to their correct locations,
# renames files for consistency, and creates necessary directories.

set -e  # Exit immediately if a command exits with a non-zero status

# Print with colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if the repo root directory exists
if [ ! -d "temp" ]; then
    echo -e "${RED}Error: 'temp' directory not found. Please run this script from the repository root.${NC}"
    exit 1
fi

echo -e "${BLUE}Starting repository reorganization...${NC}"

# Create base directory structure if they don't exist
echo -e "${YELLOW}Creating directory structure...${NC}"
mkdir -p installation/arch/scripts
mkdir -p installation/arch/configs
mkdir -p installation/nixos/scripts
mkdir -p installation/nixos/configs
mkdir -p configuration/system/{boot,network,power,security}
mkdir -p configuration/desktop/{i3,sway,hyprland,themes}
mkdir -p configuration/development/editors/{neovim,vscode}
mkdir -p configuration/development/languages/{python,javascript,ruby}
mkdir -p configuration/development/tools/{git,docker,database}
mkdir -p learning_guides
mkdir -p troubleshooting
mkdir -p scripts/{backup,monitoring,automation,maintenance}
mkdir -p projects/system-monitor

# Function to safely move and rename files
move_file() {
    local source=$1
    local destination=$2
    local name=$3
    
    # Check if source file exists
    if [ ! -f "$source" ]; then
        echo -e "${RED}Warning: Source file '$source' not found. Skipping.${NC}"
        return
    fi
    
    # Create destination directory if it doesn't exist
    mkdir -p "$(dirname "$destination")"
    
    # Move file
    cp "$source" "$destination"
    echo -e "${GREEN}Moved '$name' to '$destination'${NC}"
}

# Move root-level files
echo -e "${YELLOW}Moving root-level files...${NC}"
move_file "temp/license-file.md" "LICENSE" "License file"
move_file "temp/contributing-file.md" "CONTRIBUTING.md" "Contributing guidelines"
move_file "temp/changelog-file.md" "CHANGELOG.md" "Changelog"
move_file "temp/linux-journey-readme.md" "README.md" "Main README"

# Move installation files
echo -e "${YELLOW}Moving installation files...${NC}"
move_file "temp/arch-linux-installation-guide.md" "installation/arch/arch-linux-installation-guide.md" "Arch Linux installation guide"
move_file "temp/arch-readme.md" "installation/arch/README.md" "Arch installation README"
move_file "temp/nixos-guide.md" "installation/nixos/nixos-installation-guide.md" "NixOS installation guide"
move_file "temp/nixos-readme.md" "installation/nixos/README.md" "NixOS installation README"

# Move scripts
echo -e "${YELLOW}Moving script files...${NC}"
move_file "temp/partition-script.bash" "installation/arch/scripts/partition-setup.sh" "Arch partition script"
move_file "temp/post-install-script.bash" "installation/arch/scripts/post-install.sh" "Arch post-installation script"
move_file "temp/maintenance-script.bash" "scripts/maintenance/system-maintenance.sh" "System maintenance script"

# Move configuration files
echo -e "${YELLOW}Moving configuration files...${NC}"
move_file "temp/nixos-config.nix" "installation/nixos/configs/configuration.nix" "NixOS configuration"
move_file "temp/hardware-config.nix" "installation/nixos/configs/hardware-configuration.nix" "NixOS hardware configuration"

# Move troubleshooting files
echo -e "${YELLOW}Moving troubleshooting files...${NC}"
move_file "temp/troubleshooting-readme.md" "troubleshooting/README.md" "Troubleshooting README"
move_file "temp/graphics-troubleshooting.md" "troubleshooting/graphics.md" "Graphics troubleshooting"
move_file "temp/network-config.md" "troubleshooting/networking.md" "Network troubleshooting"

# Move development environment files
echo -e "${YELLOW}Moving development environment files...${NC}"
move_file "temp/dev-env-readme.md" "configuration/development/README.md" "Development environment README"
move_file "temp/python-dev-setup.md" "configuration/development/languages/python/README.md" "Python development setup"

# Move example project files
echo -e "${YELLOW}Moving example project files...${NC}"
move_file "temp/system-monitor-readme.md" "projects/system-monitor/README.md" "System monitor README"
move_file "temp/system-monitor-main.py" "projects/system-monitor/monitor/__main__.py" "System monitor main module"
move_file "temp/cpu-collector.py" "projects/system-monitor/monitor/collectors/cpu.py" "CPU collector module"
move_file "temp/config-module.py" "projects/system-monitor/monitor/config.py" "Configuration module"

# Create necessary __init__.py files for Python modules
echo -e "${YELLOW}Creating Python package structure...${NC}"
mkdir -p projects/system-monitor/monitor/collectors
mkdir -p projects/system-monitor/monitor/processors
mkdir -p projects/system-monitor/monitor/ui
touch projects/system-monitor/monitor/__init__.py
touch projects/system-monitor/monitor/collectors/__init__.py
touch projects/system-monitor/monitor/processors/__init__.py
touch projects/system-monitor/monitor/ui/__init__.py

# Create basic pyproject.toml for the system monitor project
cat > projects/system-monitor/pyproject.toml << EOF
[build-system]
requires = ["poetry-core>=1.0.0"]
build-backend = "poetry.core.masonry.api"

[tool.poetry]
name = "linux-system-monitor"
version = "1.0.0"
description = "A terminal-based system monitoring tool for Linux"
authors = ["Joshua Michael Hall <your.email@example.com>"]
readme = "README.md"
packages = [{include = "monitor"}]

[tool.poetry.dependencies]
python = "^3.11"
psutil = "^5.9.5"
py-cpuinfo = "^9.0.0"
blessed = "^1.20.0"
pandas = "^2.0.0"
typer = "^0.9.0"

[tool.poetry.group.dev.dependencies]
pytest = "^7.3.1"
black = "^23.3.0"
isort = "^5.12.0"
mypy = "^1.3.0"
flake8 = "^6.0.0"

[tool.poetry.scripts]
monitor = "monitor.__main__:app"

[tool.black]
line-length = 88

[tool.isort]
profile = "black"
EOF

# Check for redundant files and list them
echo -e "${YELLOW}Checking for redundant files...${NC}"
redundant_files=""
for file in temp/*.md temp/*.py temp/*.bash temp/*.nix; do
    if [ -f "$file" ]; then
        case "$file" in
            # List files that were already moved
            temp/repo-structure.md)
                redundant_files="$redundant_files\n$file"
                ;;
            # Add other redundant files here
        esac
    fi
done

if [ -n "$redundant_files" ]; then
    echo -e "${YELLOW}The following redundant files were found:${NC}"
    echo -e "$redundant_files"
    echo -e "${YELLOW}You may manually delete these files if no longer needed.${NC}"
fi

echo -e "${GREEN}Repository reorganization completed!${NC}"
echo
echo -e "${BLUE}Next steps:${NC}"
echo "1. Review the new directory structure"
echo "2. Update file paths in documentation if necessary"
echo "3. Create the monthly learning guides as outlined in the main README"
echo "4. Make the script files executable (chmod +x installation/arch/scripts/*.sh scripts/maintenance/*.sh)"
echo

exit 0

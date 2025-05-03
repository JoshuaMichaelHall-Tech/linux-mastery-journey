# Month 1: Base System Installation and Core Concepts

This first month focuses on installing a foundational Linux system (Arch Linux) and understanding core Linux concepts. By the end of this month, you'll have a working Arch Linux installation and understand the basic structure and operation of a Linux system.

## Time Commitment: ~10 hours/week for 4 weeks

## Month 1 Learning Path

```
Week 1                 Week 2                 Week 3                 Week 4
┌─────────────┐       ┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│ Installation│       │ Filesystem  │       │   User      │       │   Package   │
│    and      │──────▶│    and      │──────▶│    and      │──────▶│ Management  │
│   Setup     │       │  Commands   │       │ Permissions │       │  & Config   │
└─────────────┘       └─────────────┘       └─────────────┘       └─────────────┘
```

## Learning Objectives

By the end of this month, you should be able to:

1. Install Arch Linux on a physical machine or virtual environment
2. Navigate the Linux filesystem hierarchy confidently
3. Execute essential command-line operations for daily system management
4. Manage users, groups, and permissions effectively
5. Install, update, and remove packages using pacman
6. Configure and customize basic system settings
7. Troubleshoot common installation and configuration issues
8. Document your system configuration for future reference

## Week 1: Preparation and Installation

### Core Learning Activities

1. **System Preparation** (2 hours)
   - Read the Arch installation guide in this repository
   - Prepare installation media
   - Back up any existing data
   - Research your hardware compatibility

2. **Base System Installation** (4 hours)
   - Follow the [Arch Linux Installation Guide](../installation/arch/arch-linux-installation-guide.md)
   - Install the base system without a desktop environment
   - Configure the bootloader
   - Set up basic networking

3. **First Boot and Initial Configuration** (2 hours)
   - Boot into your new Arch Linux system
   - Create a user account
   - Install basic utilities (vim/neovim, git, etc.)

4. **Understanding the Installation Process** (2 hours)
   - Review the installation steps and understand what each accomplished
   - Study the role of the bootloader
   - Understand partition layout decisions

### Resources

- [Arch Linux Installation Guide](https://wiki.archlinux.org/title/Installation_guide)
- [ArchWiki - General Recommendations](https://wiki.archlinux.org/title/General_recommendations)
- Video: [EF - Linux Made Simple: Arch Linux Installation Guide](https://www.youtube.com/watch?v=DPLnBPM4DhI)

## Week 2: Linux Filesystem and Basic Commands

### Core Learning Activities

1. **Filesystem Hierarchy Standard** (3 hours)
   - Study the Linux directory structure (/bin, /etc, /var, /home, etc.)
   - Understand the purpose of each main directory
   - Explore your Arch Linux installation's file organization

2. **Essential Command-Line Tools** (4 hours)
   - Master navigation commands (cd, ls, pwd)
   - File operations (cp, mv, rm, mkdir)
   - Reading files (cat, less, more)
   - Finding information (find, grep, locate)
   - Redirection and pipes (>, >>, |)

3. **Man Pages and Documentation** (2 hours)
   - Learn to read and use man pages
   - Use the `info` command
   - Practice finding help with `--help` flags

4. **Text Editing Practice** (1 hour)
   - Choose a text editor (vim, nano, etc.)
   - Practice basic editing operations
   - Create and modify configuration files

### The Linux Filesystem Hierarchy

```
/                       # Root directory
├── bin                 # Essential user binaries
├── boot                # Boot loader files and kernels
├── dev                 # Device files
├── etc                 # System configuration files
├── home                # User home directories
│   └── username        # User's personal files
├── lib, lib64          # Essential shared libraries
├── media               # Mount point for removable media
├── mnt                 # Mount point for temporary filesystems
├── opt                 # Optional application software
├── proc                # Virtual filesystem for process info
├── root                # Root user's home directory
├── run                 # Runtime variable data
├── sbin                # System binaries
├── srv                 # Data for services provided by system
├── sys                 # Virtual filesystem for system info
├── tmp                 # Temporary files
├── usr                 # Secondary hierarchy
│   ├── bin             # User binaries
│   ├── include         # Header files
│   ├── lib             # Libraries
│   ├── local           # Local hierarchy
│   ├── sbin            # System binaries
│   └── share           # Architecture-independent data
└── var                 # Variable data
    ├── cache           # Application cache data
    ├── lib             # Variable state information
    ├── log             # Log files
    ├── mail            # Mailbox files
    ├── spool           # Spools for printing, mail, etc.
    └── tmp             # Temporary files preserved between reboots
```

### Resources

- [Linux Journey - Grasshopper Section](https://linuxjourney.com/)
- [The Linux Command Line (TLCL)](http://linuxcommand.org/tlcl.php) - Chapters 1-6
- [ExplainShell.com](https://explainshell.com/) - For understanding command syntax

## Week 3: User Management and Permissions

### Core Learning Activities

1. **User and Group Concepts** (3 hours)
   - Understand user accounts and the root user
   - Learn about groups and their purpose
   - Configure your user account properly

2. **File Permissions** (3 hours)
   - Understand the permission system (read, write, execute)
   - Learn numeric (octal) and symbolic permission notation
   - Practice using chmod and chown
   - Understand special permissions (setuid, setgid, sticky bit)

3. **Process Management** (2 hours)
   - Learn about processes and jobs
   - Use ps, top/htop to monitor processes
   - Practice process control (kill, nice, bg, fg)
   - Understand systemd service basics

4. **Shell Configuration** (2 hours)
   - Understand shell startup files (.bashrc, .bash_profile)
   - Configure basic shell environment variables
   - Create simple aliases for common commands

### Resources

- [Linux Journey - User Management](https://linuxjourney.com/lesson/users-and-groups)
- [Linux Journey - Permissions](https://linuxjourney.com/lesson/file-permissions)
- [ArchWiki - Users and Groups](https://wiki.archlinux.org/title/Users_and_groups)
- [The Linux Command Line (TLCL)](http://linuxcommand.org/tlcl.php) - Chapters 9-10

## Week 4: Package Management and System Configuration

### Core Learning Activities

1. **Package Management with Pacman** (3 hours)
   - Understand package concepts (packages, dependencies, repositories)
   - Learn pacman commands (install, remove, update, search)
   - Configure package repositories
   - Understand the AUR (Arch User Repository)

2. **System Maintenance** (2 hours)
   - Learn proper system update procedures
   - Understand package caches and cleanup
   - Study the pacman log file

3. **Basic System Configuration** (3 hours)
   - Configure locale and language settings
   - Set up time synchronization
   - Configure the hostname and hosts file
   - Basic network configuration

4. **Review and Reflect** (2 hours)
   - Document your installation
   - Create a list of commands you've learned
   - Identify areas of confusion for further study
   - Plan your next steps for Month 2

### Resources

- [ArchWiki - Pacman](https://wiki.archlinux.org/title/Pacman)
- [ArchWiki - System Maintenance](https://wiki.archlinux.org/title/System_maintenance)
- [Linux Journey - Package Management](https://linuxjourney.com/lesson/package-management)

## Common Installation Troubleshooting

### Boot Problems
- **Issue**: System fails to boot after installation
- **Solution**: Boot from installation media, mount your installation, and check `/boot/loader/loader.conf` and entries in `/boot/loader/entries/`

### Network Issues
- **Issue**: No network connectivity after installation
- **Solution**: Check interface with `ip link`, enable with `ip link set <interface> up`, and use `systemctl enable --now NetworkManager`

### Graphics Problems
- **Issue**: Black screen or display issues
- **Solution**: Boot with `nomodeset` kernel parameter, then install proper graphics drivers

### Package Management Issues
- **Issue**: Package installation fails
- **Solution**: Update mirrors with `reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist` and run `pacman -Syyu`

## Projects and Exercises

1. **Installation Documentation** [Beginner]
   - Document your complete installation process, including any issues faced and solutions
   - Create a simplified installation guide with your preferred settings

2. **Command Line Scavenger Hunt** [Beginner-Intermediate]
   - Create a text file with the output of various commands
   - List all running processes owned by your user
   - Find all files in /etc modified in the last week
   - Display disk usage sorted by size

3. **User Management Exercise** [Intermediate]
   - Create a test user with limited permissions
   - Configure sudo access for specific commands
   - Practice changing file ownership and permissions

4. **Package Management Script** [Intermediate-Advanced]
   - Write a bash script that performs system updates
   - Include cleaning the package cache
   - Add logging of update results

## Assessment

You should now be able to:

1. Install Arch Linux from scratch
2. Navigate the filesystem and explain its organization
3. Execute common command-line operations efficiently
4. Properly manage users, groups, and permissions
5. Install, update, and remove packages with pacman
6. Configure basic system settings

## Self-Assessment Quiz

Test your knowledge of the concepts covered this month:

1. What command would you use to list all files, including hidden ones, with detailed information?
2. Which directory contains system-wide configuration files?
3. How would you give read, write, and execute permissions to the owner, read and execute to the group, and no permissions to others for a file?
4. What is the command to install a package using pacman?
5. Which command shows your current working directory?
6. What file contains user account information in Linux?
7. How would you create a new user with a home directory?
8. Which pacman command lists all installed packages?
9. What command would you use to find all files containing the text "network" in the /etc directory?
10. How would you restart the NetworkManager service?

## Preparing for Next Month

The skills you've learned this month will be essential as we move into Month 2: System Configuration and Package Management. Be sure to:

1. **Document your installation choices** - These will be relevant for advanced configuration
2. **Practice package management** - You'll be installing many more packages next month
3. **Get comfortable with the command line** - All future months build on these fundamental skills
4. **Review filesystem hierarchy** - Understanding locations of configuration files is crucial
5. **Practice user and permission management** - Security configuration builds on these concepts

## Next Steps

In Month 2, we'll build on these foundations by:
- Setting up a window manager/desktop environment
- Configuring additional system services
- Exploring more advanced package management
- Learning system configuration file management

## Acknowledgements

This learning guide was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Learning path structure and organization
- Resource recommendations
- Project suggestions

Claude was used as a development aid while all final implementation decisions and verification were performed by Joshua Michael Hall.

## Disclaimer

This guide is provided "as is", without warranty of any kind. Follow all instructions carefully and always make backups before making system changes.
# Month 1: Base System Installation and Core Concepts

This first month focuses on installing a foundational Linux system (Arch Linux) and understanding core Linux concepts. By the end of this month, you'll have a working Arch Linux installation and understand the basic structure and operation of a Linux system.

## Time Commitment: ~10 hours/week for 4 weeks

## Learning Objectives

By the end of this month, you should be able to:

1. Install Arch Linux on a physical machine or virtual environment
2. Navigate the Linux filesystem and understand its structure
3. Execute basic command-line operations
4. Understand Linux user management and permissions
5. Manage packages using pacman
6. Configure basic system settings

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

## Projects and Exercises

1. **Installation Documentation**
   - Document your complete installation process, including any issues faced and solutions
   - Create a simplified installation guide with your preferred settings

2. **Command Line Scavenger Hunt**
   - Create a text file with the output of various commands
   - List all running processes owned by your user
   - Find all files in /etc modified in the last week
   - Display disk usage sorted by size

3. **User Management Exercise**
   - Create a test user with limited permissions
   - Configure sudo access for specific commands
   - Practice changing file ownership and permissions

4. **Package Management Script**
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

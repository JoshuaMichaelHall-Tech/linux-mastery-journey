# Version Control Strategy

This document outlines the version control strategy for managing configurations, dotfiles, and projects within the Linux Mastery Journey repository.

## Table of Contents

1. [Repository Structure](#repository-structure)
2. [Branching Strategy](#branching-strategy)
3. [Commit Guidelines](#commit-guidelines)
4. [Configuration Evolution Management](#configuration-evolution-management)
5. [System-Specific Configurations](#system-specific-configurations)
6. [Dotfiles Management](#dotfiles-management)
7. [Continuous Integration](#continuous-integration)
8. [Backup Strategy](#backup-strategy)

## Repository Structure

The Linux Mastery Journey repository follows a modular structure to organize different aspects of the system:

```
linux-mastery-journey/
├── installation/          # Installation guides and scripts
├── configuration/         # System configuration files
│   ├── system/           # Core system configuration
│   ├── desktop/          # Desktop environment setup
│   └── development/      # Development tools configuration
├── learning_guides/      # Structured learning curriculum
├── troubleshooting/      # Solutions to common problems
└── projects/             # Example projects that demonstrate skills
```

This structure allows for:
- Separation of concerns between different configuration types
- Easy navigation to find specific configurations
- Independent versioning of different components
- Selective adoption of configurations by users

## Branching Strategy

### Main Branches

- **main**: Stable, tested configurations and documentation
- **develop**: Integration branch for new features and changes

### Feature Branches

For significant changes, create feature branches from `develop`:

```
feature/window-manager-config
feature/neovim-lsp-setup
feature/python-environment
```

### System-Specific Branches

For configurations specific to different hardware or use cases:

```
system/desktop-workstation
system/laptop
system/server
```

### Workflow

1. Create feature branch from `develop`
2. Make changes and test
3. Submit pull request to `develop`
4. Review and merge
5. Periodically merge `develop` into `main` for stable releases

## Commit Guidelines

### Commit Message Structure

Each commit message should follow this format:

```
<type>(<scope>): <short summary>

<body>

<footer>
```

### Commit Types

- **feat**: A new feature or enhancement
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Changes that don't affect code functionality (formatting, etc.)
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **test**: Adding or correcting tests
- **chore**: Changes to build process or auxiliary tools

### Scope

Indicate the part of the codebase affected:

- **arch**: Arch Linux specific changes
- **nixos**: NixOS specific changes
- **wm**: Window manager configurations
- **vim**: Vim/Neovim configurations
- **shell**: Shell configurations (zsh, bash)
- **tmux**: Tmux configurations
- **py**: Python environment
- **js**: JavaScript environment
- **docs**: Documentation updates

### Examples

```
feat(vim): add LSP configuration for Python

Add Python language server support to Neovim configuration with pyright.
Configure autocompletion and code navigation features.

Closes #42
```

```
fix(tmux): resolve session persistence issue

Fix tmux-resurrect plugin configuration to properly save and restore
terminal sessions across reboots.
```

## Configuration Evolution Management

### Versioning Configuration Files

All configuration files should include version information and change dates:

```bash
# ~/.zshrc
# Version: 2.3.0
# Last updated: 2025-05-02
# Changes:
# - Added pyenv initialization
# - Updated prompt theme
# - Fixed path variable order
```

### Migration Scripts

For significant configuration changes, provide migration scripts:

```bash
# migration-v2.3.sh
# Migrate from v2.2.x to v2.3.0

# Backup old config
cp ~/.zshrc ~/.zshrc.backup

# Apply changes
sed -i 's/old_setting/new_setting/g' ~/.zshrc
echo "# New setting added by migration" >> ~/.zshrc
echo "export NEW_VARIABLE=value" >> ~/.zshrc
```

### Change Documentation

Document all configuration changes in a changelog:

```markdown
# Changelog

## [2.3.0] - 2025-05-02

### Added
- pyenv initialization in .zshrc
- New Git aliases for improved workflow
- VSCode integration for Neovim

### Changed
- Updated prompt theme to Powerlevel10k
- Reorganized PATH variable for better precedence
- Improved tmux status bar with system information

### Fixed
- ZSH history search keybindings
- Neovim Python plugin configuration
```

## System-Specific Configurations

### Configuration Templates

Provide template configurations that can be customized:

```bash
# template.tmux.conf
# Hardware-specific settings
%if "#{==:#{host},desktop-machine}"
set -g status-style "bg=blue"
%elif "#{==:#{host},laptop}"
set -g status-style "bg=green"
%else
set -g status-style "bg=gray"
%endif
```

### Conditional Includes

Use conditional includes in configuration files:

```bash
# .gitconfig
[include]
    # Include system-specific configuration
    path = ~/.gitconfig.local

[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig.work
```

### Feature Flags

Implement feature flags for optional configurations:

```bash
# .zshrc
# Feature flags
ENABLE_PYTHON_ENV=true
ENABLE_NODE_ENV=true
ENABLE_RUBY_ENV=false

# Conditional loading based on flags
if [ "$ENABLE_PYTHON_ENV" = true ]; then
    # Python environment setup
fi
```

## Dotfiles Management

### Using GNU Stow

The repository uses [GNU Stow](https://www.gnu.org/software/stow/) to manage dotfiles:

```bash
# Directory structure
dotfiles/
├── zsh/
│   ├── .zshrc
│   └── .zprofile
├── vim/
│   ├── .vimrc
│   └── .vim/
├── tmux/
│   └── .tmux.conf
└── git/
    └── .gitconfig
```

Install configurations using:

```bash
cd dotfiles
stow zsh vim tmux git
```

Uninstall configurations using:

```bash
cd dotfiles
stow -D zsh vim tmux git
```

### Bootstrapping Script

A bootstrap script to set up a new system:

```bash
#!/bin/bash
# bootstrap.sh
# Set up a new system with configurations

# Clone repository
git clone https://github.com/username/linux-mastery-journey.git
cd linux-mastery-journey/dotfiles

# Install dependencies
sudo pacman -S stow

# Create backups of existing configs
mkdir -p ~/dotfiles_backup
for file in $(find . -type f -name ".*" | sed 's/^\.\///'); do
    if [ -e ~/$file ]; then
        mv ~/$file ~/dotfiles_backup/
    fi
done

# Install dotfiles
stow */
```

## Continuous Integration

### Validation Scripts

Scripts to validate configuration files:

```bash
#!/bin/bash
# validate-configs.sh

# Validate shell scripts
for file in $(find . -name "*.sh"); do
    shellcheck "$file" || echo "Error in $file"
done

# Validate Vim configuration
vim -u .vimrc -c 'q'

# Validate tmux configuration
tmux -f .tmux.conf start-server \; list-sessions -F '#{session_name}' \; kill-server
```

### Testing Environments

Use Docker containers to test configurations in isolated environments:

```dockerfile
# Dockerfile.test
FROM archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm git zsh vim tmux

COPY dotfiles /dotfiles
WORKDIR /dotfiles

RUN ./validate-configs.sh

CMD ["/bin/zsh"]
```

### GitHub Actions Workflow

Automated validation using GitHub Actions:

```yaml
# .github/workflows/validate.yml
name: Validate Configurations

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Build test container
      run: docker build -t config-test -f Dockerfile.test .
    - name: Run validation
      run: docker run config-test ./validate-configs.sh
```

## Backup Strategy

### Regular Backups

Schedule regular backups of configurations:

```bash
#!/bin/bash
# backup-configs.sh

# Set backup directory
BACKUP_DIR="$HOME/config_backups/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# Copy important config files
cp ~/.zshrc "$BACKUP_DIR/"
cp ~/.vimrc "$BACKUP_DIR/"
cp ~/.tmux.conf "$BACKUP_DIR/"
cp ~/.gitconfig "$BACKUP_DIR/"

# Backup Vim plugins
cp -r ~/.vim "$BACKUP_DIR/"

# Backup specific application configs
cp -r ~/.config/nvim "$BACKUP_DIR/"
cp -r ~/.config/i3 "$BACKUP_DIR/"

# Create a compressed archive
tar -czf "$BACKUP_DIR.tar.gz" "$BACKUP_DIR"
rm -rf "$BACKUP_DIR"

# Cleanup old backups (keep last 5)
find "$HOME/config_backups" -maxdepth 1 -name "*.tar.gz" | sort | head -n -5 | xargs rm -f
```

### Git-Based Backup

Use git to version control personal configurations:

```bash
#!/bin/bash
# git-backup.sh

# Navigate to dotfiles repo
cd ~/dotfiles

# Add all changes
git add -A

# Commit with timestamp
git commit -m "Automated backup $(date +'%Y-%m-%d %H:%M:%S')"

# Push to remote repository
git push origin main
```

### Cloud Synchronization

Synchronize configurations with cloud storage:

```bash
#!/bin/bash
# cloud-sync.sh

# Synchronize configs with cloud
rclone sync ~/dotfiles cloud-storage:dotfiles-backup

# Log the sync
echo "$(date): Synchronized dotfiles to cloud storage" >> ~/.config/backup-logs.txt
```

## Implementation Plan

1. **Initial Setup**: Create the repository structure and add base configurations
2. **Baseline Versioning**: Create initial commit with version 1.0.0 of all configurations
3. **Documentation**: Document the version control strategy and configuration guidelines
4. **Automation**: Set up validation scripts and CI workflows
5. **Backup System**: Implement regular backup procedures
6. **Migration Tools**: Develop tools for migrating between configuration versions
7. **Community Collaboration**: Establish guidelines for external contributions

By following this version control strategy, we can effectively manage the evolution of configurations while maintaining stability and enabling collaboration.

---

> "Master the basics. Then practice them every day without fail." - John C. Maxwell

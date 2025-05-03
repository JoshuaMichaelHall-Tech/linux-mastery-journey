# NixOS Installation Guide

This directory contains guides and resources for installing and configuring NixOS as a professional development environment. The installation process is designed to provide a solid foundation for software development with a focus on declarative configuration and reproducibility.

## Installation Options

This guide provides two installation approaches:

1. **Standard Installation**: A detailed, step-by-step manual installation process that provides deep understanding of the system components.
2. **Declarative Installation**: Full system configuration using Nix expressions for a consistent and reproducible setup.

## Prerequisites

Before beginning the installation, ensure you have:

- A computer with at least 4GB RAM (8GB+ recommended for development)
- At least 20GB free disk space (50GB+ recommended)
- Backed up any important data
- A USB drive (4GB+) for creating installation media
- Internet connection (wired connection recommended for installation)
- Basic familiarity with command-line interfaces
- Basic understanding of functional programming concepts (helpful but not required)

## Installation Media Preparation

1. Download the latest NixOS ISO from the [official website](https://nixos.org/download.html)
2. Create a bootable USB using one of these methods:
   ```bash
   # On Linux
   dd bs=4M if=path/to/nixos.iso of=/dev/sdX status=progress oflag=sync
   
   # On macOS
   dd if=path/to/nixos.iso of=/dev/rdiskX bs=1m
   ```

## Documentation Structure

- [nixos-installation-guide.md](nixos-installation-guide.md): Comprehensive step-by-step installation guide
- [scripts/](scripts/): Helper scripts for installation and post-installation
  - [partition-setup.sh](scripts/partition-setup.sh): Automated disk partitioning script
  - [initial-config.sh](scripts/initial-config.sh): Initial configuration generator
- [configs/](configs/): Example configuration files
  - [configuration.nix](configs/configuration.nix): Example system configuration
  - [hardware-configuration.nix](configs/hardware-configuration.nix): Example hardware configuration

## Installation Overview

The installation process consists of these main phases:

1. **Pre-Installation**: Boot preparation, network setup, disk partitioning
2. **Base Installation**: Installing the base system and generating initial configuration
3. **System Configuration**: Customizing the configuration.nix file
4. **Post-Installation**: Development environment setup, Home Manager configuration

## Key Concepts

NixOS differs from traditional Linux distributions in several important ways:

1. **Declarative Configuration**: The entire system is configured through a central configuration file (`configuration.nix`) rather than modifying files across the filesystem.
2. **Atomic Upgrades**: System changes are done as atomic operations, allowing for easy rollbacks.
3. **Reproducibility**: System configurations can be exactly reproduced across machines.
4. **Reliability**: NixOS avoids common issues like dependency conflicts and partial upgrades.
5. **Multiple Environments**: Different users can have different software environments simultaneously.

## Post-Installation

After completing the base installation, refer to these resources for further configuration:

1. [Month 1 Learning Guide](../learning_guides/month-01-base-system.md) for deepening your understanding of the base system
2. [Desktop Environment Setup](../configuration/desktop/README.md) for customizing your desktop experience
3. [Development Workflow Guide](../configuration/development/README.md) for optimizing your development environment
4. [NixOS and Home Manager Guide](../learning_guides/month-11-nixos.md) for advanced NixOS usage

## Troubleshooting

If you encounter issues during installation, refer to the [Troubleshooting Guide](../../troubleshooting/README.md) for common problems and solutions. The guide includes specific sections for:

- Boot issues
- Network connectivity problems
- Graphics driver configuration
- Package management issues

## Contributing

If you find improvements for the installation process or configurations, please see the [Contributing Guide](../../CONTRIBUTING.md) for information on how to submit changes.

## Acknowledgements

This guide was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Documentation organization
- Installation step sequencing
- Troubleshooting guidance

Claude was used as a development aid while all final implementation decisions and verification were performed by Joshua Michael Hall.

## Disclaimer

This guide is provided "as is", without warranty of any kind. Always back up important data before system installations or major changes.

---

> "Master the basics. Then practice them every day without fail." - John C. Maxwell

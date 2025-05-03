# Linux Mastery Journey - Learning Guides

This directory contains the month-by-month learning curriculum for the Linux Mastery Journey. Each guide provides a structured path with specific learning objectives, practical activities, resources, and projects to help you systematically build Linux expertise for professional software development.

## Curriculum Overview

### Phase 1: Foundations (Months 1-3)
- [**Month 1: Base System Installation and Core Concepts**](month-01-base-system.md)
  - *Topics*: Arch Linux installation, file system hierarchy, command line basics, user management
  - *Project*: Custom Arch Linux installation with documentation
  - *Related Resources*: [Installation Guides](/installation)

- [**Month 2: System Configuration and Package Management**](month-02-system-config.md)
  - *Topics*: systemd, configuration files, pacman, AUR, system maintenance
  - *Project*: Automated system maintenance scripts
  - *Related Resources*: [Troubleshooting Guide](/troubleshooting)

- [**Month 3: Desktop Environment and Workflow Setup**](month-03-desktop-setup.md)
  - *Topics*: Window managers, display configuration, visual customization, keyboard-driven workflows
  - *Project*: Custom desktop environment with dotfiles repository
  - *Related Resources*: [Configuration Files](/configuration)

### Phase a2: Development Environment (Months 4-6)
- [**Month 4: Terminal Tools and Shell Customization**](month-04-terminal-tools.md)
  - *Topics*: Zsh, Tmux, text processing tools, shell scripting
  - *Project*: Custom terminal environment with productivity scripts
  - *Related Resources*: [Development Environment](/configuration/development)

- [**Month 5: Programming Languages and Development Tools**](month-05-dev-tools.md)
  - *Topics*: Neovim, language servers, debugging, Git integration
  - *Project*: IDE-like development environment for multiple languages
  - *Related Resources*: [Python Environment](/configuration/development/languages/python)

- [**Month 6: Containerization and Virtual Environments**](month-06-containers.md)
  - *Topics*: Docker, Docker Compose, virtual environments, reproducible development
  - *Project*: Containerized multi-service application
  - *Related Resources*: [System Monitor Project](/projects/system-monitor)

### Phase 3: System Administration (Months 7-9)
- [**Month 7: System Maintenance and Performance Tuning**](month-07-maintenance.md)
  - *Topics*: System monitoring, performance optimization, backup strategies
  - *Project*: Comprehensive system monitoring and maintenance solution
  - *Related Resources*: [Graphics Troubleshooting](/troubleshooting/graphics.md)

- [**Month 8: Networking and Security Fundamentals**](month-08-networking.md)
  - *Topics*: Network configuration, firewalls, SSH, VPNs
  - *Project*: Secure networking setup with VPN and firewalls
  - *Related Resources*: [Networking Guide](/troubleshooting/networking.md)

- [**Month 9: Automation and Scripting**](month-09-automation.md)
  - *Topics*: Shell scripting, systemd timers, workflow automation
  - *Project*: Automation framework for common tasks
  - *Related Resources*: [System Monitor Scripts](/projects/system-monitor/monitor)

### Phase 4: Advanced Applications (Months 10-12)
- [**Month 10: Cloud Integration and Remote Development**](month-10-cloud.md)
  - *Topics*: Cloud services, remote development, Infrastructure as Code
  - *Project*: Integrated local-cloud development environment
  - *Related Resources*: [Installation Guides](/installation)

- [**Month 11: NixOS and Declarative Configuration**](month-11-nixos.md)
  - *Topics*: NixOS, Nix language, declarative system configuration
  - *Project*: Complete NixOS environment with custom modules
  - *Related Resources*: [NixOS Installation Guide](/installation/nixos)

- [**Month 12: Career Portfolio and Advanced Projects**](month-12-portfolio.md)
  - *Topics*: Portfolio development, project documentation, open source contribution
  - *Project*: Professional Linux expertise portfolio
  - *Related Resources*: [Project Examples](/projects)

## Learning Path Progression

The learning path is designed with deliberate progression:

```
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│  FOUNDATIONS     │     │  TOOLS           │     │  APPLICATIONS    │
│  Months 1-3      │────▶│  Months 4-6      │────▶│  Months 7-12     │
│  Installation    │     │  Customization   │     │  Advanced Usage  │
│  Configuration   │     │  Development     │     │  Projects        │
└──────────────────┘     └──────────────────┘     └──────────────────┘
```

## How to Use These Guides

### Weekly Structure

Each monthly guide is structured in a 4-week format with approximately 10 hours per week:

1. **Week 1**: Core concepts and basic setup
2. **Weeks 2-3**: Deep dives into specific topics
3. **Week 4**: Integration and practical application

### Recommended Approach

1. **Read the entire month's guide** before starting to understand the big picture
2. **Schedule regular learning time** (e.g., 2 hours daily or 5 hours over the weekend)
3. **Complete all hands-on exercises**, as they reinforce the theoretical knowledge
4. **Document your learning** in your own words to aid retention
5. **Build the suggested projects** to solidify practical skills
6. **Connect with the community** for support (see resources in each guide)

### Prerequisites for Success

- Comfortable using the command line interface
- Basic programming knowledge
- Access to a computer where you can install Linux (physical or virtual)
- Willingness to read documentation and solve problems independently
- Persistence when encountering challenges

## Customizing Your Journey

While the guides are designed to be followed sequentially, you may adjust based on your experience:

- **Accelerated Path**: Experienced Linux users might complete Months 1-3 more quickly
- **Focus Areas**: Spend more time on areas relevant to your career goals
- **Extended Learning**: Add supplementary resources for topics of special interest
- **Parallel Projects**: Work on personal projects alongside the curriculum

## Progress Tracking

Track your progress through the curriculum:

- [ ] Month 1: Base System Installation and Core Concepts
- [ ] Month 2: System Configuration and Package Management
- [ ] Month 3: Desktop Environment and Workflow Setup
- [ ] Month 4: Terminal Tools and Shell Customization
- [ ] Month 5: Programming Languages and Development Tools
- [ ] Month 6: Containerization and Virtual Environments
- [ ] Month 7: System Maintenance and Performance Tuning
- [ ] Month 8: Networking and Security Fundamentals
- [ ] Month 9: Automation and Scripting
- [ ] Month 10: Cloud Integration and Remote Development
- [ ] Month 11: NixOS and Declarative Configuration
- [ ] Month 12: Career Portfolio and Advanced Projects

## Community Resources

Enhance your learning experience by connecting with these Linux communities:

- [Arch Linux Forums](https://bbs.archlinux.org/)
- [NixOS Discourse](https://discourse.nixos.org/)
- [r/archlinux](https://www.reddit.com/r/archlinux/)
- [r/unixporn](https://www.reddit.com/r/unixporn/) (for desktop customization)
- [Stack Exchange - Unix & Linux](https://unix.stackexchange.com/)

## Acknowledgements

These learning guides were developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Learning path structure and organization
- Resource recommendations
- Project suggestions

Claude was used as a development aid while all final implementation decisions and verification were performed by Joshua Michael Hall.

## Disclaimer

This guide is provided "as is", without warranty of any kind. Always back up important data before making system changes.

---

> "Master the basics. Then practice them every day without fail." - John C. Maxwell

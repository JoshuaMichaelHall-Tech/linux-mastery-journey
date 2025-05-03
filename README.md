curriculum designed to systematically build expertise:

### Phase 1: Foundations (Months 1-3)
- **Month 1:** [Base System Installation and Core Concepts](/learning_guides/month-01-base-system.md)
  - [Practical Exercises](/learning_guides/month-01-exercises.md)
- **Month 2:** [System Configuration and Package Management](/learning_guides/month-02-system-config.md)
- **Month 3:** [Desktop Environment and Workflow Setup](/learning_guides/month-03-desktop-setup.md)

### Phase 2: Development Environment (Months 4-6)
- **Month 4:** [Terminal Tools and Shell Customization](/learning_guides/month-04-terminal-tools.md)
- **Month 5:** [Programming Languages and Development Tools](/learning_guides/month-05-dev-tools.md)
- **Month 6:** [Containerization and Virtual Environments](/learning_guides/month-06-containers.md)

### Phase 3: System Administration (Months 7-9)
- **Month 7:** [System Maintenance and Performance Tuning](/learning_guides/month-07-maintenance.md)
- **Month 8:** [Networking and Security Fundamentals](/learning_guides/month-08-networking.md)
- **Month 9:** [Automation and Scripting](/learning_guides/month-09-automation.md)

### Phase 4: Advanced Applications (Months 10-12)
- **Month 10:** [Cloud Integration and Remote Development](/learning_guides/month-10-cloud.md)
- **Month 11:** [NixOS and Declarative Configuration](/learning_guides/month-11-nixos.md)
- **Month 12:** [Career Portfolio and Advanced Projects](/learning_guides/month-12-portfolio.md)

→ [Explore the Full Learning Curriculum](/learning_guides)

## Development Environment

A key focus of this project is creating an efficient, powerful development environment for professional software engineering work:

### Terminal Environment

The terminal setup includes:
- **Shell**: Zsh with Oh My Zsh
- **Terminal Multiplexer**: Tmux for session management
- **Editor**: Neovim configured as a full-featured IDE
- **Version Control**: Git with enhanced workflow tools

→ [Terminal Configuration Details](/learning_guides/month-04-terminal-tools.md)

### Programming Languages

Language-specific configurations include:
- **Python**: [Development Environment](/configuration/development/languages/python/README.md)
- **JavaScript**: Node.js, npm, and frontend tooling
- **Ruby**: RVM, Bundler, and testing frameworks

Each language environment is configured for:
- Dependency management
- Code quality (linting/formatting)
- Testing frameworks
- Debugging tools
- Project scaffolding

→ [Language Configuration Details](/configuration/development)

### Container Development

Docker and containerization setup:
- Local development containers
- Multi-service applications
- Production environment parity
- Kubernetes integration

→ [Container Configuration Details](/learning_guides/month-06-containers.md)

## Projects

### System Monitor

A terminal-based system monitoring tool that demonstrates:
- Python development in a Linux environment
- System resource data collection
- Terminal UI development
- Background processes and real-time updates

Key features:
- CPU, memory, disk, and network monitoring
- Process management
- Historical data visualization
- Alerting and notifications

→ [Explore the System Monitor Project](/projects/system-monitor)

## Configuration Files

### System Configuration

Core system configuration files for:
- Boot and system initialization
- Package management
- User management
- Filesystem layout
- Hardware configuration

### Desktop Environment

Desktop configuration for a minimal, keyboard-driven workflow:
- Window manager (i3, Sway, or Hyprland)
- Display server (X11 or Wayland)
- Status bar and notifications
- Application launchers
- Theming and appearance

### Development Environment

Development tools configuration for:
- Code editors and IDEs
- Terminal applications
- Version control systems
- Build tools
- Debugging tools

→ [Explore All Configuration Files](/configuration)

## Troubleshooting

Comprehensive troubleshooting guides for common Linux issues:

### Boot Issues
- Bootloader problems
- Kernel parameters
- Initramfs configuration
- Emergency recovery

### Graphics Issues
- [Driver installation and configuration](/troubleshooting/graphics.md)
- Multi-monitor setup
- GPU performance optimization
- Wayland-specific troubleshooting

### Networking Issues
- [Network configuration](/troubleshooting/networking.md)
- DNS and connectivity problems
- VPN setup
- Wireless troubleshooting

→ [Explore All Troubleshooting Guides](/troubleshooting)

## Essential Resources

### Books
- **The Linux Command Line** by William Shotts - Fundamental command line skills
- **How Linux Works** by Brian Ward - Understanding Linux internals
- **Unix and Linux System Administration Handbook** - Comprehensive reference

### Online Documentation
- [Arch Linux Wiki](https://wiki.archlinux.org/) - Definitive Linux documentation resource
- [NixOS Manual](https://nixos.org/manual/nixos/stable/) - Official NixOS documentation
- [Digital Ocean Community Tutorials](https://www.digitalocean.com/community/tutorials) - Practical guides for Linux concepts

### Tools
- [Explainshell](https://explainshell.com/) - Interactive explanation of shell commands
- [tldr pages](https://tldr.sh/) - Simplified and community-driven man pages
- [ShellCheck](https://www.shellcheck.net/) - Script analysis tool

### Community Resources
- [Arch Linux Forums](https://bbs.archlinux.org/) - Community support and discussion
- [NixOS Discourse](https://discourse.nixos.org/) - NixOS community forum
- [r/archlinux](https://www.reddit.com/r/archlinux/) - Reddit Arch Linux community
- [r/NixOS](https://www.reddit.com/r/NixOS/) - Reddit NixOS community

## Time Commitment

This learning path is designed to be completed in 12 months with approximately 10-15 hours of study per week. The breakdown of time investment is:

- **Initial Setup**: 3-7 days of focused work
- **Adaptation Phase**: 2-4 weeks of regular use and customization
- **Proficiency**: 3-6 months of continued learning and practice
- **Mastery**: Ongoing development beyond the core curriculum

## Repository Organization

```
linux-mastery-journey/
├── installation/               # Installation guides and scripts
│   ├── arch/                   # Arch Linux installation
│   └── nixos/                  # NixOS installation
├── configuration/              # System configuration files
│   ├── system/                 # Core system configuration
│   ├── desktop/                # Desktop environment setup
│   └── development/            # Development tools configuration
├── learning_guides/            # Structured learning curriculum
│   ├── month-01-base-system.md # Month 1 guide
│   ├── month-01-exercises.md   # Month 1 practical exercises
│   └── ...                     # Additional monthly guides
├── troubleshooting/            # Solutions to common problems
│   ├── graphics.md             # Graphics troubleshooting
│   ├── networking.md           # Networking troubleshooting
│   └── ...                     # Additional guides
├── projects/                   # Example projects that demonstrate skills
│   └── system-monitor/         # Terminal-based system monitoring tool
└── README.md                   # This file
```

## Getting Started

If you're following along with this journey, start here:

1. Choose your installation path:
   - [Arch Linux Installation Guide](/installation/arch/README.md)
   - [NixOS Installation Guide](/installation/nixos/README.md)

2. Follow the [Month 1 Guide](/learning_guides/month-01-base-system.md) and [Month 1 Exercises](/learning_guides/month-01-exercises.md) to establish your foundation

3. Progress through each monthly guide as your skills and confidence grow

4. Join the [learning community](#community-resources) to share your journey and get support

## Key Tools and Technologies

- **Operating Systems**: Arch Linux and NixOS
- **Window Managers**: i3wm, Sway, or Hyprland
- **Shell**: Zsh with Oh My Zsh
- **Terminal Multiplexer**: Tmux
- **Editor**: Neovim
- **Development**: Python, JavaScript, Ruby environments
- **Containers**: Docker, Podman
- **System Management**: Systemd, Nix

## Progress Tracking

Track your Linux mastery journey with this checklist:

- [ ] Complete Arch Linux installation
- [ ] Set up development environment
- [ ] Configure window manager and desktop
- [ ] Master shell and terminal tools
- [ ] Set up programming language environments
- [ ] Configure containerization
- [ ] Implement automated system maintenance
- [ ] Configure networking and security
- [ ] Create automation scripts
- [ ] Integrate with cloud services
- [ ] Set up NixOS with declarative configuration
- [ ] Create professional portfolio of Linux skills

## Why This Approach

This repository represents a career-oriented approach to Linux mastery. Rather than learning disjointed concepts, this structured path builds skills systematically, with each month building on the previous one.

The combination of Arch Linux (for deep understanding) and NixOS (for declarative configuration) provides both breadth and depth of Linux knowledge that can significantly enhance a software engineering career.

## Contributing

While this is primarily a personal learning journey, contributions are welcome:

- File an issue for corrections or suggestions
- Submit a PR for improvements to guides or scripts
- Share your own experiences in discussions

See the [CONTRIBUTING.md](/CONTRIBUTING.md) file for guidelines on how to contribute.

## Acknowledgements

This project was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Documentation writing and organization
- Learning path structure
- Troubleshooting and debugging assistance

Claude was used as a development aid while all final implementation decisions and code review were performed by Joshua Michael Hall.

## Disclaimer

This software is provided "as is", without warranty of any kind, express or implied. The authors or copyright holders shall not be liable for any claim, damages or other liability arising from the use of the software.

This project is a work in progress and may contain bugs or incomplete features. Users are encouraged to report any issues they encounter.

## License

This project is licensed under the MIT License - see the [LICENSE](/LICENSE) file for details.

---

> "Master the basics. Then practice them every day without fail." - John C. Maxwell

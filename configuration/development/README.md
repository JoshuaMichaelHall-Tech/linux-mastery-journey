# Development Environment Configuration

This directory contains configuration files and setup guides for creating a professional software development environment on Linux. The configurations focus on terminal-centric workflows using Neovim, tmux, and related tools optimized for Python, JavaScript, and Ruby development.

## Directory Structure

```
development/
├── README.md                      # This file
├── editors/                       # Editor configurations
│   ├── neovim/                    # Neovim configuration
│   │   ├── README.md              # Neovim setup guide
│   │   ├── init.lua               # Main configuration file
│   │   └── lua/                   # Lua modules for Neovim
│   └── vscode/                    # VS Code configuration (alternative)
│       ├── README.md              # VS Code setup guide
│       └── settings.json          # User settings
├── languages/                     # Language-specific configurations
│   ├── python/                    # Python development setup
│   │   ├── README.md              # Python setup guide
│   │   └── pyproject.toml         # Project configuration template
│   ├── javascript/                # JavaScript development setup
│   │   ├── README.md              # JavaScript setup guide
│   │   └── templates/             # Project templates
│   └── ruby/                      # Ruby development setup
│       ├── README.md              # Ruby setup guide
│       └── templates/             # Project templates
└── tools/                         # Development tools configuration
    ├── git/                       # Git configuration
    │   ├── README.md              # Git setup guide
    │   └── gitconfig              # Git configuration template
    ├── docker/                    # Docker configuration
    │   ├── README.md              # Docker setup guide
    │   └── templates/             # Dockerfile templates
    └── database/                  # Database tools
        ├── README.md              # Database setup guide
        └── configs/               # Database configuration templates
```

## Terminal-Centric Development Approach

This configuration embraces a terminal-centric development workflow focused on:

1. **Keyboard-Driven Interface**: Minimize mouse usage for increased productivity
2. **Customizable Environment**: Fully tailorable to your specific needs
3. **Version Control Integration**: Seamless Git workflows
4. **Resource Efficiency**: Lightweight tools that work well on any hardware
5. **Reproducibility**: Configurations can be version-controlled and reproduced across systems

## Core Tools

### Command Line

- **Shell**: Zsh with customized prompt and plugins
- **Terminal Multiplexer**: Tmux for session management
- **File Navigation**: Ranger/Nnn for file browsing
- **Text Search**: Ripgrep, fd, fzf for fast searching
- **Version Control**: Git with enhanced CLI tools

### Text Editing

- **Primary Editor**: Neovim with LSP support
- **Configuration**: Lua-based for better organization and performance
- **Features**:
  - Language Server Protocol (LSP) for code intelligence
  - Treesitter for improved syntax highlighting
  - Telescope for fuzzy finding
  - Git integration with signs and diffs
  - Customized key mappings for efficiency

### Development Tools

- **Virtual Environments**: Python venv/Poetry, Node.js nvm, Ruby rbenv
- **Package Management**: pip, npm/yarn, gem/bundler
- **Testing**: pytest, Jest, RSpec
- **Linting/Formatting**: black/flake8, ESLint/Prettier, Rubocop
- **Containerization**: Docker, Docker Compose
- **Database Tools**: CLI clients for PostgreSQL, MySQL, SQLite

## Setup Instructions

Each subdirectory contains detailed README files with setup instructions for specific components. The general approach for setting up the complete environment follows these steps:

1. Install the base system (Arch Linux or NixOS) following the installation guides
2. Install and configure core tools (Zsh, Tmux, Neovim)
3. Set up language-specific environments
4. Install and configure additional development tools
5. Customize the environment to your preferences

## Customization

All configurations provided here are templates that you should customize according to your preferences and workflow. The most important files to personalize are:

- Shell configuration (`~/.zshrc`)
- Tmux configuration (`~/.tmux.conf`)
- Neovim configuration (`~/.config/nvim/init.lua`)
- Git configuration (`~/.gitconfig`)

## Workflow Examples

The repository includes example workflow scripts to demonstrate efficient development patterns:

1. **Project Setup**: Scripts for initializing new projects with standard structure
2. **Development Workflow**: Examples of daily development workflows
3. **Deployment Pipeline**: Example scripts for deploying applications

## Performance Optimization

Special attention has been paid to performance optimization:

- Fast terminal startup time
- Efficient editor configurations
- Lazy-loading of plugins and components
- Minimal resource usage

## Cross-Platform Compatibility

While primarily designed for Linux, most configurations can be adapted for:

- macOS (with homebrew)
- Windows (with WSL2)

Refer to platform-specific notes in each component's README for details.

## Acknowledgements

This development environment configuration was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Documentation writing and organization
- Configuration structure suggestions
- Workflow optimization guidance

Claude was used as a development aid while all final implementation decisions and code review were performed by Joshua Michael Hall.

## Disclaimer

This configuration is provided "as is", without warranty of any kind. Always back up your existing configurations before applying these settings. The configurations are intended for professional software development and may require customization for specific use cases.

---

> "Master the basics. Then practice them every day without fail." - John C. Maxwell

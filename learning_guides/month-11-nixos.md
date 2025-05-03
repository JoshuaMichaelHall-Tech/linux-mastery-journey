# Month 11: NixOS and Declarative Configuration

This month focuses on the declarative approach to system configuration using NixOS. By the end of this month, you'll understand the Nix language, be able to create custom packages and modules, and maintain your entire system configuration as code.

## Time Commitment: ~10 hours/week for 4 weeks

## Learning Objectives

By the end of this month, you should be able to:

1. Install and configure a complete NixOS system
2. Write and understand configurations in the Nix language
3. Create custom packages and modules
4. Implement reproducible development environments
5. Manage complex system configurations declaratively
6. Apply NixOS principles for reliable system management

## Week 1: NixOS Fundamentals and Installation

### Core Learning Activities

1. **Understanding NixOS Philosophy** (2 hours)
   - Learn about purely functional package management
   - Understand declarative configuration principles
   - Compare traditional vs. NixOS approaches
   - Study atomic upgrades and rollbacks
   - Learn about Nix store and isolation

2. **NixOS Installation** (3 hours)
   - Follow the [NixOS Installation Guide](/installation/nixos/nixos-installation-guide.md)
   - Install base NixOS system
   - Configure initial system settings
   - Understand the configuration.nix file structure

3. **Nix Language Basics** (3 hours)
   - Learn Nix expression language syntax
   - Understand attribute sets and functions
   - Study derivations and packages
   - Learn about evaluation and laziness
   - Practice basic Nix expressions

4. **System Configuration Basics** (2 hours)
   - Understand configuration.nix structure
   - Learn about module system
   - Configure basic system settings
   - Apply and test configurations
   - Use nixos-rebuild command

### Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Expression Language](https://nixos.org/manual/nix/stable/expressions/expression-language.html)
- [Getting Started with NixOS](https://nixos.org/guides/nix-pills/)

## Week 2: Package Management and Development Environments

### Core Learning Activities

1. **NixOS Package Management** (3 hours)
   - Understand package derivations
   - Learn to install and remove packages
   - Search for packages using nix-env and nixpkgs
   - Pin package versions
   - Override package attributes
   - Create custom packages

2. **Declarative Package Management** (2 hours)
   - Configure system-wide packages
   - Manage user packages with home-manager
   - Create package collections
   - Pin nixpkgs versions
   - Handle package overlays

3. **Development Environments** (3 hours)
   - Create project-specific environments with nix-shell
   - Configure language-specific environments
   - Manage developer tools
   - Use direnv integration
   - Work with lorri for improved shell experience

4. **Reproducible Builds** (2 hours)
   - Understand reproducibility principles
   - Configure deterministic builds
   - Lock dependencies
   - Create a fully reproducible development environment
   - Share configurations with colleagues

### Resources

- [Nix Package Manager Guide](https://nixos.org/manual/nix/stable/)
- [Nixpkgs Manual](https://nixos.org/manual/nixpkgs/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)

## Week 3: System Configuration and Customization

### Core Learning Activities

1. **NixOS Module System** (3 hours)
   - Understand the module system architecture
   - Create custom modules
   - Implement module options
   - Handle dependencies between modules
   - Use conditional configuration

2. **System Services Configuration** (3 hours)
   - Configure system services using NixOS modules
   - Understand systemd integration
   - Create custom services
   - Manage service dependencies
   - Handle service configuration

3. **User Environment Configuration** (2 hours)
   - Configure user profiles
   - Manage dotfiles declaratively
   - Configure desktop environment
   - Set up program configurations
   - Handle user service management

4. **Hardware Configuration** (2 hours)
   - Understand hardware-configuration.nix
   - Configure drivers and kernel modules
   - Handle hardware-specific settings
   - Configure graphics and display
   - Manage power management

### Resources

- [NixOS Module System](https://nixos.org/manual/nixos/stable/index.html#sec-writing-modules)
- [Writing NixOS Modules](https://nixos.wiki/wiki/Module)

## Week 4: Advanced NixOS and Integration

### Core Learning Activities

1. **NixOS Generations and System Management** (2 hours)
   - Manage system generations
   - Perform system rollbacks
   - Understand boot management
   - Clean up old generations
   - Test configurations

2. **Distributed Builds and Caching** (2 hours)
   - Configure distributed builds
   - Set up binary caches
   - Create private caches
   - Optimize build times
   - Manage cache signing keys

3. **Multiple System Configuration** (3 hours)
   - Create configurations for multiple machines
   - Share common configurations
   - Manage machine-specific settings
   - Deploy configurations remotely
   - Use NixOps for multi-machine deployment

4. **Integration with Existing Workflow** (3 hours)
   - Integrate NixOS with version control
   - Develop a workflow for configuration changes
   - Set up continuous integration
   - Test configurations automatically
   - Deploy configurations safely

### Resources

- [NixOS Wiki](https://nixos.wiki/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [NixOps Manual](https://nixos.org/manual/nixops/stable/)

## Projects and Exercises

### Project 1: Complete NixOS Environment

1. Install NixOS from scratch following the installation guide
2. Configure your system with the following specifications:
   - User account with appropriate permissions
   - Network configuration with firewall rules
   - Development environment for your primary languages
   - Desktop environment or window manager configuration
   - System services for development (databases, web servers)

3. Create a basic configuration.nix:

```nix
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan
      ./hardware-configuration.nix
    ];

  # Boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos-dev";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
  };

  # Time zone and locale
  time.timeZone = "America/New_York"; # Adjust for your location
  i18n.defaultLocale = "en_US.UTF-8";

  # User account
  users.users.yourusername = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    shell = pkgs.zsh;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System packages
  environment.systemPackages = with pkgs; [
    # Basic utilities
    vim git wget curl firefox htop

    # Development tools
    vscode neovim
    python311 python311Packages.pip
    nodejs_20
    gcc gnumake

    # System tools
    tmux zsh oh-my-zsh
  ];

  # Services
  services = {
    # SSH server
    openssh.enable = true;
    
    # X11 and window manager
    xserver = {
      enable = true;
      desktopManager.xterm.enable = false;
      displayManager.lightdm.enable = true;
      windowManager.i3.enable = true;
    };
  };

  # Docker
  virtualisation.docker.enable = true;

  # This value determines the NixOS release with which your system is compatible
  system.stateVersion = "23.11";
}
```

### Project 2: Development Environment Shells

Create shell.nix files for at least three different development environments:

1. Python development environment:

```nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Python with packages
    (python311.withPackages(ps: with ps; [
      pip
      virtualenv
      pytest
      black
      mypy
      numpy
      pandas
    ]))
    
    # Development tools
    poetry
    gnumake
  ];

  shellHook = ''
    echo "Python development environment activated!"
    export PS1="\e[1;34m(py-dev)\e[0m \w $ "
  '';
}
```

2. Node.js development environment:

```nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    nodejs_20
    yarn
    nodePackages.typescript
    nodePackages.eslint
    nodePackages.prettier
  ];

  shellHook = ''
    echo "Node.js development environment activated!"
    export PS1="\e[1;32m(node-dev)\e[0m \w $ "
    export PATH="$PWD/node_modules/.bin:$PATH"
  '';
}
```

3. System monitoring tool development environment:

```nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Base Python
    (python311.withPackages(ps: with ps; [
      psutil
      py-cpuinfo
      blessed
      pandas
      typer
    ]))
    
    # System utilities for testing
    htop
    sysstat
    lm_sensors
    iproute2
  ];

  shellHook = ''
    echo "System monitoring development environment activated!"
    export PS1="\e[1;35m(sysmon-dev)\e[0m \w $ "
  '';
}
```

### Project 3: Custom NixOS Module

Create a custom NixOS module that configures a complete development workspace:

1. Create a directory structure:

```
~/nixos-config/
├── configuration.nix
├── hardware-configuration.nix
└── modules/
    └── dev-workspace.nix
```

2. Implement dev-workspace.nix:

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.dev-workspace;
in {
  options.services.dev-workspace = {
    enable = mkEnableOption "development workspace configuration";
    
    user = mkOption {
      type = types.str;
      description = "The user for whom to configure the development workspace";
    };
    
    languages = mkOption {
      type = types.listOf types.str;
      default = [];
      example = [ "python" "javascript" "go" ];
      description = "Programming languages to install";
    };
    
    editors = mkOption {
      type = types.listOf types.str;
      default = [ "vim" ];
      example = [ "vim" "vscode" "emacs" ];
      description = "Text editors to install";
    };
    
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Extra packages to install";
    };
  };
  
  config = mkIf cfg.enable {
    # Install language-specific packages
    environment.systemPackages = with pkgs; [
      # Base development tools
      git
      gnumake
      gcc
      gdb
    ] 
    # Add language-specific packages
    ++ (if elem "python" cfg.languages then [ python311 python311Packages.pip python311Packages.black ] else [])
    ++ (if elem "javascript" cfg.languages then [ nodejs_20 nodePackages.npm nodePackages.yarn ] else [])
    ++ (if elem "go" cfg.languages then [ go ] else [])
    ++ (if elem "rust" cfg.languages then [ rustc cargo rustfmt ] else [])
    # Add editors
    ++ (if elem "vim" cfg.editors then [ vim neovim ] else [])
    ++ (if elem "vscode" cfg.editors then [ vscode ] else [])
    ++ (if elem "emacs" cfg.editors then [ emacs ] else [])
    # Add extra packages
    ++ cfg.extraPackages;
    
    # Configure Git globally
    programs.git = {
      enable = true;
      config = {
        init.defaultBranch = "main";
      };
    };
    
    # Enable Docker if needed
    virtualisation.docker.enable = true;
    users.users.${cfg.user}.extraGroups = [ "docker" ];
    
    # Configure terminal and shell
    programs.zsh.enable = true;
    users.users.${cfg.user}.shell = pkgs.zsh;
    
    # Create project directories
    system.activationScripts.devWorkspace = ''
      mkdir -p /home/${cfg.user}/projects
      mkdir -p /home/${cfg.user}/projects/python
      mkdir -p /home/${cfg.user}/projects/javascript
      mkdir -p /home/${cfg.user}/projects/experiments
      chown -R ${cfg.user}:users /home/${cfg.user}/projects
    '';
  };
}
```

3. Import and use in configuration.nix:

```nix
{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ./modules/dev-workspace.nix
    ];
  
  # Enable the development workspace
  services.dev-workspace = {
    enable = true;
    user = "yourusername";
    languages = [ "python" "javascript" "rust" ];
    editors = [ "vim" "vscode" ];
    extraPackages = with pkgs; [
      firefox
      tmux
      ripgrep
      fd
    ];
  };
  
  # Rest of your system configuration
  # ...
}
```

### Project 4: Full System Configuration with Home Manager

Set up a fully declarative system with Home Manager:

1. Add home-manager as a NixOS module:

```nix
{ config, pkgs, ... }:

{
  imports = [ 
    <home-manager/nixos>
  ];

  # Home Manager configuration
  home-manager.users.yourusername = { pkgs, ... }: {
    # Home Manager packages
    home.packages = with pkgs; [
      ripgrep
      fd
      bat
      exa
      fzf
    ];

    # Git configuration
    programs.git = {
      enable = true;
      userName = "Your Name";
      userEmail = "your.email@example.com";
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
      };
    };

    # Neovim configuration
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      extraConfig = ''
        set number
        set relativenumber
        set tabstop=4
        set shiftwidth=4
        set expandtab
        set smartindent
      '';
      plugins = with pkgs.vimPlugins; [
        vim-nix
        vim-surround
        vim-commentary
      ];
    };

    # Tmux configuration
    programs.tmux = {
      enable = true;
      shortcut = "a";
      keyMode = "vi";
      customPaneNavigationAndResize = true;
      extraConfig = ''
        # Status bar
        set -g status-bg black
        set -g status-fg white
        set -g status-left "#[fg=green]#S #[fg=yellow]#I #[fg=cyan]#P"
        set -g status-right "#[fg=cyan]%d %b %R"
      '';
    };

    # Zsh configuration
    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;
      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [ "git" "docker" "python" "node" ];
      };
      shellAliases = {
        ll = "ls -la";
        update = "sudo nixos-rebuild switch";
        gs = "git status";
        gp = "git push";
      };
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Enable home-manager
    programs.home-manager.enable = true;
  };
}
```

## Assessment

You should now be able to:

1. Install and configure NixOS from scratch
2. Write and modify configurations in the Nix language
3. Create and manage development environments with Nix
4. Build custom NixOS modules
5. Manage your entire system configuration declaratively
6. Perform system updates and rollbacks effectively

## Next Steps

In Month 12, we'll build on this knowledge by:
- Creating a professional portfolio showcasing your Linux skills
- Developing advanced projects that demonstrate your expertise
- Contributing to open source projects
- Preparing for professional Linux/DevOps roles

## Cross-References

- The [NixOS Installation Guide](/installation/nixos/nixos-installation-guide.md) provides detailed steps for initial setup
- For performance optimization, refer to [System Maintenance](/learning_guides/month-07-maintenance.md)
- For network configuration, see the [Networking Guide](/troubleshooting/networking.md)
- Review [Month 6: Containerization](/learning_guides/month-06-containers.md) for integrating containers with NixOS
- See [Version Control Strategy](/configuration/development/docs/version_control_strategy.md) for managing NixOS configurations

## Acknowledgements

This learning guide was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Learning path structure and organization
- Nix code examples and configuration templates
- Project ideas and exercises

Claude was used as a development aid while all final implementation decisions and verification were performed by Joshua Michael Hall.

## Disclaimer

This guide is provided "as is", without warranty of any kind. Always make backups before making system changes. NixOS's rollback feature provides additional protection, but proper backups are still essential.
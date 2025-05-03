# Month 11: NixOS and Declarative Configuration

This month shifts focus to NixOS, a Linux distribution built around a purely functional package manager and declarative system configuration. You'll learn how to deploy, configure, and maintain a NixOS system, taking advantage of its unique properties for reproducible and reliable environments.

## Time Commitment: ~10 hours/week for 4 weeks

## Learning Objectives

By the end of this month, you should be able to:

1. Install and configure a complete NixOS system
2. Understand and write configurations in the Nix language
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
   - Prepare installation media
   - Partition and format disks
   - Install base NixOS system
   - Configure initial system settings
   - Perform post-installation setup

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
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [Getting Started with NixOS](https://nixos.wiki/wiki/NixOS_Installation_Guide)
- [Learn Nix Language](https://learnxinyminutes.com/docs/nix/)
- [Nix Language Overview](https://nixos.wiki/wiki/Overview_of_the_Nix_Language)

## Week 2: Package Management and Environments

### Core Learning Activities

1. **Nix Package Manager** (3 hours)
   - Understand nix-env, nix-build, and nix-shell
   - Learn package installation and removal
   - Study generations and rollbacks
   - Configure channels and priorities
   - Learn to search and query packages

2. **Creating Custom Packages** (3 hours)
   - Understand package derivations
   - Create simple package definitions
   - Learn to override existing packages
   - Study build phases and hooks
   - Handle dependencies properly

3. **Development Environments with nix-shell** (2 hours)
   - Create isolated development environments
   - Configure project-specific dependencies
   - Study shell.nix file structure
   - Implement multi-language environments
   - Use direnv integration

4. **Flakes Introduction** (2 hours)
   - Understand Nix flakes concept
   - Learn about reproducible dependencies
   - Configure flake.nix for projects
   - Study flake outputs and inputs
   - Compare flakes vs. traditional approach

### Resources

- [Nixpkgs Manual](https://nixos.org/manual/nixpkgs/stable/)
- [Nix Package Manager Guide](https://nixos.org/manual/nix/stable/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [Building and Running Packages](https://nixos.org/guides/nix-pills/building-and-running.html)
- [Packaging Tutorial](https://nix.dev/tutorials/packaging-existing-software.html)

## Week 3: System Configuration and Modules

### Core Learning Activities

1. **Advanced System Configuration** (3 hours)
   - Configure desktop environments
   - Set up system services
   - Manage users and permissions
   - Configure hardware settings
   - Implement boot options

2. **Managing Dotfiles** (2 hours)
   - Understand Home Manager
   - Configure user-specific settings
   - Manage application configurations
   - Implement dotfile versioning
   - Create consistent multi-machine setup

3. **Creating Custom Modules** (3 hours)
   - Understand NixOS module system
   - Create modular configurations
   - Implement option declarations
   - Define services and configurations
   - Study module composition

4. **Testing and Debugging Configurations** (2 hours)
   - Learn debugging techniques for Nix
   - Implement testing for configurations
   - Study common errors and solutions
   - Use nix-repl for interactive testing
   - Validate configurations before applying

### Resources

- [NixOS Module System](https://nixos.wiki/wiki/Module)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [NixOS Options Search](https://search.nixos.org/options)
- [Writing NixOS Modules](https://nixos.wiki/wiki/NixOS:extend_NixOS)
- [Debugging Nix Expressions](https://nixos.wiki/wiki/Debugging)

## Week 4: Advanced NixOS Techniques

### Core Learning Activities

1. **System Deployment and Management** (3 hours)
   - Learn about NixOps for deployment
   - Understand distributed builds
   - Configure multi-machine deployments
   - Study container integration
   - Implement image building

2. **Reproducible Development** (2 hours)
   - Create fully reproducible environments
   - Configure language-specific settings
   - Set up IDE integration
   - Implement consistent cross-platform setups
   - Ensure dependency pinning

3. **NixOS for Servers** (3 hours)
   - Configure server-specific services
   - Implement secure defaults
   - Study container deployments
   - Configure monitoring and logging
   - Implement backup and recovery

4. **Community and Resources** (2 hours)
   - Explore Nix ecosystem and packages
   - Learn about community modules and overlays
   - Study example configurations
   - Understand contribution process
   - Keep up with Nix developments

### Resources

- [NixOps Manual](https://nixos.org/manual/nixops/stable/)
- [Nixpkgs Contributors Guide](https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md)
- [Example NixOS Configurations](https://github.com/search?q=nixos+configuration)
- [Nix Community Resources](https://nixos.wiki/wiki/Community)
- [Nix Ecosystem](https://nixos.wiki/wiki/Nix_Ecosystem)

## Projects and Exercises

1. **Complete NixOS Migration**
   - Migrate your current Arch Linux setup to NixOS
   - Implement all current functionality in declarative configuration
   - Set up user environments with Home Manager
   - Document the entire configuration
   - Create a Git repository for your NixOS config

2. **Reproducible Development Environment**
   - Create a development environment for a multi-language project
   - Configure IDE integration
   - Implement dependency pinning with flakes
   - Set up CI/CD integration
   - Document the setup process and usage

3. **Custom NixOS Module**
   - Create a custom NixOS module for a specialized service
   - Implement configuration options
   - Add service management
   - Create proper documentation
   - Share with the community (optional)

4. **Multi-Machine Deployment**
   - Configure multiple NixOS machines with shared configuration
   - Implement role-specific configurations
   - Create a deployment strategy
   - Set up secrets management
   - Document the architecture and deployment process

## Assessment

You should now be able to:

1. Install, configure, and maintain a NixOS system
2. Write and understand Nix expressions and configurations
3. Create custom packages and modules
4. Implement reproducible development environments
5. Manage complex system configurations declaratively
6. Apply NixOS principles for reliable system management

## Next Steps

In Month 12, we'll focus on:
- Creating a portfolio of your Linux skills
- Building advanced project implementations
- Documenting your Linux journey
- Preparing for professional applications
- Continuing your learning beyond this curriculum

## Acknowledgements

This learning guide was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Learning path structure and organization
- Resource recommendations
- Project suggestions

Claude was used as a development aid while all final implementation decisions and verification were performed by Joshua Michael Hall.

## Disclaimer

This guide is provided "as is", without warranty of any kind. Follow all instructions carefully and always make backups before making system changes.

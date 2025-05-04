# Month 11: NixOS and Declarative Configuration - Exercises

This document contains practical exercises to accompany the Month 11 learning guide. Complete these exercises to solidify your understanding of the Nix language, declarative system configuration, package management, and NixOS module development.

## NixOS Installation and Documentation Project

Create a comprehensive documentation of your NixOS installation process.

### Tasks:

1. **Prepare for installation**:
   ```bash
   # Create a documentation directory
   mkdir -p ~/nixos-installation-docs
   
   # Document your hardware specifications
   lscpu > ~/nixos-installation-docs/cpu-info.txt
   lsblk > ~/nixos-installation-docs/disk-info.txt
   free -h > ~/nixos-installation-docs/memory-info.txt
   ```

2. **Install NixOS with different partition schemes**:
   ```bash
   # After installation, document your partition layout
   lsblk -f > ~/nixos-installation-docs/partition-scheme.txt
   cat /etc/fstab > ~/nixos-installation-docs/fstab.txt
   ```

3. **Document your system configuration**:
   ```bash
   # Capture important configuration files
   cp /etc/nixos/configuration.nix ~/nixos-installation-docs/
   cp /etc/nixos/hardware-configuration.nix ~/nixos-installation-docs/
   
   # Document your system generation
   nix-env --list-generations > ~/nixos-installation-docs/generations.txt
   ```

4. **Document the configuration building process**:
   ```bash
   # Create a build log
   nixos-rebuild build --show-trace &> ~/nixos-installation-docs/build-log.txt
   
   # Capture dependency graph (requires graphviz)
   nix-store -q --graph $(readlink -f /run/current-system) | dot -Tsvg > ~/nixos-installation-docs/system-graph.svg
   ```

5. **Create a step-by-step guide**:
   Create a markdown document with screenshots combining all your findings into a reproducible installation guide.

## Nix Expression Language Exercise

Create a script that solves several challenges using the Nix expression language:

1. **Create the script file**:
   ```bash
   touch ~/nix-challenges.sh
   chmod +x ~/nix-challenges.sh
   ```

2. **Add the script content**:
   ```bash
   #!/bin/bash
   
   # Create a results directory
   mkdir -p ~/nix-challenges-results
   cd ~/nix-challenges-results
   
   echo "Starting Nix language challenges at $(date)" > results.txt
   echo "==================================" >> results.txt
   
   # Challenge 1: Create a simple attribute set with your personal information
   echo -e "\nCHALLENGE 1: Simple attribute set" >> results.txt
   cat > challenge1.nix << 'EOF'
   let
     person = {
       name = "Your Name";
       email = "your.email@example.com";
       skills = [ "Linux" "Nix" "Development" ];
       experience = {
         years = 5;
         level = "intermediate";
       };
     };
   in
     person
   EOF
   
   nix-instantiate --eval challenge1.nix >> results.txt
   
   # Challenge 2: Function that calculates factorial
   echo -e "\nCHALLENGE 2: Factorial function" >> results.txt
   cat > challenge2.nix << 'EOF'
   let
     factorial = n:
       if n == 0
       then 1
       else n * factorial (n - 1);
   in
     {
       fact5 = factorial 5;
       fact10 = factorial 10;
     }
   EOF
   
   nix-instantiate --eval challenge2.nix >> results.txt
   
   # Challenge 3: Work with lists and string manipulation
   echo -e "\nCHALLENGE 3: List manipulation" >> results.txt
   cat > challenge3.nix << 'EOF'
   with (import <nixpkgs> {});
   let
     lib = pkgs.lib;
     
     myList = [ "nix" "os" "linux" "declarative" "configuration" ];
     
     result = {
       upper = map lib.toUpper myList;
       sorted = lib.sort (a: b: a < b) myList;
       concat = lib.concatStringsSep "-" myList;
       filtered = lib.filter (x: lib.stringLength x > 3) myList;
     };
   in
     result
   EOF
   
   nix-instantiate --eval challenge3.nix >> results.txt
   
   # Challenge 4: Create a simple derivation
   echo -e "\nCHALLENGE 4: Simple derivation" >> results.txt
   cat > challenge4.nix << 'EOF'
   with (import <nixpkgs> {});
   
   derivation {
     name = "hello-world";
     builder = "${bash}/bin/bash";
     args = [ "-c" "echo Hello, NixOS World! > $out" ];
     system = builtins.currentSystem;
   }
   EOF
   
   drv_path=$(nix-instantiate challenge4.nix)
   echo "Derivation path: $drv_path" >> results.txt
   nix-store -r "$drv_path" >> results.txt
   cat $(nix-store -r "$drv_path") >> results.txt
   
   # Challenge 5: Create a more complex derivation
   echo -e "\nCHALLENGE 5: Complex derivation" >> results.txt
   cat > challenge5.nix << 'EOF'
   with (import <nixpkgs> {});
   
   stdenv.mkDerivation {
     name = "custom-script";
     src = ./.; # Current directory
     buildInputs = [ python3 ];
     installPhase = ''
       mkdir -p $out/bin
       cat > $out/bin/system-info.py << INNER_EOF
   #!/usr/bin/env python3
   import platform
   import os
   
   print("System Information Script")
   print("=========================")
   print(f"Hostname: {platform.node()}")
   print(f"Platform: {platform.platform()}")
   print(f"Python: {platform.python_version()}")
   print(f"Current directory: {os.getcwd()}")
   INNER_EOF
       chmod +x $out/bin/system-info.py
     '';
   }
   EOF
   
   drv_path=$(nix-instantiate challenge5.nix)
   echo "Derivation path: $drv_path" >> results.txt
   nix-store -r "$drv_path" >> results.txt
   ls -la "$(nix-store -r "$drv_path")/bin" >> results.txt
   "$(nix-store -r "$drv_path")/bin/system-info.py" >> results.txt
   
   echo -e "\nNix language challenges completed at $(date)" >> results.txt
   echo "Results saved to ~/nix-challenges-results/results.txt"
   ```

3. **Run the script**:
   ```bash
   ./nix-challenges.sh
   ```

4. **Analyze the results** and create a summary of what you've learned about the Nix expression language.

## Development Environment Management Exercise

Create reproducible development environments for different programming tasks:

1. **Create a Python data science environment**:
   ```bash
   # Create directory
   mkdir -p ~/nix-dev-environments/python-data-science
   cd ~/nix-dev-environments/python-data-science
   
   # Create shell.nix
   cat > shell.nix << 'EOF'
   { pkgs ? import <nixpkgs> {} }:

   pkgs.mkShell {
     buildInputs = with pkgs; [
       python3
       python3Packages.numpy
       python3Packages.pandas
       python3Packages.matplotlib
       python3Packages.scikit-learn
       python3Packages.jupyter
       python3Packages.ipython
     ];
     
     shellHook = ''
       echo "Python Data Science Environment"
       echo "==============================="
       python --version
       echo "Available packages: numpy, pandas, matplotlib, scikit-learn, jupyter, ipython"
       echo ""
       
       # Create a sample script
       if [ ! -f "sample_analysis.py" ]; then
         cat > sample_analysis.py << 'INNER_EOF'
   #!/usr/bin/env python3
   import numpy as np
   import pandas as pd
   import matplotlib.pyplot as plt
   
   # Generate sample data
   np.random.seed(42)
   data = np.random.randn(100, 2)
   df = pd.DataFrame(data, columns=['x', 'y'])
   
   # Print basic statistics
   print("Data statistics:")
   print(df.describe())
   
   # Create a scatter plot
   plt.figure(figsize=(8, 6))
   plt.scatter(df['x'], df['y'], alpha=0.7)
   plt.title('Random Data Scatter Plot')
   plt.xlabel('X')
   plt.ylabel('Y')
   plt.grid(True, alpha=0.3)
   plt.savefig('scatter_plot.png')
   print("\nScatter plot saved as 'scatter_plot.png'")
   INNER_EOF
         chmod +x sample_analysis.py
         echo "Created sample_analysis.py"
       fi
     '';
   }
   EOF
   
   # Enter the environment
   nix-shell
   ```

2. **Create a web development environment**:
   ```bash
   # Create directory
   mkdir -p ~/nix-dev-environments/web-dev
   cd ~/nix-dev-environments/web-dev
   
   # Create shell.nix
   cat > shell.nix << 'EOF'
   { pkgs ? import <nixpkgs> {} }:

   pkgs.mkShell {
     buildInputs = with pkgs; [
       nodejs
       nodePackages.npm
       nodePackages.typescript
       nodePackages.webpack
       nodePackages.eslint
       nodePackages.prettier
     ];
     
     shellHook = ''
       echo "Web Development Environment"
       echo "==========================="
       node --version
       npm --version
       echo "Available tools: nodejs, npm, typescript, webpack, eslint, prettier"
       echo ""
       
       # Create a basic project structure
       if [ ! -d "sample-project" ]; then
         mkdir -p sample-project/{src,public}
         
         # Create package.json
         cat > sample-project/package.json << 'INNER_EOF'
   {
     "name": "sample-project",
     "version": "1.0.0",
     "description": "Sample web project created in Nix environment",
     "main": "src/index.js",
     "scripts": {
       "start": "echo 'Starting development server...'",
       "build": "echo 'Building project...'"
     },
     "author": "",
     "license": "MIT"
   }
   INNER_EOF
         
         # Create index.html
         cat > sample-project/public/index.html << 'INNER_EOF'
   <!DOCTYPE html>
   <html lang="en">
   <head>
     <meta charset="UTF-8">
     <meta name="viewport" content="width=device-width, initial-scale=1.0">
     <title>Nix Web Development</title>
     <link rel="stylesheet" href="styles.css">
   </head>
   <body>
     <div class="container">
       <h1>Nix Web Development</h1>
       <p>This page was created in a Nix-managed development environment.</p>
     </div>
     <script src="main.js"></script>
   </body>
   </html>
   INNER_EOF
         
         # Create CSS file
         cat > sample-project/public/styles.css << 'INNER_EOF'
   body {
     font-family: Arial, sans-serif;
     line-height: 1.6;
     margin: 0;
     padding: 0;
     background-color: #f4f4f4;
   }
   
   .container {
     width: 80%;
     margin: 0 auto;
     padding: 2rem;
   }
   
   h1 {
     color: #333;
   }
   INNER_EOF
         
         # Create JS file
         cat > sample-project/src/index.js << 'INNER_EOF'
   console.log('Nix web development environment is working!');
   
   document.addEventListener('DOMContentLoaded', () => {
     const heading = document.querySelector('h1');
     heading.style.textDecoration = 'underline';
     
     console.log('DOM fully loaded');
   });
   INNER_EOF
         
         echo "Created sample web project in 'sample-project' directory"
       fi
     '';
   }
   EOF
   
   # Enter the environment
   nix-shell
   ```

3. **Create a system administration tools environment**:
   ```bash
   # Create directory
   mkdir -p ~/nix-dev-environments/sysadmin
   cd ~/nix-dev-environments/sysadmin
   
   # Create shell.nix
   cat > shell.nix << 'EOF'
   { pkgs ? import <nixpkgs> {} }:

   pkgs.mkShell {
     buildInputs = with pkgs; [
       htop
       iotop
       dstat
       inetutils
       nmap
       tcpdump
       rsync
       jq
       curl
       wget
       tmux
       bat
       ripgrep
     ];
     
     shellHook = ''
       echo "System Administration Environment"
       echo "================================="
       echo "Available tools: htop, iotop, dstat, nmap, tcpdump, rsync, jq, curl, wget, tmux, etc."
       echo ""
       
       # Create a sample monitoring script
       if [ ! -f "system_monitor.sh" ]; then
         cat > system_monitor.sh << 'INNER_EOF'
   #!/usr/bin/env bash
   
   echo "System Monitoring Script"
   echo "========================"
   
   echo -e "\nSystem Information:"
   echo "------------------------"
   uname -a
   
   echo -e "\nCPU Information:"
   echo "------------------------"
   grep "model name" /proc/cpuinfo | head -1
   echo "CPU cores: $(grep -c processor /proc/cpuinfo)"
   
   echo -e "\nMemory Usage:"
   echo "------------------------"
   free -h
   
   echo -e "\nDisk Usage:"
   echo "------------------------"
   df -h | grep -v "tmpfs"
   
   echo -e "\nTop Processes by CPU:"
   echo "------------------------"
   ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head
   
   echo -e "\nTop Processes by Memory:"
   echo "------------------------"
   ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head
   
   echo -e "\nNetwork Connections:"
   echo "------------------------"
   ss -tuln
   
   echo -e "\nReport completed at $(date)"
   INNER_EOF
         chmod +x system_monitor.sh
         echo "Created system_monitor.sh"
       fi
     '';
   }
   EOF
   
   # Enter the environment
   nix-shell
   ```

4. **Create a multi-language development environment**:
   ```bash
   # Create directory
   mkdir -p ~/nix-dev-environments/multi-lang
   cd ~/nix-dev-environments/multi-lang
   
   # Create shell.nix
   cat > shell.nix << 'EOF'
   { pkgs ? import <nixpkgs> {} }:

   pkgs.mkShell {
     buildInputs = with pkgs; [
       # C/C++
       gcc
       cmake
       gnumake
       
       # Python
       python3
       python3Packages.pip
       
       # JavaScript
       nodejs
       
       # Rust
       rustc
       cargo
       
       # Go
       go
       
       # Development tools
       git
       vscode
     ];
     
     shellHook = ''
       echo "Multi-Language Development Environment"
       echo "======================================"
       echo "Available languages and tools:"
       echo " - C/C++: $(gcc --version | head -1)"
       echo " - Python: $(python3 --version)"
       echo " - Node.js: $(node --version)"
       echo " - Rust: $(rustc --version)"
       echo " - Go: $(go version)"
       echo ""
       
       # Create example files for each language
       mkdir -p examples/{c,python,javascript,rust,go}
       
       # C example
       if [ ! -f "examples/c/hello.c" ]; then
         cat > examples/c/hello.c << 'INNER_EOF'
   #include <stdio.h>
   
   int main() {
       printf("Hello from C in Nix environment!\n");
       return 0;
   }
   INNER_EOF
         echo "Created C example"
       fi
       
       # Python example
       if [ ! -f "examples/python/hello.py" ]; then
         cat > examples/python/hello.py << 'INNER_EOF'
   #!/usr/bin/env python3
   
   def main():
       print("Hello from Python in Nix environment!")
   
   if __name__ == "__main__":
       main()
   INNER_EOF
         chmod +x examples/python/hello.py
         echo "Created Python example"
       fi
       
       # JavaScript example
       if [ ! -f "examples/javascript/hello.js" ]; then
         cat > examples/javascript/hello.js << 'INNER_EOF'
   #!/usr/bin/env node
   
   console.log("Hello from JavaScript in Nix environment!");
   INNER_EOF
         chmod +x examples/javascript/hello.js
         echo "Created JavaScript example"
       fi
       
       # Rust example
       if [ ! -f "examples/rust/hello.rs" ]; then
         cat > examples/rust/hello.rs << 'INNER_EOF'
   fn main() {
       println!("Hello from Rust in Nix environment!");
   }
   INNER_EOF
         echo "Created Rust example"
       fi
       
       # Go example
       if [ ! -f "examples/go/hello.go" ]; then
         cat > examples/go/hello.go << 'INNER_EOF'
   package main
   
   import "fmt"
   
   func main() {
       fmt.Println("Hello from Go in Nix environment!")
   }
   INNER_EOF
         echo "Created Go example"
       fi
       
       echo -e "\nExample files created in 'examples' directory"
     '';
   }
   EOF
   
   # Enter the environment
   nix-shell
   ```

5. **Test each development environment** and document your observations on how the Nix approach differs from traditional development environment setups.

## NixOS Module Development Exercise

Create a custom NixOS module to manage a complete development workspace:

1. **Create the module directory structure**:
   ```bash
   # Create the module directory
   mkdir -p ~/nixos-modules/dev-workspace
   cd ~/nixos-modules/dev-workspace
   ```

2. **Create the module definition file**:
   ```bash
   # Create the module file
   cat > default.nix << 'EOF'
   { config, lib, pkgs, ... }:

   with lib;

   let
     cfg = config.services.dev-workspace;
   in {
     options.services.dev-workspace = {
       enable = mkEnableOption "Development workspace environment";
       
       username = mkOption {
         type = types.str;
         description = "The user to configure the development workspace for";
         example = "developer";
       };
       
       languages = mkOption {
         type = types.listOf types.str;
         default = [ "python" "javascript" ];
         description = "Programming languages to support";
         example = ''[ "python" "javascript" "rust" "go" "c" ]'';
       };
       
       editors = mkOption {
         type = types.listOf types.str;
         default = [ "vscode" "vim" ];
         description = "Code editors to install";
         example = ''[ "vscode" "vim" "emacs" "intellij" ]'';
       };
       
       tools = mkOption {
         type = types.listOf types.str;
         default = [ "git" "docker" ];
         description = "Development tools to install";
         example = ''[ "git" "docker" "kubernetes" "terraform" ]'';
       };
       
       projectsDir = mkOption {
         type = types.str;
         default = "projects";
         description = "Name of the projects directory in the user's home";
         example = "dev";
       };
       
       extraPackages = mkOption {
         type = types.listOf types.package;
         default = [];
         description = "Additional packages to install";
         example = "[ pkgs.ripgrep pkgs.jq ]";
       };
     };
     
     config = mkIf cfg.enable {
       # System packages
       environment.systemPackages = 
         # Language-specific packages
         (optional (elem "python" cfg.languages) pkgs.python3) ++
         (optional (elem "javascript" cfg.languages) pkgs.nodejs) ++
         (optional (elem "rust" cfg.languages) pkgs.rustc) ++
         (optional (elem "go" cfg.languages) pkgs.go) ++
         (optional (elem "c" cfg.languages) pkgs.gcc) ++
         
         # Editor packages
         (optional (elem "vscode" cfg.editors) pkgs.vscode) ++
         (optional (elem "vim" cfg.editors) pkgs.vim) ++
         (optional (elem "emacs" cfg.editors) pkgs.emacs) ++
         (optional (elem "intellij" cfg.editors) pkgs.jetbrains.idea-community) ++
         
         # Tool packages
         (optional (elem "git" cfg.tools) pkgs.git) ++
         (optional (elem "docker" cfg.tools) pkgs.docker) ++
         (optional (elem "kubernetes" cfg.tools) pkgs.kubernetes) ++
         (optional (elem "terraform" cfg.tools) pkgs.terraform) ++
         
         # Extra packages
         cfg.extraPackages;
       
       # Docker configuration if needed
       virtualisation = mkIf (elem "docker" cfg.tools) {
         docker.enable = true;
       };
       
       # Create the projects directory
       system.activationScripts.setupDevWorkspace = ''
         mkdir -p /home/${cfg.username}/${cfg.projectsDir}
         chown ${cfg.username}:users /home/${cfg.username}/${cfg.projectsDir}
       '';
       
       # Add the user to relevant groups
       users.users.${cfg.username} = {
         extraGroups = mkIf (elem "docker" cfg.tools) [ "docker" ];
       };
     };
   }
   EOF
   ```

3. **Create a test configuration to use your module**:
   ```bash
   # Create a test configuration
   cat > test-config.nix << 'EOF'
   { pkgs, ... }:

   {
     imports = [ ./default.nix ];
     
     # Enable the module
     services.dev-workspace = {
       enable = true;
       username = "yourusername"; # Change to your actual username
       languages = [ "python" "javascript" "rust" "go" ];
       editors = [ "vscode" "vim" ];
       tools = [ "git" "docker" "kubernetes" ];
       projectsDir = "dev-projects";
       extraPackages = with pkgs; [ 
         ripgrep 
         jq 
         tmux 
         bat 
       ];
     };
   }
   EOF
   ```

4. **Create a testing script**:
   ```bash
   # Create a testing script
   cat > test-module.sh << 'EOF'
   #!/bin/bash
   
   echo "Testing NixOS dev-workspace module..."
   
   # Validate the module syntax
   echo "Validating module syntax..."
   nix-instantiate --parse default.nix
   
   if [ $? -eq 0 ]; then
     echo "✅ Module syntax is valid"
   else
     echo "❌ Module syntax has errors"
     exit 1
   fi
   
   # Validate the module against the NixOS module system
   echo "Validating against NixOS module system..."
   nix-instantiate --eval -E "with import <nixpkgs/nixos> { configuration = ./test-config.nix; }; config.services.dev-workspace" > /dev/null 2>&1
   
   if [ $? -eq 0 ]; then
     echo "✅ Module validates against NixOS module system"
   else
     echo "❌ Module has errors when integrated with NixOS"
     exit 1
   fi
   
   # Print the module options
   echo -e "\nModule options:"
   echo "=============="
   nix-instantiate --eval -E "with import <nixpkgs/nixos> { configuration = ./test-config.nix; }; config.services.dev-workspace" | grep -v "^{" | grep -v "^}$"
   
   echo -e "\nTest completed successfully!"
   EOF
   
   chmod +x test-module.sh
   ```

5. **Run the test script**:
   ```bash
   ./test-module.sh
   ```

6. **Create a module documentation file**:
   ```bash
   # Create documentation
   cat > README.md << 'EOF'
   # Development Workspace NixOS Module

   This module provides a declarative way to set up development environments in NixOS.

   ## Usage

   First, import the module in your NixOS configuration:

   ```nix
   { config, pkgs, ... }:

   {
     imports = [ /path/to/dev-workspace/default.nix ];
     
     services.dev-workspace = {
       enable = true;
       username = "yourusername";
       languages = [ "python" "javascript" "rust" ];
       editors = [ "vscode" "vim" ];
       tools = [ "git" "docker" ];
       projectsDir = "projects";
       extraPackages = with pkgs; [ ripgrep jq tmux ];
     };
   }
   ```

   ## Options

   | Option | Type | Default | Description |
   |--------|------|---------|-------------|
   | `enable` | boolean | `false` | Whether to enable the development workspace |
   | `username` | string | - | The user to configure the workspace for |
   | `languages` | list of strings | `[ "python" "javascript" ]` | Programming languages to support |
   | `editors` | list of strings | `[ "vscode" "vim" ]` | Code editors to install |
   | `tools` | list of strings | `[ "git" "docker" ]` | Development tools to install |
   | `projectsDir` | string | `"projects"` | Name of the projects directory |
   | `extraPackages` | list of packages | `[]` | Additional packages to install |

   ## Supported Languages

   - python
   - javascript
   - rust
   - go
   - c

   ## Supported Editors

   - vscode
   - vim
   - emacs
   - intellij

   ## Supported Tools

   - git
   - docker
   - kubernetes
   - terraform

   ## Notes

   - The module creates a projects directory in the user's home
   - If Docker is enabled, the user is added to the docker group
   - Additional packages can be added through the extraPackages option
   EOF
   ```

## Multi-System Configuration Management Exercise

Create a flake-based configuration for managing multiple systems:

1. **Create a flake directory structure**:
   ```bash
   # Create the flake directory
   mkdir -p ~/nixos-configs/{hosts,modules,users,pkgs}
   cd ~/nixos-configs
   ```

2. **Create the flake.nix file**:
   ```bash
   # Create the flake.nix file
   cat > flake.nix << 'EOF'
   {
     description = "NixOS system configurations";
     
     inputs = {
       # Core dependencies
       nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
       home-manager = {
         url = "github:nix-community/home-manager";
         inputs.nixpkgs.follows = "nixpkgs";
       };
       
       # Optional dependencies
       nixos-hardware.url = "github:NixOS/nixos-hardware/master";
     };
     
     outputs = { self, nixpkgs, home-manager, nixos-hardware, ... }@inputs:
     let
       # System types to support
       supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
       
       # Helper function to generate an attribute set for each supported system
       forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
       
       # Nixpkgs configuration
       nixpkgsConfig = {
         allowUnfree = true;
         allowBroken = false;
       };
     in
     {
       # NixOS configurations
       nixosConfigurations = {
         # Desktop configuration
         desktop = nixpkgs.lib.nixosSystem {
           system = "x86_64-linux";
           modules = [
             # Hardware configuration
             ./hosts/desktop/hardware-configuration.nix
             
             # Base configuration
             ./hosts/desktop/configuration.nix
             
             # Home manager module
             home-manager.nixosModules.home-manager
             {
               home-manager.useGlobalPkgs = true;
               home-manager.useUserPackages = true;
               home-manager.users.yourusername = import ./users/yourusername/home.nix;
             }
             
             # Custom modules
             ./modules/dev-workspace
           ];
           specialArgs = { inherit inputs; };
         };
         
         # Laptop configuration
         laptop = nixpkgs.lib.nixosSystem {
           system = "x86_64-linux";
           modules = [
             # Hardware configuration
             ./hosts/laptop/hardware-configuration.nix
             nixos-hardware.nixosModules.dell-xps-15-9500
             
             # Base configuration
             ./hosts/laptop/configuration.nix
             
             # Home manager module
             home-manager.nixosModules.home-manager
             {
               home-manager.useGlobalPkgs = true;
               home-manager.useUserPackages = true;
               home-manager.users.yourusername = import ./users/yourusername/home.nix;
             }
             
             # Custom modules
             ./modules/dev-workspace
           ];
           specialArgs = { inherit inputs; };
         };
         
         # Server configuration
         server = nixpkgs.lib.nixosSystem {
           system = "x86_64-linux";
           modules = [
             # Hardware configuration
             ./hosts/server/hardware-configuration.nix
             
             # Base configuration
             ./hosts/server/configuration.nix
             
             # Custom modules
             ./modules/server
           ];
           specialArgs = { inherit inputs; };
         };
       };
       
       # Development environments
       devShells = forAllSystems (system:
         let
           pkgs = import nixpkgs {
             inherit system;
             config = nixpkgsConfig;
           };
         in
         {
           default = pkgs.mkShell {
             buildInputs = with pkgs; [
               nixpkgs-fmt
               git
             ];
             shellHook = ''
               echo "NixOS configuration development shell"
               echo "====================================="
               echo "Available commands:"
               echo "  nixpkgs-fmt *.nix  - Format Nix files"
               echo "  git status         - Check status of repository"
               echo ""
             '';
           };
         }
       );
     };
   }
   EOF
   ```

3. **Create host-specific configuration directories**:
   ```bash
   # Create directories for each host
   mkdir -p hosts/{desktop,laptop,server}
   
   # Create basic configuration files
   
   # Desktop
   cat > hosts/desktop/configuration.nix << 'EOF'
   { config, pkgs, inputs, ... }:

   {
     imports = [];
     
     # Basic system configuration
     networking.hostName = "desktop";
     time.timeZone = "America/New_York";
     
     # Desktop environment
     services.xserver = {
       enable = true;
       displayManager.gdm.enable = true;
       desktopManager.gnome.enable = true;
     };
     
     # Common packages
     environment.systemPackages = with pkgs; [
       firefox
       git
       vim
       tmux
     ];
     
     # Enable development workspace
     services.dev-workspace = {
       enable = true;
       username = "yourusername"; # Change to your actual username
       languages = [ "python" "javascript" "rust" "go" ];
       editors = [ "vscode" "vim" ];
       tools = [ "git" "docker" "kubernetes" ];
     };
     
     # System version
     system.stateVersion = "24.05";
   }
   EOF
   
   # Create dummy hardware configuration
   cat > hosts/desktop/hardware-configuration.nix << 'EOF'
   { config, lib, pkgs, modulesPath, ... }:

   {
     imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
     
     # This is a placeholder. Replace with your actual hardware configuration.
     boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
     boot.initrd.kernelModules = [];
     boot.kernelModules = [ "kvm-intel" ];
     boot.extraModulePackages = [];
     
     fileSystems."/" = {
       device = "/dev/disk/by-label/nixos";
       fsType = "ext4";
     };
     
     fileSystems."/boot" = {
       device = "/dev/disk/by-label/boot";
       fsType = "vfat";
     };
     
     swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];
     
     networking.useDHCP = lib.mkDefault true;
     
     hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
   }
   EOF
   
   # Laptop
   cat > hosts/laptop/configuration.nix << 'EOF'
   { config, pkgs, inputs, ... }:

   {
     imports = [];
     
     # Basic system configuration
     networking.hostName = "laptop";
     time.timeZone = "America/New_York";
     
     # Desktop environment
     services.xserver = {
       enable = true;
       displayManager.sddm.enable = true;
       desktopManager.plasma5.enable = true;
     };
     
     # Power management
     services.tlp.enable = true;
     
     # Common packages
     environment.systemPackages = with pkgs; [
       firefox
       git
       vim
       tmux
     ];
     
     # Enable development workspace
     services.dev-workspace = {
       enable = true;
       username = "yourusername"; # Change to your actual username
       languages = [ "python" "javascript" ];
       editors = [ "vscode" "vim" ];
       tools = [ "git" ];
     };
     
     # System version
     system.stateVersion = "24.05";
   }
   EOF
   
   # Create dummy hardware configuration
   cat > hosts/laptop/hardware-configuration.nix << 'EOF'
   { config, lib, pkgs, modulesPath, ... }:

   {
     imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
     
     # This is a placeholder. Replace with your actual hardware configuration.
     boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
     boot.initrd.kernelModules = [];
     boot.kernelModules = [ "kvm-intel" ];
     boot.extraModulePackages = [];
     
     fileSystems."/" = {
       device = "/dev/disk/by-label/nixos";
       fsType = "ext4";
     };
     
     fileSystems."/boot" = {
       device = "/dev/disk/by-label/boot";
       fsType = "vfat";
     };
     
     swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];
     
     networking.useDHCP = lib.mkDefault true;
     
     hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
   }
   EOF
   
   # Server
   cat > hosts/server/configuration.nix << 'EOF'
   { config, pkgs, inputs, ... }:

   {
     imports = [];
     
     # Basic system configuration
     networking.hostName = "server";
     time.timeZone = "America/New_York";
     
     # No desktop environment for server
     
     # Server-specific services
     services.openssh.enable = true;
     networking.firewall.allowedTCPPorts = [ 22 80 443 ];
     
     # Common packages
     environment.systemPackages = with pkgs; [
       git
       vim
       tmux
       htop
     ];
     
     # System version
     system.stateVersion = "24.05";
   }
   EOF
   
   # Create dummy hardware configuration
   cat > hosts/server/hardware-configuration.nix << 'EOF'
   { config, lib, pkgs, modulesPath, ... }:

   {
     imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
     
     # This is a placeholder. Replace with your actual hardware configuration.
     boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
     boot.initrd.kernelModules = [];
     boot.kernelModules = [ "kvm-intel" ];
     boot.extraModulePackages = [];
     
     fileSystems."/" = {
       device = "/dev/disk/by-label/nixos";
       fsType = "ext4";
     };
     
     fileSystems."/boot" = {
       device = "/dev/disk/by-label/boot";
       fsType = "vfat";
     };
     
     swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];
     
     networking.useDHCP = lib.mkDefault true;
     
     hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
   }
   EOF
   ```

4. **Create user configuration directory**:
   ```bash
   # Create user configuration directory
   mkdir -p users/yourusername
   
   # Create home-manager configuration
   cat > users/yourusername/home.nix << 'EOF'
   { config, pkgs, ... }:

   {
     # Home Manager needs a bit of information about you and the paths it should manage
     home.username = "yourusername"; # Change to your actual username
     home.homeDirectory = "/home/yourusername"; # Change to your actual home directory
     
     # Packages specific to this user
     home.packages = with pkgs; [
       htop
       ripgrep
       fd
       fzf
       bat
       exa
       jq
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
     
     # Shell configuration
     programs.bash = {
       enable = true;
       shellAliases = {
         ll = "ls -la";
         ".." = "cd ..";
         "..." = "cd ../..";
       };
     };
     
     programs.zsh = {
       enable = true;
       enableAutosuggestions = true;
       enableSyntaxHighlighting = true;
       shellAliases = {
         ll = "ls -la";
         ".." = "cd ..";
         "..." = "cd ../..";
       };
       oh-my-zsh = {
         enable = true;
         plugins = [ "git" "docker" "sudo" "tmux" ];
         theme = "robbyrussell";
       };
     };
     
     # Vim configuration
     programs.vim = {
       enable = true;
       extraConfig = ''
         syntax on
         set number
         set relativenumber
         set expandtab
         set tabstop=2
         set shiftwidth=2
         set softtabstop=2
         set mouse=a
       '';
     };
     
     # Tmux configuration
     programs.tmux = {
       enable = true;
       clock24 = true;
       keyMode = "vi";
       terminal = "screen-256color";
       extraConfig = ''
         # Use Ctrl+a as prefix
         set -g prefix C-a
         unbind C-b
         bind C-a send-prefix
         
         # Easier split keys
         bind | split-window -h
         bind - split-window -v
         
         # Easy reload
         bind r source-file ~/.tmux.conf \; display "Reloaded!"
       '';
     };
     
     # Alacritty terminal configuration
     programs.alacritty = {
       enable = true;
       settings = {
         window = {
           padding = {
             x = 10;
             y = 10;
           };
         };
         font = {
           normal = {
             family = "JetBrains Mono";
             style = "Regular";
           };
           size = 12.0;
         };
       };
     };
     
     # VSCode configuration
     programs.vscode = {
       enable = true;
       extensions = with pkgs.vscode-extensions; [
         vscodevim.vim
         ms-python.python
         jnoortheen.nix-ide
       ];
       userSettings = {
         "editor.fontFamily" = "'JetBrains Mono', 'monospace'";
         "editor.fontSize" = 14;
         "editor.lineNumbers" = "relative";
         "editor.formatOnSave" = true;
         "workbench.colorTheme" = "Default Dark+";
       };
     };
     
     # Let Home Manager manage itself
     programs.home-manager.enable = true;
     
     # This value determines the Home Manager release that your
     # configuration is compatible with.
     home.stateVersion = "24.05";
   }
   EOF
   ```

5. **Copy the dev-workspace module**:
   ```bash
   # Create the modules directory
   mkdir -p modules/dev-workspace
   
   # Copy the dev-workspace module
   cp ~/nixos-modules/dev-workspace/default.nix modules/dev-workspace/
   ```

6. **Create a README.md file**:
   ```bash
   # Create README.md
   cat > README.md << 'EOF'
   # NixOS Configurations

   This repository contains NixOS configurations for multiple systems managed with Nix Flakes.

   ## Systems

   - **Desktop**: Personal workstation with full development environment
   - **Laptop**: Mobile development machine with power management
   - **Server**: Headless server with SSH

   ## Usage

   ### Prerequisites

   - NixOS with flakes enabled
   - Git

   ### Building and Deploying

   First, clone this repository:

   ```bash
   git clone https://github.com/yourusername/nixos-configs.git
   cd nixos-configs
   ```

   To switch to a specific configuration:

   ```bash
   sudo nixos-rebuild switch --flake .#desktop
   # or
   sudo nixos-rebuild switch --flake .#laptop
   # or
   sudo nixos-rebuild switch --flake .#server
   ```

   To update all inputs:

   ```bash
   nix flake update
   ```

   To enter the development shell:

   ```bash
   nix develop
   ```

   ## Structure

   - **flake.nix**: Main configuration entry point
   - **hosts/**: System-specific configurations
     - **desktop/**: Desktop configuration
     - **laptop/**: Laptop configuration
     - **server/**: Server configuration
   - **modules/**: Custom NixOS modules
     - **dev-workspace/**: Development workspace module
   - **users/**: User-specific Home Manager configurations
     - **yourusername/**: Your user configuration
   - **pkgs/**: Custom packages

   ## License

   MIT
   EOF
   ```

7. **Create a .gitignore file**:
   ```bash
   # Create .gitignore
   cat > .gitignore << 'EOF'
   # Nix
   result
   result-*
   
   # Direnv
   .direnv/
   
   # Hardware configs should be replaced by actual configs
   hardware-configuration.nix
   
   # Editor files
   .vscode/
   *~
   *.swp
   EOF
   ```

8. **Initialize a Git repository**:
   ```bash
   # Initialize Git
   git init
   git add .
   git commit -m "Initial commit"
   ```

9. **Optional: Create a deployment script**:
   ```bash
   # Create a deployment script
   cat > deploy.sh << 'EOF'
   #!/bin/bash
   
   set -e
   
   function usage() {
     echo "Usage: $0 [--dry-run] host"
     echo "  --dry-run   Build but don't deploy the config"
     echo "  host        The host to deploy (desktop, laptop, server)"
     exit 1
   }
   
   DRY_RUN=0
   HOST=""
   
   # Parse arguments
   while [[ $# -gt 0 ]]; do
     case $1 in
       --dry-run)
         DRY_RUN=1
         shift
         ;;
       desktop|laptop|server)
         HOST=$1
         shift
         ;;
       *)
         usage
         ;;
     esac
   done
   
   # Check for required arguments
   if [ -z "$HOST" ]; then
     usage
   fi
   
   # Check that the host configuration exists
   if [ ! -d "hosts/$HOST" ]; then
     echo "Error: Configuration for host '$HOST' not found"
     exit 1
   fi
   
   echo "-------------------------------------------"
   echo "Deploying configuration for host: $HOST"
   echo "-------------------------------------------"
   
   # Build and optionally deploy
   if [ $DRY_RUN -eq 1 ]; then
     echo "Dry run: Building but not deploying..."
     nixos-rebuild build --flake ".#$HOST"
   else
     echo "Building and deploying..."
     sudo nixos-rebuild switch --flake ".#$HOST"
   fi
   
   if [ $? -eq 0 ]; then
     echo "-------------------------------------------"
     echo "Deployment successful!"
     echo "-------------------------------------------"
   else
     echo "-------------------------------------------"
     echo "Deployment failed!"
     echo "-------------------------------------------"
     exit 1
   fi
   EOF
   
   chmod +x deploy.sh
   ```

10. **Test the configuration** (if possible, or just check the syntax):
    ```bash
    # Check flake syntax
    nix flake check
    ```

## Projects and Exercises

### Project 1: Complete NixOS Development Environment [Intermediate] (8-10 hours)

Create a fully configured NixOS development environment that includes:

1. Base NixOS system with graphical interface
2. Development tools for web development (node.js, npm, etc.)
3. Development tools for backend development (Python, databases, etc.)
4. Custom shell configuration with nice prompt, aliases, and functions
5. Advanced editor setup (VSCode or Neovim) with extensions and configuration
6. Container management with Docker
7. Basic project structure for a full-stack application

Document your configuration in a Git repository and include a README explaining how to deploy it.

### Project 2: NixOS Package Development [Advanced] (6-8 hours)

Create a custom Nix package for a tool or application that isn't currently packaged in nixpkgs:

1. Choose a small open-source tool that you find useful
2. Write a proper Nix derivation for it
3. Create a flake that exposes your package
4. Test that the package builds and runs correctly
5. Document the package and how to use it
6. Optionally, submit your package to nixpkgs or a personal collection

### Project 3: NixOS Home Server [Advanced] (10-12 hours)

Create a NixOS configuration for a home server that provides multiple services:

1. Base NixOS server configuration (headless)
2. Network file sharing service (NFS or Samba)
3. Media server (such as Jellyfin or Plex)
4. Automatic backup system
5. Simple web server for hosting personal website
6. Monitoring and alerting (like Prometheus + Grafana)
7. Automatic updates with specific maintenance windows
8. Security hardening

Deploy the configuration on a real or virtual machine and test each service.

### Project 4: Multi-Machine Deployment [Expert] (12-15 hours)

Design a Nix-based infrastructure for a small development team:

1. Create a flake-based NixOS configuration repository
2. Add configurations for:
   - Development workstations
   - Testing server
   - Production server
3. Implement shared modules and code
4. Create a deployment system with secrets management
5. Set up CI/CD for the configuration itself
6. Document the entire system for onboarding team members
7. Include rollback procedures and monitoring

Deploy to at least one machine (can be virtual) and document the process.

## Additional Resources

### Nix Language Reference

- **Basic Types**:
  ```
  strings: "hello" or ''multi-line''
  integers: 42
  floats: 3.14
  booleans: true, false
  null: null
  lists: [ 1 2 3 ]
  attribute sets: { a = 1; b = 2; }
  functions: x: x + 1
  ```

- **Common Operators**:
  ```
  + - * /           # Arithmetic
  ++                # List concatenation
  ==, !=, <, >, etc # Comparison
  &&, ||, !         # Logical
  ?                 # Attribute set membership test
  ```

- **Control Structures**:
  ```
  if condition then value1 else value2

  let
    x = 1;
    y = 2;
  in
    x + y

  with import <nixpkgs> {}; pkgs.hello
  ```

### NixOS Module System Reference

```
Module Structure:
{ config, lib, pkgs, ... }:

{
  # Imports
  imports = [ ./other-module.nix ];
  
  # Options declaration
  options = {
    services.myservice = {
      enable = lib.mkEnableOption "My custom service";
      port = lib.mkOption {
        type = lib.types.port;
        default = 8080;
        description = "Port to listen on";
      };
    };
  };
  
  # Configuration
  config = lib.mkIf config.services.myservice.enable {
    systemd.services.myservice = {
      wantedBy = [ "multi-user.target" ];
      script = ''
        exec ${pkgs.mypackage}/bin/myservice --port ${toString config.services.myservice.port}
      '';
    };
  };
}
```

### Nixpkgs Function Reference

```
# Basic derivation
derivation {
  name = "hello";
  builder = "${bash}/bin/bash";
  args = [ "-c" "echo Hello > $out" ];
  system = builtins.currentSystem;
}

# Common pattern for packages
{ lib, stdenv, fetchFromGitHub, ... }:

stdenv.mkDerivation rec {
  pname = "example";
  version = "1.0.0";
  
  src = fetchFromGitHub {
    owner = "user";
    repo = "repo";
    rev = "v${version}";
    sha256 = "0000000000000000000000000000000000000000000000000000";
  };
  
  buildInputs = [ /* dependencies */ ];
  
  configurePhase = ''
    # Configure commands
  '';
  
  buildPhase = ''
    # Build commands
  '';
  
  installPhase = ''
    # Install commands
  '';
  
  meta = with lib; {
    description = "Example package";
    homepage = "https://example.com";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ yourname ];
  };
}
```

### Linux Filesystem Hierarchy in NixOS

```
/
├── boot          # Boot loader files
├── etc           # Host-specific system configuration
│   └── nixos     # NixOS configuration
├── home          # User home directories
├── nix           # Nix package manager files
│   ├── store     # Nix store containing all packages
│   └── var       # Nix database and logs
├── run           # Runtime variable data
├── tmp           # Temporary files
└── usr           # Secondary hierarchy
```

### NixOS Configuration Structure

```
/etc/nixos/
├── configuration.nix       # Main system configuration
├── hardware-configuration.nix  # Hardware-specific settings
└── additional-module.nix   # Custom or additional modules
```

### Key NixOS Commands

```
nixos-rebuild switch    # Activate a new configuration
nixos-rebuild build     # Build but don't activate
nixos-rebuild boot      # Build and add to boot menu
nixos-rebuild test      # Build and activate temporarily
nixos-rebuild --rollback # Revert to previous generation
nix-env -i package      # Install a package for the user
nix-env -e package      # Uninstall a package
nix-env -q              # List installed packages
nix-env --rollback      # Rollback to previous generation
nix-collect-garbage     # Clean up unused packages
```

## Reflection Questions

After completing the exercises and projects, reflect on these questions:

1. How does NixOS's declarative approach to system configuration compare to the traditional imperative approach used by other Linux distributions? What are the advantages and disadvantages of each?

2. How does the Nix package manager's approach to dependency management solve common problems like dependency conflicts and "dependency hell"? Are there any downsides to this approach?

3. In what ways has the Nix expression language influenced your thinking about configuration, software installation, and system management? How might you apply these concepts to other areas of your work?

4. How could the NixOS approach to system management be integrated with existing DevOps practices like Infrastructure as Code and CI/CD pipelines?

5. What challenges did you encounter during the NixOS installation and configuration process? How did you solve them?

6. How does the ability to roll back system configurations affect your approach to system administration? How might it change your testing and deployment strategies?

7. What improvements could be made to the NixOS ecosystem to make it more accessible to beginners or more powerful for experts?

8. How do you think declarative configuration systems like NixOS will evolve in the future, and what role might they play in cloud computing, containerization, and other modern computing paradigms?

## Answers to Self-Assessment Quiz

1. The term "purely functional" means that Nix treats packages like values in a functional programming language. Packages are built based solely on their inputs, and the result of a build is immutable - once built, a package cannot be changed. This ensures reproducibility and eliminates side effects.

2. Traditional Linux distributions use an imperative approach where system states are modified in-place. NixOS uses a declarative approach where the desired system state is described in configuration files, and the system builds that exact state without modifying existing components.

3. The Nix store at `/nix/store` contains all packages, configurations, and system components in an immutable, content-addressed way. Each component has a unique hash-based path that encodes its complete dependency graph, ensuring isolation and preventing conflicts.

4. `nixos-rebuild switch` builds the new system configuration and activates it immediately, while `nixos-rebuild test` builds and activates the configuration only for the current session without making it permanent across reboots.

5. A Nix derivation is a description of how to build a package. It specifies inputs, build steps, and dependencies. A package is the result of building a derivation - the actual binaries, libraries, and files that get installed.

6. You can pin a specific version of a package in NixOS by either specifying the exact version in a package declaration, using a fixed version of nixpkgs, or creating a custom overlay that provides the specific version you need.

7. The `imports` attribute in a NixOS configuration is used to include other modules into the current configuration. It allows for modular configuration by breaking complex setups into smaller, reusable components.

8. NixOS handles system rollbacks by keeping a list of all previous system generations. Each change creates a new generation, and previous generations remain accessible through the bootloader. You can switch to a previous generation with `nixos-rebuild --rollback` or by selecting it at boot time.

9. The `mkOption` function is used to declare configuration options in NixOS modules. It defines the type, default value, description, and other properties of an option, creating a well-documented and type-checked interface for module users.

10. Generations in NixOS are immutable, complete snapshots of system configurations. Each time you rebuild the system, a new generation is created. This allows for atomic updates and reliable rollbacks, as you can always boot into a previous, working configuration if something goes wrong.

## Next Steps

After completing the Month 11 exercises, consider these activities to further solidify your learning:

1. **Join the NixOS community** through IRC, Discord, or the NixOS Discourse forum

2. **Contribute to the NixOS ecosystem** by improving documentation, submitting package updates, or fixing bugs

3. **Create a personal dotfiles repository** managed with Nix and Home Manager

4. **Set up a CI/CD pipeline** for your NixOS configurations using GitHub Actions or similar services

5. **Experiment with NixOps** for deploying configurations to remote machines

6. **Deploy NixOS to cloud providers** like AWS, GCP, or DigitalOcean

7. **Explore advanced topics** like cross-compilation, distributed builds, and binary caches

8. **Try other Nix-based tools** like Nix-darwin (for macOS) or home-manager standalone mode (for non-NixOS systems)

Remember: The key to mastering NixOS is regular practice and experimentation. Keep refining your configurations and learning from the community!

## Acknowledgements

This exercise guide was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Exercise structure and organization
- Resource recommendations
- Script development suggestions
- Nix language examples

Claude was used as a development aid while all final implementation decisions and review were performed by Joshua Michael Hall.

## Disclaimer

These exercises are provided "as is", without warranty of any kind. Always make backups before making system changes. Be particularly careful when experimenting with NixOS as improper configurations might render your system unbootable. However, the rollback feature provides an additional layer of safety.
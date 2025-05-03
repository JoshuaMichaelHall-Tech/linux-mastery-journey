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
   - Understand package evaluation and derivation concepts

2. **NixOS Installation** (3 hours)
   - Prepare installation media
   - Partition and format disks
   - Install base NixOS system
   - Configure initial system settings
   - Perform post-installation setup
   - Understand the configuration.nix file structure

3. **Nix Language Basics** (3 hours)
   - Learn Nix expression language syntax
   - Understand attribute sets and functions
   - Study derivations and packages
   - Learn about evaluation and laziness
   - Practice basic Nix expressions
   - Understand the Nix expression vs. the Nix programming language

4. **System Configuration Basics** (2 hours)
   - Understand configuration.nix structure
   - Learn about module system
   - Configure basic system settings
   - Apply and test configurations
   - Use nixos-rebuild command
   - Understand system generations

### Practical Exercises

#### Installing NixOS

1. Download the NixOS ISO:

Download the latest NixOS ISO from the official website: https://nixos.org/download.html

2. Create a bootable USB drive:

```bash
# For Linux
dd if=nixos-*.iso of=/dev/sdX bs=4M status=progress
```

3. Boot from the USB drive and open a terminal.

4. Prepare your disk (example for a simple setup with one disk):

```bash
# Create a new GPT partition table
parted /dev/sda -- mklabel gpt

# Create a boot partition
parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
parted /dev/sda -- set 1 boot on

# Create a swap partition
parted /dev/sda -- mkpart primary linux-swap 512MiB 4GiB

# Create a root partition
parted /dev/sda -- mkpart primary 4GiB 100%

# Format the partitions
mkfs.fat -F 32 -n boot /dev/sda1
mkswap -L swap /dev/sda2
mkfs.ext4 -L nixos /dev/sda3

# Mount the partitions
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
swapon /dev/disk/by-label/swap
```

5. Generate the initial NixOS configuration:

```bash
nixos-generate-config --root /mnt
```

6. Edit the configuration:

```bash
nano /mnt/etc/nixos/configuration.nix
```

Here's a basic NixOS configuration:

```nix
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Boot loader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.yourusername = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "changeme";
  };

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    firefox
    htop
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible. Change this only after NixOS release notes say you should.
  system.stateVersion = "23.05"; # Did you read the comment?
}
```

7. Install NixOS:

```bash
nixos-install
```

8. Set the root password when prompted.

9. Reboot into your new NixOS system:

```bash
reboot
```

#### Learning Nix Language Basics

1. Open a terminal in your NixOS system.

2. Create a directory for your Nix examples:

```bash
mkdir -p ~/nix-examples
cd ~/nix-examples
```

3. Create a simple Nix expression file:

```bash
nano simple.nix
```

Add the following content:

```nix
# Basic values
{
  aString = "Hello, NixOS!";
  anInteger = 42;
  aFloat = 3.14;
  aBoolean = true;
  aNull = null;
  
  # Lists
  aList = [ 1 2 3 4 5 ];
  aListOfMixed = [ 1 "two" true ];
  
  # Attribute sets (similar to dictionaries)
  anAttrSet = {
    name = "NixOS";
    version = "23.05";
    website = "https://nixos.org";
  };
  
  # Nested attribute sets
  nested = {
    a = {
      b = {
        c = "nested value";
      };
    };
  };
  
  # Functions
  increment = x: x + 1;
  greet = name: "Hello, ${name}!";
  
  # Function with multiple arguments (curried)
  add = a: b: a + b;
  
  # Function with attribute set argument
  makeUser = { name, email, ... }: {
    username = name;
    contactEmail = email;
    created = "2023-01-01";
  };
}
```

4. Evaluate the Nix expression using `nix-instantiate`:

```bash
nix-instantiate --eval simple.nix
```

5. Create a file to practice with strings and string interpolation:

```bash
nano strings.nix
```

Add the following content:

```nix
{
  simple = "A simple string";
  
  # String concatenation
  concat = "Hello, " + "NixOS!";
  
  # Multi-line string
  multiline = ''
    This is a multi-line
    string in Nix.
    It preserves line breaks.
  '';
  
  # String interpolation
  name = "NixOS";
  greeting = "Hello, ${name}!";
  
  # Escaping
  dollar = "The price is $10";  # No need to escape $ unless using ${}
  literal = ''
    This is a ${
      # We need to calculate this
      toString (5 + 5)
    } dollar product.
  '';
  
  # Path as string
  path = toString /etc/nixos;
  
  # String operations
  length = builtins.stringLength "Hello";
  substring = builtins.substring 0 5 "Hello, World!";
}
```

6. Create a file to practice with functions:

```bash
nano functions.nix
```

Add the following content:

```nix
let
  # Simple function
  double = x: x * 2;
  
  # Function with multiple arguments (curried)
  add = a: b: a + b;
  
  # Function using let-in
  addAndDouble = a: b:
    let
      sum = a + b;
    in
      double sum;
  
  # Function with attribute set destructuring
  makeFullName = { firstName, lastName, ... }: "${firstName} ${lastName}";
  
  # Function with default values
  greet = { name ? "Anonymous", greeting ? "Hello" }: "${greeting}, ${name}!";
  
  # Recursive function (factorial)
  factorial = n:
    if n == 0
    then 1
    else n * factorial (n - 1);
    
  # Anonymous function
  anonymousFunc = (x: x * x);
  
  # Higher-order function
  applyTwice = f: x: f (f x);
in
{
  doubleOfFive = double 5;
  sumOfNumbers = add 3 4;
  addAndDoubleResult = addAndDouble 3 4;
  fullName = makeFullName { firstName = "John"; lastName = "Doe"; };
  greeting1 = greet { name = "NixOS"; };
  greeting2 = greet { };  # Uses defaults
  factorialOfFive = factorial 5;
  squareOfFour = anonymousFunc 4;
  quadrupleOfThree = applyTwice double 3;
}
```

7. Create a file to practice with conditionals:

```bash
nano conditionals.nix
```

Add the following content:

```nix
let
  checkNumber = n:
    if n > 0 then "positive"
    else if n < 0 then "negative"
    else "zero";
  
  # Boolean operators
  hasAccess = user: permission:
    user.isAdmin || user.permissions ? ${permission};
  
  # With attribute set
  getEnvironmentVariables = environment:
    if environment == "development" then {
      DEBUG = true;
      API_URL = "http://localhost:3000";
    } else if environment == "production" then {
      DEBUG = false;
      API_URL = "https://api.example.com";
    } else {
      DEBUG = false;
      API_URL = "https://staging.example.com";
    };
in
{
  numCheck1 = checkNumber 5;
  numCheck2 = checkNumber (-3);
  numCheck3 = checkNumber 0;
  
  accessResult1 = hasAccess { isAdmin = true; permissions = {}; } "read";
  accessResult2 = hasAccess { isAdmin = false; permissions = { read = true; }; } "read";
  accessResult3 = hasAccess { isAdmin = false; permissions = { write = true; }; } "read";
  
  devEnv = getEnvironmentVariables "development";
  prodEnv = getEnvironmentVariables "production";
  stagingEnv = getEnvironmentVariables "staging";
}
```

8. Create a file to practice with builtins:

```bash
nano builtins.nix
```

Add the following content:

```nix
{
  # Type checking functions
  isStringCheck = builtins.isString "Hello";
  isIntCheck = builtins.isInt 42;
  
  # List operations
  listLength = builtins.length [1 2 3 4 5];
  elementAt = builtins.elemAt ["a" "b" "c"] 1; # Gets "b"
  
  # Attribute set operations
  hasAttr = builtins.hasAttr "name" { name = "value"; };
  getAttr = builtins.getAttr "name" { name = "value"; };
  attrNames = builtins.attrNames { a = 1; b = 2; c = 3; };
  
  # Converting between types
  toString = builtins.toString 42;
  toPath = builtins.toPath "/etc/nixos";
  
  # File operations
  fileExists = builtins.pathExists /etc/nixos/configuration.nix;
  fileContents = builtins.readFile ./simple.nix;
  
  # Importing files
  imported = import ./simple.nix;
  
  # JSON operations
  jsonFile = builtins.toJSON { name = "value"; list = [1 2 3]; };
  parsedJson = builtins.fromJSON ''{"name": "value", "list": [1, 2, 3]}'';
  
  # Debugging
  trace = builtins.trace "This is a debug message" "The result";
}
```

9. Evaluate each of these files to see the results:

```bash
nix-instantiate --eval strings.nix
nix-instantiate --eval functions.nix
nix-instantiate --eval conditionals.nix
nix-instantiate --eval builtins.nix
```

#### Creating a Basic NixOS Module

1. Create a directory for your custom modules:

```bash
sudo mkdir -p /etc/nixos/modules
```

2. Create a simple module for a development environment:

```bash
sudo nano /etc/nixos/modules/development.nix
```

Add the following content:

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myModules.development;
in {
  options.myModules.development = {
    enable = mkEnableOption "development environment";
    
    username = mkOption {
      type = types.str;
      description = "The username for the development environment";
    };
    
    languages = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Programming languages to install";
    };
    
    editors = mkOption {
      type = types.listOf types.str;
      default = ["vim"];
      description = "Text editors to install";
    };
  };
  
  config = mkIf cfg.enable {
    # Install development tools
    environment.systemPackages = with pkgs; [
      git
      gnumake
      gcc
      gdb
    ] 
    # Add language-specific packages
    ++ (if elem "python" cfg.languages then [ python3 python3Packages.pip ] else [])
    ++ (if elem "rust" cfg.languages then [ rustc cargo ] else [])
    ++ (if elem "go" cfg.languages then [ go ] else [])
    ++ (if elem "nodejs" cfg.languages then [ nodejs ] else [])
    # Add editors
    ++ (if elem "vim" cfg.editors then [ vim ] else [])
    ++ (if elem "emacs" cfg.editors then [ emacs ] else [])
    ++ (if elem "vscode" cfg.editors then [ vscode ] else []);
    
    # Create development directory
    system.activationScripts.createDevDir = ''
      mkdir -p /home/${cfg.username}/projects
      chown ${cfg.username}:users /home/${cfg.username}/projects
    '';
    
    # Configure Git globally
    programs.git = {
      enable = true;
      config = {
        init.defaultBranch = "main";
        core.editor = if elem "vim" cfg.editors then "vim" 
                      else if elem "emacs" cfg.editors then "emacs"
                      else "nano";
      };
    };
  };
}
```

3. Update your main configuration.nix to use the new module:

```bash
sudo nano /etc/nixos/configuration.nix
```

Add the module to your imports and enable it:

```nix
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Include your custom module
      ./modules/development.nix
    ];

  # Enable the development module
  myModules.development = {
    enable = true;
    username = "yourusername";  # Replace with your username
    languages = [ "python" "rust" "nodejs" ];
    editors = [ "vim" "vscode" ];
  };

  # Existing configuration follows...
}
```

4. Apply the new configuration:

```bash
sudo nixos-rebuild switch
```

5. Verify that your development environment is set up correctly:

```bash
# Check if git is installed
git --version

# Check if Python is installed
python3 --version

# Check if Rust is installed
rustc --version

# Check if your projects directory was create
# Network Configuration Guide

This guide covers the configuration and management of networking on Arch Linux and NixOS for professional software development environments. It focuses on both wired and wireless connections, VPNs, firewalls, and network troubleshooting.

## Table of Contents

1. [Basic Network Configuration](#basic-network-configuration)
   - [Wired Connections](#wired-connections)
   - [Wireless Connections](#wireless-connections)
2. [Network Manager Setup](#network-manager-setup)
3. [Static IP Configuration](#static-ip-configuration)
4. [DNS Configuration](#dns-configuration)
5. [Firewall Setup](#firewall-setup)
6. [VPN Configuration](#vpn-configuration)
7. [SSH Configuration](#ssh-configuration)
8. [Network Security](#network-security)
9. [Network Troubleshooting](#network-troubleshooting)

## Basic Network Configuration

### Wired Connections

#### Arch Linux

1. List network interfaces:
   ```bash
   ip link
   ```

2. Enable and start NetworkManager:
   ```bash
   sudo systemctl enable NetworkManager
   sudo systemctl start NetworkManager
   ```

3. Connect using NetworkManager:
   ```bash
   # List available connections
   nmcli connection show
   
   # Connect to wired network
   nmcli device connect eth0
   ```

#### NixOS

In configuration.nix:
```nix
{
  networking = {
    useDHCP = false;
    interfaces.enp0s3.useDHCP = true;  # Replace with your interface name
    
    # Alternatively, use static IP
    # interfaces.enp0s3.ipv4.addresses = [{
    #   address = "192.168.1.50";
    #   prefixLength = 24;
    # }];
  };
  
  # Enable NetworkManager
  networking.networkmanager.enable = true;
}
```

Apply the changes:
```bash
sudo nixos-rebuild switch
```

### Wireless Connections

#### Arch Linux

1. Ensure NetworkManager is running:
   ```bash
   sudo systemctl status NetworkManager
   ```

2. Connect to WiFi:
   ```bash
   # Scan for networks
   nmcli device wifi list
   
   # Connect to a network
   nmcli device wifi connect SSID password PASSWORD
   ```

3. Create a persistent connection:
   ```bash
   nmcli connection add type wifi con-name "MyWiFi" ifname wlan0 ssid SSID
   nmcli connection modify "MyWiFi" wifi-sec.key-mgmt wpa-psk wifi-sec.psk PASSWORD
   nmcli connection up "MyWiFi"
   ```

#### NixOS

In configuration.nix:
```nix
{
  networking = {
    wireless = {
      enable = true;  # Enables wireless support via wpa_supplicant
      networks = {
        "SSID" = {
          psk = "PASSWORD";
        };
      };
    };
    
    # Or alternatively, use NetworkManager
    networkmanager.enable = true;
  };
}
```

Apply the changes:
```bash
sudo nixos-rebuild switch
```

## Network Manager Setup

NetworkManager provides a unified interface for managing network connections.

### Arch Linux

1. Install NetworkManager:
   ```bash
   sudo pacman -S networkmanager network-manager-applet
   ```

2. Enable and start the service:
   ```bash
   sudo systemctl enable NetworkManager
   sudo systemctl start NetworkManager
   ```

3. Install a front-end (optional):
   ```bash
   # For GNOME
   sudo pacman -S network-manager-applet
   
   # For terminal use
   sudo pacman -S nmtui
   ```

### NixOS

In configuration.nix:
```nix
{
  networking.networkmanager = {
    enable = true;
    # Additional configurations
    wifi.backend = "iwd";  # Use iwd backend for better WiFi performance
  };
  
  # Add user to networkmanager group
  users.users.yourusername.extraGroups = [ "networkmanager" ];
  
  # Install front-ends
  environment.systemPackages = with pkgs; [
    networkmanagerapplet  # GUI applet
    networkmanager_dmenu  # dmenu integration
  ];
}
```

## Static IP Configuration

### Arch Linux

1. Using NetworkManager:
   ```bash
   nmcli connection modify "Connection Name" ipv4.method manual ipv4.addresses 192.168.1.50/24 ipv4.gateway 192.168.1.1 ipv4.dns "8.8.8.8,8.8.4.4"
   nmcli connection up "Connection Name"
   ```

2. Using systemd-networkd:
   
   Create a network file:
   ```bash
   sudo nano /etc/systemd/network/20-wired.network
   ```
   
   Add:
   ```
   [Match]
   Name=enp0s3
   
   [Network]
   Address=192.168.1.50/24
   Gateway=192.168.1.1
   DNS=8.8.8.8
   DNS=8.8.4.4
   ```
   
   Enable and start systemd-networkd:
   ```bash
   sudo systemctl enable systemd-networkd
   sudo systemctl start systemd-networkd
   ```

### NixOS

In configuration.nix:
```nix
{
  networking = {
    useDHCP = false;
    interfaces.enp0s3 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "192.168.1.50";
        prefixLength = 24;
      }];
    };
    defaultGateway = "192.168.1.1";
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
  };
}
```

## DNS Configuration

### Arch Linux

1. Using NetworkManager:
   ```bash
   nmcli connection modify "Connection Name" ipv4.dns "8.8.8.8,8.8.4.4"
   nmcli connection up "Connection Name"
   ```

2. Using systemd-resolved:
   
   Create/edit resolved.conf:
   ```bash
   sudo nano /etc/systemd/resolved.conf
   ```
   
   Add:
   ```
   [Resolve]
   DNS=8.8.8.8 8.8.4.4
   FallbackDNS=1.1.1.1 1.0.0.1
   ```
   
   Enable and start systemd-resolved:
   ```bash
   sudo systemctl enable systemd-resolved
   sudo systemctl start systemd-resolved
   ```

3. For local domain resolution (e.g., development environments):
   
   Edit /etc/hosts:
   ```bash
   sudo nano /etc/hosts
   ```
   
   Add:
   ```
   127.0.0.1    localhost
   127.0.0.1    myproject.local
   127.0.0.1    api.myproject.local
   ```

### NixOS

In configuration.nix:
```nix
{
  networking = {
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
    
    # Use systemd-resolved
    useHostResolvConf = false;
    
    # Local domains
    extraHosts = ''
      127.0.0.1 myproject.local
      127.0.0.1 api.myproject.local
    '';
  };
  
  services.resolved = {
    enable = true;
    fallbackDns = [ "1.1.1.1" "1.0.0.1" ];
  };
}
```

## Firewall Setup

### Arch Linux

#### Using ufw (Uncomplicated Firewall):

1. Install ufw:
   ```bash
   sudo pacman -S ufw
   ```

2. Configure basic rules:
   ```bash
   # Set default policies
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   
   # Allow SSH
   sudo ufw allow ssh
   
   # Allow specific ports
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   
   # Allow specific IPs
   sudo ufw allow from 192.168.1.0/24
   
   # Enable firewall
   sudo ufw enable
   
   # Check status
   sudo ufw status verbose
   ```

#### Using firewalld:

1. Install firewalld:
   ```bash
   sudo pacman -S firewalld
   ```

2. Enable and start the service:
   ```bash
   sudo systemctl enable firewalld
   sudo systemctl start firewalld
   ```

3. Configure rules:
   ```bash
   # Check current zone
   sudo firewall-cmd --get-active-zones
   
   # Allow services
   sudo firewall-cmd --permanent --add-service=http
   sudo firewall-cmd --permanent --add-service=https
   sudo firewall-cmd --permanent --add-service=ssh
   
   # Allow ports
   sudo firewall-cmd --permanent --add-port=8080/tcp
   
   # Reload to apply changes
   sudo firewall-cmd --reload
   ```

### NixOS

In configuration.nix:
```nix
{
  # Option 1: Simple iptables-based firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 8080 ];
    allowedUDPPorts = [ 53 ];
    allowPing = true;
    
    # For development, allow local network connections
    allowedTCPPortRanges = [
      { from = 1024; to = 65535; }
    ];
  };
  
  # Option 2: Use firewalld for more flexibility
  services.firewalld = {
    enable = true;
    zones = {
      public.allowedServices = [ "ssh" "http" "https" ];
      trusted = {
        interfaces = [ "docker0" ];
        allowedServices = [ "all" ];
      };
    };
  };
}
```

## VPN Configuration

### Arch Linux

#### OpenVPN Setup:

1. Install OpenVPN:
   ```bash
   sudo pacman -S openvpn networkmanager-openvpn
   ```

2. Import .ovpn configuration:
   ```bash
   # Using NetworkManager
   nmcli connection import type openvpn file path/to/config.ovpn
   
   # Or manual setup
   sudo cp path/to/config.ovpn /etc/openvpn/client/
   sudo systemctl enable openvpn-client@config
   sudo systemctl start openvpn-client@config
   ```

#### WireGuard Setup:

1. Install WireGuard:
   ```bash
   sudo pacman -S wireguard-tools networkmanager-wireguard
   ```

2. Create a configuration file:
   ```bash
   sudo nano /etc/wireguard/wg0.conf
   ```
   
   Add:
   ```
   [Interface]
   PrivateKey = your_private_key
   Address = 10.0.0.2/24
   
   [Peer]
   PublicKey = server_public_key
   AllowedIPs = 0.0.0.0/0
   Endpoint = server:51820
   ```

3. Start WireGuard:
   ```bash
   sudo systemctl enable wg-quick@wg0
   sudo systemctl start wg-quick@wg0
   ```

### NixOS

In configuration.nix for OpenVPN:
```nix
{
  services.openvpn.servers = {
    myVPN = {
      config = ''
        config /root/my-vpn-config.ovpn
      '';
      autoStart = false;
    };
  };
}
```

For WireGuard:
```nix
{
  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.0.0.2/24" ];
      privateKey = "YOUR_PRIVATE_KEY";
      peers = [
        {
          publicKey = "SERVER_PUBLIC_KEY";
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "server:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
```

## SSH Configuration

### Secure SSH Server Setup

#### Arch Linux:

1. Install and enable SSH:
   ```bash
   sudo pacman -S openssh
   sudo systemctl enable sshd
   sudo systemctl start sshd
   ```

2. Secure the configuration:
   ```bash
   sudo nano /etc/ssh/sshd_config
   ```
   
   Recommend settings:
   ```
   # Use protocol 2 only
   Protocol 2
   
   # Disable root login
   PermitRootLogin no
   
   # Disable password authentication
   PasswordAuthentication no
   
   # Use key authentication only
   PubkeyAuthentication yes
   
   # Limit user access
   AllowUsers yourusername
   
   # Set idle timeout (5 minutes)
   ClientAliveInterval 300
   ClientAliveCountMax 0
   ```

3. Restart SSH service:
   ```bash
   sudo systemctl restart sshd
   ```

#### NixOS:

In configuration.nix:
```nix
{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
    allowedUsers = [ "yourusername" ];
  };
}
```

### SSH Client Configuration

Create/edit ~/.ssh/config:
```
# Default settings
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    IdentitiesOnly yes
    AddKeysToAgent yes

# Custom host configuration
Host github.com
    User git
    IdentityFile ~/.ssh/github_key
    
Host dev-server
    HostName 192.168.1.100
    User yourusername
    Port 22
    IdentityFile ~/.ssh/dev_server_key
    ForwardAgent yes
```

## Network Security

### SSH Key Management

1. Generate a new key:
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```

2. Add to SSH agent:
   ```bash
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_ed25519
   ```

3. Copy to remote server:
   ```bash
   ssh-copy-id -i ~/.ssh/id_ed25519.pub user@host
   ```

### Network Monitoring

Install and use tcpdump for network analysis:
```bash
# Arch Linux
sudo pacman -S tcpdump

# Monitor specific interface
sudo tcpdump -i eth0 -n

# Monitor specific host
sudo tcpdump -i any host 192.168.1.1

# Monitor specific port
sudo tcpdump -i any port 80
```

## Network Troubleshooting

### Common Issues and Solutions

#### Connection Drop Issues

1. Check physical connections
2. Check interface status:
   ```bash
   ip link show
   ```
3. Check network manager status:
   ```bash
   systemctl status NetworkManager
   ```
4. Restart network interface:
   ```bash
   sudo ip link set eth0 down
   sudo ip link set eth0 up
   ```

#### DNS Resolution Issues

1. Test DNS resolution:
   ```bash
   nslookup example.com
   dig example.com
   ```
2. Check current DNS servers:
   ```bash
   cat /etc/resolv.conf
   ```
3. Try alternative DNS servers:
   ```bash
   # Temporary change
   echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf
   ```

#### Network Performance Issues

1. Check bandwidth usage:
   ```bash
   sudo pacman -S iftop
   sudo iftop -i eth0
   ```
2. Run MTR to check for packet loss:
   ```bash
   sudo pacman -S mtr
   sudo mtr example.com
   ```
3. Check for hardware issues:
   ```bash
   ethtool eth0
   ```

### Diagnostic Commands

| Command | Purpose |
|---------|---------|
| `ping host` | Test basic connectivity |
| `ip addr` | Display IP addresses |
| `ip route` | Display routing table |
| `ss -tuln` | List open ports |
| `dig domain` | Query DNS |
| `traceroute host` | Trace packet route |
| `nmap localhost` | Scan for open ports |
| `netstat -tuln` | Show listening ports |
| `iwconfig` | Show wireless info |
| `tcpdump -i eth0` | Capture packets |

## Acknowledgements

This network configuration guide was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Documentation organization
- Configuration examples
- Troubleshooting methodology

Claude was used as a development aid while all final implementation decisions and verification were performed by Joshua Michael Hall.

## Disclaimer

This guide is provided "as is", without warranty of any kind. Always back up important data before making system changes.

# Month 8: Networking and Security Fundamentals

This month focuses on networking concepts, security hardening, and creating secure connections on Linux. You'll learn to configure network interfaces, set up firewalls, establish secure tunnels, and protect your system from various threats.

## Time Commitment: ~10 hours/week for 4 weeks

## Learning Objectives

By the end of this month, you should be able to:

1. Configure and manage network interfaces and connections
2. Implement and manage firewalls with different tools
3. Set up secure remote access with SSH and VPNs
4. Understand and apply basic system hardening techniques
5. Monitor network traffic and detect security issues
6. Implement network services securely

## Week 1: Advanced Networking Configuration

### Core Learning Activities

1. **Network Fundamentals Review** (2 hours)
   - Refresh understanding of IP addressing and subnetting
     ```bash
     # View current network configuration
     ip addr show
     
     # Display routing table
     ip route show
     
     # Show network statistics
     ss -tuln
     ```
   - Review TCP/IP protocol stack layers:
     - Physical layer
     - Data link layer (Ethernet)
     - Network layer (IP)
     - Transport layer (TCP/UDP)
     - Application layer (HTTP, DNS, etc.)
   - Understand network interfaces and routing:
     ```bash
     # Configure interface (temporary)
     sudo ip addr add 192.168.1.100/24 dev eth0
     
     # Add static route
     sudo ip route add 10.0.0.0/24 via 192.168.1.1
     ```
   - Study DNS resolution process:
     ```bash
     # Test DNS resolution
     dig example.com
     
     # Trace DNS resolution
     dig +trace example.com
     
     # View local DNS configuration
     cat /etc/resolv.conf
     ```

2. **Network Configuration Tools** (3 hours)
   - Master ip command for interface management:
     ```bash
     # Bring interface up/down
     sudo ip link set eth0 up
     sudo ip link set eth0 down
     
     # Configure IP address
     sudo ip addr add 192.168.1.100/24 dev eth0
     
     # Delete IP address
     sudo ip addr del 192.168.1.100/24 dev eth0
     
     # Show statistics for interface
     ip -s link show dev eth0
     ```
   - Configure NetworkManager through CLI and GUI:
     ```bash
     # List connections
     nmcli connection show
     
     # Connect to WiFi
     nmcli device wifi connect SSID password PASSWORD
     
     # Create a connection profile
     nmcli connection add type ethernet con-name "work" ifname eth0
     
     # Modify connection properties
     nmcli connection modify work ipv4.addresses 192.168.1.100/24
     nmcli connection modify work ipv4.gateway 192.168.1.1
     nmcli connection modify work ipv4.dns "8.8.8.8,8.8.4.4"
     
     # Apply changes
     nmcli connection up work
     ```
   - Understand systemd-networkd as an alternative:
     ```bash
     # Create network configuration
     sudo nano /etc/systemd/network/20-wired.network
     
     # Configuration content
     [Match]
     Name=eth0
     
     [Network]
     Address=192.168.1.100/24
     Gateway=192.168.1.1
     DNS=8.8.8.8
     DNS=8.8.4.4
     
     # Enable systemd-networkd
     sudo systemctl enable systemd-networkd
     sudo systemctl start systemd-networkd
     ```
   - Explore wpa_supplicant for wireless connections:
     ```bash
     # Create wpa_supplicant configuration
     sudo nano /etc/wpa_supplicant/wpa_supplicant.conf
     
     # Configuration content
     ctrl_interface=/run/wpa_supplicant
     update_config=1
     
     network={
         ssid="YourNetwork"
         psk="YourPassword"
     }
     
     # Connect using wpa_supplicant
     sudo wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf
     
     # Get IP address
     sudo dhclient wlan0
     ```

3. **Routing and Network Namespaces** (3 hours)
   - Configure static routes:
     ```bash
     # Add temporary route
     sudo ip route add 10.0.0.0/24 via 192.168.1.1
     
     # Add permanent route (Arch Linux)
     sudo nano /etc/systemd/network/20-wired.network
     
     # Add to the [Network] section
     [Route]
     Destination=10.0.0.0/24
     Gateway=192.168.1.1
     ```
   - Understand and use network namespaces:
     ```bash
     # Create network namespace
     sudo ip netns add netspace1
     
     # List namespaces
     ip netns list
     
     # Execute command in namespace
     sudo ip netns exec netspace1 ip link list
     
     # Create veth pair
     sudo ip link add veth0 type veth peer name veth1
     
     # Move veth1 to namespace
     sudo ip link set veth1 netns netspace1
     
     # Configure interfaces
     sudo ip addr add 192.168.100.1/24 dev veth0
     sudo ip link set veth0 up
     sudo ip netns exec netspace1 ip addr add 192.168.100.2/24 dev veth1
     sudo ip netns exec netspace1 ip link set veth1 up
     
     # Test connectivity
     sudo ip netns exec netspace1 ping 192.168.100.1
     ```
   - Set up policy-based routing:
     ```bash
     # Create routing table
     echo "200 custom" | sudo tee -a /etc/iproute2/rt_tables
     
     # Add route to table
     sudo ip route add default via 192.168.2.1 table custom
     
     # Add routing policy
     sudo ip rule add from 192.168.2.0/24 table custom
     ```
   - Learn about routing protocols:
     ```bash
     # Install FRR (Free Range Routing)
     sudo pacman -S frr
     
     # Enable and configure services (e.g., for OSPF)
     sudo systemctl enable frr
     sudo vtysh
     ```

4. **Network Diagnostics** (2 hours)
   - Use ping, traceroute, and mtr effectively:
     ```bash
     # Basic connectivity test
     ping -c 4 example.com
     
     # Trace route to host
     traceroute example.com
     
     # Combined traceroute and ping
     mtr example.com
     
     # Ping with specific parameters
     ping -c 4 -i 0.2 -s 1500 example.com
     ```
   - Master netstat and ss for connection monitoring:
     ```bash
     # List all connections
     ss -a
     
     # List listening TCP ports
     ss -tln
     
     # Show connections with processes
     ss -tplno
     
     # Show connection statistics
     ss -s
     
     # Filter by port
     ss -t dst :443
     ```
   - Deploy tcpdump for packet capture and analysis:
     ```bash
     # Basic packet capture
     sudo tcpdump -i eth0
     
     # Capture with filters
     sudo tcpdump -i eth0 host 192.168.1.1
     sudo tcpdump -i eth0 port 80
     sudo tcpdump -i eth0 'tcp port 80 and host 192.168.1.1'
     
     # Capture with detailed output and timestamps
     sudo tcpdump -i eth0 -ttttnnvvS
     
     # Capture to file for later analysis
     sudo tcpdump -i eth0 -w capture.pcap
     ```
   - Implement network testing and benchmarking tools:
     ```bash
     # Install iperf
     sudo pacman -S iperf
     
     # Run iperf server
     iperf -s
     
     # Run iperf client
     iperf -c server_ip
     
     # Test with multiple streams
     iperf -c server_ip -P 4
     
     # Test UDP performance
     iperf -c server_ip -u -b 100M
     ```

### Resources

- [ArchWiki - Network Configuration](https://wiki.archlinux.org/title/Network_configuration)
- [Linux Network Administration Guide](https://tldp.org/LDP/nag2/index.html)
- [NetworkManager Documentation](https://networkmanager.dev/docs/)
- [Arch Linux Network Debugging](https://wiki.archlinux.org/title/Network_debugging)

## Week 2: Firewall Configuration and Management

### Core Learning Activities

1. **Firewall Concepts** (2 hours)
   - Understand iptables, nftables, and firewalld:
     - iptables: Traditional Linux packet filtering
     - nftables: Modern replacement for iptables
     - firewalld: High-level management tool for nftables/iptables
   - Learn about stateful vs. stateless firewalls:
     - Stateful: Tracks connection state (most Linux firewalls)
     - Stateless: Evaluates each packet independently
   - Study zones and trust levels:
     - Public, trusted, home, work, etc.
     - Different rules for different network environments
   - Understand packet flow and filtering:
     - Input, output, and forward chains
     - Prerouting and postrouting for NAT
     - Connection tracking
     - Rule evaluation order

2. **Firewalld Configuration** (3 hours)
   - Install and configure firewalld:
     ```bash
     # Install firewalld
     sudo pacman -S firewalld
     
     # Enable and start service
     sudo systemctl enable firewalld
     sudo systemctl start firewalld
     ```
   - Manage zones and services:
     ```bash
     # List available zones
     sudo firewall-cmd --get-zones
     
     # Get active zones
     sudo firewall-cmd --get-active-zones
     
     # List available services
     sudo firewall-cmd --get-services
     
     # Add service to zone
     sudo firewall-cmd --zone=public --add-service=http
     
     # Add service permanently
     sudo firewall-cmd --zone=public --add-service=https --permanent
     
     # Reload firewall
     sudo firewall-cmd --reload
     ```
   - Configure port forwarding:
     ```bash
     # Forward external port 8080 to internal port 80
     sudo firewall-cmd --zone=public --add-forward-port=port=8080:proto=tcp:toport=80 --permanent
     
     # Forward to different host
     sudo firewall-cmd --zone=public --add-forward-port=port=8080:proto=tcp:toport=80:toaddr=192.168.1.2 --permanent
     
     # Allow masquerading (for forwarding to another host)
     sudo firewall-cmd --zone=public --add-masquerade --permanent
     ```
   - Set up rich rules:
     ```bash
     # Allow SSH from specific IP
     sudo firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" service name="ssh" accept' --permanent
     
     # Rate limit connections
     sudo firewall-cmd --zone=public --add-rich-rule='rule service name="http" limit value="10/m" accept' --permanent
     
     # Log and reject traffic
     sudo firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address="10.0.0.1" log prefix="BLOCKED: " level="warning" limit value="3/m" reject' --permanent
     ```
   - Implement logging:
     ```bash
     # Log all dropped packets
     sudo firewall-cmd --set-log-denied=all
     
     # Log all new connections
     sudo firewall-cmd --add-rich-rule='rule family="ipv4" log prefix="FIREWALL: " level="info"' --permanent
     
     # View logs
     sudo journalctl -t kernel | grep FIREWALL
     ```

3. **Direct iptables/nftables Management** (3 hours)
   - Learn basic iptables syntax and chains:
     ```bash
     # List rules
     sudo iptables -L -v
     
     # Basic allow rule
     sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
     
     # Basic deny rule
     sudo iptables -A INPUT -p tcp --dport 23 -j DROP
     
     # Allow established connections
     sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
     
     # Set default policy
     sudo iptables -P INPUT DROP
     ```
   - Understand nftables as a modern replacement:
     ```bash
     # Install nftables
     sudo pacman -S nftables
     
     # Basic nftables configuration
     sudo nano /etc/nftables.conf
     
     # Example configuration
     #!/usr/sbin/nft -f
     
     flush ruleset
     
     table inet filter {
       chain input {
         type filter hook input priority 0; policy drop;
         
         # Accept loopback traffic
         iif lo accept
         
         # Accept established connections
         ct state established,related accept
         
         # Accept SSH
         tcp dport 22 accept
         
         # Drop invalid connections
         ct state invalid drop
       }
       
       chain forward {
         type filter hook forward priority 0; policy drop;
       }
       
       chain output {
         type filter hook output priority 0; policy accept;
       }
     }
     
     # Enable and start nftables
     sudo systemctl enable nftables
     sudo systemctl start nftables
     ```
   - Create persistent rules:
     ```bash
     # Save current rules to config
     sudo nft list ruleset > /etc/nftables.conf
     
     # Load rules from config
     sudo nft -f /etc/nftables.conf
     ```
   - Implement custom chains:
     ```bash
     # Create custom chain
     sudo nft add chain inet filter web { type filter hook input priority 0 \; }
     
     # Add rules to custom chain
     sudo nft add rule inet filter web tcp dport 80 accept
     sudo nft add rule inet filter web tcp dport 443 accept
     
     # Jump to custom chain from input chain
     sudo nft add rule inet filter input jump web
     ```
   - Configure logging and rate limiting:
     ```bash
     # Log dropped packets
     sudo nft add rule inet filter input counter log prefix \"Dropped: \" drop
     
     # Rate limiting
     sudo nft add rule inet filter input tcp dport 22 limit rate 3/minute accept
     ```

4. **Application Layer Firewalls** (2 hours)
   - Understand application firewalls vs. network firewalls:
     - Network firewalls: Filter by IP, port, protocol
     - Application firewalls: Filter by application behavior
   - Configure fail2ban for brute force protection:
     ```bash
     # Install fail2ban
     sudo pacman -S fail2ban
     
     # Create jail configuration
     sudo nano /etc/fail2ban/jail.local
     
     # Example configuration
     [DEFAULT]
     bantime = 1h
     findtime = 10m
     maxretry = 5
     
     [sshd]
     enabled = true
     port = ssh
     filter = sshd
     logpath = /var/log/auth.log
     
     # Enable and start service
     sudo systemctl enable fail2ban
     sudo systemctl start fail2ban
     
     # Check status
     sudo fail2ban-client status
     ```
   - Implement ModSecurity for web applications:
     ```bash
     # Install ModSecurity for Nginx
     sudo pacman -S nginx-mod-modsecurity
     
     # Configure ModSecurity
     sudo nano /etc/nginx/modsec/main.conf
     
     # Enable ModSecurity in Nginx
     sudo nano /etc/nginx/nginx.conf
     
     # Add to server block
     modsecurity on;
     modsecurity_rules_file /etc/nginx/modsec/main.conf;
     ```
   - Learn about intrusion detection systems:
     ```bash
     # Install OSSEC
     git clone https://github.com/ossec/ossec-hids.git
     cd ossec-hids
     sudo ./install.sh
     
     # Install Suricata
     sudo pacman -S suricata
     
     # Configure Suricata
     sudo nano /etc/suricata/suricata.yaml
     
     # Enable and start service
     sudo systemctl enable suricata
     sudo systemctl start suricata
     ```

### Resources

- [ArchWiki - Firewalld](https://wiki.archlinux.org/title/Firewalld)
- [ArchWiki - Nftables](https://wiki.archlinux.org/title/Nftables)
- [Firewalld Documentation](https://firewalld.org/documentation/)
- [Fail2ban Documentation](https://www.fail2ban.org/wiki/index.php/Main_Page)

## Week 3: SSH, VPNs, and Secure Connections

### Core Learning Activities

1. **Advanced SSH Configuration** (3 hours)
   - Secure SSH server configuration:
     ```bash
     # Edit SSH server config
     sudo nano /etc/ssh/sshd_config
     
     # Recommended settings
     Port 22                   # Consider changing to non-standard port
     PermitRootLogin no        # Disable root login
     PasswordAuthentication no # Use key authentication only
     PubkeyAuthentication yes  # Enable key-based authentication
     X11Forwarding no          # Disable X11 forwarding
     MaxAuthTries 3            # Limit authentication attempts
     LoginGraceTime 30         # Reduce login grace time
     
     # Restart SSH service
     sudo systemctl restart sshd
     ```
   - Set up SSH key authentication:
     ```bash
     # Generate key pair
     ssh-keygen -t ed25519 -C "your_email@example.com"
     
     # Copy public key to server
     ssh-copy-id user@hostname
     
     # Alternatively, manually add key
     cat ~/.ssh/id_ed25519.pub | ssh user@hostname "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
     
     # Set proper permissions
     ssh user@hostname "chmod 700 ~/.ssh; chmod 600 ~/.ssh/authorized_keys"
     ```
   - Configure SSH client for multiple hosts:
     ```bash
     # Edit SSH client config
     nano ~/.ssh/config
     
     # Example configuration
     Host myserver
       HostName server.example.com
       User myusername
       Port 22
       IdentityFile ~/.ssh/id_ed25519
       
     Host github
       HostName github.com
       User git
       IdentityFile ~/.ssh/github_key
       
     Host *
       ServerAliveInterval 60
       ServerAliveCountMax 3
       ControlMaster auto
       ControlPath ~/.ssh/control/%r@%h:%p
       ControlPersist 1h
     ```
   - Implement SSH agents and forwarding:
     ```bash
     # Start SSH agent
     eval "$(ssh-agent -s)"
     
     # Add key to agent
     ssh-add ~/.ssh/id_ed25519
     
     # Use agent forwarding
     ssh -A user@hostname
     
     # Configure in SSH config
     Host myserver
       ForwardAgent yes
     ```
   - Use SSH config for efficiency:
     ```bash
     # Configure multiplexing for faster connections
     Host myserver
       ControlMaster auto
       ControlPath ~/.ssh/control/%r@%h:%p
       ControlPersist 1h
       
     # Configure connection sharing
     # Connect once
     ssh myserver
     # Subsequent connections will be faster
     ```

2. **SSH Tunneling and Port Forwarding** (2 hours)
   - Set up local and remote port forwarding:
     ```bash
     # Local port forwarding (access remote service locally)
     ssh -L 8080:localhost:80 user@remote-server
     # Access remote server's port 80 at localhost:8080
     
     # Remote port forwarding (expose local service remotely)
     ssh -R 8080:localhost:3000 user@remote-server
     # Access local port 3000 at remote-server:8080
     
     # Multiple port forwards
     ssh -L 8080:localhost:80 -L 5432:localhost:5432 user@remote-server
     ```
   - Implement dynamic (SOCKS) proxying:
     ```bash
     # Create SOCKS proxy
     ssh -D 1080 user@remote-server
     
     # Configure browser to use proxy
     # Settings > Network > Settings > Manual proxy configuration
     # SOCKS Host: 127.0.0.1, Port: 1080
     
     # Configure applications to use proxy
     export all_proxy=socks5://localhost:1080
     ```
   - Create jump hosts for multi-hop connections:
     ```bash
     # Connect through jump host
     ssh -J jumpuser@jumphost user@destination
     
     # Configure in SSH config
     Host destination
       HostName destination.example.com
       User user
       ProxyJump jumpuser@jumphost
       
     # Multi-hop jump
     ssh -J user1@host1,user2@host2 user3@host3
     ```
   - Use SSH tunnels for secure services:
     ```bash
     # Secure access to a remote MySQL server
     ssh -L 3306:localhost:3306 user@dbserver
     
     # Secure X11 forwarding
     ssh -X user@server
     
     # VNC over SSH
     ssh -L 5901:localhost:5901 user@server
     # Then connect VNC client to localhost:5901
     ```

3. **VPN Setup with WireGuard** (3 hours)
   - Install and configure WireGuard:
     ```bash
     # Install WireGuard
     sudo pacman -S wireguard-tools
     
     # Generate keys
     wg genkey | tee privatekey | wg pubkey > publickey
     
     # Server configuration
     sudo nano /etc/wireguard/wg0.conf
     
     # Server config content
     [Interface]
     PrivateKey = SERVER_PRIVATE_KEY
     Address = 10.0.0.1/24
     ListenPort = 51820
     
     # Allow forwarding
     PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
     PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
     
     [Peer]
     PublicKey = CLIENT_PUBLIC_KEY
     AllowedIPs = 10.0.0.2/32
     ```
   - Generate keys and set up peers:
     ```bash
     # Client configuration
     sudo nano /etc/wireguard/wg0.conf
     
     # Client config content
     [Interface]
     PrivateKey = CLIENT_PRIVATE_KEY
     Address = 10.0.0.2/24
     DNS = 1.1.1.1, 1.0.0.1
     
     [Peer]
     PublicKey = SERVER_PUBLIC_KEY
     Endpoint = server.example.com:51820
     AllowedIPs = 0.0.0.0/0, ::/0
     PersistentKeepalive = 25
     ```
   - Configure routing for VPN traffic:
     ```bash
     # Enable IP forwarding
     sudo nano /etc/sysctl.d/99-sysctl.conf
     
     # Add line
     net.ipv4.ip_forward=1
     
     # Apply changes
     sudo sysctl -p /etc/sysctl.d/99-sysctl.conf
     
     # Start WireGuard interface
     sudo wg-quick up wg0
     
     # Enable on boot
     sudo systemctl enable wg-quick@wg0
     ```
   - Implement split tunneling:
     ```bash
     # Modify client configuration
     # Change AllowedIPs to only route specific traffic
     
     # For specific subnets only
     AllowedIPs = 10.0.0.0/24, 192.168.1.0/24
     
     # For specific domains (using DNS routing)
     # Requires additional client-side DNS configuration
     ```
   - Test and troubleshoot connections:
     ```bash
     # Check interface status
     sudo wg show
     
     # Test connection
     ping 10.0.0.1
     
     # Troubleshoot routing
     ip route
     
     # Check logs
     journalctl -xeu wg-quick@wg0
     ```

4. **OpenVPN Configuration** (2 hours)
   - Install and configure OpenVPN:
     ```bash
     # Install OpenVPN
     sudo pacman -S openvpn easy-rsa
     
     # Set up Certificate Authority
     mkdir -p ~/openvpn-ca
     cp -r /usr/share/easy-rsa/* ~/openvpn-ca/
     cd ~/openvpn-ca
     
     # Edit vars
     nano vars
     
     # Initialize PKI
     ./easyrsa init-pki
     ./easyrsa build-ca
     
     # Generate server certificate
     ./easyrsa build-server-full server nopass
     
     # Generate client certificate
     ./easyrsa build-client-full client1 nopass
     ```
   - Understand certificate-based authentication:
     ```bash
     # Create server configuration
     sudo nano /etc/openvpn/server/server.conf
     
     # Basic config
     port 1194
     proto udp
     dev tun
     ca ca.crt
     cert server.crt
     key server.key
     dh dh.pem
     server 10.8.0.0 255.255.255.0
     push "redirect-gateway def1 bypass-dhcp"
     push "dhcp-option DNS 208.67.222.222"
     push "dhcp-option DNS 208.67.220.220"
     keepalive 10 120
     comp-lzo
     user nobody
     group nobody
     persist-key
     persist-tun
     status openvpn-status.log
     verb 3
     ```
   - Configure client connections:
     ```bash
     # Create client configuration
     nano client.ovpn
     
     # Basic client config
     client
     dev tun
     proto udp
     remote server.example.com 1194
     resolv-retry infinite
     nobind
     user nobody
     group nobody
     persist-key
     persist-tun
     remote-cert-tls server
     comp-lzo
     verb 3
     
     # Add certificates inline
     <ca>
     # Insert ca.crt content here
     </ca>
     <cert>
     # Insert client1.crt content here
     </cert>
     <key>
     # Insert client1.key content here
     </key>
     ```
   - Implement network configuration:
     ```bash
     # Enable IP forwarding
     echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
     
     # Configure NAT
     sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
     
     # Start OpenVPN server
     sudo systemctl enable openvpn-server@server
     sudo systemctl start openvpn-server@server
     ```
   - Compare with WireGuard:
     - WireGuard: Simpler, faster, modern crypto
     - OpenVPN: More established, more features, works on more platforms
     - Both provide secure VPN functionality

### Resources

- [ArchWiki - SSH](https://wiki.archlinux.org/title/SSH)
- [ArchWiki - WireGuard](https://wiki.archlinux.org/title/WireGuard)
- [ArchWiki - OpenVPN](https://wiki.archlinux.org/title/OpenVPN)
- [WireGuard Quick Start](https://www.wireguard.com/quickstart/)
- [OpenSSH Documentation](https://www.openssh.com/manual.html)

## Week 4: System Hardening and Security Monitoring

### Core Learning Activities

1. **Basic System Hardening** (3 hours)
   - Implement the principle of least privilege:
     ```bash
     # Review sudo permissions
     sudo visudo
     
     # Configure specific permissions
     username ALL=(ALL) /usr/bin/pacman -Syu, /bin/systemctl restart apache
     
     # Configure group permissions
     %admin ALL=(ALL) ALL
     ```
   - Configure secure boot options:
     ```bash
     # Edit bootloader configuration
     sudo nano /etc/default/grub
     
     # Add kernel parameters for security
     GRUB_CMDLINE_LINUX_DEFAULT="quiet apparmor=1 security=apparmor"
     
     # Update grub
     sudo grub-mkconfig -o /boot/grub/grub.cfg
     ```
   - Set up disk encryption:
     ```bash
     # For new installations, use LUKS during install
     
     # For encrypting non-root partitions
     sudo cryptsetup luksFormat --type luks2 /dev/sdXY
     sudo cryptsetup open /dev/sdXY encrypted_volume
     sudo mkfs.ext4 /dev/mapper/encrypted_volume
     
     # Add to /etc/crypttab
     encrypted_volume UUID=device-UUID none
     
     # Add to /etc/fstab
     /dev/mapper/encrypted_volume /mnt/secure ext4 defaults 0 2
     ```
   - Secure user accounts and authentication:
     ```bash
     # Set strong password policies
     sudo nano /etc/security/pwquality.conf
     
     # Configure settings
     minlen = 12
     minclass = 4
     maxrepeat = 2
     
     # Configure account lockout
     sudo nano /etc/pam.d/system-auth
     
     # Add line
     auth required pam_faillock.so preauth silent deny=5 unlock_time=1800
     ```
   - Implement process isolation:
     ```bash
     # Install and configure AppArmor
     sudo pacman -S apparmor
     
     # Enable in bootloader and kernel parameters
     # (see secure boot options above)
     
     # Enable AppArmor
     sudo systemctl enable apparmor
     sudo systemctl start apparmor
     
     # Check status
     sudo aa-status
     ```

2. **Security Monitoring** (2 hours)
   - Configure log auditing for security events:
     ```bash
     # Install audit
     sudo pacman -S audit
     
     # Configure audit rules
     sudo nano /etc/audit/rules.d/audit.rules
     
     # Example rules
     # Monitor changes to authentication configuration
     -w /etc/pam.d/ -p wa -k auth_changes
     
     # Monitor changes to system users
     -w /etc/passwd -p wa -k user_changes
     -w /etc/shadow -p wa -k user_changes
     
     # Monitor sudo usage
     -w /etc/sudoers -p wa -k sudo_changes
     -a exit,always -F arch=b64 -S execve -F euid=0 -F auid>=1000 -F auid!=4294967295 -k sudo_commands
     
     # Enable and start service
     sudo systemctl enable auditd
     sudo systemctl start auditd
     ```
   - Set up auditd for system call monitoring:
     ```bash
     # Check audit logs
     sudo ausearch -k sudo_commands
     
     # Generate audit reports
     sudo aureport --auth
     sudo aureport --login
     sudo aureport --summary
     ```
   - Implement intrusion detection with AIDE:
     ```bash
     # Install AIDE
     sudo pacman -S aide
     
     # Configure AIDE
     sudo nano /etc/aide.conf
     
     # Initialize database
     sudo aide --init
     
     # Move initial database to active
     sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
     
     # Check for changes
     sudo aide --check
     ```
   - Learn about system integrity verification:
     ```bash
     # Verify installed packages
     sudo pacman -Qk
     
     # Check file permissions
     sudo find /etc -type f -exec stat -c "%a %n" {} \; | sort -n
     
     # Verify all installed packages
     sudo pacman -Qkk
     ```

3. **Network Monitoring and Analysis** (3 hours)
   - Set up network traffic monitoring:
     ```bash
     # Install tools
     sudo pacman -S iftop nethogs ethtool
     
     # Monitor bandwidth usage by interface
     sudo iftop -i eth0
     
     # Monitor bandwidth usage by process
     sudo nethogs eth0
     
     # Monitor all traffic
     sudo tcpdump -i eth0
     ```
   - Use Wireshark/tshark for packet analysis:
     ```bash
     # Install Wireshark
     sudo pacman -S wireshark-qt
     
     # Add user to wireshark group
     sudo usermod -a -G wireshark $(whoami)
     
     # Capture with tshark (CLI version)
     sudo tshark -i eth0 -w capture.pcap
     
     # Filter traffic
     sudo tshark -i eth0 -f "port 80 or port 443"
     
     # Analyze captures
     sudo tshark -r capture.pcap -T fields -e ip.src -e ip.dst -e tcp.port
     ```
   - Implement bandwidth monitoring:
     ```bash
     # Install bandwidth monitoring tools
     sudo pacman -S vnstat
     
     # Initialize monitoring
     sudo vnstat -u -i eth0
     
     # Enable and start service
     sudo systemctl enable vnstat
     sudo systemctl start vnstat
     
     # View statistics
     vnstat -h  # hourly
     vnstat -d  # daily
     vnstat -m  # monthly
     ```
   - Configure alerts for suspicious activity:
     ```bash
     # Install psad for port scan detection
     sudo pacman -S psad
     
     # Configure psad
     sudo nano /etc/psad/psad.conf
     
     # Set email for alerts
     EMAIL_ADDRESSES youremail@example.com;
     
     # Enable and start service
     sudo systemctl enable psad
     sudo systemctl start psad
     ```

4. **Security Scanning and Testing** (2 hours)
   - Use nmap for network scanning:
     ```bash
     # Install nmap
     sudo pacman -S nmap
     
     # Basic scan
     nmap 192.168.1.0/24
     
     # Detailed scan
     sudo nmap -sS -sV -O -A -p- 192.168.1.1
     
     # Vulnerability scanning
     sudo nmap --script vuln 192.168.1.1
     ```
   - Conduct security audits with Lynis:
     ```bash
     # Install Lynis
     sudo pacman -S lynis
     
     # Run security audit
     sudo lynis audit system
     
     # View full report
     sudo lynis --report-file /tmp/lynis-report.dat
     ```
   - Check for vulnerabilities with OpenVAS:
     ```bash
     # Install OpenVAS (from AUR)
     yay -S openvas
     
     # Setup OpenVAS
     sudo gvm-setup
     
     # Start OpenVAS services
     sudo gvm-start
     
     # Access web interface at https://localhost:9392
     ```
   - Implement regular security checks:
     ```bash
     # Create security check script
     nano ~/security-check.sh
     
     #!/bin/bash
     echo "Running security checks at $(date)"
     echo "Checking for failed login attempts..."
     grep "Failed password" /var/log/auth.log
     
     echo "Checking for suspicious processes..."
     ps aux | grep -v grep | grep -E "nc|netcat|nmap"
     
     echo "Checking open ports..."
     ss -tulpn
     
     echo "Checking for modified system files..."
     sudo aide --check
     
     echo "Security check completed."
     
     # Make script executable
     chmod +x ~/security-check.sh
     
     # Set up as weekly cron job
     (crontab -l ; echo "0 0 * * 0 ~/security-check.sh") | crontab -
     ```

### Resources

- [ArchWiki - Security](https://wiki.archlinux.org/title/Security)
- [Linux Hardening Guide](https://madaidans-insecurities.github.io/guides/linux-hardening.html)
- [Wireshark Documentation](https://www.wireshark.org/docs/)
- [Lynis Documentation](https://cisofy.com/documentation/lynis/)

## Projects and Exercises

1. **Home Network Security Project**
   - Set up a secure home router with Linux
   - Implement VLANs for network segmentation
   - Configure firewall rules for different zones
   - Set up intrusion detection
   - Document your setup and security measures

2. **Secure Remote Access Solution**
   - Set up a WireGuard VPN server
   - Configure client profiles for different devices
   - Implement secure SSH access
   - Create access control rules
   - Document the setup process

3. **Security Monitoring System**
   - Set up centralized logging for network devices
   - Configure alerts for suspicious activity
   - Implement regular security scans
   - Create a security incident response plan
   - Document monitoring procedures

4. **Hardened Web Server**
   - Set up a web server with security in mind
   - Implement proper firewall rules
   - Configure TLS/SSL properly
   - Set up fail2ban and ModSecurity
   - Document security measures and best practices

## Assessment

You should now be able to:

1. Configure and manage advanced network settings
2. Implement and maintain effective firewall configurations
3. Set up secure connections using SSH and VPNs
4. Apply system hardening techniques to protect your Linux installation
5. Monitor network traffic and detect potential security issues
6. Implement network services with security as a priority

## Next Steps

In [Month 9: Automation and Scripting](month-09-automation.md), we'll focus on:
- Creating powerful shell scripts for automation
- Implementing configuration management
- Setting up task scheduling and monitoring
- Developing system administration tools
- Automating routine maintenance and backups

## Acknowledgements

This learning guide was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Learning path structure and organization
- Resource recommendations
- Project suggestions

Claude was used as a development aid while all final implementation decisions and verification were performed by Joshua Michael Hall.

## Disclaimer

This guide is provided "as is", without warranty of any kind. Follow all instructions carefully and always make backups before making system changes.
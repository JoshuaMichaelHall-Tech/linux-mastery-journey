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
   - Review TCP/IP protocol stack
   - Understand network interfaces and routing
   - Study DNS resolution process

2. **Network Configuration Tools** (3 hours)
   - Master ip command for interface management
   - Configure NetworkManager through CLI and GUI
   - Understand systemd-networkd as an alternative
   - Explore wpa_supplicant for wireless connections

3. **Routing and Network Namespaces** (3 hours)
   - Configure static routes
   - Understand and use network namespaces
   - Set up policy-based routing
   - Learn about routing protocols

4. **Network Diagnostics** (2 hours)
   - Use ping, traceroute, and mtr effectively
   - Master netstat and ss for connection monitoring
   - Deploy tcpdump for packet capture and analysis
   - Implement network testing and benchmarking tools

### Resources

- [ArchWiki - Network Configuration](https://wiki.archlinux.org/title/Network_configuration)
- [Linux Network Administration Guide](https://tldp.org/LDP/nag2/index.html)
- [NetworkManager Documentation](https://networkmanager.dev/docs/)
- [Arch Linux Network Debugging](https://wiki.archlinux.org/title/Network_debugging)

## Week 2: Firewall Configuration and Management

### Core Learning Activities

1. **Firewall Concepts** (2 hours)
   - Understand iptables, nftables, and firewalld
   - Learn about stateful vs. stateless firewalls
   - Study zones and trust levels
   - Understand packet flow and filtering

2. **Firewalld Configuration** (3 hours)
   - Install and configure firewalld
   - Manage zones and services
   - Configure port forwarding
   - Set up rich rules
   - Implement logging

3. **Direct iptables/nftables Management** (3 hours)
   - Learn basic iptables syntax and chains
   - Understand nftables as a modern replacement
   - Create persistent rules
   - Implement custom chains
   - Configure logging and rate limiting

4. **Application Layer Firewalls** (2 hours)
   - Understand application firewalls vs. network firewalls
   - Configure fail2ban for brute force protection
   - Implement ModSecurity for web applications
   - Learn about intrusion detection systems

### Resources

- [ArchWiki - Firewalld](https://wiki.archlinux.org/title/Firewalld)
- [ArchWiki - Nftables](https://wiki.archlinux.org/title/Nftables)
- [Firewalld Documentation](https://firewalld.org/documentation/)
- [Fail2ban Documentation](https://www.fail2ban.org/wiki/index.php/Main_Page)

## Week 3: SSH, VPNs, and Secure Connections

### Core Learning Activities

1. **Advanced SSH Configuration** (3 hours)
   - Secure SSH server configuration
   - Set up SSH key authentication
   - Configure SSH client for multiple hosts
   - Implement SSH agents and forwarding
   - Use SSH config for efficiency

2. **SSH Tunneling and Port Forwarding** (2 hours)
   - Set up local and remote port forwarding
   - Implement dynamic (SOCKS) proxying
   - Create jump hosts for multi-hop connections
   - Use SSH tunnels for secure services

3. **VPN Setup with WireGuard** (3 hours)
   - Install and configure WireGuard
   - Generate keys and set up peers
   - Configure routing for VPN traffic
   - Implement split tunneling
   - Test and troubleshoot connections

4. **OpenVPN Configuration** (2 hours)
   - Install and configure OpenVPN
   - Understand certificate-based authentication
   - Configure client connections
   - Implement network configuration
   - Compare with WireGuard

### Resources

- [ArchWiki - SSH](https://wiki.archlinux.org/title/SSH)
- [ArchWiki - WireGuard](https://wiki.archlinux.org/title/WireGuard)
- [ArchWiki - OpenVPN](https://wiki.archlinux.org/title/OpenVPN)
- [WireGuard Quick Start](https://www.wireguard.com/quickstart/)
- [OpenSSH Documentation](https://www.openssh.com/manual.html)

## Week 4: System Hardening and Security Monitoring

### Core Learning Activities

1. **Basic System Hardening** (3 hours)
   - Implement the principle of least privilege
   - Configure secure boot options
   - Set up disk encryption
   - Secure user accounts and authentication
   - Implement process isolation

2. **Security Monitoring** (2 hours)
   - Configure log auditing for security events
   - Set up auditd for system call monitoring
   - Implement intrusion detection with AIDE
   - Learn about system integrity verification

3. **Network Monitoring and Analysis** (3 hours)
   - Set up network traffic monitoring
   - Use Wireshark/tshark for packet analysis
   - Implement bandwidth monitoring
   - Configure alerts for suspicious activity

4. **Security Scanning and Testing** (2 hours)
   - Use nmap for network scanning
   - Conduct security audits with Lynis
   - Check for vulnerabilities with OpenVAS
   - Implement regular security checks

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

In Month 9, we'll focus on:
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

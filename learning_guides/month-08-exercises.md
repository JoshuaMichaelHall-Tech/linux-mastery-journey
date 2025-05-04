# Month 8: Networking and Security Fundamentals - Exercises

This document contains practical exercises and projects to accompany the Month 8 learning guide. Complete these exercises to develop your skills in network configuration, firewall management, secure connections, and system hardening.

## Exercise 1: Network Configuration and Analysis

Create a comprehensive network configuration and analysis toolkit.

### Task 1: Network Interface Management

1. **Document your current network setup**:
   ```bash
   # Create a documentation directory
   mkdir -p ~/network-security-exercises/network-config
   cd ~/network-security-exercises/network-config
   
   # Document current network configuration
   ip -c a > 01-interfaces.txt
   ip -c route > 02-routes.txt
   cat /etc/resolv.conf > 03-dns.txt
   ss -tuln > 04-listening-ports.txt
   cat /etc/hosts > 05-hosts.txt
   hostname -f > 06-hostname.txt
   ```

2. **Create a NetworkManager connection profile script**:
   ```bash
   # Create a script to set up a new connection profile
   cat > create-nm-profile.sh << 'EOF'
   #!/bin/bash
   # Usage: ./create-nm-profile.sh PROFILE_NAME INTERFACE IP_ADDRESS GATEWAY DNS1 DNS2

   if [ $# -lt 6 ]; then
     echo "Usage: $0 PROFILE_NAME INTERFACE IP_ADDRESS GATEWAY DNS1 DNS2"
     echo "Example: $0 work-static eth0 192.168.1.100/24 192.168.1.1 8.8.8.8 8.8.4.4"
     exit 1
   fi

   PROFILE=$1
   IFACE=$2
   IP=$3
   GW=$4
   DNS1=$5
   DNS2=$6

   # Check if profile already exists
   if nmcli connection show | grep -q "$PROFILE"; then
     echo "Profile $PROFILE already exists. Remove it? (y/n)"
     read answer
     if [ "$answer" == "y" ]; then
       nmcli connection delete "$PROFILE"
     else
       echo "Exiting without changes."
       exit 1
     fi
   fi

   # Create new connection profile
   echo "Creating new profile: $PROFILE"
   nmcli connection add type ethernet con-name "$PROFILE" ifname "$IFACE"
   nmcli connection modify "$PROFILE" ipv4.addresses "$IP"
   nmcli connection modify "$PROFILE" ipv4.gateway "$GW"
   nmcli connection modify "$PROFILE" ipv4.dns "$DNS1 $DNS2"
   nmcli connection modify "$PROFILE" ipv4.method manual

   echo "Profile created. Activate now? (y/n)"
   read answer
   if [ "$answer" == "y" ]; then
     nmcli connection up "$PROFILE"
   fi

   # Show the new profile
   echo "Profile details:"
   nmcli connection show "$PROFILE"
   EOF

   chmod +x create-nm-profile.sh
   ```

3. **Create a script to toggle between different network profiles**:
   ```bash
   cat > toggle-network.sh << 'EOF'
   #!/bin/bash
   # Quick toggle between network profiles

   # Define profiles
   PROFILES=()
   
   # Get list of available profiles
   while IFS= read -r line; do
     # Extract connection name from nmcli output
     name=$(echo "$line" | awk '{print $1}')
     if [[ -n "$name" && "$name" != "NAME" ]]; then
       PROFILES+=("$name")
     fi
   done < <(nmcli -t -f NAME connection show)

   # Display menu
   echo "Available network profiles:"
   for i in "${!PROFILES[@]}"; do
     echo "$((i+1)). ${PROFILES[$i]}"
   done
   echo "Enter profile number to activate:"
   
   # Get user choice
   read choice
   index=$((choice-1))
   
   if [[ $index -ge 0 && $index -lt ${#PROFILES[@]} ]]; then
     selected="${PROFILES[$index]}"
     echo "Activating profile: $selected"
     nmcli connection up "$selected"
   else
     echo "Invalid selection"
     exit 1
   fi
   EOF

   chmod +x toggle-network.sh
   ```

### Task 2: Advanced Network Diagnostics

1. **Create a network diagnostics script**:
   ```bash
   cat > network-diagnostics.sh << 'EOF'
   #!/bin/bash
   # Network diagnostics tool

   OUTPUT_DIR="network-diagnostics-$(date +%Y%m%d-%H%M%S)"
   mkdir -p "$OUTPUT_DIR"
   cd "$OUTPUT_DIR"

   echo "Running comprehensive network diagnostics at $(date)"
   echo "==================================================="

   # Function to run a command and save output
   run_cmd() {
     local cmd="$1"
     local outfile="$2"
     echo "Running: $cmd"
     echo "# Command: $cmd" > "$outfile"
     echo "# Run at: $(date)" >> "$outfile"
     echo "===========================================" >> "$outfile"
     eval "$cmd" >> "$outfile" 2>&1
     echo "" >> "$outfile"
   }

   # Basic connectivity tests
   echo "Testing basic connectivity..."
   run_cmd "ping -c 4 8.8.8.8" "01-ping-google-dns.txt"
   run_cmd "ping -c 4 example.com" "02-ping-example.txt"

   # DNS resolution
   echo "Testing DNS resolution..."
   run_cmd "dig +short google.com" "03-dig-google.txt"
   run_cmd "dig +trace example.com" "04-dig-trace-example.txt"
   run_cmd "cat /etc/resolv.conf" "05-resolv-conf.txt"

   # Network interface details
   echo "Collecting interface information..."
   run_cmd "ip -c a" "06-ip-interfaces.txt"
   run_cmd "ip -c route" "07-ip-routes.txt"
   run_cmd "ip -s link" "08-interface-statistics.txt"

   # Connection details
   echo "Collecting connection information..."
   run_cmd "ss -tunapl" "09-active-connections.txt"
   run_cmd "netstat -rn" "10-routing-table.txt"
   run_cmd "ss -s" "11-socket-statistics.txt"

   # Network services
   echo "Identifying network services..."
   run_cmd "systemctl list-units --type=service --state=running | grep -E 'network|dhcp|dns|firewall|ssh|vpn'" "12-network-services.txt"

   # Traceroutes
   echo "Running traceroutes..."
   run_cmd "traceroute -n 8.8.8.8" "13-traceroute-google-dns.txt"
   run_cmd "traceroute -n example.com" "14-traceroute-example.txt"

   # MTR (My Traceroute)
   echo "Running MTR tests..."
   run_cmd "mtr -n -c 5 -r 8.8.8.8" "15-mtr-google-dns.txt"
   run_cmd "mtr -n -c 5 -r example.com" "16-mtr-example.txt"

   # Firewall status
   echo "Checking firewall status..."
   if command -v firewall-cmd >/dev/null 2>&1; then
     run_cmd "firewall-cmd --list-all" "17-firewall-cmd.txt"
   fi
   run_cmd "iptables -L -v" "18-iptables.txt"
   if command -v nft >/dev/null 2>&1; then
     run_cmd "nft list ruleset" "19-nftables.txt"
   fi

   # Listen ports
   echo "Checking listening ports..."
   run_cmd "ss -tulpn" "20-listening-ports.txt"

   # DNS leak test
   echo "Testing for DNS leaks..."
   run_cmd "for i in {1..3}; do dig +short whoami.akamai.net @ns1.google.com; done" "21-dns-leak-test.txt"

   # ARP table
   echo "Collecting ARP table..."
   run_cmd "ip neigh" "22-arp-table.txt"

   # Create summary file
   echo "Creating summary report..."
   cat > summary.txt << 'SUMMARY'
   NETWORK DIAGNOSTICS SUMMARY
   ===========================

   This directory contains the results of a comprehensive network diagnostic scan.
   Review the following files for detailed information:

   Basic Connectivity:
   - 01-ping-google-dns.txt: Tests connectivity to Google DNS
   - 02-ping-example.txt: Tests connectivity to example.com

   DNS Configuration:
   - 03-dig-google.txt: DNS resolution for google.com
   - 04-dig-trace-example.txt: Trace DNS resolution for example.com
   - 05-resolv-conf.txt: DNS resolver configuration

   Network Interfaces:
   - 06-ip-interfaces.txt: Network interface configuration
   - 07-ip-routes.txt: Routing table
   - 08-interface-statistics.txt: Interface statistics

   Connections:
   - 09-active-connections.txt: Active network connections
   - 10-routing-table.txt: Network routing table
   - 11-socket-statistics.txt: Socket statistics

   Services:
   - 12-network-services.txt: Running network-related services

   Route Analysis:
   - 13-traceroute-google-dns.txt: Traceroute to Google DNS
   - 14-traceroute-example.txt: Traceroute to example.com
   - 15-mtr-google-dns.txt: MTR to Google DNS
   - 16-mtr-example.txt: MTR to example.com

   Firewall Status:
   - 17-firewall-cmd.txt: firewalld configuration (if installed)
   - 18-iptables.txt: iptables rules
   - 19-nftables.txt: nftables rules (if installed)

   Security:
   - 20-listening-ports.txt: Open ports listening for connections
   - 21-dns-leak-test.txt: Test for DNS leaks
   - 22-arp-table.txt: ARP table (potential for ARP spoofing detection)
   SUMMARY

   # Create archive
   cd ..
   tar -czf "$OUTPUT_DIR.tar.gz" "$OUTPUT_DIR"
   echo "Diagnostics complete! Results saved in $OUTPUT_DIR/ and $OUTPUT_DIR.tar.gz"
   EOF

   chmod +x network-diagnostics.sh
   ```

2. **Create a packet capture and analysis script**:
   ```bash
   cat > packet-capture.sh << 'EOF'
   #!/bin/bash
   # Packet capture and analysis script

   if [ "$EUID" -ne 0 ]; then
     echo "Please run as root"
     exit 1
   fi

   # Default values
   INTERFACE=$(ip route | grep default | awk '{print $5}')
   DURATION=30
   FILTER=""
   OUTPUT="capture-$(date +%Y%m%d-%H%M%S).pcap"

   # Help function
   show_help() {
     echo "Packet Capture Script"
     echo "Usage: $0 [options]"
     echo ""
     echo "Options:"
     echo "  -i, --interface INTERFACE  Network interface to capture (default: $INTERFACE)"
     echo "  -d, --duration SECONDS     Capture duration in seconds (default: $DURATION)"
     echo "  -f, --filter FILTER        Capture filter expression (e.g., 'port 80')"
     echo "  -o, --output FILE          Output file name (default: $OUTPUT)"
     echo "  -h, --help                 Show this help message"
     echo ""
     echo "Examples:"
     echo "  $0 -i eth0 -d 60 -f 'port 80 or port 443'"
     echo "  $0 -i wlan0 -f 'host 192.168.1.1'"
   }

   # Parse arguments
   while [[ $# -gt 0 ]]; do
     case $1 in
       -i|--interface)
         INTERFACE="$2"
         shift 2
         ;;
       -d|--duration)
         DURATION="$2"
         shift 2
         ;;
       -f|--filter)
         FILTER="$2"
         shift 2
         ;;
       -o|--output)
         OUTPUT="$2"
         shift 2
         ;;
       -h|--help)
         show_help
         exit 0
         ;;
       *)
         echo "Unknown option: $1"
         show_help
         exit 1
         ;;
     esac
   done

   # Validate interface
   if ! ip link show "$INTERFACE" &>/dev/null; then
     echo "Error: Interface $INTERFACE does not exist"
     echo "Available interfaces:"
     ip -o link show | awk -F': ' '{print $2}'
     exit 1
   fi

   # Build tcpdump command
   TCPDUMP_CMD="tcpdump -i $INTERFACE -w $OUTPUT"
   if [ -n "$FILTER" ]; then
     TCPDUMP_CMD="$TCPDUMP_CMD '$FILTER'"
   fi

   # Display capture details
   echo "Starting packet capture with the following settings:"
   echo "  Interface: $INTERFACE"
   echo "  Duration: $DURATION seconds"
   echo "  Filter: ${FILTER:-None}"
   echo "  Output file: $OUTPUT"
   echo ""
   echo "Press Ctrl+C to stop capturing earlier."

   # Start capture
   echo "Capturing packets for $DURATION seconds..."
   timeout "$DURATION" tcpdump -i "$INTERFACE" -w "$OUTPUT" ${FILTER:+-f "$FILTER"}

   # Check if capture was successful
   if [ $? -eq 124 ]; then
     echo "Capture completed after $DURATION seconds."
   elif [ $? -eq 0 ]; then
     echo "Capture stopped manually."
   else
     echo "Capture failed with error code $?."
     exit 1
   fi

   # Display capture summary
   FILESIZE=$(du -h "$OUTPUT" | cut -f1)
   PACKETCOUNT=$(tcpdump -r "$OUTPUT" -c 2>/dev/null | wc -l)
   echo ""
   echo "Capture Summary:"
   echo "  File: $OUTPUT"
   echo "  Size: $FILESIZE"
   echo "  Packets: $PACKETCOUNT"
   echo ""

   # Offer to analyze the capture
   echo "Would you like to analyze this capture now? (y/n)"
   read -r answer

   if [[ "$answer" =~ ^[Yy] ]]; then
     echo "Choose analysis type:"
     echo "  1) Basic packet summary"
     echo "  2) Protocol distribution"
     echo "  3) Top talkers (IP addresses)"
     echo "  4) HTTP traffic"
     echo "  5) All of the above"
     read -r choice

     case "$choice" in
       1)
         echo "Basic packet summary:"
         tcpdump -r "$OUTPUT" -qn | head -n 20
         ;;
       2)
         echo "Protocol distribution:"
         tcpdump -r "$OUTPUT" -qn | awk '{print $2}' | cut -d'.' -f1 | sort | uniq -c | sort -nr
         ;;
       3)
         echo "Top talkers:"
         tcpdump -r "$OUTPUT" -qn | awk '{print $3, $5}' | sed 's/:.*//' | sort | uniq -c | sort -nr | head -n 10
         ;;
       4)
         echo "HTTP traffic:"
         tcpdump -r "$OUTPUT" -A -s 0 | grep -i -E "^(GET|POST|PUT|DELETE|HTTP)"
         ;;
       5)
         echo "Basic packet summary:"
         tcpdump -r "$OUTPUT" -qn | head -n 20
         echo ""
         
         echo "Protocol distribution:"
         tcpdump -r "$OUTPUT" -qn | awk '{print $2}' | cut -d'.' -f1 | sort | uniq -c | sort -nr
         echo ""
         
         echo "Top talkers:"
         tcpdump -r "$OUTPUT" -qn | awk '{print $3, $5}' | sed 's/:.*//' | sort | uniq -c | sort -nr | head -n 10
         echo ""
         
         echo "HTTP traffic (first 10 lines):"
         tcpdump -r "$OUTPUT" -A -s 0 | grep -i -E "^(GET|POST|PUT|DELETE|HTTP)" | head -n 10
         ;;
       *)
         echo "Invalid choice"
         ;;
     esac
   fi

   echo "Capture file saved as $OUTPUT"
   EOF

   chmod +x packet-capture.sh
   ```

3. **Create a network performance testing script**:
   ```bash
   cat > network-performance.sh << 'EOF'
   #!/bin/bash
   # Network performance testing script

   # Install required tools if not present
   check_install() {
     if ! command -v "$1" &>/dev/null; then
       echo "$1 is not installed. Attempting to install..."
       sudo pacman -Sy --noconfirm "$1" || {
         echo "Failed to install $1. Please install it manually and try again."
         exit 1
       }
     fi
   }

   # Check for required tools
   check_install iperf3
   check_install nmap
   check_install curl

   # Create output directory
   OUTPUT_DIR="network-performance-$(date +%Y%m%d-%H%M%S)"
   mkdir -p "$OUTPUT_DIR"
   cd "$OUTPUT_DIR"

   echo "Running network performance tests at $(date)" | tee results.txt
   echo "===============================================" | tee -a results.txt

   # Function to run a test and log results
   run_test() {
     local test_name="$1"
     local cmd="$2"
     
     echo "" | tee -a results.txt
     echo "Running test: $test_name" | tee -a results.txt
     echo "Command: $cmd" | tee -a results.txt
     echo "----------------------------------------" | tee -a results.txt
     
     eval "$cmd" | tee -a results.txt
     
     echo "----------------------------------------" | tee -a results.txt
     echo "Test completed at $(date)" | tee -a results.txt
   }

   # Basic latency tests
   run_test "Basic Latency Test (Google DNS)" "ping -c 10 8.8.8.8 | tail -2"
   run_test "Basic Latency Test (CloudFlare DNS)" "ping -c 10 1.1.1.1 | tail -2"

   # MTR Tests
   run_test "MTR Test (Google)" "mtr -c 10 -r google.com"
   run_test "MTR Test (CloudFlare)" "mtr -c 10 -r cloudflare.com"

   # DNS Resolution Speed
   run_test "DNS Resolution Speed" "for i in {1..10}; do time dig +short google.com &>/dev/null; done"

   # HTTP Performance
   run_test "HTTP Download Speed (Small File)" "curl -o /dev/null -s -w 'Time: %{time_total} s\nSpeed: %{speed_download} bytes/sec\n' https://example.com"
   run_test "HTTP Download Speed (Large File)" "curl -o /dev/null -s -w 'Time: %{time_total} s\nSpeed: %{speed_download} bytes/sec\n' https://speed.cloudflare.com/__down?bytes=10000000"

   # Speedtest (if internet connection available)
   if ping -c 1 google.com &>/dev/null; then
     if command -v speedtest-cli &>/dev/null; then
       run_test "Internet Speed Test" "speedtest-cli --simple"
     else
       echo "speedtest-cli not installed. Skipping internet speed test."
     fi
   else
     echo "Internet connection not available. Skipping internet speed test."
   fi

   # Check for iperf server
   read -p "Do you want to run iperf tests against a server? (y/n): " run_iperf
   if [[ "$run_iperf" =~ ^[Yy] ]]; then
     read -p "Enter iperf server address: " iperf_server
     
     # TCP Test
     run_test "iperf3 TCP Test" "iperf3 -c $iperf_server -t 10"
     
     # UDP Test
     run_test "iperf3 UDP Test" "iperf3 -c $iperf_server -u -b 100M -t 10"
     
     # Multiple Streams Test
     run_test "iperf3 Multiple Streams Test" "iperf3 -c $iperf_server -P 4 -t 10"
   fi

   # Network interface speed check
   echo "" | tee -a results.txt
   echo "Network Interface Speed Report:" | tee -a results.txt
   echo "--------------------------------" | tee -a results.txt
   for iface in $(ip -o link show | awk -F': ' '{print $2}' | grep -v -E 'lo|docker|veth|br-'); do
     if ethtool "$iface" &>/dev/null; then
       echo "Interface: $iface" | tee -a results.txt
       ethtool "$iface" | grep -E 'Speed|Duplex|Link' | tee -a results.txt
       echo "" | tee -a results.txt
     fi
   done

   # Create a summary
   echo "" | tee -a results.txt
   echo "Performance Test Summary" | tee -a results.txt
   echo "======================" | tee -a results.txt
   echo "Tests completed at: $(date)" | tee -a results.txt
   echo "Results saved in: $PWD/results.txt" | tee -a results.txt

   # Create archive
   cd ..
   tar -czf "$OUTPUT_DIR.tar.gz" "$OUTPUT_DIR"
   echo "Performance tests complete! Results saved in $OUTPUT_DIR/ and $OUTPUT_DIR.tar.gz"
   EOF

   chmod +x network-performance.sh
   ```

### Task 3: Network Namespaces and Virtual Interfaces

1. **Create a network namespace lab environment**:
   ```bash
   cat > network-namespace-lab.sh << 'EOF'
   #!/bin/bash
   # Network namespace laboratory for testing isolated networks

   # Check for root privileges
   if [ "$EUID" -ne 0 ]; then
     echo "Please run as root"
     exit 1
   fi

   # Clean up function
   cleanup() {
     echo "Cleaning up namespaces and interfaces..."
     # Delete veth pairs
     ip link del veth0 2>/dev/null
     ip link del veth2 2>/dev/null
     
     # Delete namespaces
     ip netns del ns1 2>/dev/null
     ip netns del ns2 2>/dev/null
     
     echo "Cleanup complete"
   }

   # Setup function
   setup() {
     echo "Setting up network namespaces and virtual interfaces..."
     
     # Create namespaces
     ip netns add ns1
     ip netns add ns2
     
     # Create veth pairs
     ip link add veth0 type veth peer name veth1
     ip link add veth2 type veth peer name veth3
     
     # Move interfaces to namespaces
     ip link set veth1 netns ns1
     ip link set veth3 netns ns2
     
     # Configure interfaces
     ip addr add 10.0.1.1/24 dev veth0
     ip netns exec ns1 ip addr add 10.0.1.2/24 dev veth1
     ip addr add 10.0.2.1/24 dev veth2
     ip netns exec ns2 ip addr add 10.0.2.2/24 dev veth3
     
     # Bring interfaces up
     ip link set veth0 up
     ip link set veth2 up
     ip netns exec ns1 ip link set veth1 up
     ip netns exec ns1 ip link set lo up
     ip netns exec ns2 ip link set veth3 up
     ip netns exec ns2 ip link set lo up
     
     # Setup routing
     ip netns exec ns1 ip route add default via 10.0.1.1
     ip netns exec ns2 ip route add default via 10.0.2.1
     
     # Enable forwarding between namespaces
     echo 1 > /proc/sys/net/ipv4/ip_forward
     iptables -t nat -A POSTROUTING -s 10.0.1.0/24 -j MASQUERADE
     iptables -t nat -A POSTROUTING -s 10.0.2.0/24 -j MASQUERADE
     
     echo "Setup complete!"
     echo ""
     echo "Namespace Configuration:"
     echo "------------------------"
     echo "ns1: 10.0.1.2/24 (gateway: 10.0.1.1)"
     echo "ns2: 10.0.2.2/24 (gateway: 10.0.2.1)"
     echo ""
     echo "Available commands:"
     echo "  ip netns exec ns1 bash     # Start a shell in namespace 1"
     echo "  ip netns exec ns2 bash     # Start a shell in namespace 2"
     echo "  ip netns exec ns1 ping -c 3 10.0.2.2  # Test connectivity from ns1 to ns2"
     echo "  ip netns exec ns2 ping -c 3 10.0.1.2  # Test connectivity from ns2 to ns1"
     echo ""
   }

   # Command selection
   case "$1" in
     setup)
       cleanup
       setup
       ;;
     clean)
       cleanup
       ;;
     test)
       echo "Testing connectivity between namespaces..."
       echo "Ping from ns1 to ns2:"
       ip netns exec ns1 ping -c 3 10.0.2.2
       echo ""
       echo "Ping from ns2 to ns1:"
       ip netns exec ns2 ping -c 3 10.0.1.2
       ;;
     ns1)
       echo "Starting shell in namespace ns1..."
       ip netns exec ns1 bash
       ;;
     ns2)
       echo "Starting shell in namespace ns2..."
       ip netns exec ns2 bash
       ;;
     status)
       echo "Namespace status:"
       ip netns list
       echo ""
       echo "Interface status:"
       ip link show veth0
       ip link show veth2
       ip netns exec ns1 ip link show veth1
       ip netns exec ns2 ip link show veth3
       echo ""
       echo "Routing tables:"
       echo "Host:"
       ip route
       echo "ns1:"
       ip netns exec ns1 ip route
       echo "ns2:"
       ip netns exec ns2 ip route
       ;;
     *)
       echo "Network Namespace Lab"
       echo "Usage: $0 [command]"
       echo ""
       echo "Commands:"
       echo "  setup   - Set up network namespaces and virtual interfaces"
       echo "  clean   - Clean up namespaces and interfaces"
       echo "  test    - Test connectivity between namespaces"
       echo "  ns1     - Start a shell in namespace ns1"
       echo "  ns2     - Start a shell in namespace ns2"
       echo "  status  - Show current namespace and interface status"
       echo ""
       ;;
   esac
   EOF

   chmod +x network-namespace-lab.sh
   ```

## Exercise 2: Firewall Configuration

Build a comprehensive firewall configuration system using different Linux firewall technologies.

### Task 1: Firewalld Multi-Zone Configuration

1. **Create a firewalld configuration script**:
   ```bash
   cat > firewalld-config.sh << 'EOF'
   #!/bin/bash
   # Firewalld multi-zone configuration script

   # Check if running as root
   if [ "$EUID" -ne 0 ]; then
     echo "Please run as root"
     exit 1
   fi

   # Check if firewalld is installed
   if ! command -v firewall-cmd &> /dev/null; then
     echo "firewalld is not installed. Installing..."
     pacman -Sy --noconfirm firewalld || {
       echo "Failed to install firewalld"
       exit 1
     }
   fi

   # Ensure firewalld is running
   systemctl is-active --quiet firewalld
   if [ $? -ne 0 ]; then
     echo "Starting firewalld..."
     systemctl start firewalld
     systemctl enable firewalld
   fi

   # Function to apply configuration
   apply_config() {
     echo "Configuring firewalld with multi-zone setup..."
     
     # Reset to default configuration
     echo "Resetting to default configuration..."
     firewall-cmd --set-default-zone=public
     
     # Get all interfaces
     INTERFACES=$(ip -o link show | awk -F': ' '{print $2}' | grep -v -E 'lo|docker|veth|br-')
     
     # Setup public zone (restrictive, for untrusted networks)
     echo "Setting up public zone (restrictive)..."
     firewall-cmd --zone=public --remove-service=dhcpv6-client --permanent
     firewall-cmd --zone=public --add-service=ssh --permanent
     firewall-cmd --zone=public --add-service=http --permanent
     firewall-cmd --zone=public --add-service=https --permanent
     firewall-cmd --zone=public --add-port=53/tcp --permanent
     firewall-cmd --zone=public --add-port=53/udp --permanent
     
     # Setup home zone (less restrictive, for trusted home networks)
     echo "Setting up home zone (moderate)..."
     firewall-cmd --zone=home --add-service=ssh --permanent
     firewall-cmd --zone=home --add-service=http --permanent
     firewall-cmd --zone=home --add-service=https --permanent
     firewall-cmd --zone=home --add-service=samba --permanent
     firewall-cmd --zone=home --add-service=mdns --permanent
     firewall-cmd --zone=home --add-service=dhcpv6-client --permanent
     
     # Setup trusted zone (most permissive, for completely trusted networks)
     echo "Setting up trusted zone (permissive)..."
     # Almost everything allowed in trusted zone
     
     # Setup DMZ zone (for servers accessible from public networks)
     echo "Setting up DMZ zone (server-focused)..."
     firewall-cmd --zone=dmz --add-service=ssh --permanent
     firewall-cmd --zone=dmz --add-service=http --permanent
     firewall-cmd --zone=dmz --add-service=https --permanent
     
     # Assign interfaces (default is public)
     echo "Available interfaces: $INTERFACES"
     echo "Assign interfaces to zones? (y/n)"
     read answer
     
     if [[ "$answer" =~ ^[Yy] ]]; then
       for iface in $INTERFACES; do
         echo "Assign interface $iface to which zone? (public/home/trusted/dmz/skip)"
         read zone
         
         if [ "$zone" != "skip" ]; then
           echo "Assigning $iface to $zone zone..."
           firewall-cmd --zone="$zone" --change-interface="$iface" --permanent
         fi
       done
     fi
     
     # Port forwarding example
     echo "Set up port forwarding? (y/n)"
     read portfwd
     
     if [[ "$portfwd" =~ ^[Yy] ]]; then
       echo "Enter external port to forward: "
       read ext_port
       
       echo "Enter internal IP to forward to: "
       read int_ip
       
       echo "Enter internal port to forward to: "
       read int_port
       
       echo "Select protocol (tcp/udp): "
       read proto
       
       echo "Setting up port forwarding for $ext_port -> $int_ip:$int_port ($proto)..."
       firewall-cmd --zone=public --add-forward-port=port="$ext_port":proto="$proto":toport="$int_port":toaddr="$int_ip" --permanent
       
       # Enable masquerading for forwarding
       firewall-cmd --zone=public --add-masquerade --permanent
     fi
     
     # Rich rules examples
     echo "Set up rate limiting for SSH? (y/n)"
     read ratelimit
     
     if [[ "$ratelimit" =~ ^[Yy] ]]; then
       echo "Setting up rate limiting for SSH (3 connections per minute)..."
       firewall-cmd --zone=public --add-rich-rule='rule service name="ssh" accept limit value="3/m"' --permanent
     fi
     
     # Set up logging
     echo "Enable logging for denied packets? (y/n)"
     read logging
     
     if [[ "$logging" =~ ^[Yy] ]]; then
       echo "Enabling logging for denied packets..."
       firewall-cmd --set-log-denied=all
     fi
     
     # Apply changes
     echo "Reloading firewall to apply changes..."
     firewall-cmd --reload
     
     # Show new configuration
     echo "New firewall configuration:"
     firewall-cmd --list-all-zones | grep -A 10 "^[a-z]"
   }

   # Function to backup configuration
   backup_config() {
     BACKUP_FILE="firewalld-backup-$(date +%Y%m%d-%H%M%S).xml"
     echo "Backing up firewalld configuration to $BACKUP_FILE..."
     firewall-cmd --export-all-zones > "$BACKUP_FILE"
     echo "Backup completed"
   }

   # Function to restore configuration
   restore_config() {
     echo "Available backup files:"
     ls -1 firewalld-backup-*
     
     echo "Enter backup file to restore:"
     read backup_file
     
     if [ -f "$backup_file" ]; then
       echo "Restoring from $backup_file..."
       firewall-cmd --import-xml-file="$backup_file"
       echo "Restoration completed"
     else
       echo "Backup file not found"
     fi
   }

   # Menu
   echo "Firewalld Multi-Zone Configuration Tool"
   echo "========================================"
   echo "1. Apply multi-zone configuration"
   echo "2. Backup current configuration"
   echo "3. Restore from backup"
   echo "4. Show current configuration"
   echo "5. Exit"
   echo ""
   echo "Enter choice: "
   read choice

   case "$choice" in
     1)
       apply_config
       ;;
     2)
       backup_config
       ;;
     3)
       restore_config
       ;;
     4)
       echo "Current firewall configuration:"
       firewall-cmd --list-all-zones
       ;;
     5)
       echo "Exiting..."
       exit 0
       ;;
     *)
       echo "Invalid choice"
       ;;
   esac
   EOF

   chmod +x firewalld-config.sh
   ```

### Task 2: NFTables Ruleset Implementation

1. **Create an nftables configuration script**:
   ```bash
   cat > nftables-config.sh << 'EOF'
   #!/bin/bash
   # NFTables ruleset implementation script

   # Check if running as root
   if [ "$EUID" -ne 0 ]; then
     echo "Please run as root"
     exit 1
   fi

   # Check if nftables is installed
   if ! command -v nft &> /dev/null; then
     echo "nftables is not installed. Installing..."
     pacman -Sy --noconfirm nftables || {
       echo "Failed to install nftables"
       exit 1
     }
   fi

   # Directory for configurations
   CONF_DIR="/etc/nftables"
   mkdir -p "$CONF_DIR"

   # Function to create a basic ruleset
   create_basic_ruleset() {
     echo "Creating basic nftables ruleset..."
     
     cat > "$CONF_DIR/basic-ruleset.nft" << 'END'
   #!/usr/sbin/nft -f

   # Clear existing ruleset
   flush ruleset

   # Create basic table and chains
   table inet filter {
     chain input {
       type filter hook input priority 0; policy drop;
       
       # Allow established/related connections
       ct state established,related accept
       
       # Allow loopback traffic
       iif lo accept
       
       # Allow ICMP and IGMP
       ip protocol icmp accept
       ip6 nexthdr icmpv6 accept
       ip protocol igmp accept
       
       # Allow SSH
       tcp dport 22 accept
       
       # Allow HTTP/HTTPS
       tcp dport { 80, 443 } accept
       
       # Drop invalid connections
       ct state invalid drop
       
       # Log dropped packets
       log prefix "nftables dropped: " limit rate 3/minute
       
       # Reject other traffic
       reject with icmpx type port-unreachable
     }
     
     chain forward {
       type filter hook forward priority 0; policy drop;
       
       # Allow established/related connections
       ct state established,related accept
       
       # Drop invalid connections
       ct state invalid drop
     }
     
     chain output {
       type filter hook output priority 0; policy accept;
     }
   }
   END
     
     echo "Basic ruleset created at $CONF_DIR/basic-ruleset.nft"
   }

   # Function to create advanced ruleset
   create_advanced_ruleset() {
     echo "Creating advanced nftables ruleset..."
     
     cat > "$CONF_DIR/advanced-ruleset.nft" << 'END'
   #!/usr/sbin/nft -f

   # Clear existing ruleset
   flush ruleset

   # Define variables
   define LAN_INTERFACE = eth0
   define WAN_INTERFACE = eth1
   define LAN_NETWORK = 192.168.1.0/24
   define DNS_SERVERS = { 1.1.1.1, 8.8.8.8 }

   # Table for address family independent rules
   table inet filter {
     # Basic connection tracking
     chain ct_rules {
       # Accept established/related connections
       ct state established,related accept
       # Drop invalid connections
       ct state invalid drop
     }
     
     # Input chain
     chain input {
       type filter hook input priority 0; policy drop;
       
       # Jump to connection tracking chain
       jump ct_rules
       
       # Allow loopback traffic
       iif lo accept
       
       # Allow ICMP and IGMP
       ip protocol icmp accept
       ip6 nexthdr icmpv6 accept
       ip protocol igmp accept
       
       # Allow LAN traffic
       iif $LAN_INTERFACE ip saddr $LAN_NETWORK accept
       
       # Rate limit SSH connections from WAN
       iif $WAN_INTERFACE tcp dport 22 limit rate 3/minute accept
       
       # HTTP/HTTPS from anywhere
       tcp dport { 80, 443 } accept
       
       # Log and reject everything else
       log prefix "nftables input rejected: " limit rate 3/minute
       reject with icmpx type port-unreachable
     }
     
     # Forward chain
     chain forward {
       type filter hook forward priority 0; policy drop;
       
       # Jump to connection tracking chain
       jump ct_rules
       
       # Allow LAN to WAN forwarding
       iif $LAN_INTERFACE oif $WAN_INTERFACE accept
       
       # Allow specific WAN to LAN forwarding (for port forwards)
       iif $WAN_INTERFACE oif $LAN_INTERFACE ct state new jump forward_wan_to_lan
       
       # Log and reject everything else
       log prefix "nftables forward rejected: " limit rate 3/minute
       reject with icmpx type port-unreachable
     }
     
     # Chain for WAN to LAN forwards
     chain forward_wan_to_lan {
       # Example port forward: WAN:80 -> LAN:192.168.1.10:80
       # ip daddr 192.168.1.10 tcp dport 80 accept
       
       # Add more port forwards here
       
       # Default is to return to parent chain for rejection
       return
     }
     
     # Output chain
     chain output {
       type filter hook output priority 0; policy accept;
     }
   }

   # NAT table
   table ip nat {
     # Prerouting chain (for DNAT/port forwarding)
     chain prerouting {
       type nat hook prerouting priority -100; policy accept;
       
       # Example port forward: WAN:80 -> LAN:192.168.1.10:80
       # iif $WAN_INTERFACE tcp dport 80 dnat to 192.168.1.10:80
       
       # Add more port forwards here
     }
     
     # Postrouting chain (for SNAT/masquerading)
     chain postrouting {
       type nat hook postrouting priority 100; policy accept;
       
       # Masquerade LAN traffic going to WAN
       oif $WAN_INTERFACE ip saddr $LAN_NETWORK masquerade
     }
   }

   # IPv6-specific rules
   table ip6 filter {
     chain input {
       type filter hook input priority 0; policy drop;
       
       # Accept established/related connections
       ct state established,related accept
       
       # Allow loopback traffic
       iif lo accept
       
       # Allow ICMPv6 (required for IPv6)
       icmpv6 type {
         destination-unreachable, packet-too-big, time-exceeded,
         parameter-problem, mld-listener-query, mld-listener-report,
         mld-listener-reduction, nd-router-advert, nd-neighbor-solicit,
         nd-neighbor-advert, ind-neighbor-solicit, ind-neighbor-advert,
         mld2-listener-report
       } accept
       
       # Allow SSH
       tcp dport 22 accept
       
       # Allow HTTP/HTTPS
       tcp dport { 80, 443 } accept
       
       # Log and reject everything else
       log prefix "nftables ipv6 rejected: " limit rate 3/minute
       reject with icmpv6 type port-unreachable
     }
   }
   END
     
     echo "Advanced ruleset created at $CONF_DIR/advanced-ruleset.nft"
   }

   # Function to create a stateful ruleset
   create_stateful_ruleset() {
     echo "Creating stateful nftables ruleset..."
     
     cat > "$CONF_DIR/stateful-ruleset.nft" << 'END'
   #!/usr/sbin/nft -f

   # Clear existing ruleset
   flush ruleset

   # Create table for connection tracking
   table inet filter {
     # Connection tracking set
     set ct_state {
       type ct_state
       elements = { established, related, invalid }
     }
     
     # Rate limiting sets
     set tcp_ports {
       type inet_service
       elements = { 22, 80, 443 }
     }
     
     # Port groups
     set web_services {
       type inet_service
       elements = { 80, 443, 8080, 8443 }
     }
     
     # IP blacklist
     set blacklist {
       type ipv4_addr
       flags interval
       auto-merge
     }
     
     # Input chain
     chain input {
       type filter hook input priority 0; policy drop;
       
       # Early drop of blacklisted IPs
       ip saddr @blacklist counter drop
       
       # Connection tracking
       ct state @ct_state vmap { established : accept, related : accept, invalid : drop }
       
       # Allow loopback
       iif lo accept
       
       # ICMPv4/v6 rate limiting
       ip protocol icmp limit rate 4/second accept
       ip6 nexthdr icmpv6 limit rate 4/second accept
       
       # Service-specific rules with rate limiting
       tcp dport 22 limit rate 3/minute accept
       
       # Web services
       tcp dport @web_services accept
       
       # UDP services (DNS example)
       udp dport 53 accept
       
       # Log and reject everything else
       counter log prefix "nftables input rejected: " limit rate 5/minute
       counter reject with icmpx type port-unreachable
     }
     
     # Forward chain
     chain forward {
       type filter hook forward priority 0; policy drop;
       
       # Connection tracking
       ct state @ct_state vmap { established : accept, related : accept, invalid : drop }
       
       # Further forwarding rules here
       
       # Log and reject everything else
       counter log prefix "nftables forward rejected: " limit rate 5/minute
       counter reject with icmpx type port-unreachable
     }
     
     # Output chain
     chain output {
       type filter hook output priority 0; policy accept;
     }
   }
   END
     
     echo "Stateful ruleset created at $CONF_DIR/stateful-ruleset.nft"
   }

   # Function to apply ruleset
   apply_ruleset() {
     echo "Available rulesets:"
     ls -1 "$CONF_DIR"/*.nft | sort
     
     echo "Enter ruleset to apply:"
     read ruleset
     
     if [ -f "$CONF_DIR/$ruleset" ]; then
       echo "Applying ruleset $CONF_DIR/$ruleset..."
       nft -f "$CONF_DIR/$ruleset"
       
       echo "Saving as default ruleset..."
       cp "$CONF_DIR/$ruleset" /etc/nftables.conf
       
       echo "Enabling nftables service..."
       systemctl enable nftables
       systemctl restart nftables
       
       echo "Current nftables ruleset:"
       nft list ruleset
     else
       echo "Ruleset file not found"
     fi
   }

   # Function to backup current ruleset
   backup_ruleset() {
     BACKUP_FILE="nftables-backup-$(date +%Y%m%d-%H%M%S).nft"
     echo "Backing up current nftables ruleset to $BACKUP_FILE..."
     nft list ruleset > "$BACKUP_FILE"
     echo "Backup completed"
   }

   # Main menu
   echo "NFTables Configuration Tool"
   echo "=========================="
   echo "1. Create basic ruleset"
   echo "2. Create advanced ruleset"
   echo "3. Create stateful ruleset"
   echo "4. Apply ruleset"
   echo "5. Backup current ruleset"
   echo "6. List current ruleset"
   echo "7. Exit"
   echo ""
   echo "Enter choice: "
   read choice

   case "$choice" in
     1)
       create_basic_ruleset
       ;;
     2)
       create_advanced_ruleset
       ;;
     3)
       create_stateful_ruleset
       ;;
     4)
       apply_ruleset
       ;;
     5)
       backup_ruleset
       ;;
     6)
       echo "Current nftables ruleset:"
       nft list ruleset
       ;;
     7)
       echo "Exiting..."
       exit 0
       ;;
     *)
       echo "Invalid choice"
       ;;
   esac
   EOF

   chmod +x nftables-config.sh
   ```

### Task 3: Application Layer Firewall Configuration

1. **Create a fail2ban configuration script**:
   ```bash
   cat > configure-fail2ban.sh << 'EOF'
   #!/bin/bash
   # Fail2ban configuration script

   # Check if running as root
   if [ "$EUID" -ne 0 ]; then
     echo "Please run as root"
     exit 1
   fi

   # Check if fail2ban is installed
   if ! command -v fail2ban-client &> /dev/null; then
     echo "fail2ban is not installed. Installing..."
     pacman -Sy --noconfirm fail2ban || {
       echo "Failed to install fail2ban"
       exit 1
     }
   fi

   # Configuration directory
   JAIL_LOCAL="/etc/fail2ban/jail.local"
   FILTER_DIR="/etc/fail2ban/filter.d"

   # Function to create basic configuration
   create_basic_config() {
     echo "Creating basic fail2ban configuration..."
     
     cat > "$JAIL_LOCAL" << 'END'
   # Fail2Ban configuration file
   [DEFAULT]
   # Ban hosts for one hour:
   bantime = 1h

   # Banning conditions
   findtime = 10m
   maxretry = 5

   # Override /etc/fail2ban/jail.d/00-firewalld.conf:
   banaction = iptables-multiport

   # Email settings (uncomment to enable)
   #mta = mail
   #destemail = your-email@example.com
   #sendername = Fail2Ban
   #action = %(action_mwl)s

   # SSH jail
   [sshd]
   enabled = true
   port = ssh
   filter = sshd
   logpath = /var/log/auth.log
   maxretry = 3
   bantime = 2h

   # HTTP/HTTPS Basic Auth
   [apache-auth]
   enabled = false
   port = http,https
   filter = apache-auth
   logpath = /var/log/apache2/error_log
   maxretry = 3

   # HTTP/HTTPS Bad Bots
   [apache-badbots]
   enabled = false
   port = http,https
   filter = apache-badbots
   logpath = /var/log/apache2/access_log
   maxretry = 2

   # Nginx HTTP Auth
   [nginx-http-auth]
   enabled = false
   port = http,https
   filter = nginx-http-auth
   logpath = /var/log/nginx/error.log
   maxretry = 3
   END
     
     echo "Basic fail2ban configuration created at $JAIL_LOCAL"
   }

   # Function to create custom filters
   create_custom_filters() {
     echo "Creating custom fail2ban filters..."
     
     # Create a custom SSH filter with additional patterns
     cat > "$FILTER_DIR/sshd-aggressive.conf" << 'END'
   # Custom SSH filter with more aggressive matching
   [INCLUDES]
   before = common.conf

   [Definition]
   _daemon = sshd

   failregex = ^%(__prefix_line)s(?:error: PAM: )?[aA]uthentication (?:failure|error) for .* from <HOST>( via \S+)?\s*$
              ^%(__prefix_line)s(?:error: PAM: )?User not known to the underlying authentication module for .* from <HOST>\s*$
              ^%(__prefix_line)sFailed \S+ for (?:invalid user )?(?P<user>\S+) from <HOST>(?: port \d+)?(?: ssh\d*)?(: (?P<pname>\S+))?\s*$
              ^%(__prefix_line)sROOT LOGIN REFUSED.* FROM <HOST>\s*$
              ^%(__prefix_line)s[iI](?:llegal|nvalid) user (?P<user>\S+)(?: from <HOST>)?\s*$
              ^%(__prefix_line)sUser \S+ from <HOST> not allowed because not listed in AllowUsers\s*$
              ^%(__prefix_line)sUser \S+ from <HOST> not allowed because listed in DenyUsers\s*$
              ^%(__prefix_line)sUser \S+ from <HOST> not allowed because not in any group\s*$
              ^%(__prefix_line)srefused connect from \S+ \(<HOST>\)\s*$
              ^%(__prefix_line)sReceived disconnect from <HOST>: 3: \S+: Auth fail\s*$
              ^%(__prefix_line)sUser \S+ from <HOST> not allowed because a group is listed in DenyGroups\s*$
              ^%(__prefix_line)sUser \S+ from <HOST> not allowed because none of user's groups are listed in AllowGroups\s*$
              ^%(__prefix_line)spam_unix\(sshd:auth\):\s+authentication failure;\s*logname=\S*\s*uid=\d*\s*euid=\d*\s*tty=\S*\s*ruser=\S*\s*rhost=<HOST>\s.*$
              ^%(__prefix_line)spam_unix\(sshd:auth\):\s+authentication failure;\s*logname=\S*\s*uid=\d*\s*euid=\d*\s*tty=\S*\s*ruser=\S*\s*rhost=<HOST>$
              ^%(__prefix_line)sConnection closed by authenticating user \S+ <HOST> port \d+ \[preauth\]\s*$
              ^%(__prefix_line)sDisconnected from authenticating user \S+ <HOST> port \d+ \[preauth\]\s*$

   ignoreregex = 
   END
     
     # Create a custom HTTP scan detection filter
     cat > "$FILTER_DIR/http-scan.conf" << 'END'
   # Detect HTTP vulnerability scanning
   [Definition]
   failregex = ^<HOST> .* "(?:GET|POST|HEAD) \/(?:admin|wp-admin|administrator|phpmyadmin|myadmin|mysql|wp-login|administrator\/index\.php).* HTTP\/.*" .*$
               ^<HOST> .* "(?:GET|POST|HEAD) .*(?:\.php|\.asp|\.jsp)(?:\?|&).*(?:union|select|insert|update|delete|drop|alter).*HTTP\/.*" .*$
               ^<HOST> .* "(?:GET|POST|HEAD) .*\.(cgi|pl|sh|py|exe|bat|cmd).*HTTP\/.*" .*$

   ignoreregex = 
   END
     
     # Create a custom brute force detection filter
     cat > "$FILTER_DIR/auth-generic.conf" << 'END'
   # Generic authentication failure detection
   [Definition]
   failregex = .*authentication failure.*rhost=<HOST>
               .*Failed password for.*from <HOST>
               .*Failed login.*from <HOST>
               .*authentication failed for.*from <HOST>

   ignoreregex = 
   END
     
     echo "Custom fail2ban filters created"
   }

   # Function to create advanced configuration
   create_advanced_config() {
     echo "Creating advanced fail2ban configuration..."
     
     cat > "$JAIL_LOCAL" << 'END'
   # Advanced Fail2Ban configuration file
   [DEFAULT]
   # Ban IP for progressively longer times on repeat offenses
   # 1 hour for first offense, 6 hours for second, 3 days for third
   bantime = 1h
   bantime.increment = true
   bantime.factor = 6
   bantime.maxtime = 72h

   # Monitor window and failure threshold
   findtime = 10m
   maxretry = 5

   # Use nftables (modern) instead of iptables
   banaction = nftables
   banaction_allports = nftables[type=allports]

   # Action for all jails
   action = %(action_)s

   # Email notification with log excerpt
   #mta = mail
   #destemail = security@example.com
   #sendername = Fail2Ban
   #action = %(action_mwl)s

   # Logging
   loglevel = INFO
   logtarget = /var/log/fail2ban.log

   # Ignoring IP addresses
   ignoreip = 127.0.0.1/8 ::1 192.168.1.0/24

   # SSH jail with aggressive filter
   [sshd]
   enabled = true
   port = ssh
   filter = sshd-aggressive
   logpath = /var/log/auth.log
   maxretry = 3
   bantime = 4h

   # SSH combined with brute force protection
   [sshd-brute]
   enabled = true
   port = ssh
   filter = sshd
   logpath = /var/log/auth.log
   maxretry = 5
   findtime = 30m
   bantime = 12h

   # HTTP Basic Auth
   [http-auth]
   enabled = false
   port = http,https
   filter = apache-auth
   logpath = /var/log/apache2/error_log /var/log/nginx/error.log
   maxretry = 3

   # Block vulnerability scanners
   [http-scan]
   enabled = false
   port = http,https
   filter = http-scan
   logpath = /var/log/apache2/access_log /var/log/nginx/access.log
   maxretry = 2
   bantime = 48h

   # Generic authentication failures
   [auth-generic]
   enabled = false
   filter = auth-generic
   logpath = /var/log/auth.log
   maxretry = 5
   bantime = 6h
   END
     
     echo "Advanced fail2ban configuration created at $JAIL_LOCAL"
   }

   # Function to apply configuration
   apply_config() {
     echo "Applying fail2ban configuration..."
     
     # Ensure fail2ban service is enabled
     systemctl enable fail2ban
     
     # Restart fail2ban to apply changes
     systemctl restart fail2ban
     
     # Check status
     echo "Fail2ban status:"
     fail2ban-client status
     
     echo "Configuration applied successfully"
   }

   # Function to test configuration
   test_config() {
     echo "Testing fail2ban configuration..."
     
     # Check if jail.local is valid
     echo "Checking jail.local syntax..."
     fail2ban-client -d | grep -A 5 "Loading configs for jail"
     
     # Test filters
     echo "Testing filters..."
     echo "Enter a filter to test (e.g., sshd, http-scan):"
     read filter
     
     if [ -f "$FILTER_DIR/$filter.conf" ]; then
       echo "Testing $filter filter..."
       fail2ban-regex /var/log/auth.log "$FILTER_DIR/$filter.conf"
     else
       echo "Filter not found: $filter"
     fi
     
     echo "Testing completed"
   }

   # Main menu
   echo "Fail2Ban Configuration Tool"
   echo "=========================="
   echo "1. Create basic configuration"
   echo "2. Create custom filters"
   echo "3. Create advanced configuration"
   echo "4. Apply configuration"
   echo "5. Test configuration"
   echo "6. Check fail2ban status"
   echo "7. Exit"
   echo ""
   echo "Enter choice: "
   read choice

   case "$choice" in
     1)
       create_basic_config
       ;;
     2)
       create_custom_filters
       ;;
     3)
       create_advanced_config
       ;;
     4)
       apply_config
       ;;
     5)
       test_config
       ;;
     6)
       echo "Fail2ban status:"
       fail2ban-client status
       ;;
     7)
       echo "Exiting..."
       exit 0
       ;;
     *)
       echo "Invalid choice"
       ;;
   esac
   EOF

   chmod +x configure-fail2ban.sh
   ```

## Exercise 3: Secure Remote Access

Create a comprehensive secure remote access solution with SSH and VPN.

### Task 1: SSH Hardening and Configuration

1. **Create an SSH hardening script**:
   ```bash
   cat > ssh-hardening.sh << 'EOF'
   #!/bin/bash
   # SSH hardening and configuration script

   # Check if running as root
   if [ "$EUID" -ne 0 ]; then
     echo "Please run as root"
     exit 1
   fi

   # SSH configuration file
   SSH_CONFIG="/etc/ssh/sshd_config"
   SSH_CONFIG_BACKUP="/etc/ssh/sshd_config.backup.$(date +%Y%m%d-%H%M%S)"

   # Create backup
   cp "$SSH_CONFIG" "$SSH_CONFIG_BACKUP"
   echo "Created backup at $SSH_CONFIG_BACKUP"

   # Function to apply basic hardening
   apply_basic_hardening() {
     echo "Applying basic SSH hardening..."
     
     # Create a new configuration based on the original
     cat "$SSH_CONFIG_BACKUP" | grep -v "^#" | grep -v "^$" > "$SSH_CONFIG.new"
     
     # Add our hardened configuration
     cat >> "$SSH_CONFIG.new" << 'END'
   # SSH Hardened Configuration - Basic Level

   # Authentication
   PermitRootLogin no
   MaxAuthTries 3
   MaxSessions 5

   # Session and login
   LoginGraceTime 30
   ClientAliveInterval 300
   ClientAliveCountMax 2

   # Features
   X11Forwarding no
   AllowAgentForwarding no
   AllowTcpForwarding yes
   PrintMotd no
   UseDNS no

   # Strict mode for user files and directories
   StrictModes yes

   # Use strong authentication methods
   PasswordAuthentication yes
   PubkeyAuthentication yes
   PermitEmptyPasswords no
   ChallengeResponseAuthentication no
   KerberosAuthentication no
   GSSAPIAuthentication no

   # Disable unused authentication
   HostbasedAuthentication no
   IgnoreRhosts yes

   # Disable user environment
   PermitUserEnvironment no

   # Banner
   Banner /etc/issue.net

   # Allow only specific users (uncomment and modify)
   #AllowUsers user1 user2
   #AllowGroups ssh-users sudo

   # Enable compression
   Compression delayed

   # Logging
   SyslogFacility AUTH
   LogLevel VERBOSE
   END
     
     # Replace the original with new configuration
     mv "$SSH_CONFIG.new" "$SSH_CONFIG"
     
     # Create a banner
     cat > /etc/issue.net << 'END'
   ***************************************************************************
   AUTHORIZED ACCESS ONLY
   
   This system is restricted to authorized users for legitimate business purposes.
   Unauthorized access is prohibited and will be prosecuted to the maximum 
   extent possible under applicable law.
   
   All connections are monitored and recorded.
   ***************************************************************************
   END
     
     echo "Basic SSH hardening applied"
   }

   # Function to apply advanced hardening
   apply_advanced_hardening() {
     echo "Applying advanced SSH hardening..."
     
     # Create a new configuration based on the original
     cat "$SSH_CONFIG_BACKUP" | grep -v "^#" | grep -v "^$" > "$SSH_CONFIG.new"
     
     # Add our hardened configuration
     cat >> "$SSH_CONFIG.new" << 'END'
   # SSH Hardened Configuration - Advanced Level

   # Protocol and Ciphers
   Protocol 2
   HostKey /etc/ssh/ssh_host_ed25519_key
   HostKey /etc/ssh/ssh_host_rsa_key
   
   # Strong ciphers and MACs
   Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
   MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com
   KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha256
   
   # Authentication
   PermitRootLogin no
   MaxAuthTries 3
   MaxSessions 3
   MaxStartups 3:50:10

   # Session and login
   LoginGraceTime 20
   ClientAliveInterval 180
   ClientAliveCountMax 2

   # Features
   X11Forwarding no
   AllowAgentForwarding no
   AllowTcpForwarding yes
   GatewayPorts no
   PermitTunnel no
   PrintLastLog yes
   PrintMotd no
   TCPKeepAlive yes
   UseDNS no
   Compression no

   # Strict mode for user files and directories
   StrictModes yes

   # Use strong authentication methods
   PasswordAuthentication no
   PubkeyAuthentication yes
   PermitEmptyPasswords no
   ChallengeResponseAuthentication no
   KerberosAuthentication no
   GSSAPIAuthentication no
   
   # Disable unused authentication
   HostbasedAuthentication no
   IgnoreRhosts yes

   # Disable user environment
   PermitUserEnvironment no

   # Banner
   Banner /etc/issue.net

   # Allow only specific users (uncomment and modify)
   #AllowUsers user1 user2 user3
   #AllowGroups ssh-users sudo wheel

   # Restrict to specific IP ranges (uncomment and modify)
   #Match Address 192.168.1.0/24
   #    PasswordAuthentication yes
   
   # Restrict user session access and sftp
   Subsystem sftp internal-sftp
   Match Group sftp-only
       ChrootDirectory /home/%u
       ForceCommand internal-sftp
       AllowTcpForwarding no
       X11Forwarding no
   
   # Two-factor authentication for admin users (if google-authenticator installed)
   #Match Group admin
   #    AuthenticationMethods publickey,keyboard-interactive

   # Logging
   SyslogFacility AUTH
   LogLevel VERBOSE
   END
     
     # Replace the original with new configuration
     mv "$SSH_CONFIG.new" "$SSH_CONFIG"
     
     # Create a stronger banner
     cat > /etc/issue.net << 'END'
   ***************************************************************************
                           AUTHORIZED ACCESS ONLY
   
   This system is restricted to authorized users with legitimate business 
   purposes only. Unauthorized access is a violation of local and international 
   laws and will be prosecuted to the maximum extent possible.
   
   All activity on this system is logged, monitored, and subject to audit. By 
   using this system, you expressly consent to such monitoring.
   
   If you are not an authorized user, DISCONNECT NOW.
   ***************************************************************************
   END
     
     # Generate new host keys with stronger algorithms
     echo "Generating new SSH host keys..."
     rm -f /etc/ssh/ssh_host_*key*
     ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ""
     ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
     
     # Set proper permissions
     chmod 600 /etc/ssh/ssh_host_*key
     chmod 644 /etc/ssh/ssh_host_*key.pub
     
     echo "Advanced SSH hardening applied"
   }

   # Function to configure key-based authentication
   setup_key_authentication() {
     echo "Setting up key-based authentication..."
     
     echo "Enter username to set up key-based auth:"
     read username
     
     if ! id "$username" &>/dev/null; then
       echo "User does not exist. Create user? (y/n)"
       read create_user
       
       if [[ "$create_user" =~ ^[
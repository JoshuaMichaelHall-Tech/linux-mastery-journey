# Month 9: Automation and Scripting

This month focuses on automating system tasks through shell scripting and other automation tools. You'll learn to create powerful scripts, implement scheduled tasks, and build repeatable processes to make your Linux system work for you.

## Time Commitment: ~10 hours/week for 4 weeks

## Learning Objectives

By the end of this month, you should be able to:

1. Create advanced shell scripts with proper error handling and logging
2. Implement automated tasks with systemd timers and cron
3. Build command-line tools with robust interfaces
4. Use configuration management principles
5. Automate common system administration tasks
6. Create reusable scripts for deployment and maintenance

## Week 1: Advanced Shell Scripting

### Core Learning Activities

1. **Shell Scripting Foundations** (2 hours)
   - Review shell script structure and best practices:
     ```bash
     #!/bin/bash
     
     # Script name: example.sh
     # Description: Example script demonstrating good structure
     # Author: Your Name
     # Date: 2025-05-15
     
     # Constants and configuration
     LOG_FILE="/var/log/myscript.log"
     CONFIG_FILE="/etc/myscript.conf"
     
     # Functions
     function log_message() {
       local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
       echo "[$timestamp] $1" >> "$LOG_FILE"
     }
     
     function display_usage() {
       echo "Usage: $0 [options] <argument>"
       echo "Options:"
       echo "  -h, --help     Display this help message"
       echo "  -v, --verbose  Enable verbose output"
       exit 1
     }
     
     # Main execution
     log_message "Script started"
     
     # Script logic here...
     
     log_message "Script completed"
     exit 0
     ```
   - Understand different shell types and compatibility:
     ```bash
     # Check current shell
     echo $SHELL
     
     # List available shells
     cat /etc/shells
     
     # Portable shebang
     #!/usr/bin/env bash
     
     # POSIX-compliant script
     #!/bin/sh
     ```
   - Learn proper code organization techniques:
     - Group related functionality into functions
     - Use meaningful variable and function names
     - Document code with comments
     - Separate configuration from logic
   - Implement consistent style and formatting:
     ```bash
     # Indentation using spaces (2 or 4 spaces)
     if [ "$condition" = true ]; then
       echo "Condition is true"
     fi
     
     # Naming conventions
     # Constants in UPPERCASE
     MAX_RETRIES=5
     
     # Variables in lowercase or camelCase
     user_name="John"
     serverCount=10
     
     # Functions in snake_case
     function check_status() {
       # Function body
     }
     ```

2. **Variables and Data Structures** (2 hours)
   - Master variable scope and naming conventions:
     ```bash
     # Global variable
     GLOBAL_VAR="This is global"
     
     function example() {
       # Local variable, only available within function
       local local_var="This is local"
       echo "$local_var and $GLOBAL_VAR"
     }
     
     # Script arguments
     echo "Script name: $0"
     echo "First argument: $1"
     echo "All arguments: $@"
     echo "Number of arguments: $#"
     ```
   - Work with arrays and associative arrays:
     ```bash
     # Indexed array
     servers=("server1" "server2" "server3")
     echo "First server: ${servers[0]}"
     echo "All servers: ${servers[@]}"
     echo "Number of servers: ${#servers[@]}"
     
     # Loop through array
     for server in "${servers[@]}"; do
       echo "Processing $server"
     done
     
     # Associative array (bash 4+)
     declare -A user_roles
     user_roles=([alice]="admin" [bob]="user" [charlie]="developer")
     echo "Alice's role: ${user_roles[alice]}"
     
     # Loop through associative array
     for user in "${!user_roles[@]}"; do
       echo "User $user has role ${user_roles[$user]}"
     done
     ```
   - Understand parameter expansion techniques:
     ```bash
     # Default value if variable is unset or null
     echo "${name:-John}"
     
     # Assign default value if variable is unset or null
     echo "${name:=John}"
     
     # String length
     echo "${#name}"
     
     # Substring extraction
     echo "${name:0:5}"  # First 5 characters
     
     # String replacement
     echo "${name/John/Jane}"  # Replace first occurrence
     echo "${name//o/O}"       # Replace all occurrences
     
     # Pattern matching
     echo "${name#*h}"  # Remove shortest match from beginning
     echo "${name##*/}" # Remove longest match from beginning
     echo "${name%/*}"  # Remove shortest match from end
     ```
   - Handle special variables effectively:
     ```bash
     # Special variables
     echo "Exit status of last command: $?"
     echo "Current process ID: $$"
     echo "Background process ID: $!"
     echo "Script flags: $-"
     
     # Saving exit status
     command
     exit_status=$?
     if [ $exit_status -ne 0 ]; then
       echo "Command failed with exit status $exit_status"
     fi
     ```

3. **Control Structures and Functions** (3 hours)
   - Implement advanced conditionals:
     ```bash
     # Extended test syntax
     if [[ "$string" == *"substring"* ]]; then
       echo "String contains substring"
     fi
     
     # Regular expressions
     if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
       echo "Valid email address"
     fi
     
     # Multiple conditions
     if [ "$age" -ge 18 ] && [ "$has_id" = true ] || [ "$has_guardian" = true ]; then
       echo "Access granted"
     fi
     
     # Case statement
     case "$option" in
       start)
         echo "Starting service"
         ;;
       stop)
         echo "Stopping service"
         ;;
       restart)
         echo "Restarting service"
         ;;
       *)
         echo "Unknown option"
         ;;
     esac
     ```
   - Create efficient loops and iteration:
     ```bash
     # For loop with range
     for i in {1..10}; do
       echo "Number: $i"
     done
     
     # C-style for loop
     for ((i=0; i<10; i++)); do
       echo "Index: $i"
     done
     
     # While loop with condition
     count=0
     while [ $count -lt 5 ]; do
       echo "Count: $count"
       ((count++))
     done
     
     # Until loop
     until [ "$response" = "yes" ]; do
       read -p "Continue? (yes/no): " response
     done
     
     # Loop with early exit
     for file in *.txt; do
       [ -f "$file" ] || continue  # Skip if not a file
       [ -r "$file" ] || break     # Exit if not readable
       echo "Processing $file"
     done
     ```
   - Design modular functions:
     ```bash
     # Function with arguments
     function greet() {
       local name="${1:-World}"
       echo "Hello, $name!"
     }
     
     # Function with named parameters
     function create_user() {
       local username=""
       local role=""
       local group=""
       
       # Parse named parameters
       while [ $# -gt 0 ]; do
         case "$1" in
           --username=*)
             username="${1#*=}"
             ;;
           --role=*)
             role="${1#*=}"
             ;;
           --group=*)
             group="${1#*=}"
             ;;
         esac
         shift
       done
       
       # Validate parameters
       [ -z "$username" ] && echo "Error: Username required" && return 1
       
       echo "Creating user $username with role $role in group $group"
     }
     
     # Call function with named parameters
     create_user --username=alice --role=admin --group=developers
     ```
   - Use recursion where appropriate:
     ```bash
     # Recursive function to calculate factorial
     function factorial() {
       local n=$1
       
       if [ $n -le 1 ]; then
         echo 1
       else
         local sub=$((n-1))
         local subfact=$(factorial $sub)
         echo $((n * subfact))
       fi
     }
     
     # Call recursive function
     result=$(factorial 5)
     echo "Factorial of 5 is $result"
     ```
   - Implement proper function return values:
     ```bash
     # Return status code
     function is_valid_user() {
       local user=$1
       id "$user" &>/dev/null
       return $?  # Return exit status of last command
     }
     
     # Call function and check return status
     if is_valid_user "alice"; then
       echo "Alice is a valid user"
     else
       echo "Alice is not a valid user"
     fi
     
     # Return value via echo/stdout
     function get_user_home() {
       local user=$1
       echo "/home/$user"
     }
     
     # Capture function output
     home_dir=$(get_user_home "alice")
     echo "Alice's home directory is $home_dir"
     ```

4. **Input/Output and File Handling** (3 hours)
   - Process command-line arguments effectively:
     ```bash
     # Manual argument processing
     if [ $# -lt 2 ]; then
       echo "Error: Not enough arguments"
       echo "Usage: $0 <source> <destination>"
       exit 1
     fi
     
     source_dir="$1"
     dest_dir="$2"
     
     # Using getopts for flags
     while getopts "hvf:" option; do
       case $option in
         h) # Display help
           display_usage
           ;;
         v) # Enable verbose mode
           verbose=true
           ;;
         f) # Specify config file
           config_file=$OPTARG
           ;;
         ?) # Invalid option
           display_usage
           ;;
       esac
     done
     
     # Shift to access positional arguments
     shift $((OPTIND-1))
     ```
   - Implement input validation:
     ```bash
     # Validate numeric input
     function validate_number() {
       local input=$1
       if [[ ! $input =~ ^[0-9]+$ ]]; then
         echo "Error: '$input' is not a valid number"
         return 1
       fi
       return 0
     }
     
     # Validate file existence
     function validate_file() {
       local file=$1
       if [ ! -f "$file" ]; then
         echo "Error: File '$file' does not exist"
         return 1
       fi
       return 0
     }
     
     # Interactive input with validation
     read -p "Enter your age: " age
     while ! validate_number "$age"; do
       read -p "Please enter a valid number for age: " age
     done
     ```
   - Handle file operations safely:
     ```bash
     # Check file existence before reading
     if [ -f "$config_file" ]; then
       source "$config_file"
     else
       echo "Config file not found, using defaults"
     fi
     
     # Create file with proper permissions
     touch "$log_file"
     chmod 600 "$log_file"
     
     # Safe file deletion
     if [ -f "$temp_file" ]; then
       rm "$temp_file"
     fi
     
     # Process files with proper quoting
     find /path -type f -name "*.log" | while read -r file; do
       process_file "$file"
     done
     ```
   - Manage standard input, output, and error:
     ```bash
     # Redirect stdout to file
     echo "Log message" > "$log_file"
     
     # Append to file
     echo "Another message" >> "$log_file"
     
     # Redirect stderr to file
     command 2> "$error_log"
     
     # Redirect both stdout and stderr
     command > "$log_file" 2> "$error_log"
     
     # Redirect stderr to stdout and then to file
     command > "$log_file" 2>&1
     
     # Discard output
     command > /dev/null 2>&1
     ```
   - Implement proper redirection techniques:
     ```bash
     # Heredoc for multi-line input
     cat << EOF > config.ini
     [General]
     LogLevel = INFO
     MaxRetries = 5
     
     [Network]
     Timeout = 30
     Port = 8080
     EOF
     
     # Process substitution
     diff <(ls dir1) <(ls dir2)
     
     # Read file line by line
     while IFS= read -r line; do
       echo "Processing: $line"
     done < "$input_file"
     
     # Redirect only if command succeeds
     command && echo "Success" > "$log_file"
     
     # Tee output to file and console
     echo "Message" | tee -a "$log_file"
     ```

### Resources

- [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/)
- [Bash Hackers Wiki](https://wiki.bash-hackers.org/)
- [Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [ShellCheck](https://www.shellcheck.net/) - Script analysis tool

## Week 2: Error Handling, Logging, and Robust Scripting

### Core Learning Activities

1. **Error Handling and Exit Codes** (3 hours)
   - Understand exit status and return codes:
     ```bash
     # Common exit codes
     # 0: Success
     # 1: General error
     # 2: Misuse of shell built-ins
     # 126: Command invoked cannot execute
     # 127: Command not found
     # 128+n: Fatal error signal "n"
     
     # Check exit status
     command
     if [ $? -ne 0 ]; then
       echo "Command failed"
       exit 1
     fi
     
     # Set custom exit code
     exit 42
     ```
   - Implement proper error checking:
     ```bash
     # Check commands in sequence
     cd "$directory" || { echo "Cannot change to directory"; exit 1; }
     
     # Function for error checking
     function check_error() {
       if [ $? -ne 0 ]; then
         echo "Error: $1"
         exit 1
       fi
     }
     
     # Usage
     cp file1 file2
     check_error "Failed to copy file"
     ```
   - Create error handling functions:
     ```bash
     # Error handler function
     function error_handler() {
       local line_no="$1"
       local error_code="$2"
       echo "Error on line $line_no with status $error_code"
       exit $error_code
     }
     
     # Set trap for errors
     trap 'error_handler ${LINENO} $?' ERR
     ```
   - Set up error traps and cleanup:
     ```bash
     # Define cleanup function
     function cleanup() {
       echo "Performing cleanup..."
       rm -f "$temp_file"
       [ -n "$pid" ] && kill $pid 2>/dev/null
     }
     
     # Set trap for script exit
     trap cleanup EXIT
     
     # Create temporary file
     temp_file=$(mktemp)
     
     # Start background process
     command &
     pid=$!
     
     # Script continues...
     ```
   - Design fail-fast scripts:
     ```bash
     # Enable strict mode
     set -euo pipefail
     
     # Explanation:
     # -e: Exit immediately if a command exits with non-zero status
     # -u: Treat unset variables as an error
     # -o pipefail: Return value of a pipeline is the status of
     #              the last command to exit with a non-zero status
     ```

2. **Logging and Debugging** (2 hours)
   - Implement comprehensive logging:
     ```bash
     # Define log function
     function log() {
       local level="$1"
       local message="$2"
       local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
       
       echo "[$timestamp] [$level] $message" | tee -a "$log_file"
     }
     
     # Usage
     log "INFO" "Script started"
     log "ERROR" "Failed to create file"
     ```
   - Create different verbosity levels:
     ```bash
     # Define verbosity levels
     declare -r LOG_LEVEL_ERROR=0
     declare -r LOG_LEVEL_WARN=1
     declare -r LOG_LEVEL_INFO=2
     declare -r LOG_LEVEL_DEBUG=3
     
     # Current verbosity level (from command line)
     verbosity=${VERBOSITY:-$LOG_LEVEL_INFO}
     
     # Enhanced log function
     function log() {
       local level="$1"
       local level_name="$2"
       local message="$3"
       
       if [ "$level" -le "$verbosity" ]; then
         local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
         echo "[$timestamp] [$level_name] $message" | tee -a "$log_file"
       fi
     }
     
     # Usage
     log $LOG_LEVEL_ERROR "ERROR" "Critical failure"
     log $LOG_LEVEL_INFO "INFO" "Operation completed"
     log $LOG_LEVEL_DEBUG "DEBUG" "Variable value: $value"
     ```
   - Add timestamps and context to logs:
     ```bash
     # Log with script name and line number
     function log() {
       local level="$1"
       local message="$2"
       local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
       local script_name=$(basename "$0")
       local line_no="${BASH_LINENO[0]}"
       
       echo "[$timestamp] [$level] [$script_name:$line_no] $message" >> "$log_file"
     }
     ```
   - Set up log rotation for script outputs:
     ```bash
     # Log rotation function
     function rotate_logs() {
       local log_file="$1"
       local max_logs="$2"
       
       # Check if log file exists and is large enough
       if [ -f "$log_file" ] && [ $(stat -c %s "$log_file") -gt 1048576 ]; then
         # Rotate logs
         for i in $(seq $((max_logs-1)) -1 1); do
           if [ -f "${log_file}.$i" ]; then
             mv "${log_file}.$i" "${log_file}.$((i+1))"
           fi
         done
         
         # Move current log to .1
         mv "$log_file" "${log_file}.1"
         
         # Create new log file
         touch "$log_file"
         chmod 600 "$log_file"
       fi
     }
     
     # Use rotation
     rotate_logs "/var/log/myscript.log" 5
     ```
   - Develop debugging techniques:
     ```bash
     # Debug mode flag
     debug_mode=false
     
     # Parse options
     while getopts "d" opt; do
       case $opt in
         d)
           debug_mode=true
           ;;
       esac
     done
     
     # Debug function
     function debug() {
       if [ "$debug_mode" = true ]; then
         echo "DEBUG: $*" >&2
       fi
     }
     
     # Enable bash debug mode conditionally
     $debug_mode && set -x
     
     # Use debug function
     debug "Processing file: $file"
     debug "Variables: a=$a, b=$b"
     
     # Disable bash debug mode if needed
     $debug_mode && set +x
     ```

3. **Security Best Practices** (2 hours)
   - Handle sensitive data safely:
     ```bash
     # Read password without echo
     read -s -p "Enter password: " password
     echo
     
     # Use environment variables cautiously
     # Avoid storing sensitive data in environment variables
     
     # Use temporary files with restricted permissions
     temp_file=$(mktemp)
     chmod 600 "$temp_file"
     echo "sensitive data" > "$temp_file"
     
     # Process data
     process_data "$temp_file"
     
     # Securely delete temporary file
     shred -u "$temp_file"
     ```
   - Validate and sanitize inputs:
     ```bash
     # Sanitize filename input
     function sanitize_filename() {
       local input="$1"
       # Replace dangerous characters
       echo "${input//[^a-zA-Z0-9._-]/}"
     }
     
     # Usage
     user_input="file name; rm -rf /"
     safe_filename=$(sanitize_filename "$user_input")
     touch "$safe_filename"
     
     # Validate paths
     function is_safe_path() {
       local path="$1"
       [[ "$path" = /* ]] && return 1  # Absolute paths not allowed
       [[ "$path" = *..* ]] && return 1  # Path traversal not allowed
       return 0
     }
     ```
   - Avoid common security pitfalls:
     ```bash
     # Avoid command injection
     # BAD:
     eval "ls $user_input"
     
     # GOOD:
     ls -- "$user_input"
     
     # Avoid temporary file race conditions
     temp_dir=$(mktemp -d)
     chmod 700 "$temp_dir"
     temp_file="$temp_dir/data"
     
     # Limit command output size
     output=$(command | head -c 1000)
     
     # Don't trust external commands
     result=$(curl -s "https://example.com/?param=$input")
     # Validate result before using it
     ```
   - Implement proper permissions:
     ```bash
     # Set umask to restrict new file permissions
     umask 077  # New files: owner=rwx, group=---, others=---
     
     # Create file with specific permissions
     install -m 600 /dev/null "$config_file"
     
     # Set permissions on script output
     touch "$output_file"
     chmod 640 "$output_file"
     
     # Run with reduced privileges
     if [ "$EUID" -eq 0 ]; then
       # Drop privileges for specific commands
       sudo -u nobody command
     fi
     ```
   - Use principle of least privilege:
     ```bash
     # Check if running as root
     if [ "$EUID" -ne 0 ]; then
       echo "This script must be run as root"
       exit 1
     fi
     
     # Drop to non-privileged user for operations
     sudo -u nobody /bin/sh << EOF
     # Perform operations with reduced privileges
     EOF
     
     # Use root only for specific operations
     function requires_root() {
       if [ "$EUID" -ne 0 ]; then
         echo "Operation requires root privileges"
         return 1
       fi
       return 0
     }
     ```

4. **Testing and Validation** (3 hours)
   - Create test cases for scripts:
     ```bash
     # Simple test function
     function test_function() {
       local test_name="$1"
       local expected="$2"
       local actual="$3"
       
       if [ "$expected" = "$actual" ]; then
         echo "PASS: $test_name"
       else
         echo "FAIL: $test_name"
         echo "  Expected: '$expected'"
         echo "  Actual:   '$actual'"
       fi
     }
     
     # Test a function
     result=$(add 2 3)
     test_function "add function" "5" "$result"
     ```
   - Implement unit testing for functions:
     ```bash
     #!/bin/bash
     # test_script.sh
     
     # Source the script to test
     source ./my_functions.sh
     
     # Test cases
     function test_add() {
       local result=$(add 2 3)
       [ "$result" -eq 5 ] || { echo "FAIL: add 2 3 = $result, expected 5"; return 1; }
       
       result=$(add -1 1)
       [ "$result" -eq 0 ] || { echo "FAIL: add -1 1 = $result, expected 0"; return 1; }
       
       echo "PASS: add function tests"
       return 0
     }
     
     function test_subtract() {
       local result=$(subtract 5 2)
       [ "$result" -eq 3 ] || { echo "FAIL: subtract 5 2 = $result, expected 3"; return 1; }
       
       echo "PASS: subtract function tests"
       return 0
     }
     
     # Run all tests
     test_add
     test_subtract
     ```
   - Validate script behavior in different environments:
     ```bash
     # Check required tools and commands
     for cmd in grep sed awk curl; do
       if ! command -v $cmd &> /dev/null; then
         echo "Error: Required command '$cmd' not found"
         exit 1
       fi
     done
     
     # Check OS compatibility
     os_name=$(uname -s)
     case "$os_name" in
       Linux)
         # Linux-specific setup
         ;;
       Darwin)
         # macOS-specific setup
         ;;
       *)
         echo "Error: Unsupported operating system: $os_name"
         exit 1
         ;;
     esac
     
     # Check bash version
     if ((BASH_VERSINFO[0] < 4)); then
       echo "Error: This script requires Bash version 4 or higher"
       exit 1
     fi
     ```
   - Set up integration testing:
     ```bash
     #!/bin/bash
     # integration_test.sh
     
     # Test setup
     echo "Setting up test environment"
     test_dir=$(mktemp -d)
     test_file="$test_dir/test_file.txt"
     
     # Create test data
     echo "Test content" > "$test_file"
     
     # Run the script being tested
     echo "Running script with test data"
     ./my_script.sh --input="$test_file" --output="$test_dir/output.txt"
     
     # Verify results
     if [ ! -f "$test_dir/output.txt" ]; then
       echo "FAIL: Output file was not created"
       exit 1
     fi
     
     if ! grep -q "Processed content" "$test_dir/output.txt"; then
       echo "FAIL: Output does not contain expected content"
       exit 1
     fi
     
     echo "PASS: Integration test"
     
     # Clean up
     rm -rf "$test_dir"
     ```
   - Create self-tests within scripts:
     ```bash
     # Add self-test option
     if [ "$1" = "--test" ]; then
       echo "Running self-tests"
       
       # Test function 1
       result=$(function1 "test input")
       [ "$result" = "expected output" ] || { echo "Test failed: function1"; exit 1; }
       
       # Test function 2
       function2 "test input"
       [ $? -eq 0 ] || { echo "Test failed: function2"; exit 1; }
       
       echo "All tests passed"
       exit 0
     fi
     ```

### Resources

- [Defensive BASH Programming](https://kfirlavi.herokuapp.com/blog/2012/11/14/defensive-bash-programming/)
- [BASH3 Boilerplate](https://github.com/kvz/bash3boilerplate)
- [Shell Script Testing Framework](https://github.com/kward/shunit2)
- [BASH Debugging Techniques](https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_02_03.html)

## Week 3: Automation with Systemd and Cron

### Core Learning Activities

1. **Systemd Timer Basics** (3 hours)
   - Understand systemd timer units vs cron:
     - Advantages of systemd timers:
       - Better logging and status tracking
       - Dependency management
       - Accuracy for missed events
       - Easier debugging
     - Cron advantages:
       - Simpler syntax
       - More portable across Linux distributions
       - Well-established
   - Create and configure timer units:
     ```bash
     # Create a simple service unit
     sudo nano /etc/systemd/system/backup.service
     
     [Unit]
     Description=Backup Service
     
     [Service]
     Type=oneshot
     ExecStart=/home/user/scripts/backup.sh
     
     [Install]
     WantedBy=multi-user.target
     ```
     
     ```bash
     # Create the timer unit
     sudo nano /etc/systemd/system/backup.timer
     
     [Unit]
     Description=Run backup daily at 2:00 AM
     
     [Timer]
     OnCalendar=*-*-* 02:00:00
     Persistent=true
     
     [Install]
     WantedBy=timers.target
     ```
   - Set up service units for tasks:
     ```bash
     # More complex service unit
     sudo nano /etc/systemd/system/web-update.service
     
     [Unit]
     Description=Update Web Content
     After=network.target
     
     [Service]
     Type=oneshot
     User=www-data
     Group=www-data
     WorkingDirectory=/var/www/html
     ExecStart=/usr/bin/git pull
     ExecStart=/usr/bin/npm install
     ExecStart=/usr/bin/npm run build
     
     [Install]
     WantedBy=multi-user.target
     ```
   - Implement calendar and monotonic timers:
     ```bash
     # Calendar timer (specific time)
     OnCalendar=Mon,Thu 17:00:00
     
     # Calendar timer (every 15 minutes)
     OnCalendar=*:0/15
     
     # Calendar timer (weekdays at 9 AM)
     OnCalendar=Mon..Fri 09:00:00
     
     # Monotonic timer (from boot time)
     OnBootSec=15min
     
     # Monotonic timer (from last execution)
     OnUnitActiveSec=1h
     ```
   - Configure randomized delays:
     ```bash
     # Add randomized delay to timer
     [Timer]
     OnCalendar=daily
     RandomizedDelaySec=30min
     
     # This will execute daily with a random delay of up to 30 minutes
     ```

2. **Advanced Cron Usage** (2 hours)
   - Master cron syntax and special strings:
     ```bash
     # Cron syntax: minute hour day month day-of-week command
     
     # Run at 2:30 AM every day
     30 2 * * * /path/to/script.sh
     
     # Run every 15 minutes
     */15 * * * * /path/to/script.sh
     
     # Run on the first day of each month at 4:45 AM
     45 4 1 * * /path/to/script.sh
     
     # Run at 6:30 PM on weekdays
     30 18 * * 1-5 /path/to/script.sh
     
     # Special strings
     @hourly   /path/to/script.sh  # Run once an hour
     @daily    /path/to/script.sh  # Run once a day (00:00)
     @weekly   /path/to/script.sh  # Run once a week (00:00 on Sunday)
     @monthly  /path/to/script.sh  # Run once a month (00:00 on first day)
     @yearly   /path/to/script.sh  # Run once a year (00:00 on Jan 1)
     @reboot   /path/to/script.sh  # Run at system startup
     ```
   - Configure user and system crontabs:
     ```bash
     # Edit user crontab
     crontab -e
     
     # Edit system crontab
     sudo crontab -e
     
     # List existing cron jobs
     crontab -l
     
     # Edit crontab for specific user
     sudo crontab -u username -e
     
     # System-wide cron directories
     sudo nano /etc/cron.daily/backup
     sudo nano /etc/cron.weekly/maintenance
     sudo chmod +x /etc/cron.daily/backup
     ```
   - Implement environment setup for cron jobs:
     ```bash
     # Set environment variables in crontab
     PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
     SHELL=/bin/bash
     MAILTO=user@example.com
     
     # Run job with full environment setup
     0 2 * * * . $HOME/.profile; /path/to/script.sh
     
     # Create wrapper script for complex environment
     cat > /usr/local/bin/cron-wrapper << 'EOF'
     #!/bin/bash
     # Load environment
     if [ -f "$HOME/.bash_profile" ]; then
       . "$HOME/.bash_profile"
     elif [ -f "$HOME/.profile" ]; then
       . "$HOME/.profile"
     fi
     
     # Execute the command
     exec "$@"
     EOF
     chmod +x /usr/local/bin/cron-wrapper
     
     # Use wrapper in crontab
     0 2 * * * /usr/local/bin/cron-wrapper /path/to/script.sh
     ```
   - Manage cron output and notifications:
     ```bash
     # Redirect stdout and stderr to a file
     0 2 * * * /path/to/script.sh > /var/log/script.log 2>&1
     
     # Append to log file
     0 2 * * * /path/to/script.sh >> /var/log/script.log 2>&1
     
     # Discard output
     0 2 * * * /path/to/script.sh > /dev/null 2>&1
     
     # Send output via email (default behavior)
     0 2 * * * /path/to/script.sh
     
     # Send notification but not output
     0 2 * * * /path/to/script.sh > /dev/null || echo "Script failed" | mail -s "Cron job failed" user@example.com
     ```
   - Understand anacron for missed jobs:
     ```bash
     # Install anacron
     sudo pacman -S anacron
     
     # Edit anacrontab
     sudo nano /etc/anacrontab
     
     # Format: period delay job-id command
     # period: frequency in days
     # delay: delay in minutes
     # job-id: unique identifier
     
     # Example: run backup daily with 5-minute delay
     1   5   daily-backup   /path/to/backup.sh
     
     # Example: run cleanup weekly with 10-minute delay
     7   10  weekly-cleanup /path/to/cleanup.sh
     ```

3. **Job Scheduling Best Practices** (2 hours)
   - Balance system load with proper scheduling:
     ```bash
     # Distribute jobs throughout the day
     0 2 * * * /path/to/backup.sh      # 2:00 AM
     0 4 * * * /path/to/cleanup.sh     # 4:00 AM
     30 6 * * * /path/to/report.sh     # 6:30 AM
     
     # Schedule resource-intensive jobs during off-hours
     0 1 * * 0 /path/to/heavy-task.sh  # 1:00 AM on Sundays
     
     # Stagger similar jobs
     0 3 * * * /path/to/job1.sh
     15 3 * * * /path/to/job2.sh
     30 3 * * * /path/to/job3.sh
     ```
   - Handle overlapping job execution:
     ```bash
     #!/bin/bash
     # Lock file to prevent concurrent runs
     LOCK_FILE="/tmp/script.lock"
     
     # Check if lock file exists
     if [ -e "$LOCK_FILE" ]; then
       pid=$(cat "$LOCK_FILE")
       if ps -p $pid > /dev/null; then
         echo "Script is already running with PID $pid"
         exit 1
       else
         echo "Removing stale lock file"
         rm "$LOCK_FILE"
       fi
     fi
     
     # Create lock file with current PID
     echo $ > "$LOCK_FILE"
     
     # Clean up lock file on exit
     trap 'rm -f "$LOCK_FILE"' EXIT
     
     # Script logic here...
     ```
   - Implement locking mechanisms:
     ```bash
     # Using flock for file locking
     (
       flock -n 200 || { echo "Cannot acquire lock"; exit 1; }
       
       # Critical section - only one instance will execute this
       echo "Running exclusive task"
       sleep 10
       
     ) 200>/var/lock/myapp.lock
     
     # Alternative with timeout
     flock --timeout 10 /var/lock/myapp.lock /path/to/script.sh
     ```
   - Set up job dependencies:
     ```bash
     # Systemd service dependencies
     [Unit]
     Description=Database Backup
     After=postgresql.service
     Requires=postgresql.service
     
     # Chained cron jobs
     0 1 * * * /path/to/backup.sh && /path/to/sync.sh
     
     # Job orchestration script
     #!/bin/bash
     # First job
     /path/to/job1.sh
     if [ $? -ne 0 ]; then
       echo "Job 1 failed, aborting sequence"
       exit 1
     fi
     
     # Second job
     /path/to/job2.sh
     if [ $? -ne 0 ]; then
       echo "Job 2 failed, aborting sequence"
       exit 1
     fi
     
     # Final job
     /path/to/job3.sh
     ```
   - Monitor scheduled job execution:
     ```bash
     # Create job with logging
     #!/bin/bash
     LOG_FILE="/var/log/jobs/myjob.log"
     
     # Log start time
     echo "$(date): Job started" >> "$LOG_FILE"
     
     # Record output and errors
     {
       # Run the actual job
       /path/to/actual/script.sh
       exit_code=$?
       
       # Log completion status
       if [ $exit_code -eq 0 ]; then
         echo "$(date): Job completed successfully" >> "$LOG_FILE"
       else
         echo "$(date): Job failed with exit code $exit_code" >> "$LOG_FILE"
       fi
       
       exit $exit_code
     } 2>> "$LOG_FILE"
     ```

4. **Automation Monitoring and Alerting** (3 hours)
   - Configure execution failure notifications:
     ```bash
     #!/bin/bash
     # Email settings
     ADMIN_EMAIL="admin@example.com"
     FROM_EMAIL="automation@example.com"
     
     # Run the command
     /path/to/important/script.sh
     exit_code=$?
     
     # Send notification if command fails
     if [ $exit_code -ne 0 ]; then
       echo "Script failed with exit code $exit_code" | \
         mail -s "Automation Alert: Script Failure" \
         -r "$FROM_EMAIL" "$ADMIN_EMAIL"
     fi
     ```
   - Implement job status monitoring:
     ```bash
     # Status file approach
     STATUS_DIR="/var/status/jobs"
     mkdir -p "$STATUS_DIR"
     
     # Update job status
     function update_status() {
       local job_name="$1"
       local status="$2"
       local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
       echo "$timestamp $status" > "$STATUS_DIR/$job_name"
     }
     
     # Usage in jobs
     update_status "daily-backup" "STARTED"
     
     # Run job
     /path/to/backup.sh
     if [ $? -eq 0 ]; then
       update_status "daily-backup" "SUCCESS"
     else
       update_status "daily-backup" "FAILED"
     fi
     
     # Monitor script
     #!/bin/bash
     for status_file in "$STATUS_DIR"/*; do
       job_name=$(basename "$status_file")
       status=$(tail -1 "$status_file" | awk '{print $NF}')
       timestamp=$(tail -1 "$status_file" | cut -d' ' -f1,2)
       
       echo "Job: $job_name, Status: $status, Last update: $timestamp"
     done
     ```
   - Create dashboard for automation tasks:
     ```bash
     #!/bin/bash
     # Simple HTML dashboard generator
     
     HTML_FILE="/var/www/html/jobs/dashboard.html"
     
     # Create HTML header
     cat > "$HTML_FILE" << EOF
     <!DOCTYPE html>
     <html>
     <head>
       <title>Automation Dashboard</title>
       <style>
         table { border-collapse: collapse; width: 100%; }
         th, td { padding: 8px; text-align: left; border-bottom: 1px solid #ddd; }
         tr.success { background-color: #d4edda; }
         tr.failure { background-color: #f8d7da; }
         tr.running { background-color: #cce5ff; }
       </style>
     </head>
     <body>
       <h1>Automation Dashboard</h1>
       <p>Last updated: $(date)</p>
       <table>
         <tr>
           <th>Job Name</th>
           <th>Status</th>
           <th>Last Run</th>
           <th>Duration</th>
         </tr>
     EOF
     
     # Add job data
     for status_file in /var/status/jobs/*; do
       job_name=$(basename "$status_file")
       status=$(tail -1 "$status_file" | awk '{print $NF}')
       timestamp=$(tail -1 "$status_file" | cut -d' ' -f1,2)
       
       # Determine CSS class based on status
       css_class=""
       case "$status" in
         SUCCESS) css_class="success" ;;
         FAILED)  css_class="failure" ;;
         STARTED) css_class="running" ;;
       esac
       
       # Add table row
       cat >> "$HTML_FILE" << EOF
       <tr class="$css_class">
         <td>$job_name</td>
         <td>$status</td>
         <td>$timestamp</td>
         <td>unknown</td>
       </tr>
     EOF
     done
     
     # Add HTML footer
     cat >> "$HTML_FILE" << EOF
       </table>
     </body>
     </html>
     EOF
     ```
   - Design escalation procedures:
     ```bash
     #!/bin/bash
     # Escalation levels script
     
     # Configuration
     LEVEL1_EMAIL="operator@example.com"
     LEVEL2_EMAIL="manager@example.com"
     LEVEL3_EMAIL="director@example.com"
     MAX_RETRIES=3
     
     # Status file
     STATUS_FILE="/var/status/critical-job.txt"
     
     # Get current failure count
     if [ -f "$STATUS_FILE" ]; then
       failures=$(cat "$STATUS_FILE")
     else
       failures=0
     fi
     
     # Run the job
     /path/to/critical/job.sh
     exit_code=$?
     
     if [ $exit_code -eq 0 ]; then
       # Success - reset failure count
       echo "0" > "$STATUS_FILE"
       exit 0
     else
       # Failure - increment count
       failures=$((failures + 1))
       echo "$failures" > "$STATUS_FILE"
       
       # Determine escalation level
       message="Critical job failed (attempt $failures of $MAX_RETRIES)"
       
       if [ $failures -eq 1 ]; then
         # Level 1 escalation
         echo "$message" | mail -s "ALERT: Critical Job Failure" "$LEVEL1_EMAIL"
       elif [ $failures -eq 2 ]; then
         # Level 2 escalation
         echo "$message" | mail -s "URGENT: Critical Job Failure" "$LEVEL1_EMAIL,$LEVEL2_EMAIL"
       elif [ $failures -ge 3 ]; then
         # Level 3 escalation
         echo "$message" | mail -s "CRITICAL: Job Failure Escalation" "$LEVEL1_EMAIL,$LEVEL2_EMAIL,$LEVEL3_EMAIL"
       fi
       
       exit $exit_code
     fi
     ```

### Resources

- [ArchWiki - Systemd/Timers](https://wiki.archlinux.org/title/Systemd/Timers)
- [Cron Tutorial](https://www.digitalocean.com/community/tutorials/how-to-use-cron-to-automate-tasks-on-a-vps)
- [Linux Journal - Moving from Cron to Systemd Timers](https://www.linuxjournal.com/content/replacing-cron-systemd)
- [Flock for Script Locking](https://linuxaria.com/howto/linux-shell-introduction-to-flock)

## Week 4: Building Command-Line Tools and Integration

### Core Learning Activities

1. **Command-Line Interface Design** (3 hours)
   - Design user-friendly CLI interfaces:
     ```bash
     #!/bin/bash
     # Example CLI tool structure
     
     # Script name and version
     SCRIPT_NAME="$(basename "$0")"
     VERSION="1.0.0"
     
     # Default values
     verbose=false
     output_file=""
     mode="default"
     
     # Display usage information
     function usage() {
       cat << EOF
     Usage: $SCRIPT_NAME [OPTIONS] <input-file>
     
     A tool for processing input files.
     
     Options:
       -h, --help         Display this help message
       -v, --verbose      Enable verbose output
       -o, --output FILE  Write output to FILE
       -m, --mode MODE    Set processing mode (default|fast|thorough)
       --version          Display version information
     
     Examples:
       $SCRIPT_NAME input.txt
       $SCRIPT_NAME --verbose --output result.txt input.txt
       $SCRIPT_NAME --mode=thorough input.txt
     
     EOF
     }
     
     # Display version
     function show_version() {
       echo "$SCRIPT_NAME version $VERSION"
     }
     
     # Parse command line arguments
     while [[ $# -gt 0 ]]; do
       case "$1" in
         -h|--help)
           usage
           exit 0
           ;;
         -v|--verbose)
           verbose=true
           shift
           ;;
         -o|--output)
           output_file="$2"
           shift 2
           ;;
         --output=*)
           output_file="${1#*=}"
           shift
           ;;
         -m|--mode)
           mode="$2"
           shift 2
           ;;
         --mode=*)
           mode="${1#*=}"
           shift
           ;;
         --version)
           show_version
           exit 0
           ;;
         -*)
           echo "Error: Unknown option $1" >&2
           usage >&2
           exit 1
           ;;
         *)
           # Assume it's the input file
           input_file="$1"
           shift
           ;;
       esac
     done
     
     # Validate arguments
     if [ -z "$input_file" ]; then
       echo "Error: Input file is required" >&2
       usage >&2
       exit 1
     fi
     
     # Check if input file exists
     if [ ! -f "$input_file" ]; then
       echo "Error: Input file '$input_file' does not exist" >&2
       exit 1
     fi
     
     # Validate mode
     valid_modes=("default" "fast" "thorough")
     if [[ ! " ${valid_modes[*]} " =~ " ${mode} " ]]; then
       echo "Error: Invalid mode '$mode'" >&2
       echo "Valid modes: ${valid_modes[*]}" >&2
       exit 1
     fi
     
     # Display configuration if verbose
     if [ "$verbose" = true ]; then
       echo "Configuration:"
       echo "  Input file: $input_file"
       echo "  Output file: ${output_file:-stdout}"
       echo "  Mode: $mode"
       echo "  Verbose: $verbose"
     fi
     
     # Process the file
     echo "Processing $input_file in $mode mode..."
     
     # (Actual processing logic here)
     
     # Output results
     if [ -n "$output_file" ]; then
       echo "Results written to $output_file"
     else
       echo "Results:"
       # (Display results on stdout)
     fi
     ```
   - Implement argument parsing with getopts:
     ```bash
     #!/bin/bash
     # Simpler argument parsing with getopts
     
     # Default values
     verbose=false
     output_file=""
     
     # Display usage
     function usage() {
       echo "Usage: $(basename $0) [-v] [-o FILE] input_file"
       echo
       echo "Options:"
       echo "  -v          Enable verbose mode"
       echo "  -o FILE     Write output to FILE"
       echo "  -h          Display this help message"
     }
     
     # Parse options
     while getopts ":hvo:" opt; do
       case ${opt} in
         h )
           usage
           exit 0
           ;;
         v )
           verbose=true
           ;;
         o )
           output_file=$OPTARG
           ;;
         \? )
           echo "Invalid option: $OPTARG" 1>&2
           usage
           exit 1
           ;;
         : )
           echo "Invalid option: $OPTARG requires an argument" 1>&2
           usage
           exit 1
           ;;
       esac
     done
     
     # Shift to access non-option arguments
     shift $((OPTIND -1))
     
     # Check for input file
     if [ $# -eq 0 ]; then
       echo "Error: Input file is required" 1>&2
       usage
       exit 1
     fi
     
     input_file=$1
     
     # Process the file
     # ...
     ```
   - Create self-documenting scripts:
     ```bash
     #!/bin/bash
     # Script with embedded documentation
     
     # Function to extract and display embedded documentation
     function show_docs() {
       sed -n '/^#:/s/^#://p' "$0" | sed 's/^/ /'
     }
     
     # Check if --help was requested
     if [ "$1" = "--help" ]; then
       show_docs
       exit 0
     fi
     
     #: NAME
     #:     example.sh - Example script with embedded documentation
     #:
     #: SYNOPSIS
     #:     example.sh [OPTIONS] <input-file>
     #:
     #: DESCRIPTION
     #:     This script demonstrates embedded documentation that can
     #:     be extracted and displayed when requested.
     #:
     #: OPTIONS
     #:     --help     Display this help message
     #:     --version  Display version information
     #:
     #: EXAMPLES
     #:     example.sh input.txt
     #:     example.sh --help
     
     # Script logic here
     # ...
     ```
   - Add help and version information:
     ```bash
     #!/bin/bash
     # Script metadata
     SCRIPT_NAME="backup-tool"
     VERSION="1.2.3"
     AUTHOR="Your Name"
     
     # Help function
     function show_help() {
       cat << EOF
     $SCRIPT_NAME $VERSION
     
     A tool for creating and managing backups.
     
     Usage: $SCRIPT_NAME [OPTIONS] COMMAND
     
     Commands:
       create     Create a new backup
       restore    Restore from backup
       list       List available backups
       verify     Verify backup integrity
     
     Options:
       -h, --help     Show this help message
       -v, --verbose  Enable verbose mode
       --version      Show version information
     
     For more information, see: https://example.com/docs
     
     EOF
     }
     
     # Version function
     function show_version() {
       cat << EOF
     $SCRIPT_NAME $VERSION
     
     Copyright (C) $(date +%Y) $AUTHOR
     License: MIT
     
     EOF
     }
     
     # Parse command line
     if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
       show_help
       exit 0
     elif [ "$1" = "--version" ]; then
       show_version
       exit 0
     fi
     
     # Rest of script
     # ...
     ```
   - Design consistent output formats:
     ```bash
     #!/bin/bash
     # Output formatting functions
     
     # Text formatting
     bold=$(tput bold)
     normal=$(tput sgr0)
     red=$(tput setaf 1)
     green=$(tput setaf 2)
     yellow=$(tput setaf 3)
     
     # Output functions
     function info() {
       echo "${bold}[INFO]${normal} $*"
     }
     
     function warn() {
       echo "${yellow}[WARN]${normal} $*" >&2
     }
     
     function error() {
       echo "${red}[ERROR]${normal} $*" >&2
     }
     
     function success() {
       echo "${green}[SUCCESS]${normal} $*"
     }
     
     # Progress indicator
     function show_progress() {
       local percent=$1
       local width=50
       local num_filled=$(( width * percent / 100 ))
       local num_empty=$(( width - num_filled ))
       
       # Create the progress bar
       printf "["
       printf "%${num_filled}s" | tr ' ' '#'
       printf "%${num_empty}s" | tr ' ' ' '
       printf "] %3d%%\r" $percent
     }
     
     # Machine-parseable output
     function output_json() {
       local status=$1
       local message=$2
       local data=$3
       
       cat << EOF
     {
       "status": "$status",
       "message": "$message",
       "data": $data,
       "timestamp": "$(date -Iseconds)"
     }
     EOF
     }
     
     # Usage examples
     info "Starting backup process"
     warn "Disk space is low"
     error "Failed to create backup"
     success "Backup completed successfully"
     
     # Show progress
     for i in $(seq 0 5 100); do
       show_progress $i
       sleep 0.1
     done
     echo
     
     # Output structured data
     output_json "success" "Operation completed" '{"files": 42, "size": "1.2GB"}'
     ```

2. **Integration with Other Tools** (3 hours)
   - Create scripts that work in pipelines:
     ```bash
     #!/bin/bash
     # filter-logs.sh
     # Filter log entries by severity
     
     # Check if input is from a pipe or redirect
     if [ -t 0 ]; then
       echo "Error: No input provided" >&2
       echo "Usage: cat logfile.log | $(basename $0) [INFO|WARN|ERROR]" >&2
       exit 1
     fi
     
     # Default to ERROR if no argument
     severity=${1:-ERROR}
     
     # Process input line by line
     while IFS= read -r line; do
       if [[ "$line" == *"[$severity]"* ]]; then
         echo "$line"
       fi
     done
     
     # Usage: 
     # cat app.log | ./filter-logs.sh WARN
     ```
   - Design for composability:
     ```bash
     #!/bin/bash
     # count-errors.sh
     # Count errors by type in a log file
     
     # Check if filename is provided
     if [ $# -ne 1 ]; then
       echo "Usage: $(basename $0) <logfile>" >&2
       exit 1
     fi
     
     logfile="$1"
     
     # Extract error types and count occurrences
     grep -i "error" "$logfile" | \
       sed -E 's/.*Error: ([^:]+):.*/\1/' | \
       sort | \
       uniq -c | \
       sort -nr
     
     # This can be combined with other tools:
     # ./count-errors.sh app.log | head -5
     # ./count-errors.sh app.log | grep "Database" | mail -s "DB Errors" admin@example.com
     ```
   - Implement proper exit codes for chaining:
     ```bash
     #!/bin/bash
     # validate-config.sh
     # Validate configuration file
     
     # Exit codes
     SUCCESS=0
     SYNTAX_ERROR=1
     MISSING_REQUIRED=2
     INVALID_VALUE=3
     
     # Check if filename is provided
     if [ $# -ne 1 ]; then
       echo "Usage: $(basename $0) <config-file>" >&2
       exit 1
     fi
     
     config_file="$1"
     
     # Check file existence
     if [ ! -f "$config_file" ]; then
       echo "Error: Config file not found: $config_file" >&2
       exit 1
     fi
     
     # Check syntax
     if ! grep -q "^VERSION=" "$config_file"; then
       echo "Error: Missing VERSION in config file" >&2
       exit $MISSING_REQUIRED
     fi
     
     # Validate values
     if grep -q "^DEBUG=[^01]" "$config_file"; then
       echo "Error: DEBUG must be 0 or 1" >&2
       exit $INVALID_VALUE
     fi
     
     # All checks passed
     echo "Configuration file is valid"
     exit $SUCCESS
     
     # Usage in a chain:
     # ./validate-config.sh app.conf && ./start-app.sh app.conf || echo "Failed to start app"
     ```
   - Use temporary files safely:
     ```bash
     #!/bin/bash
     # safe-temp.sh
     # Safely handle temporary files
     
     # Create secure temporary directory
     temp_dir=$(mktemp -d)
     if [ ! -d "$temp_dir" ]; then
       echo "Error: Failed to create temporary directory" >&2
       exit 1
     fi
     
     # Set permissions
     chmod 700 "$temp_dir"
     
     # Create temporary files
     temp_file1="$temp_dir/data1.tmp"
     temp_file2="$temp_dir/data2.tmp"
     
     # Clean up on exit
     function cleanup() {
       rm -rf "$temp_dir"
     }
     
     # Register cleanup function
     trap cleanup EXIT
     
     # Use temporary files
     echo "Data 1" > "$temp_file1"
     echo "Data 2" > "$temp_file2"
     
     # Process files
     cat "$temp_file1" "$temp_file2" | sort
     
     # Cleanup happens automatically when script exits
     ```
   - Handle signals properly:
     ```bash
     #!/bin/bash
     # signal-handler.sh
     # Proper signal handling
     
     # Variables for state
     pid_file="/var/run/myapp.pid"
     running=true
     
     # Signal handlers
     function handle_sigint() {
       echo "Received SIGINT, shutting down gracefully..."
       running=false
     }
     
     function handle_sigterm() {
       echo "Received SIGTERM, shutting down gracefully..."
       running=false
     }
     
     function cleanup() {
       echo "Cleaning up..."
       rm -f "$pid_file"
       echo "Done"
     }
     
     # Register signal handlers
     trap handle_sigint SIGINT
     trap handle_sigterm SIGTERM
     trap cleanup EXIT
     
     # Create PID file
     echo $ > "$pid_file"
     
     # Main loop
     echo "Started. PID: $"
     echo "Press Ctrl+C to exit"
     
     counter=0
     while $running; do
       echo "Working... (iteration $counter)"
       counter=$((counter + 1))
       sleep 1
     done
     
     echo "Exiting normally"
     exit 0
     ```

3. **Building an Automation Framework** (2 hours)
   - Create a library of reusable functions:
     ```bash
     #!/bin/bash
     # lib/common.sh
     # Common utility functions
     
     # Error handling
     function die() {
       echo "ERROR: $*" >&2
       exit 1
     }
     
     # Logging with timestamp and level
     function log() {
       local level="$1"
       shift
       local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
       echo "[$timestamp] [$level] $*"
     }
     
     function log_info() {
       log "INFO" "$@"
     }
     
     function log_warn() {
       log "WARN" "$@" >&2
     }
     
     function log_error() {
       log "ERROR" "$@" >&2
     }
     
     # Check if command exists
     function command_exists() {
       command -v "$1" >/dev/null 2>&1
     }
     
     # Require command or exit
     function require_command() {
       local cmd="$1"
       local package="${2:-$1}"
       
       if ! command_exists "$cmd"; then
         die "Required command '$cmd' not found. Please install $package."
       fi
     }
     
     # Safe temporary directory
     function make_temp_dir() {
       local dir=$(mktemp -d)
       chmod 700 "$dir"
       echo "$dir"
     }
     
     # Confirm action
     function confirm() {
       local prompt="${1:-Are you sure?}"
       local response
       
       read -p "$prompt [y/N] " response
       [[ "$response" =~ ^[Yy] ]]
       return $?
     }
     
     # Run command with timeout
     function run_with_timeout() {
       local timeout="$1"
       shift
       
       # Run command in background
       "$@" &
       local pid=$!
       
       # Wait for timeout
       local count=0
       while [ $count -lt $timeout ] && kill -0 $pid 2>/dev/null; do
         sleep 1
         count=$((count + 1))
       done
       
       # Check if still running
       if kill -0 $pid 2>/dev/null; then
         kill $pid
         wait $pid 2>/dev/null
         return 124  # Timeout
       fi
       
       wait $pid
       return $?
     }
     ```
   - Implement consistent logging and error handling:
     ```bash
     #!/bin/bash
     # Example script using the framework
     
     # Load common library
     source "$(dirname "$0")/lib/common.sh"
     
     # Script configuration
     config_file="${1:-config.ini}"
     
     # Check requirements
     require_command "curl" "curl"
     require_command "jq" "jq"
     
     # Log start
     log_info "Starting script with config: $config_file"
     
     # Check config file
     if [ ! -f "$config_file" ]; then
       log_error "Config file not found: $config_file"
       exit 1
     fi
     
     # Create temporary directory
     temp_dir=$(make_temp_dir)
     log_info "Created temporary directory: $temp_dir"
     
     # Clean up on exit
     trap 'rm -rf "$temp_dir"' EXIT
     
     # Main logic
     log_info "Fetching data..."
     if ! curl -s "https://api.example.com/data" > "$temp_dir/data.json"; then
       log_error "Failed to fetch data"
       exit 1
     fi
     
     # Process data
     if ! jq '.items[]' "$temp_dir/data.json" > "$temp_dir/processed.json"; then
       log_error "Failed to process data"
       exit 1
     fi
     
     log_info "Processed $(jq length "$temp_dir/processed.json") items"
     
     # Ask for confirmation before proceeding
     if confirm "Do you want to continue?"; then
       log_info "Proceeding with operation"
     else
       log_warn "Operation aborted by user"
       exit 0
     fi
     
     # Run with timeout
     log_info "Running time-sensitive operation..."
     if ! run_with_timeout 30 "./long-running-task.sh"; then
       log_error "Operation timed out"
       exit 1
     fi
     
     log_info "Script completed successfully"
     exit 0
     ```
   - Design configuration management:
     ```bash
     #!/bin/bash
     # config.sh
     # Configuration management
     
     # Default configuration
     config_file="/etc/myapp/config.ini"
     config_defaults=(
       "DEBUG=0"
       "VERBOSE=0"
       "MAX_RETRIES=3"
       "TIMEOUT=30"
       "LOG_LEVEL=INFO"
     )
     
     # Load configuration
     function load_config() {
       local config_file="$1"
       local temp_file
       
       # Check if config file exists
       if [ ! -f "$config_file" ]; then
         echo "Warning: Config file not found, using defaults: $config_file" >&2
         temp_file=$(mktemp)
         printf "%s\n" "${config_defaults[@]}" > "$temp_file"
       else
         temp_file=$(mktemp)
         cat "$config_file" > "$temp_file"
         
         # Add missing defaults
         for default in "${config_defaults[@]}"; do
           key="${default%%=*}"
           if ! grep -q "^$key=" "$temp_file"; then
             echo "$default" >> "$temp_file"
             echo "Warning: Added missing default: $default" >&2
           fi
         done
       fi
       
       # Source the config
       source "$temp_file"
       rm "$temp_file"
     }
     
     # Save configuration
     function save_config() {
       local config_file="$1"
       local temp_file=$(mktemp)
       
       # Create config content
       for key in DEBUG VERBOSE MAX_RETRIES TIMEOUT LOG_LEVEL; do
         value="${!key}"
         echo "$key=$value" >> "$temp_file"
       done
       
       # Create directory if needed
       mkdir -p "$(dirname "$config_file")"
       
       # Move temp file to config file
       mv "$temp_file" "$config_file"
       chmod 644 "$config_file"
     }
     
     # Get config value
     function get_config() {
       local key="$1"
       local default="$2"
       
       value="${!key}"
       if [ -z "$value" ] && [ -n "$default" ]; then
         value="$default"
       fi
       
       echo "$value"
     }
     
     # Set config value
     function set_config() {
       local key="$1"
       local value="$2"
       
       # Validate key
       if ! [[ " DEBUG VERBOSE MAX_RETRIES TIMEOUT LOG_LEVEL " =~ " $key " ]]; then
         echo "Error: Invalid configuration key: $key" >&2
         return 1
       fi
       
       # Set value in environment
       export "$key=$value"
     }
     
     # Example usage
     load_config "$config_file"
     
     echo "Current configuration:"
     echo "DEBUG = $(get_config DEBUG)"
     echo "VERBOSE = $(get_config VERBOSE)"
     echo "MAX_RETRIES = $(get_config MAX_RETRIES 5)"  # Default if not set
     
     # Update configuration
     set_config "DEBUG" "1"
     set_config "TIMEOUT" "60"
     
     # Save updated configuration
     save_config "$config_file"
     ```
   - Build a task framework:
     ```bash
     #!/bin/bash
     # task-framework.sh
     # Simple task execution framework
     
     # Task directory
     TASK_DIR="$(dirname "$0")/tasks"
     
     # Available tasks
     function list_tasks() {
       echo "Available tasks:"
       for task_file in "$TASK_DIR"/*.sh; do
         task_name=$(basename "$task_file" .sh)
         task_description=$(grep "^# Description:" "$task_file" | cut -d: -f2- | sed 's/^ *//')
         printf "  %-15s %s\n" "$task_name" "$task_description"
       done
     }
     
     # Run task with arguments
     function run_task() {
       local task_name="$1"
       shift
       
       local task_file="$TASK_DIR/$task_name.sh"
       
       if [ ! -f "$task_file" ]; then
         echo "Error: Task not found: $task_name" >&2
         list_tasks
         return 1
       fi
       
       echo "Running task: $task_name"
       bash "$task_file" "$@"
       local status=$?
       
       if [ $status -eq 0 ]; then
         echo "Task completed successfully: $task_name"
       else
         echo "Task failed with status $status: $task_name" >&2
       fi
       
       return $status
     }
     
     # Main function
     function main() {
       if [ $# -eq 0 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
         echo "Usage: $(basename "$0") TASK [OPTIONS]"
         echo
         list_tasks
         exit 0
       fi
       
       local task_name="$1"
       shift
       
       run_task "$task_name" "$@"
       exit $?
     }
     
     # Run main function
     main "$@"
     ```
   - Structure for maintainability:
     ```
     project-structure/
     ├── bin/
     │   ├── app-cli        # Main command-line interface
     │   └── app-daemon     # Service daemon script
     ├── lib/
     │   ├── common.sh      # Common utility functions
     │   ├── config.sh      # Configuration management
     │   ├── logging.sh     # Logging utilities
     │   └── database.sh    # Database functions
     ├── tasks/
     │   ├── backup.sh      # Backup task
     │   ├── cleanup.sh     # Cleanup task
     │   └── deploy.sh      # Deployment task
     ├── tests/
     │   ├── test-common.sh # Unit tests for common functions
     │   └── test-config.sh # Unit tests for configuration
     ├── config/
     │   └── app.conf.dist  # Example configuration
     ├── docs/
     │   ├── cli.md         # CLI documentation
     │   └── tasks.md       # Task documentation
     ├── install.sh         # Installation script
     └── README.md          # Project documentation
     ```

4. **Documentation and Distribution** (2 hours)
   - Create man pages for scripts:
     ```bash
     #!/bin/bash
     # generate-man.sh
     # Generate man page from script
     
     if [ $# -ne 1 ]; then
       echo "Usage: $(basename $0) <script-file>" >&2
       exit 1
     fi
     
     script_file="$1"
     script_name=$(basename "$script_file")
     
     # Extract metadata
     title=$(grep "^# Title:" "$script_file" | cut -d: -f2- | sed 's/^ *//')
     version=$(grep "^# Version:" "$script_file" | cut -d: -f2- | sed 's/^ *//')
     date=$(date +"%B %Y")
     description=$(grep "^# Description:" "$script_file" | cut -d: -f2- | sed 's/^ *//')
     author=$(grep "^# Author:" "$script_file" | cut -d: -f2- | sed 's/^ *//')
     
     # Create man page content
     cat << EOF > "$script_name.1"
     .TH "$(echo $script_name | tr '[:lower:]' '[:upper:]')" 1 "$date" "$version" "$title"
     
     .SH NAME
     $script_name \\- $description
     
     .SH SYNOPSIS
     .B $script_name
     [\fIOPTIONS\fR]
     [\fIARGUMENTS\fR]
     
     .SH DESCRIPTION
     $(grep "^# Description-long:" "$script_file" | cut -d: -f2- | sed 's/^ *//')
     
     .SH OPTIONS
     $(grep "^# Option:" "$script_file" | sed 's/^# Option: //' | sed 's/^\(.*\) - \(.*\)$/.IP "\\1" 4\\n\\2/')
     
     .SH EXAMPLES
     $(grep "^# Example:" "$script_file" | sed 's/^# Example: //' | sed 's/^\(.*\)$/.IP\\n\\1/')
     
     .SH AUTHOR
     $author
     
     .SH SEE ALSO
     $(grep "^# See-also:" "$script_file" | cut -d: -f2- | sed 's/^ *//')
     EOF
     
     echo "Man page generated: $script_name.1"
     
     # Install man page
     sudo install -m 644 "$script_name.1" "/usr/local/share/man/man1/"
     sudo mandb
     
     echo "Man page installed. Use 'man $script_name' to view."
     ```
   - Implement --help output:
     ```bash
     #!/bin/bash
     # example-script.sh
     # Title: Example Script
     # Version: 1.0.0
     # Description: An example script with good documentation
     # Description-long: This script demonstrates how to implement good documentation practices, including help output, man pages, and usage information.
     # Author: Your Name <your.email@example.com>
     # See-also: related-script(1), another-tool(1)
     
     # Option: -h, --help - Display this help message
     # Option: -v, --verbose - Enable verbose output
     # Option: -f FILE, --file=FILE - Input file to process
     
     # Example: example-script.sh -v -f input.txt
     # Example: example-script.sh --verbose --file=input.txt
     
     # Display help function
     function show_help() {
       cat << EOF
     Usage: $(basename $0) [OPTIONS]
     
     $(grep "^# Description:" "$0" | cut -d: -f2- | sed 's/^ *//')
     
     Options:
     $(grep "^# Option:" "$0" | sed 's/^# Option: /  /')
     
     Examples:
     $(grep "^# Example:" "$0" | sed 's/^# Example: /  /')
     
     For more information, see the man page: man $(basename $0)
     EOF
     }
     
     # Check for help flag
     if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
       show_help
       exit 0
     fi
     
     # Script logic here
     # ...
     ```
   - Generate usage documentation:
     ```bash
     #!/bin/bash
     # generate-docs.sh
     # Generate documentation for all scripts
     
     # Output directory
     output_dir="docs"
     mkdir -p "$output_dir"
     
     # Generate README
     cat << EOF > "$output_dir/README.md"
     # Script Documentation
     
     This directory contains documentation for all scripts in the project.
     
     ## Scripts
     
     EOF
     
     # Process each script
     for script_file in bin/*.sh; do
       script_name=$(basename "$script_file")
       
       # Extract metadata
       title=$(grep "^# Title:" "$script_file" | cut -d: -f2- | sed 's/^ *//')
       description=$(grep "^# Description:" "$script_file" | cut -d: -f2- | sed 's/^ *//')
       
       # Add to README
       echo "- [$script_name]($script_name.md) - $description" >> "$output_dir/README.md"
       
       # Generate script doc
       cat << EOF > "$output_dir/$script_name.md"
     # $title
     
     $(grep "^# Description-long:" "$script_file" | cut -d: -f2- | sed 's/^ *//')
     
     ## Usage
     
     \`\`\`
     $(grep "^# Example:" "$script_file" | sed 's/^# Example: //')
     \`\`\`
     
     ## Options
     
     $(grep "^# Option:" "$script_file" | sed 's/^# Option: /- `/' | sed 's/ - /` - /')
     
     ## Examples
     
     $(grep "^# Example:" "$script_file" | sed 's/^# Example: /- `/' | sed 's/$/`/')
     
     ## See Also
     
     $(grep "^# See-also:" "$script_file" | cut -d: -f2- | sed 's/^ *//')
     EOF
     done
     
     echo "Documentation generated in $output_dir"
     ```
   - Package scripts for distribution:
     ```bash
     #!/bin/bash
     # create-package.sh
     # Create distributable package
     
     # Package information
     package_name="my-scripts"
     version=$(grep "^VERSION=" "bin/app-cli" | cut -d= -f2 | tr -d '"')
     output_dir="dist"
     
     # Create package directory
     package_dir="$output_dir/$package_name-$version"
     mkdir -p "$package_dir"
     
     # Copy files
     cp -r bin lib tasks "$package_dir"
     cp install.sh README.md LICENSE "$package_dir"
     mkdir -p "$package_dir/config"
     cp config/*.dist "$package_dir/config"
     
     # Generate documentation
     ./generate-docs.sh
     mkdir -p "$package_dir/docs"
     cp -r docs/*.md "$package_dir/docs"
     
     # Create install script
     cat << EOF > "$package_dir/install.sh"
     #!/bin/bash
     # Installation script for $package_name $version
     
     # Default install location
     prefix="/usr/local"
     
     # Parse options
     while getopts "p:" opt; do
       case \$opt in
         p) prefix="\$OPTARG" ;;
         *) echo "Usage: \$0 [-p prefix]" >&2; exit 1 ;;
       esac
     done
     
     # Create directories
     mkdir -p "\$prefix/bin"
     mkdir -p "\$prefix/lib/$package_name"
     mkdir -p "\$prefix/share/$package_name"
     mkdir -p "\$prefix/share/doc/$package_name"
     
     # Install binaries
     for file in bin/*; do
       install -m 755 "\$file" "\$prefix/bin/"
     done
     
     # Install libraries
     cp -r lib/* "\$prefix/lib/$package_name/"
     
     # Install tasks
     cp -r tasks "\$prefix/share/$package_name/"
     
     # Install documentation
     cp -r docs/* "\$prefix/share/doc/$package_name/"
     cp README.md LICENSE "\$prefix/share/doc/$package_name/"
     
     # Create configuration
     mkdir -p "/etc/$package_name"
     for file in config/*.dist; do
       dest="/etc/$package_name/\$(basename \$file .dist)"
       if [ ! -f "\$dest" ]; then
         cp "\$file" "\$dest"
       else
         echo "Config file exists, not overwriting: \$dest"
       fi
     done
     
     echo "$package_name $version installed successfully"
     EOF
     
     chmod +x "$package_dir/install.sh"
     
     # Create tarball
     (cd "$output_dir" && tar czf "$package_name-$version.tar.gz" "$package_name-$version")
     
     echo "Package created: $output_dir/$package_name-$version.tar.gz"
     ```
   - Version scripts properly:
     ```bash
     #!/bin/bash
     # update-version.sh
     # Update version across all scripts
     
     if [ $# -ne 1 ]; then
       echo "Usage: $(basename $0) <new-version>" >&2
       exit 1
     fi
     
     new_version="$1"
     
     # Update main script version
     sed -i "s/^VERSION=.*/VERSION=\"$new_version\"/" bin/app-cli
     
     # Update version in man pages
     sed -i "s/^# Version:.*/# Version: $new_version/" bin/*.sh
     
     # Update version in package manifest
     sed -i "s/\"version\": .*/\"version\": \"$new_version\",/" package.json
     
     # Generate new documentation
     ./generate-docs.sh
     
     echo "Version updated to $new_version"
     ```

### Resources

- [Command Line Interface Guidelines](https://clig.dev/)
- [Building Awesome Command-Line Tools in Go](https://spf13.com/presentation/building-awesome-cli-apps-in-go/)
- [argbash](https://github.com/matejak/argbash) - Bash argument parsing code generator
- [Comprehensive command-line options](https://tldp.org/LDP/GNU-Linux-Tools-Summary/html/x11655.htm)

## Projects and Exercises

1. **System Maintenance Automation Suite**
   - Create a complete system maintenance toolkit
   - Include package updates, cleanup, and backup
   - Implement logging and error reporting
   - Add email/notification capabilities
   - Schedule with systemd timers
   - Create a status dashboard

2. **Log Analysis and Reporting Tool**
   - Build a script to analyze system logs
   - Implement pattern matching for important events
   - Generate daily/weekly reports
   - Create alerts for critical patterns
   - Add visualization of trends
   - Schedule regular execution

3. **Deployment Automation Framework**
   - Create a framework for deploying applications
   - Implement environment setup and validation
   - Add backup and rollback capabilities
   - Create logging and monitoring
   - Design modular architecture for different apps
   - Document usage and extension

4. **User Management Toolkit**
   - Build scripts for user account management
   - Implement bulk operations with CSV input
   - Add reporting and auditing
   - Include permission management
   - Create secure password handling
   - Design for both interactive and automated use

## Assessment

You should now be able to:

1. Create robust, production-ready shell scripts
2. Implement proper error handling and logging
3. Schedule and manage automated tasks effectively
4. Build user-friendly command-line tools
5. Design reusable automation frameworks
6. Document and distribute your scripts

## Next Steps

In [Month 10: Cloud Integration and Remote Development](month-10-cloud.md), we'll focus on:
- Cloud service provider integration
- Setting up remote development environments
- Implementing Infrastructure as Code
- Connecting local and cloud resources
- Managing cloud resources from Linux

## Acknowledgements

This learning guide was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Learning path structure and organization
- Resource recommendations
- Project suggestions

Claude was used as a development aid while all final implementation decisions and verification were performed by Joshua Michael Hall.

## Disclaimer

This guide is provided "as is", without warranty of any kind. Follow all instructions carefully and always make backups before making system changes.
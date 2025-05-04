[@]}" | head -20
     
     if [[ "$(find "${find_opts[@]}" | wc -l)" -gt 20 ]]; then
       echo
       echo "... and $(( $(find "${find_opts[@]}" | wc -l) - 20 )) more files"
     fi
     
     return 0
   }
   
   # Find files command
   function cmd_find() {
     local case_sensitive=false
     local type="file"
     local pattern=""
     
     # Parse command options
     while [[ $# -gt 0 ]]; do
       case "$1" in
         --case-sensitive)
           case_sensitive=true
           shift
           ;;
         --type=*)
           type="${1#*=}"
           shift
           ;;
         --help)
           echo "Usage: $(basename "$0") find [options] <pattern>"
           echo
           echo "Options:"
           echo "  --case-sensitive    Enable case-sensitive matching"
           echo "  --type=TYPE         File type: file, dir, symlink (default: file)"
           echo
           echo "Examples:"
           echo "  $(basename "$0") find \"*.txt\""
           echo "  $(basename "$0") find --case-sensitive \"README*\""
           echo "  $(basename "$0") find --type=dir \"data*\""
           return 0
           ;;
         -*)
           echo "Error: Unknown option for find command: $1" >&2
           return 1
           ;;
         *)
           pattern="$1"
           shift
           ;;
       esac
     done
     
     # Check if pattern is provided
     if [[ -z "$pattern" ]]; then
       echo "Error: Pattern is required for find command" >&2
       echo "Run '$(basename "$0") find --help' for usage information" >&2
       return 1
     fi
     
     verbose_output "Searching for files in $workspace"
     verbose_output "Pattern: $pattern"
     verbose_output "Case sensitive: $case_sensitive"
     verbose_output "Type: $type"
     
     # Build find command
     if [[ "$type" == "file" ]]; then
       type_opt="-type f"
     elif [[ "$type" == "dir" ]]; then
       type_opt="-type d"
     elif [[ "$type" == "symlink" ]]; then
       type_opt="-type l"
     else
       echo "Error: Invalid type: $type" >&2
       return 1
     fi
     
     # Case sensitivity
     if [[ "$case_sensitive" == "true" ]]; then
       name_opt="-name"
     else
       name_opt="-iname"
     fi
     
     # Execute command
     echo "Searching for: $pattern"
     echo "Workspace: $workspace"
     echo
     
     result=$(find "$workspace" "$type_opt" "$name_opt" "$pattern")
     
     if [[ -n "$result" ]]; then
       echo "$result"
       echo
       echo "Total matches: $(echo "$result" | wc -l)"
     else
       echo "No matches found"
     fi
     
     return 0
   }
   
   # Organize files command
   function cmd_organize() {
     local dry_run=false
     local custom_rules=""
     
     # Parse command options
     while [[ $# -gt 0 ]]; do
       case "$1" in
         --dry-run)
           dry_run=true
           shift
           ;;
         --rules=*)
           custom_rules="${1#*=}"
           shift
           ;;
         --help)
           echo "Usage: $(basename "$0") organize [options]"
           echo
           echo "Options:"
           echo "  --dry-run          Show what would be done without making changes"
           echo "  --rules=FILE       Use custom organization rules file"
           echo
           echo "Examples:"
           echo "  $(basename "$0") organize"
           echo "  $(basename "$0") organize --dry-run"
           echo "  $(basename "$0") organize --rules=~/my-rules.txt"
           return 0
           ;;
         *)
           echo "Error: Unknown option for organize command: $1" >&2
           return 1
           ;;
       esac
     done
     
     verbose_output "Organizing files in $workspace"
     verbose_output "Dry run: $dry_run"
     
     # Default organization rules
     local rules=(
       "Images:\.jpg$|\.jpeg$|\.png$|\.gif$|\.bmp$|\.svg$|\.tiff$"
       "Documents:\.pdf$|\.doc$|\.docx$|\.txt$|\.rtf$|\.odt$"
       "Spreadsheets:\.xls$|\.xlsx$|\.csv$|\.ods$"
       "Archives:\.zip$|\.tar$|\.gz$|\.rar$|\.7z$"
       "Code:\.py$|\.js$|\.html$|\.css$|\.java$|\.c$|\.cpp$|\.sh$|\.rb$"
       "Videos:\.mp4$|\.avi$|\.mov$|\.mkv$|\.wmv$"
       "Audio:\.mp3$|\.wav$|\.ogg$|\.flac$|\.aac$"
     )
     
     # Load custom rules if provided
     if [[ -n "$custom_rules" && -f "$custom_rules" ]]; then
       readarray -t rules < "$custom_rules"
       verbose_output "Loaded custom rules from $custom_rules"
     fi
     
     echo "Organizing files in $workspace"
     if [[ "$dry_run" == "true" ]]; then
       echo "DRY RUN MODE - No changes will be made"
     fi
     echo
     
     # Process each rule
     for rule in "${rules[@]}"; do
       # Extract category and pattern
       category="${rule%%:*}"
       pattern="${rule#*:}"
       
       # Create category directory if it doesn't exist
       if [[ ! -d "$workspace/$category" && "$dry_run" != "true" ]]; then
         mkdir -p "$workspace/$category"
         verbose_output "Created directory: $workspace/$category"
       fi
       
       # Find files matching pattern
       verbose_output "Finding files for category: $category (pattern: $pattern)"
       files=$(find "$workspace" -maxdepth 1 -type f -regextype posix-extended -regex ".*($pattern)")
       
       # Move files to category directory
       if [[ -n "$files" ]]; then
         echo "Category: $category"
         while IFS= read -r file; do
           filename=$(basename "$file")
           echo "  $filename -> $category/"
           
           if [[ "$dry_run" != "true" ]]; then
             mv "$file" "$workspace/$category/"
           fi
         done <<< "$files"
         echo
       fi
     done
     
     echo "Organization completed"
     return 0
   }
   
   # Backup command
   function cmd_backup() {
     local name=""
     local format="$compression"
     local include_all=false
     
     # Parse command options
     while [[ $# -gt 0 ]]; do
       case "$1" in
         --format=*)
           format="${1#*=}"
           shift
           ;;
         --all)
           include_all=true
           shift
           ;;
         --help)
           echo "Usage: $(basename "$0") backup [options] [name]"
           echo
           echo "Options:"
           echo "  --format=FORMAT    Backup format: zip, tar, gz (default: $compression)"
           echo "  --all              Include all files, including hidden files"
           echo
           echo "Examples:"
           echo "  $(basename "$0") backup"
           echo "  $(basename "$0") backup project-backup"
           echo "  $(basename "$0") backup --format=tar project-backup"
           return 0
           ;;
         -*)
           echo "Error: Unknown option for backup command: $1" >&2
           return 1
           ;;
         *)
           name="$1"
           shift
           ;;
       esac
     done
     
     # Set default name if not provided
     if [[ -z "$name" ]]; then
       name="backup-$(date +%Y%m%d-%H%M%S)"
     fi
     
     verbose_output "Creating backup of $workspace"
     verbose_output "Name: $name"
     verbose_output "Format: $format"
     verbose_output "Include all files: $include_all"
     
     # Create backup directory if it doesn't exist
     if [[ ! -d "$backup_dir" ]]; then
       mkdir -p "$backup_dir"
       verbose_output "Created backup directory: $backup_dir"
     fi
     
     # Determine command and file extension based on format
     local cmd=""
     local ext=""
     
     case "$format" in
       zip)
         cmd="zip -r"
         ext=".zip"
         ;;
       tar)
         cmd="tar -cf"
         ext=".tar"
         ;;
       gz|targz)
         cmd="tar -czf"
         ext=".tar.gz"
         ;;
       *)
         echo "Error: Unsupported format: $format" >&2
         return 1
         ;;
     esac
     
     # Create backup
     local backup_file="$backup_dir/$name$ext"
     
     echo "Creating backup: $backup_file"
     echo
     
     # Set exclude pattern for hidden files
     local exclude=""
     if [[ "$include_all" != "true" ]]; then
       if [[ "$format" == "zip" ]]; then
         exclude="-x */\\.*"
       else
         exclude="--exclude='*/.*'"
       fi
     fi
     
     # Execute backup command
     if [[ "$format" == "zip" ]]; then
       (cd "$workspace" && eval "$cmd \"$backup_file\" . $exclude")
     else
       (cd "$workspace" && eval "$cmd \"$backup_file\" . $exclude")
     fi
     
     if [[ $? -eq 0 ]]; then
       echo
       echo "Backup created successfully: $backup_file"
       echo "Size: $(du -h "$backup_file" | cut -f1)"
     else
       echo
       echo "Error: Failed to create backup" >&2
       return 1
     fi
     
     return 0
   }
   
   # Stats command
   function cmd_stats() {
     local by_type=false
     local include_hidden=false
     
     # Parse command options
     while [[ $# -gt 0 ]]; do
       case "$1" in
         --by-type)
           by_type=true
           shift
           ;;
         --include-hidden)
           include_hidden=true
           shift
           ;;
         --help)
           echo "Usage: $(basename "$0") stats [options]"
           echo
           echo "Options:"
           echo "  --by-type           Show statistics by file type"
           echo "  --include-hidden    Include hidden files and directories"
           echo
           echo "Examples:"
           echo "  $(basename "$0") stats"
           echo "  $(basename "$0") stats --by-type"
           return 0
           ;;
         *)
           echo "Error: Unknown option for stats command: $1" >&2
           return 1
           ;;
       esac
     done
     
     verbose_output "Generating statistics for $workspace"
     verbose_output "By type: $by_type"
     verbose_output "Include hidden: $include_hidden"
     
     echo "File Statistics for $workspace"
     echo "============================"
     echo
     
     # Overall statistics
     local find_opts=("$workspace")
     
     if [[ "$include_hidden" != "true" ]]; then
       find_opts+=("!" "-path" "*/.*")
     fi
     
     local total_files=$(find "${find_opts[@]}" -type f | wc -l)
     local total_dirs=$(find "${find_opts[@]}" -type d | wc -l)
     local total_size=$(du -sb "$workspace" | cut -f1)
     
     # Format size in human-readable format
     local size_human
     if [[ "$total_size" -gt 1073741824 ]]; then  # 1 GB
       size_human=$(awk "BEGIN {printf \"%.2f GB\", $total_size/1073741824}")
     elif [[ "$total_size" -gt 1048576 ]]; then  # 1 MB
       size_human=$(awk "BEGIN {printf \"%.2f MB\", $total_size/1048576}")
     elif [[ "$total_size" -gt 1024 ]]; then  # 1 KB
       size_human=$(awk "BEGIN {printf \"%.2f KB\", $total_size/1024}")
     else
       size_human="$total_size bytes"
     fi
     
     echo "Overall Statistics:"
     echo "  Total files: $total_files"
     echo "  Total directories: $total_dirs"
     echo "  Total size: $size_human"
     echo
     
     # Statistics by file type
     if [[ "$by_type" == "true" ]]; then
       echo "Statistics by File Type:"
       echo
       
       # Get all files
       local all_files=$(find "${find_opts[@]}" -type f)
       
       # Extract file extensions
       local extensions=$(echo "$all_files" | grep -o '\.[^./]*# Month 9: Automation and Scripting - Exercises

This document contains practical exercises and projects to accompany the Month 9 learning guide. Complete these exercises to solidify your understanding of shell scripting, automation, scheduled tasks, and building robust command-line tools.

## Exercise 1: Advanced Shell Scripting

### Shell Script Structure and Best Practices

1. **Create a well-structured script template**:
   ```bash
   # Create a script template file
   mkdir -p ~/scripts
   touch ~/scripts/template.sh
   chmod +x ~/scripts/template.sh
   ```

   Add this basic template structure:
   ```bash
   #!/bin/bash
   #
   # Script name: template.sh
   # Description: A template for well-structured bash scripts
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   #
   # Usage: ./template.sh [options] <arguments>
   
   # Exit on error, undefined variables, and pipe failures
   set -euo pipefail
   
   # Constants and configuration
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
   LOG_FILE="/tmp/${SCRIPT_NAME%.sh}.log"
   
   # Functions
   function log() {
     local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
     echo "[$timestamp] $1" | tee -a "$LOG_FILE"
   }
   
   function display_usage() {
     cat << EOF
   Usage: $SCRIPT_NAME [options] <argument>
   
   Options:
     -h, --help     Display this help message
     -v, --verbose  Enable verbose output
   
   Example:
     $SCRIPT_NAME --verbose argument
   EOF
     exit 1
   }
   
   function cleanup() {
     log "Cleaning up resources..."
     # Add cleanup code here
   }
   
   # Set up trap to ensure cleanup happens
   trap cleanup EXIT
   
   # Parse command line arguments
   verbose=false
   
   while [[ $# -gt 0 ]]; do
     case "$1" in
       -h|--help)
         display_usage
         ;;
       -v|--verbose)
         verbose=true
         shift
         ;;
       *)
         # Store as positional argument
         if [[ -z ${positional_arg+x} ]]; then
           positional_arg="$1"
         else
           log "Error: Unknown argument: $1"
           display_usage
         fi
         shift
         ;;
     esac
   done
   
   # Check required arguments
   if [[ -z ${positional_arg+x} ]]; then
     log "Error: Missing required argument"
     display_usage
   fi
   
   # Main execution
   log "Script started with argument: $positional_arg"
   
   if [[ "$verbose" = true ]]; then
     log "Verbose mode enabled"
   fi
   
   # Your script logic goes here
   
   log "Script completed successfully"
   exit 0
   ```

2. **Create a script for managing data structures**:
   ```bash
   # Create a script for working with data structures
   touch ~/scripts/data_structures.sh
   chmod +x ~/scripts/data_structures.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: data_structures.sh
   # Description: Demonstrates working with Bash data structures
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Exit on error, undefined variables, and pipe failures
   set -euo pipefail
   
   # 1. Working with arrays
   echo "===== Arrays ====="
   
   # Create an indexed array
   fruits=("apple" "banana" "cherry" "date" "elderberry")
   echo "Number of fruits: ${#fruits[@]}"
   echo "All fruits: ${fruits[*]}"
   echo "First fruit: ${fruits[0]}"
   echo "Last two fruits: ${fruits[@]:3:2}"
   
   # Loop through array
   echo "Listing all fruits:"
   for fruit in "${fruits[@]}"; do
     echo "- $fruit"
   done
   
   # Edit array
   fruits[1]="blueberry"
   fruits+=("fig")
   echo "Updated fruits: ${fruits[*]}"
   
   # Remove element (note: leaves gap in array)
   unset 'fruits[2]'
   echo "After removal: ${fruits[*]}"
   
   # 2. Working with associative arrays
   echo -e "\n===== Associative Arrays ====="
   
   # Requires Bash 4+
   if ((BASH_VERSINFO[0] < 4)); then
     echo "Associative arrays require Bash 4 or higher"
     exit 1
   fi
   
   # Create an associative array
   declare -A user_roles
   user_roles=([alice]="admin" [bob]="user" [charlie]="developer" [dave]="analyst")
   
   echo "Number of users: ${#user_roles[@]}"
   echo "All users: ${!user_roles[@]}"
   echo "All roles: ${user_roles[@]}"
   echo "Alice's role: ${user_roles[alice]}"
   
   # Check if key exists
   if [[ -v user_roles[bob] ]]; then
     echo "Bob's role is ${user_roles[bob]}"
   else
     echo "Bob has no assigned role"
   fi
   
   # Loop through associative array
   echo "User roles:"
   for user in "${!user_roles[@]}"; do
     echo "$user: ${user_roles[$user]}"
   done
   
   # Add or modify entry
   user_roles[eve]="manager"
   user_roles[bob]="admin"
   
   # Remove entry
   unset 'user_roles[dave]'
   
   echo "Updated user roles:"
   for user in "${!user_roles[@]}"; do
     echo "$user: ${user_roles[$user]}"
   done
   
   # 3. String manipulation
   echo -e "\n===== String Manipulation ====="
   
   filepath="/home/user/documents/report.txt"
   
   # Get filename
   filename="${filepath##*/}"
   echo "Filename: $filename"
   
   # Get directory
   directory="${filepath%/*}"
   echo "Directory: $directory"
   
   # Get file extension
   extension="${filename##*.}"
   echo "Extension: $extension"
   
   # Get filename without extension
   basename="${filename%.*}"
   echo "Basename: $basename"
   
   # String replacement
   newfilepath="${filepath/report/summary}"
   echo "New filepath: $newfilepath"
   
   # Convert to uppercase
   uppercase="${filename^^}"
   echo "Uppercase: $uppercase"
   
   # Convert to lowercase
   lowercase="${filename,,}"
   echo "Lowercase: $lowercase"
   
   # Substring extraction
   echo "First 4 chars: ${filename:0:4}"
   echo "Last 4 chars: ${filename: -4}"
   
   echo "Script completed successfully"
   exit 0
   ```

3. **Create a script to demonstrate control structures**:
   ```bash
   # Create a script for demonstrating control structures
   touch ~/scripts/control_structures.sh
   chmod +x ~/scripts/control_structures.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: control_structures.sh
   # Description: Demonstrates advanced control structures in Bash
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Exit on error, undefined variables, and pipe failures
   set -euo pipefail
   
   # 1. Advanced conditionals
   echo "===== Advanced Conditionals ====="
   
   # Pattern matching with [[ ]]
   filename="document.pdf"
   if [[ "$filename" == *.pdf ]]; then
     echo "$filename is a PDF file"
   fi
   
   # Regular expression matching
   email="user@example.com"
   if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
     echo "$email is a valid email address"
   else
     echo "$email is not a valid email address"
   fi
   
   # Multiple conditions
   age=25
   has_id=true
   if [ "$age" -ge 18 ] && [ "$has_id" = true ]; then
     echo "Access granted: Adult with ID"
   elif [ "$age" -ge 18 ] && [ "$has_id" != true ]; then
     echo "Access denied: Adult without ID"
   elif [ "$age" -lt 18 ] && [ "$has_id" = true ]; then
     echo "Access denied: Minor with ID"
   else
     echo "Access denied: Minor without ID"
   fi
   
   # Case statement
   fruit="apple"
   case "$fruit" in
     apple)
       echo "It's an apple!"
       ;;
     banana|orange)
       echo "It's a yellow or orange fruit"
       ;;
     *)
       echo "It's some other fruit"
       ;;
   esac
   
   # 2. Advanced loop structures
   echo -e "\n===== Advanced Loops ====="
   
   # For loop with sequence
   echo "Simple sequence:"
   for i in {1..5}; do
     echo "Number: $i"
   done
   
   # For loop with step
   echo "Sequence with step:"
   for i in {10..1..2}; do
     echo "Number: $i"
   done
   
   # C-style for loop
   echo "C-style loop:"
   for ((i=0; i<5; i++)); do
     echo "Index: $i"
   done
   
   # While loop with read
   echo "Parsing data from here-document:"
   data=$(cat << EOF
   John,32,Manager
   Alice,28,Developer
   Bob,45,Director
   EOF
   )
   
   echo "$data" | while IFS=, read -r name age role; do
     echo "$name is $age years old and works as a $role"
   done
   
   # Until loop
   echo "Until loop:"
   counter=5
   until [ $counter -le 0 ]; do
     echo "Countdown: $counter"
     ((counter--))
   done
   
   # Breaking out of loops
   echo "Breaking out of loop:"
   for i in {1..10}; do
     echo "Processing $i"
     if [ $i -eq 5 ]; then
       echo "Reached 5, breaking out"
       break
     fi
   done
   
   # Skipping iterations
   echo "Skipping iterations:"
   for i in {1..5}; do
     if [ $i -eq 3 ]; then
       echo "Skipping 3"
       continue
     fi
     echo "Processing $i"
   done
   
   # 3. Advanced function usage
   echo -e "\n===== Advanced Functions ====="
   
   # Function with local variables
   function greet() {
     local name="${1:-World}"
     echo "Hello, $name!"
   }
   
   # Call function with and without parameter
   greet
   greet "Sarah"
   
   # Function with return value
   function is_even() {
     local num=$1
     if (( num % 2 == 0 )); then
       return 0  # True in Bash
     else
       return 1  # False in Bash
     fi
   }
   
   # Use return value
   if is_even 42; then
     echo "42 is even"
   else
     echo "42 is odd"
   fi
   
   if ! is_even 15; then
     echo "15 is odd"
   fi
   
   # Function that returns value via output
   function add() {
     local a=$1
     local b=$2
     echo $((a + b))
   }
   
   # Capture function output
   sum=$(add 5 3)
   echo "5 + 3 = $sum"
   
   # Function with named parameters
   function create_user() {
     local username=""
     local role=""
     local active=false
     
     # Parse named parameters
     while [[ $# -gt 0 ]]; do
       case "$1" in
         --username=*)
           username="${1#*=}"
           ;;
         --role=*)
           role="${1#*=}"
           ;;
         --active)
           active=true
           ;;
       esac
       shift
     done
     
     # Use parameters
     echo "Creating user: $username"
     echo "Role: $role"
     echo "Active: $active"
   }
   
   # Call function with named parameters
   create_user --username=jane --role=admin --active
   
   # Recursive function
   function countdown() {
     local count=$1
     echo "$count"
     
     if [[ $count -gt 1 ]]; then
       countdown $((count - 1))
     fi
   }
   
   echo "Recursive countdown:"
   countdown 5
   
   echo "Script completed successfully"
   exit 0
   ```

4. **Create a script for file and I/O handling**:
   ```bash
   # Create a script for handling files and I/O
   touch ~/scripts/file_io.sh
   chmod +x ~/scripts/file_io.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: file_io.sh
   # Description: Demonstrates advanced file and I/O handling in Bash
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Exit on error, undefined variables, and pipe failures
   set -euo pipefail
   
   # Create a temporary directory for this exercise
   temp_dir=$(mktemp -d)
   echo "Created temporary directory: $temp_dir"
   
   # Clean up on exit
   function cleanup() {
     echo "Cleaning up temporary directory"
     rm -rf "$temp_dir"
   }
   
   trap cleanup EXIT
   
   # 1. Command-line argument processing
   echo "===== Command-Line Arguments ====="
   
   # Check for --help
   if [[ "$#" -gt 0 && ("$1" == "-h" || "$1" == "--help") ]]; then
     cat << EOF
   Usage: $(basename "$0") [options]
   
   A demonstration of file and I/O handling in Bash.
   
   Options:
     -h, --help    Show this help message
     --file=PATH   Process the specified file
     --verbose     Enable verbose output
   EOF
     exit 0
   fi
   
   # Process arguments
   file=""
   verbose=false
   
   for arg in "$@"; do
     case "$arg" in
       --file=*)
         file="${arg#*=}"
         ;;
       --verbose)
         verbose=true
         ;;
     esac
   done
   
   # Show processed arguments
   echo "File: ${file:-Not specified}"
   echo "Verbose mode: $verbose"
   
   # 2. Reading and writing files
   echo -e "\n===== File Operations ====="
   
   # Create a sample file
   sample_file="$temp_dir/sample.txt"
   cat > "$sample_file" << EOF
   Line 1: This is a sample file.
   Line 2: It contains multiple lines.
   Line 3: We will use it for testing.
   Line 4: File operations in Bash.
   EOF
   
   echo "Created sample file: $sample_file"
   
   # Read file line by line
   echo "Reading file line by line:"
   line_num=1
   while IFS= read -r line; do
     echo "$line_num: $line"
     ((line_num++))
   done < "$sample_file"
   
   # Read specific lines
   echo -e "\nReading lines 2-3:"
   sed -n '2,3p' "$sample_file"
   
   # Write to a new file
   output_file="$temp_dir/output.txt"
   {
     echo "Report generated on $(date)"
     echo "--------------------------"
     grep "Line" "$sample_file"
     echo "--------------------------"
   } > "$output_file"
   
   echo "Created output file: $output_file"
   echo "Contents:"
   cat "$output_file"
   
   # Append to file
   echo -e "\nAppending to file:"
   echo "End of report." >> "$output_file"
   tail -1 "$output_file"
   
   # 3. Redirection techniques
   echo -e "\n===== Redirection Techniques ====="
   
   # Redirect stdout and stderr separately
   echo "Redirecting stdout and stderr separately:"
   {
     echo "This goes to stdout"
     echo "This goes to stderr" >&2
   } > "$temp_dir/stdout.log" 2> "$temp_dir/stderr.log"
   
   echo "stdout.log contents:"
   cat "$temp_dir/stdout.log"
   echo "stderr.log contents:"
   cat "$temp_dir/stderr.log"
   
   # Redirect both to same file
   echo -e "\nRedirecting both to same file:"
   {
     echo "This goes to stdout"
     echo "This goes to stderr" >&2
   } > "$temp_dir/combined.log" 2>&1
   
   echo "combined.log contents:"
   cat "$temp_dir/combined.log"
   
   # Here documents (heredoc)
   echo -e "\nHere document example:"
   cat << 'EOF' > "$temp_dir/config.ini"
   [General]
   ApplicationName=File Demo
   Version=1.0
   
   [Network]
   Host=localhost
   Port=8080
   Timeout=30
   EOF
   
   echo "Created config.ini:"
   cat "$temp_dir/config.ini"
   
   # Here strings
   echo -e "\nHere string example:"
   grep "Port" <<< "Port=8080"
   
   # Process substitution
   echo -e "\nProcess substitution example:"
   echo "Comparing file contents:"
   diff <(head -2 "$sample_file") <(tail -2 "$sample_file")
   
   # Named pipes
   echo -e "\nNamed pipe example:"
   pipe="$temp_dir/mypipe"
   mkfifo "$pipe"
   
   # Start background process to read from the pipe
   {
     while read -r line; do
       echo "Received: $line"
     done < "$pipe"
   } &
   pipe_reader_pid=$!
   
   # Write to the pipe
   echo "Hello through pipe!" > "$pipe"
   echo "Another message!" > "$pipe"
   
   # Wait for background process to process messages
   sleep 1
   kill $pipe_reader_pid 2>/dev/null || true
   
   echo "Script completed successfully"
   exit 0
   ```

### Execute and Explore Scripts

Run each of the scripts you created above:

```bash
# Run data structures script
~/scripts/data_structures.sh

# Run control structures script
~/scripts/control_structures.sh

# Run file I/O script
~/scripts/file_io.sh
```

Take time to understand how each component works. Try modifying the scripts to change behavior or extend functionality.

## Exercise 2: Error Handling, Logging, and Robust Scripting

### Create a Robust Script Template

1. **Create a script template with error handling**:
   ```bash
   # Create a robust script template
   touch ~/scripts/robust_template.sh
   chmod +x ~/scripts/robust_template.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: robust_template.sh
   # Description: A template for robust bash scripts with error handling
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Exit on error, undefined variables, and pipe failures
   set -euo pipefail
   
   # Variables
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
   LOG_DIR="${HOME}/logs"
   LOG_FILE="${LOG_DIR}/${SCRIPT_NAME%.sh}.log"
   TEMP_DIR=$(mktemp -d)
   LOCK_FILE="/tmp/${SCRIPT_NAME%.sh}.lock"
   
   # Default settings
   VERBOSE=false
   DEBUG=false
   DRY_RUN=false
   
   # Exit codes
   readonly E_SUCCESS=0
   readonly E_USAGE=1
   readonly E_DEPENDENCY=2
   readonly E_PERMISSION=3
   readonly E_INPUT=4
   readonly E_OUTPUT=5
   readonly E_RUNTIME=6
   readonly E_LOCKED=7
   readonly E_TIMEOUT=8
   
   # =====================
   # Logging functions
   # =====================
   function _setup_logging() {
     # Create log directory if it doesn't exist
     mkdir -p "$LOG_DIR"
     
     # Create or truncate log file
     : > "$LOG_FILE"
     
     # Set permission
     chmod 600 "$LOG_FILE"
   }
   
   function log() {
     local level="$1"
     local message="$2"
     local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
     
     # Format log line
     local log_line="[$timestamp] [$level] $message"
     
     # Write to log file
     echo "$log_line" >> "$LOG_FILE"
     
     # Write to stdout/stderr based on level
     case "$level" in
       ERROR)
         echo "$log_line" >&2
         ;;
       WARN)
         $VERBOSE && echo "$log_line" >&2
         ;;
       INFO)
         $VERBOSE && echo "$log_line"
         ;;
       DEBUG)
         $DEBUG && echo "$log_line"
         ;;
       *)
         echo "$log_line"
         ;;
     esac
   }
   
   function log_error() { log "ERROR" "$1"; }
   function log_warn() { log "WARN" "$1"; }
   function log_info() { log "INFO" "$1"; }
   function log_debug() { log "DEBUG" "$1"; }
   function log_success() { log "SUCCESS" "$1"; }
   
   # =====================
   # Error handling functions
   # =====================
   function error_handler() {
     local line_no="$1"
     local error_code="${2:-1}"
     local command="$3"
     
     # Don't trigger on successful exit
     if [[ $error_code -eq 0 ]]; then
       return
     fi
     
     log_error "Error in ${SCRIPT_NAME}, line ${line_no}: '${command}' exited with status ${error_code}"
     
     # Cleanup on error
     cleanup
     
     exit "$error_code"
   }
   
   function cleanup() {
     log_debug "Performing cleanup"
     
     # Remove temporary directory if it exists
     [[ -d "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"
     
     # Remove lock file if it exists
     [[ -f "$LOCK_FILE" ]] && rm -f "$LOCK_FILE"
     
     log_debug "Cleanup completed"
   }
   
   # =====================
   # Utility functions
   # =====================
   function check_dependencies() {
     local missing_deps=()
     
     for cmd in "$@"; do
       if ! command -v "$cmd" &>/dev/null; then
         missing_deps+=("$cmd")
       fi
     done
     
     if [[ ${#missing_deps[@]} -gt 0 ]]; then
       log_error "Missing dependencies: ${missing_deps[*]}"
       return $E_DEPENDENCY
     fi
     
     return $E_SUCCESS
   }
   
   function create_lock() {
     # Check if lock file exists and process is still running
     if [[ -f "$LOCK_FILE" ]]; then
       local old_pid=$(cat "$LOCK_FILE")
       
       if ps -p "$old_pid" &>/dev/null; then
         log_error "Another instance is already running with PID ${old_pid}"
         return $E_LOCKED
       else
         log_warn "Removing stale lock file"
         rm -f "$LOCK_FILE"
       fi
     fi
     
     # Create new lock file
     echo $$ > "$LOCK_FILE"
     log_debug "Created lock file: $LOCK_FILE"
     
     return $E_SUCCESS
   }
   
   function display_usage() {
     cat << EOF
   Usage: $SCRIPT_NAME [OPTIONS]
   
   A robust script template with error handling and logging.
   
   Options:
     -h, --help       Display this help message
     -v, --verbose    Enable verbose output
     -d, --debug      Enable debug mode
     --dry-run        Run without making changes
   
   Example:
     $SCRIPT_NAME --verbose
   EOF
   }
   
   # =====================
   # Parse command-line arguments
   # =====================
   function parse_arguments() {
     while [[ $# -gt 0 ]]; do
       case "$1" in
         -h|--help)
           display_usage
           exit $E_SUCCESS
           ;;
         -v|--verbose)
           VERBOSE=true
           shift
           ;;
         -d|--debug)
           DEBUG=true
           VERBOSE=true  # Debug implies verbose
           shift
           ;;
         --dry-run)
           DRY_RUN=true
           shift
           ;;
         *)
           log_error "Unknown option: $1"
           display_usage
           exit $E_USAGE
           ;;
       esac
     done
   }
   
   # =====================
   # Main function
   # =====================
   function main() {
     # Set up error handling
     trap 'error_handler ${LINENO} $? "${BASH_COMMAND}"' ERR
     trap cleanup EXIT
     
     # Set up logging
     _setup_logging
     
     # Log script start
     log_info "Script started (pid: $$)"
     
     # Create lock file
     if ! create_lock; then
       exit $E_LOCKED
     fi
     
     # Check dependencies
     check_dependencies grep sed awk || exit $E_DEPENDENCY
     
     # Print configuration
     log_debug "Configuration:"
     log_debug "  Script directory: $SCRIPT_DIR"
     log_debug "  Log file: $LOG_FILE"
     log_debug "  Temp directory: $TEMP_DIR"
     log_debug "  Verbose mode: $VERBOSE"
     log_debug "  Debug mode: $DEBUG"
     log_debug "  Dry run mode: $DRY_RUN"
     
     # Your script logic goes here
     log_info "Executing main logic"
     
     # Use TEMP_DIR for temporary files
     echo "This is sample data" > "$TEMP_DIR/sample.txt"
     log_debug "Created sample file: $TEMP_DIR/sample.txt"
     
     # Simulated task
     if $DRY_RUN; then
       log_info "Would process data (dry run)"
     else
       log_info "Processing data..."
       sleep 2  # Simulate work
       log_success "Data processed successfully"
     fi
     
     # Script completed successfully
     log_info "Script completed successfully"
     return $E_SUCCESS
   }
   
   # Call the main function
   parse_arguments "$@"
   main
   exit $?
   ```

2. **Test the robust script template**:
   ```bash
   # Test with various options
   ~/scripts/robust_template.sh
   ~/scripts/robust_template.sh --verbose
   ~/scripts/robust_template.sh --debug
   ~/scripts/robust_template.sh --dry-run
   ```

### Create a Logging Library

1. **Create a reusable logging library**:
   ```bash
   # Create a logging library file
   mkdir -p ~/scripts/lib
   touch ~/scripts/lib/logging.sh
   chmod +x ~/scripts/lib/logging.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Library name: logging.sh
   # Description: A reusable logging library for Bash scripts
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Ensure this file is sourced, not executed
   if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
     echo "Error: This script should be sourced, not executed."
     exit 1
   fi
   
   # Default values
   : "${LOG_LEVEL:=INFO}"
   : "${LOG_FILE:=/dev/null}"
   : "${LOG_DATE_FORMAT:=%Y-%m-%d %H:%M:%S}"
   : "${LOG_COLOR:=true}"
   : "${LOG_TO_SYSLOG:=false}"
   : "${LOG_FACILITY:=user}"
   
   # Log levels
   declare -A LOG_LEVELS=(
     ["DEBUG"]=0
     ["INFO"]=1
     ["WARN"]=2
     ["ERROR"]=3
     ["FATAL"]=4
   )
   
   # ANSI color codes
   if [[ "$LOG_COLOR" == true ]]; then
     declare -A LOG_COLORS=(
       ["DEBUG"]="\033[36m"   # Cyan
       ["INFO"]="\033[32m"    # Green
       ["WARN"]="\033[33m"    # Yellow
       ["ERROR"]="\033[31m"   # Red
       ["FATAL"]="\033[35m"   # Magenta
       ["RESET"]="\033[0m"    # Reset
     )
   else
     declare -A LOG_COLORS=(
       ["DEBUG"]=""
       ["INFO"]=""
       ["WARN"]=""
       ["ERROR"]=""
       ["FATAL"]=""
       ["RESET"]=""
     )
   fi
   
   # Initialize logging
   function log_init() {
     # Create log directory if it doesn't exist
     local log_dir
     log_dir=$(dirname "$LOG_FILE")
     
     if [[ "$log_dir" != "/dev" && ! -d "$log_dir" ]]; then
       mkdir -p "$log_dir" || return 1
     fi
     
     # Create or truncate log file if not /dev/null
     if [[ "$LOG_FILE" != "/dev/null" ]]; then
       : > "$LOG_FILE" || return 1
       chmod 600 "$LOG_FILE" || return 1
     fi
     
     return 0
   }
   
   # Internal logging function
   function _log() {
     local level="$1"
     local message="$2"
     local timestamp
     local log_line
     local level_numeric
     local current_level_numeric
     
     # Get numeric values for comparison
     level_numeric="${LOG_LEVELS[$level]}"
     current_level_numeric="${LOG_LEVELS[$LOG_LEVEL]}"
     
     # Only log if level is high enough
     if [[ $level_numeric -lt $current_level_numeric ]]; then
       return 0
     fi
     
     # Format timestamp
     timestamp=$(date +"$LOG_DATE_FORMAT")
     
     # Format log message
     log_line="[$timestamp] [${level}] $message"
     
     # Write to log file
     if [[ "$LOG_FILE" != "/dev/null" ]]; then
       echo "$log_line" >> "$LOG_FILE"
     fi
     
     # Write to syslog if enabled
     if [[ "$LOG_TO_SYSLOG" == true ]]; then
       logger -p "${LOG_FACILITY}.${level,,}" -t "$(basename "$0")" "$message"
     fi
     
     # Write to stdout/stderr with color
     if [[ "$level" == "ERROR" || "$level" == "FATAL" ]]; then
       echo -e "${LOG_COLORS[$level]}$log_line${LOG_COLORS[RESET]}" >&2
     else
       echo -e "${LOG_COLORS[$level]}$log_line${LOG_COLORS[RESET]}"
     fi
     
     return 0
   }
   
   # Public logging functions
   function log_debug() { _log "DEBUG" "$1"; }
   function log_info() { _log "INFO" "$1"; }
   function log_warn() { _log "WARN" "$1"; }
   function log_error() { _log "ERROR" "$1"; }
   function log_fatal() { _log "FATAL" "$1"; }
   
   # Log rotation function
   function log_rotate() {
     local max_size=${1:-1048576}  # Default: 1MB
     local max_rotations=${2:-5}   # Default: 5 rotations
     
     # Don't rotate if log file doesn't exist
     if [[ ! -f "$LOG_FILE" || "$LOG_FILE" == "/dev/null" ]]; then
       return 0
     fi
     
     # Get current file size
     local size
     size=$(stat -c %s "$LOG_FILE" 2>/dev/null || stat -f %z "$LOG_FILE" 2>/dev/null)
     
     # Rotate if file size exceeds max size
     if [[ $size -gt $max_size ]]; then
       # Rotate old log files
       for i in $(seq "$max_rotations" -1 1); do
         local j=$((i + 1))
         
         if [[ -f "${LOG_FILE}.$i" ]]; then
           mv "${LOG_FILE}.$i" "${LOG_FILE}.$j" 2>/dev/null || true
         fi
       done
       
       # Rotate current log file
       mv "$LOG_FILE" "${LOG_FILE}.1" 2>/dev/null || true
       
       # Create new log file
       log_init
       
       return 0
     fi
     
     return 0
   }
   
   # Enable/disable syslog
   function log_enable_syslog() {
     LOG_TO_SYSLOG=true
   }
   
   function log_disable_syslog() {
     LOG_TO_SYSLOG=false
   }
   
   # Set log level
   function log_set_level() {
     local level="$1"
     
     if [[ -n "${LOG_LEVELS[$level]}" ]]; then
       LOG_LEVEL="$level"
       return 0
     else
       log_error "Invalid log level: $level"
       return 1
     fi
   }
   
   # Set log file
   function log_set_file() {
     local file="$1"
     
     LOG_FILE="$file"
     log_init
     
     return $?
   }
   
   # Enable/disable color
   function log_enable_color() {
     LOG_COLOR=true
     
     LOG_COLORS=(
       ["DEBUG"]="\033[36m"   # Cyan
       ["INFO"]="\033[32m"    # Green
       ["WARN"]="\033[33m"    # Yellow
       ["ERROR"]="\033[31m"   # Red
       ["FATAL"]="\033[35m"   # Magenta
       ["RESET"]="\033[0m"    # Reset
     )
   }
   
   function log_disable_color() {
     LOG_COLOR=false
     
     LOG_COLORS=(
       ["DEBUG"]=""
       ["INFO"]=""
       ["WARN"]=""
       ["ERROR"]=""
       ["FATAL"]=""
       ["RESET"]=""
     )
   }
   
   # Initialize logging
   log_init
   ```

2. **Create a test script that uses the logging library**:
   ```bash
   # Create a script that uses the logging library
   touch ~/scripts/test_logging.sh
   chmod +x ~/scripts/test_logging.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: test_logging.sh
   # Description: Tests the logging library
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Source the logging library
   source ~/scripts/lib/logging.sh
   
   # Set log file
   log_set_file "$HOME/logs/test_logging.log"
   
   # Test all log levels
   log_info "Testing logging library"
   
   log_debug "This is a debug message"
   log_info "This is an info message"
   log_warn "This is a warning message"
   log_error "This is an error message"
   log_fatal "This is a fatal message"
   
   # Test log level filtering
   log_info "Setting log level to WARN"
   log_set_level "WARN"
   
   log_debug "This debug message should not appear"
   log_info "This info message should not appear"
   log_warn "This warning message should appear"
   log_error "This error message should appear"
   
   # Test color toggling
   log_info "Disabling colors"
   log_disable_color
   log_warn "This warning should have no color"
   
   log_info "Re-enabling colors"
   log_enable_color
   log_warn "This warning should have color again"
   
   # Test log rotation
   log_info "Testing log rotation"
   for i in {1..100}; do
     log_info "Generating log entry $i"
     log_rotate 1024  # Rotate at 1KB
   done
   
   log_info "Testing completed"
   exit 0
   ```

3. **Run the test script and examine the logs**:
   ```bash
   # Run the test script
   ~/scripts/test_logging.sh
   
   # View the log file
   cat ~/logs/test_logging.log
   
   # Check for rotated logs
   ls -la ~/logs/
   ```

### Create a Script with Proper Security Practices

1. **Create a script with security best practices**:
   ```bash
   # Create a secure script
   touch ~/scripts/secure_script.sh
   chmod +x ~/scripts/secure_script.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: secure_script.sh
   # Description: Demonstrates secure scripting practices
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Exit on errors, undefined variables, and failed pipes
   set -euo pipefail
   
   # Set restrictive umask (owner rw only)
   umask 077
   
   # Create secure temporary directory
   TEMP_DIR=$(mktemp -d)
   if [[ ! -d "$TEMP_DIR" ]]; then
     echo "Error: Failed to create temporary directory" >&2
     exit 1
   fi
   
   # Clean up function
   function cleanup() {
     # Securely remove temporary files
     if [[ -d "$TEMP_DIR" ]]; then
       find "$TEMP_DIR" -type f -exec shred -uz {} \;
       rm -rf "$TEMP_DIR"
     fi
   }
   
   # Set trap to ensure cleanup on exit
   trap cleanup EXIT
   
   # Sanitize input function
   function sanitize_filename() {
     local input="$1"
     # Remove path components and special characters
     local sanitized="${input##*/}"
     sanitized="${sanitized//[^a-zA-Z0-9._-]/}"
     
     # Ensure result is not empty
     if [[ -z "$sanitized" ]]; then
       sanitized="default"
     fi
     
     echo "$sanitized"
   }
   
   # Validate input function
   function validate_number() {
     local input="$1"
     local min="${2:-0}"
     local max="${3:-100}"
     
     if [[ ! "$input" =~ ^[0-9]+$ ]]; then
       echo "Error: Input must be a number" >&2
       return 1
     fi
     
     if [[ "$input" -lt "$min" || "$input" -gt "$max" ]]; then
       echo "Error: Input must be between $min and $max" >&2
       return 1
     fi
     
     return 0
   }
   
   # Safely read sensitive input
   function read_secret() {
     local prompt="$1"
     local secret=""
     
     # Read password without echo
     read -s -p "$prompt" secret
     echo
     
     # Avoid returning empty string
     if [[ -z "$secret" ]]; then
       echo "Error: Empty input not allowed" >&2
       return 1
     fi
     
     # Return via stdout (don't use echo for secrets in production)
     echo "$secret"
     return 0
   }
   
   # Safe command execution
   function safe_execute() {
     local cmd="$1"
     local args=("${@:2}")
     
     # Avoid using eval
     "$cmd" "${args[@]}"
     return $?
   }
   
   # =====================
   # Main script
   # =====================
   echo "Secure Script Demo"
   echo "=================="
   
   # Process user input safely
   echo -n "Enter a filename: "
   read -r user_filename
   
   # Sanitize user input
   safe_filename=$(sanitize_filename "$user_filename")
   echo "Sanitized filename: $safe_filename"
   
   # Create a file in the temporary directory
   touch "$TEMP_DIR/$safe_filename"
   echo "Created file: $TEMP_DIR/$safe_filename"
   
   # Read and validate a number
   echo -n "Enter a number between 1 and 10: "
   read -r user_number
   
   if validate_number "$user_number" 1 10; then
     echo "Valid number: $user_number"
   else
     echo "Using default number: 5"
     user_number=5
   fi
   
   # Write some data to the file
   data="This is line $user_number"
   echo "$data" > "$TEMP_DIR/$safe_filename"
   
   # Read secret input
   password=$(read_secret "Enter a password: ")
   
   # Store password securely (in memory only, not in a file)
   echo "Password received (length: ${#password})"
   
   # Use password securely
   echo "Creating secure hash of password..."
   if command -v openssl >/dev/null 2>&1; then
     # Create a secure hash using a random salt
     salt=$(openssl rand -hex 8)
     hash=$(echo -n "${password}${salt}" | openssl dgst -sha256 | cut -d' ' -f2)
     echo "Password hash (with salt): $hash"
   else
     echo "OpenSSL not available, skipping password hashing"
   fi
   
   # Clear sensitive variable
   password=""
   
   # Safe command execution demo
   echo "Safe command execution:"
   safe_execute ls -la "$TEMP_DIR"
   
   # Show that temp files will be cleaned up
   echo
   echo "Script completed. Temporary files will be securely removed."
   exit 0
   ```

2. **Run the secure script**:
   ```bash
   # Execute the secure script
   ~/scripts/secure_script.sh
   ```

   Experiment with different inputs, including potentially problematic ones like `../../../etc/passwd` for the filename or non-numeric values for the number.

### Create a Test Framework for Scripts

1. **Create a simple test framework for shell scripts**:
   ```bash
   # Create a test framework
   mkdir -p ~/scripts/test_framework
   touch ~/scripts/test_framework/test.sh
   chmod +x ~/scripts/test_framework/test.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: test.sh
   # Description: A simple test framework for shell scripts
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Variables
   TEST_COUNT=0
   PASS_COUNT=0
   FAIL_COUNT=0
   CURRENT_TEST=""
   TEST_OUTPUT=""
   ERROR_OUTPUT=""
   
   # Colors
   RED="\033[31m"
   GREEN="\033[32m"
   YELLOW="\033[33m"
   BLUE="\033[34m"
   RESET="\033[0m"
   
   # Test framework functions
   function describe() {
     echo -e "${BLUE}$1${RESET}"
     echo "========================================"
   }
   
   function it() {
     CURRENT_TEST="$1"
     echo -n "  - $CURRENT_TEST ... "
   }
   
   function assert_equals() {
     local actual="$1"
     local expected="$2"
     local message="${3:-Expected '$actual' to equal '$expected'}"
     
     TEST_COUNT=$((TEST_COUNT + 1))
     
     if [[ "$actual" == "$expected" ]]; then
       PASS_COUNT=$((PASS_COUNT + 1))
       echo -e "${GREEN}PASS${RESET}"
     else
       FAIL_COUNT=$((FAIL_COUNT + 1))
       echo -e "${RED}FAIL${RESET}"
       echo -e "    ${RED}$message${RESET}"
     fi
   }
   
   function assert_not_equals() {
     local actual="$1"
     local expected="$2"
     local message="${3:-Expected '$actual' to not equal '$expected'}"
     
     TEST_COUNT=$((TEST_COUNT + 1))
     
     if [[ "$actual" != "$expected" ]]; then
       PASS_COUNT=$((PASS_COUNT + 1))
       echo -e "${GREEN}PASS${RESET}"
     else
       FAIL_COUNT=$((FAIL_COUNT + 1))
       echo -e "${RED}FAIL${RESET}"
       echo -e "    ${RED}$message${RESET}"
     fi
   }
   
   function assert_contains() {
     local haystack="$1"
     local needle="$2"
     local message="${3:-Expected '$haystack' to contain '$needle'}"
     
     TEST_COUNT=$((TEST_COUNT + 1))
     
     if [[ "$haystack" == *"$needle"* ]]; then
       PASS_COUNT=$((PASS_COUNT + 1))
       echo -e "${GREEN}PASS${RESET}"
     else
       FAIL_COUNT=$((FAIL_COUNT + 1))
       echo -e "${RED}FAIL${RESET}"
       echo -e "    ${RED}$message${RESET}"
     fi
   }
   
   function assert_exit_code() {
     local command="$1"
     local expected_code="${2:-0}"
     local message="${3:-Expected command to exit with code $expected_code}"
     
     TEST_COUNT=$((TEST_COUNT + 1))
     
     # Create temp files for output and error
     local temp_stdout=$(mktemp)
     local temp_stderr=$(mktemp)
     
     # Run command and capture output
     eval "$command" > "$temp_stdout" 2> "$temp_stderr" || true
     local actual_code="$?"
     
     # Set global outputs
     TEST_OUTPUT=$(cat "$temp_stdout")
     ERROR_OUTPUT=$(cat "$temp_stderr")
     
     # Clean up temp files
     rm -f "$temp_stdout" "$temp_stderr"
     
     if [[ "$actual_code" -eq "$expected_code" ]]; then
       PASS_COUNT=$((PASS_COUNT + 1))
       echo -e "${GREEN}PASS${RESET}"
     else
       FAIL_COUNT=$((FAIL_COUNT + 1))
       echo -e "${RED}FAIL${RESET}"
       echo -e "    ${RED}Command exited with code $actual_code, $message${RESET}"
       
       if [[ -n "$ERROR_OUTPUT" ]]; then
         echo -e "    ${RED}Error output: $ERROR_OUTPUT${RESET}"
       fi
     fi
   }
   
   function assert_file_exists() {
     local file="$1"
     local message="${2:-Expected file to exist: $file}"
     
     TEST_COUNT=$((TEST_COUNT + 1))
     
     if [[ -f "$file" ]]; then
       PASS_COUNT=$((PASS_COUNT + 1))
       echo -e "${GREEN}PASS${RESET}"
     else
       FAIL_COUNT=$((FAIL_COUNT + 1))
       echo -e "${RED}FAIL${RESET}"
       echo -e "    ${RED}$message${RESET}"
     fi
   }
   
   function assert_directory_exists() {
     local directory="$1"
     local message="${2:-Expected directory to exist: $directory}"
     
     TEST_COUNT=$((TEST_COUNT + 1))
     
     if [[ -d "$directory" ]]; then
       PASS_COUNT=$((PASS_COUNT + 1))
       echo -e "${GREEN}PASS${RESET}"
     else
       FAIL_COUNT=$((FAIL_COUNT + 1))
       echo -e "${RED}FAIL${RESET}"
       echo -e "    ${RED}$message${RESET}"
     fi
   }
   
   function run_test_suite() {
     local test_file="$1"
     
     if [[ ! -f "$test_file" ]]; then
       echo -e "${RED}Test file not found: $test_file${RESET}"
       return 1
     fi
     
     echo -e "${BLUE}Running test suite: $test_file${RESET}"
     echo "========================================"
     
     # Reset counters
     TEST_COUNT=0
     PASS_COUNT=0
     FAIL_COUNT=0
     
     # Run the test file
     source "$test_file"
     
     # Print summary
     echo "========================================"
     echo -e "${BLUE}Test Results:${RESET}"
     echo -e "  ${BLUE}Total:${RESET} $TEST_COUNT"
     echo -e "  ${GREEN}Passed:${RESET} $PASS_COUNT"
     echo -e "  ${RED}Failed:${RESET} $FAIL_COUNT"
     echo "========================================"
     
     # Return success if all tests passed
     if [[ $FAIL_COUNT -eq 0 ]]; then
       return 0
     else
       return 1
     fi
   }
   
   # If this script is run directly, display usage
   if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
     if [[ $# -eq 0 ]]; then
       echo "Usage: $(basename "$0") <test_file>"
       echo
       echo "Example: $(basename "$0") my_tests.sh"
       exit 1
     fi
     
     # Run the specified test suite
     run_test_suite "$1"
     exit $?
   fi
   ```

2. **Create a test file for a simple function library**:
   ```bash
   # Create a simple library to test
   mkdir -p ~/scripts/lib
   touch ~/scripts/lib/math.sh
   chmod +x ~/scripts/lib/math.sh
   
   # Create a test file for the math library
   mkdir -p ~/scripts/tests
   touch ~/scripts/tests/math_test.sh
   chmod +x ~/scripts/tests/math_test.sh
   ```

   Add the following content to the math library:
   ```bash
   #!/bin/bash
   #
   # Library name: math.sh
   # Description: Simple math functions
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Ensure this file is sourced, not executed
   if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
     echo "Error: This script should be sourced, not executed."
     exit 1
   fi
   
   # Add two numbers
   function add() {
     local a="$1"
     local b="$2"
     
     # Validate input
     if [[ ! "$a" =~ ^-?[0-9]+$ || ! "$b" =~ ^-?[0-9]+$ ]]; then
       echo "Error: Inputs must be integers" >&2
       return 1
     fi
     
     echo $((a + b))
     return 0
   }
   
   # Subtract b from a
   function subtract() {
     local a="$1"
     local b="$2"
     
     # Validate input
     if [[ ! "$a" =~ ^-?[0-9]+$ || ! "$b" =~ ^-?[0-9]+$ ]]; then
       echo "Error: Inputs must be integers" >&2
       return 1
     fi
     
     echo $((a - b))
     return 0
   }
   
   # Multiply two numbers
   function multiply() {
     local a="$1"
     local b="$2"
     
     # Validate input
     if [[ ! "$a" =~ ^-?[0-9]+$ || ! "$b" =~ ^-?[0-9]+$ ]]; then
       echo "Error: Inputs must be integers" >&2
       return 1
     fi
     
     echo $((a * b))
     return 0
   }
   
   # Divide a by b
   function divide() {
     local a="$1"
     local b="$2"
     
     # Validate input
     if [[ ! "$a" =~ ^-?[0-9]+$ || ! "$b" =~ ^-?[0-9]+$ ]]; then
       echo "Error: Inputs must be integers" >&2
       return 1
     fi
     
     # Check for division by zero
     if [[ "$b" -eq 0 ]]; then
       echo "Error: Division by zero" >&2
       return 1
     fi
     
     echo $((a / b))
     return 0
   }
   
   # Check if a number is prime
   function is_prime() {
     local num="$1"
     
     # Validate input
     if [[ ! "$num" =~ ^[0-9]+$ ]]; then
       echo "Error: Input must be a positive integer" >&2
       return 1
     fi
     
     # Special cases
     if [[ "$num" -lt 2 ]]; then
       echo "false"
       return 0
     fi
     
     if [[ "$num" -eq 2 || "$num" -eq 3 ]]; then
       echo "true"
       return 0
     fi
     
     # Check if number is divisible by 2
     if [[ $((num % 2)) -eq 0 ]]; then
       echo "false"
       return 0
     fi
     
     # Check odd divisors up to square root
     local sqrt
     sqrt=$(awk "BEGIN {printf \"%d\", sqrt($num)}")
     
     for (( i=3; i<=sqrt; i+=2 )); do
       if [[ $((num % i)) -eq 0 ]]; then
         echo "false"
         return 0
       fi
     done
     
     echo "true"
     return 0
   }
   ```

   Add the following content to the test file:
   ```bash
   #!/bin/bash
   #
   # Test name: math_test.sh
   # Description: Tests for the math library
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Source the test framework
   source ~/scripts/test_framework/test.sh
   
   # Source the library to test
   source ~/scripts/lib/math.sh
   
   # Test the add function
   describe "add function"
   
   it "adds two positive numbers"
   result=$(add 5 3)
   assert_equals "$result" "8"
   
   it "adds a positive and negative number"
   result=$(add 5 -3)
   assert_equals "$result" "2"
   
   it "adds two negative numbers"
   result=$(add -5 -3)
   assert_equals "$result" "-8"
   
   it "rejects non-numeric input"
   assert_exit_code "add abc 3" 1
   
   # Test the subtract function
   describe "subtract function"
   
   it "subtracts two positive numbers"
   result=$(subtract 5 3)
   assert_equals "$result" "2"
   
   it "subtracts with negative result"
   result=$(subtract 3 5)
   assert_equals "$result" "-2"
   
   it "subtracts with negative input"
   result=$(subtract 5 -3)
   assert_equals "$result" "8"
   
   it "rejects non-numeric input"
   assert_exit_code "subtract 5 xyz" 1
   
   # Test the multiply function
   describe "multiply function"
   
   it "multiplies two positive numbers"
   result=$(multiply 5 3)
   assert_equals "$result" "15"
   
   it "multiplies by zero"
   result=$(multiply 5 0)
   assert_equals "$result" "0"
   
   it "multiplies with negative input"
   result=$(multiply 5 -3)
   assert_equals "$result" "-15"
   
   it "rejects non-numeric input"
   assert_exit_code "multiply abc 3" 1
   
   # Test the divide function
   describe "divide function"
   
   it "divides two positive numbers"
   result=$(divide 6 3)
   assert_equals "$result" "2"
   
   it "performs integer division"
   result=$(divide 5 2)
   assert_equals "$result" "2"  # Integer division
   
   it "rejects division by zero"
   assert_exit_code "divide 5 0" 1
   assert_contains "$ERROR_OUTPUT" "Division by zero"
   
   # Test the is_prime function
   describe "is_prime function"
   
   it "identifies prime numbers"
   result=$(is_prime 17)
   assert_equals "$result" "true"
   
   it "identifies non-prime numbers"
   result=$(is_prime 4)
   assert_equals "$result" "false"
   
   it "correctly handles edge cases"
   result=$(is_prime 0)
   assert_equals "$result" "false"
   
   result=$(is_prime 1)
   assert_equals "$result" "false"
   
   result=$(is_prime 2)
   assert_equals "$result" "true"
   ```

3. **Run the tests**:
   ```bash
   # Run the test suite
   ~/scripts/test_framework/test.sh ~/scripts/tests/math_test.sh
   ```

## Exercise 3: Automation with Systemd and Cron

### Create a Systemd Timer for Regular Maintenance

1. **Create a system maintenance script**:
   ```bash
   # Create a system maintenance script
   touch ~/scripts/system_maintenance.sh
   chmod +x ~/scripts/system_maintenance.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: system_maintenance.sh
   # Description: Performs routine system maintenance tasks
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Configuration
   LOG_FILE="/var/log/system_maintenance.log"
   LOCK_FILE="/tmp/system_maintenance.lock"
   
   # Ensure we're running as root
   if [[ $EUID -ne 0 ]]; then
     echo "This script must be run as root"
     exit 1
   fi
   
   # Logging function
   function log() {
     local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
     echo "[$timestamp] $1" | tee -a "$LOG_FILE"
   }
   
   # Check for lock file to prevent concurrent runs
   if [[ -f "$LOCK_FILE" ]]; then
     pid=$(cat "$LOCK_FILE")
     if ps -p "$pid" &>/dev/null; then
       log "Another instance is already running with PID $pid"
       exit 1
     else
       log "Removing stale lock file"
       rm -f "$LOCK_FILE"
     fi
   fi
   
   # Create lock file
   echo $ > "$LOCK_FILE"
   
   # Clean up on exit
   trap 'rm -f "$LOCK_FILE"' EXIT
   
   # Log start
   log "Starting system maintenance"
   
   # 1. Update package lists
   log "Updating package lists"
   if pacman -Sy; then
     log "Package lists updated successfully"
   else
     log "Failed to update package lists"
   fi
   
   # 2. Clean package cache
   log "Cleaning package cache"
   if pacman -Sc --noconfirm; then
     log "Package cache cleaned successfully"
   else
     log "Failed to clean package cache"
   fi
   
   # 3. Check for and remove orphaned packages
   log "Checking for orphaned packages"
   orphans=$(pacman -Qtdq)
   if [[ -n "$orphans" ]]; then
     log "Found orphaned packages, removing"
     if pacman -Rns $orphans --noconfirm; then
       log "Orphaned packages removed successfully"
     else
       log "Failed to remove orphaned packages"
     fi
   else
     log "No orphaned packages found"
   fi
   
   # 4. Clean systemd journal
   log "Cleaning systemd journal"
   if journalctl --vacuum-time=7d; then
     log "Journal cleaned successfully"
   else
     log "Failed to clean journal"
   fi
   
   # 5. Clean temporary files
   log "Cleaning temporary files"
   find /tmp -type f -atime +7 -delete 2>/dev/null
   find /var/tmp -type f -atime +30 -delete 2>/dev/null
   log "Temporary files cleaned"
   
   # 6. Check disk usage
   log "Checking disk usage"
   df -h | grep -E '^/dev/' | while read -r line; do
     filesystem=$(echo "$line" | awk '{print $1}')
     usage=$(echo "$line" | awk '{print $5}' | tr -d '%')
     if [[ "$usage" -gt 90 ]]; then
       log "WARNING: High disk usage on $filesystem: $usage%"
     fi
   done
   
   # 7. Check system load
   log "Checking system load"
   load=$(uptime | awk -F'load average: ' '{print $2}' | cut -d, -f1)
   if awk "BEGIN {exit !($load > 2.0)}"; then
     log "WARNING: High system load: $load"
   else
     log "System load normal: $load"
   fi
   
   # Log completion
   log "System maintenance completed"
   exit 0
   ```

2. **Create systemd service and timer units**:
   ```bash
   # Create a directory for user systemd units
   mkdir -p ~/.config/systemd/user
   
   # Create the service unit
   touch ~/.config/systemd/user/system-maintenance.service
   
   # Create the timer unit
   touch ~/.config/systemd/user/system-maintenance.timer
   ```

   Add the following content to the service unit:
   ```
   [Unit]
   Description=System Maintenance Service
   After=network.target
   
   [Service]
   Type=oneshot
   ExecStart=/bin/bash %h/scripts/system_maintenance.sh
   
   [Install]
   WantedBy=default.target
   ```

   Add the following content to the timer unit:
   ```
   [Unit]
   Description=Run System Maintenance Daily
   
   [Timer]
   OnCalendar=daily
   Persistent=true
   RandomizedDelaySec=1hour
   
   [Install]
   WantedBy=timers.target
   ```

3. **Enable and start the timer**:
   ```bash
   # Reload systemd user configuration
   systemctl --user daemon-reload
   
   # Enable the timer to run at startup
   systemctl --user enable system-maintenance.timer
   
   # Start the timer
   systemctl --user start system-maintenance.timer
   
   # Check timer status
   systemctl --user list-timers system-maintenance.timer
   ```

   Note: For system-wide maintenance, you would need to place these files in `/etc/systemd/system/` and run the commands without the `--user` flag, which requires root permissions.

### Set Up Advanced Cron Jobs with Environment Control

1. **Create a script for environment-aware cron jobs**:
   ```bash
   # Create a cron wrapper script
   touch ~/scripts/cron_wrapper.sh
   chmod +x ~/scripts/cron_wrapper.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: cron_wrapper.sh
   # Description: Wrapper for cron jobs with proper environment setup
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Configuration
   LOG_DIR="$HOME/logs/cron"
   DATE_FORMAT=$(date +"%Y%m%d-%H%M%S")
   
   # Create log directory
   mkdir -p "$LOG_DIR"
   
   # Handle missing command
   if [[ $# -lt 1 ]]; then
     echo "Usage: $(basename "$0") <command> [args...]" >&2
     exit 1
   fi
   
   # Extract command and arguments
   cmd="$1"
   shift
   cmd_name=$(basename "$cmd")
   args=("$@")
   
   # Set up environment
   # 1. Load profile if it exists
   if [[ -f "$HOME/.bash_profile" ]]; then
     source "$HOME/.bash_profile"
   elif [[ -f "$HOME/.profile" ]]; then
     source "$HOME/.profile"
   fi
   
   # 2. Load .bashrc if it exists
   if [[ -f "$HOME/.bashrc" ]]; then
     source "$HOME/.bashrc"
   fi
   
   # 3. Set PATH to include common directories
   export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH"
   
   # Log file for this execution
   LOG_FILE="$LOG_DIR/${cmd_name}-${DATE_FORMAT}.log"
   
   # Execute command and log output
   {
     echo "========================================"
     echo "Running: $cmd ${args[*]}"
     echo "Date: $(date)"
     echo "User: $(whoami)"
     echo "Working Directory: $(pwd)"
     echo "Environment:"
     echo "  PATH: $PATH"
     echo "  HOME: $HOME"
     echo "  SHELL: $SHELL"
     echo "========================================"
     echo
     
     # Execute the command
     start_time=$(date +%s)
     
     "$cmd" "${args[@]}"
     exit_code=$?
     
     end_time=$(date +%s)
     duration=$((end_time - start_time))
     
     echo
     echo "========================================"
     echo "Command completed with exit code: $exit_code"
     echo "Execution time: $duration seconds"
     echo "========================================"
   } &> "$LOG_FILE"
   
   # Exit with the same exit code as the command
   exit $exit_code
   ```

2. **Create a sample script to run via cron**:
   ```bash
   # Create a sample script
   touch ~/scripts/daily_report.sh
   chmod +x ~/scripts/daily_report.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: daily_report.sh
   # Description: Generates a daily system report
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Output file
   REPORT_DIR="$HOME/reports"
   REPORT_FILE="$REPORT_DIR/system_report_$(date +"%Y%m%d").txt"
   
   # Create reports directory
   mkdir -p "$REPORT_DIR"
   
   # Generate report
   {
     echo "========================================"
     echo "System Report - $(date)"
     echo "========================================"
     echo
     
     echo "System Information:"
     echo "------------------"
     echo "Hostname: $(hostname)"
     echo "Kernel: $(uname -r)"
     echo "Uptime: $(uptime)"
     echo
     
     echo "CPU Information:"
     echo "---------------"
     lscpu | grep -E "Model name|Architecture|CPU\(s\)|Thread"
     echo
     
     echo "Memory Usage:"
     echo "-------------"
     free -h
     echo
     
     echo "Disk Usage:"
     echo "-----------"
     df -h
     echo
     
     echo "Top 5 CPU Processes:"
     echo "-------------------"
     ps aux --sort=-%cpu | head -6
     echo
     
     echo "Top 5 Memory Processes:"
     echo "----------------------"
     ps aux --sort=-%mem | head -6
     echo
     
     echo "Recent Logins:"
     echo "-------------"
     last | head -10
     echo
     
     echo "========================================"
     echo "Report generated on $(date)"
     echo "========================================"
   } > "$REPORT_FILE"
   
   echo "Report generated: $REPORT_FILE"
   exit 0
   ```

3. **Set up a cron job using the wrapper**:
   ```bash
   # Edit crontab
   crontab -e
   ```

   Add the following line to run the daily report at 7:00 AM:
   ```
   # Environment setup
   PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin
   SHELL=/bin/bash
   MAILTO=""
   
   # Daily system report at 7:00 AM
   0 7 * * * $HOME/scripts/cron_wrapper.sh $HOME/scripts/daily_report.sh
   ```

4. **Test the cron job immediately**:
   ```bash
   # Run the cron wrapper manually
   ~/scripts/cron_wrapper.sh ~/scripts/daily_report.sh
   
   # Check the log
   ls -la ~/logs/cron/
   cat ~/logs/cron/daily_report.sh-*.log
   
   # Check the report
   ls -la ~/reports/
   cat ~/reports/system_report_*.txt
   ```

### Create a Job Monitoring Dashboard

1. **Create a library for job status tracking**:
   ```bash
   # Create a job status library
   touch ~/scripts/lib/job_status.sh
   chmod +x ~/scripts/lib/job_status.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Library name: job_status.sh
   # Description: Functions for tracking job status
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Ensure this file is sourced, not executed
   if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
     echo "Error: This script should be sourced, not executed."
     exit 1
   fi
   
   # Configuration
   : "${STATUS_DIR:=$HOME/job_status}"
   
   # Ensure status directory exists
   mkdir -p "$STATUS_DIR"
   
   # Job status constants
   readonly JOB_STATUS_PENDING="PENDING"
   readonly JOB_STATUS_RUNNING="RUNNING"
   readonly JOB_STATUS_SUCCESS="SUCCESS"
   readonly JOB_STATUS_FAILED="FAILED"
   readonly JOB_STATUS_WARNING="WARNING"
   
   # Update job status
   function job_update_status() {
     local job_name="$1"
     local status="$2"
     local message="${3:-}"
     local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
     local status_file="$STATUS_DIR/$job_name.status"
     
     # Create or overwrite status file
     cat > "$status_file" << EOF
   timestamp=$timestamp
   status=$status
   message=$message
   start_time=${JOB_START_TIME:-}
   end_time=${JOB_END_TIME:-}
   duration=${JOB_DURATION:-}
   exit_code=${JOB_EXIT_CODE:-}
   hostname=$(hostname)
   EOF
     
     return 0
   }
   
   # Get job status
   function job_get_status() {
     local job_name="$1"
     local status_file="$STATUS_DIR/$job_name.status"
     
     if [[ ! -f "$status_file" ]]; then
       echo "UNKNOWN"
       return 1
     fi
     
     grep -E "^status=" "$status_file" | cut -d= -f2
     return 0
   }
   
   # Start job tracking
   function job_start() {
     local job_name="$1"
     local message="${2:-Starting job}"
     
     # Record start time
     JOB_START_TIME=$(date +"%Y-%m-%d %H:%M:%S")
     
     # Update status
     job_update_status "$job_name" "$JOB_STATUS_RUNNING" "$message"
     
     return 0
   }
   
   # End job tracking
   function job_end() {
     local job_name="$1"
     local exit_code="$2"
     local message="${3:-}"
     
     # Record end time
     JOB_END_TIME=$(date +"%Y-%m-%d %H:%M:%S")
     
     # Calculate duration
     local start_seconds=$(date -d "$JOB_START_TIME" +%s)
     local end_seconds=$(date -d "$JOB_END_TIME" +%s)
     JOB_DURATION=$((end_seconds - start_seconds))
     
     # Record exit code
     JOB_EXIT_CODE="$exit_code"
     
     # Determine status based on exit code
     local status
     if [[ "$exit_code" -eq 0 ]]; then
       status="$JOB_STATUS_SUCCESS"
       message="${message:-Job completed successfully}"
     else
       status="$JOB_STATUS_FAILED"
       message="${message:-Job failed with exit code $exit_code}"
     fi
     
     # Update status
     job_update_status "$job_name" "$status" "$message"
     
     return 0
   }
   
   # Get all job status information
   function job_list_all() {
     for status_file in "$STATUS_DIR"/*.status; do
       if [[ -f "$status_file" ]]; then
         job_name=$(basename "$status_file" .status)
         status=$(grep -E "^status=" "$status_file" | cut -d= -f2)
         timestamp=$(grep -E "^timestamp=" "$status_file" | cut -d= -f2)
         message=$(grep -E "^message=" "$status_file" | cut -d= -f2)
         
         echo "$job_name|$status|$timestamp|$message"
       fi
     done
     
     return 0
   }
   ```

2. **Create a script to generate a status dashboard**:
   ```bash
   # Create a dashboard generator script
   touch ~/scripts/generate_dashboard.sh
   chmod +x ~/scripts/generate_dashboard.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: generate_dashboard.sh
   # Description: Generates a HTML dashboard for job status
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Source the job status library
   source ~/scripts/lib/job_status.sh
   
   # Configuration
   DASHBOARD_DIR="$HOME/dashboard"
   DASHBOARD_FILE="$DASHBOARD_DIR/index.html"
   REFRESH_INTERVAL=60  # Refresh interval in seconds
   
   # Create dashboard directory
   mkdir -p "$DASHBOARD_DIR"
   
   # Generate dashboard HTML
   cat > "$DASHBOARD_FILE" << EOF
   <!DOCTYPE html>
   <html lang="en">
   <head>
     <meta charset="UTF-8">
     <meta name="viewport" content="width=device-width, initial-scale=1.0">
     <meta http-equiv="refresh" content="$REFRESH_INTERVAL">
     <title>Job Status Dashboard</title>
     <style>
       body {
         font-family: Arial, sans-serif;
         margin: 0;
         padding: 20px;
         background-color: #f5f5f5;
       }
       h1 {
         color: #333;
         margin-bottom: 20px;
       }
       .dashboard {
         background-color: #fff;
         border-radius: 5px;
         box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
         padding: 20px;
       }
       .summary {
         display: flex;
         margin-bottom: 20px;
       }
       .summary-box {
         flex: 1;
         padding: 15px;
         border-radius: 5px;
         margin-right: 10px;
         color: #fff;
         text-align: center;
       }
       .summary-box:last-child {
         margin-right: 0;
       }
       .box-total { background-color: #2196F3; }
       .box-success { background-color: #4CAF50; }
       .box-failed { background-color: #F44336; }
       .box-running { background-color: #FF9800; }
       .box-pending { background-color: #9E9E9E; }
       
       table {
         width: 100%;
         border-collapse: collapse;
       }
       th, td {
         padding: 12px 15px;
         text-align: left;
         border-bottom: 1px solid #ddd;
       }
       th {
         background-color: #f2f2f2;
         font-weight: bold;
       }
       tr:hover {
         background-color: #f5f5f5;
       }
       .status {
         padding: 5px 10px;
         border-radius: 3px;
         color: #fff;
         font-weight: bold;
       }
       .status-SUCCESS { background-color: #4CAF50; }
       .status-FAILED { background-color: #F44336; }
       .status-RUNNING { background-color: #FF9800; }
       .status-PENDING { background-color: #9E9E9E; }
       .status-WARNING { background-color: #FF5722; }
       
       .footer {
         margin-top: 20px;
         text-align: center;
         color: #777;
         font-size: 14px;
       }
     </style>
   </head>
   <body>
     <div class="dashboard">
       <h1>Job Status Dashboard</h1>
       
       <div class="summary">
   EOF
   
   # Get job counts
   total_jobs=0
   success_jobs=0
   failed_jobs=0
   running_jobs=0
   pending_jobs=0
   
   while IFS="|" read -r job status timestamp message || [[ -n "$job" ]]; do
     if [[ -z "$job" ]]; then
       continue
     fi
     
     total_jobs=$((total_jobs + 1))
     
     case "$status" in
       "$JOB_STATUS_SUCCESS") success_jobs=$((success_jobs + 1)) ;;
       "$JOB_STATUS_FAILED") failed_jobs=$((failed_jobs + 1)) ;;
       "$JOB_STATUS_RUNNING") running_jobs=$((running_jobs + 1)) ;;
       "$JOB_STATUS_PENDING") pending_jobs=$((pending_jobs + 1)) ;;
     esac
   done < <(job_list_all)
   
   # Add summary boxes to dashboard
   cat >> "$DASHBOARD_FILE" << EOF
         <div class="summary-box box-total">
           <h2>Total Jobs</h2>
           <h3>$total_jobs</h3>
         </div>
         <div class="summary-box box-success">
           <h2>Successful</h2>
           <h3>$success_jobs</h3>
         </div>
         <div class="summary-box box-failed">
           <h2>Failed</h2>
           <h3>$failed_jobs</h3>
         </div>
         <div class="summary-box box-running">
           <h2>Running</h2>
           <h3>$running_jobs</h3>
         </div>
         <div class="summary-box box-pending">
           <h2>Pending</h2>
           <h3>$pending_jobs</h3>
         </div>
       </div>
       
       <table>
         <thead>
           <tr>
             <th>Job Name</th>
             <th>Status</th>
             <th>Last Updated</th>
             <th>Message</th>
           </tr>
         </thead>
         <tbody>
   EOF
   
   # Add job rows to dashboard
   while IFS="|" read -r job status timestamp message || [[ -n "$job" ]]; do
     if [[ -z "$job" ]]; then
       continue
     fi
     
     cat >> "$DASHBOARD_FILE" << EOF
           <tr>
             <td>$job</td>
             <td><span class="status status-$status">$status</span></td>
             <td>$timestamp</td>
             <td>$message</td>
           </tr>
   EOF
   done < <(job_list_all)
   
   # Complete the HTML file
   cat >> "$DASHBOARD_FILE" << EOF
         </tbody>
       </table>
       
       <div class="footer">
         <p>Last updated: $(date)</p>
         <p>Auto-refreshes every $REFRESH_INTERVAL seconds</p>
       </div>
     </div>
   </body>
   </html>
   EOF
   
   echo "Dashboard generated: $DASHBOARD_FILE"
   exit 0
   ```

3. **Create a sample job script for testing**:
   ```bash
   # Create a sample job script
   touch ~/scripts/sample_job.sh
   chmod +x ~/scripts/sample_job.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: sample_job.sh
   # Description: Sample job script for testing job status tracking
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Source the job status library
   source ~/scripts/lib/job_status.sh
   
   # Configuration
   JOB_NAME="${1:-sample_job}"
   DURATION="${2:-10}"
   SUCCESS_RATE="${3:-80}"
   
   # Start job
   job_start "$JOB_NAME" "Starting $JOB_NAME with duration $DURATION seconds"
   
   # Simulate work
   echo "Job $JOB_NAME is running..."
   sleep "$DURATION"
   
   # Determine success or failure
   random=$((RANDOM % 100 + 1))
   if [[ "$random" -le "$SUCCESS_RATE" ]]; then
     # Job succeeded
     echo "Job $JOB_NAME completed successfully"
     job_end "$JOB_NAME" 0 "Job completed successfully"
     exit 0
   else
     # Job failed
     echo "Job $JOB_NAME failed"
     job_end "$JOB_NAME" 1 "Job failed with random error"
     exit 1
   fi
   ```

4. **Test the job monitoring setup**:
   ```bash
   # Run several jobs
   ~/scripts/sample_job.sh backup_job 5 90
   ~/scripts/sample_job.sh cleanup_job 3 70
   ~/scripts/sample_job.sh report_job 4 60
   
   # Generate the dashboard
   ~/scripts/generate_dashboard.sh
   
   # View the dashboard
   # You can open the HTML file in a browser
   # For a text-based preview, you can use:
   cat ~/dashboard/index.html
   ```

5. **Schedule regular dashboard updates**:
   ```bash
   # Add to crontab
   crontab -e
   ```

   Add this line to regenerate the dashboard every 5 minutes:
   ```
   */5 * * * * $HOME/scripts/generate_dashboard.sh
   ```

## Exercise 4: Building Command-Line Tools and Integration

### Create a Command-Line Tool with Subcommands

1. **Create a file management CLI tool**:
   ```bash
   # Create a file management tool
   mkdir -p ~/scripts/file-manager
   touch ~/scripts/file-manager/file-manager.sh
   chmod +x ~/scripts/file-manager/file-manager.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: file-manager.sh
   # Description: A command-line file management tool
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Script version
   VERSION="1.0.0"
   
   # Configuration
   CONFIG_DIR="$HOME/.config/file-manager"
   CONFIG_FILE="$CONFIG_DIR/config.ini"
   DEFAULT_WORKSPACE="$HOME/workspace"
   
   # Ensure configuration directory exists
   mkdir -p "$CONFIG_DIR"
   
   # Create default configuration if it doesn't exist
   if [[ ! -f "$CONFIG_FILE" ]]; then
     cat > "$CONFIG_FILE" << EOF
   # File Manager Configuration
   
   # Default workspace directory
   workspace=$DEFAULT_WORKSPACE
   
   # Default backup directory
   backup_dir=$HOME/backups
   
   # File extensions to skip in operations
   skip_extensions=.tmp,.bak,.swp
   
   # Default compression format (zip, tar, gz)
   compression=zip
   
   # Enable verbose output (true/false)
   verbose=false
   EOF
   fi
   
   # Load configuration
   if [[ -f "$CONFIG_FILE" ]]; then
     # Extract configuration variables
     workspace=$(grep -E "^workspace=" "$CONFIG_FILE" | cut -d= -f2)
     backup_dir=$(grep -E "^backup_dir=" "$CONFIG_FILE" | cut -d= -f2)
     skip_extensions=$(grep -E "^skip_extensions=" "$CONFIG_FILE" | cut -d= -f2)
     compression=$(grep -E "^compression=" "$CONFIG_FILE" | cut -d= -f2)
     verbose=$(grep -E "^verbose=" "$CONFIG_FILE" | cut -d= -f2)
   else
     # Use defaults
     workspace="$DEFAULT_WORKSPACE"
     backup_dir="$HOME/backups"
     skip_extensions=".tmp,.bak,.swp"
     compression="zip"
     verbose="false"
   fi
   
   # Create workspace if it doesn't exist
   if [[ ! -d "$workspace" ]]; then
     mkdir -p "$workspace"
   fi
   
   # Create backup directory if it doesn't exist
   if [[ ! -d "$backup_dir" ]]; then
     mkdir -p "$backup_dir"
   fi
   
   # Verbose output function
   function verbose_output() {
     if [[ "$verbose" == "true" ]]; then
       echo "$1"
     fi
   }
   
   # Display help
   function display_help() {
     cat << EOF
   File Manager - A command-line file management tool
   
   Usage:
     $(basename "$0") [options] <command> [command-options]
   
   Options:
     -h, --help              Display this help message
     -v, --verbose           Enable verbose output
     -w, --workspace DIR     Set the workspace directory
     -b, --backup-dir DIR    Set the backup directory
     --version               Display version information
   
   Commands:
     ls, list                List files in the workspace
     find <pattern>          Find files matching pattern
     organize               Organize files by type
     clean                   Clean up temporary files
     backup [name]           Create a backup
     restore <backup>        Restore from backup
     stats                   Show file statistics
     config                  Show or edit configuration
   
   Examples:
     $(basename "$0") list
     $(basename "$0") find "*.txt"
     $(basename "$0") --workspace ~/documents organize
     $(basename "$0") backup "project-backup"
   
   For more information on each command, run:
     $(basename "$0") <command> --help
   EOF
   }
   
   # Display version
   function display_version() {
     echo "File Manager version $VERSION"
     echo "Copyright (c) $(date +%Y) Your Name"
   }
   
   # List files command
   function cmd_list() {
     local sort_by="name"
     local reverse=false
     local pattern="*"
     
     # Parse command options
     while [[ $# -gt 0 ]]; do
       case "$1" in
         --sort=*)
           sort_by="${1#*=}"
           shift
           ;;
         --reverse)
           reverse=true
           shift
           ;;
         --pattern=*)
           pattern="${1#*=}"
           shift
           ;;
         --help)
           echo "Usage: $(basename "$0") list [options]"
           echo
           echo "Options:"
           echo "  --sort=FIELD    Sort by: name, size, time (default: name)"
           echo "  --reverse       Reverse the sort order"
           echo "  --pattern=GLOB  File pattern to match (default: *)"
           echo
           echo "Examples:"
           echo "  $(basename "$0") list"
           echo "  $(basename "$0") list --sort=size --reverse"
           echo "  $(basename "$0") list --pattern=\"*.txt\""
           return 0
           ;;
         *)
           echo "Error: Unknown option for list command: $1" >&2
           return 1
           ;;
       esac
     done
     
     verbose_output "Listing files in $workspace"
     verbose_output "Sort by: $sort_by (reverse: $reverse)"
     verbose_output "Pattern: $pattern"
     
     # Build find command
     find_opts=("$workspace" -type f -name "$pattern")
     
     # Sort options
     if [[ "$sort_by" == "size" ]]; then
       if [[ "$reverse" == "true" ]]; then
         sort_opts=(-k5,5nr)  # Sort by size column, numeric, reverse
       else
         sort_opts=(-k5,5n)   # Sort by size column, numeric
       fi
     elif [[ "$sort_by" == "time" ]]; then
       if [[ "$reverse" == "true" ]]; then
         sort_opts=(-k6,7r)   # Sort by date columns, reverse
       else
         sort_opts=(-k6,7)    # Sort by date columns
       fi
     else  # Sort by name
       if [[ "$reverse" == "true" ]]; then
         sort_opts=(-k8r)     # Sort by name column, reverse
       else
         sort_opts=(-k8)      # Sort by name column
       fi
     fi
     
     # Execute command
     echo "Workspace: $workspace"
     echo
     
     echo "Mode      | Size     | Modified           | Name"
     echo "----------|----------|--------------------|-----------------"
     
     find "${find_opts[@]}" -printf "%M | %8s | %TY-%Tm-%Td %TH:%TM | %P\n" | sort "${sort_opts | sort | uniq)
       
       # Print statistics for each extension
       echo "  Extension | Count |  Size   | Percentage"
       echo "  ----------|-------|---------|------------"
       
       while IFS= read -r ext; do
         if [[ -z "$ext" ]]; then
           continue
         fi
         
         # Count files with this extension
         local count=$(echo "$all_files" | grep -c "$ext$")
         
         # Calculate size of files with this extension
         local size=0
         while IFS= read -r file; do
           if [[ -f "$file" ]]; then
             size=$((size + $(stat -c %s "$file")))
           fi
         done < <(echo "$all_files" | grep "$ext$")
         
         # Format size
         local ext_size_human
         if [[ "$size" -gt 1073741824 ]]; then  # 1 GB
           ext_size_human=$(awk "BEGIN {printf \"%.2f GB\", $size/1073741824}")
         elif [[ "$size" -gt 1048576 ]]; then  # 1 MB
           ext_size_human=$(awk "BEGIN {printf \"%.2f MB\", $size/1048576}")
         elif [[ "$size" -gt 1024 ]]; then  # 1 KB
           ext_size_human=$(awk "BEGIN {printf \"%.2f KB\", $size/1024}")
         else
           ext_size_human="$size bytes"
         fi
         
         # Calculate percentage
         local percentage=$(awk "BEGIN {printf \"%.2f%%\", ($size/$total_size)*100}")
         
         # Print statistics
         printf "  %-10s| %-5d | %-7s | %-10s\n" "$ext" "$count" "$ext_size_human" "$percentage"
       done <<< "$extensions"
     fi
     
     return 0
   }
   
   # Config command
   function cmd_config() {
     local edit=false
     local option=""
     local value=""
     
     # Parse command options
     while [[ $# -gt 0 ]]; do
       case "$1" in
         --edit)
           edit=true
           shift
           ;;
         --set)
           option="$2"
           value="$3"
           shift 3
           ;;
         --help)
           echo "Usage: $(basename "$0") config [options]"
           echo
           echo "Options:"
           echo "  --edit              Open configuration file in editor"
           echo "  --set OPTION VALUE  Set configuration option"
           echo
           echo "Examples:"
           echo "  $(basename "$0") config"
           echo "  $(basename "$0") config --edit"
           echo "  $(basename "$0") config --set workspace ~/documents"
           return 0
           ;;
         *)
           echo "Error: Unknown option for config command: $1" >&2
           return 1
           ;;
       esac
     done
     
     # Set configuration option
     if [[ -n "$option" && -n "$value" ]]; then
       verbose_output "Setting configuration option: $option = $value"
       
       # Read existing configuration
       if [[ -f "$CONFIG_FILE" ]]; then
         local config=$(cat "$CONFIG_FILE")
         
         # Check if option exists
         if grep -q "^$option=" "$CONFIG_FILE"; then
           # Update existing option
           config=$(echo "$config" | sed "s|^$option=.*|$option=$value|")
         else
           # Add new option
           config="$config\n$option=$value"
         fi
         
         # Write updated configuration
         echo -e "$config" > "$CONFIG_FILE"
       else
         # Create new configuration file
         echo "$option=$value" > "$CONFIG_FILE"
       fi
       
       echo "Configuration updated: $option = $value"
       return 0
     fi
     
     # Edit configuration
     if [[ "$edit" == "true" ]]; then
       verbose_output "Opening configuration file in editor"
       
       # Determine editor
       local editor="${EDITOR:-nano}"
       
       # Open configuration file
       $editor "$CONFIG_FILE"
       return $?
     fi
     
     # Show configuration
     echo "Configuration File: $CONFIG_FILE"
     echo
     
     if [[ -f "$CONFIG_FILE" ]]; then
       cat "$CONFIG_FILE" | grep -v "^#" | grep -v "^$"
     else
       echo "Configuration file does not exist"
     fi
     
     return 0
   }
   
   # Main script
   
   # Parse global options
   while [[ $# -gt 0 ]]; do
     case "$1" in
       -h|--help)
         display_help
         exit 0
         ;;
       -v|--verbose)
         verbose="true"
         shift
         ;;
       -w|--workspace)
         workspace="$2"
         shift 2
         ;;
       --workspace=*)
         workspace="${1#*=}"
         shift
         ;;
       -b|--backup-dir)
         backup_dir="$2"
         shift 2
         ;;
       --backup-dir=*)
         backup_dir="${1#*=}"
         shift
         ;;
       --version)
         display_version
         exit 0
         ;;
       -*)
         echo "Error: Unknown option: $1" >&2
         echo "Run '$(basename "$0") --help' for usage information" >&2
         exit 1
         ;;
       *)
         break
         ;;
     esac
   done
   
   # Check command
   if [[ $# -eq 0 ]]; then
     display_help
     exit 1
   fi
   
   command="$1"
   shift
   
   # Execute command
   case "$command" in
     ls|list)
       cmd_list "$@"
       ;;
     find)
       cmd_find "$@"
       ;;
     organize)
       cmd_organize "$@"
       ;;
     backup)
       cmd_backup "$@"
       ;;
     stats)
       cmd_stats "$@"
       ;;
     config)
       cmd_config "$@"
       ;;
     *)
       echo "Error: Unknown command: $command" >&2
       echo "Run '$(basename "$0") --help' for usage information" >&2
       exit 1
       ;;
   esac
   
   exit $?
   ```

2. **Create a test script for the file management tool**:
   ```bash
   # Create a test script
   touch ~/scripts/file-manager/test.sh
   chmod +x ~/scripts/file-manager/test.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: test.sh
   # Description: Test script for file management tool
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Configuration
   TEST_DIR="$HOME/file-manager-test"
   FILE_MANAGER="$HOME/scripts/file-manager/file-manager.sh"
   
   # Create test directory
   mkdir -p "$TEST_DIR"
   cd "$TEST_DIR"
   
   # Clean up on exit
   function cleanup() {
     echo "Cleaning up test directory"
     rm -rf "$TEST_DIR"
   }
   
   trap cleanup EXIT
   
   # Create test files
   echo "Creating test files"
   mkdir -p docs images code
   
   # Create text files
   echo "Hello, world!" > hello.txt
   echo "Sample document" > docs/document.txt
   echo "README file" > README.md
   
   # Create image files (empty)
   touch images/photo1.jpg
   touch images/photo2.png
   touch images/logo.svg
   
   # Create code files
   cat > code/script.py << 'EOF'
   def hello():
       print("Hello, world!")
   
   if __name__ == "__main__":
       hello()
   EOF
   
   cat > code/index.html << 'EOF'
   <!DOCTYPE html>
   <html>
   <head>
       <title>Test Page</title>
   </head>
   <body>
       <h1>Hello, world!</h1>
   </body>
   </html>
   EOF
   
   # Create hidden files
   echo "Hidden file" > .hidden-file
   mkdir -p .hidden-dir
   echo "Hidden directory file" > .hidden-dir/test.txt
   
   # Run tests
   echo
   echo "Testing file-manager.sh"
   echo "======================="
   echo
   
   # Test list command
   echo "Test 1: List files"
   "$FILE_MANAGER" --workspace "$TEST_DIR" list
   echo
   
   # Test find command
   echo "Test 2: Find files"
   "$FILE_MANAGER" --workspace "$TEST_DIR" find "*.txt"
   echo
   
   # Test organize command (dry run)
   echo "Test 3: Organize files (dry run)"
   "$FILE_MANAGER" --workspace "$TEST_DIR" organize --dry-run
   echo
   
   # Test stats command
   echo "Test 4: Show statistics"
   "$FILE_MANAGER" --workspace "$TEST_DIR" stats --by-type
   echo
   
   # Test backup command
   echo "Test 5: Create backup"
   "$FILE_MANAGER" --workspace "$TEST_DIR" backup --format=zip test-backup
   echo
   
   # Test config command
   echo "Test 6: Show configuration"
   "$FILE_MANAGER" config
   echo
   
   echo "Tests completed"
   exit 0
   ```

3. **Run the tests**:
   ```bash
   # Run the test script
   ~/scripts/file-manager/test.sh
   ```

### Create a Script for Pipeline Integration

1. **Create a log processing pipeline script**:
   ```bash
   # Create a log processing script
   touch ~/scripts/log-processor.sh
   chmod +x ~/scripts/log-processor.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: log-processor.sh
   # Description: Process log files with pipeline integration
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Exit on error
   set -e
   
   # Configuration
   LOG_LEVELS=("DEBUG" "INFO" "WARN" "ERROR" "FATAL")
   DEFAULT_LEVEL="INFO"
   DEFAULT_FORMAT="text"
   DEFAULT_OUTPUT="-"  # stdout
   
   # Display help
   function display_help() {
     cat << EOF
   Log Processor - Process log files with pipeline integration
   
   Usage:
     $(basename "$0") [options] [file]
   
   Options:
     -h, --help                  Display this help message
     -l, --level LEVEL           Minimum log level to include
                                 (DEBUG, INFO, WARN, ERROR, FATAL)
     -f, --format FORMAT         Output format (text, csv, json)
     -o, --output FILE           Write output to file (default: stdout)
     --timestamp-format FORMAT   Custom timestamp format for parsing
     --count-only                Only show count of matching entries
     --summary                   Show summary statistics
   
   Examples:
     # Process a log file
     $(basename "$0") app.log
   
     # Filter by log level
     $(basename "$0") --level ERROR app.log
   
     # Output as JSON
     $(basename "$0") --format json app.log
   
     # Process stdin
     cat app.log | $(basename "$0") --level WARN
   
     # Chain with other commands
     cat app.log | $(basename "$0") --level ERROR | grep "database"
   EOF
   }
   
   # Check if level is valid
   function is_valid_level() {
     local level="$1"
     
     for valid_level in "${LOG_LEVELS[@]}"; do
       if [[ "$level" == "$valid_level" ]]; then
         return 0
       fi
     done
     
     return 1
   }
   
   # Get numeric value for log level
   function get_level_value() {
     local level="$1"
     
     for i in "${!LOG_LEVELS[@]}"; do
       if [[ "${LOG_LEVELS[$i]}" == "$level" ]]; then
         echo "$i"
         return 0
       fi
     done
     
     echo "-1"
     return 1
   }
   
   # Parse log line
   function parse_log_line() {
     local line="$1"
     local timestamp_format="$2"
     
     # Default pattern: [TIMESTAMP] [LEVEL] Message
     # Example: [2023-01-15 10:15:30] [INFO] Application started
     
     if [[ -n "$timestamp_format" ]]; then
       # Custom timestamp format
       if [[ "$line" =~ \[(.*)\]\ \[(.*)\]\ (.*) ]]; then
         timestamp="${BASH_REMATCH[1]}"
         level="${BASH_REMATCH[2]}"
         message="${BASH_REMATCH[3]}"
         
         echo "$timestamp|$level|$message"
         return 0
       fi
     else
       # Default format
       if [[ "$line" =~ \[(.*)\]\ \[(.*)\]\ (.*) ]]; then
         timestamp="${BASH_REMATCH[1]}"
         level="${BASH_REMATCH[2]}"
         message="${BASH_REMATCH[3]}"
         
         echo "$timestamp|$level|$message"
         return 0
       fi
     fi
     
     # Line doesn't match expected format
     return 1
   }
   
   # Format output
   function format_output() {
     local format="$1"
     local timestamp="$2"
     local level="$3"
     local message="$4"
     
     case "$format" in
       text)
         echo "[$timestamp] [$level] $message"
         ;;
       csv)
         echo "\"$timestamp\",\"$level\",\"$message\""
         ;;
       json)
         printf '{"timestamp":"%s","level":"%s","message":"%s"}\n' \
           "$timestamp" "$level" "${message//\"/\\\"}"
         ;;
       *)
         echo "Error: Unsupported format: $format" >&2
         return 1
         ;;
     esac
     
     return 0
   }
   
   # Process log file or stdin
   function process_logs() {
     local min_level="$1"
     local format="$2"
     local output="$3"
     local timestamp_format="$4"
     local count_only="$5"
     local summary="$6"
     local input="$7"
     
     local min_level_value
     min_level_value=$(get_level_value "$min_level")
     
     local count=0
     local level_counts=()
     
     # Initialize level counts
     for level in "${LOG_LEVELS[@]}"; do
       level_counts["$level"]=0
     done
     
     # Redirect output if needed
     if [[ "$output" != "-" ]]; then
       exec > "$output"
     fi
     
     # Write CSV header if format is CSV
     if [[ "$format" == "csv" && "$count_only" != "true" && "$summary" != "true" ]]; then
       echo "\"Timestamp\",\"Level\",\"Message\""
     fi
     
     # Process input
     while IFS= read -r line; do
       # Skip empty lines
       if [[ -z "$line" ]]; then
         continue
       fi
       
       # Parse log line
       parsed=$(parse_log_line "$line" "$timestamp_format")
       if [[ $? -ne 0 ]]; then
         continue
       fi
       
       # Extract fields
       IFS='|' read -r timestamp level message <<< "$parsed"
       
       # Check if level meets minimum
       level_value=$(get_level_value "$level")
       if [[ $level_value -ge $min_level_value ]]; then
         count=$((count + 1))
         level_counts["$level"]=$((level_counts["$level"] + 1))
         
         if [[ "$count_only" != "true" && "$summary" != "true" ]]; then
           format_output "$format" "$timestamp" "$level" "$message"
         fi
       fi
     done < "$input"
     
     # Show count if requested
     if [[ "$count_only" == "true" ]]; then
       echo "Total matching entries: $count"
     fi
     
     # Show summary if requested
     if [[ "$summary" == "true" ]]; then
       echo "Summary:"
       echo "  Total entries: $count"
       echo
       echo "  Entries by level:"
       for level in "${LOG_LEVELS[@]}"; do
         if [[ ${level_counts["$level"]} -gt 0 ]]; then
           echo "    $level: ${level_counts["$level"]}"
         fi
       done
     fi
     
     return 0
   }
   
   # Parse command-line arguments
   level="$DEFAULT_LEVEL"
   format="$DEFAULT_FORMAT"
   output="$DEFAULT_OUTPUT"
   timestamp_format=""
   count_only="false"
   summary="false"
   input_file=""
   
   while [[ $# -gt 0 ]]; do
     case "$1" in
       -h|--help)
         display_help
         exit 0
         ;;
       -l|--level)
         level="$2"
         if ! is_valid_level "$level"; then
           echo "Error: Invalid log level: $level" >&2
           echo "Valid levels: ${LOG_LEVELS[*]}" >&2
           exit 1
         fi
         shift 2
         ;;
       -f|--format)
         format="$2"
         if [[ "$format" != "text" && "$format" != "csv" && "$format" != "json" ]]; then
           echo "Error: Invalid format: $format" >&2
           echo "Valid formats: text, csv, json" >&2
           exit 1
         fi
         shift 2
         ;;
       -o|--output)
         output="$2"
         shift 2
         ;;
       --timestamp-format)
         timestamp_format="$2"
         shift 2
         ;;
       --count-only)
         count_only="true"
         shift
         ;;
       --summary)
         summary="true"
         shift
         ;;
       -*)
         echo "Error: Unknown option: $1" >&2
         display_help >&2
         exit 1
         ;;
       *)
         input_file="$1"
         shift
         ;;
     esac
   done
   
   # Determine input source
   if [[ -n "$input_file" ]]; then
     # Input from file
     if [[ ! -f "$input_file" ]]; then
       echo "Error: File not found: $input_file" >&2
       exit 1
     fi
     
     process_logs "$level" "$format" "$output" "$timestamp_format" "$count_only" "$summary" "$input_file"
   else
     # Input from stdin
     if [ -t 0 ]; then
       # No input provided
       echo "Error: No input provided" >&2
       display_help >&2
       exit 1
     fi
     
     # Process stdin
     process_logs "$level" "$format" "$output" "$timestamp_format" "$count_only" "$summary" "/dev/stdin"
   fi
   
   exit 0
   ```

2. **Create a sample log file for testing**:
   ```bash
   # Create a sample log file
   touch ~/sample.log
   ```

   Add the following content:
   ```
   [2023-01-15 10:15:30] [INFO] Application started
   [2023-01-15 10:15:31] [DEBUG] Loaded configuration from /etc/app/config.ini
   [2023-01-15 10:15:32] [INFO] Connected to database
   [2023-01-15 10:16:45] [WARN] Slow query detected: SELECT * FROM users WHERE active = 1
   [2023-01-15 10:18:12] [DEBUG] Processing user request: /api/users
   [2023-01-15 10:18:13] [DEBUG] Query executed in 45ms
   [2023-01-15 10:20:05] [ERROR] Database connection lost
   [2023-01-15 10:20:10] [INFO] Reconnecting to database
   [2023-01-15 10:20:15] [INFO] Reconnected to database
   [2023-01-15 10:25:30] [DEBUG] Processing user request: /api/products
   [2023-01-15 10:25:31] [DEBUG] Query executed in 62ms
   [2023-01-15 10:30:45] [WARN] Memory usage high: 85%
   [2023-01-15 10:35:22] [DEBUG] Garbage collection started
   [2023-01-15 10:35:25] [DEBUG] Garbage collection completed
   [2023-01-15 10:40:11] [ERROR] Failed to process request: Timeout
   [2023-01-15 10:45:30] [FATAL] Process crashed with error: SIGSEGV
   [2023-01-15 10:45:31] [INFO] Attempting automatic recovery
   [2023-01-15 10:46:00] [INFO] Recovery successful
   [2023-01-15 10:50:15] [DEBUG] Scheduled tasks started
   [2023-01-15 10:55:20] [INFO] Scheduled tasks completed
   ```

3. **Test the log processor script**:
   ```bash
   # Basic usage
   ~/scripts/log-processor.sh ~/sample.log
   
   # Filter by log level
   ~/scripts/log-processor.sh --level ERROR ~/sample.log
   
   # Output as JSON
   ~/scripts/log-processor.sh --format json ~/sample.log
   
   # Show summary
   ~/scripts/log-processor.sh --summary ~/sample.log
   
   # Test pipeline integration
   cat ~/sample.log | ~/scripts/log-processor.sh --level WARN | grep "database"
   ```

### Create an Automation Framework

1. **Create a directory structure for the automation framework**:
   ```bash
   # Create directory structure
   mkdir -p ~/automation/{lib,tasks,config,logs}
   ```

2. **Create a core library file**:
   ```bash
   # Create core library
   touch ~/automation/lib/core.sh
   chmod +x ~/automation/lib/core.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Library name: core.sh
   # Description: Core functions for automation framework
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Ensure this file is sourced, not executed
   if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
     echo "Error: This script should be sourced, not executed."
     exit 1
   fi
   
   # Framework version
   readonly FRAMEWORK_VERSION="1.0.0"
   
   # Framework directories
   readonly FRAMEWORK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
   readonly LIB_DIR="$FRAMEWORK_ROOT/lib"
   readonly TASKS_DIR="$FRAMEWORK_ROOT/tasks"
   readonly CONFIG_DIR="$FRAMEWORK_ROOT/config"
   readonly LOGS_DIR="$FRAMEWORK_ROOT/logs"
   
   # Ensure directories exist
   mkdir -p "$TASKS_DIR" "$CONFIG_DIR" "$LOGS_DIR"
   
   # Default configuration
   : "${CONFIG_FILE:=$CONFIG_DIR/config.ini}"
   : "${LOG_LEVEL:=INFO}"
   : "${LOG_FILE:=$LOGS_DIR/automation.log}"
   
   # Load additional libraries
   for lib in "$LIB_DIR"/*.sh; do
     if [[ "$lib" != "${BASH_SOURCE[0]}" && -f "$lib" ]]; then
       source "$lib"
     fi
   done
   
   # Load configuration
   function load_config() {
     local config_file="${1:-$CONFIG_FILE}"
     
     if [[ ! -f "$config_file" ]]; then
       echo "Warning: Configuration file not found: $config_file"
       return 1
     fi
     
     # Source the configuration file
     source "$config_file"
     
     return 0
   }
   
   # Display banner
   function display_banner() {
     cat << EOF
   ┌───────────────────────────────────────────────┐
   │           Automation Framework v$FRAMEWORK_VERSION           │
   └───────────────────────────────────────────────┘
   EOF
   }
   
   # Display help
   function display_help() {
     cat << EOF
   Usage: $(basename "$0") [options] <task> [arguments]
   
   Options:
     -h, --help             Display this help message
     -c, --config FILE      Use alternative configuration file
     -l, --log-level LEVEL  Set log level (DEBUG, INFO, WARN, ERROR)
     -v, --version          Display version information
   
   Tasks:
   $(list_tasks | sed 's/^/  /')
   
   For more information on a specific task, run:
     $(basename "$0") <task> --help
   EOF
   }
   
   # Display version
   function display_version() {
     echo "Automation Framework version $FRAMEWORK_VERSION"
     echo "Copyright (c) $(date +%Y) Your Name"
   }
   
   # List available tasks
   function list_tasks() {
     local task_files=()
     
     # Find all task files
     if [[ -d "$TASKS_DIR" ]]; then
       task_files=($(find "$TASKS_DIR" -type f -name "*.sh" | sort))
     fi
     
     # No tasks found
     if [[ ${#task_files[@]} -eq 0 ]]; then
       echo "No tasks available"
       return 0
     fi
     
     # Extract task descriptions
     for task_file in "${task_files[@]}"; do
       local task_name=$(basename "$task_file" .sh)
       local task_desc=$(grep -m 1 "# Description:" "$task_file" | cut -d':' -f2- | sed 's/^ *//')
       
       if [[ -z "$task_desc" ]]; then
         task_desc="No description available"
       fi
       
       printf "%-20s %s\n" "$task_name" "$task_desc"
     done
     
     return 0
   }
   
   # Run task
   function run_task() {
     local task_name="$1"
     shift
     
     local task_file="$TASKS_DIR/$task_name.sh"
     
     # Check if task exists
     if [[ ! -f "$task_file" ]]; then
       echo "Error: Task not found: $task_name"
       echo "Available tasks:"
       list_tasks
       return 1
     fi
     
     # Source the task file
     source "$task_file"
     
     # Check if the task function exists
     if [[ "$(type -t "task_$task_name")" != "function" ]]; then
       echo "Error: Task function not found: task_$task_name"
       return 1
     fi
     
     # Run the task
     "task_$task_name" "$@"
     return $?
   }
   ```

3. **Create a logging library**:
   ```bash
   # Create logging library
   touch ~/automation/lib/logging.sh
   chmod +x ~/automation/lib/logging.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Library name: logging.sh
   # Description: Logging functions for automation framework
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Ensure this file is sourced, not executed
   if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
     echo "Error: This script should be sourced, not executed."
     exit 1
   fi
   
   # Log levels
   readonly LOG_LEVEL_DEBUG=0
   readonly LOG_LEVEL_INFO=1
   readonly LOG_LEVEL_WARN=2
   readonly LOG_LEVEL_ERROR=3
   
   # Convert log level string to numeric value
   function get_log_level_value() {
     local level_str="$1"
     
     case "${level_str^^}" in
       DEBUG) echo $LOG_LEVEL_DEBUG ;;
       INFO)  echo $LOG_LEVEL_INFO ;;
       WARN)  echo $LOG_LEVEL_WARN ;;
       ERROR) echo $LOG_LEVEL_ERROR ;;
       *)     echo $LOG_LEVEL_INFO ;;
     esac
   }
   
   # Initialize logging
   function init_logging() {
     local log_file="${1:-$LOG_FILE}"
     
     # Create log directory if it doesn't exist
     local log_dir=$(dirname "$log_file")
     mkdir -p "$log_dir"
     
     # Create or truncate log file
     : > "$log_file"
     
     return 0
   }
   
   # Log message
   function log() {
     local level_str="$1"
     local message="$2"
     local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
     
     # Get numeric values for comparison
     local level_val=$(get_log_level_value "$level_str")
     local current_level_val=$(get_log_level_value "$LOG_LEVEL")
     
     # Only log if level is high enough
     if [[ $level_val -ge $current_level_val ]]; then
       # Format log message
       local log_message="[$timestamp] [$level_str] $message"
       
       # Write to log file
       echo "$log_message" >> "$LOG_FILE"
       
       # Write to console with color
       case "${level_str^^}" in
         DEBUG) echo -e "\033[36m$log_message\033[0m" ;;  # Cyan
         INFO)  echo -e "\033[32m$log_message\033[0m" ;;  # Green
         WARN)  echo -e "\033[33m$log_message\033[0m" ;;  # Yellow
         ERROR) echo -e "\033[31m$log_message\033[0m" ;;  # Red
       esac
     fi
     
     return 0
   }
   
   # Convenience logging functions
   function log_debug() { log "DEBUG" "$1"; }
   function log_info() { log "INFO" "$1"; }
   function log_warn() { log "WARN" "$1"; }
   function log_error() { log "ERROR" "$1"; }
   
   # Rotate log file
   function rotate_log() {
     local max_size="${1:-1048576}"  # Default: 1MB
     local max_rotations="${2:-5}"   # Default: 5 rotations
     
     # Get current file size
     local size=$(stat -c %s "$LOG_FILE" 2>/dev/null || stat -f %z "$LOG_FILE" 2>/dev/null)
     
     # Rotate if file size exceeds max size
     if [[ $size -gt $max_size ]]; then
       log_debug "Rotating log file: $LOG_FILE"
       
       # Rotate old log files
       for i in $(seq $max_rotations -1 1); do
         local j=$((i + 1))
         
         if [[ -f "${LOG_FILE}.$i" ]]; then
           mv "${LOG_FILE}.$i" "${LOG_FILE}.$j" 2>/dev/null || true
         fi
       done
       
       # Rotate current log file
       mv "$LOG_FILE" "${LOG_FILE}.1" 2>/dev/null || true
       
       # Create new log file
       init_logging
       
       log_debug "Log rotation completed"
     fi
     
     return 0
   }
   
   # Initialize logging
   init_logging
   ```

4. **Create a utility library**:
   ```bash
   # Create utility library
   touch ~/automation/lib/utils.sh
   chmod +x ~/automation/lib/utils.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Library name: utils.sh
   # Description: Utility functions for automation framework
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Ensure this file is sourced, not executed
   if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
     echo "Error: This script should be sourced, not executed."
     exit 1
   fi
   
   # Check if command exists
   function command_exists() {
     command -v "$1" >/dev/null 2>&1
   }
   
   # Require command
   function require_command() {
     local cmd="$1"
     local package="${2:-$1}"
     
     if ! command_exists "$cmd"; then
       log_error "Required command not found: $cmd"
       log_info "Please install package: $package"
       return 1
     fi
     
     return 0
   }
   
   # Confirm action
   function confirm() {
     local prompt="${1:-Are you sure?}"
     local default="${2:-n}"
     
     local options
     if [[ "$default" == "y" ]]; then
       options="Y/n"
     else
       options="y/N"
     fi
     
     local answer
     read -p "$prompt [$options] " answer
     
     # Default value if empty
     if [[ -z "$answer" ]]; then
       answer="$default"
     fi
     
     # Check answer
     case "${answer,,}" in
       y|yes) return 0 ;;
       *)     return 1 ;;
     esac
   }
   
   # Ask for input
   function ask() {
     local prompt="$1"
     local default="$2"
     local answer
     
     if [[ -n "$default" ]]; then
       read -p "$prompt [$default]: " answer
       : "${answer:=$default}"
     else
       read -p "$prompt: " answer
     fi
     
     echo "$answer"
   }
   
   # Ask for password
   function ask_password() {
     local prompt="$1"
     local password
     
     read -s -p "$prompt: " password
     echo
     
     echo "$password"
   }
   
   # Create secure temporary file
   function create_temp_file() {
     local prefix="${1:-temp}"
     local suffix="${2:-}"
     
     mktemp --tmpdir "${prefix}.XXXXXX${suffix}"
   }
   
   # Create secure temporary directory
   function create_temp_dir() {
     local prefix="${1:-temp}"
     
     mktemp -d --tmpdir "${prefix}.XXXXXX"
   }
   
   # Check if running as root
   function check_root() {
     if [[ $EUID -ne 0 ]]; then
       log_error "This task must be run as root"
       return 1
     fi
     
     return 0
   }
   
   # Get absolute path
   function get_abs_path() {
     local path="$1"
     
     if [[ -d "$path" ]]; then
       (cd "$path" && pwd)
     elif [[ -f "$path" ]]; then
       local dir=$(dirname "$path")
       local file=$(basename "$path")
       echo "$(cd "$dir" && pwd)/$file"
     else
       echo "$path"
     fi
   }
   
   # Check if file exists and is readable
   function check_file() {
     local file="$1"
     
     if [[ ! -f "$file" ]]; then
       log_error "File not found: $file"
       return 1
     fi
     
     if [[ ! -r "$file" ]]; then
       log_error "File not readable: $file"
       return 1
     fi
     
     return 0
   }
   
   # Check if directory exists and is writable
   function check_dir() {
     local dir="$1"
     
     if [[ ! -d "$dir" ]]; then
       log_error "Directory not found: $dir"
       return 1
     fi
     
     if [[ ! -w "$dir" ]]; then
       log_error "Directory not writable: $dir"
       return 1
     fi
     
     return 0
   }
   
   # Format duration in seconds to human-readable format
   function format_duration() {
     local seconds="$1"
     
     local days=$((seconds / 86400))
     local hours=$(( (seconds % 86400) / 3600 ))
     local minutes=$(( (seconds % 3600) / 60 ))
     local remaining_seconds=$((seconds % 60))
     
     local result=""
     
     if [[ $days -gt 0 ]]; then
       result="${days}d "
     fi
     
     if [[ $hours -gt 0 ]]; then
       result="${result}${hours}h "
     fi
     
     if [[ $minutes -gt 0 ]]; then
       result="${result}${minutes}m "
     fi
     
     result="${result}${remaining_seconds}s"
     
     echo "$result"
   }
   
   # Format file size in bytes to human-readable format
   function format_size() {
     local bytes="$1"
     
     if [[ $bytes -ge 1073741824 ]]; then  # 1 GB
       awk "BEGIN {printf \"%.2f GB\", $bytes/1073741824}"
     elif [[ $bytes -ge 1048576 ]]; then  # 1 MB
       awk "BEGIN {printf \"%.2f MB\", $bytes/1048576}"
     elif [[ $bytes -ge 1024 ]]; then  # 1 KB
       awk "BEGIN {printf \"%.2f KB\", $bytes/1024}"
     else
       echo "${bytes} bytes"
     fi
   }
   ```

5. **Create a sample task**:
   ```bash
   # Create a sample task
   touch ~/automation/tasks/backup.sh
   chmod +x ~/automation/tasks/backup.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Task name: backup.sh
   # Description: Create a backup of specified directories
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Backup task implementation
   function task_backup() {
     # Parse task options
     local target_dir=""
     local output_dir="$HOME/backups"
     local format="tar.gz"
     local include_hidden=false
     
     # Parse command-line arguments
     while [[ $# -gt 0 ]]; do
       case "$1" in
         --target)
           target_dir="$2"
           shift 2
           ;;
         --output)
           output_dir="$2"
           shift 2
           ;;
         --format)
           format="$2"
           shift 2
           ;;
         --include-hidden)
           include_hidden=true
           shift
           ;;
         --help)
           echo "Usage: $(basename "$0") backup [options]"
           echo
           echo "Options:"
           echo "  --target DIR        Directory to backup (required)"
           echo "  --output DIR        Output directory (default: ~/backups)"
           echo "  --format FORMAT     Backup format: tar.gz, zip (default: tar.gz)"
           echo "  --include-hidden    Include hidden files and directories"
           echo
           echo "Examples:"
           echo "  $(basename "$0") backup --target ~/documents"
           echo "  $(basename "$0") backup --target ~/projects --format zip"
           return 0
           ;;
         *)
           log_error "Unknown option: $1"
           return 1
           ;;
       esac
     done
     
     # Validate target directory
     if [[ -z "$target_dir" ]]; then
       log_error "Target directory is required"
       return 1
     fi
     
     if [[ ! -d "$target_dir" ]]; then
       log_error "Target directory not found: $target_dir"
       return 1
     fi
     
     # Get absolute paths
     target_dir=$(get_abs_path "$target_dir")
     output_dir=$(get_abs_path "$output_dir")
     
     # Create output directory if it doesn't exist
     if [[ ! -d "$output_dir" ]]; then
       log_info "Creating output directory: $output_dir"
       mkdir -p "$output_dir"
     fi
     
     # Generate backup filename
     local date_str=$(date +"%Y%m%d-%H%M%S")
     local target_name=$(basename "$target_dir")
     local backup_file="$output_dir/${target_name}-backup-${date_str}"
     
     # Determine backup command
     local backup_cmd=""
     
     case "$format" in
       tar.gz)
         backup_file="${backup_file}.tar.gz"
         backup_cmd="tar -czf \"$backup_file\" -C \"$(dirname "$target_dir")\" \"$(basename "$target_dir")\""
         ;;
       zip)
         backup_file="${backup_file}.zip"
         backup_cmd="cd \"$(dirname "$target_dir")\" && zip -r \"$backup_file\" \"$(basename "$target_dir")\""
         ;;
       *)
         log_error "Unsupported format: $format"
         return 1
         ;;
     esac
     
     # Exclude hidden files if needed
     if [[ "$include_hidden" != "true" ]]; then
       if [[ "$format" == "tar.gz" ]]; then
         backup_cmd="$backup_cmd --exclude=\".*\""
       elif [[ "$format" == "zip" ]]; then
         backup_cmd="$backup_cmd -x \"*/.*\""
       fi
     fi
     
     # Log backup start
     log_info "Starting backup of $target_dir to $backup_file"
     
     # Execute backup command
     local start_time=$(date +%s)
     
     eval "$backup_cmd"
     local exit_code=$?
     
     local end_time=$(date +%s)
     local duration=$((end_time - start_time))
     
     # Check if backup was successful
     if [[ $exit_code -eq 0 ]]; then
       local size=$(stat -c %s "$backup_file" 2>/dev/null || stat -f %z "$backup_file" 2>/dev/null)
       local size_human=$(format_size "$size")
       local duration_human=$(format_duration "$duration")
       
       log_info "Backup completed successfully"
       log_info "Backup file: $backup_file"
       log_info "Size: $size_human"
       log_info "Duration: $duration_human"
       
       return 0
     else
       log_error "Backup failed with exit code $exit_code"
       return 1
     fi
   }
   ```

6. **Create the main script**:
   ```bash
   # Create main script
   touch ~/automation/automation.sh
   chmod +x ~/automation/automation.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: automation.sh
   # Description: Main script for automation framework
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Get script directory
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   
   # Source core library
   source "$SCRIPT_DIR/lib/core.sh"
   
   # Parse command-line arguments
   config_file="$CONFIG_FILE"
   
   # Parse global options
   while [[ $# -gt 0 ]]; do
     case "$1" in
       -h|--help)
         display_banner
         display_help
         exit 0
         ;;
       -c|--config)
         config_file="$2"
         shift 2
         ;;
       --config=*)
         config_file="${1#*=}"
         shift
         ;;
       -l|--log-level)
         LOG_LEVEL="$2"
         shift 2
         ;;
       --log-level=*)
         LOG_LEVEL="${1#*=}"
         shift
         ;;
       -v|--version)
         display_version
         exit 0
         ;;
       -*)
         echo "Error: Unknown option: $1"
         display_help >&2
         exit 1
         ;;
       *)
         break
         ;;
     esac
   done
   
   # Check for task argument
   if [[ $# -eq 0 ]]; then
     display_banner
     display_help
     exit 1
   fi
   
   # Extract task name
   task_name="$1"
   shift
   
   # Load configuration
   load_config "$config_file"
   
   # Run task
   display_banner
   log_info "Running task: $task_name"
   
   # Start timer
   start_time=$(date +%s)
   
   # Run task
   run_task "$task_name" "$@"
   exit_code=$?
   
   # End timer
   end_time=$(date +%s)
   duration=$((end_time - start_time))
   duration_human=$(format_duration "$duration")
   
   # Log task completion
   if [[ $exit_code -eq 0 ]]; then
     log_info "Task completed successfully in $duration_human"
   else
     log_error "Task failed with exit code $exit_code in $duration_human"
   fi
   
   exit $exit_code
   ```

7. **Create a default configuration file**:
   ```bash
   # Create configuration directory and file
   mkdir -p ~/automation/config
   touch ~/automation/config/config.ini
   ```

   Add the following content:
   ```bash
   # Automation Framework Configuration
   
   # Logging
   LOG_LEVEL="INFO"
   LOG_FILE="$HOME/automation/logs/automation.log"
   
   # Backup settings
   BACKUP_DIR="$HOME/backups"
   BACKUP_FORMAT="tar.gz"
   BACKUP_KEEP_DAYS=30
   
   # Email notifications
   ENABLE_EMAIL_NOTIFICATIONS=false
   EMAIL_TO="your.email@example.com"
   EMAIL_FROM="automation@example.com"
   SMTP_SERVER="smtp.example.com"
   SMTP_PORT=587
   SMTP_USER="smtp_user"
   SMTP_PASSWORD="smtp_password"
   ```

8. **Test the automation framework**:
   ```bash
   # Run the automation script
   ~/automation/automation.sh
   
   # View available tasks
   ~/automation/automation.sh --help
   
   # Run the backup task
   ~/automation/automation.sh backup --help
   ~/automation/automation.sh backup --target ~/Documents
   
   # Check the log file
   cat ~/automation/logs/automation.log
   ```

## Projects

### Project 1: System Maintenance Automation Suite [Intermediate] (8-10 hours)

Create a comprehensive system maintenance toolkit that automates common tasks:

1. **Features to implement**:
   - Package updates and management
   - System cleaning and optimization
   - Backup and restoration of critical system files
   - Log rotation and analysis
   - Security checks and hardening
   - Performance monitoring and reporting

2. **Requirements**:
   - User-friendly command-line interface with proper help documentation
   - Configurable options stored in a configuration file
   - Comprehensive logging and error handling
   - Email notifications for critical issues
   - Scheduling through systemd timers
   - Dashboard for monitoring system status

### Project 2: Log Analysis and Reporting Tool [Intermediate] (6-8 hours)

Build a tool to analyze system logs and generate reports:

1. **Features to implement**:
   - Parse various log formats (syslog, Apache, application logs)
   - Filter logs by date, severity, or pattern
   - Identify patterns and anomalies
   - Generate reports in multiple formats (text, HTML, CSV)
   - Create visualizations of log data
   - Set up automated monitoring for specific patterns

2. **Requirements**:
   - Support for multiple log formats and files
   - Robust pattern matching using regular expressions
   - Configurable reporting templates
   - Integration with email for alerts
   - Scheduling through cron
   - Command-line interface for scripting and pipeline integration

### Project 3: Deployment Automation Framework [Advanced] (10-12 hours)

Create a framework for deploying applications:

1. **Features to implement**:
   - Environment preparation and validation
   - Dependency management
   - Application deployment and configuration
   - Database migrations
   - Health checks and validation
   - Rollback capability
   - Logging and monitoring

2. **Requirements**:
   - Support for multiple environments (dev, staging, production)
   - Configuration management with environment-specific settings
   - Proper security practices for sensitive data
   - Comprehensive error handling and validation
   - Modular architecture for extending to different applications
   - Documentation generation

### Project 4: User Management Toolkit [Beginner] (4-6 hours)

Build a toolkit for managing user accounts:

1. **Features to implement**:
   - Create, modify, and delete user accounts
   - Manage user groups and permissions
   - Generate and reset passwords
   - Import/export user data via CSV
   - Audit and report on user activity
   - Batch operations for multiple users

2. **Requirements**:
   - Command-line interface with clear documentation
   - Support for both individual and bulk operations
   - Proper validation and error handling
   - Logging of all operations
   - Secure password management
   - Both interactive and non-interactive modes

## Additional Resources

### Shell Scripting References

- **Advanced Bash-Scripting Guide**:
  [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/)

- **Bash Hackers Wiki**:
  [Bash Hackers Wiki](https://wiki.bash-hackers.org/)

- **Google Shell Style Guide**:
  [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)

- **ShellCheck** (syntax checking tool):
  [ShellCheck](https://www.shellcheck.net/)

### Systemd and Cron Resources

- **Systemd Timer Units**:
  [ArchWiki - Systemd/Timers](https://wiki.archlinux.org/title/Systemd/Timers)

- **Cron Tutorial**:
  [Cron Tutorial](https://www.digitalocean.com/community/tutorials/how-to-use-cron-to-automate-tasks-on-a-vps)

- **Flock for Script Locking**:
  [Linux Shell - Introduction to flock](https://linuxaria.com/howto/linux-shell-introduction-to-flock)

### Command-Line Tools Design

- **Command Line Interface Guidelines**:
  [CLI Guidelines](https://clig.dev/)

- **Argbash** (Bash argument parsing code generator):
  [Argbash](https://github.com/matejak/argbash)

### Testing Frameworks

- **ShUnit2** (shell script testing framework):
  [ShUnit2](https://github.com/kward/shunit2)

- **Bats** (Bash Automated Testing System):
  [Bats-Core](https://github.com/bats-core/bats-core)

## Reflection Questions

After completing the exercises and projects, reflect on these questions:

1. How does proper error handling in shell scripts improve the reliability of automation tasks?

2. What are the key differences between systemd timers and cron jobs, and in what scenarios would you choose one over the other?

3. How do the principles of modularity and reusability apply to shell scripting? How can you design scripts to be more maintainable?

4. What security considerations should you keep in mind when developing automation scripts that might run with elevated privileges?

5. How would you approach debugging a complex shell script? What techniques and tools would you use?

6. In what ways can automated logging improve the troubleshooting process for scheduled tasks?

7. How might you design a command-line interface to be intuitive for both novice and advanced users?

8. What strategies can you use to test automation scripts effectively before deploying them in production?

## Answers to Self-Assessment Quiz

1. `chmod +x *.sh`
2. `$@` expands to all positional parameters as separate quoted arguments, while `$*` expands to all positional parameters as a single argument with spaces between them.
3. Associative arrays should be used when you need to map keys to values and the keys aren't sequential integers. They're useful for lookup tables, dictionaries, and configuration data.
4. `set -euo pipefail` makes a script exit immediately if a command fails, treats unset variables as errors, and causes pipelines to return the exit status of the rightmost command that failed (or 0 if all succeeded).
5. The `Persistent=true` option in systemd timers ensures that a timer will run on the next start of the system if it would have run while the system was off.
6. `45 3 1 * * /path/to/script.sh`
7. File locking prevents multiple instances of the same script from running simultaneously, which could cause race conditions, data corruption, or resource conflicts when scripts access shared resources.
8. `getopts` is built into Bash and handles POSIX-style options (single letters with a dash), while manual parsing can handle any format including GNU-style long options (with double dashes) but requires more code.
9. Three best practices for handling sensitive data in shell scripts are: 1) Don't store passwords in the script itself, 2) Use read -s to input passwords without echoing them to the terminal, 3) Use temporary files with restricted permissions (600) that are securely deleted after use.
10. `if ((BASH_VERSINFO[0] < 4)); then echo "This script requires Bash version 4 or higher"; exit 1; fi`

## Next Steps

After completing Month 9 exercises, consider these activities to further enhance your skills:

1. **Extend the automation framework** with additional tasks and features
2. **Create a custom library** of your most frequently used shell functions
3. **Set up a CI/CD pipeline** using your scripting skills
4. **Contribute to open source shell scripts** or automation tools
5. **Create a personal collection** of one-liners and useful commands
6. **Automate a repetitive task** from your daily workflow
7. **Convert basic scripts** to more robust tools with proper error handling
8. **Create a script repository** with version control for your automation scripts

## Acknowledgements

These exercises were developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Exercise structure and organization
- Code examples and explanations
- Resource recommendations

Claude was used as a development aid while all final implementation decisions and review were performed by Joshua Michael Hall.

## Disclaimer

These exercises are provided "as is", without warranty of any kind. Always make backups before making system changes. Use caution when running scripts that modify system files or require elevated privileges.# Month 9: Automation and Scripting - Exercises

This document contains practical exercises and projects to accompany the Month 9 learning guide. Complete these exercises to solidify your understanding of shell scripting, automation, scheduled tasks, and building robust command-line tools.

## Exercise 1: Advanced Shell Scripting

### Shell Script Structure and Best Practices

1. **Create a well-structured script template**:
   ```bash
   # Create a script template file
   mkdir -p ~/scripts
   touch ~/scripts/template.sh
   chmod +x ~/scripts/template.sh
   ```

   Add this basic template structure:
   ```bash
   #!/bin/bash
   #
   # Script name: template.sh
   # Description: A template for well-structured bash scripts
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   #
   # Usage: ./template.sh [options] <arguments>
   
   # Exit on error, undefined variables, and pipe failures
   set -euo pipefail
   
   # Constants and configuration
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
   LOG_FILE="/tmp/${SCRIPT_NAME%.sh}.log"
   
   # Functions
   function log() {
     local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
     echo "[$timestamp] $1" | tee -a "$LOG_FILE"
   }
   
   function display_usage() {
     cat << EOF
   Usage: $SCRIPT_NAME [options] <argument>
   
   Options:
     -h, --help     Display this help message
     -v, --verbose  Enable verbose output
   
   Example:
     $SCRIPT_NAME --verbose argument
   EOF
     exit 1
   }
   
   function cleanup() {
     log "Cleaning up resources..."
     # Add cleanup code here
   }
   
   # Set up trap to ensure cleanup happens
   trap cleanup EXIT
   
   # Parse command line arguments
   verbose=false
   
   while [[ $# -gt 0 ]]; do
     case "$1" in
       -h|--help)
         display_usage
         ;;
       -v|--verbose)
         verbose=true
         shift
         ;;
       *)
         # Store as positional argument
         if [[ -z ${positional_arg+x} ]]; then
           positional_arg="$1"
         else
           log "Error: Unknown argument: $1"
           display_usage
         fi
         shift
         ;;
     esac
   done
   
   # Check required arguments
   if [[ -z ${positional_arg+x} ]]; then
     log "Error: Missing required argument"
     display_usage
   fi
   
   # Main execution
   log "Script started with argument: $positional_arg"
   
   if [[ "$verbose" = true ]]; then
     log "Verbose mode enabled"
   fi
   
   # Your script logic goes here
   
   log "Script completed successfully"
   exit 0
   ```

2. **Create a script for managing data structures**:
   ```bash
   # Create a script for working with data structures
   touch ~/scripts/data_structures.sh
   chmod +x ~/scripts/data_structures.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: data_structures.sh
   # Description: Demonstrates working with Bash data structures
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Exit on error, undefined variables, and pipe failures
   set -euo pipefail
   
   # 1. Working with arrays
   echo "===== Arrays ====="
   
   # Create an indexed array
   fruits=("apple" "banana" "cherry" "date" "elderberry")
   echo "Number of fruits: ${#fruits[@]}"
   echo "All fruits: ${fruits[*]}"
   echo "First fruit: ${fruits[0]}"
   echo "Last two fruits: ${fruits[@]:3:2}"
   
   # Loop through array
   echo "Listing all fruits:"
   for fruit in "${fruits[@]}"; do
     echo "- $fruit"
   done
   
   # Edit array
   fruits[1]="blueberry"
   fruits+=("fig")
   echo "Updated fruits: ${fruits[*]}"
   
   # Remove element (note: leaves gap in array)
   unset 'fruits[2]'
   echo "After removal: ${fruits[*]}"
   
   # 2. Working with associative arrays
   echo -e "\n===== Associative Arrays ====="
   
   # Requires Bash 4+
   if ((BASH_VERSINFO[0] < 4)); then
     echo "Associative arrays require Bash 4 or higher"
     exit 1
   fi
   
   # Create an associative array
   declare -A user_roles
   user_roles=([alice]="admin" [bob]="user" [charlie]="developer" [dave]="analyst")
   
   echo "Number of users: ${#user_roles[@]}"
   echo "All users: ${!user_roles[@]}"
   echo "All roles: ${user_roles[@]}"
   echo "Alice's role: ${user_roles[alice]}"
   
   # Check if key exists
   if [[ -v user_roles[bob] ]]; then
     echo "Bob's role is ${user_roles[bob]}"
   else
     echo "Bob has no assigned role"
   fi
   
   # Loop through associative array
   echo "User roles:"
   for user in "${!user_roles[@]}"; do
     echo "$user: ${user_roles[$user]}"
   done
   
   # Add or modify entry
   user_roles[eve]="manager"
   user_roles[bob]="admin"
   
   # Remove entry
   unset 'user_roles[dave]'
   
   echo "Updated user roles:"
   for user in "${!user_roles[@]}"; do
     echo "$user: ${user_roles[$user]}"
   done
   
   # 3. String manipulation
   echo -e "\n===== String Manipulation ====="
   
   filepath="/home/user/documents/report.txt"
   
   # Get filename
   filename="${filepath##*/}"
   echo "Filename: $filename"
   
   # Get directory
   directory="${filepath%/*}"
   echo "Directory: $directory"
   
   # Get file extension
   extension="${filename##*.}"
   echo "Extension: $extension"
   
   # Get filename without extension
   basename="${filename%.*}"
   echo "Basename: $basename"
   
   # String replacement
   newfilepath="${filepath/report/summary}"
   echo "New filepath: $newfilepath"
   
   # Convert to uppercase
   uppercase="${filename^^}"
   echo "Uppercase: $uppercase"
   
   # Convert to lowercase
   lowercase="${filename,,}"
   echo "Lowercase: $lowercase"
   
   # Substring extraction
   echo "First 4 chars: ${filename:0:4}"
   echo "Last 4 chars: ${filename: -4}"
   
   echo "Script completed successfully"
   exit 0
   ```

3. **Create a script to demonstrate control structures**:
   ```bash
   # Create a script for demonstrating control structures
   touch ~/scripts/control_structures.sh
   chmod +x ~/scripts/control_structures.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: control_structures.sh
   # Description: Demonstrates advanced control structures in Bash
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Exit on error, undefined variables, and pipe failures
   set -euo pipefail
   
   # 1. Advanced conditionals
   echo "===== Advanced Conditionals ====="
   
   # Pattern matching with [[ ]]
   filename="document.pdf"
   if [[ "$filename" == *.pdf ]]; then
     echo "$filename is a PDF file"
   fi
   
   # Regular expression matching
   email="user@example.com"
   if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
     echo "$email is a valid email address"
   else
     echo "$email is not a valid email address"
   fi
   
   # Multiple conditions
   age=25
   has_id=true
   if [ "$age" -ge 18 ] && [ "$has_id" = true ]; then
     echo "Access granted: Adult with ID"
   elif [ "$age" -ge 18 ] && [ "$has_id" != true ]; then
     echo "Access denied: Adult without ID"
   elif [ "$age" -lt 18 ] && [ "$has_id" = true ]; then
     echo "Access denied: Minor with ID"
   else
     echo "Access denied: Minor without ID"
   fi
   
   # Case statement
   fruit="apple"
   case "$fruit" in
     apple)
       echo "It's an apple!"
       ;;
     banana|orange)
       echo "It's a yellow or orange fruit"
       ;;
     *)
       echo "It's some other fruit"
       ;;
   esac
   
   # 2. Advanced loop structures
   echo -e "\n===== Advanced Loops ====="
   
   # For loop with sequence
   echo "Simple sequence:"
   for i in {1..5}; do
     echo "Number: $i"
   done
   
   # For loop with step
   echo "Sequence with step:"
   for i in {10..1..2}; do
     echo "Number: $i"
   done
   
   # C-style for loop
   echo "C-style loop:"
   for ((i=0; i<5; i++)); do
     echo "Index: $i"
   done
   
   # While loop with read
   echo "Parsing data from here-document:"
   data=$(cat << EOF
   John,32,Manager
   Alice,28,Developer
   Bob,45,Director
   EOF
   )
   
   echo "$data" | while IFS=, read -r name age role; do
     echo "$name is $age years old and works as a $role"
   done
   
   # Until loop
   echo "Until loop:"
   counter=5
   until [ $counter -le 0 ]; do
     echo "Countdown: $counter"
     ((counter--))
   done
   
   # Breaking out of loops
   echo "Breaking out of loop:"
   for i in {1..10}; do
     echo "Processing $i"
     if [ $i -eq 5 ]; then
       echo "Reached 5, breaking out"
       break
     fi
   done
   
   # Skipping iterations
   echo "Skipping iterations:"
   for i in {1..5}; do
     if [ $i -eq 3 ]; then
       echo "Skipping 3"
       continue
     fi
     echo "Processing $i"
   done
   
   # 3. Advanced function usage
   echo -e "\n===== Advanced Functions ====="
   
   # Function with local variables
   function greet() {
     local name="${1:-World}"
     echo "Hello, $name!"
   }
   
   # Call function with and without parameter
   greet
   greet "Sarah"
   
   # Function with return value
   function is_even() {
     local num=$1
     if (( num % 2 == 0 )); then
       return 0  # True in Bash
     else
       return 1  # False in Bash
     fi
   }
   
   # Use return value
   if is_even 42; then
     echo "42 is even"
   else
     echo "42 is odd"
   fi
   
   if ! is_even 15; then
     echo "15 is odd"
   fi
   
   # Function that returns value via output
   function add() {
     local a=$1
     local b=$2
     echo $((a + b))
   }
   
   # Capture function output
   sum=$(add 5 3)
   echo "5 + 3 = $sum"
   
   # Function with named parameters
   function create_user() {
     local username=""
     local role=""
     local active=false
     
     # Parse named parameters
     while [[ $# -gt 0 ]]; do
       case "$1" in
         --username=*)
           username="${1#*=}"
           ;;
         --role=*)
           role="${1#*=}"
           ;;
         --active)
           active=true
           ;;
       esac
       shift
     done
     
     # Use parameters
     echo "Creating user: $username"
     echo "Role: $role"
     echo "Active: $active"
   }
   
   # Call function with named parameters
   create_user --username=jane --role=admin --active
   
   # Recursive function
   function countdown() {
     local count=$1
     echo "$count"
     
     if [[ $count -gt 1 ]]; then
       countdown $((count - 1))
     fi
   }
   
   echo "Recursive countdown:"
   countdown 5
   
   echo "Script completed successfully"
   exit 0
   ```

4. **Create a script for file and I/O handling**:
   ```bash
   # Create a script for handling files and I/O
   touch ~/scripts/file_io.sh
   chmod +x ~/scripts/file_io.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: file_io.sh
   # Description: Demonstrates advanced file and I/O handling in Bash
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Exit on error, undefined variables, and pipe failures
   set -euo pipefail
   
   # Create a temporary directory for this exercise
   temp_dir=$(mktemp -d)
   echo "Created temporary directory: $temp_dir"
   
   # Clean up on exit
   function cleanup() {
     echo "Cleaning up temporary directory"
     rm -rf "$temp_dir"
   }
   
   trap cleanup EXIT
   
   # 1. Command-line argument processing
   echo "===== Command-Line Arguments ====="
   
   # Check for --help
   if [[ "$#" -gt 0 && ("$1" == "-h" || "$1" == "--help") ]]; then
     cat << EOF
   Usage: $(basename "$0") [options]
   
   A demonstration of file and I/O handling in Bash.
   
   Options:
     -h, --help    Show this help message
     --file=PATH   Process the specified file
     --verbose     Enable verbose output
   EOF
     exit 0
   fi
   
   # Process arguments
   file=""
   verbose=false
   
   for arg in "$@"; do
     case "$arg" in
       --file=*)
         file="${arg#*=}"
         ;;
       --verbose)
         verbose=true
         ;;
     esac
   done
   
   # Show processed arguments
   echo "File: ${file:-Not specified}"
   echo "Verbose mode: $verbose"
   
   # 2. Reading and writing files
   echo -e "\n===== File Operations ====="
   
   # Create a sample file
   sample_file="$temp_dir/sample.txt"
   cat > "$sample_file" << EOF
   Line 1: This is a sample file.
   Line 2: It contains multiple lines.
   Line 3: We will use it for testing.
   Line 4: File operations in Bash.
   EOF
   
   echo "Created sample file: $sample_file"
   
   # Read file line by line
   echo "Reading file line by line:"
   line_num=1
   while IFS= read -r line; do
     echo "$line_num: $line"
     ((line_num++))
   done < "$sample_file"
   
   # Read specific lines
   echo -e "\nReading lines 2-3:"
   sed -n '2,3p' "$sample_file"
   
   # Write to a new file
   output_file="$temp_dir/output.txt"
   {
     echo "Report generated on $(date)"
     echo "--------------------------"
     grep "Line" "$sample_file"
     echo "--------------------------"
   } > "$output_file"
   
   echo "Created output file: $output_file"
   echo "Contents:"
   cat "$output_file"
   
   # Append to file
   echo -e "\nAppending to file:"
   echo "End of report." >> "$output_file"
   tail -1 "$output_file"
   
   # 3. Redirection techniques
   echo -e "\n===== Redirection Techniques ====="
   
   # Redirect stdout and stderr separately
   echo "Redirecting stdout and stderr separately:"
   {
     echo "This goes to stdout"
     echo "This goes to stderr" >&2
   } > "$temp_dir/stdout.log" 2> "$temp_dir/stderr.log"
   
   echo "stdout.log contents:"
   cat "$temp_dir/stdout.log"
   echo "stderr.log contents:"
   cat "$temp_dir/stderr.log"
   
   # Redirect both to same file
   echo -e "\nRedirecting both to same file:"
   {
     echo "This goes to stdout"
     echo "This goes to stderr" >&2
   } > "$temp_dir/combined.log" 2>&1
   
   echo "combined.log contents:"
   cat "$temp_dir/combined.log"
   
   # Here documents (heredoc)
   echo -e "\nHere document example:"
   cat << 'EOF' > "$temp_dir/config.ini"
   [General]
   ApplicationName=File Demo
   Version=1.0
   
   [Network]
   Host=localhost
   Port=8080
   Timeout=30
   EOF
   
   echo "Created config.ini:"
   cat "$temp_dir/config.ini"
   
   # Here strings
   echo -e "\nHere string example:"
   grep "Port" <<< "Port=8080"
   
   # Process substitution
   echo -e "\nProcess substitution example:"
   echo "Comparing file contents:"
   diff <(head -2 "$sample_file") <(tail -2 "$sample_file")
   
   # Named pipes
   echo -e "\nNamed pipe example:"
   pipe="$temp_dir/mypipe"
   mkfifo "$pipe"
   
   # Start background process to read from the pipe
   {
     while read -r line; do
       echo "Received: $line"
     done < "$pipe"
   } &
   pipe_reader_pid=$!
   
   # Write to the pipe
   echo "Hello through pipe!" > "$pipe"
   echo "Another message!" > "$pipe"
   
   # Wait for background process to process messages
   sleep 1
   kill $pipe_reader_pid 2>/dev/null || true
   
   echo "Script completed successfully"
   exit 0
   ```

### Execute and Explore Scripts

Run each of the scripts you created above:

```bash
# Run data structures script
~/scripts/data_structures.sh

# Run control structures script
~/scripts/control_structures.sh

# Run file I/O script
~/scripts/file_io.sh
```

Take time to understand how each component works. Try modifying the scripts to change behavior or extend functionality.

## Exercise 2: Error Handling, Logging, and Robust Scripting

### Create a Robust Script Template

1. **Create a script template with error handling**:
   ```bash
   # Create a robust script template
   touch ~/scripts/robust_template.sh
   chmod +x ~/scripts/robust_template.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: robust_template.sh
   # Description: A template for robust bash scripts with error handling
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Exit on error, undefined variables, and pipe failures
   set -euo pipefail
   
   # Variables
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
   LOG_DIR="${HOME}/logs"
   LOG_FILE="${LOG_DIR}/${SCRIPT_NAME%.sh}.log"
   TEMP_DIR=$(mktemp -d)
   LOCK_FILE="/tmp/${SCRIPT_NAME%.sh}.lock"
   
   # Default settings
   VERBOSE=false
   DEBUG=false
   DRY_RUN=false
   
   # Exit codes
   readonly E_SUCCESS=0
   readonly E_USAGE=1
   readonly E_DEPENDENCY=2
   readonly E_PERMISSION=3
   readonly E_INPUT=4
   readonly E_OUTPUT=5
   readonly E_RUNTIME=6
   readonly E_LOCKED=7
   readonly E_TIMEOUT=8
   
   # =====================
   # Logging functions
   # =====================
   function _setup_logging() {
     # Create log directory if it doesn't exist
     mkdir -p "$LOG_DIR"
     
     # Create or truncate log file
     : > "$LOG_FILE"
     
     # Set permission
     chmod 600 "$LOG_FILE"
   }
   
   function log() {
     local level="$1"
     local message="$2"
     local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
     
     # Format log line
     local log_line="[$timestamp] [$level] $message"
     
     # Write to log file
     echo "$log_line" >> "$LOG_FILE"
     
     # Write to stdout/stderr based on level
     case "$level" in
       ERROR)
         echo "$log_line" >&2
         ;;
       WARN)
         $VERBOSE && echo "$log_line" >&2
         ;;
       INFO)
         $VERBOSE && echo "$log_line"
         ;;
       DEBUG)
         $DEBUG && echo "$log_line"
         ;;
       *)
         echo "$log_line"
         ;;
     esac
   }
   
   function log_error() { log "ERROR" "$1"; }
   function log_warn() { log "WARN" "$1"; }
   function log_info() { log "INFO" "$1"; }
   function log_debug() { log "DEBUG" "$1"; }
   function log_success() { log "SUCCESS" "$1"; }
   
   # =====================
   # Error handling functions
   # =====================
   function error_handler() {
     local line_no="$1"
     local error_code="${2:-1}"
     local command="$3"
     
     # Don't trigger on successful exit
     if [[ $error_code -eq 0 ]]; then
       return
     fi
     
     log_error "Error in ${SCRIPT_NAME}, line ${line_no}: '${command}' exited with status ${error_code}"
     
     # Cleanup on error
     cleanup
     
     exit "$error_code"
   }
   
   function cleanup() {
     log_debug "Performing cleanup"
     
     # Remove temporary directory if it exists
     [[ -d "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"
     
     # Remove lock file if it exists
     [[ -f "$LOCK_FILE" ]] && rm -f "$LOCK_FILE"
     
     log_debug "Cleanup completed"
   }
   
   # =====================
   # Utility functions
   # =====================
   function check_dependencies() {
     local missing_deps=()
     
     for cmd in "$@"; do
       if ! command -v "$cmd" &>/dev/null; then
         missing_deps+=("$cmd")
       fi
     done
     
     if [[ ${#missing_deps[@]} -gt 0 ]]; then
       log_error "Missing dependencies: ${missing_deps[*]}"
       return $E_DEPENDENCY
     fi
     
     return $E_SUCCESS
   }
   
   function create_lock() {
     # Check if lock file exists and process is still running
     if [[ -f "$LOCK_FILE" ]]; then
       local old_pid=$(cat "$LOCK_FILE")
       
       if ps -p "$old_pid" &>/dev/null; then
         log_error "Another instance is already running with PID ${old_pid}"
         return $E_LOCKED
       else
         log_warn "Removing stale lock file"
         rm -f "$LOCK_FILE"
       fi
     fi
     
     # Create new lock file
     echo $$ > "$LOCK_FILE"
     log_debug "Created lock file: $LOCK_FILE"
     
     return $E_SUCCESS
   }
   
   function display_usage() {
     cat << EOF
   Usage: $SCRIPT_NAME [OPTIONS]
   
   A robust script template with error handling and logging.
   
   Options:
     -h, --help       Display this help message
     -v, --verbose    Enable verbose output
     -d, --debug      Enable debug mode
     --dry-run        Run without making changes
   
   Example:
     $SCRIPT_NAME --verbose
   EOF
   }
   
   # =====================
   # Parse command-line arguments
   # =====================
   function parse_arguments() {
     while [[ $# -gt 0 ]]; do
       case "$1" in
         -h|--help)
           display_usage
           exit $E_SUCCESS
           ;;
         -v|--verbose)
           VERBOSE=true
           shift
           ;;
         -d|--debug)
           DEBUG=true
           VERBOSE=true  # Debug implies verbose
           shift
           ;;
         --dry-run)
           DRY_RUN=true
           shift
           ;;
         *)
           log_error "Unknown option: $1"
           display_usage
           exit $E_USAGE
           ;;
       esac
     done
   }
   
   # =====================
   # Main function
   # =====================
   function main() {
     # Set up error handling
     trap 'error_handler ${LINENO} $? "${BASH_COMMAND}"' ERR
     trap cleanup EXIT
     
     # Set up logging
     _setup_logging
     
     # Log script start
     log_info "Script started (pid: $$)"
     
     # Create lock file
     if ! create_lock; then
       exit $E_LOCKED
     fi
     
     # Check dependencies
     check_dependencies grep sed awk || exit $E_DEPENDENCY
     
     # Print configuration
     log_debug "Configuration:"
     log_debug "  Script directory: $SCRIPT_DIR"
     log_debug "  Log file: $LOG_FILE"
     log_debug "  Temp directory: $TEMP_DIR"
     log_debug "  Verbose mode: $VERBOSE"
     log_debug "  Debug mode: $DEBUG"
     log_debug "  Dry run mode: $DRY_RUN"
     
     # Your script logic goes here
     log_info "Executing main logic"
     
     # Use TEMP_DIR for temporary files
     echo "This is sample data" > "$TEMP_DIR/sample.txt"
     log_debug "Created sample file: $TEMP_DIR/sample.txt"
     
     # Simulated task
     if $DRY_RUN; then
       log_info "Would process data (dry run)"
     else
       log_info "Processing data..."
       sleep 2  # Simulate work
       log_success "Data processed successfully"
     fi
     
     # Script completed successfully
     log_info "Script completed successfully"
     return $E_SUCCESS
   }
   
   # Call the main function
   parse_arguments "$@"
   main
   exit $?
   ```

2. **Test the robust script template**:
   ```bash
   # Test with various options
   ~/scripts/robust_template.sh
   ~/scripts/robust_template.sh --verbose
   ~/scripts/robust_template.sh --debug
   ~/scripts/robust_template.sh --dry-run
   ```

### Create a Logging Library

1. **Create a reusable logging library**:
   ```bash
   # Create a logging library file
   mkdir -p ~/scripts/lib
   touch ~/scripts/lib/logging.sh
   chmod +x ~/scripts/lib/logging.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Library name: logging.sh
   # Description: A reusable logging library for Bash scripts
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Ensure this file is sourced, not executed
   if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
     echo "Error: This script should be sourced, not executed."
     exit 1
   fi
   
   # Default values
   : "${LOG_LEVEL:=INFO}"
   : "${LOG_FILE:=/dev/null}"
   : "${LOG_DATE_FORMAT:=%Y-%m-%d %H:%M:%S}"
   : "${LOG_COLOR:=true}"
   : "${LOG_TO_SYSLOG:=false}"
   : "${LOG_FACILITY:=user}"
   
   # Log levels
   declare -A LOG_LEVELS=(
     ["DEBUG"]=0
     ["INFO"]=1
     ["WARN"]=2
     ["ERROR"]=3
     ["FATAL"]=4
   )
   
   # ANSI color codes
   if [[ "$LOG_COLOR" == true ]]; then
     declare -A LOG_COLORS=(
       ["DEBUG"]="\033[36m"   # Cyan
       ["INFO"]="\033[32m"    # Green
       ["WARN"]="\033[33m"    # Yellow
       ["ERROR"]="\033[31m"   # Red
       ["FATAL"]="\033[35m"   # Magenta
       ["RESET"]="\033[0m"    # Reset
     )
   else
     declare -A LOG_COLORS=(
       ["DEBUG"]=""
       ["INFO"]=""
       ["WARN"]=""
       ["ERROR"]=""
       ["FATAL"]=""
       ["RESET"]=""
     )
   fi
   
   # Initialize logging
   function log_init() {
     # Create log directory if it doesn't exist
     local log_dir
     log_dir=$(dirname "$LOG_FILE")
     
     if [[ "$log_dir" != "/dev" && ! -d "$log_dir" ]]; then
       mkdir -p "$log_dir" || return 1
     fi
     
     # Create or truncate log file if not /dev/null
     if [[ "$LOG_FILE" != "/dev/null" ]]; then
       : > "$LOG_FILE" || return 1
       chmod 600 "$LOG_FILE" || return 1
     fi
     
     return 0
   }
   
   # Internal logging function
   function _log() {
     local level="$1"
     local message="$2"
     local timestamp
     local log_line
     local level_numeric
     local current_level_numeric
     
     # Get numeric values for comparison
     level_numeric="${LOG_LEVELS[$level]}"
     current_level_numeric="${LOG_LEVELS[$LOG_LEVEL]}"
     
     # Only log if level is high enough
     if [[ $level_numeric -lt $current_level_numeric ]]; then
       return 0
     fi
     
     # Format timestamp
     timestamp=$(date +"$LOG_DATE_FORMAT")
     
     # Format log message
     log_line="[$timestamp] [${level}] $message"
     
     # Write to log file
     if [[ "$LOG_FILE" != "/dev/null" ]]; then
       echo "$log_line" >> "$LOG_FILE"
     fi
     
     # Write to syslog if enabled
     if [[ "$LOG_TO_SYSLOG" == true ]]; then
       logger -p "${LOG_FACILITY}.${level,,}" -t "$(basename "$0")" "$message"
     fi
     
     # Write to stdout/stderr with color
     if [[ "$level" == "ERROR" || "$level" == "FATAL" ]]; then
       echo -e "${LOG_COLORS[$level]}$log_line${LOG_COLORS[RESET]}" >&2
     else
       echo -e "${LOG_COLORS[$level]}$log_line${LOG_COLORS[RESET]}"
     fi
     
     return 0
   }
   
   # Public logging functions
   function log_debug() { _log "DEBUG" "$1"; }
   function log_info() { _log "INFO" "$1"; }
   function log_warn() { _log "WARN" "$1"; }
   function log_error() { _log "ERROR" "$1"; }
   function log_fatal() { _log "FATAL" "$1"; }
   
   # Log rotation function
   function log_rotate() {
     local max_size=${1:-1048576}  # Default: 1MB
     local max_rotations=${2:-5}   # Default: 5 rotations
     
     # Don't rotate if log file doesn't exist
     if [[ ! -f "$LOG_FILE" || "$LOG_FILE" == "/dev/null" ]]; then
       return 0
     fi
     
     # Get current file size
     local size
     size=$(stat -c %s "$LOG_FILE" 2>/dev/null || stat -f %z "$LOG_FILE" 2>/dev/null)
     
     # Rotate if file size exceeds max size
     if [[ $size -gt $max_size ]]; then
       # Rotate old log files
       for i in $(seq "$max_rotations" -1 1); do
         local j=$((i + 1))
         
         if [[ -f "${LOG_FILE}.$i" ]]; then
           mv "${LOG_FILE}.$i" "${LOG_FILE}.$j" 2>/dev/null || true
         fi
       done
       
       # Rotate current log file
       mv "$LOG_FILE" "${LOG_FILE}.1" 2>/dev/null || true
       
       # Create new log file
       log_init
       
       return 0
     fi
     
     return 0
   }
   
   # Enable/disable syslog
   function log_enable_syslog() {
     LOG_TO_SYSLOG=true
   }
   
   function log_disable_syslog() {
     LOG_TO_SYSLOG=false
   }
   
   # Set log level
   function log_set_level() {
     local level="$1"
     
     if [[ -n "${LOG_LEVELS[$level]}" ]]; then
       LOG_LEVEL="$level"
       return 0
     else
       log_error "Invalid log level: $level"
       return 1
     fi
   }
   
   # Set log file
   function log_set_file() {
     local file="$1"
     
     LOG_FILE="$file"
     log_init
     
     return $?
   }
   
   # Enable/disable color
   function log_enable_color() {
     LOG_COLOR=true
     
     LOG_COLORS=(
       ["DEBUG"]="\033[36m"   # Cyan
       ["INFO"]="\033[32m"    # Green
       ["WARN"]="\033[33m"    # Yellow
       ["ERROR"]="\033[31m"   # Red
       ["FATAL"]="\033[35m"   # Magenta
       ["RESET"]="\033[0m"    # Reset
     )
   }
   
   function log_disable_color() {
     LOG_COLOR=false
     
     LOG_COLORS=(
       ["DEBUG"]=""
       ["INFO"]=""
       ["WARN"]=""
       ["ERROR"]=""
       ["FATAL"]=""
       ["RESET"]=""
     )
   }
   
   # Initialize logging
   log_init
   ```

2. **Create a test script that uses the logging library**:
   ```bash
   # Create a script that uses the logging library
   touch ~/scripts/test_logging.sh
   chmod +x ~/scripts/test_logging.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: test_logging.sh
   # Description: Tests the logging library
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Source the logging library
   source ~/scripts/lib/logging.sh
   
   # Set log file
   log_set_file "$HOME/logs/test_logging.log"
   
   # Test all log levels
   log_info "Testing logging library"
   
   log_debug "This is a debug message"
   log_info "This is an info message"
   log_warn "This is a warning message"
   log_error "This is an error message"
   log_fatal "This is a fatal message"
   
   # Test log level filtering
   log_info "Setting log level to WARN"
   log_set_level "WARN"
   
   log_debug "This debug message should not appear"
   log_info "This info message should not appear"
   log_warn "This warning message should appear"
   log_error "This error message should appear"
   
   # Test color toggling
   log_info "Disabling colors"
   log_disable_color
   log_warn "This warning should have no color"
   
   log_info "Re-enabling colors"
   log_enable_color
   log_warn "This warning should have color again"
   
   # Test log rotation
   log_info "Testing log rotation"
   for i in {1..100}; do
     log_info "Generating log entry $i"
     log_rotate 1024  # Rotate at 1KB
   done
   
   log_info "Testing completed"
   exit 0
   ```

3. **Run the test script and examine the logs**:
   ```bash
   # Run the test script
   ~/scripts/test_logging.sh
   
   # View the log file
   cat ~/logs/test_logging.log
   
   # Check for rotated logs
   ls -la ~/logs/
   ```

### Create a Script with Proper Security Practices

1. **Create a script with security best practices**:
   ```bash
   # Create a secure script
   touch ~/scripts/secure_script.sh
   chmod +x ~/scripts/secure_script.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: secure_script.sh
   # Description: Demonstrates secure scripting practices
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Exit on errors, undefined variables, and failed pipes
   set -euo pipefail
   
   # Set restrictive umask (owner rw only)
   umask 077
   
   # Create secure temporary directory
   TEMP_DIR=$(mktemp -d)
   if [[ ! -d "$TEMP_DIR" ]]; then
     echo "Error: Failed to create temporary directory" >&2
     exit 1
   fi
   
   # Clean up function
   function cleanup() {
     # Securely remove temporary files
     if [[ -d "$TEMP_DIR" ]]; then
       find "$TEMP_DIR" -type f -exec shred -uz {} \;
       rm -rf "$TEMP_DIR"
     fi
   }
   
   # Set trap to ensure cleanup on exit
   trap cleanup EXIT
   
   # Sanitize input function
   function sanitize_filename() {
     local input="$1"
     # Remove path components and special characters
     local sanitized="${input##*/}"
     sanitized="${sanitized//[^a-zA-Z0-9._-]/}"
     
     # Ensure result is not empty
     if [[ -z "$sanitized" ]]; then
       sanitized="default"
     fi
     
     echo "$sanitized"
   }
   
   # Validate input function
   function validate_number() {
     local input="$1"
     local min="${2:-0}"
     local max="${3:-100}"
     
     if [[ ! "$input" =~ ^[0-9]+$ ]]; then
       echo "Error: Input must be a number" >&2
       return 1
     fi
     
     if [[ "$input" -lt "$min" || "$input" -gt "$max" ]]; then
       echo "Error: Input must be between $min and $max" >&2
       return 1
     fi
     
     return 0
   }
   
   # Safely read sensitive input
   function read_secret() {
     local prompt="$1"
     local secret=""
     
     # Read password without echo
     read -s -p "$prompt" secret
     echo
     
     # Avoid returning empty string
     if [[ -z "$secret" ]]; then
       echo "Error: Empty input not allowed" >&2
       return 1
     fi
     
     # Return via stdout (don't use echo for secrets in production)
     echo "$secret"
     return 0
   }
   
   # Safe command execution
   function safe_execute() {
     local cmd="$1"
     local args=("${@:2}")
     
     # Avoid using eval
     "$cmd" "${args[@]}"
     return $?
   }
   
   # =====================
   # Main script
   # =====================
   echo "Secure Script Demo"
   echo "=================="
   
   # Process user input safely
   echo -n "Enter a filename: "
   read -r user_filename
   
   # Sanitize user input
   safe_filename=$(sanitize_filename "$user_filename")
   echo "Sanitized filename: $safe_filename"
   
   # Create a file in the temporary directory
   touch "$TEMP_DIR/$safe_filename"
   echo "Created file: $TEMP_DIR/$safe_filename"
   
   # Read and validate a number
   echo -n "Enter a number between 1 and 10: "
   read -r user_number
   
   if validate_number "$user_number" 1 10; then
     echo "Valid number: $user_number"
   else
     echo "Using default number: 5"
     user_number=5
   fi
   
   # Write some data to the file
   data="This is line $user_number"
   echo "$data" > "$TEMP_DIR/$safe_filename"
   
   # Read secret input
   password=$(read_secret "Enter a password: ")
   
   # Store password securely (in memory only, not in a file)
   echo "Password received (length: ${#password})"
   
   # Use password securely
   echo "Creating secure hash of password..."
   if command -v openssl >/dev/null 2>&1; then
     # Create a secure hash using a random salt
     salt=$(openssl rand -hex 8)
     hash=$(echo -n "${password}${salt}" | openssl dgst -sha256 | cut -d' ' -f2)
     echo "Password hash (with salt): $hash"
   else
     echo "OpenSSL not available, skipping password hashing"
   fi
   
   # Clear sensitive variable
   password=""
   
   # Safe command execution demo
   echo "Safe command execution:"
   safe_execute ls -la "$TEMP_DIR"
   
   # Show that temp files will be cleaned up
   echo
   echo "Script completed. Temporary files will be securely removed."
   exit 0
   ```

2. **Run the secure script**:
   ```bash
   # Execute the secure script
   ~/scripts/secure_script.sh
   ```

   Experiment with different inputs, including potentially problematic ones like `../../../etc/passwd` for the filename or non-numeric values for the number.

### Create a Test Framework for Scripts

1. **Create a simple test framework for shell scripts**:
   ```bash
   # Create a test framework
   mkdir -p ~/scripts/test_framework
   touch ~/scripts/test_framework/test.sh
   chmod +x ~/scripts/test_framework/test.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: test.sh
   # Description: A simple test framework for shell scripts
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Variables
   TEST_COUNT=0
   PASS_COUNT=0
   FAIL_COUNT=0
   CURRENT_TEST=""
   TEST_OUTPUT=""
   ERROR_OUTPUT=""
   
   # Colors
   RED="\033[31m"
   GREEN="\033[32m"
   YELLOW="\033[33m"
   BLUE="\033[34m"
   RESET="\033[0m"
   
   # Test framework functions
   function describe() {
     echo -e "${BLUE}$1${RESET}"
     echo "========================================"
   }
   
   function it() {
     CURRENT_TEST="$1"
     echo -n "  - $CURRENT_TEST ... "
   }
   
   function assert_equals() {
     local actual="$1"
     local expected="$2"
     local message="${3:-Expected '$actual' to equal '$expected'}"
     
     TEST_COUNT=$((TEST_COUNT + 1))
     
     if [[ "$actual" == "$expected" ]]; then
       PASS_COUNT=$((PASS_COUNT + 1))
       echo -e "${GREEN}PASS${RESET}"
     else
       FAIL_COUNT=$((FAIL_COUNT + 1))
       echo -e "${RED}FAIL${RESET}"
       echo -e "    ${RED}$message${RESET}"
     fi
   }
   
   function assert_not_equals() {
     local actual="$1"
     local expected="$2"
     local message="${3:-Expected '$actual' to not equal '$expected'}"
     
     TEST_COUNT=$((TEST_COUNT + 1))
     
     if [[ "$actual" != "$expected" ]]; then
       PASS_COUNT=$((PASS_COUNT + 1))
       echo -e "${GREEN}PASS${RESET}"
     else
       FAIL_COUNT=$((FAIL_COUNT + 1))
       echo -e "${RED}FAIL${RESET}"
       echo -e "    ${RED}$message${RESET}"
     fi
   }
   
   function assert_contains() {
     local haystack="$1"
     local needle="$2"
     local message="${3:-Expected '$haystack' to contain '$needle'}"
     
     TEST_COUNT=$((TEST_COUNT + 1))
     
     if [[ "$haystack" == *"$needle"* ]]; then
       PASS_COUNT=$((PASS_COUNT + 1))
       echo -e "${GREEN}PASS${RESET}"
     else
       FAIL_COUNT=$((FAIL_COUNT + 1))
       echo -e "${RED}FAIL${RESET}"
       echo -e "    ${RED}$message${RESET}"
     fi
   }
   
   function assert_exit_code() {
     local command="$1"
     local expected_code="${2:-0}"
     local message="${3:-Expected command to exit with code $expected_code}"
     
     TEST_COUNT=$((TEST_COUNT + 1))
     
     # Create temp files for output and error
     local temp_stdout=$(mktemp)
     local temp_stderr=$(mktemp)
     
     # Run command and capture output
     eval "$command" > "$temp_stdout" 2> "$temp_stderr" || true
     local actual_code="$?"
     
     # Set global outputs
     TEST_OUTPUT=$(cat "$temp_stdout")
     ERROR_OUTPUT=$(cat "$temp_stderr")
     
     # Clean up temp files
     rm -f "$temp_stdout" "$temp_stderr"
     
     if [[ "$actual_code" -eq "$expected_code" ]]; then
       PASS_COUNT=$((PASS_COUNT + 1))
       echo -e "${GREEN}PASS${RESET}"
     else
       FAIL_COUNT=$((FAIL_COUNT + 1))
       echo -e "${RED}FAIL${RESET}"
       echo -e "    ${RED}Command exited with code $actual_code, $message${RESET}"
       
       if [[ -n "$ERROR_OUTPUT" ]]; then
         echo -e "    ${RED}Error output: $ERROR_OUTPUT${RESET}"
       fi
     fi
   }
   
   function assert_file_exists() {
     local file="$1"
     local message="${2:-Expected file to exist: $file}"
     
     TEST_COUNT=$((TEST_COUNT + 1))
     
     if [[ -f "$file" ]]; then
       PASS_COUNT=$((PASS_COUNT + 1))
       echo -e "${GREEN}PASS${RESET}"
     else
       FAIL_COUNT=$((FAIL_COUNT + 1))
       echo -e "${RED}FAIL${RESET}"
       echo -e "    ${RED}$message${RESET}"
     fi
   }
   
   function assert_directory_exists() {
     local directory="$1"
     local message="${2:-Expected directory to exist: $directory}"
     
     TEST_COUNT=$((TEST_COUNT + 1))
     
     if [[ -d "$directory" ]]; then
       PASS_COUNT=$((PASS_COUNT + 1))
       echo -e "${GREEN}PASS${RESET}"
     else
       FAIL_COUNT=$((FAIL_COUNT + 1))
       echo -e "${RED}FAIL${RESET}"
       echo -e "    ${RED}$message${RESET}"
     fi
   }
   
   function run_test_suite() {
     local test_file="$1"
     
     if [[ ! -f "$test_file" ]]; then
       echo -e "${RED}Test file not found: $test_file${RESET}"
       return 1
     fi
     
     echo -e "${BLUE}Running test suite: $test_file${RESET}"
     echo "========================================"
     
     # Reset counters
     TEST_COUNT=0
     PASS_COUNT=0
     FAIL_COUNT=0
     
     # Run the test file
     source "$test_file"
     
     # Print summary
     echo "========================================"
     echo -e "${BLUE}Test Results:${RESET}"
     echo -e "  ${BLUE}Total:${RESET} $TEST_COUNT"
     echo -e "  ${GREEN}Passed:${RESET} $PASS_COUNT"
     echo -e "  ${RED}Failed:${RESET} $FAIL_COUNT"
     echo "========================================"
     
     # Return success if all tests passed
     if [[ $FAIL_COUNT -eq 0 ]]; then
       return 0
     else
       return 1
     fi
   }
   
   # If this script is run directly, display usage
   if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
     if [[ $# -eq 0 ]]; then
       echo "Usage: $(basename "$0") <test_file>"
       echo
       echo "Example: $(basename "$0") my_tests.sh"
       exit 1
     fi
     
     # Run the specified test suite
     run_test_suite "$1"
     exit $?
   fi
   ```

2. **Create a test file for a simple function library**:
   ```bash
   # Create a simple library to test
   mkdir -p ~/scripts/lib
   touch ~/scripts/lib/math.sh
   chmod +x ~/scripts/lib/math.sh
   
   # Create a test file for the math library
   mkdir -p ~/scripts/tests
   touch ~/scripts/tests/math_test.sh
   chmod +x ~/scripts/tests/math_test.sh
   ```

   Add the following content to the math library:
   ```bash
   #!/bin/bash
   #
   # Library name: math.sh
   # Description: Simple math functions
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Ensure this file is sourced, not executed
   if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
     echo "Error: This script should be sourced, not executed."
     exit 1
   fi
   
   # Add two numbers
   function add() {
     local a="$1"
     local b="$2"
     
     # Validate input
     if [[ ! "$a" =~ ^-?[0-9]+$ || ! "$b" =~ ^-?[0-9]+$ ]]; then
       echo "Error: Inputs must be integers" >&2
       return 1
     fi
     
     echo $((a + b))
     return 0
   }
   
   # Subtract b from a
   function subtract() {
     local a="$1"
     local b="$2"
     
     # Validate input
     if [[ ! "$a" =~ ^-?[0-9]+$ || ! "$b" =~ ^-?[0-9]+$ ]]; then
       echo "Error: Inputs must be integers" >&2
       return 1
     fi
     
     echo $((a - b))
     return 0
   }
   
   # Multiply two numbers
   function multiply() {
     local a="$1"
     local b="$2"
     
     # Validate input
     if [[ ! "$a" =~ ^-?[0-9]+$ || ! "$b" =~ ^-?[0-9]+$ ]]; then
       echo "Error: Inputs must be integers" >&2
       return 1
     fi
     
     echo $((a * b))
     return 0
   }
   
   # Divide a by b
   function divide() {
     local a="$1"
     local b="$2"
     
     # Validate input
     if [[ ! "$a" =~ ^-?[0-9]+$ || ! "$b" =~ ^-?[0-9]+$ ]]; then
       echo "Error: Inputs must be integers" >&2
       return 1
     fi
     
     # Check for division by zero
     if [[ "$b" -eq 0 ]]; then
       echo "Error: Division by zero" >&2
       return 1
     fi
     
     echo $((a / b))
     return 0
   }
   
   # Check if a number is prime
   function is_prime() {
     local num="$1"
     
     # Validate input
     if [[ ! "$num" =~ ^[0-9]+$ ]]; then
       echo "Error: Input must be a positive integer" >&2
       return 1
     fi
     
     # Special cases
     if [[ "$num" -lt 2 ]]; then
       echo "false"
       return 0
     fi
     
     if [[ "$num" -eq 2 || "$num" -eq 3 ]]; then
       echo "true"
       return 0
     fi
     
     # Check if number is divisible by 2
     if [[ $((num % 2)) -eq 0 ]]; then
       echo "false"
       return 0
     fi
     
     # Check odd divisors up to square root
     local sqrt
     sqrt=$(awk "BEGIN {printf \"%d\", sqrt($num)}")
     
     for (( i=3; i<=sqrt; i+=2 )); do
       if [[ $((num % i)) -eq 0 ]]; then
         echo "false"
         return 0
       fi
     done
     
     echo "true"
     return 0
   }
   ```

   Add the following content to the test file:
   ```bash
   #!/bin/bash
   #
   # Test name: math_test.sh
   # Description: Tests for the math library
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Source the test framework
   source ~/scripts/test_framework/test.sh
   
   # Source the library to test
   source ~/scripts/lib/math.sh
   
   # Test the add function
   describe "add function"
   
   it "adds two positive numbers"
   result=$(add 5 3)
   assert_equals "$result" "8"
   
   it "adds a positive and negative number"
   result=$(add 5 -3)
   assert_equals "$result" "2"
   
   it "adds two negative numbers"
   result=$(add -5 -3)
   assert_equals "$result" "-8"
   
   it "rejects non-numeric input"
   assert_exit_code "add abc 3" 1
   
   # Test the subtract function
   describe "subtract function"
   
   it "subtracts two positive numbers"
   result=$(subtract 5 3)
   assert_equals "$result" "2"
   
   it "subtracts with negative result"
   result=$(subtract 3 5)
   assert_equals "$result" "-2"
   
   it "subtracts with negative input"
   result=$(subtract 5 -3)
   assert_equals "$result" "8"
   
   it "rejects non-numeric input"
   assert_exit_code "subtract 5 xyz" 1
   
   # Test the multiply function
   describe "multiply function"
   
   it "multiplies two positive numbers"
   result=$(multiply 5 3)
   assert_equals "$result" "15"
   
   it "multiplies by zero"
   result=$(multiply 5 0)
   assert_equals "$result" "0"
   
   it "multiplies with negative input"
   result=$(multiply 5 -3)
   assert_equals "$result" "-15"
   
   it "rejects non-numeric input"
   assert_exit_code "multiply abc 3" 1
   
   # Test the divide function
   describe "divide function"
   
   it "divides two positive numbers"
   result=$(divide 6 3)
   assert_equals "$result" "2"
   
   it "performs integer division"
   result=$(divide 5 2)
   assert_equals "$result" "2"  # Integer division
   
   it "rejects division by zero"
   assert_exit_code "divide 5 0" 1
   assert_contains "$ERROR_OUTPUT" "Division by zero"
   
   # Test the is_prime function
   describe "is_prime function"
   
   it "identifies prime numbers"
   result=$(is_prime 17)
   assert_equals "$result" "true"
   
   it "identifies non-prime numbers"
   result=$(is_prime 4)
   assert_equals "$result" "false"
   
   it "correctly handles edge cases"
   result=$(is_prime 0)
   assert_equals "$result" "false"
   
   result=$(is_prime 1)
   assert_equals "$result" "false"
   
   result=$(is_prime 2)
   assert_equals "$result" "true"
   ```

3. **Run the tests**:
   ```bash
   # Run the test suite
   ~/scripts/test_framework/test.sh ~/scripts/tests/math_test.sh
   ```

## Exercise 3: Automation with Systemd and Cron

### Create a Systemd Timer for Regular Maintenance

1. **Create a system maintenance script**:
   ```bash
   # Create a system maintenance script
   touch ~/scripts/system_maintenance.sh
   chmod +x ~/scripts/system_maintenance.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: system_maintenance.sh
   # Description: Performs routine system maintenance tasks
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Configuration
   LOG_FILE="/var/log/system_maintenance.log"
   LOCK_FILE="/tmp/system_maintenance.lock"
   
   # Ensure we're running as root
   if [[ $EUID -ne 0 ]]; then
     echo "This script must be run as root"
     exit 1
   fi
   
   # Logging function
   function log() {
     local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
     echo "[$timestamp] $1" | tee -a "$LOG_FILE"
   }
   
   # Check for lock file to prevent concurrent runs
   if [[ -f "$LOCK_FILE" ]]; then
     pid=$(cat "$LOCK_FILE")
     if ps -p "$pid" &>/dev/null; then
       log "Another instance is already running with PID $pid"
       exit 1
     else
       log "Removing stale lock file"
       rm -f "$LOCK_FILE"
     fi
   fi
   
   # Create lock file
   echo $ > "$LOCK_FILE"
   
   # Clean up on exit
   trap 'rm -f "$LOCK_FILE"' EXIT
   
   # Log start
   log "Starting system maintenance"
   
   # 1. Update package lists
   log "Updating package lists"
   if pacman -Sy; then
     log "Package lists updated successfully"
   else
     log "Failed to update package lists"
   fi
   
   # 2. Clean package cache
   log "Cleaning package cache"
   if pacman -Sc --noconfirm; then
     log "Package cache cleaned successfully"
   else
     log "Failed to clean package cache"
   fi
   
   # 3. Check for and remove orphaned packages
   log "Checking for orphaned packages"
   orphans=$(pacman -Qtdq)
   if [[ -n "$orphans" ]]; then
     log "Found orphaned packages, removing"
     if pacman -Rns $orphans --noconfirm; then
       log "Orphaned packages removed successfully"
     else
       log "Failed to remove orphaned packages"
     fi
   else
     log "No orphaned packages found"
   fi
   
   # 4. Clean systemd journal
   log "Cleaning systemd journal"
   if journalctl --vacuum-time=7d; then
     log "Journal cleaned successfully"
   else
     log "Failed to clean journal"
   fi
   
   # 5. Clean temporary files
   log "Cleaning temporary files"
   find /tmp -type f -atime +7 -delete 2>/dev/null
   find /var/tmp -type f -atime +30 -delete 2>/dev/null
   log "Temporary files cleaned"
   
   # 6. Check disk usage
   log "Checking disk usage"
   df -h | grep -E '^/dev/' | while read -r line; do
     filesystem=$(echo "$line" | awk '{print $1}')
     usage=$(echo "$line" | awk '{print $5}' | tr -d '%')
     if [[ "$usage" -gt 90 ]]; then
       log "WARNING: High disk usage on $filesystem: $usage%"
     fi
   done
   
   # 7. Check system load
   log "Checking system load"
   load=$(uptime | awk -F'load average: ' '{print $2}' | cut -d, -f1)
   if awk "BEGIN {exit !($load > 2.0)}"; then
     log "WARNING: High system load: $load"
   else
     log "System load normal: $load"
   fi
   
   # Log completion
   log "System maintenance completed"
   exit 0
   ```

2. **Create systemd service and timer units**:
   ```bash
   # Create a directory for user systemd units
   mkdir -p ~/.config/systemd/user
   
   # Create the service unit
   touch ~/.config/systemd/user/system-maintenance.service
   
   # Create the timer unit
   touch ~/.config/systemd/user/system-maintenance.timer
   ```

   Add the following content to the service unit:
   ```
   [Unit]
   Description=System Maintenance Service
   After=network.target
   
   [Service]
   Type=oneshot
   ExecStart=/bin/bash %h/scripts/system_maintenance.sh
   
   [Install]
   WantedBy=default.target
   ```

   Add the following content to the timer unit:
   ```
   [Unit]
   Description=Run System Maintenance Daily
   
   [Timer]
   OnCalendar=daily
   Persistent=true
   RandomizedDelaySec=1hour
   
   [Install]
   WantedBy=timers.target
   ```

3. **Enable and start the timer**:
   ```bash
   # Reload systemd user configuration
   systemctl --user daemon-reload
   
   # Enable the timer to run at startup
   systemctl --user enable system-maintenance.timer
   
   # Start the timer
   systemctl --user start system-maintenance.timer
   
   # Check timer status
   systemctl --user list-timers system-maintenance.timer
   ```

   Note: For system-wide maintenance, you would need to place these files in `/etc/systemd/system/` and run the commands without the `--user` flag, which requires root permissions.

### Set Up Advanced Cron Jobs with Environment Control

1. **Create a script for environment-aware cron jobs**:
   ```bash
   # Create a cron wrapper script
   touch ~/scripts/cron_wrapper.sh
   chmod +x ~/scripts/cron_wrapper.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: cron_wrapper.sh
   # Description: Wrapper for cron jobs with proper environment setup
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Configuration
   LOG_DIR="$HOME/logs/cron"
   DATE_FORMAT=$(date +"%Y%m%d-%H%M%S")
   
   # Create log directory
   mkdir -p "$LOG_DIR"
   
   # Handle missing command
   if [[ $# -lt 1 ]]; then
     echo "Usage: $(basename "$0") <command> [args...]" >&2
     exit 1
   fi
   
   # Extract command and arguments
   cmd="$1"
   shift
   cmd_name=$(basename "$cmd")
   args=("$@")
   
   # Set up environment
   # 1. Load profile if it exists
   if [[ -f "$HOME/.bash_profile" ]]; then
     source "$HOME/.bash_profile"
   elif [[ -f "$HOME/.profile" ]]; then
     source "$HOME/.profile"
   fi
   
   # 2. Load .bashrc if it exists
   if [[ -f "$HOME/.bashrc" ]]; then
     source "$HOME/.bashrc"
   fi
   
   # 3. Set PATH to include common directories
   export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH"
   
   # Log file for this execution
   LOG_FILE="$LOG_DIR/${cmd_name}-${DATE_FORMAT}.log"
   
   # Execute command and log output
   {
     echo "========================================"
     echo "Running: $cmd ${args[*]}"
     echo "Date: $(date)"
     echo "User: $(whoami)"
     echo "Working Directory: $(pwd)"
     echo "Environment:"
     echo "  PATH: $PATH"
     echo "  HOME: $HOME"
     echo "  SHELL: $SHELL"
     echo "========================================"
     echo
     
     # Execute the command
     start_time=$(date +%s)
     
     "$cmd" "${args[@]}"
     exit_code=$?
     
     end_time=$(date +%s)
     duration=$((end_time - start_time))
     
     echo
     echo "========================================"
     echo "Command completed with exit code: $exit_code"
     echo "Execution time: $duration seconds"
     echo "========================================"
   } &> "$LOG_FILE"
   
   # Exit with the same exit code as the command
   exit $exit_code
   ```

2. **Create a sample script to run via cron**:
   ```bash
   # Create a sample script
   touch ~/scripts/daily_report.sh
   chmod +x ~/scripts/daily_report.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: daily_report.sh
   # Description: Generates a daily system report
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Output file
   REPORT_DIR="$HOME/reports"
   REPORT_FILE="$REPORT_DIR/system_report_$(date +"%Y%m%d").txt"
   
   # Create reports directory
   mkdir -p "$REPORT_DIR"
   
   # Generate report
   {
     echo "========================================"
     echo "System Report - $(date)"
     echo "========================================"
     echo
     
     echo "System Information:"
     echo "------------------"
     echo "Hostname: $(hostname)"
     echo "Kernel: $(uname -r)"
     echo "Uptime: $(uptime)"
     echo
     
     echo "CPU Information:"
     echo "---------------"
     lscpu | grep -E "Model name|Architecture|CPU\(s\)|Thread"
     echo
     
     echo "Memory Usage:"
     echo "-------------"
     free -h
     echo
     
     echo "Disk Usage:"
     echo "-----------"
     df -h
     echo
     
     echo "Top 5 CPU Processes:"
     echo "-------------------"
     ps aux --sort=-%cpu | head -6
     echo
     
     echo "Top 5 Memory Processes:"
     echo "----------------------"
     ps aux --sort=-%mem | head -6
     echo
     
     echo "Recent Logins:"
     echo "-------------"
     last | head -10
     echo
     
     echo "========================================"
     echo "Report generated on $(date)"
     echo "========================================"
   } > "$REPORT_FILE"
   
   echo "Report generated: $REPORT_FILE"
   exit 0
   ```

3. **Set up a cron job using the wrapper**:
   ```bash
   # Edit crontab
   crontab -e
   ```

   Add the following line to run the daily report at 7:00 AM:
   ```
   # Environment setup
   PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin
   SHELL=/bin/bash
   MAILTO=""
   
   # Daily system report at 7:00 AM
   0 7 * * * $HOME/scripts/cron_wrapper.sh $HOME/scripts/daily_report.sh
   ```

4. **Test the cron job immediately**:
   ```bash
   # Run the cron wrapper manually
   ~/scripts/cron_wrapper.sh ~/scripts/daily_report.sh
   
   # Check the log
   ls -la ~/logs/cron/
   cat ~/logs/cron/daily_report.sh-*.log
   
   # Check the report
   ls -la ~/reports/
   cat ~/reports/system_report_*.txt
   ```

### Create a Job Monitoring Dashboard

1. **Create a library for job status tracking**:
   ```bash
   # Create a job status library
   touch ~/scripts/lib/job_status.sh
   chmod +x ~/scripts/lib/job_status.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Library name: job_status.sh
   # Description: Functions for tracking job status
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Ensure this file is sourced, not executed
   if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
     echo "Error: This script should be sourced, not executed."
     exit 1
   fi
   
   # Configuration
   : "${STATUS_DIR:=$HOME/job_status}"
   
   # Ensure status directory exists
   mkdir -p "$STATUS_DIR"
   
   # Job status constants
   readonly JOB_STATUS_PENDING="PENDING"
   readonly JOB_STATUS_RUNNING="RUNNING"
   readonly JOB_STATUS_SUCCESS="SUCCESS"
   readonly JOB_STATUS_FAILED="FAILED"
   readonly JOB_STATUS_WARNING="WARNING"
   
   # Update job status
   function job_update_status() {
     local job_name="$1"
     local status="$2"
     local message="${3:-}"
     local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
     local status_file="$STATUS_DIR/$job_name.status"
     
     # Create or overwrite status file
     cat > "$status_file" << EOF
   timestamp=$timestamp
   status=$status
   message=$message
   start_time=${JOB_START_TIME:-}
   end_time=${JOB_END_TIME:-}
   duration=${JOB_DURATION:-}
   exit_code=${JOB_EXIT_CODE:-}
   hostname=$(hostname)
   EOF
     
     return 0
   }
   
   # Get job status
   function job_get_status() {
     local job_name="$1"
     local status_file="$STATUS_DIR/$job_name.status"
     
     if [[ ! -f "$status_file" ]]; then
       echo "UNKNOWN"
       return 1
     fi
     
     grep -E "^status=" "$status_file" | cut -d= -f2
     return 0
   }
   
   # Start job tracking
   function job_start() {
     local job_name="$1"
     local message="${2:-Starting job}"
     
     # Record start time
     JOB_START_TIME=$(date +"%Y-%m-%d %H:%M:%S")
     
     # Update status
     job_update_status "$job_name" "$JOB_STATUS_RUNNING" "$message"
     
     return 0
   }
   
   # End job tracking
   function job_end() {
     local job_name="$1"
     local exit_code="$2"
     local message="${3:-}"
     
     # Record end time
     JOB_END_TIME=$(date +"%Y-%m-%d %H:%M:%S")
     
     # Calculate duration
     local start_seconds=$(date -d "$JOB_START_TIME" +%s)
     local end_seconds=$(date -d "$JOB_END_TIME" +%s)
     JOB_DURATION=$((end_seconds - start_seconds))
     
     # Record exit code
     JOB_EXIT_CODE="$exit_code"
     
     # Determine status based on exit code
     local status
     if [[ "$exit_code" -eq 0 ]]; then
       status="$JOB_STATUS_SUCCESS"
       message="${message:-Job completed successfully}"
     else
       status="$JOB_STATUS_FAILED"
       message="${message:-Job failed with exit code $exit_code}"
     fi
     
     # Update status
     job_update_status "$job_name" "$status" "$message"
     
     return 0
   }
   
   # Get all job status information
   function job_list_all() {
     for status_file in "$STATUS_DIR"/*.status; do
       if [[ -f "$status_file" ]]; then
         job_name=$(basename "$status_file" .status)
         status=$(grep -E "^status=" "$status_file" | cut -d= -f2)
         timestamp=$(grep -E "^timestamp=" "$status_file" | cut -d= -f2)
         message=$(grep -E "^message=" "$status_file" | cut -d= -f2)
         
         echo "$job_name|$status|$timestamp|$message"
       fi
     done
     
     return 0
   }
   ```

2. **Create a script to generate a status dashboard**:
   ```bash
   # Create a dashboard generator script
   touch ~/scripts/generate_dashboard.sh
   chmod +x ~/scripts/generate_dashboard.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: generate_dashboard.sh
   # Description: Generates a HTML dashboard for job status
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Source the job status library
   source ~/scripts/lib/job_status.sh
   
   # Configuration
   DASHBOARD_DIR="$HOME/dashboard"
   DASHBOARD_FILE="$DASHBOARD_DIR/index.html"
   REFRESH_INTERVAL=60  # Refresh interval in seconds
   
   # Create dashboard directory
   mkdir -p "$DASHBOARD_DIR"
   
   # Generate dashboard HTML
   cat > "$DASHBOARD_FILE" << EOF
   <!DOCTYPE html>
   <html lang="en">
   <head>
     <meta charset="UTF-8">
     <meta name="viewport" content="width=device-width, initial-scale=1.0">
     <meta http-equiv="refresh" content="$REFRESH_INTERVAL">
     <title>Job Status Dashboard</title>
     <style>
       body {
         font-family: Arial, sans-serif;
         margin: 0;
         padding: 20px;
         background-color: #f5f5f5;
       }
       h1 {
         color: #333;
         margin-bottom: 20px;
       }
       .dashboard {
         background-color: #fff;
         border-radius: 5px;
         box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
         padding: 20px;
       }
       .summary {
         display: flex;
         margin-bottom: 20px;
       }
       .summary-box {
         flex: 1;
         padding: 15px;
         border-radius: 5px;
         margin-right: 10px;
         color: #fff;
         text-align: center;
       }
       .summary-box:last-child {
         margin-right: 0;
       }
       .box-total { background-color: #2196F3; }
       .box-success { background-color: #4CAF50; }
       .box-failed { background-color: #F44336; }
       .box-running { background-color: #FF9800; }
       .box-pending { background-color: #9E9E9E; }
       
       table {
         width: 100%;
         border-collapse: collapse;
       }
       th, td {
         padding: 12px 15px;
         text-align: left;
         border-bottom: 1px solid #ddd;
       }
       th {
         background-color: #f2f2f2;
         font-weight: bold;
       }
       tr:hover {
         background-color: #f5f5f5;
       }
       .status {
         padding: 5px 10px;
         border-radius: 3px;
         color: #fff;
         font-weight: bold;
       }
       .status-SUCCESS { background-color: #4CAF50; }
       .status-FAILED { background-color: #F44336; }
       .status-RUNNING { background-color: #FF9800; }
       .status-PENDING { background-color: #9E9E9E; }
       .status-WARNING { background-color: #FF5722; }
       
       .footer {
         margin-top: 20px;
         text-align: center;
         color: #777;
         font-size: 14px;
       }
     </style>
   </head>
   <body>
     <div class="dashboard">
       <h1>Job Status Dashboard</h1>
       
       <div class="summary">
   EOF
   
   # Get job counts
   total_jobs=0
   success_jobs=0
   failed_jobs=0
   running_jobs=0
   pending_jobs=0
   
   while IFS="|" read -r job status timestamp message || [[ -n "$job" ]]; do
     if [[ -z "$job" ]]; then
       continue
     fi
     
     total_jobs=$((total_jobs + 1))
     
     case "$status" in
       "$JOB_STATUS_SUCCESS") success_jobs=$((success_jobs + 1)) ;;
       "$JOB_STATUS_FAILED") failed_jobs=$((failed_jobs + 1)) ;;
       "$JOB_STATUS_RUNNING") running_jobs=$((running_jobs + 1)) ;;
       "$JOB_STATUS_PENDING") pending_jobs=$((pending_jobs + 1)) ;;
     esac
   done < <(job_list_all)
   
   # Add summary boxes to dashboard
   cat >> "$DASHBOARD_FILE" << EOF
         <div class="summary-box box-total">
           <h2>Total Jobs</h2>
           <h3>$total_jobs</h3>
         </div>
         <div class="summary-box box-success">
           <h2>Successful</h2>
           <h3>$success_jobs</h3>
         </div>
         <div class="summary-box box-failed">
           <h2>Failed</h2>
           <h3>$failed_jobs</h3>
         </div>
         <div class="summary-box box-running">
           <h2>Running</h2>
           <h3>$running_jobs</h3>
         </div>
         <div class="summary-box box-pending">
           <h2>Pending</h2>
           <h3>$pending_jobs</h3>
         </div>
       </div>
       
       <table>
         <thead>
           <tr>
             <th>Job Name</th>
             <th>Status</th>
             <th>Last Updated</th>
             <th>Message</th>
           </tr>
         </thead>
         <tbody>
   EOF
   
   # Add job rows to dashboard
   while IFS="|" read -r job status timestamp message || [[ -n "$job" ]]; do
     if [[ -z "$job" ]]; then
       continue
     fi
     
     cat >> "$DASHBOARD_FILE" << EOF
           <tr>
             <td>$job</td>
             <td><span class="status status-$status">$status</span></td>
             <td>$timestamp</td>
             <td>$message</td>
           </tr>
   EOF
   done < <(job_list_all)
   
   # Complete the HTML file
   cat >> "$DASHBOARD_FILE" << EOF
         </tbody>
       </table>
       
       <div class="footer">
         <p>Last updated: $(date)</p>
         <p>Auto-refreshes every $REFRESH_INTERVAL seconds</p>
       </div>
     </div>
   </body>
   </html>
   EOF
   
   echo "Dashboard generated: $DASHBOARD_FILE"
   exit 0
   ```

3. **Create a sample job script for testing**:
   ```bash
   # Create a sample job script
   touch ~/scripts/sample_job.sh
   chmod +x ~/scripts/sample_job.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: sample_job.sh
   # Description: Sample job script for testing job status tracking
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Source the job status library
   source ~/scripts/lib/job_status.sh
   
   # Configuration
   JOB_NAME="${1:-sample_job}"
   DURATION="${2:-10}"
   SUCCESS_RATE="${3:-80}"
   
   # Start job
   job_start "$JOB_NAME" "Starting $JOB_NAME with duration $DURATION seconds"
   
   # Simulate work
   echo "Job $JOB_NAME is running..."
   sleep "$DURATION"
   
   # Determine success or failure
   random=$((RANDOM % 100 + 1))
   if [[ "$random" -le "$SUCCESS_RATE" ]]; then
     # Job succeeded
     echo "Job $JOB_NAME completed successfully"
     job_end "$JOB_NAME" 0 "Job completed successfully"
     exit 0
   else
     # Job failed
     echo "Job $JOB_NAME failed"
     job_end "$JOB_NAME" 1 "Job failed with random error"
     exit 1
   fi
   ```

4. **Test the job monitoring setup**:
   ```bash
   # Run several jobs
   ~/scripts/sample_job.sh backup_job 5 90
   ~/scripts/sample_job.sh cleanup_job 3 70
   ~/scripts/sample_job.sh report_job 4 60
   
   # Generate the dashboard
   ~/scripts/generate_dashboard.sh
   
   # View the dashboard
   # You can open the HTML file in a browser
   # For a text-based preview, you can use:
   cat ~/dashboard/index.html
   ```

5. **Schedule regular dashboard updates**:
   ```bash
   # Add to crontab
   crontab -e
   ```

   Add this line to regenerate the dashboard every 5 minutes:
   ```
   */5 * * * * $HOME/scripts/generate_dashboard.sh
   ```

## Exercise 4: Building Command-Line Tools and Integration

### Create a Command-Line Tool with Subcommands

1. **Create a file management CLI tool**:
   ```bash
   # Create a file management tool
   mkdir -p ~/scripts/file-manager
   touch ~/scripts/file-manager/file-manager.sh
   chmod +x ~/scripts/file-manager/file-manager.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Script name: file-manager.sh
   # Description: A command-line file management tool
   # Author: Your Name
   # Date: $(date +%Y-%m-%d)
   
   # Script version
   VERSION="1.0.0"
   
   # Configuration
   CONFIG_DIR="$HOME/.config/file-manager"
   CONFIG_FILE="$CONFIG_DIR/config.ini"
   DEFAULT_WORKSPACE="$HOME/workspace"
   
   # Ensure configuration directory exists
   mkdir -p "$CONFIG_DIR"
   
   # Create default configuration if it doesn't exist
   if [[ ! -f "$CONFIG_FILE" ]]; then
     cat > "$CONFIG_FILE" << EOF
   # File Manager Configuration
   
   # Default workspace directory
   workspace=$DEFAULT_WORKSPACE
   
   # Default backup directory
   backup_dir=$HOME/backups
   
   # File extensions to skip in operations
   skip_extensions=.tmp,.bak,.swp
   
   # Default compression format (zip, tar, gz)
   compression=zip
   
   # Enable verbose output (true/false)
   verbose=false
   EOF
   fi
   
   # Load configuration
   if [[ -f "$CONFIG_FILE" ]]; then
     # Extract configuration variables
     workspace=$(grep -E "^workspace=" "$CONFIG_FILE" | cut -d= -f2)
     backup_dir=$(grep -E "^backup_dir=" "$CONFIG_FILE" | cut -d= -f2)
     skip_extensions=$(grep -E "^skip_extensions=" "$CONFIG_FILE" | cut -d= -f2)
     compression=$(grep -E "^compression=" "$CONFIG_FILE" | cut -d= -f2)
     verbose=$(grep -E "^verbose=" "$CONFIG_FILE" | cut -d= -f2)
   else
     # Use defaults
     workspace="$DEFAULT_WORKSPACE"
     backup_dir="$HOME/backups"
     skip_extensions=".tmp,.bak,.swp"
     compression="zip"
     verbose="false"
   fi
   
   # Create workspace if it doesn't exist
   if [[ ! -d "$workspace" ]]; then
     mkdir -p "$workspace"
   fi
   
   # Create backup directory if it doesn't exist
   if [[ ! -d "$backup_dir" ]]; then
     mkdir -p "$backup_dir"
   fi
   
   # Verbose output function
   function verbose_output() {
     if [[ "$verbose" == "true" ]]; then
       echo "$1"
     fi
   }
   
   # Display help
   function display_help() {
     cat << EOF
   File Manager - A command-line file management tool
   
   Usage:
     $(basename "$0") [options] <command> [command-options]
   
   Options:
     -h, --help              Display this help message
     -v, --verbose           Enable verbose output
     -w, --workspace DIR     Set the workspace directory
     -b, --backup-dir DIR    Set the backup directory
     --version               Display version information
   
   Commands:
     ls, list                List files in the workspace
     find <pattern>          Find files matching pattern
     organize               Organize files by type
     clean                   Clean up temporary files
     backup [name]           Create a backup
     restore <backup>        Restore from backup
     stats                   Show file statistics
     config                  Show or edit configuration
   
   Examples:
     $(basename "$0") list
     $(basename "$0") find "*.txt"
     $(basename "$0") --workspace ~/documents organize
     $(basename "$0") backup "project-backup"
   
   For more information on each command, run:
     $(basename "$0") <command> --help
   EOF
   }
   
   # Display version
   function display_version() {
     echo "File Manager version $VERSION"
     echo "Copyright (c) $(date +%Y) Your Name"
   }
   
   # List files command
   function cmd_list() {
     local sort_by="name"
     local reverse=false
     local pattern="*"
     
     # Parse command options
     while [[ $# -gt 0 ]]; do
       case "$1" in
         --sort=*)
           sort_by="${1#*=}"
           shift
           ;;
         --reverse)
           reverse=true
           shift
           ;;
         --pattern=*)
           pattern="${1#*=}"
           shift
           ;;
         --help)
           echo "Usage: $(basename "$0") list [options]"
           echo
           echo "Options:"
           echo "  --sort=FIELD    Sort by: name, size, time (default: name)"
           echo "  --reverse       Reverse the sort order"
           echo "  --pattern=GLOB  File pattern to match (default: *)"
           echo
           echo "Examples:"
           echo "  $(basename "$0") list"
           echo "  $(basename "$0") list --sort=size --reverse"
           echo "  $(basename "$0") list --pattern=\"*.txt\""
           return 0
           ;;
         *)
           echo "Error: Unknown option for list command: $1" >&2
           return 1
           ;;
       esac
     done
     
     verbose_output "Listing files in $workspace"
     verbose_output "Sort by: $sort_by (reverse: $reverse)"
     verbose_output "Pattern: $pattern"
     
     # Build find command
     find_opts=("$workspace" -type f -name "$pattern")
     
     # Sort options
     if [[ "$sort_by" == "size" ]]; then
       if [[ "$reverse" == "true" ]]; then
         sort_opts=(-k5,5nr)  # Sort by size column, numeric, reverse
       else
         sort_opts=(-k5,5n)   # Sort by size column, numeric
       fi
     elif [[ "$sort_by" == "time" ]]; then
       if [[ "$reverse" == "true" ]]; then
         sort_opts=(-k6,7r)   # Sort by date columns, reverse
       else
         sort_opts=(-k6,7)    # Sort by date columns
       fi
     else  # Sort by name
       if [[ "$reverse" == "true" ]]; then
         sort_opts=(-k8r)     # Sort by name column, reverse
       else
         sort_opts=(-k8)      # Sort by name column
       fi
     fi
     
     # Execute command
     echo "Workspace: $workspace"
     echo
     
     echo "Mode      | Size     | Modified           | Name"
     echo "----------|----------|--------------------|-----------------"
     
     find "${find_opts[@]}" -printf "%M | %8s | %TY-%Tm-%Td %TH:%TM | %P\n" | sort "${sort_opts
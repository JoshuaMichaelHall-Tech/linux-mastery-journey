# Month 4: Terminal Tools and Shell Customization - Exercises

This document contains practical exercises to accompany the Month 4 learning guide. Complete these exercises to solidify your understanding of Zsh, Tmux, command-line tools, and shell scripting.

## Zsh Configuration Project

Create a comprehensive, customized Zsh environment with plugins, theme, and productivity enhancements.

### Tasks:

1. **Install and configure Zsh with Oh My Zsh**:
   ```bash
   # Install Zsh if not already installed
   sudo pacman -S zsh
   
   # Set as default shell
   chsh -s $(which zsh)
   
   # Install Oh My Zsh
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   ```

2. **Install essential plugins**:
   ```bash
   # Install syntax highlighting
   git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
   
   # Install autosuggestions
   git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
   
   # Install z for directory jumping
   git clone https://github.com/agkozak/zsh-z ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-z
   ```

3. **Install Powerlevel10k theme**:
   ```bash
   # Install Powerlevel10k
   git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
   
   # Install required fonts
   sudo pacman -S ttf-meslo-nerd-font-powerlevel10k
   ```

4. **Create a comprehensive .zshrc configuration**:
   ```bash
   # Back up original .zshrc
   cp ~/.zshrc ~/.zshrc.bak
   
   # Create new .zshrc
   cat > ~/.zshrc << 'EOF'
   # Enable Powerlevel10k instant prompt
   if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
     source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
   fi
   
   # Path to Oh My Zsh installation
   export ZSH="$HOME/.oh-my-zsh"
   
   # Set theme
   ZSH_THEME="powerlevel10k/powerlevel10k"
   
   # Set plugins
   plugins=(
     git
     sudo
     docker
     python
     npm
     zsh-autosuggestions
     zsh-syntax-highlighting
     zsh-z
     extract
     history
     colored-man-pages
     command-not-found
   )
   
   # Load Oh My Zsh
   source $ZSH/oh-my-zsh.sh
   
   # User configuration
   export EDITOR='nvim'
   export VISUAL='nvim'
   export PAGER='less'
   
   # History configuration
   HISTSIZE=10000
   SAVEHIST=10000
   setopt HIST_VERIFY
   setopt EXTENDED_HISTORY
   setopt HIST_EXPIRE_DUPS_FIRST
   setopt HIST_IGNORE_DUPS
   setopt HIST_IGNORE_ALL_DUPS
   setopt HIST_FIND_NO_DUPS
   setopt HIST_IGNORE_SPACE
   setopt HIST_SAVE_NO_DUPS
   setopt SHARE_HISTORY
   
   # Set directory options
   setopt AUTO_CD
   setopt AUTO_PUSHD
   setopt PUSHD_IGNORE_DUPS
   setopt PUSHD_SILENT
   
   # Completion settings
   zstyle ':completion:*' menu select
   zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
   
   # Custom aliases
   alias zshconfig="$EDITOR ~/.zshrc"
   alias ohmyzsh="$EDITOR ~/.oh-my-zsh"
   alias update="sudo pacman -Syu"
   alias ls="exa"
   alias la="exa -la --git"
   alias lt="exa -T --git-ignore"
   alias cat="bat --paging=never"
   alias grep="rg"
   alias find="fd"
   alias du="duf"
   alias cp="cp -iv"
   alias mv="mv -iv"
   alias mkdir="mkdir -pv"
   alias gst="git status"
   alias ga="git add"
   alias gc="git commit"
   alias gp="git push"
   alias gl="git pull"
   
   # Custom functions
   mkcd() {
     mkdir -p "$1" && cd "$1"
   }
   
   extract() {
     if [ -f $1 ] ; then
       case $1 in
         *.tar.bz2)   tar xjf $1     ;;
         *.tar.gz)    tar xzf $1     ;;
         *.bz2)       bunzip2 $1     ;;
         *.rar)       unrar e $1     ;;
         *.gz)        gunzip $1      ;;
         *.tar)       tar xf $1      ;;
         *.tbz2)      tar xjf $1     ;;
         *.tgz)       tar xzf $1     ;;
         *.zip)       unzip $1       ;;
         *.Z)         uncompress $1  ;;
         *.7z)        7z x $1        ;;
         *)           echo "'$1' cannot be extracted via extract()" ;;
       esac
     else
       echo "'$1' is not a valid file"
     fi
   }
   
   backup() {
     cp "$1"{,.bak}
     echo "Created backup of $1 to $1.bak"
   }
   
   weather() {
     curl -s "wttr.in/${1:-}?m1"
   }
   
   # Load Powerlevel10k configuration
   [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
   
   # FZF configuration
   [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
   export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
   export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
   export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
   
   # Load any local configurations
   [[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local
   EOF
   ```

## Self-Assessment Quiz - Answers

1. **What is the difference between .zshrc and .zprofile in terms of when they are loaded?**
   - .zprofile is loaded for login shells, while .zshrc is loaded for interactive shells. In practice, .zprofile runs once at login, while .zshrc runs every time you open a new terminal.

2. **How would you customize your Zsh prompt to show git branch information?**
   - Using Oh My Zsh, you can add the git plugin to your plugins list. With Powerlevel10k, git information is included by default. Manually, you would use `$(git branch --show-current 2>/dev/null)` in your prompt variable.

3. **What command would you use to create a new Tmux session named "development" with the first window named "code"?**
   - `tmux new-session -s development -n code`

4. **How do you split a Tmux pane horizontally? How do you split it vertically?**
   - Horizontally (one above the other): `Prefix + -` (with our configuration)
   - Vertically (side by side): `Prefix + |` (with our configuration)

5. **What is the primary advantage of ripgrep over standard grep?**
   - Ripgrep is significantly faster, respects .gitignore files, has better Unicode support, and includes colored output by default.

6. **Which utility would you use to navigate a directory tree and find files with fuzzy matching?**
   - fzf (Fuzzy Finder)

7. **What's the purpose of the `set -euo pipefail` directive at the beginning of a bash script?**
   - It makes scripts exit immediately if any command fails (`-e`), treats unset variables as an error (`-u`), and causes pipelines to return the exit status of the last command to exit with a non-zero status (`-o pipefail`).

8. **Write a simple function that creates a backup of a file by copying it with a .bak extension.**
   ```bash
   backup() {
     cp "$1"{,.bak}
     echo "Created backup of $1 to $1.bak"
   }
   ```

9. **How would you create a Zsh alias that lists all files, including hidden ones, with human-readable sizes?**
   ```bash
   alias lah="ls -lah"  # Using standard ls
   # Or with exa:
   alias lah="exa -la --git -h"
   ```

10. **What tool would you use to visualize disk usage by directory in the terminal?**
    - ncdu (NCurses Disk Usage)

## Next Steps

After completing the Month 4 exercises, consider these activities to further enhance your terminal skills:

1. **Integrate your custom configurations with your dotfiles repository** for easy synchronization across machines

2. **Create more specialized scripts for your specific workflow needs**, such as database management or deployment automation

3. **Explore additional modern CLI tools** like "delta" for better git diffs or "procs" as an alternative to ps/top

4. **Create a personalized cheatsheet** of your most-used terminal commands and shortcuts

5. **Set up SSH keys and config files** for easy remote server management 

6. **Implement custom keyboard shortcuts** for your terminal emulator to speed up common tasks

7. **Create project-specific aliases and functions** that activate when you enter certain directories

8. **Experiment with alternative terminal emulators** like Alacritty or Kitty for better performance and features

Regularly review and refine your terminal workflow to continue improving your productivity!

## Acknowledgements

These exercises were developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Exercise structure and organization
- Script development and examples
- Documentation templates

Claude was used as a development aid while all final implementation decisions and review were performed by Joshua Michael Hall.

## Disclaimer

These exercises are provided "as is", without warranty of any kind. Always make backups before making system changes or implementing new scripts. Test all scripts in a safe environment before using them in production scenarios.

## Shell Scripting Project

Create a comprehensive developer toolkit with shell scripts to automate common tasks.

### Tasks:

1. **Set up the script library structure**:
   ```bash
   mkdir -p ~/dev-toolkit/{bin,lib,config,docs}
   ```

2. **Create a library of common shell functions**:
   ```bash
   cat > ~/dev-toolkit/lib/common.sh << 'EOF'
   #!/bin/bash
   # Common utilities for dev-toolkit scripts
   
   # Make sure this file is sourced, not executed
   if [ "$0" = "${BASH_SOURCE[0]}" ]; then
     echo "Error: This file should be sourced, not executed."
     exit 1
   fi
   
   # Colors and formatting
   RED='\033[0;31m'
   GREEN='\033[0;32m'
   YELLOW='\033[0;33m'
   BLUE='\033[0;34m'
   PURPLE='\033[0;35m'
   CYAN='\033[0;36m'
   GRAY='\033[0;37m'
   BOLD='\033[1m'
   RESET='\033[0m'
   
   # Logging functions
   function log_info() {
     echo -e "${BLUE}[INFO]${RESET} $*"
   }
   
   function log_success() {
     echo -e "${GREEN}[SUCCESS]${RESET} $*"
   }
   
   function log_warning() {
     echo -e "${YELLOW}[WARNING]${RESET} $*"
   }
   
   function log_error() {
     echo -e "${RED}[ERROR]${RESET} $*" >&2
   }
   
   function log_debug() {
     if [ "${DEBUG:-0}" -eq 1 ]; then
       echo -e "${GRAY}[DEBUG]${RESET} $*"
     fi
   }
   
   # Utility functions
   function confirm() {
     read -r -p "${1:-Are you sure? [y/N]} " response
     case "$response" in
       [yY][eE][sS]|[yY])
         return 0
         ;;
       *)
         return 1
         ;;
     esac
   }
   
   function require_command() {
     for cmd in "$@"; do
       if ! command -v "$cmd" &> /dev/null; then
         log_error "Required command not found: $cmd"
         return 1
       fi
     done
     return 0
   }
   
   function is_git_repo() {
     git rev-parse --is-inside-work-tree &> /dev/null
   }
   
   function get_git_branch() {
     git rev-parse --abbrev-ref HEAD 2> /dev/null
   }
   
   function timestamp() {
     date "+%Y-%m-%d %H:%M:%S"
   }
   
   function file_exists() {
     [ -f "$1" ]
   }
   
   function dir_exists() {
     [ -d "$1" ]
   }
   
   function backup_file() {
     local file="$1"
     if [ -f "$file" ]; then
       cp "$file" "${file}.$(date +%Y%m%d%H%M%S).bak"
       return $?
     else
       log_error "Cannot backup non-existent file: $file"
       return 1
     fi
   }
   
   function extract() {
     if [ -f "$1" ]; then
       case "$1" in
         *.tar.bz2)   tar xjf "$1"     ;;
         *.tar.gz)    tar xzf "$1"     ;;
         *.bz2)       bunzip2 "$1"     ;;
         *.rar)       unrar e "$1"     ;;
         *.gz)        gunzip "$1"      ;;
         *.tar)       tar xf "$1"      ;;
         *.tbz2)      tar xjf "$1"     ;;
         *.tgz)       tar xzf "$1"     ;;
         *.zip)       unzip "$1"       ;;
         *.Z)         uncompress "$1"  ;;
         *.7z)        7z x "$1"        ;;
         *)           log_error "'$1' cannot be extracted via extract" ; return 1 ;;
       esac
       return 0
     else
       log_error "'$1' is not a valid file"
       return 1
     fi
   }
   EOF
   ```

3. **Create a main toolkit script**:
   ```bash
   cat > ~/dev-toolkit/bin/dev-toolkit << 'EOF'
   #!/bin/bash
   # Dev Toolkit - Main script
   
   # Determine the script location
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   TOOLKIT_DIR="$(dirname "$SCRIPT_DIR")"
   
   # Source common functions
   source "$TOOLKIT_DIR/lib/common.sh"
   
   # Print banner
   function print_banner() {
     echo -e "${BLUE}=====================================${RESET}"
     echo -e "${BLUE}        DEVELOPER TOOLKIT           ${RESET}"
     echo -e "${BLUE}=====================================${RESET}"
     echo ""
   }
   
   # Display help
   function show_help() {
     print_banner
     
     echo -e "Usage: dev-toolkit ${BOLD}COMMAND${RESET} [OPTIONS]"
     echo ""
     echo -e "${BOLD}Commands:${RESET}"
     echo -e "  ${CYAN}setup${RESET}        Set up project environment"
     echo -e "  ${CYAN}git-tools${RESET}    Git workflow utilities"
     echo -e "  ${CYAN}docker${RESET}       Docker development utilities"
     echo -e "  ${CYAN}db${RESET}           Database utilities"
     echo -e "  ${CYAN}server${RESET}       Server management utilities"
     echo -e "  ${CYAN}stats${RESET}        Project statistics"
     echo -e "  ${CYAN}docs${RESET}         Documentation utilities"
     echo -e "  ${CYAN}config${RESET}       Configure toolkit settings"
     echo -e "  ${CYAN}help${RESET}         Show this help"
     echo ""
     echo -e "Use 'dev-toolkit ${BOLD}COMMAND${RESET} --help' for command-specific help."
     echo ""
   }
   
   # Check for dependencies
   function check_dependencies() {
     log_debug "Checking dependencies..."
     require_command git jq curl || exit 1
   }
   
   # Load toolkit configuration
   function load_config() {
     CONFIG_FILE="$TOOLKIT_DIR/config/settings.json"
     
     if [ ! -f "$CONFIG_FILE" ]; then
       log_debug "No configuration file found, creating default..."
       
       mkdir -p "$(dirname "$CONFIG_FILE")"
       cat > "$CONFIG_FILE" << 'ENDCONFIG'
   {
     "user": {
       "name": "",
       "email": ""
     },
     "projects_dir": "~/projects",
     "git": {
       "default_branch": "main",
       "auto_push": false
     },
     "docker": {
       "compose_version": "3.8"
     },
     "editor": "nvim"
   }
   ENDCONFIG
     fi
     
     if ! jq -e . "$CONFIG_FILE" > /dev/null 2>&1; then
       log_error "Invalid configuration file: $CONFIG_FILE"
       exit 1
     fi
     
     # Load default editor
     EDITOR=$(jq -r '.editor // "vim"' "$CONFIG_FILE")
     export EDITOR
     
     # Load projects directory
     PROJECTS_DIR=$(jq -r '.projects_dir // "~/projects"' "$CONFIG_FILE")
     PROJECTS_DIR="${PROJECTS_DIR/#\~/$HOME}"
     
     log_debug "Configuration loaded successfully"
   }
   
   # Handle commands
   function run_command() {
     local command="$1"
     shift
     
     case "$command" in
       setup)
         "$SCRIPT_DIR/project-setup" "$@"
         ;;
       git-tools)
         "$SCRIPT_DIR/git-tools" "$@"
         ;;
       docker)
         "$SCRIPT_DIR/docker-tools" "$@"
         ;;
       db)
         "$SCRIPT_DIR/db-tools" "$@"
         ;;
       server)
         "$SCRIPT_DIR/server-tools" "$@"
         ;;
       stats)
         "$SCRIPT_DIR/project-stats" "$@"
         ;;
       docs)
         "$SCRIPT_DIR/doc-tools" "$@"
         ;;
       config)
         "$SCRIPT_DIR/config-tool" "$@"
         ;;
       help)
         show_help
         ;;
       *)
         log_error "Unknown command: $command"
         echo ""
         show_help
         exit 1
         ;;
     esac
   }
   
   # Main function
   function main() {
     if [ "$DEBUG" = "1" ]; then
       set -x
     fi
     
     check_dependencies
     load_config
     
     if [ $# -eq 0 ]; then
       show_help
       exit 0
     fi
     
     local command="$1"
     shift
     
     run_command "$command" "$@"
   }
   
   # Execute main
   main "$@"
   EOF
   
   # Make executable
   chmod +x ~/dev-toolkit/bin/dev-toolkit
   ```

4. **Create a git tools script**:
   ```bash
   cat > ~/dev-toolkit/bin/git-tools << 'EOF'
   #!/bin/bash
   # Git workflow utilities
   
   # Determine the script location
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   TOOLKIT_DIR="$(dirname "$SCRIPT_DIR")"
   
   # Source common functions
   source "$TOOLKIT_DIR/lib/common.sh"
   
   # Display help
   function show_help() {
     echo -e "${BLUE}=====================================${RESET}"
     echo -e "${BLUE}        GIT WORKFLOW TOOLS          ${RESET}"
     echo -e "${BLUE}=====================================${RESET}"
     echo ""
     echo -e "Usage: git-tools ${BOLD}COMMAND${RESET} [OPTIONS]"
     echo ""
     echo -e "${BOLD}Commands:${RESET}"
     echo -e "  ${CYAN}new-branch NAME${RESET}    Create a new feature branch"
     echo -e "  ${CYAN}publish${RESET}            Push current branch to origin"
     echo -e "  ${CYAN}update${RESET}             Update current branch with latest main/master"
     echo -e "  ${CYAN}sync${RESET}               Sync all branches with remote"
     echo -e "  ${CYAN}cleanup${RESET}            Remove merged branches"
     echo -e "  ${CYAN}changelog${RESET}          Generate changelog from commits"
     echo -e "  ${CYAN}undo${RESET}               Undo last commit (keeping changes)"
     echo -e "  ${CYAN}wip${RESET}                Commit work-in-progress changes"
     echo -e "  ${CYAN}unwip${RESET}              Undo WIP commit"
     echo -e "  ${CYAN}save NAME${RESET}          Save current changes to a stash"
     echo -e "  ${CYAN}apply [NAME]${RESET}       Apply a saved stash"
     echo -e "  ${CYAN}list-stashes${RESET}       List all saved stashes"
     echo -e "  ${CYAN}standup${RESET}            Show your commits from the last day"
     echo -e "  ${CYAN}stats${RESET}              Show commit statistics"
     echo -e "  ${CYAN}help${RESET}               Show this help"
     echo ""
   }
   
   # Check if current directory is a git repository
   function check_git_repo() {
     if ! is_git_repo; then
       log_error "Not a git repository"
       exit 1
     fi
   }
   
   # Create a new feature branch
   function new_branch() {
     if [ -z "$1" ]; then
       log_error "Branch name required"
       return 1
     fi
     
     local branch="$1"
     local main_branch=""
     
     # Determine main branch (main or master)
     if git show-ref --verify --quiet refs/heads/main; then
       main_branch="main"
     elif git show-ref --verify --quiet refs/heads/master; then
       main_branch="master"
     else
       log_error "Neither main nor master branch found"
       return 1
     fi
     
     # Update main branch
     log_info "Updating $main_branch branch..."
     git checkout "$main_branch"
     git pull origin "$main_branch"
     
     # Create new branch
     log_info "Creating new branch: $branch"
     git checkout -b "$branch"
     log_success "Created and switched to branch '$branch' from '$main_branch'"
   }
   
   # Push current branch to origin
   function publish() {
     local current_branch=$(get_git_branch)
     
     if [ -z "$current_branch" ]; then
       log_error "Failed to determine current branch"
       return 1
     fi
     
     log_info "Pushing '$current_branch' to origin..."
     git push -u origin "$current_branch"
     log_success "Branch published successfully"
   }
   
   # Update current branch with latest main/master
   function update() {
     local current_branch=$(get_git_branch)
     local main_branch=""
     
     if [ -z "$current_branch" ]; then
       log_error "Failed to determine current branch"
       return 1
     fi
     
     # Determine main branch (main or master)
     if git show-ref --verify --quiet refs/heads/main; then
       main_branch="main"
     elif git show-ref --verify --quiet refs/heads/master; then
       main_branch="master"
     else
       log_error "Neither main nor master branch found"
       return 1
     fi
     
     # Stash changes if needed
     local stashed=0
     if ! git diff --quiet; then
       log_info "Stashing working changes..."
       git stash
       stashed=1
     fi
     
     # Update main branch
     log_info "Updating $main_branch branch..."
     git checkout "$main_branch"
     git pull origin "$main_branch"
     
     # Rebase feature branch
     log_info "Updating '$current_branch' with latest '$main_branch'..."
     git checkout "$current_branch"
     git rebase "$main_branch"
     
     # Apply stash if needed
     if [ $stashed -eq 1 ]; then
       log_info "Applying stashed changes..."
       git stash pop
     fi
     
     log_success "Branch '$current_branch' updated with latest '$main_branch'"
   }
   
   # Sync all branches with remote
   function sync() {
     log_info "Syncing with remote repository..."
     git fetch --all --prune
     log_success "Synced with remote repository"
   }
   
   # Remove merged branches
   function cleanup() {
     local main_branch=""
     
     # Determine main branch (main or master)
     if git show-ref --verify --quiet refs/heads/main; then
       main_branch="main"
     elif git show-ref --verify --quiet refs/heads/master; then
       main_branch="master"
     else
       log_error "Neither main nor master branch found"
       return 1
     fi
     
     # Delete local branches that have been merged
     log_info "Switching to $main_branch branch..."
     git checkout "$main_branch"
     
     log_info "Identifying merged branches..."
     local merged_branches=$(git branch --merged | grep -v "\*" | grep -v "$main_branch" | tr -d ' ')
     
     if [ -z "$merged_branches" ]; then
       log_info "No merged branches to clean up"
       return 0
     fi
     
     echo "The following branches will be deleted:"
     echo "$merged_branches"
     echo ""
     
     if confirm "Proceed with deletion? [y/N]"; then
       log_info "Deleting merged branches..."
       git branch --merged | grep -v "\*" | grep -v "$main_branch" | xargs -r git branch -d
       log_success "Cleaned up merged branches"
     else
       log_info "Cleanup canceled"
     fi
   }
   
   # Generate changelog from commits
   function changelog() {
     local days=${1:-7}
     
     log_info "Generating changelog for the last $days days..."
     echo "Changelog ($(date -d "$days days ago" "+%Y-%m-%d") to $(date "+%Y-%m-%d")):"
     echo "======================================================"
     git log --pretty=format:"- %s (%an, %ad)" --date=short --since="$days days ago"
     echo ""
   }
   
   # Undo last commit
   function undo() {
     log_info "Undoing last commit while preserving changes..."
     git reset --soft HEAD^
     log_success "Undid last commit, changes preserved in working directory"
   }
   
   # Commit work-in-progress changes
   function wip() {
     log_info "Creating WIP commit..."
     git add .
     git commit -m "WIP: Work in progress [skip ci]"
     log_success "Created WIP commit"
   }
   
   # Undo WIP commit
   function unwip() {
     local last_msg=$(git log -1 --pretty=%B)
     if [[ "$last_msg" == "WIP: "* ]]; then
       log_info "Undoing WIP commit..."
       git reset --soft HEAD^
       log_success "Undid WIP commit, changes preserved in working directory"
     else
       log_error "Last commit is not a WIP commit"
       return 1
     fi
   }
   
   # Save changes to a stash
   function save_stash() {
     if [ -z "$1" ]; then
       log_error "Stash name required"
       return 1
     fi
     
     local stash_name="$1"
     
     if ! git diff --quiet || ! git diff --cached --quiet; then
       log_info "Saving changes to stash: $stash_name"
       git stash push -m "$stash_name"
       log_success "Changes saved to stash: $stash_name"
     else
       log_warning "No changes to stash"
     fi
   }
   
   # Apply a saved stash
   function apply_stash() {
     if [ -z "$1" ]; then
       # Get the most recent stash
       log_info "Applying most recent stash..."
       git stash apply
       log_success "Applied most recent stash"
     else
       # Find the stash by name
       local stash_id=$(git stash list | grep "$1" | cut -d: -f1)
       
       if [ -n "$stash_id" ]; then
         log_info "Applying stash: $1 ($stash_id)"
         git stash apply "$stash_id"
         log_success "Applied stash: $1"
       else
         log_error "Stash not found: $1"
         return 1
       fi
     fi
   }
   
   # List all stashes
   function list_stashes() {
     log_info "Listing saved stashes..."
     git stash list
   }
   
   # Show user's recent commits
   function standup() {
     local since=${1:-yesterday}
     local author=$(git config user.email)
     
     log_info "Showing your commits since $since..."
     git log --author="$author" --since="$since" --format="%h - %s"
   }
   
   # Show commit statistics
   function show_stats() {
     log_info "Generating commit statistics..."
     
     echo "Total commits: $(git rev-list --count HEAD)"
     echo "Your commits: $(git rev-list --count --author=\"$(git config user.email)\" HEAD)"
     echo ""
     
     echo "Commits by author:"
     git shortlog -sn --all
     echo ""
     
     echo "Commits by day of week:"
     git log --format="%ad" --date=format:"%A" | sort | uniq -c | sort -nr
     echo ""
     
     echo "Commits by hour of day:"
     git log --format="%ad" --date=format:"%H" | sort | uniq -c
   }
   
   # Check git repository
   check_git_repo
   
   # Parse command
   if [ $# -eq 0 ]; then
     show_help
     exit 0
   fi
   
   COMMAND="$1"
   shift
   
   case "$COMMAND" in
     new-branch)
       new_branch "$@"
       ;;
     publish)
       publish
       ;;
     update)
       update
       ;;
     sync)
       sync
       ;;
     cleanup)
       cleanup
       ;;
     changelog)
       changelog "$@"
       ;;
     undo)
       undo
       ;;
     wip)
       wip
       ;;
     unwip)
       unwip
       ;;
     save)
       save_stash "$@"
       ;;
     apply)
       apply_stash "$@"
       ;;
     list-stashes)
       list_stashes
       ;;
     standup)
       standup "$@"
       ;;
     stats)
       show_stats
       ;;
     help|*)
       show_help
       ;;
   esac
   
   exit 0
   EOF
   
   # Make it executable
   chmod +x ~/dev-toolkit/bin/git-tools
   ```

5. **Create a project setup script**:
   ```bash
   cat > ~/dev-toolkit/bin/project-setup << 'EOF'
   #!/bin/bash
   # Project setup utilities
   
   # Determine the script location
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   TOOLKIT_DIR="$(dirname "$SCRIPT_DIR")"
   
   # Source common functions
   source "$TOOLKIT_DIR/lib/common.sh"
   
   # Load toolkit configuration
   CONFIG_FILE="$TOOLKIT_DIR/config/settings.json"
   PROJECTS_DIR=$(jq -r '.projects_dir // "~/projects"' "$CONFIG_FILE")
   PROJECTS_DIR="${PROJECTS_DIR/#\~/$HOME}"
   
   # Display help
   function show_help() {
     echo -e "${BLUE}=====================================${RESET}"
     echo -e "${BLUE}        PROJECT SETUP TOOLS         ${RESET}"
     echo -e "${BLUE}=====================================${RESET}"
     echo ""
     echo -e "Usage: project-setup ${BOLD}COMMAND${RESET} [OPTIONS]"
     echo ""
     echo -e "${BOLD}Commands:${RESET}"
     echo -e "  ${CYAN}create NAME TYPE${RESET}      Create a new project"
     echo -e "  ${CYAN}list${RESET}                  List available project types"
     echo -e "  ${CYAN}clone URL [DIR]${RESET}       Clone a repository"
     echo -e "  ${CYAN}scaffold DIR TYPE${RESET}     Scaffold a project structure"
     echo -e "  ${CYAN}template DIR NAME${RESET}     Apply a template to a project"
     echo -e "  ${CYAN}help${RESET}                  Show this help"
     echo ""
     echo -e "${BOLD}Available project types:${RESET}"
     echo -e "  python         Python project with virtual environment"
     echo -e "  node           Node.js/JavaScript project"
     echo -e "  web            Static web project"
     echo -e "  go             Go project"
     echo -e "  rust           Rust project"
     echo ""
   }
   
   # List available project types
   function list_types() {
     echo -e "${BLUE}Available Project Types:${RESET}"
     echo -e "${CYAN}python${RESET}       Python project with virtual environment"
     echo -e "${CYAN}node${RESET}         Node.js/JavaScript project"
     echo -e "${CYAN}web${RESET}          Static web project"
     echo -e "${CYAN}go${RESET}           Go project"
     echo -e "${CYAN}rust${RESET}         Rust project"
   }
   
   # Create a new project
   function create_project() {
     if [ -z "$1" ] || [ -z "$2" ]; then
       log_error "Project name and type required"
       echo "Usage: project-setup create NAME TYPE"
       list_types
       return 1
     fi
     
     local name="$1"
     local type="$2"
     local project_dir="$PROJECTS_DIR/$name"
     
     # Check if project directory already exists
     if [ -d "$project_dir" ]; then
       log_error "Project directory already exists: $project_dir"
       return 1
     fi
     
     # Create project directory
     mkdir -p "$project_dir"
     cd "$project_dir" || return 1
     
     # Initialize git repository
     log_info "Initializing git repository..."
     git init
     
     # Create README.md
     cat > README.md << READMEEOF
   # $name
   
   Project created on $(date "+%Y-%m-%d")
   
   ## Description
   
   A brief description of your project.
   
   ## Installation
   
   Installation instructions here.
   
   ## Usage
   
   Usage examples here.
   
   ## License
   
   MIT
   
   ## Acknowledgements
   
   This project was developed with assistance from Anthropic's Claude AI assistant, which helped with:
   - Documentation writing and organization
   - Code structure suggestions
   - Troubleshooting and debugging assistance
   
   Claude was used as a development aid while all final implementation decisions and code review were performed by Joshua Michael Hall.
   READMEEOF
     
     # Create .gitignore
     log_info "Creating .gitignore..."
     
     # Create project structure based on type
     case "$type" in
       python)
         scaffold_python_project "$project_dir"
         ;;
       node)
         scaffold_node_project "$project_dir"
         ;;
       web)
         scaffold_web_project "$project_dir"
         ;;
       go)
         scaffold_go_project "$project_dir"
         ;;
       rust)
         scaffold_rust_project "$project_dir"
         ;;
       *)
         log_error "Unknown project type: $type"
         list_types
         return 1
         ;;
     esac
     
     log_success "Project created successfully: $name ($type)"
     log_info "Location: $project_dir"
     log_info "Next steps:"
     log_info "  cd $project_dir"
     log_info "  git add ."
     log_info "  git commit -m \"Initial commit\""
   }
   
   # Clone a repository
   function clone_repo() {
     if [ -z "$1" ]; then
       log_error "Repository URL required"
       echo "Usage: project-setup clone URL [DIR]"
       return 1
     fi
     
     local url="$1"
     local dir="${2:-}"
     local clone_dir
     
     if [ -n "$dir" ]; then
       clone_dir="$PROJECTS_DIR/$dir"
     else
       # Extract repository name from URL
       local repo_name=$(basename "$url" .git)
       clone_dir="$PROJECTS_DIR/$repo_name"
     fi
     
     log_info "Cloning repository..."
     git clone "$url" "$clone_dir"
     
     if [ $? -eq 0 ]; then
       log_success "Repository cloned successfully"
       log_info "Location: $clone_dir"
     else
       log_error "Failed to clone repository"
       return 1
     fi
   }
   
   # Scaffold Python project
   function scaffold_python_project() {
     local project_dir="$1"
     
     log_info "Scaffolding Python project..."
     
     # Create project structure
     mkdir -p "$project_dir"/{src,tests,docs}
     touch "$project_dir/src/__init__.py"
     touch "$project_dir/tests/__init__.py"
     
     # Create setup.py
     cat > "$project_dir/setup.py" << EOF
   from setuptools import setup, find_packages
   
   setup(
       name="$(basename "$project_dir")",
       version="0.1.0",
       packages=find_packages(where="src"),
       package_dir={"": "src"},
       python_requires=">=3.8",
       install_requires=[],
   )
   EOF
     
     # Create pyproject.toml
     cat > "$project_dir/pyproject.toml" << EOF
   [build-system]
   requires = ["setuptools>=42", "wheel"]
   build-backend = "setuptools.build_meta"
   
   [tool.black]
   line-length = 88
   
   [tool.isort]
   profile = "black"
   
   [tool.pytest]
   testpaths = ["tests"]
   EOF
     
     # Create requirements files
     touch "$project_dir/requirements.txt"
     touch "$project_dir/requirements-dev.txt"
     
     # Create a .gitignore file for Python
     cat > "$project_dir/.gitignore" << EOF
   # Byte-compiled / optimized / DLL files
   __pycache__/
   *.py[cod]
   *$py.class
   
   # Distribution / packaging
   dist/
   build/
   *.egg-info/
   
   # Unit test / coverage reports
   htmlcov/
   .tox/
   .coverage
   .coverage.*
   .cache
   .pytest_cache/
   
   # Environments
   .env
   .venv
   env/
   venv/
   ENV/
   
   # IDE settings
   .idea/
   .vscode/
   *.swp
   *.swo
   EOF
     
     # Create a sample test
     cat > "$project_dir/tests/test_sample.py" << EOF
   def test_sample():
       assert True
   EOF
     
     # Initialize virtual environment
     log_info "Creating virtual environment..."
     cd "$project_dir" || return 1
     python -m venv venv
     
     log_success "Python project scaffolded successfully"
   }
   
   # Scaffold Node.js project
   function scaffold_node_project() {
     local project_dir="$1"
     
     log_info "Scaffolding Node.js project..."
     
     # Create project structure
     mkdir -p "$project_dir"/{src,test,config}
     
     # Create package.json
     cat > "$project_dir/package.json" << EOF
   {
     "name": "$(basename "$project_dir")",
     "version": "1.0.0",
     "description": "",
     "main": "src/index.js",
     "scripts": {
       "start": "node src/index.js",
       "test": "jest"
     },
     "keywords": [],
     "author": "",
     "license": "MIT"
   }
   EOF
     
     # Create index.js
     cat > "$project_dir/src/index.js" << EOF
   console.log('Hello, world!');
   EOF
     
     # Create a .gitignore file for Node.js
     cat > "$project_dir/.gitignore" << EOF
   # Dependency directories
   node_modules/
   
   # Build output
   dist/
   build/
   
   # Logs
   logs
   *.log
   npm-debug.log*
   yarn-debug.log*
   yarn-error.log*
   
   # Environment variables
   .env
   .env.local
   .env.development.local
   .env.test.local
   .env.production.local
   
   # IDE settings
   .idea/
   .vscode/
   *.swp
   *.swo
   
   # Coverage directory
   coverage/
   EOF
     
     log_success "Node.js project scaffolded successfully"
   }
   
   # Scaffold web project
   function scaffold_web_project() {
     local project_dir="$1"
     
     log_info "Scaffolding web project..."
     
     # Create project structure
     mkdir -p "$project_dir"/{css,js,img}
     
     # Create index.html
     cat > "$project_dir/index.html" << EOF
   <!DOCTYPE html>
   <html lang="en">
   <head>
       <meta charset="UTF-8">
       <meta name="viewport" content="width=device-width, initial-scale=1.0">
       <title>$(basename "$project_dir")</title>
       <link rel="stylesheet" href="css/styles.css">
   </head>
   <body>
       <h1>$(basename "$project_dir")</h1>
       <p>Welcome to your new web project!</p>
       
       <script src="js/main.js"></script>
   </body>
   </html>
   EOF
     
     # Create CSS file
     cat > "$project_dir/css/styles.css" << EOF
   body {
       font-family: Arial, sans-serif;
       margin: 0;
       padding: 20px;
       line-height: 1.6;
   }
   
   h1 {
       color: #333;
   }
   EOF
     
     # Create JavaScript file
     cat > "$project_dir/js/main.js" << EOF
   // Main JavaScript file
   console.log('Script loaded');
   EOF
     
     # Create a .gitignore file for web projects
     cat > "$project_dir/.gitignore" << EOF
   # Dependency directories
   node_modules/
   
   # Build output
   dist/
   build/
   
   # IDE settings
   .idea/
   .vscode/
   *.swp
   *.swo
   
   # OS files
   .DS_Store
   Thumbs.db
   EOF
     
     log_success "Web project scaffolded successfully"
   }
   
   # Scaffold Go project
   function scaffold_go_project() {
     local project_dir="$1"
     local module_name=$(basename "$project_dir")
     
     log_info "Scaffolding Go project..."
     
     # Create project structure
     mkdir -p "$project_dir"/{cmd,internal,pkg}
     
     # Initialize Go module
     cd "$project_dir" || return 1
     go mod init "github.com/$(git config user.username 2>/dev/null || echo "yourusername")/$module_name"
     
     # Create main.go
     mkdir -p "$project_dir/cmd/$module_name"
     cat > "$project_dir/cmd/$module_name/main.go" << EOF
   package main
   
   import (
       "fmt"
   )
   
   func main() {
       fmt.Println("Hello, world!")
   }
   EOF
     
     # Create a .gitignore file for Go
     cat > "$project_dir/.gitignore" << EOF
   # Binaries for programs and plugins
   *.exe
   *.exe~
   *.dll
   *.so
   *.dylib
   
   # Test binary, built with `go test -c`
   *.test
   
   # Output of the go coverage tool, specifically when used with LiteIDE
   *.out
   
   # Dependency directories
   vendor/
   
   # IDE settings
   .idea/
   .vscode/
   *.swp
   *.swo
   EOF
     
     log_success "Go project scaffolded successfully"
   }
   
   # Scaffold Rust project
   function scaffold_rust_project() {
     local project_dir="$1"
     
     log_info "Scaffolding Rust project..."
     
     # Check if cargo is installed
     if ! command -v cargo &> /dev/null; then
       log_error "Cargo is required for Rust projects"
       return 1
     fi
     
     # Create a new Rust project
     cargo new --bin "$(basename "$project_dir")"
     
     # Copy the generated files to the target directory
     if [ "$(basename "$project_dir")" != "$(basename "$PWD")/$(basename "$project_dir")" ]; then
       cp -r "$(basename "$project_dir")"/* "$project_dir"
       cp -r "$(basename "$project_dir")/.git" "$project_dir" 2>/dev/null
       rm -rf "$(basename "$project_dir")"
     fi
     
     log_success "Rust project scaffolded successfully"
   }
   
   # Main command parsing
   if [ $# -eq 0 ]; then
     show_help
     exit 0
   fi
   
   COMMAND="$1"
   shift
   
   case "$COMMAND" in
     create)
       create_project "$@"
       ;;
     list)
       list_types
       ;;
     clone)
       clone_repo "$@"
       ;;
     scaffold)
       # This would call the appropriate scaffold function
       log_error "Not implemented yet"
       ;;
     template)
       # This would apply a template to a project
       log_error "Not implemented yet"
       ;;
     help|*)
       show_help
       ;;
   esac
   
   exit 0
   EOF
   
   # Make it executable
   chmod +x ~/dev-toolkit/bin/project-setup
   ```

6. **Add symlinks to make the tools easily accessible**:
   ```bash
   # Create a bin directory in your home directory
   mkdir -p ~/bin
   
   # Create symlinks to the toolkit scripts
   ln -sf ~/dev-toolkit/bin/dev-toolkit ~/bin/dev-toolkit
   ln -sf ~/dev-toolkit/bin/git-tools ~/bin/git-tools
   ln -sf ~/dev-toolkit/bin/project-setup ~/bin/project-setup
   
   # Add to .zshrc if not already there
   if ! grep -q "PATH=\"\$HOME/bin:\$PATH\"" ~/.zshrc; then
     echo '# Dev toolkit bin directory' >> ~/.zshrc
     echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
   fi
   ```

7. **Create documentation for your toolkit**:
   ```bash
   cat > ~/dev-toolkit/docs/README.md << 'EOF'
   # Developer Toolkit Documentation
   
   This is a collection of command-line tools for software development. The toolkit provides utilities for project management, git workflows, and more.
   
   ## Installation
   
   ```bash
   # Clone the repository (or just create the directory structure)
   mkdir -p ~/dev-toolkit/{bin,lib,config,docs}
   
   # Add bin directory to PATH
   echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
   
   # Create symlinks
   ln -sf ~/dev-toolkit/bin/dev-toolkit ~/bin/dev-toolkit
   ln -sf ~/dev-toolkit/bin/git-tools ~/bin/git-tools
   ln -sf ~/dev-toolkit/bin/project-setup ~/bin/project-setup
   ```
   
   ## Available Tools
   
   ### Main Toolkit
   
   The `dev-toolkit` command provides access to all available tools:
   
   ```bash
   dev-toolkit help
   ```
   
   ### Git Tools
   
   The `git-tools` command provides utilities for git workflows:
   
   ```bash
   git-tools help
   ```
   
   Commands:
   
   - `new-branch NAME` - Create a new feature branch from main/master
   - `publish` - Push current branch to origin
   - `update` - Update current branch with latest main/master
   - `sync` - Sync all branches with remote
   - `cleanup` - Remove merged branches
   - `changelog` - Generate changelog from commits
   - `undo` - Undo last commit (keeping changes)
   - `wip` - Commit work-in-progress changes
   - `unwip` - Undo WIP commit
   - `save NAME` - Save current changes to a stash
   - `apply [NAME]` - Apply a saved stash
   - `list-stashes` - List all saved stashes
   - `standup` - Show your commits from the last day
   - `stats` - Show commit statistics
   
   ### Project Setup
   
   The `project-setup` command provides utilities for project creation and management:
   
   ```bash
   project-setup help
   ```
   
   Commands:
   
   - `create NAME TYPE` - Create a new project
   - `list` - List available project types
   - `clone URL [DIR]` - Clone a repository
   - `scaffold DIR TYPE` - Scaffold a project structure
   - `template DIR NAME` - Apply a template to a project
   
   ## Configuration
   
   The toolkit configuration is stored in `~/dev-toolkit/config/settings.json`. You can edit this file directly, or use the `dev-toolkit config` command to update settings.
   
   ## Extending the Toolkit
   
   To add a new tool, create a script in the `bin` directory and make it executable. Then add a corresponding entry in the `dev-toolkit` script.
   
   ## Acknowledgements
   
   This developer toolkit was created with assistance from Anthropic's Claude AI assistant, which helped with:
   - Script structure and organization
   - Code implementation
   - Documentation writing
   
   Claude was used as a development aid while all final implementation decisions and code review were performed by Joshua Michael Hall.
   EOF
   ```

8. **Test your toolkit**:
   ```bash
   # Source your .zshrc to make the bin directory available
   source ~/.zshrc
   
   # Test main toolkit
   dev-toolkit help
   
   # Test git tools
   git-tools help
   
   # Test project setup
   project-setup help
   ```
       

## Advanced CLI Tools Exercise

Create a comprehensive workflow utilizing modern command-line tools for file management, search, and system monitoring.

### Tasks:

1. **Install modern CLI tools**:
   ```bash
   # Install the core tools
   sudo pacman -S fzf ripgrep bat exa fd duf ncdu btop jq httpie tldr ranger neofetch
   ```

2. **Create a file search and preview script**:
   ```bash
   cat > ~/scripts/utils/file-finder.sh << 'EOF'
   #!/bin/bash
   # Advanced file finder with preview
   
   function show_help() {
     echo "Advanced File Finder"
     echo "Usage: $0 [options] [search_pattern]"
     echo ""
     echo "Options:"
     echo "  -t, --type TYPE   Filter by type (f:file, d:directory)"
     echo "  -e, --ext EXT     Filter by extension"
     echo "  -s, --size SIZE   Filter by size (e.g., +1M, -10k)"
     echo "  -m, --modified N  Filter by modification time (days)"
     echo "  -p, --path DIR    Search in specific directory (default: current)"
     echo "  -c, --content STR Search file contents for pattern"
     echo "  -h, --help        Show this help message"
   }
   
   # Default values
   TYPE=""
   EXT=""
   SIZE=""
   DAYS=""
   PATH="."
   CONTENT=""
   
   # Parse arguments
   while [[ $# -gt 0 ]]; do
     case "$1" in
       -t|--type)
         TYPE="$2"
         shift 2
         ;;
       -e|--ext)
         EXT="$2"
         shift 2
         ;;
       -s|--size)
         SIZE="$2"
         shift 2
         ;;
       -m|--modified)
         DAYS="$2"
         shift 2
         ;;
       -p|--path)
         PATH="$2"
         shift 2
         ;;
       -c|--content)
         CONTENT="$2"
         shift 2
         ;;
       -h|--help)
         show_help
         exit 0
         ;;
       *)
         PATTERN="$1"
         shift
         ;;
     esac
   done
   
   # Build fd command
   FD_CMD="fd"
   
   if [ -n "$TYPE" ]; then
     if [ "$TYPE" = "f" ]; then
       FD_CMD="$FD_CMD --type f"
     elif [ "$TYPE" = "d" ]; then
       FD_CMD="$FD_CMD --type d"
     fi
   fi
   
   if [ -n "$EXT" ]; then
     FD_CMD="$FD_CMD -e $EXT"
   fi
   
   if [ -n "$SIZE" ]; then
     FD_CMD="$FD_CMD --size $SIZE"
   fi
   
   if [ -n "$DAYS" ]; then
     FD_CMD="$FD_CMD --changed-within ${DAYS}d"
   fi
   
   if [ -n "$PATTERN" ]; then
     FD_CMD="$FD_CMD \"$PATTERN\""
   fi
   
   # Search for content if specified
   if [ -n "$CONTENT" ]; then
     if [ -z "$TYPE" ] || [ "$TYPE" = "f" ]; then
       if [ -n "$EXT" ]; then
         PREVIEW_CMD="rg -p --color=always \"$CONTENT\" {} || bat --color=always --line-range :50 {}"
         eval "$FD_CMD $PATH" | xargs -I{} bash -c "rg --files-with-matches \"$CONTENT\" \"{}\" 2>/dev/null" | fzf --preview "$PREVIEW_CMD"
       else
         PREVIEW_CMD="rg -p --color=always \"$CONTENT\" {} || bat --color=always --line-range :50 {}"
         rg --files-with-matches --hidden --glob "!.git/" "$CONTENT" "$PATH" | fzf --preview "$PREVIEW_CMD"
       fi
     else
       echo "Content search only works with files, not directories"
       exit 1
     fi
   else
     # Just search for files matching pattern and other criteria
     PREVIEW_CMD="if [ -d {} ]; then ls -la {}; else bat --color=always --line-range :50 {}; fi"
     eval "$FD_CMD $PATH" | fzf --preview "$PREVIEW_CMD"
   fi
   EOF
   
   # Make the script executable
   chmod +x ~/scripts/utils/file-finder.sh
   ```

3. **Create a system information dashboard script**:
   ```bash
   cat > ~/scripts/utils/system-dashboard.sh << 'EOF'
   #!/bin/bash
   # System information dashboard
   
   # Function to display system information
   function show_system_info() {
     clear
     echo "========================================"
     echo "         SYSTEM INFORMATION             "
     echo "========================================"
     echo ""
     
     # Hostname and kernel
     echo "HOST: $(hostname)"
     echo "KERNEL: $(uname -r)"
     echo "UPTIME: $(uptime -p)"
     echo ""
     
     # CPU information
     echo "======= CPU INFORMATION ======="
     echo "MODEL: $(grep "model name" /proc/cpuinfo | head -n1 | cut -d: -f2 | xargs)"
     echo "CORES: $(grep -c "processor" /proc/cpuinfo)"
     echo "USAGE:"
     top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4 "%"}'
     echo ""
     
     # Memory information
     echo "======= MEMORY INFORMATION ======="
     free -h | grep -v "Swap"
     echo ""
     
     # Disk information
     echo "======= DISK INFORMATION ======="
     df -h | grep -v "tmpfs" | grep -v "devtmpfs"
     echo ""
     
     # Network information
     echo "======= NETWORK INFORMATION ======="
     ip -o addr show | grep -v "lo" | awk '{print $2, $4}'
     echo ""
     
     # Running processes
     echo "======= TOP PROCESSES (CPU) ======="
     ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6
     echo ""
     
     # Memory hogs
     echo "======= TOP PROCESSES (MEMORY) ======="
     ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6
     echo ""
     
     echo "Press 'q' to quit, any other key to refresh..."
   }
   
   # Main loop
   while true; do
     show_system_info
     
     # Wait for a key press
     read -n 1 -t 5 key
     
     # Exit if 'q' is pressed
     if [[ "$key" == "q" ]]; then
       clear
       exit 0
     fi
   done
   EOF
   
   # Make the script executable
   chmod +x ~/scripts/utils/system-dashboard.sh
   ```

4. **Create a log analysis script**:
   ```bash
   cat > ~/scripts/utils/log-analyzer.sh << 'EOF'
   #!/bin/bash
   # Log file analyzer
   
   function show_help() {
     echo "Log File Analyzer"
     echo "Usage: $0 [options] log_file"
     echo ""
     echo "Options:"
     echo "  -e, --errors     Show only errors"
     echo "  -w, --warnings   Show only warnings"
     echo "  -i, --info       Show only info messages"
     echo "  -t, --tail N     Show last N lines (default: all)"
     echo "  -f, --follow     Follow log updates"
     echo "  -p, --pattern P  Filter by pattern"
     echo "  -c, --count      Show counts by message type"
     echo "  -h, --help       Show this help message"
   }
   
   # Default values
   ERRORS=0
   WARNINGS=0
   INFO=0
   TAIL=""
   FOLLOW=0
   PATTERN=""
   COUNT=0
   LOG_FILE=""
   
   # Parse arguments
   while [[ $# -gt 0 ]]; do
     case "$1" in
       -e|--errors)
         ERRORS=1
         shift
         ;;
       -w|--warnings)
         WARNINGS=1
         shift
         ;;
       -i|--info)
         INFO=1
         shift
         ;;
       -t|--tail)
         TAIL="$2"
         shift 2
         ;;
       -f|--follow)
         FOLLOW=1
         shift
         ;;
       -p|--pattern)
         PATTERN="$2"
         shift 2
         ;;
       -c|--count)
         COUNT=1
         shift
         ;;
       -h|--help)
         show_help
         exit 0
         ;;
       *)
         LOG_FILE="$1"
         shift
         ;;
     esac
   done
   
   # Check if log file exists
   if [ -z "$LOG_FILE" ] || [ ! -f "$LOG_FILE" ]; then
     echo "Error: Valid log file required"
     show_help
     exit 1
   fi
   
   # Build grep command
   GREP_CMD="cat"
   
   # If filtering by message type
   if [ $ERRORS -eq 1 ] || [ $WARNINGS -eq 1 ] || [ $INFO -eq 1 ]; then
     GREP_PATTERN=""
     
     if [ $ERRORS -eq 1 ]; then
       GREP_PATTERN="error|exception|fail|critical"
     fi
     
     if [ $WARNINGS -eq 1 ]; then
       if [ -n "$GREP_PATTERN" ]; then
         GREP_PATTERN="$GREP_PATTERN|warn"
       else
         GREP_PATTERN="warn"
       fi
     fi
     
     if [ $INFO -eq 1 ]; then
       if [ -n "$GREP_PATTERN" ]; then
         GREP_PATTERN="$GREP_PATTERN|info"
       else
         GREP_PATTERN="info"
       fi
     fi
     
     GREP_CMD="grep -i -E \"$GREP_PATTERN\""
   fi
   
   # Add pattern filter if specified
   if [ -n "$PATTERN" ]; then
     GREP_CMD="$GREP_CMD | grep -i \"$PATTERN\""
   fi
   
   # If counting by message type
   if [ $COUNT -eq 1 ]; then
     echo "Message counts from $LOG_FILE:"
     echo "------------------------------"
     echo "Errors: $(grep -i -E "error|exception|fail|critical" "$LOG_FILE" | wc -l)"
     echo "Warnings: $(grep -i -w "warn" "$LOG_FILE" | wc -l)"
     echo "Info: $(grep -i -w "info" "$LOG_FILE" | wc -l)"
     echo "------------------------------"
     echo "Total lines: $(wc -l < "$LOG_FILE")"
     exit 0
   fi
   
   # Apply tail if specified
   if [ -n "$TAIL" ]; then
     GREP_CMD="$GREP_CMD | tail -n $TAIL"
   fi
   
   # Apply follow if specified
   if [ $FOLLOW -eq 1 ]; then
     GREP_CMD="$GREP_CMD | tail -f"
   fi
   
   # Run the command
   eval "$GREP_CMD \"$LOG_FILE\" | bat --paging=never -l log"
   EOF
   
   # Make the script executable
   chmod +x ~/scripts/utils/log-analyzer.sh
   ```

5. **Create a workspace switcher script**:
   ```bash
   cat > ~/scripts/utils/workspace.sh << 'EOF'
   #!/bin/bash
   # Workspace switcher with project management
   
   WORKSPACE_DIR="$HOME/projects"
   WORKSPACE_FILE="$HOME/.workspace_projects.txt"
   
   function show_help() {
     echo "Workspace Project Manager"
     echo "Usage: $0 [command]"
     echo ""
     echo "Commands:"
     echo "  ls, list           List all projects"
     echo "  cd, goto PROJECT   Change to project directory"
     echo "  new PROJECT        Create a new project"
     echo "  add PATH           Add existing directory as a project"
     echo "  remove PROJECT     Remove a project from tracking"
     echo "  info PROJECT       Show project information"
     echo "  find               Fuzzy find and navigate to a project"
     echo "  status             Show git status of all projects"
     echo "  updates            Check for projects needing updates"
     echo "  help               Show this help message"
   }
   
   function list_projects() {
     echo "Workspace Projects:"
     echo "------------------"
     
     if [ ! -f "$WORKSPACE_FILE" ]; then
       echo "No projects found. Add some with 'workspace add' or 'workspace new'"
       return
     fi
     
     while IFS=: read -r name path; do
       if [ -d "$path" ]; then
         echo "$(basename "$path") ($path)"
       fi
     done < "$WORKSPACE_FILE"
   }
   
   function goto_project() {
     if [ -z "$1" ]; then
       echo "Error: Project name required"
       return 1
     fi
     
     if [ ! -f "$WORKSPACE_FILE" ]; then
       echo "No projects found. Add some with 'workspace add' or 'workspace new'"
       return 1
     fi
     
     local target_path=""
     while IFS=: read -r name path; do
       if [ "$(basename "$path")" = "$1" ] || [ "$name" = "$1" ]; then
         target_path="$path"
         break
       fi
     done < "$WORKSPACE_FILE"
     
     if [ -n "$target_path" ] && [ -d "$target_path" ]; then
       cd "$target_path" || return 1
       echo "Changed to $target_path"
       
       # Show git status if it's a git repository
       if [ -d ".git" ]; then
         echo ""
         echo "Git status:"
         git status -s
       fi
     else
       echo "Project '$1' not found"
       return 1
     fi
   }
   
   function new_project() {
     if [ -z "$1" ]; then
       echo "Error: Project name required"
       return 1
     fi
     
     local project_path="$WORKSPACE_DIR/$1"
     
     if [ -d "$project_path" ]; then
       echo "Error: Project directory already exists: $project_path"
       return 1
     fi
     
     # Create project directory
     mkdir -p "$project_path"
     
     # Initialize git repository
     cd "$project_path" || return 1
     git init
     
     # Create README.md
     echo "# $1" > README.md
     echo "" >> README.md
     echo "Project created on $(date)" >> README.md
     
     # Add to workspace file
     echo "$1:$project_path" >> "$WORKSPACE_FILE"
     
     echo "Created new project: $1 at $project_path"
     echo "Initialized git repository"
   }
   
   function add_project() {
     if [ -z "$1" ]; then
       echo "Error: Project path required"
       return 1
     fi
     
     local path=$(realpath "$1")
     
     if [ ! -d "$path" ]; then
       echo "Error: Directory does not exist: $path"
       return 1
     fi
     
     local name=$(basename "$path")
     
     # Check if already in workspace file
     if [ -f "$WORKSPACE_FILE" ]; then
       while IFS=: read -r existing_name existing_path; do
         if [ "$existing_path" = "$path" ]; then
           echo "Project already exists in workspace"
           return 1
         fi
       done < "$WORKSPACE_FILE"
     fi
     
     # Add to workspace file
     echo "$name:$path" >> "$WORKSPACE_FILE"
     
     echo "Added project: $name at $path"
   }
   
   function remove_project() {
     if [ -z "$1" ]; then
       echo "Error: Project name required"
       return 1
     fi
     
     if [ ! -f "$WORKSPACE_FILE" ]; then
       echo "No projects found"
       return 1
     fi
     
     local temp_file=$(mktemp)
     local found=0
     
     while IFS=: read -r name path; do
       if [ "$(basename "$path")" = "$1" ] || [ "$name" = "$1" ]; then
         found=1
       else
         echo "$name:$path" >> "$temp_file"
       fi
     done < "$WORKSPACE_FILE"
     
     if [ $found -eq 1 ]; then
       mv "$temp_file" "$WORKSPACE_FILE"
       echo "Removed project: $1"
     else
       rm "$temp_file"
       echo "Project '$1' not found"
       return 1
     fi
   }
   
   function show_project_info() {
     if [ -z "$1" ]; then
       echo "Error: Project name required"
       return 1
     fi
     
     if [ ! -f "$WORKSPACE_FILE" ]; then
       echo "No projects found"
       return 1
     fi
     
     local target_path=""
     while IFS=: read -r name path; do
       if [ "$(basename "$path")" = "$1" ] || [ "$name" = "$1" ]; then
         target_path="$path"
         break
       fi
     done < "$WORKSPACE_FILE"
     
     if [ -n "$target_path" ] && [ -d "$target_path" ]; then
       echo "Project: $(basename "$target_path")"
       echo "Path: $target_path"
       echo "Size: $(du -sh "$target_path" | cut -f1)"
       echo "Last modified: $(stat -c "%y" "$target_path")"
       
       if [ -d "$target_path/.git" ]; then
         echo ""
         echo "Git information:"
         echo "Branch: $(cd "$target_path" && git branch --show-current)"
         echo "Last commit: $(cd "$target_path" && git log -1 --pretty=format:"%h - %s (%ar)")"
         echo "Status:"
         cd "$target_path" && git status -s
       fi
     else
       echo "Project '$1' not found"
       return 1
     fi
   }
   
   function find_project() {
     if [ ! -f "$WORKSPACE_FILE" ]; then
       echo "No projects found. Add some with 'workspace add' or 'workspace new'"
       return 1
     fi
     
     # Create a temporary file with project listings
     local temp_file=$(mktemp)
     while IFS=: read -r name path; do
       if [ -d "$path" ]; then
         echo "$(basename "$path") - $path" >> "$temp_file"
       fi
     done < "$WORKSPACE_FILE"
     
     # Use fzf to select a project
     local selected=$(cat "$temp_file" | fzf --height 40% --reverse)
     rm "$temp_file"
     
     if [ -n "$selected" ]; then
       local selected_path=$(echo "$selected" | awk -F' - ' '{print $2}')
       cd "$selected_path" || return 1
       echo "Changed to $selected_path"
       
       # Show git status if it's a git repository
       if [ -d ".git" ]; then
         echo ""
         echo "Git status:"
         git status -s
       fi
     fi
   }
   
   function show_all_status() {
     if [ ! -f "$WORKSPACE_FILE" ]; then
       echo "No projects found"
       return 1
     fi
     
     echo "Git Status for All Projects:"
     echo "---------------------------"
     
     while IFS=: read -r name path; do
       if [ -d "$path/.git" ]; then
         echo "$(basename "$path"):"
         (cd "$path" && git status -s)
         echo ""
       fi
     done < "$WORKSPACE_FILE"
   }
   
   function check_updates() {
     if [ ! -f "$WORKSPACE_FILE" ]; then
       echo "No projects found"
       return 1
     fi
     
     echo "Checking for Updates:"
     echo "--------------------"
     
     while IFS=: read -r name path; do
       if [ -d "$path/.git" ]; then
         echo -n "$(basename "$path"): "
         
         # Check if branch is ahead/behind remote
         cd "$path" || continue
         
         git remote update > /dev/null 2>&1
         
         LOCAL=$(git rev-parse @)
         REMOTE=$(git rev-parse @{u} 2>/dev/null)
         BASE=$(git merge-base @ @{u} 2>/dev/null)
         
         if [ -z "$REMOTE" ]; then
           echo "No remote tracking branch"
         elif [ "$LOCAL" = "$REMOTE" ]; then
           echo "Up to date"
         elif [ "$LOCAL" = "$BASE" ]; then
           echo "Need to pull (behind by $(git rev-list --count HEAD..@{u}) commits)"
         elif [ "$REMOTE" = "$BASE" ]; then
           echo "Need to push (ahead by $(git rev-list --count @{u}..HEAD) commits)"
         else
           echo "Diverged"
         fi
       fi
     done < "$WORKSPACE_FILE"
   }
   
   # Create workspace directory if it doesn't exist
   mkdir -p "$WORKSPACE_DIR"
   
   # Main command parsing
   if [ $# -eq 0 ]; then
     show_help
     exit 0
   fi
   
   case "$1" in
     ls|list)
       list_projects
       ;;
     cd|goto)
       goto_project "$2"
       ;;
     new)
       new_project "$2"
       ;;
     add)
       add_project "$2"
       ;;
     remove)
       remove_project "$2"
       ;;
     info)
       show_project_info "$2"
       ;;
     find)
       find_project
       ;;
     status)
       show_all_status
       ;;
     updates)
       check_updates
       ;;
     help|*)
       show_help
       ;;
   esac
   EOF
   
   # Make the script executable
   chmod +x ~/scripts/utils/workspace.sh
   
   # Add alias to .zshrc
   echo 'alias ws="~/scripts/utils/workspace.sh"' >> ~/.zshrc
   ```

6. **Set up aliases for all the tools in .zshrc**:
   ```bash
   cat >> ~/.zshrc << 'EOF'
   
   # Advanced CLI tools aliases
   alias ff="~/scripts/utils/file-finder.sh"
   alias sysinfo="~/scripts/utils/system-dashboard.sh"
   alias logs="~/scripts/utils/log-analyzer.sh"
   alias ws="~/scripts/utils/workspace.sh"
   alias cat="bat --paging=never"
   alias ls="exa"
   alias la="exa -la --git"
   alias ll="exa -l --git"
   alias lt="exa -T --git-ignore"
   alias grep="rg"
   alias find="fd"
   alias top="btop"
   alias df="duf"
   alias du="ncdu"
   alias help="tldr"
   alias http="httpie"
   EOF
   ```

7. **Create a document explaining your CLI toolkit**:
   ```bash
   mkdir -p ~/dotfiles/cli-tools
   
   cat > ~/dotfiles/cli-tools/README.md << 'EOF'
   # Modern CLI Tools Toolkit
   
   This document outlines the modern command-line tools I use to improve productivity and efficiency.
   
   ## Core Tools
   
   | Traditional | Modern Replacement | Purpose |
   |-------------|-------------------|---------|
   | `cat` | `bat` | View files with syntax highlighting |
   | `ls` | `exa` | List files with improved output |
   | `grep` | `ripgrep` | Search for patterns with better performance |
   | `find` | `fd` | Find files and directories more intuitively |
   | `top` | `btop` | Monitor system resources with a better UI |
   | `du` | `ncdu` | Analyze disk usage interactively |
   | `df` | `duf` | Display disk usage with better formatting |
   | `man` | `tldr` | Simplified command documentation |
   | `curl` | `httpie` | More user-friendly HTTP client |
   
   ## Custom Scripts
   
   | Script | Description | Usage |
   |--------|-------------|-------|
   | `file-finder.sh` | Advanced file search tool | `ff [options] [pattern]` |
   | `system-dashboard.sh` | Interactive system monitor | `sysinfo` |
   | `log-analyzer.sh` | Log file analysis tool | `logs [options] log_file` |
   | `workspace.sh` | Project management tool | `ws [command]` |
   
   ## Aliases
   
   These aliases are configured in `.zshrc`:
   
   ```bash
   alias ff="~/scripts/utils/file-finder.sh"
   alias sysinfo="~/scripts/utils/system-dashboard.sh"
   alias logs="~/scripts/utils/log-analyzer.sh"
   alias ws="~/scripts/utils/workspace.sh"
   alias cat="bat --paging=never"
   alias ls="exa"
   alias la="exa -la --git"
   alias ll="exa -l --git"
   alias lt="exa -T --git-ignore"
   alias grep="rg"
   alias find="fd"
   alias top="btop"
   alias df="duf"
   alias du="ncdu"
   alias help="tldr"
   alias http="httpie"
   ```
   
   ## File Finder Usage Examples
   
   Find all Python files modified in the last 7 days:
   ```
   ff -t f -e py -m 7
   ```
   
   Search for files containing a specific pattern:
   ```
   ff -c "TODO" -e py
   ```
   
   Find large files (>100MB):
   ```
   ff -s +100M
   ```
   
   ## Log Analyzer Usage Examples
   
   Show only errors from a log file:
   ```
   logs -e /var/log/application.log
   ```
   
   Follow a log file in real-time, showing only certain patterns:
   ```
   logs -f -p "authentication" /var/log/auth.log
   ```
   
   Get a count of message types in a log file:
   ```
   logs -c /var/log/application.log
   ```
   
   ## Workspace Manager Usage Examples
   
   Create a new project:
   ```
   ws new my-project
   ```
   
   Navigate to an existing project:
   ```
   ws goto my-project
   ```
   
   Find a project with fuzzy search:
   ```
   ws find
   ```
   
   Show git status for all projects:
   ```
   ws status
   ```
   
   ## Installation
   
   Most tools can be installed via pacman:
   
   ```bash
   sudo pacman -S fzf ripgrep bat exa fd duf ncdu btop jq httpie tldr ranger neofetch
   ```
   
   For the custom scripts:
   
   1. Copy scripts to `~/scripts/utils/` directory
   2. Make them executable: `chmod +x ~/scripts/utils/*.sh`
   3. Add aliases to `.zshrc` as shown above
   EOF
   ```

2. **Install Tmux Plugin Manager (TPM)**:
   ```bash
   # Create plugins directory
   mkdir -p ~/.tmux/plugins
   
   # Clone TPM
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
   
   # Add TPM configuration to ~/.tmux.conf
   cat >> ~/.tmux.conf << 'EOF'
   
   # List of plugins
   set -g @plugin 'tmux-plugins/tpm'
   set -g @plugin 'tmux-plugins/tmux-sensible'
   set -g @plugin 'tmux-plugins/tmux-resurrect'
   set -g @plugin 'tmux-plugins/tmux-continuum'
   set -g @plugin 'tmux-plugins/tmux-yank'
   
   # Plugin settings
   set -g @resurrect-capture-pane-contents 'on'
   set -g @continuum-restore 'on'
   set -g @continuum-save-interval '10'
   
   # Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
   run '~/.tmux/plugins/tpm/tpm'
   EOF
   ```

3. **Create custom Tmux layouts for different development scenarios**:
   ```bash
   # Create scripts directory
   mkdir -p ~/scripts/tmux
   
   # Create a web development layout script
   cat > ~/scripts/tmux/web-dev.sh << 'EOF'
   #!/bin/bash
   # Web development Tmux setup
   
   SESSION="web-dev"
   WORK_DIR="$HOME/projects/web"
   
   # Check if the session already exists
   tmux has-session -t $SESSION 2>/dev/null
   
   if [ $? != 0 ]; then
     # Create the session
     tmux new-session -s $SESSION -d -c "$WORK_DIR"
     
     # Editor window
     tmux rename-window -t $SESSION:1 "editor"
     tmux send-keys -t $SESSION:1 "cd $WORK_DIR" C-m
     tmux send-keys -t $SESSION:1 "nvim ." C-m
     
     # Server window with split panes
     tmux new-window -t $SESSION -c "$WORK_DIR" -n "server"
     tmux split-window -h -t $SESSION:2 -c "$WORK_DIR"
     tmux select-pane -t $SESSION:2.1
     tmux send-keys -t $SESSION:2.1 "echo 'Starting development server...'" C-m
     tmux send-keys -t $SESSION:2.1 "npm run dev" C-m
     tmux select-pane -t $SESSION:2.2
     tmux send-keys -t $SESSION:2.2 "echo 'Monitoring build process...'" C-m
     tmux send-keys -t $SESSION:2.2 "npm run watch" C-m
     
     # Git & terminal window
     tmux new-window -t $SESSION -c "$WORK_DIR" -n "git"
     tmux send-keys -t $SESSION:3 "git status" C-m
     
     # Database window
     tmux new-window -t $SESSION -c "$WORK_DIR" -n "db"
     tmux send-keys -t $SESSION:4 "echo 'Starting database client...'" C-m
     
     # Select the first window
     tmux select-window -t $SESSION:1
   fi
   
   # Attach to the session
   tmux attach-session -t $SESSION
   EOF
   
   # Create a Python development layout script
   cat > ~/scripts/tmux/python-dev.sh << 'EOF'
   #!/bin/bash
   # Python development Tmux setup
   
   SESSION="python-dev"
   WORK_DIR="$HOME/projects/python"
   
   # Check if the session already exists
   tmux has-session -t $SESSION 2>/dev/null
   
   if [ $? != 0 ]; then
     # Create the session
     tmux new-session -s $SESSION -d -c "$WORK_DIR"
     
     # Editor window
     tmux rename-window -t $SESSION:1 "editor"
     tmux send-keys -t $SESSION:1 "cd $WORK_DIR" C-m
     tmux send-keys -t $SESSION:1 "nvim ." C-m
     
     # REPL window with split pane
     tmux new-window -t $SESSION -c "$WORK_DIR" -n "repl"
     tmux split-window -h -t $SESSION:2 -c "$WORK_DIR"
     tmux select-pane -t $SESSION:2.1
     tmux send-keys -t $SESSION:2.1 "python" C-m
     tmux select-pane -t $SESSION:2.2
     tmux send-keys -t $SESSION:2.2 "echo 'Running tests...'" C-m
     tmux send-keys -t $SESSION:2.2 "pytest -xvs" C-m
     
     # Git & terminal window
     tmux new-window -t $SESSION -c "$WORK_DIR" -n "git"
     tmux send-keys -t $SESSION:3 "git status" C-m
     
     # Docs window
     tmux new-window -t $SESSION -c "$WORK_DIR" -n "docs"
     tmux send-keys -t $SESSION:4 "cd docs" C-m
     
     # Select the first window
     tmux select-window -t $SESSION:1
   fi
   
   # Attach to the session
   tmux attach-session -t $SESSION
   EOF
   
   # Make scripts executable
   chmod +x ~/scripts/tmux/web-dev.sh
   chmod +x ~/scripts/tmux/python-dev.sh
   ```

4. **Set up Tmuxinator for more complex project management**:
   ```bash
   # Install Ruby and Tmuxinator
   sudo pacman -S ruby
   gem install --user-install tmuxinator
   
   # Add gem bin to PATH in .zshrc
   echo 'export PATH="$HOME/.gem/ruby/3.0.0/bin:$PATH"' >> ~/.zshrc
   
   # Create a Tmuxinator project for a full-stack development
   mkdir -p ~/.config/tmuxinator
   
   cat > ~/.config/tmuxinator/fullstack.yml << 'EOF'
   # ~/.config/tmuxinator/fullstack.yml
   
   name: fullstack
   root: ~/projects/fullstack
   
   # Optional tmux socket
   # socket_name: foo
   
   # Runs before everything. Use it to start daemons etc.
   # pre: sudo /etc/rc.d/mysqld start
   
   # Project hooks
   # Runs on project start, always
   on_project_start: echo "Starting fullstack development environment"
   # Run on project start, the first time
   # on_project_first_start: command
   # Run on project start, after the first time
   # on_project_restart: command
   # Run on project exit ( detaching from tmux session )
   on_project_exit: echo "Shutting down fullstack development environment"
   # Run on project stop
   # on_project_stop: command
   
   # Runs in each window and pane before window/pane specific commands. Useful for setting up interpreter versions.
   # pre_window: rbenv shell 2.0.0-p247
   
   # Pass command line options to tmux. Useful for specifying a different tmux.conf.
   # tmux_options: -f ~/.tmux.mac.conf
   
   # Change the command to call tmux.  This can be used by derivatives/wrappers like byobu.
   # tmux_command: byobu
   
   # Specifies (by name or index) which window will be selected on project startup. If not set, the first window is used.
   startup_window: editor
   
   # Specifies (by index) which pane of the specified window will be selected on project startup. If not set, the first pane is used.
   # startup_pane: 1
   
   # Controls whether the tmux session should be attached to automatically. Defaults to true.
   # attach: false
   
   # Runs after everything. Use it to attach to tmux with custom options etc.
   # post: tmux -CC attach -t fullstack
   
   windows:
     - editor:
         layout: main-vertical
         # Synchronize all panes of this window, can be enabled before or after the pane commands run.
         # synchronize: after
         panes:
           - nvim .
           - echo "Terminal ready"
     - server:
         layout: even-horizontal
         panes:
           - cd backend && echo "Starting backend server..." && npm start
           - cd frontend && echo "Starting frontend server..." && npm start
     - database:
         panes:
           - echo "Starting database client..."
     - git:
         layout: main-horizontal
         panes:
           - git status
           - echo "Git log:" && git log --oneline -n 5
     - logs:
         panes:
           - tail -f logs/app.log
     - tests:
         layout: even-horizontal
         panes:
           - cd backend && echo "Running backend tests..." && npm test
           - cd frontend && echo "Running frontend tests..." && npm test
   EOF
   ```

5. **Create a simple script to manage multiple Tmux sessions**:
   ```bash
   cat > ~/scripts/tmux/tmux-manager.sh << 'EOF'
   #!/bin/bash
   # Tmux Session Manager
   
   function show_help() {
     echo "Tmux Session Manager"
     echo "Usage: $0 [command]"
     echo ""
     echo "Commands:"
     echo "  list        List all sessions"
     echo "  new NAME    Create a new session"
     echo "  attach NAME Attach to a session"
     echo "  kill NAME   Kill a session"
     echo "  web         Start web development layout"
     echo "  python      Start Python development layout"
     echo "  fs          Start fullstack development layout with tmuxinator"
     echo "  help        Show this help message"
   }
   
   function list_sessions() {
     echo "Current Tmux sessions:"
     tmux list-sessions 2>/dev/null || echo "No active sessions"
   }
   
   function new_session() {
     if [ -z "$1" ]; then
       echo "Error: Session name required"
       return 1
     fi
     
     tmux new-session -d -s "$1"
     echo "Created session: $1"
     tmux attach-session -t "$1"
   }
   
   function attach_session() {
     if [ -z "$1" ]; then
       echo "Error: Session name required"
       return 1
     fi
     
     if tmux has-session -t "$1" 2>/dev/null; then
       tmux attach-session -t "$1"
     else
       echo "Error: Session '$1' does not exist"
       list_sessions
       return 1
     fi
   }
   
   function kill_session() {
     if [ -z "$1" ]; then
       echo "Error: Session name required"
       return 1
     fi
     
     if tmux has-session -t "$1" 2>/dev/null; then
       tmux kill-session -t "$1"
       echo "Killed session: $1"
     else
       echo "Error: Session '$1' does not exist"
       list_sessions
       return 1
     fi
   }
   
   # Main script logic
   if [ $# -eq 0 ]; then
     show_help
     exit 0
   fi
   
   case "$1" in
     list)
       list_sessions
       ;;
     new)
       new_session "$2"
       ;;
     attach)
       attach_session "$2"
       ;;
     kill)
       kill_session "$2"
       ;;
     web)
       ~/scripts/tmux/web-dev.sh
       ;;
     python)
       ~/scripts/tmux/python-dev.sh
       ;;
     fs)
       tmuxinator start fullstack
       ;;
     help|*)
       show_help
       ;;
   esac
   EOF
   
   # Make the script executable
   chmod +x ~/scripts/tmux/tmux-manager.sh
   
   # Add an alias to .zshrc
   echo 'alias tm="~/scripts/tmux/tmux-manager.sh"' >> ~/.zshrc
   ```

6. **Document your Tmux configuration**:
   ```bash
   mkdir -p ~/dotfiles/tmux
   
   cat > ~/dotfiles/tmux/README.md << 'EOF'
   # Tmux Configuration
   
   This directory contains my Tmux configuration files and session management scripts.
   
   ## Files
   
   - `.tmux.conf`: Main configuration file
   - `scripts/tmux/web-dev.sh`: Web development layout script
   - `scripts/tmux/python-dev.sh`: Python development layout script
   - `scripts/tmux/tmux-manager.sh`: Session management script
   - `.config/tmuxinator/fullstack.yml`: Tmuxinator project configuration
   
   ## Key Features
   
   - Custom key bindings with Ctrl-a prefix
   - Mouse support for pane resizing and selection
   - Vim-like navigation and copy mode
   - Session persistence with tmux-resurrect and tmux-continuum
   - Status bar customization with useful information
   - Project-specific layouts for different development tasks
   
   ## Key Bindings
   
   | Binding | Action |
   |---------|--------|
   | `Ctrl-a` | Prefix key |
   | `Prefix r` | Reload configuration |
   | `Prefix \|` | Split window horizontally |
   | `Prefix -` | Split window vertically |
   | `Alt+Arrow` | Navigate between panes |
   | `Prefix c` | Create new window |
   | `Prefix n` | Next window |
   | `Prefix p` | Previous window |
   | `Prefix d` | Detach from session |
   | `Prefix :` | Command mode |
   | `Prefix [` | Copy mode |
   | `v` | Begin selection (in copy mode) |
   | `y` | Copy selection (in copy mode) |
   
   ## Session Management Commands
   
   The `tm` alias provides easy access to Tmux session management:
   
   ```
   tm list        # List all sessions
   tm new NAME    # Create a new session
   tm attach NAME # Attach to a session
   tm kill NAME   # Kill a session
   tm web         # Start web development layout
   tm python      # Start Python development layout
   tm fs          # Start fullstack development layout
   ```
   
   ## Installation
   
   1. Install Tmux: `pacman -S tmux`
   2. Copy `.tmux.conf` to home directory
   3. Install Tmux Plugin Manager: `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`
   4. Install plugins: Press `Prefix` + `I` inside a Tmux session
   5. Copy scripts to `~/scripts/tmux/` directory
   6. Make scripts executable: `chmod +x ~/scripts/tmux/*.sh`
   7. Install Tmuxinator: `gem install --user-install tmuxinator`
   8. Copy Tmuxinator configurations to `~/.config/tmuxinator/`
   
   ## Dependencies
   
   - Tmux
   - Tmux Plugin Manager
   - Tmuxinator (requires Ruby)
   EOF
   ```

5. **Configure Powerlevel10k**:
   ```bash
   # Run the configuration wizard
   p10k configure
   ```

6. **Create additional Zsh files for organization**:
   ```bash
   # Create a directory for custom scripts
   mkdir -p ~/.zsh/functions
   
   # Create a file for custom functions
   cat > ~/.zsh/functions/custom.zsh << 'EOF'
   # Function to find files and open in editor
   fe() {
     local file
     file=$(fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}') && $EDITOR "$file"
   }
   
   # Function to find directories and cd into them
   fd() {
     local dir
     dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m) && cd "$dir"
   }
   
   # Function to search command history
   fh() {
     print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g')
   }
   
   # Function to kill processes
   fkill() {
     local pid
     pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
     
     if [ "x$pid" != "x" ]; then
       echo $pid | xargs kill -${1:-9}
     fi
   }
   EOF
   
   # Source the functions file in .zshrc
   echo '# Load custom functions' >> ~/.zshrc
   echo 'source ~/.zsh/functions/custom.zsh' >> ~/.zshrc
   ```

7. **Test your configuration**:
   ```bash
   # Source your new configuration
   source ~/.zshrc
   
   # Test some aliases and functions
   la
   mkcd test_directory
   weather
   ```

8. **Document your Zsh setup**:
   ```bash
   # Create a README for your Zsh configuration
   mkdir -p ~/dotfiles/zsh
   
   cat > ~/dotfiles/zsh/README.md << 'EOF'
   # Zsh Configuration
   
   This directory contains my Zsh shell configuration files.
   
   ## Files
   
   - `.zshrc`: Main configuration file
   - `.p10k.zsh`: Powerlevel10k theme configuration
   - `.zsh/functions/custom.zsh`: Custom functions
   
   ## Key Features
   
   - Powerlevel10k theme for informative, customizable prompt
   - Syntax highlighting and autosuggestions
   - Directory jumping with zsh-z
   - Command history management and searching
   - FZF integration for fuzzy finding
   - Custom functions for productivity
   
   ## Aliases
   
   | Alias | Command | Description |
   |-------|---------|-------------|
   | `update` | `sudo pacman -Syu` | Update system packages |
   | `ls` | `exa` | Modern alternative to ls |
   | `la` | `exa -la --git` | List all files with git status |
   | `lt` | `exa -T --git-ignore` | Show directory tree |
   | `cat` | `bat --paging=never` | Enhanced cat with syntax highlighting |
   | ... | ... | ... |
   
   ## Functions
   
   | Function | Description |
   |----------|-------------|
   | `mkcd` | Create directory and cd into it |
   | `extract` | Extract various archive formats |
   | `backup` | Create a quick backup of a file |
   | `weather` | Show weather for current or specified location |
   | `fe` | Fuzzy find files and open in editor |
   | `fh` | Fuzzy search command history |
   | ... | ... | ... |
   
   ## Installation
   
   1. Install Zsh: `pacman -S zsh`
   2. Install Oh My Zsh: `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
   3. Install required plugins (see plugin installation commands)
   4. Copy configuration files to home directory
   5. Source configuration: `source ~/.zshrc`
   
   ## Dependencies
   
   - Zsh
   - Oh My Zsh
   - Powerlevel10k
   - zsh-autosuggestions
   - zsh-syntax-highlighting
   - zsh-z
   - fzf
   - exa
   - bat
   - ripgrep
   - fd
   EOF
   ```

## Tmux Workflow Project

Create an efficient Tmux development environment with custom layouts and session management.

### Tasks:

1. **Create a basic Tmux configuration**:
   ```bash
   # Create .tmux.conf
   cat > ~/.tmux.conf << 'EOF'
   # Set prefix key to Ctrl-a
   unbind C-b
   set -g prefix C-a
   bind C-a send-prefix

   # Enable mouse support
   set -g mouse on

   # Start window numbering at 1
   set -g base-index 1
   setw -g pane-base-index 1

   # Reload configuration
   bind r source-file ~/.tmux.conf \; display "Config reloaded!"

   # Split panes using | and -
   bind | split-window -h -c "#{pane_current_path}"
   bind - split-window -v -c "#{pane_current_path}"
   unbind '"'
   unbind %

   # Switch panes using Alt-arrow without prefix
   bind -n M-Left select-pane -L
   bind -n M-Right select-pane -R
   bind -n M-Up select-pane -U
   bind -n M-Down select-pane -D

   # Use vim keybindings in copy mode
   setw -g mode-keys vi
   bind-key -T copy-mode-vi v send -X begin-selection
   bind-key -T copy-mode-vi y send -X copy-selection-and-cancel

   # Increase history limit
   set -g history-limit 10000

   # Set terminal color
   set -g default-terminal "tmux-256color"
   set -ga terminal-overrides ",*256col*:Tc"

   # Status bar configuration
   set -g status-position bottom
   set -g status-style fg=colour137,bg=colour234
   set -g status-left ' #[fg=colour255]#S '
   set -g status-right '#[fg=colour233,bg=colour241,bold] %d/%m #[fg=colour233,bg=colour245,bold] %H:%M:%S '
   set -g status-right-length 50
   set -g status-left-length 20

   setw -g window-status-current-style fg=colour81,bg=colour238,bold
   setw -g window-status-current-format ' #I#[fg=colour250]:#[fg=colour255]#W#[fg=colour50]#F '

   setw -g window-status-style fg=colour138,bg=colour235
   setw -g window-status-format ' #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F '

   # Enable focus events (for vim/neovim)
   set -g focus-events on

   # Reduce escape-time (for vim/neovim)
   set -sg escape-time 10
EOF
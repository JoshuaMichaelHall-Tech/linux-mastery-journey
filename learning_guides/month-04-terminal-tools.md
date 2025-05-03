# Month 4: Terminal Tools and Shell Customization

This month focuses on creating an efficient, powerful terminal environment by mastering Zsh, terminal multiplexing with Tmux, and essential command-line utilities. You'll transform your terminal into a productivity powerhouse for development work.

## Time Commitment: ~10 hours/week for 4 weeks

## Learning Objectives

By the end of this month, you should be able to:

1. Configure and customize the Z shell (Zsh) with frameworks like Oh My Zsh
2. Master terminal multiplexing with Tmux for efficient workflow
3. Use advanced text processing tools and utilities
4. Create powerful shell aliases, functions, and scripts
5. Set up a consistent, cross-machine terminal configuration
6. Implement efficient file navigation and management techniques

## Week 1: Z Shell (Zsh) Configuration

### Core Learning Activities

1. **Zsh Basics** (2 hours)
   - Understand shell startup files (.zshrc, .zprofile, etc.)
   - Learn Zsh-specific features vs. Bash
   - Configure basic Zsh settings
   - Practice using Zsh interactive features
   - Study shell data structures and variable types
   - Learn Zsh command substitution techniques

2. **Oh My Zsh Setup** (2 hours)
   - Install and configure Oh My Zsh framework
   - Explore available themes
   - Understand plugin system
   - Set up initial plugins (git, sudo, etc.)
   - Configure plugin loading strategies
   - Implement custom plugins

3. **Prompt Customization** (3 hours)
   - Understand prompt escapes and formatting
   - Configure a custom prompt or use Powerlevel10k
   - Add git status information
   - Optimize prompt performance
   - Implement context-aware prompts
   - Add custom prompt segments

4. **Zsh Advanced Features** (3 hours)
   - Master command history features
   - Set up directory auto-jumping
   - Configure tab completion
   - Use globbing and extended globbing
   - Implement spelling correction
   - Configure command prediction
   - Set up command line editing shortcuts

### Practical Exercises

#### Installing and Configuring Zsh

1. Install Zsh:

```bash
sudo pacman -S zsh
```

2. Set Zsh as your default shell:

```bash
chsh -s $(which zsh)
```

3. Create basic Zsh configuration files:

```bash
touch ~/.zshrc ~/.zprofile
```

4. Add basic Zsh settings to ~/.zshrc:

```bash
# Basic Zsh settings
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export TERM="xterm-256color"

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt histignorealldups
setopt histignorespace
setopt incappendhistory

# Basic Zsh options
setopt autocd
setopt extendedglob
setopt nomatch
setopt notify
unsetopt beep

# Basic key bindings
bindkey -e  # Emacs key bindings
bindkey '^[[7~' beginning-of-line
bindkey '^[[8~' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[5~' up-line-or-history
bindkey '^[[6~' down-line-or-history

# Basic completions
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
```

#### Installing and Configuring Oh My Zsh

1. Install Oh My Zsh:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

2. Backup and edit your .zshrc:

```bash
cp ~/.zshrc ~/.zshrc.backup
nano ~/.zshrc
```

3. Configure Oh My Zsh with essential plugins:

```bash
# Path to your Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set theme
ZSH_THEME="robbyrussell"

# Set plugins
plugins=(
  git
  sudo
  history
  colored-man-pages
  zsh-autosuggestions
  zsh-syntax-highlighting
  extract
  docker
  python
  npm
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# User configuration
export PATH="$HOME/bin:/usr/local/bin:$PATH"

# Custom aliases
alias zshconfig="nano ~/.zshrc"
alias ohmyzsh="nano ~/.oh-my-zsh"
alias ll="ls -alF"
alias la="ls -A"
alias l="ls -CF"
alias c="clear"
alias updatesys="sudo pacman -Syu"
```

4. Install additional plugins:

```bash
# Install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Install zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

5. Source your updated configuration:

```bash
source ~/.zshrc
```

#### Installing and Configuring Powerlevel10k

1. Install Powerlevel10k:

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

2. Install recommended fonts:

```bash
sudo pacman -S ttf-meslo-nerd-font-powerlevel10k
```

3. Update your theme in ~/.zshrc:

```bash
ZSH_THEME="powerlevel10k/powerlevel10k"
```

4. Configure Powerlevel10k by running:

```bash
p10k configure
```

5. Or manually create a p10k.zsh configuration:

```bash
nano ~/.p10k.zsh
```

Add this minimal configuration:

```bash
# Basic Powerlevel10k configuration
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  dir                     # Current directory
  vcs                     # Git status
  newline                 # \n
  prompt_char             # Prompt symbol
)

POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  status                  # Exit code of the last command
  command_execution_time  # Duration of the last command
  background_jobs         # Presence of background jobs
  time                    # Current time
)

# Set prompt style
POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION='❯'
POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_CONTENT_EXPANSION='❯'
POWERLEVEL9K_PROMPT_CHAR_OK_VICMD_CONTENT_EXPANSION='❮'
POWERLEVEL9K_PROMPT_CHAR_ERROR_VICMD_CONTENT_EXPANSION='❮'

# Set directory path shortening
POWERLEVEL9K_SHORTEN_DIR_LENGTH=3
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_from_right"

# Set status colors
POWERLEVEL9K_STATUS_OK=false
POWERLEVEL9K_STATUS_ERROR_BACKGROUND='red'
POWERLEVEL9K_STATUS_ERROR_FOREGROUND='white'

# Set command execution time format
POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=2
```

#### Implementing Advanced Zsh Features

1. Create a directory jumping configuration:

```bash
# Install the z plugin
git clone https://github.com/agkozak/zsh-z ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-z
```

2. Add it to your plugins in ~/.zshrc:

```bash
plugins=( ... zsh-z ... )
```

3. Create custom Zsh functions:

```bash
nano ~/.zsh_functions
```

Add useful functions:

```bash
# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
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

# Find files containing a pattern
fif() {
    if [ ! "$#" -gt 0 ]; then
        echo "Need a search pattern"
        return 1
    fi
    rg --files-with-matches --no-messages "$1" | fzf --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}"
}

# Create a quick backup of a file
backup() {
    cp "$1"{,.bak}
}
```

4. Source the functions in ~/.zshrc:

```bash
# Load custom functions
[ -f ~/.zsh_functions ] && source ~/.zsh_functions
```

### Resources

- [Zsh Documentation](https://zsh.sourceforge.io/Doc/)
- [Oh My Zsh Wiki](https://github.com/ohmyzsh/ohmyzsh/wiki)
- [Powerlevel10k Documentation](https://github.com/romkatv/powerlevel10k)
- [Zsh Guide on ArchWiki](https://wiki.archlinux.org/title/Zsh)
- [Shell Scripting with Zsh](https://linuxconfig.org/learn-the-basics-of-the-zsh-shell)
- [Zsh Startup Files](https://zsh.sourceforge.io/Intro/intro_3.html)
- [Zsh Completion System](https://zsh.sourceforge.io/Doc/Release/Completion-System.html)

## Week 2: Terminal Multiplexing with Tmux

### Core Learning Activities

1. **Tmux Basics** (2 hours)
   - Understand terminal multiplexing concepts
   - Learn about sessions, windows, and panes
   - Master basic navigation and commands
   - Configure the prefix key
   - Understand tmux architecture
   - Learn about client-server model

2. **Tmux Configuration** (3 hours)
   - Create and customize .tmux.conf
   - Set up status bar appearance
   - Configure key bindings
   - Enable mouse support (optional)
   - Set up copy mode with vim keybindings
   - Configure tmux plugins
   - Implement theme and appearance settings

3. **Advanced Tmux Usage** (3 hours)
   - Work with multiple sessions
   - Practice window and pane management
   - Use synchronized panes
   - Learn to search and copy text efficiently
   - Master session detaching and attaching
   - Implement complex layouts
   - Configure nested tmux sessions

4. **Session Management** (2 hours)
   - Create named sessions for different projects
   - Set up tmuxinator or tmux-resurrect
   - Implement session saving and restoration
   - Create startup scripts for predefined layouts
   - Develop project-specific tmux configurations
   - Automate tmux environment setup

### Practical Exercises

#### Installing and Configuring Tmux

1. Install Tmux:

```bash
sudo pacman -S tmux
```

2. Create a basic tmux configuration:

```bash
nano ~/.tmux.conf
```

Add basic configuration:

```bash
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
set -g status-left ''
set -g status-right '#[fg=colour233,bg=colour241,bold] %d/%m #[fg=colour233,bg=colour245,bold] %H:%M:%S '
set -g status-right-length 50
set -g status-left-length 20

setw -g window-status-current-style fg=colour81,bg=colour238,bold
setw -g window-status-current-format ' #I#[fg=colour250]:#[fg=colour255]#W#[fg=colour50]#F '

setw -g window-status-style fg=colour138,bg=colour235
setw -g window-status-format ' #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F '
```

3. Reload your configuration:

```bash
tmux source-file ~/.tmux.conf
```

Or if you're already in a tmux session:

```bash
Press Ctrl-a, then r
```

#### Installing Tmux Plugin Manager

1. Install Tmux Plugin Manager (TPM):

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

2. Add TPM configuration to ~/.tmux.conf:

```bash
# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-yank'

# Plugin settings
set -g @resurrect-capture-pane-contents 'on'
set -g @continuum-restore 'on'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run -b '~/.tmux/plugins/tpm/tpm'
```

3. Install the plugins by pressing:

```
Ctrl-a I
```

#### Creating Custom Tmux Layouts

1. Create a development layout script:

```bash
mkdir -p ~/scripts
nano ~/scripts/dev-tmux.sh
```

2. Add content:

```bash
#!/bin/bash
# Create a development tmux session

SESSION="development"
WINDOW="code"

# Check if session exists
tmux has-session -t $SESSION 2>/dev/null

if [ $? != 0 ]; then
    # Create session
    tmux new-session -s $SESSION -n $WINDOW -d
    
    # Set up main coding window
    tmux split-window -h -t $SESSION:$WINDOW
    tmux split-window -v -t $SESSION:$WINDOW.2
    
    # Configure panes
    tmux send-keys -t $SESSION:$WINDOW.1 'cd ~/projects' C-m
    tmux send-keys -t $SESSION:$WINDOW.1 'nvim' C-m
    tmux send-keys -t $SESSION:$WINDOW.2 'cd ~/projects' C-m
    tmux send-keys -t $SESSION:$WINDOW.3 'cd ~/projects' C-m
    tmux send-keys -t $SESSION:$WINDOW.3 'git status' C-m
    
    # Create additional windows
    tmux new-window -t $SESSION -n 'server'
    tmux send-keys -t $SESSION:server 'cd ~/projects' C-m
    
    tmux new-window -t $SESSION -n 'logs'
    tmux send-keys -t $SESSION:logs 'journalctl -f' C-m
    
    # Select first window
    tmux select-window -t $SESSION:$WINDOW
    tmux select-pane -t $SESSION:$WINDOW.1
fi

# Attach to session
tmux attach-session -t $SESSION
```

3. Make the script executable:

```bash
chmod +x ~/scripts/dev-tmux.sh
```

#### Setting Up Tmuxinator

1. Install Ruby and Tmuxinator:

```bash
sudo pacman -S ruby
gem install --user-install tmuxinator
```

2. Add the gem bin directory to your PATH in ~/.zshrc:

```bash
export PATH="$HOME/.gem/ruby/3.0.0/bin:$PATH"  # Adjust the Ruby version as needed
```

3. Create a Tmuxinator project:

```bash
tmuxinator new project
```

4. Edit the configuration:

```yaml
name: project
root: ~/projects/my-project

windows:
  - editor:
      layout: main-vertical
      panes:
        - nvim
        - git status
        - npm run dev
  - server: npm start
  - logs: tail -f logs/development.log
  - database: psql mydatabase
```

5. Start the project:

```bash
tmuxinator start project
```

### Resources

- [Tmux Tutorial](https://www.hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/)
- [The Tao of Tmux](https://leanpub.com/the-tao-of-tmux/read)
- [Tmux Cheat Sheet](https://tmuxcheatsheet.com/)
- [ArchWiki - Tmux](https://wiki.archlinux.org/title/Tmux)
- [tmuxinator](https://github.com/tmuxinator/tmuxinator)
- [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
- [Tmux Configuration Examples](https://github.com/samoshkin/tmux-config)

## Week 3: Advanced Command-Line Tools

### Core Learning Activities

1. **Text Processing Tools** (3 hours)
   - Master grep, sed, and awk
   - Learn to use cut, sort, uniq, and wc
   - Process structured data with jq
   - Combine tools with pipes
   - Practice advanced text manipulation
   - Create reusable text processing patterns
   - Master regular expressions

2. **File Management and Navigation** (2 hours)
   - Configure and use fzf for fuzzy finding
   - Set up fasd or z for quick directory jumping
   - Learn to use advanced ls alternatives (exa, lsd)
   - Master file operations with rsync
   - Implement batch renaming techniques
   - Configure advanced file searching
   - Set up file synchronization workflows

3. **System Monitoring Tools** (2 hours)
   - Use htop/btop for process monitoring
   - Monitor disk usage with ncdu
   - Track network activity with iftop
   - View system logs with journalctl
   - Configure resource usage alerts
   - Set up continual monitoring solutions
   - Practice identifying system bottlenecks

4. **Modern CLI Replacements** (3 hours)
   - Replace cat with bat
   - Use fd instead of find
   - Learn ripgrep for code searching
   - Set up delta for git diff
   - Configure modern HTTP clients (curl, httpie)
   - Explore improved command line tools
   - Create integrated workflows with modern tools

### Practical Exercises

#### Installing and Configuring Advanced CLI Tools

1. Install essential modern CLI tools:

```bash
sudo pacman -S fzf ripgrep bat exa fd ncdu htop jq httpie diff-so-fancy
```

2. Install optional CLI tools:

```bash
sudo pacman -S duf tldr ranger neofetch bottom btop iftop
```

3. Install the z plugin for Zsh if not already done:

```bash
git clone https://github.com/agkozak/zsh-z ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-z
```

4. Add the following to your ~/.zshrc:

```bash
# Modern CLI tools aliases and configuration
alias cat='bat --paging=never'
alias ls='exa'
alias la='exa -la --git'
alias lt='exa -T --git-ignore'
alias grep='rg'
alias find='fd'
alias du='duf'
alias diff='diff-so-fancy'
alias top='btop'
alias http='httpie'

# FZF configuration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
```

#### Creating Text Processing Workflows

1. Create a log analysis script:

```bash
nano ~/scripts/analyze-logs.sh
```

2. Add content:

```bash
#!/bin/bash
# Analyze log files for errors and warnings

LOG_FILE=$1
OUTPUT_DIR=~/log-analysis

# Check if log file provided
if [ -z "$LOG_FILE" ]; then
    echo "Usage: $0 <log-file>"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Extract timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Extract errors
echo "Extracting errors..."
grep -i "error" "$LOG_FILE" | sort | uniq -c | sort -nr > "$OUTPUT_DIR/errors_$TIMESTAMP.txt"

# Extract warnings
echo "Extracting warnings..."
grep -i "warn" "$LOG_FILE" | sort | uniq -c | sort -nr > "$OUTPUT_DIR/warnings_$TIMESTAMP.txt"

# Count occurrences by hour
echo "Analyzing time patterns..."
grep -i "error\|warn" "$LOG_FILE" | sed -E 's/.*([0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}):.*/\1/g' | sort | uniq -c > "$OUTPUT_DIR/hourly_$TIMESTAMP.txt"

# Find most common IP addresses (if present)
echo "Finding IP addresses..."
grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -10 > "$OUTPUT_DIR/ip_addresses_$TIMESTAMP.txt"

echo "Analysis complete. Results saved to $OUTPUT_DIR"
echo "Summary:"
echo "========="
echo "Total errors: $(wc -l < "$OUTPUT_DIR/errors_$TIMESTAMP.txt")"
echo "Total warnings: $(wc -l < "$OUTPUT_DIR/warnings_$TIMESTAMP.txt")"
```

3. Make the script executable:

```bash
chmod +x ~/scripts/analyze-logs.sh
```

#### Setting Up Advanced File Navigation

1. Configure FZF for enhanced file navigation:

```bash
# Generate FZF key bindings and completion
echo 'source /usr/share/fzf/key-bindings.zsh' >> ~/.zshrc
echo 'source /usr/share/fzf/completion.zsh' >> ~/.zshrc
```

2. Create a custom directory navigation script:

```bash
nano ~/scripts/quick-nav.sh
```

3. Add content:

```bash
#!/bin/bash
# Quick directory navigation script

# Define frequently accessed directories
PROJECTS="$HOME/projects"
DOCS="$HOME/documents"
CONFIG="$HOME/.config"
SCRIPTS="$HOME/scripts"

# Function to fuzzy find in a directory
function fuzzy_cd() {
    local dir
    dir=$(fd --type d --hidden --follow --exclude ".git" . "$1" | fzf +m) && cd "$dir"
}

# Check argument
case "$1" in
    projects)
        cd "$PROJECTS" || return
        ;;
    docs)
        cd "$DOCS" || return
        ;;
    config)
        cd "$CONFIG" || return
        ;;
    scripts)
        cd "$SCRIPTS" || return
        ;;
    fuzzy)
        fuzzy_cd "$HOME"
        ;;
    *)
        echo "Usage: $(basename "$0") {projects|docs|config|scripts|fuzzy}"
        echo "  projects - Go to projects directory"
        echo "  docs     - Go to documents directory"
        echo "  config   - Go to configuration directory"
        echo "  scripts  - Go to scripts directory"
        echo "  fuzzy    - Fuzzy find and navigate to a directory"
        return 1
        ;;
esac
```

4. Make the script executable:

```bash
chmod +x ~/scripts/quick-nav.sh
```

5. Add aliases to ~/.zshrc:

```bash
# Quick navigation
alias p='~/scripts/quick-nav.sh projects'
alias d='~/scripts/quick-nav.sh docs'
alias cf='~/scripts/quick-nav.sh config'
alias sc='~/scripts/quick-nav.sh scripts'
alias fcd='~/scripts/quick-nav.sh fuzzy'
```

#### Setting Up System Monitoring Dashboard

1. Create a simple system monitoring script:

```bash
nano ~/scripts/sysmon.sh
```

2. Add content:

```bash
#!/bin/bash
# Simple system monitoring dashboard using tmux

SESSION="sysmon"

# Check if session exists
tmux has-session -t $SESSION 2>/dev/null

if [ $? != 0 ]; then
    # Create session
    tmux new-session -s $SESSION -d
    
    # Set up panes
    tmux split-window -h -t $SESSION
    tmux split-window -v -t $SESSION:0.1
    tmux split-window -v -t $SESSION:0.0
    
    # Configure monitoring tools
    tmux send-keys -t $SESSION:0.0 'btop' C-m
    tmux send-keys -t $SESSION:0.1 'watch -n 1 "free -h | grep -v Swap"' C-m
    tmux send-keys -t $SESSION:0.2 'watch -n 1 df -h' C-m
    tmux send-keys -t $SESSION:0.3 'journalctl -f' C-m
    
    # Select first pane
    tmux select-pane -t $SESSION:0.0
fi

# Attach to session
tmux attach-session -t $SESSION
```

3. Make the script executable:

```bash
chmod +x ~/scripts/sysmon.sh
```

### Resources

- [Linux Command Line Tools](https://linuxjourney.com/lesson/stderr-standard-error-redirect)
- [Linux Productivity Tools](https://www.usenix.org/sites/default/files/conference/protected-files/lisa19_maheshwari.pdf)
- [Ripgrep User Guide](https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md)
- [fzf Examples](https://github.com/junegunn/fzf/wiki/examples)
- [Awesome CLI Apps List](https://github.com/agarrharr/awesome-cli-apps)
- [Bat Documentation](https://github.com/sharkdp/bat)
- [JQ Manual](https://stedolan.github.io/jq/manual/)
- [Advanced Bash Scripting Guide](https://tldp.org/LDP/abs/html/)

## Week 4: Shell Scripting and Workflow Integration

### Core Learning Activities

1. **Shell Scripting Fundamentals** (3 hours)
   - Learn script structure and best practices
   - Master variables and parameter expansion
   - Understand conditionals and loops
   - Use functions effectively
   - Learn proper error handling
   - Implement input validation
   - Create modular shell scripts

2. **Creating Useful Aliases and Functions** (2 hours)
   - Design shortcuts for common tasks
   - Implement smart command wrappers
   - Create project-specific aliases
   - Set up git workflow helpers
   - Develop context-aware aliases
   - Implement alias management
   - Create completion for custom functions

3. **Terminal Integration with Editor** (2 hours)
   - Configure terminal to work with Neovim
   - Set up terminal colors and themes
   - Create keybindings for editor integration
   - Implement consistent copying and pasting
   - Configure terminal-editor workflows
   - Set up file preview in terminal
   - Integrate terminal with IDE features

4. **Personal CLI Workflow Project** (3 hours)
   - Create scripts for development workflows
   - Implement project management helpers
   - Set up a task management system
   - Design status reporting tools
   - Build productivity enhancements
   - Create a unified CLI environment
   - Develop custom tools for your workflow

### Practical Exercises

#### Creating a Comprehensive Shell Script Library

1. Set up a script library structure:

```bash
mkdir -p ~/scripts/{dev,sys,utils,net}
```

2. Create a script template:

```bash
nano ~/scripts/template.sh
```

3. Add template content:

```bash
#!/bin/bash
#
# Script Name: 
# Description: 
# Author: Your Name
# Date Created: 
# Last Modified: 
#
# Usage: 
#
################################################################################

# Exit on error, undefined variable, and pipe failures
set -euo pipefail

# Script variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
LOG_FILE="/tmp/${SCRIPT_NAME%.*}.log"

# Functions
function log() {
    local message="$1"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "[$timestamp] $message" | tee -a "$LOG_FILE"
}

function cleanup() {
    # Add cleanup code here
    log "Cleaning up and exiting"
}

function show_help() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Description:
    Brief description of what the script does.

Options:
    -h, --help      Show this help message and exit
    -v, --verbose   Enable verbose output
    -f, --file      Specify an input file

Examples:
    $SCRIPT_NAME --file input.txt
EOF
}

# Parse command line arguments
VERBOSE=0
INPUT_FILE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
        -f|--file)
            INPUT_FILE="$2"
            shift 2
            ;;
        *)
            log "Error: Unknown option $1"
            show_help
            exit 1
            ;;
    esac
done

# Set up trap for cleanup on exit
trap cleanup EXIT

# Main script logic
log "Script started"

if [[ $VERBOSE -eq 1 ]]; then
    log "Verbose mode enabled"
fi

if [[ -n "$INPUT_FILE" ]]; then
    log "Using input file: $INPUT_FILE"
    
    if [[ ! -f "$INPUT_FILE" ]]; then
        log "Error: File not found - $INPUT_FILE"
        exit 1
    fi
fi

# Add your code here

log "Script completed successfully"
exit 0
```

4. Create a development workflow script:

```bash
nano ~/scripts/dev/create-project.sh
```

5. Add content:

```bash
#!/bin/bash
#
# Script Name: create-project.sh
# Description: Creates a new development project with standard structure
# Author: Your Name
# Date Created: $(date "+%Y-%m-%d")
# Last Modified: $(date "+%Y-%m-%d")
#
# Usage: create-project.sh [project-name] [project-type]
#
################################################################################

# Exit on error, undefined variable, and pipe failures
set -euo pipefail

# Script variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
PROJECTS_DIR="$HOME/projects"
LOG_FILE="/tmp/${SCRIPT_NAME%.*}.log"

# Functions
function log() {
    local message="$1"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "[$timestamp] $message" | tee -a "$LOG_FILE"
}

function show_help() {
    cat << EOF
Usage: $SCRIPT_NAME [project-name] [project-type]

Description:
    Creates a new development project with standardized structure.

Project Types:
    python      Python project with virtual environment
    node        Node.js project
    web         Static web project
    go          Go project

Examples:
    $SCRIPT_NAME my-app python
    $SCRIPT_NAME my-website web
EOF
}

# Check arguments
if [[ $# -lt 2 ]]; then
    show_help
    exit 1
fi

PROJECT_NAME="$1"
PROJECT_TYPE="$2"
PROJECT_DIR="$PROJECTS_DIR/$PROJECT_NAME"

# Check if project directory already exists
if [[ -d "$PROJECT_DIR" ]]; then
    log "Error: Project directory already exists: $PROJECT_DIR"
    exit 1
fi

# Create project directory
log "Creating project: $PROJECT_NAME ($PROJECT_TYPE)"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Create common files
touch README.md
echo "# $PROJECT_NAME" > README.md
echo "## Description" >> README.md
echo "Project created on $(date)" >> README.md

touch .gitignore
git init

# Create project structure based on type
case "$PROJECT_TYPE" in
    python)
        log "Setting up Python project structure"
        mkdir -p src/$PROJECT_NAME tests docs
        python -m venv venv
        source venv/bin/activate
        pip install pytest black flake8
        echo "venv/" >> .gitignore
        echo "__pycache__/" >> .gitignore
        echo "*.pyc" >> .gitignore
        touch setup.py
        ;;
    node)
        log "Setting up Node.js project structure"
        mkdir -p src tests public
        npm init -y
        npm install --save-dev jest eslint
        echo "node_modules/" >> .gitignore
        echo "package-lock.json" >> .gitignore
        ;;
    web)
        log "Setting up web project structure"
        mkdir -p css js img
        touch index.html
        echo "<!DOCTYPE html>" > index.html
        echo "<html><head><title>$PROJECT_NAME</title></head><body><h1>$PROJECT_NAME</h1></body></html>" >> index.html
        ;;
    go)
        log "Setting up Go project structure"
        mkdir -p cmd pkg internal
        go mod init "github.com/yourusername/$PROJECT_NAME"
        echo "/bin/" >> .gitignore
        ;;
    *)
        log "Error: Unknown project type: $PROJECT_TYPE"
        rm -rf "$PROJECT_DIR"
        exit 1
        ;;
esac

log "Project created successfully at $PROJECT_DIR"
echo "Next steps:"
echo "  cd $PROJECT_DIR"
echo "  git add ."
echo "  git commit -m \"Initial commit\""

exit 0
```

6. Make the script executable:

```bash
chmod +x ~/scripts/dev/create-project.sh
```

#### Creating Git Workflow Improvements

1. Create a git workflow script:

```bash
nano ~/scripts/dev/git-workflow.sh
```

2. Add content:

```bash
#!/bin/bash
#
# Script Name: git-workflow.sh
# Description: Streamlines common Git operations
# Author: Your Name
# Date Created: $(date "+%Y-%m-%d")
# Last Modified: $(date "+%Y-%m-%d")
#
# Usage: git-workflow.sh [command]
#
################################################################################

# Exit on error, undefined variable, and pipe failures
set -euo pipefail

# Script variables
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

# Functions
function show_help() {
    cat << EOF
Usage: $SCRIPT_NAME [command]

Commands:
    new-branch <branch-name>      Create a new feature branch
    publish                       Push current branch to origin
    update                        Update current branch with latest main/master
    sync                          Sync all branches with remote
    cleanup                       Remove merged branches
    changelog                     Generate changelog from commits
    undo                          Undo last commit (keeping changes)
    wip                           Commit work-in-progress changes
    unwip                         Undo WIP commit
    standup                       Show your commits from the last day
EOF
}

function new_branch() {
    if [[ -z "${1:-}" ]]; then
        echo "Error: Branch name required"
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
        echo "Error: Neither main nor master branch found"
        return 1
    fi
    
    # Update main branch
    git checkout "$main_branch"
    git pull origin "$main_branch"
    
    # Create new branch
    git checkout -b "$branch"
    echo "Created and switched to branch '$branch' from '$main_branch'"
}

function publish() {
    local current_branch=$(git symbolic-ref --short HEAD)
    git push -u origin "$current_branch"
    echo "Pushed '$current_branch' to origin"
}

function update() {
    local current_branch=$(git symbolic-ref --short HEAD)
    local main_branch=""
    
    # Determine main branch (main or master)
    if git show-ref --verify --quiet refs/heads/main; then
        main_branch="main"
    elif git show-ref --verify --quiet refs/heads/master; then
        main_branch="master"
    else
        echo "Error: Neither main nor master branch found"
        return 1
    fi
    
    # Stash changes if needed
    local stashed=0
    if ! git diff --quiet; then
        git stash
        stashed=1
        echo "Stashed working changes"
    fi
    
    # Update main branch
    git checkout "$main_branch"
    git pull origin "$main_branch"
    
    # Rebase feature branch
    git checkout "$current_branch"
    git rebase "$main_branch"
    
    # Apply stash if needed
    if [[ $stashed -eq 1 ]]; then
        git stash pop
        echo "Applied stashed changes"
    fi
    
    echo "Updated '$current_branch' with latest '$main_branch'"
}

function sync() {
    git fetch --all --prune
    echo "Synced with remote repository"
}

function cleanup() {
    local main_branch=""
    
    # Determine main branch (main or master)
    if git show-ref --verify --quiet refs/heads/main; then
        main_branch="main"
    elif git show-ref --verify --quiet refs/heads/master; then
        main_branch="master"
    else
        echo "Error: Neither main nor master branch found"
        return 1
    fi
    
    # Delete local branches that have been merged
    git checkout "$main_branch"
    git branch --merged | grep -v "\*" | grep -v "$main_branch" | xargs -r git branch -d
    echo "Cleaned up merged branches"
}

function changelog() {
    local days=${1:-7}
    git log --pretty=format:"- %s (%an, %ad)" --date=short --since="$days days ago"
}

function undo() {
    git reset --soft HEAD^
    echo "Undid last commit, changes preserved in working directory"
}

function wip() {
    git add .
    git commit -m "WIP: Work in progress [skip ci]"
    echo "Created WIP commit"
}

function unwip() {
    local last_msg=$(git log -1 --pretty=%B)
    if [[ "$last_msg" == "WIP: "* ]]; then
        git reset --soft HEAD^
        echo "Undid WIP commit, changes preserved in working directory"
    else
        echo "Error: Last commit is not a WIP commit"
        return 1
    fi
}

function standup() {
    git log --since=yesterday --author="$(git config user.name)" --pretty=format:"%h - %s"
}

# Parse command
if [[ $# -eq 0 ]]; then
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
    standup)
        standup
        ;;
    *)
        echo "Error: Unknown command $COMMAND"
        show_help
        exit 1
        ;;
esac

exit 0
```

3. Make it executable:

```bash
chmod +x ~/scripts/dev/git-workflow.sh
```

4. Add aliases to ~/.zshrc:

```bash
# Git workflow aliases
alias gnb='~/scripts/dev/git-workflow.sh new-branch'
alias gpu='~/scripts/dev/git-workflow.sh publish'
alias gup='~/scripts/dev/git-workflow.sh update'
alias gsync='~/scripts/dev/git-workflow.sh sync'
alias gclean='~/scripts/dev/git-workflow.sh cleanup'
alias glog='~/scripts/dev/git-workflow.sh changelog'
alias gundo='~/scripts/dev/git-workflow.sh undo'
alias gwip='~/scripts/dev/git-workflow.sh wip'
alias gunwip='~/scripts/dev/git-workflow.sh unwip'
alias gstand='~/scripts/dev/git-workflow.sh standup'
```

#### Creating a Terminal-Editor Integration

1. Configure Neovim for terminal integration in ~/.config/nvim/init.vim or ~/.config/nvim/init.lua:

```lua
-- Terminal integration settings
vim.opt.termguicolors = true
vim.opt.updatetime = 300
vim.g.terminal_scrollback_buffer_size = 10000

-- Terminal keybindings
vim.api.nvim_set_keymap('n', '<leader>t', ':terminal<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<C-h>', '<C-\\><C-n><C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<C-j>', '<C-\\><C-n><C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<C-k>', '<C-\\><C-n><C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<C-l>', '<C-\\><C-n><C-w>l', { noremap = true, silent = true })

-- Auto enter insert mode when entering terminal buffer
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '*',
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.cmd('startinsert')
  end
})

-- Close terminal buffer when process exits
vim.api.nvim_create_autocmd('TermClose', {
  pattern = '*',
  callback = function()
    if vim.v.event.status == 0 then
      vim.api.nvim_buf_delete(0, {force = true})
    end
  end
})
```

2. Create a terminal-editor integration script:

```bash
nano ~/scripts/utils/edit-and-run.sh
```

3. Add content:

```bash
#!/bin/bash
#
# Script Name: edit-and-run.sh
# Description: Opens a file in Neovim and provides options to run it
# Author: Your Name
# Date Created: $(date "+%Y-%m-%d")
# Last Modified: $(date "+%Y-%m-%d")
#
# Usage: edit-and-run.sh [file]
#
################################################################################

# Exit on error, undefined variable, and pipe failures
set -euo pipefail

# Check arguments
if [[ $# -eq 0 ]]; then
    echo "Usage: $(basename "$0") [file]"
    exit 1
fi

FILE="$1"
FILE_EXT="${FILE##*.}"

# Check if file exists, if not, create it based on extension
if [[ ! -f "$FILE" ]]; then
    case "$FILE_EXT" in
        py)
            echo '#!/usr/bin/env python3' > "$FILE"
            echo '' >> "$FILE"
            echo 'def main():' >> "$FILE"
            echo '    print("Hello, world!")' >> "$FILE"
            echo '' >> "$FILE"
            echo 'if __name__ == "__main__":' >> "$FILE"
            echo '    main()' >> "$FILE"
            chmod +x "$FILE"
            ;;
        sh)
            echo '#!/bin/bash' > "$FILE"
            echo '' >> "$FILE"
            echo 'echo "Hello, world!"' >> "$FILE"
            chmod +x "$FILE"
            ;;
        js)
            echo 'console.log("Hello, world!");' > "$FILE"
            ;;
        *)
            touch "$FILE"
            ;;
    esac
    echo "Created new file: $FILE"
fi

# Open file in Neovim
nvim "$FILE"

# Ask if user wants to run the file
read -p "Do you want to run this file? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    case "$FILE_EXT" in
        py)
            python "$FILE"
            ;;
        sh)
            bash "$FILE"
            ;;
        js)
            node "$FILE"
            ;;
        md)
            glow "$FILE"  # Requires glow to be installed
            ;;
        *)
            echo "Don't know how to run files with .$FILE_EXT extension"
            ;;
    esac
fi

exit 0
```

4. Make it executable:

```bash
chmod +x ~/scripts/utils/edit-and-run.sh
```

5. Add alias to ~/.zshrc:

```bash
# Edit and run alias
alias er='~/scripts/utils/edit-and-run.sh'
```

#### Creating a Unified CLI Dashboard

1. Create a CLI dashboard script:

```bash
nano ~/scripts/utils/dashboard.sh
```

2. Add content:

```bash
#!/bin/bash
#
# Script Name: dashboard.sh
# Description: Creates a developer dashboard in the terminal
# Author: Your Name
# Date Created: $(date "+%Y-%m-%d")
# Last Modified: $(date "+%Y-%m-%d")
#
# Usage: dashboard.sh
#
################################################################################

# Exit on error, undefined variable, and pipe failures
set -euo pipefail

# Check for required tools
for cmd in tmux fzf; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: $cmd is required but not installed"
        exit 1
    fi
done

# Create tmux session
SESSION="dashboard"
tmux has-session -t $SESSION 2>/dev/null

if [ $? != 0 ]; then
    # Create session
    tmux new-session -s $SESSION -d
    
    # Set up system info pane
    tmux rename-window -t $SESSION:0 "System"
    tmux send-keys -t $SESSION:0 "neofetch && echo '' && date && echo '' && uptime && echo ''" C-m
    tmux send-keys -t $SESSION:0 "echo 'Disk usage:' && df -h | grep -v tmpfs | grep -v devtmpfs" C-m
    tmux send-keys -t $SESSION:0 "echo '' && echo 'Memory usage:' && free -h | grep -v Swap" C-m
    
    # Create projects window
    tmux new-window -t $SESSION -n "Projects"
    tmux send-keys -t $SESSION:1 "cd ~/projects && echo 'Recent projects:' && ls -lt | head -10" C-m
    tmux send-keys -t $SESSION:1 "echo '' && echo 'Press Enter to select a project with fzf'" C-m
    tmux send-keys -t $SESSION:1 "read -n 1 && cd \$(find ~/projects -maxdepth 1 -type d | fzf)" C-m
    
    # Create tasks window
    tmux new-window -t $SESSION -n "Tasks"
    
    # Find or create a todo.txt file
    if [[ -f "$HOME/todo.txt" ]]; then
        tmux send-keys -t $SESSION:2 "cat $HOME/todo.txt" C-m
    else
        tmux send-keys -t $SESSION:2 "echo '# Todo List' > $HOME/todo.txt" C-m
        tmux send-keys -t $SESSION:2 "echo '' >> $HOME/todo.txt" C-m
        tmux send-keys -t $SESSION:2 "echo '- [ ] Task 1' >> $HOME/todo.txt" C-m
        tmux send-keys -t $SESSION:2 "echo '- [ ] Task 2' >> $HOME/todo.txt" C-m
        tmux send-keys -t $SESSION:2 "cat $HOME/todo.txt" C-m
    fi
    
    tmux send-keys -t $SESSION:2 "echo '' && echo 'Press e to edit, q to exit'" C-m
    tmux send-keys -t $SESSION:2 "read -n 1 choice && if [[ \$choice == 'e' ]]; then nvim $HOME/todo.txt; fi" C-m
    
    # Create monitoring window
    tmux new-window -t $SESSION -n "Monitor"
    tmux send-keys -t $SESSION:3 "btop" C-m
    
    # Select first window
    tmux select-window -t $SESSION:0
fi

# Attach to session
tmux attach-session -t $SESSION
```

3. Make it executable:

```bash
chmod +x ~/scripts/utils/dashboard.sh
```

4. Add alias to ~/.zshrc:

```bash
# Dashboard alias
alias dash='~/scripts/utils/dashboard.sh'
```

### Resources

- [Bash Guide for Beginners](https://tldp.org/LDP/Bash-Beginners-Guide/html/index.html)
- [Zsh Scripting](https://zsh.sourceforge.io/Doc/Release/Shell-Grammar.html)
- [Shell Script Best Practices](https://sharats.me/posts/shell-script-best-practices/)
- [Pure Bash Bible](https://github.com/dylanaraps/pure-bash-bible)
- [Writing Robust Bash Shell Scripts](https://www.davidpashley.com/articles/writing-robust-shell-scripts/)
- [Neovim Terminal Documentation](https://neovim.io/doc/user/nvim_terminal_emulator.html)
- [Bash Scripting Cheatsheet](https://devhints.io/bash)
- [Advanced Command Line Tips](https://blog.balthazar-rouberol.com/shell-productivity-tips-and-tricks)

## Projects and Exercises

1. **Dotfiles Enhancement**
   - Refactor your dotfiles repository to include Zsh configuration
   - Add Tmux configuration files
   - Create a bootstrap script for new machines
   - Document your terminal setup thoroughly
   - Implement version control for configuration evolution

2. **Custom Tmux Environment**
   - Create a development-focused Tmux configuration
   - Add project-specific session scripts
   - Implement a custom status bar with relevant information
   - Create keybindings for efficient workflow
   - Design session templates for different types of work

3. **CLI Productivity Suite**
   - Create a collection of shell functions for common development tasks
   - Implement project management functionality
   - Add system monitoring capabilities
   - Include documentation and usage examples
   - Design a cohesive set of tools that work together

4. **Terminal Data Processing Pipeline**
   - Create a script to process and analyze log data
   - Implement filtering, transformation, and aggregation
   - Generate reports or visualizations in the terminal
   - Add options for different analysis modes
   - Include documentation and examples of use cases

## Cross-References

- **Previous Month**: [Month 3: Desktop Environment and Workflow Setup](month-03-desktop-setup.md) - Foundation for terminal configuration
- **Next Month**: [Month 5: Programming Languages and Development Tools](month-05-dev-tools.md) - Will build on your terminal environment with programming tools
- **Related Guides**: 
  - [Troubleshooting Guide](/troubleshooting/README.md) - For resolving terminal and shell issues
  - [Development Environment Configuration](/configuration/development/README.md) - For integrating terminal with development tools
  - [System Monitor Project](/projects/system-monitor/README.md) - A practical project that uses terminal concepts
- **Reference Resources**:
  - [Linux Shortcuts & Commands Reference](linux-shortcuts.md) - For terminal shortcuts
  - [Linux Mastery Journey - Glossary](linux-glossary.md) - For terminal and shell terminology

## Assessment

You should now be able to:

1. Configure and customize Zsh for efficient command-line use
2. Use Tmux to manage multiple terminal sessions effectively
3. Process text and data using advanced command-line tools
4. Create and use powerful aliases, functions, and scripts
5. Navigate the filesystem with speed and precision
6. Maintain a consistent terminal environment across systems

## Next Steps

In Month 5, we'll focus on:
- Setting up language-specific development environments
- Configuring Neovim as a full-featured IDE
- Implementing language servers and code completion
- Creating language-specific workflows and tools
- Setting up debugging environments

## Acknowledgements

This learning guide was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Learning path structure and organization
- Resource recommendations
- Project suggestions

Claude was used as a development aid while all final implementation decisions and verification were performed by Joshua Michael Hall.

## Disclaimer

This guide is provided "as is", without warranty of any kind. Follow all instructions carefully and always make backups before making system changes.

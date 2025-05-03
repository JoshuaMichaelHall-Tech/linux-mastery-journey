#!/bin/bash
#
# post-install.sh - Post-installation setup for Arch Linux
# Part of the Linux Mastery Journey project
#
# This script automates the setup of a development environment on Arch Linux.
# It installs and configures common development tools, desktop environment,
# and system utilities optimized for software development.

set -e # Exit immediately if a command exits with a non-zero status

# Print with colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display usage information
show_usage() {
    echo -e "${BLUE}Post-Installation Setup Script for Arch Linux${NC}"
    echo
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -u, --username USERNAME Set the main user name (required)"
    echo "  -d, --desktop ENV       Desktop environment (i3, sway, gnome, kde, none) (default: i3)"
    echo "  -g, --graphics DRIVER   Graphics driver (intel, amd, nvidia) (default: auto-detect)"
    echo "  -l, --languages LANGS   Programming languages to install (default: python,javascript,ruby)"
    echo "  --no-aur                Skip AUR helper installation"
    echo "  --dotfiles URL          Git repository URL with dotfiles to install"
    echo
    echo "Example:"
    echo "  $0 --username johndoe --desktop i3 --graphics intel --languages python,javascript,rust"
    echo
    exit 1
}

# Default values
USERNAME=""
DESKTOP="i3"
GRAPHICS="auto"
LANGUAGES="python,javascript,ruby"
INSTALL_AUR=true
DOTFILES_URL=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            ;;
        -u|--username)
            USERNAME="$2"
            shift 2
            ;;
        -d|--desktop)
            DESKTOP="$2"
            shift 2
            ;;
        -g|--graphics)
            GRAPHICS="$2"
            shift 2
            ;;
        -l|--languages)
            LANGUAGES="$2"
            shift 2
            ;;
        --no-aur)
            INSTALL_AUR=false
            shift
            ;;
        --dotfiles)
            DOTFILES_URL="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}Error: Unknown option: $1${NC}"
            show_usage
            ;;
    esac
done

# Validate inputs
if [[ -z "$USERNAME" ]]; then
    echo -e "${RED}Error: Username is required.${NC}"
    show_usage
fi

if ! [[ "$USERNAME" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    echo -e "${RED}Error: Invalid username. Use only lowercase letters, numbers, underscores, and hyphens. Must start with a letter or underscore.${NC}"
    exit 1
fi

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Error: This script must be run as root.${NC}"
    exit 1
fi

# Detect if user already exists
if id "$USERNAME" &>/dev/null; then
    echo -e "${YELLOW}User $USERNAME already exists.${NC}"
    EXISTING_USER=true
else
    EXISTING_USER=false
fi

# Validate desktop environment
case "$DESKTOP" in
    i3|sway|gnome|kde|none)
        echo -e "${BLUE}Desktop environment: $DESKTOP${NC}"
        ;;
    *)
        echo -e "${RED}Error: Invalid desktop environment. Choose from: i3, sway, gnome, kde, none.${NC}"
        exit 1
        ;;
esac

# Validate graphics driver
case "$GRAPHICS" in
    intel|amd|nvidia|auto)
        echo -e "${BLUE}Graphics driver: $GRAPHICS${NC}"
        ;;
    *)
        echo -e "${RED}Error: Invalid graphics driver. Choose from: intel, amd, nvidia, auto.${NC}"
        exit 1
        ;;
esac

# Display setup information
echo -e "${BLUE}Post-Installation Setup${NC}"
echo "Username: $USERNAME"
echo "Desktop environment: $DESKTOP"
echo "Graphics driver: $GRAPHICS"
echo "Programming languages: $LANGUAGES"
echo "Install AUR helper: $(if $INSTALL_AUR; then echo "Yes"; else echo "No"; fi)"
echo "Dotfiles URL: $(if [[ -n "$DOTFILES_URL" ]]; then echo "$DOTFILES_URL"; else echo "None"; fi)"
echo

# Confirm before proceeding
read -p "Continue with setup? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 1
fi

# Update system
echo -e "${YELLOW}Updating system...${NC}"
pacman -Syu --noconfirm

# Install base development packages
echo -e "${YELLOW}Installing base development packages...${NC}"
pacman -S --noconfirm --needed base-devel git curl wget sudo zsh tmux neovim

# Create user if not exists
if ! $EXISTING_USER; then
    echo -e "${YELLOW}Creating user $USERNAME...${NC}"
    useradd -m -G wheel -s /bin/zsh "$USERNAME"
    echo -e "${YELLOW}Setting password for $USERNAME...${NC}"
    passwd "$USERNAME"
fi

# Configure sudo access
echo -e "${YELLOW}Configuring sudo access...${NC}"
sed -i '/%wheel ALL=(ALL:ALL) ALL/s/^# //' /etc/sudoers

# Install graphics driver
if [[ "$GRAPHICS" == "auto" ]]; then
    # Auto-detect graphics hardware
    echo -e "${YELLOW}Auto-detecting graphics hardware...${NC}"
    if lspci | grep -i nvidia > /dev/null; then
        GRAPHICS="nvidia"
    elif lspci | grep -i amd > /dev/null; then
        GRAPHICS="amd"
    elif lspci | grep -i intel > /dev/null; then
        GRAPHICS="intel"
    else
        echo -e "${RED}Warning: Could not detect graphics hardware. Defaulting to Intel.${NC}"
        GRAPHICS="intel"
    fi
    echo -e "${BLUE}Detected graphics: $GRAPHICS${NC}"
fi

echo -e "${YELLOW}Installing $GRAPHICS graphics driver...${NC}"
case "$GRAPHICS" in
    intel)
        pacman -S --noconfirm --needed xf86-video-intel mesa lib32-mesa vulkan-intel lib32-vulkan-intel
        ;;
    amd)
        pacman -S --noconfirm --needed xf86-video-amdgpu mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon
        ;;
    nvidia)
        pacman -S --noconfirm --needed nvidia nvidia-utils lib32-nvidia-utils
        ;;
esac

# Install desktop environment
echo -e "${YELLOW}Installing $DESKTOP desktop environment...${NC}"
case "$DESKTOP" in
    i3)
        pacman -S --noconfirm --needed xorg xorg-xinit i3-gaps i3status i3lock dmenu lightdm lightdm-gtk-greeter picom
        systemctl enable lightdm
        ;;
    sway)
        pacman -S --noconfirm --needed sway swaylock swayidle waybar dmenu
        ;;
    gnome)
        pacman -S --noconfirm --needed gnome gnome-extra
        systemctl enable gdm
        ;;
    kde)
        pacman -S --noconfirm --needed plasma kde-applications sddm
        systemctl enable sddm
        ;;
    none)
        echo -e "${BLUE}Skipping desktop environment installation.${NC}"
        ;;
esac

# Install common utilities
echo -e "${YELLOW}Installing common utilities...${NC}"
pacman -S --noconfirm --needed firefox alacritty kitty rofi thunar ranger feh \
    pulseaudio pavucontrol bluez bluez-utils \
    ttf-dejavu ttf-liberation noto-fonts \
    zip unzip p7zip unrar rsync htop

# Install network tools
echo -e "${YELLOW}Installing network tools...${NC}"
pacman -S --noconfirm --needed networkmanager network-manager-applet \
    wpa_supplicant dhcpcd openssh
systemctl enable NetworkManager
systemctl enable sshd

# Install AUR helper (paru)
if $INSTALL_AUR; then
    echo -e "${YELLOW}Installing AUR helper (paru)...${NC}"
    # Install dependencies for paru
    pacman -S --noconfirm --needed base-devel
    
    # Create temporary directory
    TMP_DIR=$(sudo -u "$USERNAME" mktemp -d)
    chown "$USERNAME":"$USERNAME" "$TMP_DIR"
    
    # Clone and build paru
    sudo -u "$USERNAME" bash -c "cd $TMP_DIR && \
        git clone https://aur.archlinux.org/paru.git && \
        cd paru && \
        makepkg -si --noconfirm"
    
    # Cleanup
    rm -rf "$TMP_DIR"
    
    echo -e "${GREEN}AUR helper (paru) installed successfully.${NC}"
fi

# Install programming languages
echo -e "${YELLOW}Installing programming languages...${NC}"
IFS=',' read -ra LANG_ARRAY <<< "$LANGUAGES"
for lang in "${LANG_ARRAY[@]}"; do
    case "$lang" in
        python)
            echo -e "${BLUE}Installing Python development environment...${NC}"
            pacman -S --noconfirm --needed python python-pip python-virtualenv \
                python-poetry python-pytest ipython
            ;;
        javascript)
            echo -e "${BLUE}Installing JavaScript development environment...${NC}"
            pacman -S --noconfirm --needed nodejs npm yarn
            ;;
        ruby)
            echo -e "${BLUE}Installing Ruby development environment...${NC}"
            pacman -S --noconfirm --needed ruby rubygems
            gem install bundler
            ;;
        rust)
            echo -e "${BLUE}Installing Rust development environment...${NC}"
            pacman -S --noconfirm --needed rustup
            sudo -u "$USERNAME" rustup default stable
            ;;
        go)
            echo -e "${BLUE}Installing Go development environment...${NC}"
            pacman -S --noconfirm --needed go
            ;;
        java)
            echo -e "${BLUE}Installing Java development environment...${NC}"
            pacman -S --noconfirm --needed jdk-openjdk maven gradle
            ;;
        *)
            echo -e "${RED}Unknown language: $lang. Skipping.${NC}"
            ;;
    esac
done

# Install development tools
echo -e "${YELLOW}Installing development tools...${NC}"
pacman -S --noconfirm --needed git cmake clang gdb docker docker-compose
systemctl enable docker

# Add user to docker group
usermod -aG docker "$USERNAME"

# Install dotfiles if URL is provided
if [[ -n "$DOTFILES_URL" ]]; then
    echo -e "${YELLOW}Installing dotfiles from $DOTFILES_URL...${NC}"
    
    # Clone dotfiles repository
    DOTFILES_DIR="/home/$USERNAME/.dotfiles"
    sudo -u "$USERNAME" git clone "$DOTFILES_URL" "$DOTFILES_DIR"
    
    # Run installation script if it exists
    if [[ -f "$DOTFILES_DIR/install.sh" ]]; then
        echo -e "${BLUE}Running dotfiles installation script...${NC}"
        chown -R "$USERNAME":"$USERNAME" "$DOTFILES_DIR"
        cd "$DOTFILES_DIR"
        sudo -u "$USERNAME" bash "$DOTFILES_DIR/install.sh"
    else
        echo -e "${RED}No installation script found in dotfiles repository.${NC}"
    fi
fi

# Create zsh configuration if it doesn't exist
ZSH_CONFIG="/home/$USERNAME/.zshrc"
if [[ ! -f "$ZSH_CONFIG" ]]; then
    echo -e "${YELLOW}Creating basic zsh configuration...${NC}"
    cat > "$ZSH_CONFIG" << EOF
# ~/.zshrc - ZSH configuration file

# Environment variables
export EDITOR=nvim
export VISUAL=nvim
export TERM=xterm-256color
export PAGER=less
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE=~/.zsh_history

# Path
export PATH=\$HOME/.local/bin:\$PATH

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lah'
alias grep='grep --color=auto'
alias vi='nvim'
alias vim='nvim'
alias g='git'
alias gst='git status'
alias gd='git diff'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'

# Basic zsh options
setopt autocd                   # Change directory just by typing its name
setopt prompt_subst             # Enable parameter expansion in prompt
setopt hist_ignore_dups         # Do not record dupes in history
setopt hist_ignore_space        # Do not record commands starting with space
setopt extended_history         # Record timestamp in history
setopt share_history            # Share history between sessions
setopt hist_verify              # Show command with history expansion before executing

# Basic completion system
autoload -Uz compinit
compinit

# Basic prompt (customize as needed)
PS1='%F{cyan}%n%f@%F{green}%m%f:%F{blue}%~%f\$ '

# Add local customizations if they exist
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
EOF
    
    # Set proper ownership
    chown "$USERNAME":"$USERNAME" "$ZSH_CONFIG"
fi

# Create basic neovim configuration
NVIM_CONFIG_DIR="/home/$USERNAME/.config/nvim"
if [[ ! -d "$NVIM_CONFIG_DIR" ]]; then
    echo -e "${YELLOW}Creating basic neovim configuration...${NC}"
    mkdir -p "$NVIM_CONFIG_DIR"
    chown "$USERNAME":"$USERNAME" "$NVIM_CONFIG_DIR"
    
    # Create init.vim
    cat > "$NVIM_CONFIG_DIR/init.vim" << EOF
" ~/.config/nvim/init.vim - Neovim configuration file

" General settings
set number              " Show line numbers
set relativenumber      " Show relative line numbers
set tabstop=4           " Number of spaces tabs count for
set shiftwidth=4        " Size of an indent
set expandtab           " Use spaces instead of tabs
set smartindent         " Enable smart indentation
set autoindent          " Copy indent from current line when starting a new line
set showmatch           " Show matching brackets
set ignorecase          " Ignore case when searching
set smartcase           " Case sensitive if search contains uppercase
set hlsearch            " Highlight search results
set incsearch           " Show search matches as you type
set wrap                " Wrap lines
set laststatus=2        " Always show status line
set clipboard=unnamedplus  " Use system clipboard
set hidden              " Allow buffer switching without saving
set mouse=a             " Enable mouse for all modes
set updatetime=300      " Faster completion
set signcolumn=yes      " Always show signcolumn
set termguicolors       " Enable true colors support

" Key mappings
let mapleader = " "     " Set leader key to space

" Easy buffer navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Escape insert mode with jk
inoremap jk <Esc>

" Save and quit shortcuts
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>wq :wq<CR>

" Basic auto-install of vim-plug
let data_dir = expand('~/.local/share/nvim/site')
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source \$MYVIMRC
endif

" Plugins (vim-plug)
call plug#begin(data_dir . '/plugged')

" General Plugins
Plug 'tpope/vim-fugitive'                     " Git integration
Plug 'airblade/vim-gitgutter'                 " Git gutter signs
Plug 'nvim-lua/plenary.nvim'                  " Lua functions dependency
Plug 'nvim-telescope/telescope.nvim'          " Fuzzy finder
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " Syntax highlighting
Plug 'neovim/nvim-lspconfig'                  " LSP configuration
Plug 'hrsh7th/nvim-cmp'                       " Completion plugin
Plug 'hrsh7th/cmp-nvim-lsp'                   " LSP completion
Plug 'hrsh7th/cmp-buffer'                     " Buffer completion
Plug 'hrsh7th/cmp-path'                       " Path completion
Plug 'L3MON4D3/LuaSnip'                       " Snippets
Plug 'saadparwaiz1/cmp_luasnip'               " Snippets for cmp
Plug 'morhetz/gruvbox'                        " Color scheme

call plug#end()

" Theme configuration
colorscheme desert                            " Default colorscheme

" Install plugins on first start 
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source \$MYVIMRC
\| endif

" Add local customizations if they exist
if filereadable(expand("~/.config/nvim/init.vim.local"))
  source ~/.config/nvim/init.vim.local
endif
EOF
    
    # Set proper ownership
    chown -R "$USERNAME":"$USERNAME" "$NVIM_CONFIG_DIR"
    
    # Create basic lua configuration
    mkdir -p "$NVIM_CONFIG_DIR/lua"
    chown "$USERNAME":"$USERNAME" "$NVIM_CONFIG_DIR/lua"
    
    # Create basic tmux configuration
    TMUX_CONFIG="/home/$USERNAME/.tmux.conf"
    if [[ ! -f "$TMUX_CONFIG" ]]; then
        echo -e "${YELLOW}Creating basic tmux configuration...${NC}"
        cat > "$TMUX_CONFIG" << EOF
# ~/.tmux.conf - Tmux configuration file

# Use C-a as prefix
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

# Reload config
bind r source-file ~/.tmux.conf \; display "Config reloaded!"

# Split panes using | and -
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# Switch panes using Alt-arrow
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Enable mouse mode
set -g mouse on

# Set vi mode
setw -g mode-keys vi

# Increase history limit
set -g history-limit 10000

# Set base index to 1
set -g base-index 1
setw -g pane-base-index 1

# Status bar
set -g status-bg black
set -g status-fg white
set -g status-left "#[fg=green]#S #[fg=yellow]#I #[fg=cyan]#P"
set -g status-right "#[fg=cyan]%d %b %R"

# Enable true colors
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-256color:RGB"

# Add local customizations if they exist
if-shell "[ -f ~/.tmux.conf.local ]" 'source ~/.tmux.conf.local'
EOF
        
        # Set proper ownership
        chown "$USERNAME":"$USERNAME" "$TMUX_CONFIG"
    fi
fi

# Configure git
echo -e "${YELLOW}Configuring git for user $USERNAME...${NC}"
sudo -u "$USERNAME" git config --global init.defaultBranch main
sudo -u "$USERNAME" git config --global core.editor nvim

# Print completion message
echo -e "${GREEN}Post-installation setup completed successfully!${NC}"
echo
echo -e "${BLUE}Next steps:${NC}"
echo "1. Reboot the system with: systemctl reboot"
echo "2. Login as $USERNAME"
echo "3. Start exploring your new system!"
echo
echo -e "${YELLOW}For more information, refer to the Linux Mastery Journey documentation.${NC}"
echo

exit 0

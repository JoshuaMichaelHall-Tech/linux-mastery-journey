Mouseless on Arch Linux: The Ultimate Terminal-Centric Workflow
Introduction
This guide will transform your computing experience by eliminating mouse dependency and embracing keyboard-driven workflows on Arch Linux. By mastering terminal-based applications and keyboard shortcuts, you'll dramatically increase your productivity and efficiency while working in a distraction-free environment.
Learning Objectives
By the end of this course, you will:

Configure and navigate Arch Linux entirely via keyboard
Master terminal-based applications for daily computing tasks
Develop muscle memory for essential keyboard shortcuts
Create a customized, efficient workflow without GUI dependencies
Seamlessly integrate AI tools into your terminal environment

Prerequisites

Basic familiarity with Linux systems
Functional Arch Linux installation
Comfort with terminal basics (navigation, file manipulation)
Willingness to invest time in developing new computing habits

Week 1: Foundation and Environment Setup
Day 1-2: Setting Up a Tiling Window Manager

Install either i3, dwm, or bspwm:
bashsudo pacman -S i3-wm i3status i3lock dmenu
# OR
sudo pacman -S bspwm sxhkd

Configure basic keybindings in configuration files:

For i3: ~/.config/i3/config
For bspwm: ~/.config/sxhkd/sxhkdrc


Essential keybindings to configure:

Workspace navigation
Window focus/movement
Application launching
Terminal spawning (Mod+Enter)



Day 3-4: Terminal Multiplexer (tmux)

Install and configure tmux:
bashsudo pacman -S tmux

Create a custom .tmux.conf:
bash# Set prefix to Ctrl+a
unbind C-b
set -g prefix C-a

# Vim-style pane navigation
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Enable mouse mode (for transition period)
set -g mouse on

# More intuitive window splitting
bind | split-window -h
bind - split-window -v

# Enable vi mode for copy mode
setw -g mode-keys vi

Essential tmux commands:

Session management: tmux new -s name, tmux attach -t name
Window management: prefix + c (create), prefix + n/p (next/prev)
Pane management: prefix + |/- (split h/v), prefix + hjkl (navigate)
Copy mode: prefix + [, navigate with vim keys, select with v, copy with y



Day 5-7: Neovim Setup and Configuration

Install Neovim and dependencies:
bashsudo pacman -S neovim python-pynvim nodejs npm ripgrep fd

Set up a package manager (packer.nvim):
bashgit clone https://github.com/wbthomason/packer.nvim \
  ~/.local/share/nvim/site/pack/packer/start/packer.nvim

Create initial configuration in ~/.config/nvim/init.lua:
lua-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true

-- Set leader key to space
vim.g.mapleader = " "

-- Essential keybindings
vim.keymap.set('n', '<leader>e', ':Explore<CR>')
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

Install essential plugins (create ~/.config/nvim/lua/plugins.lua):
luareturn require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'nvim-telescope/telescope.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'L3MON4D3/LuaSnip'
end)


Week 2: Terminal Web Browsing and Communication
Day 8-9: Terminal Web Browsing

Install and configure terminal browsers:
bashsudo pacman -S w3m lynx
# For more capability with JavaScript:
paru -S browsh-bin

Learn essential shortcuts:

w3m: Navigation (h/j/k/l), forms (TAB), links (ENTER)
lynx: Arrow keys, forms (TAB), links (right arrow)
browsh: Similar to Firefox but works in terminal


Configure w3m in ~/.w3m/config:
accept_cookie 1
ssl_verify_server 1
display_link_number 1
use_mouse 0


Day 10-11: Terminal Email with Neomutt

Install and configure Neomutt:
bashsudo pacman -S neomutt isync msmtp pass notmuch
mkdir -p ~/.config/neomutt

Create basic configuration in ~/.config/neomutt/neomuttrc:
# Account settings
set realname = "Your Name"
set from = "your.email@example.com"

# IMAP settings using mbsync/isync
set folder = "~/.mail"
set spoolfile = "+inbox"
set record = "+sent"
set postponed = "+drafts"
set trash = "+trash"

# Key bindings (vim-like)
bind index,pager j next-entry
bind index,pager k previous-entry
bind index,pager g noop
bind index gg first-entry
bind index G last-entry

# Sidebar configuration
set sidebar_visible = yes
set sidebar_width = 30

Configure mbsync in ~/.mbsyncrc (for email syncing)
Learn essential commands:

Navigation: j/k (next/prev), gg/G (first/last)
Email actions: r (reply), f (forward), d (delete)
Composition: m (new mail), a (attach file)



Day 12-13: Terminal Chat (Slack, Matrix, etc.)

Install terminal Slack client:
bashparu -S slack-term-bin

Configure in ~/.config/slack-term/config.json
Install and configure terminal Matrix client:
bashsudo pacman -S weechat
# Then in weechat:
/script install matrix.py

Learn essential commands:

slack-term: arrows to navigate, Enter to select, Esc to cancel
weechat/matrix: /join, /part, arrows to navigate



Week 3: Media and File Management
Day 14-15: Terminal File Management

Install advanced file managers:
bashsudo pacman -S ranger vifm

Configure ranger in ~/.config/ranger/rc.conf:
set viewmode miller
set column_ratios 1,3,4
set show_hidden true
set preview_images true
set preview_images_method kitty

Learn essential commands:

Navigation: h/j/k/l, gg/G
File operations: dd (cut), yy (copy), pp (paste), space (select)
Preview: i (toggle preview)



Day 16-17: Terminal Media Playback

Install media players:
bashsudo pacman -S mpv moc cmus youtube-dl

Configure MOC (music player) in ~/.moc/config:
Theme = darkdot_theme
ReadTags = yes
MusicDir = ~/Music
StartInMusicDir = yes

Learn essential commands:

mpv: space (play/pause), [ ] (speed adjustment)
cmus: c (pause), b (next), z (previous), / (search)
moc: q (add to queue), p (pause), n (next), b (previous)


YouTube in terminal:
bash# Play YouTube video directly in terminal
mpv --no-video https://www.youtube.com/watch?v=VIDEO_ID
# Audio only
mpv --no-video https://www.youtube.com/watch?v=VIDEO_ID


Day 18-19: PDF Viewing and Document Management

Install document tools:
bashsudo pacman -S zathura zathura-pdf-poppler pandoc

Configure Zathura in ~/.config/zathura/zathurarc:
set selection-clipboard clipboard
set window-title-basename true
map <C-i> zoom in
map <C-o> zoom out
map u scroll half-up
map d scroll half-down

Learn essential commands:

Navigation: h/j/k/l, gg/G, / (search)
View: a (adjust to width), s (adjust to fit)
Table of contents: Tab



Week 4: Advanced Integration and Customization
Day 20-21: AI Integration in Terminal

Install AI tools and libraries:
bashsudo pacman -S python-pip
pip install anthropic requests

Create a simple Claude CLI script:
python#!/usr/bin/env python3
import os
import sys
import argparse
from anthropic import Anthropic

def main():
    parser = argparse.ArgumentParser(description='CLI for Claude')
    parser.add_argument('prompt', nargs='*', help='Prompt for Claude')
    parser.add_argument('-f', '--file', help='Read prompt from file')
    args = parser.parse_args()

    # Get API key from environment
    api_key = os.environ.get('ANTHROPIC_API_KEY')
    if not api_key:
        print("Error: ANTHROPIC_API_KEY not set in environment")
        sys.exit(1)

    # Get prompt from arguments or file
    if args.file:
        with open(args.file, 'r') as f:
            prompt = f.read()
    elif args.prompt:
        prompt = ' '.join(args.prompt)
    else:
        prompt = sys.stdin.read()

    # Create client and get response
    client = Anthropic(api_key=api_key)
    message = client.messages.create(
        model="claude-3-haiku-20240307",
        max_tokens=1000,
        system="You are a helpful assistant providing concise responses for terminal use.",
        messages=[{"role": "user", "content": prompt}]
    )
    
    print(message.content[0].text)

if __name__ == "__main__":
    main()

Make it executable and accessible:
bashchmod +x ~/scripts/claude-cli.py
ln -s ~/scripts/claude-cli.py ~/.local/bin/claude

Create a Neovim plugin for Claude integration (in ~/.config/nvim/lua/plugins/claude.lua)

Day 22-23: Video Conferencing in Terminal

Install terminal-friendly conferencing tools:
bashsudo pacman -S ffmpeg v4l2loopback-dkms

Load the v4l2loopback module:
bashsudo modprobe v4l2loopback

For screen sharing:
bashffmpeg -f x11grab -r 15 -s 1920x1080 -i :0.0 -vcodec rawvideo -pix_fmt yuv420p -f v4l2 /dev/video0

For CLI Zoom client interaction:
bashparu -S zoom-cli-bin

Learn essential commands for managing meetings via CLI

Day 24-25: Customizing Shell Environment

Install and configure zsh with plugins:
bashsudo pacman -S zsh zsh-autosuggestions zsh-syntax-highlighting fzf

Create a robust .zshrc:
bash# Enable Powerlevel10k theme
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# Enable plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Key bindings
bindkey -v  # vim mode
bindkey '^R' history-incremental-search-backward

# Aliases
alias ls='ls --color=auto'
alias ll='ls -la'
alias v='nvim'
alias t='tmux'
alias ta='tmux attach -t'
alias tn='tmux new -s'
alias tk='tmux kill-session -t'

# FZF integration
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

# Functions
function cheat() {
  curl "cheat.sh/$1"
}


Week 5-6: Practice and Workflow Integration
Day 26-30: Daily Practice Exercises

Set up a practice routine:

30 minutes daily dedicated to keyboard-only navigation
Disable mouse/trackpad entirely to force adaptation
Set daily challenges (e.g., "Handle all email without mouse")


Create workflow automation scripts:

Task management
Note-taking
Project templates


Develop custom keybinding cheat sheets:
bash# Create a simple cheatsheet script
echo '#!/bin/bash
case "$1" in
  tmux) cat ~/.tmux-cheatsheet.txt ;;
  vim) cat ~/.vim-cheatsheet.txt ;;
  i3) cat ~/.i3-cheatsheet.txt ;;
  *) echo "Available cheatsheets: tmux, vim, i3" ;;
esac' > ~/.local/bin/cheatsheet
chmod +x ~/.local/bin/cheatsheet


Day 31-40: Full Workflow Integration

Create a system for rapid application launching:
bash# Create a dmenu/rofi custom script
echo '#!/bin/bash
case "$(echo -e "email\nbrowse\nmusic\nchat\ncode" | dmenu -i -p "Quick Launch:")" in
  email) neomutt ;;
  browse) w3m ;;
  music) cmus ;;
  chat) slack-term ;;
  code) cd ~/projects && nvim ;;
esac' > ~/.local/bin/quicklaunch
chmod +x ~/.local/bin/quicklaunch

Add to i3 or bspwm config to bind to a key (e.g., Mod+p)
Set up workspace templates:

Coding (tmux with vim, git terminal)
Writing (vim with distraction-free settings)
Communication (email, chat clients in tmux)



Resources and Further Learning
Terminal Applications Reference
CategoryApplicationInstallationWeb Browsingw3m, lynx, browshsudo pacman -S w3m lynx; paru -S browsh-binEmailneomutt, mbsync, msmtpsudo pacman -S neomutt isync msmtp passChatslack-term, weechatparu -S slack-term-bin; sudo pacman -S weechatFile Managementranger, vifmsudo pacman -S ranger vifmMediampv, cmus, mocsudo pacman -S mpv cmus mocDocumentszathura, pandocsudo pacman -S zathura zathura-pdf-poppler pandocDevelopmentneovim, git, tmuxsudo pacman -S neovim git tmux
Recommended Resources

Books and Documentation:

"Practical Vim" by Drew Neil
Arch Wiki (https://wiki.archlinux.org/)
Neovim documentation (:help)


Communities:

r/unixporn (for configuration inspiration)
r/vim
r/commandline


YouTube Channels:

ThePrimeagen (Vim tutorials)
DistroTube (Linux configuration)
Luke Smith (Terminal workflows)



Assessment and Challenges
Weekly Challenges

Week 1: Navigate entire day without touching mouse
Week 2: Send and reply to 5 emails using Neomutt
Week 3: Manage project files entirely in terminal
Week 4: Create a custom workflow script

Final Challenge
Create a comprehensive personal productivity system using only terminal applications, integrating:

Task management
Note-taking
Calendar
Project organization
Communication

Document your workflow and share with the community.
Acknowledgements
This project was developed with assistance from Anthropic's Claude AI assistant, which helped with:

Documentation writing and organization
Code structure suggestions
Troubleshooting and debugging assistance

Claude was used as a development aid while all final implementation decisions and code review were performed by Joshua Michael Hall.
Disclaimer
This guide is provided for educational purposes only. The author makes no warranties regarding the functionality or security of configurations and applications mentioned. This is a work in progress - report any issues or suggestions for improvement. Use at your own risk and always backup your system before making significant changes.RetryClaude can make mistakes. Please double-check responses.

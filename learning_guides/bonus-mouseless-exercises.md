# Mouseless on Arch Linux: Exercise Guide

This exercise guide provides practical tasks and projects to accompany the "Mouseless on Arch Linux: The Ultimate Terminal-Centric Workflow" learning guide. By completing these exercises, you'll develop the muscle memory and efficiency needed to work productively without a mouse in a Linux environment.

This document contains practical exercises to accompany the "Mouseless on Arch Linux: The Ultimate Terminal-Centric Workflow" guide. Complete these exercises to develop muscle memory, efficiency, and confidence with keyboard-driven workflows in Linux.

## Window Manager Configuration Project

Create a personalized tiling window manager configuration that suits your workflow needs.

### Tasks:

1. **Install and set up your chosen window manager**:
   ```bash
   # Install i3 window manager
   sudo pacman -S i3-wm i3status i3blocks dmenu
   
   # Or install bspwm with sxhkd
   sudo pacman -S bspwm sxhkd
   ```

2. **Create a custom keybinding configuration**:
   ```bash
   # For i3, make a backup of default config first
   mkdir -p ~/.config/i3
   cp /etc/i3/config ~/.config/i3/config.bak
   touch ~/.config/i3/config
   
   # For bspwm
   mkdir -p ~/.config/bspwm ~/.config/sxhkd
   cp /usr/share/doc/bspwm/examples/bspwmrc ~/.config/bspwm/
   cp /usr/share/doc/bspwm/examples/sxhkdrc ~/.config/sxhkd/
   chmod +x ~/.config/bspwm/bspwmrc
   ```

3. **Configure essential window management keybindings**:
   ```bash
   # Example i3 configuration additions - add to ~/.config/i3/config
   
   # Set mod key to Alt (Mod1) or Super (Mod4)
   set $mod Mod4
   
   # Launch terminal
   bindsym $mod+Return exec alacritty
   
   # Kill focused window
   bindsym $mod+Shift+q kill
   
   # Start dmenu
   bindsym $mod+d exec dmenu_run
   
   # Change focus with vim-like keys
   bindsym $mod+h focus left
   bindsym $mod+j focus down
   bindsym $mod+k focus up
   bindsym $mod+l focus right
   
   # Move windows with vim-like keys
   bindsym $mod+Shift+h move left
   bindsym $mod+Shift+j move down
   bindsym $mod+Shift+k move up
   bindsym $mod+Shift+l move right
   
   # Split in horizontal/vertical orientation
   bindsym $mod+bar split h
   bindsym $mod+minus split v
   
   # Enter fullscreen mode
   bindsym $mod+f fullscreen toggle
   
   # Change container layout
   bindsym $mod+s layout stacking
   bindsym $mod+w layout tabbed
   bindsym $mod+e layout toggle split
   
   # Define workspaces
   set $ws1 "1"
   set $ws2 "2"
   set $ws3 "3"
   # (continue for all desired workspaces)
   
   # Switch to workspace
   bindsym $mod+1 workspace $ws1
   bindsym $mod+2 workspace $ws2
   bindsym $mod+3 workspace $ws3
   # (continue for all workspaces)
   
   # Move focused container to workspace
   bindsym $mod+Shift+1 move container to workspace $ws1
   bindsym $mod+Shift+2 move container to workspace $ws2
   bindsym $mod+Shift+3 move container to workspace $ws3
   # (continue for all workspaces)
   ```

4. **Create a window manager cheat sheet**:
   Create a text file with all your custom keybindings for easy reference while you're learning:
   ```bash
   mkdir -p ~/cheatsheets
   touch ~/cheatsheets/i3-cheatsheet.txt
   
   # Add your keybindings to the cheatsheet
   echo "# i3 Keybindings Cheatsheet
   
   ## Basic Controls
   $mod+Return - Open terminal
   $mod+Shift+q - Close window
   $mod+d - Launch dmenu
   
   ## Window Navigation
   $mod+h/j/k/l - Focus left/down/up/right
   $mod+Shift+h/j/k/l - Move window left/down/up/right
   
   ## Layout Management
   $mod+bar - Split horizontally
   $mod+minus - Split vertically
   $mod+f - Toggle fullscreen
   $mod+s - Stacking layout
   $mod+w - Tabbed layout
   $mod+e - Toggle split layout
   
   ## Workspace Management
   $mod+1-9 - Switch to workspace 1-9
   $mod+Shift+1-9 - Move window to workspace 1-9
   
   ## System Controls
   $mod+Shift+c - Reload configuration
   $mod+Shift+r - Restart i3
   $mod+Shift+e - Exit i3
   " > ~/cheatsheets/i3-cheatsheet.txt
   ```

5. **Test your configuration**:
   Log out, select i3 or bspwm as your window manager, and log back in. Try your configured keybindings to ensure they work as expected.

## Tmux Mastery Challenge

Develop proficiency with tmux for terminal multiplexing and session management.

### Tasks:

1. **Install and configure tmux**:
   ```bash
   # Install tmux
   sudo pacman -S tmux
   
   # Create basic configuration file
   touch ~/.tmux.conf
   
   # Add basic configuration
   echo "# Change prefix from Ctrl+b to Ctrl+a
   unbind C-b
   set -g prefix C-a
   bind C-a send-prefix
   
   # Split panes using | and -
   bind | split-window -h
   bind - split-window -v
   unbind '\"'
   unbind %
   
   # Switch panes using Alt-arrow without prefix
   bind -n M-Left select-pane -L
   bind -n M-Right select-pane -R
   bind -n M-Up select-pane -U
   bind -n M-Down select-pane -D
   
   # Enable mouse mode (tmux 2.1+)
   set -g mouse on
   
   # Vim-style pane navigation
   bind h select-pane -L
   bind j select-pane -D
   bind k select-pane -U
   bind l select-pane -R
   
   # Reload config file
   bind r source-file ~/.tmux.conf \; display '~/.tmux.conf reloaded'
   
   # Set windows and panes at 1, not 0
   set -g base-index 1
   setw -g pane-base-index 1
   
   # Enable vi mode keys
   setw -g mode-keys vi
   
   # Set terminal color
   set -g default-terminal 'screen-256color'" > ~/.tmux.conf
   ```

2. **Session management practice**:
   ```bash
   # Create a new named session
   tmux new -s dev
   
   # Detach from the session (prefix + d)
   
   # Create another named session
   tmux new -s notes
   
   # Detach from the session (prefix + d)
   
   # List all sessions
   tmux ls
   
   # Attach to the dev session
   tmux attach -t dev
   
   # Switch to the notes session without detaching
   # Press prefix + s, then select the session
   ```

3. **Window and pane manipulation exercise**:
   ```bash
   # Start a new tmux session
   tmux new -s practice
   
   # Create three windows (press prefix + c twice)
   # Name them: code, docs, terminal (prefix + ,)
   
   # In the 'code' window, split into three panes
   # One horizontal split (prefix + -)
   # Then split the bottom pane vertically (prefix + |)
   
   # In the 'docs' window, create a 2x2 grid of panes
   # Split horizontally, then split each pane vertically
   
   # Practice moving between panes using prefix + h/j/k/l
   
   # Practice moving between windows using prefix + n/p
   
   # Try resizing panes (prefix + H/J/K/L if configured)
   ```

4. **Create a productive tmux workspace**:
   ```bash
   # Create a shell script to set up your development environment
   touch ~/bin/dev-workspace.sh
   chmod +x ~/bin/dev-workspace.sh
   
   # Add the following script content
   echo '#!/bin/bash
   
   # Create or attach to "dev" session
   if tmux has-session -t dev 2>/dev/null; then
     tmux attach -t dev
     exit
   fi
   
   # Create a new session
   tmux new-session -d -s dev -n editor
   
   # Set up editor window
   tmux send-keys -t dev:editor "cd ~/projects" C-m
   tmux send-keys -t dev:editor "vim" C-m
   
   # Create a terminal window with three panes
   tmux new-window -t dev:2 -n terminal
   tmux split-window -t dev:terminal -h
   tmux split-window -t dev:terminal.1 -v
   
   # Set up the panes
   tmux send-keys -t dev:terminal.0 "cd ~/projects" C-m
   tmux send-keys -t dev:terminal.1 "cd ~/projects && git status" C-m
   tmux send-keys -t dev:terminal.2 "htop" C-m
   
   # Create a notes window
   tmux new-window -t dev:3 -n notes
   tmux send-keys -t dev:notes "cd ~/notes && vim todo.md" C-m
   
   # Select the editor window
   tmux select-window -t dev:editor
   
   # Attach to the session
   tmux attach -t dev' > ~/bin/dev-workspace.sh
   
   # Test your script
   ~/bin/dev-workspace.sh
   ```

5. **Learn copy mode and text selection**:
   ```bash
   # Start a new tmux session
   tmux new -s copy-practice
   
   # Create some text to practice with
   echo "This is line 1
   This is line 2
   This is line 3
   This is line 4
   This is line 5" > practice.txt
   
   # Display the file
   cat practice.txt
   
   # Enter copy mode (prefix + [)
   # Navigate using vi keys (h/j/k/l)
   # Start selection (v in vi mode)
   # Copy selected text (y in vi mode)
   # Paste the text (prefix + ])
   ```

## Neovim Configuration and Usage Marathon

Build a personalized Neovim configuration and develop essential editing skills.

### Tasks:

1. **Install Neovim and dependencies**:
   ```bash
   # Install Neovim and dependencies
   sudo pacman -S neovim python-pynvim nodejs npm ripgrep fd git
   
   # Create Neovim configuration directory
   mkdir -p ~/.config/nvim/lua/plugins
   ```

2. **Set up a package manager**:
   ```bash
   # Install packer.nvim
   git clone https://github.com/wbthomason/packer.nvim \
     ~/.local/share/nvim/site/pack/packer/start/packer.nvim
   
   # Create initial configuration
   touch ~/.config/nvim/init.lua
   
   # Add basic configuration
   echo "-- Load plugins
   require('plugins')
   
   -- Basic settings
   vim.opt.number = true
   vim.opt.relativenumber = true
   vim.opt.expandtab = true
   vim.opt.shiftwidth = 2
   vim.opt.tabstop = 2
   vim.opt.smartindent = true
   vim.opt.wrap = false
   vim.opt.ignorecase = true
   vim.opt.smartcase = true
   vim.opt.cursorline = true
   vim.opt.termguicolors = true
   vim.opt.background = 'dark'
   vim.opt.signcolumn = 'yes'
   vim.opt.backup = false
   vim.opt.writebackup = false
   vim.opt.updatetime = 300
   vim.opt.timeoutlen = 500
   vim.opt.clipboard = 'unnamedplus'
   
   -- Set leader key to space
   vim.g.mapleader = ' '
   
   -- Essential keybindings
   vim.keymap.set('n', '<leader>e', ':Explore<CR>')
   vim.keymap.set('n', '<C-h>', '<C-w>h')
   vim.keymap.set('n', '<C-j>', '<C-w>j')
   vim.keymap.set('n', '<C-k>', '<C-w>k')
   vim.keymap.set('n', '<C-l>', '<C-w>l')
   
   -- File operations
   vim.keymap.set('n', '<leader>w', ':w<CR>')
   vim.keymap.set('n', '<leader>q', ':q<CR>')
   vim.keymap.set('n', '<leader>x', ':x<CR>')
   
   -- Buffer navigation
   vim.keymap.set('n', '<leader>bn', ':bnext<CR>')
   vim.keymap.set('n', '<leader>bp', ':bprevious<CR>')
   vim.keymap.set('n', '<leader>bd', ':bdelete<CR>')
   
   -- Window management
   vim.keymap.set('n', '<leader>sv', ':vsplit<CR>')
   vim.keymap.set('n', '<leader>sh', ':split<CR>')
   
   -- Search improvements
   vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>')" > ~/.config/nvim/init.lua
   
   # Create plugins file
   touch ~/.config/nvim/lua/plugins.lua
   
   # Add plugin configuration
   echo "return require('packer').startup(function(use)
     -- Packer can manage itself
     use 'wbthomason/packer.nvim'
     
     -- Themes
     use 'folke/tokyonight.nvim'
     
     -- Status line
     use {
       'nvim-lualine/lualine.nvim',
       requires = { 'kyazdani42/nvim-web-devicons', opt = true }
     }
     
     -- File explorer
     use {
       'kyazdani42/nvim-tree.lua',
       requires = 'kyazdani42/nvim-web-devicons'
     }
     
     -- Fuzzy finder
     use {
       'nvim-telescope/telescope.nvim',
       requires = { {'nvim-lua/plenary.nvim'} }
     }
     
     -- LSP
     use 'neovim/nvim-lspconfig'
     
     -- Autocompletion
     use 'hrsh7th/nvim-cmp'
     use 'hrsh7th/cmp-nvim-lsp'
     use 'hrsh7th/cmp-buffer'
     use 'hrsh7th/cmp-path'
     
     -- Snippets
     use 'L3MON4D3/LuaSnip'
     use 'saadparwaiz1/cmp_luasnip'
     
     -- Treesitter
     use {
       'nvim-treesitter/nvim-treesitter',
       run = ':TSUpdate'
     }
   end)" > ~/.config/nvim/lua/plugins.lua
   
   # Create plugin configurations directory
   mkdir -p ~/.config/nvim/after/plugin
   
   # Install plugins
   nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
   ```

3. **Create plugin configuration files**:
   ```bash
   # Create lualine configuration
   echo "require('lualine').setup {
     options = {
       theme = 'tokyonight',
       component_separators = { left = '|', right = '|'},
       section_separators = { left = '', right = ''},
     }
   }" > ~/.config/nvim/after/plugin/lualine.lua
   
   # Create nvim-tree configuration
   echo "require('nvim-tree').setup {
     view = {
       width = 30,
     },
     renderer = {
       group_empty = true,
     },
   }
   
   vim.keymap.set('n', '<leader>t', ':NvimTreeToggle<CR>')" > ~/.config/nvim/after/plugin/nvim-tree.lua
   
   # Create telescope configuration
   echo "local telescope = require('telescope')
   telescope.setup {}
   
   local builtin = require('telescope.builtin')
   vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
   vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
   vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
   vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})" > ~/.config/nvim/after/plugin/telescope.lua
   
   # Create treesitter configuration
   echo "require('nvim-treesitter.configs').setup {
     ensure_installed = { 'c', 'lua', 'vim', 'python', 'javascript', 'typescript', 'bash' },
     highlight = {
       enable = true,
     },
   }" > ~/.config/nvim/after/plugin/treesitter.lua
   
   # Create LSP and completion configuration
   echo "local lspconfig = require('lspconfig')
   local capabilities = require('cmp_nvim_lsp').default_capabilities()
   
   -- Set up LSP servers
   lspconfig.pyright.setup { capabilities = capabilities }
   lspconfig.tsserver.setup { capabilities = capabilities }
   lspconfig.bashls.setup { capabilities = capabilities }
   
   -- Global mappings
   vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
   vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
   vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
   vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)
   
   -- Use LspAttach autocommand to only map the following keys
   -- after the language server attaches to the current buffer
   vim.api.nvim_create_autocmd('LspAttach', {
     group = vim.api.nvim_create_augroup('UserLspConfig', {}),
     callback = function(ev)
       -- Buffer local mappings
       local opts = { buffer = ev.buf }
       vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
       vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
       vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
       vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
       vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
       vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
       vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
       vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
     end,
   })
   
   -- Set up nvim-cmp
   local cmp = require'cmp'
   local luasnip = require'luasnip'
   
   cmp.setup({
     snippet = {
       expand = function(args)
         luasnip.lsp_expand(args.body)
       end,
     },
     mapping = cmp.mapping.preset.insert({
       ['<C-b>'] = cmp.mapping.scroll_docs(-4),
       ['<C-f>'] = cmp.mapping.scroll_docs(4),
       ['<C-Space>'] = cmp.mapping.complete(),
       ['<C-e>'] = cmp.mapping.abort(),
       ['<CR>'] = cmp.mapping.confirm({ select = true }),
       ['<Tab>'] = cmp.mapping(function(fallback)
         if cmp.visible() then
           cmp.select_next_item()
         elseif luasnip.expand_or_jumpable() then
           luasnip.expand_or_jump()
         else
           fallback()
         end
       end, { 'i', 's' }),
       ['<S-Tab>'] = cmp.mapping(function(fallback)
         if cmp.visible() then
           cmp.select_prev_item()
         elseif luasnip.jumpable(-1) then
           luasnip.jump(-1)
         else
           fallback()
         end
       end, { 'i', 's' }),
     }),
     sources = cmp.config.sources({
       { name = 'nvim_lsp' },
       { name = 'luasnip' },
     }, {
       { name = 'buffer' },
       { name = 'path' },
     })
   })" > ~/.config/nvim/after/plugin/lsp.lua
   
   # Create theme configuration
   echo "require('tokyonight').setup({
     style = 'storm',
     transparent = false,
     terminal_colors = true,
   })
   
   vim.cmd[[colorscheme tokyonight]]" > ~/.config/nvim/after/plugin/theme.lua
   ```

4. **Create Neovim cheat sheet**:
   ```bash
   echo "# Neovim Keybindings Cheatsheet

   ## General
   - Space - Leader key
   - :q - Quit
   - :w - Save
   - :wq or :x - Save and quit
   - <leader>w - Save
   - <leader>q - Quit
   - <leader>x - Save and quit
   
   ## Navigation
   - h/j/k/l - Left/down/up/right
   - w/b - Next/previous word
   - e - End of word
   - 0/$ - Start/end of line
   - gg/G - Top/bottom of file
   - Ctrl+o/i - Jump backward/forward
   - :{number} - Go to line number
   
   ## Editing
   - i - Insert mode
   - a - Append
   - A - Append at end of line
   - o/O - Insert new line below/above
   - d{motion} - Delete (e.g., dw, dd)
   - c{motion} - Change (e.g., cw, cc)
   - y{motion} - Yank/copy (e.g., yw, yy)
   - p/P - Paste after/before
   - u - Undo
   - Ctrl+r - Redo
   
   ## Window Management
   - <leader>sv - Split vertically
   - <leader>sh - Split horizontally
   - Ctrl+h/j/k/l - Navigate between windows
   
   ## Buffer Management
   - <leader>bn - Next buffer
   - <leader>bp - Previous buffer
   - <leader>bd - Delete buffer
   
   ## File Navigation
   - <leader>e - File explorer
   - <leader>t - NvimTree toggle
   
   ## Telescope
   - <leader>ff - Find files
   - <leader>fg - Live grep
   - <leader>fb - Buffers
   - <leader>fh - Help tags
   
   ## LSP
   - gd - Go to definition
   - gD - Go to declaration
   - K - Hover information
   - <leader>rn - Rename
   - <leader>ca - Code action
   - gr - References
   - [d/]d - Previous/next diagnostic" > ~/cheatsheets/neovim-cheatsheet.txt
   ```

5. **Editing exercises**:
   ```bash
   # Create a practice file
   mkdir -p ~/practice
   cd ~/practice
   
   # Create a practice file for editing
   cat > editing-practice.txt << EOF
   # Neovim Editing Practice
   
   ## Exercise 1: Text Navigation
   Navigate to each marked position (X) using efficient commands
   Start here: X
   
   This is a X paragraph with some text.
   Navigate efficiently X between words and lines.
   The goal is to minimize X keystrokes.
   
   X Another paragraph starts here.
   Practice jumping X between paragraphs quickly.
   
   ## Exercise 2: Text Manipulation
   
   1. Delete this entire line.
   2. Change this word only: CHANGE-ME
   3. Replace this sentence with your name.
   4. Fix thes speling msitakes.
   5. Convert this line to UPPERCASE.
   
   ## Exercise 3: Advanced Editing
   
   - Indent this block of text
     - And this nested list
     - Practice proper indentation
       - At multiple levels
   
   ## Exercise 4: Copy/Paste Practice
   
   Cut this line and paste it after the next paragraph.
   
   This is the next paragraph.
   Paste the cut line here.
   
   Copy this line without cutting it.
   And paste it here: 
   EOF
   
   # Open the file in Neovim and practice the exercises
   nvim editing-practice.txt
   ```

## Terminal Applications Marathon

Practice using terminal-based applications for daily computing tasks.

### Tasks:

1. **Install terminal applications**:
   ```bash
   # Install terminal applications
   sudo pacman -S ranger w3m neomutt lynx cmus mpv zathura newsboat

   # Create configuration directories
   mkdir -p ~/.config/ranger ~/.config/cmus ~/.config/zathura
   ```

2. **Configure Ranger file manager**:
   ```bash
   # Generate default configuration
   ranger --copy-config=all
   
   # Edit rc.conf to enable previews
   sed -i 's/set preview_images false/set preview_images true/' ~/.config/ranger/rc.conf
   sed -i 's/set preview_images_method w3m/set preview_images_method kitty/' ~/.config/ranger/rc.conf
   
   # Create ranger exercise directory
   mkdir -p ~/ranger-exercise/{images,documents,code,archives}
   
   # Create sample files
   touch ~/ranger-exercise/code/{script.py,notes.md,config.json}
   echo "# Sample Python Script
   
   def hello_world():
       print('Hello from your terminal-centric workflow!')
       
   if __name__ == '__main__':
       hello_world()" > ~/ranger-exercise/code/script.py
   
   echo "# Markdown Notes
   
   This is a sample markdown file for practicing with ranger.
   
   ## Features to try
   
   - File operations
   - Tagging
   - Searching
   - Bulk renaming" > ~/ranger-exercise/code/notes.md
   
   # Create ranger practice tasks
   echo "# Ranger Practice Tasks
   
   1. Navigate to ~/ranger-exercise
   2. Create a new directory called 'music'
   3. Copy script.py to the 'music' directory
   4. Rename notes.md to README.md
   5. Create a new file called TODO.txt
   6. Select multiple files and copy them to 'documents'
   7. Use search to find files containing 'sample'
   8. Use visual mode to select and delete files
   9. Use tagging to mark several files
   10. Sort files by different criteria (size, type, etc.)
   " > ~/ranger-practice.txt
   ```

3. **Media playback exercise**:
   ```bash
   # Create music directory
   mkdir -p ~/music-practice
   
   # Create sample playlist file
   echo "# CMUS Playlist Practice
   
   To add your own music to cmus:
   
   1. Open cmus with the command 'cmus'
   2. Press 5 to go to the file browser
   3. Navigate to your music directory
   4. Press a to add the selected file/directory to the library
   5. Press 1 to go back to the library view
   
   Basic controls:
   - c: pause/play
   - b: next track
   - z: previous track
   - s: toggle shuffle
   - v: stop playback
   - x: restart track
   - -/+: decrease/increase volume
   - /: search
   - q: quit view/cmus
   " > ~/music-practice/cmus-guide.txt
   
   # Create MPV practice file
   echo "# MPV Practice Commands
   
   Basic MPV controls:
   
   - Space: Play/Pause
   - q: Quit
   - f: Toggle fullscreen
   - 9/0: Decrease/increase volume
   - [/]: Decrease/increase playback speed
   - Left/Right: Seek backwards/forwards
   - ,/.: Previous/next frame (while paused)
   - m: Mute
   " > ~/music-practice/mpv-guide.txt
   ```

4. **Terminal web browsing exercise**:
   ```bash
   # Create w3m practice directory
   mkdir -p ~/web-practice
   
   # Create w3m guide file
   echo "# W3M Practice Guide
   
   Basic controls:
   
   - Arrow keys: Navigate
   - Enter: Follow link
   - B: Go back
   - q: Quit
   - /: Search
   - n: Next search result
   - Tab: Next link
   - Shift+Tab: Previous link
   - s: History
   - U: Go to URL
   - ESC+b: Add bookmark
   - ESC+l: Show bookmarks
   
   Practice sites:
   
   - https://lite.duckduckgo.com
   - https://text.npr.org
   - https://news.ycombinator.com
   - https://old.reddit.com
   " > ~/web-practice/w3m-guide.txt
   
   # Create lynx guide file
   echo "# Lynx Practice Guide
   
   Basic controls:
   
   - Arrow keys: Navigate
   - Right arrow/Enter: Follow link
   - Left arrow: Go back
   - q: Quit (followed by y to confirm)
   - /: Search
   - n: Next search result
   - g: Go to URL
   - a: Add bookmark
   - v: View bookmarks
   - h: Help
   
   Try browsing these sites:
   
   - https://lite.duckduckgo.com
   - https://text.npr.org
   - https://old.reddit.com
   " > ~/web-practice/lynx-guide.txt
   ```

5. **Document viewing exercise**:
   ```bash
   # Create Zathura practice directory
   mkdir -p ~/pdf-practice
   
   # Create Zathura guide file
   echo "# Zathura Practice Guide
   
   Basic controls:
   
   - j/k: Scroll down/up
   - h/l: Scroll left/right
   - Space/Shift+Space: Scroll full page down/up
   - a: Fit to width
   - s: Fit to height
   - /: Search
   - n/N: Next/previous search result
   - Tab: Index
   - f: Fullscreen
   - r: Rotate
   - +/-: Zoom in/out
   - q: Quit
   
   Find a PDF document to practice with.
   " > ~/pdf-practice/zathura-guide.txt
   ```

6. **Create a terminal workflow script**:
   ```bash
   # Create a script to launch your terminal workflow
   touch ~/bin/terminal-workflow.sh
   chmod +x ~/bin/terminal-workflow.sh
   
   # Add script content
   echo '#!/bin/bash
   
   # Terminal workflow launcher script
   TERMINAL="alacritty"
   
   # Function to check if a command exists
   command_exists() {
     command -v "$1" >/dev/null 2>&1
   }
   
   # Launch applications based on argument
   case "$1" in
     "files")
       if command_exists ranger; then
         $TERMINAL -e ranger
       else
         echo "Ranger is not installed"
       fi
       ;;
     "music")
       if command_exists cmus; then
         $TERMINAL -e cmus
       else
         echo "cmus is not installed"
       fi
       ;;
     "web")
       if command_exists w3m; then
         $TERMINAL -e w3m https://lite.duckduckgo.com
       else
         echo "w3m is not installed"
       fi
       ;;
     "mail")
       if command_exists neomutt; then
         $TERMINAL -e neomutt
       else
         echo "neomutt is not installed"
       fi
       ;;
     "editor")
       if command_exists nvim; then
         $TERMINAL -e nvim
       else
         echo "Neovim is not installed"
       fi
       ;;
     "media")
       if command_exists mpv; then
         # You can replace this with a specific media file
         read -p "Enter path to media file: " media_file
         mpv "$media_file"
       else
         echo "mpv is not installed"
       fi
       ;;
     "pdf")
       if command_exists zathura; then
         read -p "Enter path to PDF file: " pdf_file
         zathura "$pdf_file" &
       else
         echo "zathura is not installed"
       fi
       ;;
     *)
       echo "Usage: terminal-workflow.sh [option]"
       echo "Options:"
       echo "  files  - Open file manager (ranger)"
       echo "  music  - Open music player (cmus)"
       echo "  web    - Open web browser (w3m)"
       echo "  mail   - Open email client (neomutt)"
       echo "  editor - Open text editor (neovim)"
       echo "  media  - Open media player (mpv)"
       echo "  pdf    - Open PDF viewer (zathura)"
       ;;
   esac' > ~/bin/terminal-workflow.sh
   ```

## 30-Day Mouseless Challenge

A month-long structured program to eliminate mouse dependency.

### Phase 1: Preparation (Days 1-5)

1. **Day 1: Environment Setup**
   ```bash
   # Create a 30-day challenge tracker
   mkdir -p ~/mouseless-challenge
   
   # Create tracking file
   echo "# 30-Day Mouseless Challenge Log
   
   ## Phase 1: Preparation (Days 1-5)
   
   - [ ] Day 1: Environment Setup
   - [ ] Day 2: Basic Window Manager Navigation
   - [ ] Day 3: Terminal Navigation Basics
   - [ ] Day 4: Text Editor Basics
   - [ ] Day 5: File Management Basics
   
   ## Phase 2: Application Mastery (Days 6-15)
   
   - [ ] Day 6: Advanced Window Manager Techniques
   - [ ] Day 7: Tmux Deep Dive
   - [ ] Day 8: Vim/Neovim Editing Patterns
   - [ ] Day 9: Terminal File Management
   - [ ] Day 10: Web Browsing in Terminal
   - [ ] Day 11: Email in Terminal
   - [ ] Day 12: Document Viewing
   - [ ] Day 13: Media Management
   - [ ] Day 14: CLI Productivity Tools
   - [ ] Day 15: Custom Keybindings Refinement
   
   ## Phase 3: Workflow Integration (Days 16-25)
   
   - [ ] Day 16: Combined Workflows: Development
   - [ ] Day 17: Combined Workflows: Writing
   - [ ] Day 18: Combined Workflows: System Administration
   - [ ] Day 19: Combined Workflows: Web Research
   - [ ] Day 20: Keyboard Shortcut Efficiency
   - [ ] Day 21: Speed Challenges
   - [ ] Day 22: Mouseless for 24 Hours
   - [ ] Day 23: Workflow Customization
   - [ ] Day 24: Workflow Automation
   - [ ] Day 25: Mouseless Troubleshooting
   
   ## Phase 4: Mastery (Days 26-30)
   
   - [ ] Day 26: Full Day With No Mouse
   - [ ] Day 27: Full Day With No Mouse
   - [ ] Day 28: Full Day With No Mouse
   - [ ] Day 29: Full Day With No Mouse
   - [ ] Day 30: Challenge Completion & Reflection
   " > ~/mouseless-challenge/tracker.md
   
   # Create a log file
   echo "# Mouseless Challenge Daily Log
   
   ## Day 1
   
   Date: $(date +%Y-%m-%d)
   
   Goals:
   - Set up window manager
   - Configure terminal
   - Install necessary applications
   - Create cheat sheets for reference
   
   Accomplishments:
   - 
   
   Challenges:
   - 
   
   Notes:
   - 
   " > ~/mouseless-challenge/daily-log.md
   ```

2. **Create daily challenge tasks**:
   ```bash
   # Create a file with daily challenges
   echo "# 30-Day Mouseless Challenge: Daily Tasks
   
   ## Phase 1: Preparation (Days 1-5)
   
   ### Day 1: Environment Setup
   - Install and configure window manager
   - Set up terminal emulator
   - Create cheatsheets for keybindings
   - Disable mouse/touchpad for 30 minutes
   
   ### Day 2: Basic Window Manager Navigation
   - Practice opening applications with keybindings
   - Navigate between workspaces using keyboard only
   - Move windows between workspaces
   - Resize windows with keyboard
   - Disable mouse for 1 hour
   
   ### Day 3: Terminal Navigation Basics
   - Practice command history navigation
   - Use tab completion extensively
   - Navigate and edit command line with shortcuts
   - Create 3 custom shell aliases for common tasks
   - Disable mouse for 2 hours
   
   ### Day 4: Text Editor Basics
   - Complete the Vim/Neovim tutor
   - Practice basic editing operations
   - Create a configuration file from scratch
   - Practice navigating between files
   - Disable mouse for 3 hours
   
   ### Day 5: File Management Basics
   - Use ranger or another terminal file manager exclusively
   - Practice file operations (copy, move, delete)
   - Set up file previews
   - Create bookmarks for common directories
   - Disable mouse for 4 hours
   
   ## Phase 2: Application Mastery (Days 6-15)
   
   ### Day 6: Advanced Window Manager Techniques
   - Create and use scratchpad windows
   - Set up and use different layouts
   - Configure application-specific settings
   - Practice window stacking operations
   - Disable mouse for half a day
   
   ### Day 7: Tmux Deep Dive
   - Create multiple sessions for different projects
   - Practice window and pane management
   - Use copy mode to select and paste text
   - Customize status bar
   - Disable mouse for half a day
   
   ### Day 8: Vim/Neovim Editing Patterns
   - Practice text objects (words, paragraphs, etc.)
   - Use macros for repetitive tasks
   - Practice search and replace operations
   - Use multiple buffers effectively
   - Disable mouse for half a day
   
   ### Day 9: Terminal File Management
   - Process batches of files
   - Use advanced search techniques
   - Practice bulk renaming
   - Set up custom commands
   - Disable mouse for half a day
   
   ### Day 10: Web Browsing in Terminal
   - Use w3m or lynx for all web browsing
   - Practice efficient link navigation
   - Set up bookmarks
   - Configure custom keybindings
   - Disable mouse for half a day
   
   ### Day 11: Email in Terminal
   - Configure and use neomutt
   - Practice mailbox navigation
   - Create and send emails
   - Manage attachments
   - Disable mouse for half a day
   
   ### Day 12: Document Viewing
   - Use zathura for PDF viewing
   - Practice document navigation
   - Configure appearance settings
   - Set up keybindings
   - Disable mouse for half a day
   
   ### Day 13: Media Management
   - Use cmus or mpv for media playback
   - Create and manage playlists
   - Practice playback controls
   - Configure visualization options
   - Disable mouse for half a day
   
   ### Day 14: CLI Productivity Tools
   - Set up and use a CLI calendar
   - Configure a task manager
   - Use a note-taking system
   - Practice moving between tools
   - Disable mouse for half a day
   
   ### Day 15: Custom Keybindings Refinement
   - Review all application keybindings
   - Make adjustments for ergonomics and efficiency
   - Create a unified system for similar operations
   - Document your personal keybinding system
   - Disable mouse for half a day
   
   ## Phase 3: Workflow Integration (Days 16-25)
   
   ### Day 16: Combined Workflows: Development
   - Set up a full development environment
   - Use tmux + vim + git + compiler/interpreter
   - Complete a small coding project
   - Disable mouse for full day
   
   ### Day 17: Combined Workflows: Writing
   - Set up a writing environment
   - Use vim + spell checking + markdown preview
   - Write a 500+ word document
   - Disable mouse for full day
   
   ### Day 18: Combined Workflows: System Administration
   - Monitor system resources
   - Manage users and permissions
   - Configure services
   - View and analyze logs
   - Disable mouse for full day
   
   ### Day 19: Combined Workflows: Web Research
   - Use terminal browsers and search tools
   - Take notes in Vim
   - Save and organize information
   - Disable mouse for full day
   
   ### Day 20: Keyboard Shortcut Efficiency
   - Time yourself on common tasks
   - Identify and eliminate bottlenecks
   - Create new shortcuts for frequent operations
   - Disable mouse for full day
   
   ### Day 21: Speed Challenges
   - Complete timed challenges for editing
   - Race against previous times for navigation
   - Optimize slowest operations
   - Disable mouse for full day
   
   ### Day 22: Mouseless for 24 Hours
   - Use only keyboard for all computing tasks
   - Document frustrations and workarounds
   - Identify remaining gaps in workflow
   
   ### Day 23: Workflow Customization
   - Create custom scripts for common tasks
   - Set up application launchers
   - Configure global keyboard shortcuts
   - Disable mouse for full day
   
   ### Day 24: Workflow Automation
   - Set up automated tasks
   - Create template systems
   - Configure triggers for common sequences
   - Disable mouse for full day
   
   ### Day 25: Mouseless Troubleshooting
   - Practice diagnosing and fixing issues without a mouse
   - Create contingency plans for mouse-dependent scenarios
   - Document solutions to common problems
   - Disable mouse for full day
   
   ## Phase 4: Mastery (Days 26-30)
   
   ### Day 26-29: Full Days With No Mouse
   - Complete all computing tasks without a mouse
   - Continue refining workflow
   - Document improvements and challenges
   
   ### Day 30: Challenge Completion & Reflection
   - Review the entire challenge
   - Document lessons learned
   - Measure improvements in efficiency
   - Create a sustainment plan
   " > ~/mouseless-challenge/daily-tasks.md
   ```

3. **Set up challenge timer script**:
   ```bash
   touch ~/bin/mouse-block.sh
   chmod +x ~/bin/mouse-block.sh
   
   echo '#!/bin/bash
   
   # Mouse blocking script for Mouseless Challenge
   
   # Check if running as root
   if [ "$EUID" -ne 0 ]; then
     echo "Please run as root"
     exit 1
   fi
   
   case "$1" in
     "disable")
       # Disable all mouse and touchpad inputs
       xinput list | grep -i -E "mouse|touchpad" | grep -o "id=[0-9]*" | grep -o "[0-9]*" | xargs -I{} xinput disable {}
       echo "Mouse and touchpad disabled. Use keyboard to navigate."
       echo "To re-enable, run: sudo $0 enable"
       ;;
     "enable")
       # Re-enable all mouse and touchpad inputs
       xinput list | grep -i -E "mouse|touchpad" | grep -o "id=[0-9]*" | grep -o "[0-9]*" | xargs -I{} xinput enable {}
       echo "Mouse and touchpad enabled."
       ;;
     "timer")
       if [ -z "$2" ]; then
         echo "Please specify a duration in minutes."
         echo "Usage: $0 timer <minutes>"
         exit 1
       fi
       
       duration=$2
       echo "Disabling mouse and touchpad for $duration minutes..."
       xinput list | grep -i -E "mouse|touchpad" | grep -o "id=[0-9]*" | grep -o "[0-9]*" | xargs -I{} xinput disable {}
       
       # Display countdown
       end_time=$(( $(date +%s) + duration * 60 ))
       while [ $(date +%s) -lt $end_time ]; do
         time_left=$(( end_time - $(date +%s) ))
         minutes=$(( time_left / 60 ))
         seconds=$(( time_left % 60 ))
         echo -ne "Mouse disabled. Time remaining: ${minutes}m ${seconds}s\r"
         sleep 1
       done
       
       # Re-enable devices
       xinput list | grep -i -E "mouse|touchpad" | grep -o "id=[0-9]*" | grep -o "[0-9]*" | xargs -I{} xinput enable {}
       echo -e "\nTime up! Mouse and touchpad re-enabled."
       ;;
     *)
       echo "Usage: $0 [disable|enable|timer <minutes>]"
       echo "  disable - Disable mouse and touchpad"
       echo "  enable - Re-enable mouse and touchpad"
       echo "  timer <minutes> - Disable for specified minutes"
       ;;
   esac' > ~/bin/mouse-block.sh
   ```

### Phase 2: Challenge Tracking

1. **Create progress visualization**:
   ```bash
   # Create a script to visualize progress
   touch ~/bin/challenge-progress.sh
   chmod +x ~/bin/challenge-progress.sh
   
   echo '#!/bin/bash
   
   # Mouseless Challenge progress tracker
   
   TRACKER_FILE="$HOME/mouseless-challenge/tracker.md"
   
   if [ ! -f "$TRACKER_FILE" ]; then
     echo "Tracker file not found at $TRACKER_FILE"
     exit 1
   fi
   
   # Count completed items
   TOTAL_DAYS=30
   COMPLETED=$(grep -c "^\- \[x\]" "$TRACKER_FILE")
   PERCENTAGE=$((COMPLETED * 100 / TOTAL_DAYS))
   
   # Display progress bar
   echo "Mouseless Challenge Progress: $COMPLETED/$TOTAL_DAYS days ($PERCENTAGE%)"
   
   BAR_LENGTH=50
   FILLED=$((BAR_LENGTH * COMPLETED / TOTAL_DAYS))
   
   printf "["
   for ((i=0; i<BAR_LENGTH; i++)); do
     if [ $i -lt $FILLED ]; then
       printf "#"
     else
       printf " "
     fi
   done
   printf "] $PERCENTAGE%%\n"
   
   # Display current phase
   if [ $COMPLETED -lt 5 ]; then
     echo "Current Phase: Preparation (Days 1-5)"
   elif [ $COMPLETED -lt 15 ]; then
     echo "Current Phase: Application Mastery (Days 6-15)"
   elif [ $COMPLETED -lt 25 ]; then
     echo "Current Phase: Workflow Integration (Days 16-25)"
   else
     echo "Current Phase: Mastery (Days 26-30)"
   fi
   
   # If not completed, show next task
   if [ $COMPLETED -lt $TOTAL_DAYS ]; then
     NEXT_DAY=$((COMPLETED + 1))
     echo -e "\nNext task:"
     grep -A 2 "Day $NEXT_DAY:" "$HOME/mouseless-challenge/daily-tasks.md" | tail -n 2
   else
     echo -e "\nChallenge completed! Congratulations on becoming mouseless!"
   fi' > ~/bin/challenge-progress.sh
   ```

2. **Create daily log update script**:
   ```bash
   touch ~/bin/log-challenge-day.sh
   chmod +x ~/bin/log-challenge-day.sh
   
   echo '#!/bin/bash
   
   # Daily challenge log script
   
   LOG_FILE="$HOME/mouseless-challenge/daily-log.md"
   TRACKER_FILE="$HOME/mouseless-challenge/tracker.md"
   TASKS_FILE="$HOME/mouseless-challenge/daily-tasks.md"
   
   # Get current day number
   COMPLETED=$(grep -c "^\- \[x\]" "$TRACKER_FILE")
   DAY_NUM=$((COMPLETED + 1))
   
   if [ $DAY_NUM -gt 30 ]; then
     echo "Challenge already completed!"
     exit 0
   fi
   
   # Get daily tasks
   DAY_TASKS=$(grep -A 5 "Day $DAY_NUM:" "$TASKS_FILE" | tail -n 5)
   
   # Update log file
   echo -e "\n## Day $DAY_NUM\n" >> "$LOG_FILE"
   echo "Date: $(date +%Y-%m-%d)" >> "$LOG_FILE"
   echo -e "\nTasks:" >> "$LOG_FILE"
   echo "$DAY_TASKS" >> "$LOG_FILE"
   echo -e "\nAccomplishments:" >> "$LOG_FILE"
   echo "- " >> "$LOG_FILE"
   echo -e "\nChallenges:" >> "$LOG_FILE"
   echo "- " >> "$LOG_FILE"
   echo -e "\nNotes:" >> "$LOG_FILE"
   echo "- " >> "$LOG_FILE"
   echo -e "\nTime spent without mouse: ___ hours" >> "$LOG_FILE"
   
   echo "Day $DAY_NUM log entry created. Please edit $LOG_FILE to complete it."
   echo "When finished with today's challenge, update the tracker by changing [ ] to [x] for Day $DAY_NUM."' > ~/bin/log-challenge-day.sh
   ```

## Terminal AI Integration Project

Develop a terminal-based AI assistant integration to enhance your mouseless workflow. This project helps you leverage AI without breaking your terminal-centric workflow and demonstrates how AI can be incorporated into a keyboard-driven environment.

### Tasks:

1. **Set up environment for AI integration**:
   ```bash
   # Create project directory
   mkdir -p ~/ai-terminal
   
   # Install required Python packages
   pip install --user anthropic requests
   
   # Add API key to your shell configuration
   echo '# Claude API key
   export ANTHROPIC_API_KEY="your_api_key_here"' >> ~/.zshrc
   # Or if using bash
   # echo 'export ANTHROPIC_API_KEY="your_api_key_here"' >> ~/.bashrc
   
   # Source the updated configuration
   source ~/.zshrc # or ~/.bashrc
   ```

2. **Create Claude CLI script**:
   ```bash
   mkdir -p ~/ai-terminal
   touch ~/ai-terminal/claude-cli.py
   chmod +x ~/ai-terminal/claude-cli.py
   
   echo '#!/usr/bin/env python3
   
   import os
   import sys
   import argparse
   import textwrap
   import json
   from datetime import datetime
   
   # Import required libraries
   try:
       from anthropic import Anthropic
   except ImportError:
       print("Anthropic library not installed. Installing now...")
       os.system("pip install --user anthropic")
       from anthropic import Anthropic
   
   # Configure the CLI
   def main():
       parser = argparse.ArgumentParser(description="Command-line interface for Claude AI")
       parser.add_argument("prompt", nargs="*", help="Prompt for Claude")
       parser.add_argument("-f", "--file", help="Read prompt from file")
       parser.add_argument("-c", "--code", action="store_true", help="Focus on code generation")
       parser.add_argument("-s", "--system", help="Custom system prompt")
       parser.add_argument("-m", "--model", default="claude-3-haiku-20240307", 
                           help="Model to use (default: claude-3-haiku-20240307)")
       parser.add_argument("-o", "--output", help="Save response to file")
       parser.add_argument("-l", "--log", action="store_true", help="Log conversation")
       args = parser.parse_args()
   
       # Get API key from environment
       api_key = os.environ.get("ANTHROPIC_API_KEY")
       if not api_key:
           print("Error: ANTHROPIC_API_KEY not set in environment")
           print("Please set it with: export ANTHROPIC_API_KEY=your_api_key")
           sys.exit(1)
   
       # Get prompt from arguments, file, or stdin
       if args.file:
           try:
               with open(args.file, "r") as f:
                   prompt = f.read()
           except FileNotFoundError:
               print(f"Error: File {args.file} not found")
               sys.exit(1)
       elif args.prompt:
           prompt = " ".join(args.prompt)
       else:
           print("Reading prompt from stdin (Ctrl+D to submit)...")
           prompt = sys.stdin.read()
   
       if not prompt:
           print("Error: Empty prompt")
           sys.exit(1)
   
       # Set up system prompt
       if args.code:
           system = "You are a helpful coding assistant. Provide concise, well-commented code with explanations suitable for the terminal. Focus on practical solutions and terminal-friendly output formatting."
       elif args.system:
           system = args.system
       else:
           system = "You are a helpful assistant providing concise responses for terminal use. Format your responses for readability in a terminal environment."
   
       # Create client and get response
       try:
           client = Anthropic(api_key=api_key)
           message = client.messages.create(
               model=args.model,
               max_tokens=4000,
               system=system,
               messages=[{"role": "user", "content": prompt}]
           )
           
           response = message.content[0].text
           
           # Format the response for terminal display
           width = min(os.get_terminal_size().columns, 100)
           wrapped_response = textwrap.fill(response, width=width)
           
           # Print the response
           print(wrapped_response)
           
           # Save to file if requested
           if args.output:
               with open(args.output, "w") as f:
                   f.write(response)
                   print(f"\nResponse saved to {args.output}")
           
           # Log conversation if requested
           if args.log:
               log_dir = os.path.expanduser("~/.claude_logs")
               os.makedirs(log_dir, exist_ok=True)
               
               timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
               log_file = f"{log_dir}/claude_conversation_{timestamp}.json"
               
               log_data = {
                   "timestamp": timestamp,
                   "model": args.model,
                   "system": system,
                   "prompt": prompt,
                   "response": response
               }
               
               with open(log_file, "w") as f:
                   json.dump(log_data, f, indent=2)
                   print(f"\nConversation logged to {log_file}")
               
       except Exception as e:
           print(f"Error: {e}")
           sys.exit(1)
   
   if __name__ == "__main__":
       main()' > ~/ai-terminal/claude-cli.py
   ```

3. **Create Neovim integration for Claude**:
   ```bash
   mkdir -p ~/.config/nvim/lua/plugins/claude
   touch ~/.config/nvim/lua/plugins/claude/init.lua
   
   echo 'local M = {}

   -- Function to send selected text to Claude
   function M.ask_claude()
     -- Get visual selection
     vim.cmd("normal! \"xy")
     local selection = vim.fn.getreg("x")
     
     -- Create temporary file for prompt
     local prompt_file = vim.fn.tempname()
     local file = io.open(prompt_file, "w")
     file:write(selection)
     file:close()
     
     -- Create temporary file for response
     local response_file = vim.fn.tempname()
     
     -- Call Claude CLI
     local cmd = string.format("~/ai-terminal/claude-cli.py -f %s -o %s", vim.fn.shellescape(prompt_file), vim.fn.shellescape(response_file))
     
     -- Create a new split window
     vim.cmd("rightbelow vnew")
     vim.cmd("setlocal buftype=nofile bufhidden=hide noswapfile")
     vim.cmd("file Claude\\ Response")
     
     -- Show loading message
     vim.api.nvim_buf_set_lines(0, 0, -1, false, {"Asking Claude...", "", "This might take a few seconds."})
     
     -- Execute the command
     vim.fn.jobstart(cmd, {
       on_exit = function(_, exit_code)
         if exit_code == 0 then
           -- Read response
           local file = io.open(response_file, "r")
           if file then
             local response = {}
             for line in file:lines() do
               table.insert(response, line)
             end
             file:close()
             
             -- Update buffer with response
             vim.api.nvim_buf_set_lines(0, 0, -1, false, response)
             
             -- Set filetype to markdown for highlighting
             vim.cmd("setlocal filetype=markdown")
           else
             vim.api.nvim_buf_set_lines(0, 0, -1, false, {"Error: Could not read Claude\'s response"})
           end
         else
           vim.api.nvim_buf_set_lines(0, 0, -1, false, {"Error: Claude CLI failed"})
         end
         
         -- Clean up temporary files
         os.remove(prompt_file)
         os.remove(response_file)
       end
     })
   end

   -- Function to insert response at cursor
   function M.ask_claude_inline()
     -- Get visual selection
     vim.cmd("normal! \"xy")
     local selection = vim.fn.getreg("x")
     
     -- Create temporary file for prompt
     local prompt_file = vim.fn.tempname()
     local file = io.open(prompt_file, "w")
     file:write(selection)
     file:close()
     
     -- Create temporary file for response
     local response_file = vim.fn.tempname()
     
     -- Call Claude CLI
     local cmd = string.format("~/ai-terminal/claude-cli.py -f %s -o %s", vim.fn.shellescape(prompt_file), vim.fn.shellescape(response_file))
     
     -- Show message
     vim.api.nvim_echo({{"Asking Claude...", "None"}}, false, {})
     
     -- Execute the command
     vim.fn.jobstart(cmd, {
       on_exit = function(_, exit_code)
         if exit_code == 0 then
           -- Read response
           local file = io.open(response_file, "r")
           if file then
             local response = {}
             for line in file:lines() do
               table.insert(response, line)
             end
             file:close()
             
             -- Insert response at cursor
             vim.api.nvim_put(response, "l", true, true)
             
             vim.api.nvim_echo({{"Claude response inserted", "None"}}, false, {})
           else
             vim.api.nvim_echo({{"Error: Could not read Claude\'s response", "ErrorMsg"}}, false, {})
           end
         else
           vim.api.nvim_echo({{"Error: Claude CLI failed", "ErrorMsg"}}, false, {})
         end
         
         -- Clean up temporary files
         os.remove(prompt_file)
         os.remove(response_file)
       end
     })
   end

   -- Set up keymappings
   function M.setup()
     vim.api.nvim_set_keymap("v", "<leader>c", ":<C-U>lua require(\'plugins.claude\').ask_claude()<CR>", {noremap = true, silent = true})
     vim.api.nvim_set_keymap("v", "<leader>ci", ":<C-U>lua require(\'plugins.claude\').ask_claude_inline()<CR>", {noremap = true, silent = true})
   end

   return M' > ~/.config/nvim/lua/plugins/claude/init.lua
   
   # Add to Neovim initialization
   echo "-- Claude AI integration
   require('plugins.claude').setup()" >> ~/.config/nvim/after/plugin/custom.lua
   ```

4. **Create a tmux Claude integration**:
   ```bash
   touch ~/.tmux-claude.sh
   chmod +x ~/.tmux-claude.sh
   
   echo '#!/bin/bash
   
   # Tmux integration for Claude
   
   # Check if Claude CLI exists
   if [ ! -f ~/ai-terminal/claude-cli.py ]; then
     echo "Claude CLI not found at ~/ai-terminal/claude-cli.py"
     exit 1
   fi
   
   # Check if ANTHROPIC_API_KEY is set
   if [ -z "$ANTHROPIC_API_KEY" ]; then
     echo "Error: ANTHROPIC_API_KEY not set in environment"
     echo "Please set it with: export ANTHROPIC_API_KEY=your_api_key"
     exit 1
   fi
   
   # Create a new tmux pane and run Claude in it
   tmux split-window -h "~/ai-terminal/claude-cli.py"' > ~/.tmux-claude.sh
   
   # Add keybinding to tmux.conf
   echo "# Claude AI integration
   bind-key C run-shell ~/.tmux-claude.sh" >> ~/.tmux.conf
   ```

6. **Create AI integration tests**:
   ```bash
   # Create a test directory
   mkdir -p ~/ai-terminal/tests
   
   # Create a test script
   touch ~/ai-terminal/tests/test-claude-cli.sh
   chmod +x ~/ai-terminal/tests/test-claude-cli.sh
   
   # Add test content
   echo '#!/bin/bash
   
   # Test script for Claude CLI
   
   echo "Testing Claude CLI..."
   
   # Test basic functionality
   echo "Test 1: Basic question"
   ~/ai-terminal/claude-cli.py "What is Linux?"
   
   # Test code generation
   echo -e "\nTest 2: Code generation"
   ~/ai-terminal/claude-cli.py -c "Write a simple Python function to calculate factorial"
   
   # Test custom system prompt
   echo -e "\nTest 3: Custom system prompt"
   ~/ai-terminal/claude-cli.py -s "You are a Linux commands expert. Keep answers under 50 words." "How do I find large files?"
   
   echo -e "\nTests completed."
   ' > ~/ai-terminal/tests/test-claude-cli.sh
   
   # Create a test script for Neovim integration
   touch ~/ai-terminal/tests/test-neovim-integration.md
   
   echo '# Testing Neovim Claude Integration

   1. Open any file in Neovim:
      ```
      nvim test-file.txt
      ```
      
   2. Add some sample text:
      ```
      This is a test file.
      I want to test the Claude integration with Neovim.
      Let me try a simple question:
      How do I configure my tmux status line?
      ```
      
   3. Select the text in visual mode (press v and select with movement keys)
   
   4. Press <leader>c to send to Claude in a split window
   
   5. Try the inline version by selecting different text and pressing <leader>ci
   
   6. Verify that the responses appear correctly
   ' > ~/ai-terminal/tests/test-neovim-integration.md
   ```

5. **Create terminal AI helper script**:
   ```bash
   touch ~/bin/ai-help.sh
   chmod +x ~/bin/ai-help.sh
   
   echo '#!/bin/bash
   
   # Terminal AI helper script
   
   # Check if Claude CLI exists
   if [ ! -f ~/ai-terminal/claude-cli.py ]; then
     echo "Claude CLI not found at ~/ai-terminal/claude-cli.py"
     exit 1
   fi
   
   # Function to show help
   show_help() {
     echo "AI Helper - Terminal assistance with Claude"
     echo ""
     echo "Usage: ai-help.sh [command] [options]"
     echo ""
     echo "Commands:"
     echo "  ask       Ask a general question"
     echo "  explain   Explain a command or concept"
     echo "  code      Generate code for a given task"
     echo "  fix       Fix or debug provided code"
     echo "  shell     Generate a shell command"
     echo "  summary   Summarize provided text"
     echo "  help      Show this help message"
     echo ""
     echo "Examples:"
     echo "  ai-help.sh ask \"How do I set up a cronjob?\""
     echo "  ai-help.sh explain \"awk '{print \$1}'\""
     echo "  ai-help.sh code \"Python script to list files recursively\""
     echo "  ai-help.sh shell \"Find all .jpg files and resize them\""
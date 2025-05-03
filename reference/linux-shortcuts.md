# Linux Mastery Journey - Keyboard Shortcuts & Commands Reference

This comprehensive reference guide provides essential keyboard shortcuts and commands for the tools and environments covered in the Linux Mastery Journey curriculum. Learning these shortcuts will significantly improve your efficiency and workflow.

## Table of Contents

1. [Terminal Basics](#terminal-basics)
2. [File Navigation](#file-navigation)
3. [Text Editors](#text-editors)
   - [Vim/Neovim](#vimneovim)
   - [Emacs](#emacs)
   - [Nano](#nano)
4. [Shell](#shell)
   - [Bash](#bash)
   - [Zsh](#zsh)
5. [Tmux](#tmux)
6. [Window Managers](#window-managers)
   - [i3](#i3)
   - [Sway](#sway)
   - [Hyprland](#hyprland)
7. [Git](#git)
8. [Package Management](#package-management)
9. [System Control](#system-control)
10. [Custom Shortcuts Configuration](#custom-shortcuts-configuration)

## Terminal Basics

| Shortcut | Action |
|----------|--------|
| `Ctrl+C` | Interrupt (kill) current process |
| `Ctrl+Z` | Suspend current process |
| `Ctrl+D` | Send EOF (End-of-file) / Exit shell |
| `Ctrl+L` | Clear screen |
| `Ctrl+A` | Move cursor to beginning of line |
| `Ctrl+E` | Move cursor to end of line |
| `Ctrl+U` | Delete from cursor to beginning of line |
| `Ctrl+K` | Delete from cursor to end of line |
| `Ctrl+W` | Delete the word before the cursor |
| `Ctrl+R` | Search command history |
| `Ctrl+G` | Cancel history search |
| `Alt+.` | Insert last argument of previous command |
| `Ctrl+Alt+T` | Open new terminal (most desktop environments) |
| `Ctrl+Shift+T` | Open new terminal tab |
| `Ctrl+Shift+N` | Open new terminal window |
| `Ctrl+PgUp/PgDn` | Switch between terminal tabs |

## File Navigation

### Command Line Navigation

| Command/Shortcut | Action |
|------------------|--------|
| `cd directory` | Change to specified directory |
| `cd` or `cd ~` | Change to home directory |
| `cd ..` | Change to parent directory |
| `cd -` | Change to previous directory |
| `ls` | List files in current directory |
| `ls -l` | List files with details |
| `ls -a` | List all files including hidden ones |
| `ls -la` | List all files with details |
| `pwd` | Print working directory |
| `find . -name "pattern"` | Find files matching pattern |
| `locate filename` | Find file locations using updatedb database |
| `which command` | Show path of command executable |
| `Alt+B` | Move backward one word |
| `Alt+F` | Move forward one word |

### File Operations

| Command | Action |
|---------|--------|
| `cp source dest` | Copy file or directory |
| `mv source dest` | Move/rename file or directory |
| `rm file` | Remove file |
| `rm -r directory` | Remove directory and contents recursively |
| `mkdir directory` | Create directory |
| `rmdir directory` | Remove empty directory |
| `touch file` | Create empty file or update timestamp |
| `ln -s target link` | Create symbolic link |

### File Viewing

| Command | Action |
|---------|--------|
| `cat file` | Display file contents |
| `less file` | View file with pagination |
| `head file` | Display first 10 lines of file |
| `tail file` | Display last 10 lines of file |
| `tail -f file` | Follow file content as it grows |
| `grep pattern file` | Search for pattern in file |
| `grep -r pattern dir` | Search recursively for pattern |

## Text Editors

### Vim/Neovim

#### Modes

| Key | Mode |
|-----|------|
| `i` | Insert mode - insert text |
| `a` | Insert mode - append after cursor |
| `A` | Insert mode - append at end of line |
| `o` | Insert mode - open new line below |
| `O` | Insert mode - open new line above |
| `Esc` | Normal mode |
| `v` | Visual mode - select text |
| `V` | Visual line mode - select lines |
| `Ctrl+v` | Visual block mode - select blocks |
| `:` | Command mode |

#### Navigation (Normal Mode)

| Key | Action |
|-----|--------|
| `h j k l` | Move left, down, up, right |
| `w` | Move to start of next word |
| `b` | Move to start of previous word |
| `e` | Move to end of word |
| `0` | Move to start of line |
| `$` | Move to end of line |
| `gg` | Move to first line of document |
| `G` | Move to last line of document |
| `{` | Move to previous paragraph |
| `}` | Move to next paragraph |
| `Ctrl+u` | Move up half a screen |
| `Ctrl+d` | Move down half a screen |
| `Ctrl+b` | Move up one full screen |
| `Ctrl+f` | Move down one full screen |
| `%` | Jump to matching bracket |
| `:n` | Go to line n |

#### Editing (Normal Mode)

| Key | Action |
|-----|--------|
| `x` | Delete character under cursor |
| `dd` | Delete line |
| `dw` | Delete word |
| `d$` | Delete to end of line |
| `yy` | Copy line |
| `yw` | Copy word |
| `p` | Paste after cursor |
| `P` | Paste before cursor |
| `u` | Undo |
| `Ctrl+r` | Redo |
| `r` | Replace single character |
| `cw` | Change word |
| `cc` | Change entire line |
| `c$` | Change to end of line |
| `.` | Repeat last command |
| `>` | Indent |
| `<` | Unindent |

#### Search and Replace

| Key | Action |
|-----|--------|
| `/pattern` | Search forward for pattern |
| `?pattern` | Search backward for pattern |
| `n` | Next search result |
| `N` | Previous search result |
| `:%s/old/new/g` | Replace all occurrences of "old" with "new" |
| `:s/old/new/g` | Replace all occurrences in current line |

#### Files and Buffers

| Key | Action |
|-----|--------|
| `:w` | Save file |
| `:w filename` | Save file as filename |
| `:q` | Quit |
| `:q!` | Quit without saving |
| `:wq` or `:x` | Save and quit |
| `:e filename` | Edit a file |
| `:bn` | Next buffer |
| `:bp` | Previous buffer |
| `:bd` | Delete buffer |
| `:ls` | List buffers |

#### Split Windows

| Key | Action |
|-----|--------|
| `:sp` | Horizontal split |
| `:vsp` | Vertical split |
| `Ctrl+w h/j/k/l` | Navigate between splits |
| `Ctrl+w +/-` | Increase/decrease window height |
| `Ctrl+w >/`<` | Increase/decrease window width |
| `Ctrl+w =` | Make all windows equal size |
| `Ctrl+w q` | Close window |

### Emacs

#### Basic Controls

| Key | Action |
|-----|--------|
| `Ctrl+x Ctrl+c` | Exit Emacs |
| `Ctrl+g` | Cancel current command |
| `Ctrl+x Ctrl+s` | Save file |
| `Ctrl+x Ctrl+f` | Open file |
| `Ctrl+x Ctrl+w` | Save as |
| `Ctrl+x k` | Kill buffer |
| `Ctrl+h t` | Tutorial |
| `Ctrl+h k` | Describe key |

#### Navigation

| Key | Action |
|-----|--------|
| `Ctrl+a` | Move to beginning of line |
| `Ctrl+e` | Move to end of line |
| `Ctrl+f` | Forward one character |
| `Ctrl+b` | Back one character |
| `Alt+f` | Forward one word |
| `Alt+b` | Back one word |
| `Ctrl+n` | Next line |
| `Ctrl+p` | Previous line |
| `Alt+<` | Beginning of buffer |
| `Alt+>` | End of buffer |
| `Ctrl+v` | Page down |
| `Alt+v` | Page up |
| `Ctrl+l` | Center screen on cursor |

#### Editing

| Key | Action |
|-----|--------|
| `Ctrl+d` | Delete character |
| `Ctrl+k` | Kill (cut) to end of line |
| `Ctrl+w` | Kill (cut) region |
| `Alt+w` | Copy region |
| `Ctrl+y` | Yank (paste) |
| `Alt+y` | Cycle through kill ring after yank |
| `Ctrl+_` | Undo |
| `Ctrl+x u` | Undo |
| `Ctrl+Space` | Set mark (start selection) |

#### Search and Replace

| Key | Action |
|-----|--------|
| `Ctrl+s` | Incremental search forward |
| `Ctrl+r` | Incremental search backward |
| `Alt+%` | Query replace |
| `Alt+x replace-string` | Replace string |

#### Windows and Buffers

| Key | Action |
|-----|--------|
| `Ctrl+x 2` | Split window horizontally |
| `Ctrl+x 3` | Split window vertically |
| `Ctrl+x o` | Switch to other window |
| `Ctrl+x 0` | Close current window |
| `Ctrl+x 1` | Close all windows except current |
| `Ctrl+x b` | Switch buffer |
| `Ctrl+x Ctrl+b` | List buffers |

### Nano

| Key | Action |
|-----|--------|
| `Ctrl+G` | Display help text |
| `Ctrl+X` | Exit nano |
| `Ctrl+O` | Save file |
| `Ctrl+R` | Read file into current buffer |
| `Ctrl+W` | Search for text |
| `Ctrl+\` | Search and replace |
| `Ctrl+K` | Cut line |
| `Ctrl+U` | Paste text |
| `Ctrl+A` | Move to beginning of line |
| `Ctrl+E` | Move to end of line |
| `Ctrl+C` | Show cursor position |
| `Ctrl+_` | Go to specified line and column |
| `Alt+A` | Mark text from cursor position |
| `Ctrl+V` | Move down one page |
| `Ctrl+Y` | Move up one page |

## Shell

### Bash

| Shortcut | Action |
|----------|--------|
| `Tab` | Auto-complete command or filename |
| `Tab Tab` | Show all possible completions |
| `Ctrl+L` | Clear screen |
| `Ctrl+R` | Search command history |
| `Ctrl+A` | Move to beginning of line |
| `Ctrl+E` | Move to end of line |
| `Ctrl+U` | Delete from cursor to beginning of line |
| `Ctrl+K` | Delete from cursor to end of line |
| `Ctrl+W` | Delete the word before the cursor |
| `Alt+D` | Delete the word after the cursor |
| `Alt+F` | Move forward one word |
| `Alt+B` | Move backward one word |
| `Alt+.` | Insert last argument of previous command |
| `!!` | Repeat last command |
| `!string` | Run last command starting with "string" |
| `!n` | Run command with history number n |
| `!$` | Last argument of previous command |
| `!*` | All arguments of previous command |
| `^string1^string2^` | Replace "string1" with "string2" in previous command |

### Zsh

Includes all Bash shortcuts plus:

| Shortcut | Action |
|----------|--------|
| `Tab` | Cycle through completions |
| `Shift+Tab` | Cycle backwards through completions |
| `Alt+Q` | Push current line to buffer stack |
| `Alt+H` | Display man page for current command |
| `Ctrl+T` | Transpose two characters |
| `Alt+T` | Transpose two words |
| `Alt+U` | Uppercase word |
| `Alt+L` | Lowercase word |
| `Alt+C` | Capitalize word |
| `Alt+/` | Complete word from history |
| `Alt+P` | Previous command matching current line |
| `Alt+N` | Next command matching current line |

## Tmux

Default prefix: `Ctrl+b`

### Session Management

| Key | Action |
|-----|--------|
| `prefix d` | Detach from session |
| `prefix $` | Rename session |
| `prefix s` | List sessions |
| `prefix (` | Previous session |
| `prefix )` | Next session |
| `prefix L` | Last (previously used) session |

### Window Management

| Key | Action |
|-----|--------|
| `prefix c` | Create new window |
| `prefix ,` | Rename window |
| `prefix &` | Kill window |
| `prefix n` | Next window |
| `prefix p` | Previous window |
| `prefix l` | Last (previously used) window |
| `prefix w` | List windows |
| `prefix 0-9` | Switch to window number |

### Pane Management

| Key | Action |
|-----|--------|
| `prefix %` | Split pane vertically |
| `prefix "` | Split pane horizontally |
| `prefix arrow` | Switch to pane in direction |
| `prefix o` | Cycle through panes |
| `prefix q` | Show pane numbers (press number to switch) |
| `prefix x` | Kill pane |
| `prefix z` | Toggle pane zoom |
| `prefix {` | Move pane left |
| `prefix }` | Move pane right |
| `prefix Ctrl+arrow` | Resize pane |
| `prefix !` | Convert pane to window |

### Copy Mode

| Key | Action |
|-----|--------|
| `prefix [` | Enter copy mode |
| `prefix ]` | Paste from buffer |
| `Space` | Start selection |
| `Enter` | Copy selection |
| `q` | Quit copy mode |
| `/` | Search forward |
| `?` | Search backward |
| `n` | Next search match |
| `N` | Previous search match |

## Window Managers

### i3

Default modifier: `$mod` (Alt or Super key)

#### Window Management

| Key | Action |
|-----|--------|
| `$mod+Enter` | Open terminal |
| `$mod+Shift+q` | Kill window |
| `$mod+d` | Open application launcher (dmenu) |
| `$mod+h,j,k,l` | Focus window left, down, up, right |
| `$mod+Shift+h,j,k,l` | Move window left, down, up, right |
| `$mod+v` | Split vertically |
| `$mod+b` | Split horizontally |
| `$mod+f` | Toggle fullscreen |
| `$mod+Shift+space` | Toggle floating |
| `$mod+space` | Toggle focus between tiling/floating |
| `$mod+a` | Focus parent container |
| `$mod+s` | Stacking layout |
| `$mod+w` | Tabbed layout |
| `$mod+e` | Toggle split layout |
| `$mod+r` | Resize mode |

#### Workspaces

| Key | Action |
|-----|--------|
| `$mod+1-0` | Switch to workspace 1-10 |
| `$mod+Shift+1-0` | Move window to workspace 1-10 |
| `$mod+Shift+c` | Reload configuration |
| `$mod+Shift+r` | Restart i3 |
| `$mod+Shift+e` | Exit i3 |

### Sway

Sway uses the same keybindings as i3 by default, plus:

| Key | Action |
|-----|--------|
| `$mod+Shift+minus` | Move to scratchpad |
| `$mod+minus` | Show scratchpad |
| `$mod+b` | Splith (horizontal split) |
| `$mod+v` | Splitv (vertical split) |
| `$mod+Alt+number` | Move window to relative workspace |
| `$mod+Tab` | Next workspace |
| `$mod+Shift+Tab` | Previous workspace |

### Hyprland

Default modifier: `SUPER` (Windows/Command key)

| Key | Action |
|-----|--------|
| `SUPER+Q` | Kill active window |
| `SUPER+M` | Exit Hyprland |
| `SUPER+E` | Launch file manager |
| `SUPER+V` | Toggle floating window |
| `SUPER+F` | Toggle fullscreen |
| `SUPER+T` | Toggle pseudo-tiling |
| `SUPER+S` | Take screenshot |
| `SUPER+W` | Switch to next window |
| `SUPER+MouseScroll` | Cycle through workspaces |
| `SUPER+[1-9]` | Switch to workspace |
| `SUPER+SHIFT+[1-9]` | Move window to workspace |
| `SUPER+SHIFT+arrow` | Move window in direction |
| `SUPER+arrow` | Focus window in direction |
| `SUPER+CTRL+arrow` | Resize window |

## Git

| Command | Action |
|---------|--------|
| `git init` | Initialize a new repository |
| `git clone <url>` | Clone a repository |
| `git add <file>` | Add file to staging |
| `git add .` | Add all changes to staging |
| `git commit -m "message"` | Commit staged changes |
| `git status` | Show working tree status |
| `git diff` | Show changes between commits, commit and working tree, etc. |
| `git log` | Show commit logs |
| `git branch` | List branches |
| `git branch <name>` | Create a new branch |
| `git checkout <branch>` | Switch to branch |
| `git merge <branch>` | Merge branch into current branch |
| `git pull` | Fetch and merge changes from remote |
| `git push` | Push changes to remote |
| `git remote -v` | List remote repositories |
| `git stash` | Stash changes in working directory |
| `git stash apply` | Apply stashed changes |
| `git reset HEAD <file>` | Unstage file |
| `git checkout -- <file>` | Discard changes in working directory |

## Package Management

### Arch Linux (Pacman)

| Command | Action |
|---------|--------|
| `pacman -S <package>` | Install package |
| `pacman -Sy` | Synchronize package database |
| `pacman -Syu` | Update system |
| `pacman -Ss <keyword>` | Search for package |
| `pacman -Qs <keyword>` | Search for installed package |
| `pacman -R <package>` | Remove package |
| `pacman -Rs <package>` | Remove package and its dependencies |
| `pacman -Qe` | List explicitly installed packages |
| `pacman -Qdt` | List orphaned dependencies |
| `pacman -Ql <package>` | List files owned by package |
| `pacman -Qo <file>` | Find which package owns a file |

### NixOS (Nix)

| Command | Action |
|---------|--------|
| `nix-env -i <package>` | Install package |
| `nix-env -e <package>` | Uninstall package |
| `nix-env -q` | List installed packages |
| `nix-env -qa <pattern>` | Search for package |
| `nix-env -u` | Upgrade packages |
| `nix-channel --update` | Update channels |
| `nix-collect-garbage` | Remove unused packages |
| `nixos-rebuild switch` | Rebuild and switch to new configuration |
| `nixos-rebuild test` | Test configuration without making it permanent |
| `nixos-rebuild boot` | Rebuild configuration for next boot |
| `nix-shell` | Start development environment |
| `nix-shell -p <packages>` | Start shell with packages |

## System Control

### Systemd

| Command | Action |
|---------|--------|
| `systemctl start <unit>` | Start a service |
| `systemctl stop <unit>` | Stop a service |
| `systemctl restart <unit>` | Restart a service |
| `systemctl reload <unit>` | Reload a service |
| `systemctl enable <unit>` | Enable a service to start at boot |
| `systemctl disable <unit>` | Disable a service from starting at boot |
| `systemctl status <unit>` | Show status of a service |
| `systemctl list-units` | List running units |
| `systemctl list-unit-files` | List all available unit files |
| `systemctl daemon-reload` | Reload systemd configuration |
| `journalctl -u <unit>` | Show logs for a service |
| `journalctl -f` | Follow system logs |
| `journalctl -b` | Show logs from current boot |
| `journalctl --since today` | Show today's logs |

### System Control

| Command | Action |
|---------|--------|
| `shutdown -h now` | Shut down immediately |
| `shutdown -r now` | Reboot immediately |
| `reboot` | Reboot system |
| `poweroff` | Power off system |
| `halt` | Halt system |
| `mount <device> <mountpoint>` | Mount a filesystem |
| `umount <mountpoint>` | Unmount a filesystem |
| `ps aux` | List all running processes |
| `ps -ef` | List all running processes in full format |
| `kill <pid>` | Terminate a process |
| `kill -9 <pid>` | Force terminate a process |
| `killall <name>` | Kill processes by name |
| `top` | Display and manage processes |
| `htop` | Interactive process viewer |
| `free -h` | Display free and used memory |
| `df -h` | Show disk space usage |
| `du -sh <directory>` | Show directory size |

## Custom Shortcuts Configuration

### Creating i3 Custom Shortcuts

Edit `~/.config/i3/config`:

```
# Custom application shortcuts
bindsym $mod+Shift+f exec firefox
bindsym $mod+Shift+n exec nautilus
bindsym $mod+Shift+v exec code

# Custom script execution
bindsym $mod+Shift+s exec --no-startup-id ~/scripts/screenshot.sh
```

### Creating Sway Custom Shortcuts

Edit `~/.config/sway/config`:

```
# Custom application shortcuts
bindsym $mod+Shift+f exec firefox
bindsym $mod+Shift+n exec nautilus
bindsym $mod+Shift+v exec code

# Custom script execution
bindsym $mod+Shift+s exec --no-startup-id ~/scripts/screenshot.sh
```

### Creating X11 Custom Shortcuts

Using xbindkeys, create `~/.xbindkeysrc`:

```
# Launch Firefox
"firefox"
  Alt + Shift + f

# Take screenshot
"~/scripts/screenshot.sh"
  Alt + Shift + s
```

### Creating Keyboard Shortcuts in Zsh

Edit `~/.zshrc`:

```
# Custom keyboard shortcuts for Zsh
bindkey '^[s' push-line    # Alt+S: push line to buffer stack
bindkey '^[r' history-incremental-search-backward  # Alt+R: search history
bindkey '^[l' clear-screen  # Alt+L: clear screen
bindkey '^[e' edit-command-line  # Alt+E: edit command in editor
```

### Creating Vim Custom Mappings

Edit `~/.vimrc` or `~/.config/nvim/init.vim`:

```
" Custom key mappings
" Map jj to escape in insert mode
inoremap jj <Esc>

" Map space as leader key
let mapleader=" "

" Quick save
nnoremap <leader>w :w<CR>

" Quick quit
nnoremap <leader>q :q<CR>

" Quick save and quit
nnoremap <leader>x :x<CR>

" Toggle NERDTree
nnoremap <leader>n :NERDTreeToggle<CR>

" Format document
nnoremap <leader>f :Prettier<CR>
```

## Acknowledgements

This shortcut guide was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Shortcut compilation and organization
- Format standardization
- Documentation structure

Claude was used as a development aid while all final implementation decisions and review were performed by Joshua Michael Hall.

## Disclaimer

This guide is provided "as is", without warranty of any kind. Always back up important configuration files before making changes.

---

> "Master the basics. Then practice them every day without fail." - John C. Maxwell

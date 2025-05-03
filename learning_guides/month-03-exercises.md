# Month 3: Desktop Environment and Workflow Setup - Exercises

This document contains practical exercises and projects to accompany the Month 3 learning guide. Complete these exercises to solidify your understanding of window managers, desktop environments, and workflow optimization.

## Exercise 1: Window Manager Installation and Configuration

### Installation and Initial Setup

1. **Install your chosen window manager**:

   Choose one of the following window managers to install:

   **i3 (X11)**:
   ```bash
   sudo pacman -S i3-gaps i3blocks i3status dmenu feh picom xorg-xrandr xorg-xinit
   ```

   **Sway (Wayland)**:
   ```bash
   sudo pacman -S sway swaylock swayidle waybar wofi wl-clipboard
   ```

   **Hyprland (Wayland)**:
   ```bash
   sudo pacman -S hyprland waybar wofi wl-clipboard
   ```

2. **Configure a display manager**:

   ```bash
   # Install lightdm
   sudo pacman -S lightdm lightdm-gtk-greeter
   
   # Enable it
   sudo systemctl enable lightdm
   
   # Create a basic xsession file
   echo "[Desktop Entry]
   Name=i3
   Comment=improved dynamic tiling window manager
   Exec=i3
   TryExec=i3
   Type=Application
   X-LightDM-DesktopName=i3
   DesktopNames=i3" | sudo tee /usr/share/xsessions/i3.desktop
   ```

3. **Create basic configuration**:

   For i3:
   ```bash
   mkdir -p ~/.config/i3
   cp /etc/i3/config ~/.config/i3/config
   ```

   For Sway:
   ```bash
   mkdir -p ~/.config/sway
   cp /etc/sway/config ~/.config/sway/
   ```

   For Hyprland:
   ```bash
   mkdir -p ~/.config/hypr
   cp /usr/share/hypr/hyprland.conf ~/.config/hypr/
   ```

### Window Manager Customization

1. **Create a wallpaper directory and download a wallpaper**:

   ```bash
   mkdir -p ~/Pictures/wallpapers
   curl -o ~/Pictures/wallpapers/wallpaper.jpg https://source.unsplash.com/random/1920x1080/?nature
   ```

2. **Configure the wallpaper in your window manager**:

   For i3, add to `~/.config/i3/config`:
   ```
   # Set wallpaper
   exec --no-startup-id feh --bg-fill ~/Pictures/wallpapers/wallpaper.jpg
   ```

   For Sway, add to `~/.config/sway/config`:
   ```
   # Set wallpaper
   output * bg ~/Pictures/wallpapers/wallpaper.jpg fill
   ```

3. **Configure basic keybindings**:

   Edit your window manager config and ensure these keybindings are set:

   ```
   # Terminal
   bindsym $mod+Return exec alacritty
   
   # Application launcher
   bindsym $mod+d exec dmenu_run  # for i3
   # or 
   bindsym $mod+d exec wofi --show=drun  # for Sway/Hyprland
   
   # Kill focused window
   bindsym $mod+Shift+q kill
   
   # Reload configuration
   bindsym $mod+Shift+c reload
   
   # Restart window manager
   bindsym $mod+Shift+r restart  # for i3
   # or
   bindsym $mod+Shift+r exec swaymsg reload  # for Sway
   ```

4. **Configure window navigation**:

   Add these keybindings to your config:

   ```
   # Change focus (vim-style keys)
   bindsym $mod+h focus left
   bindsym $mod+j focus down
   bindsym $mod+k focus up
   bindsym $mod+l focus right
   
   # Move focused window
   bindsym $mod+Shift+h move left
   bindsym $mod+Shift+j move down
   bindsym $mod+Shift+k move up
   bindsym $mod+Shift+l move right
   ```

### Basic Usage Practice

1. **Start your window manager** (either log out and select it from your display manager, or run it directly):

   For i3 without display manager:
   ```bash
   echo "exec i3" > ~/.xinitrc
   startx
   ```

   For Sway without display manager:
   ```bash
   sway
   ```

2. **Practice basic window operations**:

   - Open a terminal with Mod+Return
   - Launch applications with Mod+d
   - Close windows with Mod+Shift+q
   - Move focus between windows with Mod+h, Mod+j, Mod+k, Mod+l
   - Move windows with Mod+Shift+h, Mod+Shift+j, Mod+Shift+k, Mod+Shift+l

3. **Practice using workspaces**:

   - Switch to workspace 1 with Mod+1
   - Switch to workspace 2 with Mod+2
   - Move a window to workspace 2 with Mod+Shift+2
   - Return to workspace 1 with Mod+1

4. **Practice layouts**:

   - Open multiple terminals in workspace 1
   - Toggle between different layouts:
     - Mod+e for tiling layout
     - Mod+w for tabbed layout
     - Mod+s for stacking layout (in i3/Sway)
   - Try resizing windows with Mod+r followed by arrow keys (in i3/Sway)

## Exercise 2: Desktop Environment Configuration

### Display Configuration

1. **Install display configuration tools**:

   ```bash
   # For X11
   sudo pacman -S arandr
   
   # For Wayland
   sudo pacman -S wdisplays
   ```

2. **Configure multiple monitors** (if available):

   For X11 with arandr:
   - Launch arandr
   - Arrange your monitors visually
   - Save the configuration
   - Add the generated script to your i3 config

   For Sway, add to ~/.config/sway/config:
   ```
   # Example multi-monitor setup
   output HDMI-A-1 resolution 1920x1080 position 0,0
   output eDP-1 resolution 1920x1080 position 1920,0
   ```

3. **Create a monitor profile switcher script**:

   ```bash
   mkdir -p ~/scripts
   nano ~/scripts/display-switcher.sh
   ```

   Add this content (for X11):
   ```bash
   #!/bin/bash
   
   PROFILE=$1
   
   case "$PROFILE" in
     single)
       xrandr --output eDP-1 --auto --output HDMI-A-1 --off
       ;;
     dual)
       xrandr --output eDP-1 --auto --output HDMI-A-1 --auto --right-of eDP-1
       ;;
     mirror)
       xrandr --output eDP-1 --auto --output HDMI-A-1 --auto --same-as eDP-1
       ;;
     present)
       xrandr --output HDMI-A-1 --auto --output eDP-1 --off
       ;;
     *)
       echo "Usage: $0 {single|dual|mirror|present}"
       exit 1
       ;;
   esac
   
   # Update wallpaper
   feh --bg-fill ~/Pictures/wallpapers/wallpaper.jpg
   ```

   Make it executable:
   ```bash
   chmod +x ~/scripts/display-switcher.sh
   ```

### Input Device Configuration

1. **Configure keyboard layout**:

   For X11, create `/etc/X11/xorg.conf.d/00-keyboard.conf`:
   ```
   Section "InputClass"
       Identifier "system-keyboard"
       MatchIsKeyboard "on"
       Option "XkbLayout" "us"
       Option "XkbModel" "pc105"
       Option "XkbOptions" "caps:escape"
   EndSection
   ```

   For Sway, add to `~/.config/sway/config`:
   ```
   input type:keyboard {
       xkb_layout us
       xkb_options caps:escape
   }
   ```

2. **Configure touchpad** (if available):

   For X11, create `/etc/X11/xorg.conf.d/30-touchpad.conf`:
   ```
   Section "InputClass"
       Identifier "touchpad"
       Driver "libinput"
       MatchIsTouchpad "on"
       Option "Tapping" "on"
       Option "NaturalScrolling" "true"
       Option "ClickMethod" "clickfinger"
       Option "DisableWhileTyping" "true"
   EndSection
   ```

   For Sway, add to `~/.config/sway/config`:
   ```
   input type:touchpad {
       tap enabled
       natural_scroll enabled
       dwt enabled
       click_method clickfinger
   }
   ```

3. **Test your input configurations**:

   Keyboard test:
   - Make sure Caps Lock now functions as Escape
   - Try typing in different applications to ensure layout works

   Touchpad test (if applicable):
   - Test tapping to click
   - Test two-finger scrolling with natural direction
   - Test that touchpad disables while typing

### Audio Setup

1. **Install audio packages**:

   ```bash
   # PulseAudio
   sudo pacman -S pulseaudio pulseaudio-alsa pavucontrol
   
   # Or PipeWire (more modern)
   sudo pacman -S pipewire pipewire-pulse wireplumber pavucontrol
   ```

2. **Configure media keys in your window manager**:

   For i3, add to `~/.config/i3/config`:
   ```
   # Media keys
   bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5%
   bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5%
   bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle
   bindsym XF86AudioMicMute exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle
   bindsym XF86AudioPlay exec --no-startup-id playerctl play-pause
   bindsym XF86AudioNext exec --no-startup-id playerctl next
   bindsym XF86AudioPrev exec --no-startup-id playerctl previous
   ```

   Similar settings for Sway/Hyprland configs.

3. **Create a volume indicator script**:

   ```bash
   nano ~/scripts/volume-notification.sh
   ```

   Add this content:
   ```bash
   #!/bin/bash
   
   # Volume notification script
   
   # Get volume and mute status
   VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -o '[0-9]*%' | head -1)
   MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
   
   # Show notification
   if [ "$MUTE" = "yes" ]; then
       notify-send -u low -i audio-volume-muted "Volume" "Muted"
   else
       notify-send -u low -i audio-volume-high "Volume" "$VOLUME"
   fi
   ```

   Make it executable:
   ```bash
   chmod +x ~/scripts/volume-notification.sh
   ```

   Update your window manager config to use this script:
   ```
   bindsym XF86AudioRaiseVolume exec --no-startup-id "pactl set-sink-volume @DEFAULT_SINK@ +5% && ~/scripts/volume-notification.sh"
   bindsym XF86AudioLowerVolume exec --no-startup-id "pactl set-sink-volume @DEFAULT_SINK@ -5% && ~/scripts/volume-notification.sh"
   bindsym XF86AudioMute exec --no-startup-id "pactl set-sink-mute @DEFAULT_SINK@ toggle && ~/scripts/volume-notification.sh"
   ```

### Essential Desktop Applications

1. **Install a terminal emulator**:

   ```bash
   # Install Alacritty
   sudo pacman -S alacritty
   
   # Create configuration directory
   mkdir -p ~/.config/alacritty
   
   # Create configuration file
   nano ~/.config/alacritty/alacritty.yml
   ```

   Add basic configuration to `alacritty.yml`:
   ```yaml
   window:
     padding:
       x: 10
       y: 10
     dynamic_padding: true
     decorations: full
     opacity: 0.95
   
   scrolling:
     history: 10000
     multiplier: 3
   
   font:
     normal:
       family: "JetBrains Mono"
       style: Regular
     bold:
       family: "JetBrains Mono"
       style: Bold
     italic:
       family: "JetBrains Mono"
       style: Italic
     size: 11.0
   
   # Colors (Dracula)
   colors:
     primary:
       background: '#282a36'
       foreground: '#f8f8f2'
     cursor:
       text: CellBackground
       cursor: CellForeground
     selection:
       text: CellForeground
       background: '#44475a'
     normal:
       black:   '#000000'
       red:     '#ff5555'
       green:   '#50fa7b'
       yellow:  '#f1fa8c'
       blue:    '#bd93f9'
       magenta: '#ff79c6'
       cyan:    '#8be9fd'
       white:   '#bfbfbf'
     bright:
       black:   '#4d4d4d'
       red:     '#ff6e67'
       green:   '#5af78e'
       yellow:  '#f4f99d'
       blue:    '#caa9fa'
       magenta: '#ff92d0'
       cyan:    '#9aedfe'
       white:   '#e6e6e6'
   ```

2. **Install and configure a notification daemon**:

   ```bash
   # Install dunst
   sudo pacman -S dunst
   
   # Create configuration directory
   mkdir -p ~/.config/dunst
   
   # Copy default configuration
   cp /etc/dunst/dunstrc ~/.config/dunst/
   ```

   Edit `~/.config/dunst/dunstrc` and customize:
   ```ini
   [global]
       monitor = 0
       follow = mouse
       width = 300
       height = 300
       origin = top-right
       offset = 10x50
       scale = 0
       notification_limit = 20
       progress_bar = true
       indicate_hidden = yes
       transparency = 20
       separator_height = 2
       padding = 8
       horizontal_padding = 8
       text_icon_padding = 0
       frame_width = 2
       frame_color = "#aaaaaa"
       separator_color = frame
       sort = yes
       font = JetBrains Mono 10
       line_height = 0
       markup = full
       format = "<b>%s</b>\n%b"
       alignment = left
       vertical_alignment = center
       show_age_threshold = 60
       ellipsize = middle
       ignore_newline = no
       stack_duplicates = true
       hide_duplicate_count = false
       show_indicators = yes
       icon_position = left
       
   [urgency_low]
       background = "#222222"
       foreground = "#888888"
       timeout = 10
   
   [urgency_normal]
       background = "#285577"
       foreground = "#ffffff"
       timeout = 10
   
   [urgency_critical]
       background = "#900000"
       foreground = "#ffffff"
       frame_color = "#ff0000"
       timeout = 0
   ```

   Add to your window manager config to autostart dunst (for i3):
   ```
   # Start notification daemon
   exec --no-startup-id dunst
   ```

3. **Install and configure a file manager**:

   ```bash
   # Install PCManFM
   sudo pacman -S pcmanfm
   
   # Launch once to generate config
   pcmanfm
   ```

   Configure PCManFM for your desktop:
   - Open PCManFM
   - Go to Edit > Preferences
   - Set your preferred view mode, default folders, etc.
   
   Add a keybinding to your window manager config (for i3):
   ```
   # Launch file manager
   bindsym $mod+e exec pcmanfm
   ```

4. **Install and configure an application launcher**:

   ```bash
   # Install Rofi
   sudo pacman -S rofi
   
   # Create configuration directory
   mkdir -p ~/.config/rofi
   
   # Generate default configuration
   rofi -dump-config > ~/.config/rofi/config.rasi
   ```

   Create a custom theme:
   ```bash
   nano ~/.config/rofi/theme.rasi
   ```

   Add content:
   ```css
   * {
       background-color:      #282a36;
       border-color:          #bd93f9;
       text-color:            #f8f8f2;
       font:                  "JetBrains Mono 12";
   }
   
   window {
       border:               2px;
       border-color:         @border-color;
       border-radius:        10px;
       padding:              10px;
       width:                40%;
   }
   
   mainbox {
       border:  0;
       padding: 0;
   }
   
   message {
       border:       2px 0 0;
       border-color: @border-color;
       padding:      1px;
   }
   
   listview {
       lines:      10;
       columns:    1;
       fixed-height: false;
       border:        0;
       scrollbar:     true;
   }
   
   element {
       padding: 5px;
       spacing: 5px;
   }
   
   element normal.normal {
       background-color: @background-color;
       text-color:       @text-color;
   }
   
   element selected.normal {
       background-color: #44475a;
       text-color:       @text-color;
   }
   
   scrollbar {
       handle-width: 10px;
       handle-color: @border-color;
   }
   ```

   Update your window manager config (for i3):
   ```
   # Use rofi instead of dmenu
   bindsym $mod+d exec rofi -show drun -theme ~/.config/rofi/theme.rasi
   ```

5. **Install a web browser and configure it**:

   ```bash
   # Install Firefox
   sudo pacman -S firefox
   
   # Add keybinding to your window manager
   ```

   Add to your window manager config (for i3):
   ```
   # Launch browser
   bindsym $mod+b exec firefox
   ```

6. **Install and configure screenshot tools**:

   ```bash
   # Install Flameshot
   sudo pacman -S flameshot
   ```

   Add to your window manager config:
   ```
   # Screenshot tools
   bindsym Print exec flameshot gui
   bindsym Shift+Print exec flameshot full -c
   ```

## Exercise 3: Visual Customization and Workflow Optimization

### Theme Configuration

1. **Install GTK and icon themes**:

   ```bash
   # Install themes
   sudo pacman -S arc-gtk-theme arc-icon-theme papirus-icon-theme
   ```

2. **Configure GTK theme settings**:

   ```bash
   # Create GTK3 settings file
   mkdir -p ~/.config/gtk-3.0
   nano ~/.config/gtk-3.0/settings.ini
   ```

   Add content:
   ```ini
   [Settings]
   gtk-theme-name=Arc-Dark
   gtk-icon-theme-name=Papirus-Dark
   gtk-font-name=Noto Sans 11
   gtk-cursor-theme-name=Adwaita
   gtk-cursor-theme-size=0
   gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
   gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
   gtk-button-images=1
   gtk-menu-images=1
   gtk-enable-event-sounds=1
   gtk-enable-input-feedback-sounds=1
   gtk-xft-antialias=1
   gtk-xft-hinting=1
   gtk-xft-hintstyle=hintslight
   gtk-xft-rgba=rgb
   ```

   For GTK2 applications:
   ```bash
   nano ~/.gtkrc-2.0
   ```

   Add content:
   ```
   gtk-theme-name="Arc-Dark"
   gtk-icon-theme-name="Papirus-Dark"
   gtk-font-name="Noto Sans 11"
   gtk-cursor-theme-name="Adwaita"
   gtk-cursor-theme-size=0
   gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
   gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
   gtk-button-images=1
   gtk-menu-images=1
   gtk-enable-event-sounds=1
   gtk-enable-input-feedback-sounds=1
   gtk-xft-antialias=1
   gtk-xft-hinting=1
   gtk-xft-hintstyle="hintslight"
   gtk-xft-rgba="rgb"
   ```

3. **Install Nerd Fonts for better terminal and UI**:

   ```bash
   # Install JetBrains Mono Nerd Font
   sudo pacman -S ttf-jetbrains-mono-nerd
   
   # Install Noto fonts for good coverage
   sudo pacman -S noto-fonts noto-fonts-emoji noto-fonts-cjk
   
   # Update font cache
   fc-cache -fv
   ```

4. **Install a theme configuration tool**:

   ```bash
   # Install lxappearance
   sudo pacman -S lxappearance
   
   # Run it to configure themes visually
   lxappearance
   ```

### Font Configuration

1. **Create a fontconfig file**:

   ```bash
   mkdir -p ~/.config/fontconfig
   nano ~/.config/fontconfig/fonts.conf
   ```

   Add content:
   ```xml
   <?xml version="1.0"?>
   <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
   <fontconfig>
     <match target="font">
       <edit name="antialias" mode="assign">
         <bool>true</bool>
       </edit>
       <edit name="hinting" mode="assign">
         <bool>true</bool>
       </edit>
       <edit name="hintstyle" mode="assign">
         <const>hintslight</const>
       </edit>
       <edit name="rgba" mode="assign">
         <const>rgb</const>
       </edit>
       <edit name="lcdfilter" mode="assign">
         <const>lcddefault</const>
       </edit>
     </match>
   
     <!-- Set preferred serif, sans-serif, and monospace fonts -->
     <alias>
       <family>serif</family>
       <prefer>
         <family>Noto Serif</family>
         <family>DejaVu Serif</family>
       </prefer>
     </alias>
     <alias>
       <family>sans-serif</family>
       <prefer>
         <family>Noto Sans</family>
         <family>DejaVu Sans</family>
       </prefer>
     </alias>
     <alias>
       <family>monospace</family>
       <prefer>
         <family>JetBrains Mono</family>
         <family>DejaVu Sans Mono</family>
       </prefer>
     </alias>
   </fontconfig>
   ```

2. **Test your font configuration**:

   ```bash
   # Update font cache
   fc-cache -fv
   
   # List configured fonts
   fc-list | grep -i jetbrains
   ```

### Status Bar Configuration

1. **Configure i3status** (for i3):

   ```bash
   mkdir -p ~/.config/i3status
   nano ~/.config/i3status/config
   ```

   Add content:
   ```
   general {
       colors = true
       interval = 5
       color_good = "#50fa7b"
       color_degraded = "#f1fa8c"
       color_bad = "#ff5555"
   }
   
   order += "cpu_usage"
   order += "memory"
   order += "disk /"
   order += "wireless _first_"
   order += "ethernet _first_"
   order += "battery all"
   order += "volume master"
   order += "tztime local"
   
   cpu_usage {
       format = "CPU: %usage"
       max_threshold = 75
   }
   
   memory {
       format = "Mem: %used / %available"
       threshold_degraded = "1G"
       format_degraded = "MEMORY < %available"
   }
   
   disk "/" {
       format = "Disk: %avail"
   }
   
   wireless _first_ {
       format_up = "W: (%quality at %essid) %ip"
       format_down = "W: down"
   }
   
   ethernet _first_ {
       format_up = "E: %ip (%speed)"
       format_down = "E: down"
   }
   
   battery all {
       format = "%status %percentage %remaining"
       format_down = "No battery"
       status_chr = "CHR"
       status_bat = "BAT"
       status_unk = "UNK"
       status_full = "FULL"
       path = "/sys/class/power_supply/BAT%d/uevent"
       low_threshold = 10
   }
   
   volume master {
       format = "Vol: %volume"
       format_muted = "Vol: muted"
       device = "default"
       mixer = "Master"
       mixer_idx = 0
   }
   
   tztime local {
       format = "%Y-%m-%d %H:%M:%S"
   }
   ```

2. **Configure Waybar** (for Sway/Hyprland):

   ```bash
   mkdir -p ~/.config/waybar
   nano ~/.config/waybar/config
   ```

   Add content:
   ```json
   {
       "layer": "top",
       "position": "top",
       "height": 30,
       "modules-left": ["sway/workspaces", "sway/mode"],
       "modules-center": ["sway/window"],
       "modules-right": ["pulseaudio", "network", "cpu", "memory", "battery", "clock", "tray"],
       "sway/workspaces": {
           "disable-scroll": true,
           "all-outputs": true,
           "format": "{name}"
       },
       "sway/mode": {
           "format": "<span style=\"italic\">{}</span>"
       },
       "tray": {
           "icon-size": 21,
           "spacing": 10
       },
       "clock": {
           "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
           "format": "{:%Y-%m-%d %H:%M}"
       },
       "cpu": {
           "format": "{usage}% CPU",
           "tooltip": false
       },
       "memory": {
           "format": "{}% MEM"
       },
       "battery": {
           "states": {
               "warning": 30,
               "critical": 15
           },
           "format": "{capacity}% BAT",
           "format-charging": "{capacity}% CHG",
           "format-plugged": "{capacity}% PLG"
       },
       "network": {
           "format-wifi": "{essid} ({signalStrength}%) ",
           "format-ethernet": "{ipaddr}/{cidr} ",
           "tooltip-format": "{ifname} via {gwaddr} ",
           "format-linked": "{ifname} (No IP) ",
           "format-disconnected": "Disconnected ⚠",
           "format-alt": "{ifname}: {ipaddr}/{cidr}"
       },
       "pulseaudio": {
           "format": "{volume}% VOL",
           "format-muted": "MUTED",
           "on-click": "pavucontrol"
       }
   }
   ```

   Create a style file:
   ```bash
   nano ~/.config/waybar/style.css
   ```

   Add content:
   ```css
   * {
       border: none;
       border-radius: 0;
       font-family: "JetBrains Mono", monospace;
       font-size: 14px;
       min-height: 0;
   }
   
   window#waybar {
       background-color: rgba(40, 42, 54, 0.9);
       color: #f8f8f2;
       transition-property: background-color;
       transition-duration: .5s;
   }
   
   #workspaces button {
       padding: 0 5px;
       background-color: transparent;
       color: #f8f8f2;
   }
   
   #workspaces button:hover {
       background: rgba(0, 0, 0, 0.2);
   }
   
   #workspaces button.focused {
       background-color: #44475a;
   }
   
   #mode {
       background-color: #44475a;
       border-bottom: 3px solid #f8f8f2;
   }
   
   #clock,
   #battery,
   #cpu,
   #memory,
   #temperature,
   #network,
   #pulseaudio,
   #tray {
       padding: 0 10px;
       margin: 0 4px;
   }
   
   #battery.warning {
       background-color: #f1fa8c;
       color: black;
   }
   
   #battery.critical {
       background-color: #ff5555;
       color: #f8f8f2;
   }
   
   #network.disconnected {
       background-color: #ff5555;
   }
   ```

3. **Add custom status bar scripts**:

   Create a weather script:
   ```bash
   nano ~/scripts/weather.sh
   ```

   Add content:
   ```bash
   #!/bin/bash
   
   # Simple weather script for i3status
   
   LOCATION="$(curl -s ipinfo.io/city)"
   WEATHER_INFO=$(curl -s "wttr.in/$LOCATION?format=%C+%t")
   
   echo "$WEATHER_INFO"
   ```

   Make it executable:
   ```bash
   chmod +x ~/scripts/weather.sh
   ```

   Create a system info script:
   ```bash
   nano ~/scripts/sysinfo.sh
   ```

   Add content:
   ```bash
   #!/bin/bash
   
   # System information script
   
   CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
   MEMORY=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')
   DISK=$(df -h / | awk 'NR==2 {print $4 " free"}')
   
   echo "CPU: $CPU_USAGE | MEM: $MEMORY | DISK: $DISK"
   ```

   Make it executable:
   ```bash
   chmod +x ~/scripts/sysinfo.sh
   ```

### Workflow Optimization

1. **Configure application workspace assignments**:

   For i3, add to config:
   ```
   # Assign applications to workspaces
   assign [class="firefox"] → 2
   assign [class="code-oss"] → 3
   assign [class="discord"] → 4
   assign [class="Spotify"] → 5
   ```

2. **Create custom keybindings for common tasks**:

   For i3, add to config:
   ```
   # Application shortcuts
   bindsym $mod+b exec firefox
   bindsym $mod+c exec code
   bindsym $mod+m exec thunderbird
   bindsym $mod+Shift+s exec flameshot gui
   
   # Layout shortcuts
   bindsym $mod+Shift+x split h
   bindsym $mod+Shift+v split v
   bindsym $mod+Shift+f floating toggle
   ```

3. **Create a layout switcher script**:

   ```bash
   nano ~/scripts/i3-layout.sh
   ```

   Add content:
   ```bash
   #!/bin/bash
   
   # i3 layout switcher
   
   LAYOUT=$1
   
   case "$LAYOUT" in
     coding)
       # Switch to workspace 3
       i3-msg workspace 3
       
       # Open terminal with text editor
       i3-msg exec "alacritty -e nvim"
       
       # Split and open another terminal
       i3-msg split v
       i3-msg exec alacritty
       
       # Resize
       i3-msg resize grow height 10 ppt
       ;;
       
     browsing)
       # Switch to workspace 2
       i3-msg workspace 2
       
       # Open browser
       i3-msg exec firefox
       ;;
       
     communication)
       # Switch to workspace 4
       i3-msg workspace 4
       
       # Open email client and chat side by side
       i3-msg exec thunderbird
       sleep 2
       i3-msg split h
       i3-msg exec discord
       ;;
       
     *)
       echo "Usage: $0 {coding|browsing|communication}"
       exit 1
       ;;
   esac
   ```

   Make it executable:
   ```bash
   chmod +x ~/scripts/i3-layout.sh
   ```

   Add keybindings to i3 config:
   ```
   # Layout presets
   bindsym $mod+F1 exec ~/scripts/i3-layout.sh coding
   bindsym $mod+F2 exec ~/scripts/i3-layout.sh browsing
   bindsym $mod+F3 exec ~/scripts/i3-layout.sh communication
   ```

4. **Create a focus mode script**:

   ```bash
   nano ~/scripts/focus-mode.sh
   ```

   Add content:
   ```bash
   #!/bin/bash
   
   # Toggle focus mode
   
   FOCUS_FILE="/tmp/focus_mode_active"
   
   if [ -f "$FOCUS_FILE" ]; then
       # Disable focus mode
       rm "$FOCUS_FILE"
       
       # Restore normal setup
       i3-msg "gaps inner all set 10"
       
       # Show status bar
       i3-msg "bar mode dock"
       
       # Restore notifications
       killall -SIGUSR2 dunst
       
       notify-send "Focus mode disabled" "Welcome back to normal mode"
   else
       # Enable focus mode
       touch "$FOCUS_FILE"
       
       # Increase gaps for less distraction
       i3-msg "gaps inner all set 20"
       
       # Hide status bar
       i3-msg "bar mode hide"
       
       # Pause notifications
       killall -SIGUSR1 dunst
       
       notify-send "Focus mode enabled" "Distractions minimized"
   fi
   ```

   Make it executable:
   ```bash
   chmod +x ~/scripts/focus-mode.sh
   ```

   Add keybinding to i3 config:
   ```
   # Toggle focus mode
   bindsym $mod+Shift+f exec ~/scripts/focus-mode.sh
   ```

## Exercise 4: Workflow Integration and Resource Management

### Application Integration

1. **Configure default applications**:

   ```bash
   # Create the MIME applications file
   mkdir -p ~/.config
   nano ~/.config/mimeapps.list
   ```

   Add content:
   ```ini
   [Default Applications]
   application/pdf=org.pwmt.zathura.desktop
   image/jpeg=feh.desktop
   image/png=feh.desktop
   image/gif=mpv.desktop
   text/plain=nvim.desktop
   text/html=firefox.desktop
   x-scheme-handler/http=firefox.desktop
   x-scheme-handler/https=firefox.desktop
   x-scheme-handler/mailto=thunderbird.desktop
   inode/directory=pcmanfm.desktop
   ```

2. **Install and configure a clipboard manager**:

   ```bash
   # Install clipboard manager
   sudo pacman -S clipmenu

   # Autostart in window manager
   ```

   For i3, add to config:
   ```
   # Start clipboard manager
   exec --no-startup-id clipmenud
   
   # Clipboard manager keybinding
   bindsym $mod+v exec clipmenu
   ```

3. **Configure screenshot tools**:

   Create a screenshot script:
   ```bash
   nano ~/scripts/screenshot.sh
   ```

   Add content:
   ```bash
   #!/bin/bash
   
   # Screenshot script with options
   
   ACTION=$1
   SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
   
   # Create directory if it doesn't exist
   mkdir -p "$SCREENSHOT_DIR"
   
   # Generate filename with timestamp
   FILENAME="$SCREENSHOT_DIR/screenshot_$(date +%Y%m%d_%H%M%S).png"
   
   case "$ACTION" in
     full)
       # Capture full screen
       flameshot full -p "$SCREENSHOT_DIR"
       notify-send "Screenshot taken" "Saved to $SCREENSHOT_DIR"
       ;;
       
     select)
       # Capture selection
       flameshot gui -p "$SCREENSHOT_DIR"
       ;;
       
     window)
       # Capture active window
       import -window "$(xdotool getactivewindow)" "$FILENAME"
       notify-send "Window captured" "Saved to $FILENAME"
       ;;
       
     delayed)
       # Capture after 5 seconds
       notify-send "Screenshot" "Taking screenshot in 5 seconds..."
       sleep 5
       flameshot full -p "$SCREENSHOT_DIR"
       notify-send "Screenshot taken" "Saved to $SCREENSHOT_DIR"
       ;;
       
     *)
       echo "Usage: $0 {full|select|window|delayed}"
       exit 1
       ;;
   esac
   ```

   Make it executable:
   ```bash
   chmod +x ~/scripts/screenshot.sh
   ```

   Add keybindings to i3 config:
   ```
   # Screenshot tools
   bindsym Print exec ~/scripts/screenshot.sh select
   bindsym Shift+Print exec ~/scripts/screenshot.sh full
   bindsym Ctrl+Print exec ~/scripts/screenshot.sh window
   bindsym Mod1+Print exec ~/scripts/screenshot.sh delayed
   ```

### System Resource Optimization

1. **Install resource monitoring tools**:

   ```bash
   # Install monitoring tools
   sudo pacman -S htop btop powertop
   ```

2. **Create a power management script**:

   ```bash
   nano ~/scripts/power-profile.sh
   ```

   Add content:
   ```bash
   #!/bin/bash
   
   # Power profile switcher
   
   PROFILE=$1
   
   case "$PROFILE" in
     performance)
       # Set CPU governor to performance
       sudo cpupower frequency-set -g performance
       
       # Disable power saving
       sudo powertop --auto-tune 0
       
       # Set screen brightness to max
       if [[ -d /sys/class/backlight/intel_backlight ]]; then
         echo $(cat /sys/class/backlight/intel_backlight/max_brightness) | sudo tee /sys/class/backlight/intel_backlight/brightness
       fi
       
       # Disable auto-suspend
       systemctl --user mask sleep.target suspend.target hibernate.target hybrid-sleep.target
       
       notify-send "Power Profile" "Set to Performance Mode"
       ;;
       
     balanced)
       # Set CPU governor to schedutil
       sudo cpupower frequency-set -g schedutil
       
       # Apply some power saving
       sudo powertop --auto-tune
       
       # Set screen brightness to 70%
       if [[ -d /sys/class/backlight/intel_backlight ]]; then
         echo $(( $(cat /sys/class/backlight/intel_backlight/max_brightness) * 7 / 10 )) | sudo tee /sys/class/backlight/intel_backlight/brightness
       fi
       
       # Enable auto-suspend
       systemctl --user unmask sleep.target suspend.target hibernate.target hybrid-sleep.target
       
       notify-send "Power Profile" "Set to Balanced Mode"
       ;;
       
     powersave)
       # Set CPU governor to powersave
       sudo cpupower frequency-set -g powersave
       
       # Apply aggressive power saving
       sudo powertop --auto-tune
       
       # Set screen brightness to 40%
       if [[ -d /sys/class/backlight/intel_backlight ]]; then
         echo $(( $(cat /sys/class/backlight/intel_backlight/max_brightness) * 4 / 10 )) | sudo tee /sys/class/backlight/intel_backlight/brightness
       fi
       
       # Enable auto-suspend with short timeout
       systemctl --user unmask sleep.target suspend.target hibernate.target hybrid-sleep.target
       
       notify-send "Power Profile" "Set to Power Saving Mode"
       ;;
       
     *)
       echo "Usage: $0 {performance|balanced|powersave}"
       exit 1
       ;;
   esac
   ```

   Make it executable:
   ```bash
   chmod +x ~/scripts/power-profile.sh
   ```

   Add keybindings to i3 config:
   ```
   # Power profiles
   bindsym $mod+Shift+1 exec ~/scripts/power-profile.sh performance
   bindsym $mod+Shift+2 exec ~/scripts/power-profile.sh balanced
   bindsym $mod+Shift+3 exec ~/scripts/power-profile.sh powersave
   ```

3. **Create a system monitor dashboard**:

   ```bash
   nano ~/scripts/system-dashboard.sh
   ```

   Add content:
   ```bash
   #!/bin/bash
   
   # System monitoring dashboard using tmux
   
   SESSION="sysmon"
   
   # Check if session exists
   tmux has-session -t $SESSION 2>/dev/null
   
   if [ $? != 0 ]; then
       # Create session
       tmux new-session -s $SESSION -d
       
       # Split into panes
       tmux split-window -h -t $SESSION
       tmux split-window -v -t $SESSION:0.1
       tmux split-window -v -t $SESSION:0.0
       
       # Configure monitoring tools
       tmux send-keys -t $SESSION:0.0 'btop' C-m
       tmux send-keys -t $SESSION:0.1 'watch -n 1 "free -h"' C-m
       tmux send-keys -t $SESSION:0.2 'watch -n 1 "df -h"' C-m
       tmux send-keys -t $SESSION:0.3 'journalctl -f' C-m
       
       # Select first pane
       tmux select-pane -t $SESSION:0.0
   fi
   
   # Attach to session
   tmux attach-session -t $SESSION
   ```

   Make it executable:
   ```bash
   chmod +x ~/scripts/system-dashboard.sh
   ```

   Add a keybinding to i3 config:
   ```
   # System monitor dashboard
   bindsym $mod+m exec alacritty -e ~/scripts/system-dashboard.sh
   ```

### Backup and Restore Your Configuration

1. **Create a dotfiles repository**:

   ```bash
   # Create dotfiles directory
   mkdir -p ~/dotfiles
   
   # Initialize git repository
   cd ~/dotfiles
   git init
   
   # Create directory structure
   mkdir -p {i3,alacritty,dunst,rofi}
   ```

2. **Create a script to organize and backup dotfiles**:

   ```bash
   nano ~/scripts/backup-dotfiles.sh
   ```

   Add content:
   ```bash
   #!/bin/bash
   
   # Dotfiles backup script
   
   DOTFILES_DIR="$HOME/dotfiles"
   
   # Check if dotfiles directory exists
   if [ ! -d "$DOTFILES_DIR" ]; then
       echo "Creating dotfiles directory..."
       mkdir -p "$DOTFILES_DIR"
       cd "$DOTFILES_DIR"
       git init
   else
       cd "$DOTFILES_DIR"
   fi
   
   # Create directories
   mkdir -p {i3,alacritty,dunst,rofi,scripts,wallpapers}
   
   # Backup i3 config
   echo "Backing up i3 configuration..."
   mkdir -p "$DOTFILES_DIR/i3/.config/i3"
   cp -r ~/.config/i3/* "$DOTFILES_DIR/i3/.config/i3/"
   
   # Backup i3status config
   mkdir -p "$DOTFILES_DIR/i3/.config/i3status"
   cp -r ~/.config/i3status/* "$DOTFILES_DIR/i3/.config/i3status/"
   
   # Backup Alacritty config
   echo "Backing up Alacritty configuration..."
   mkdir -p "$DOTFILES_DIR/alacritty/.config/alacritty"
   cp -r ~/.config/alacritty/* "$DOTFILES_DIR/alacritty/.config/alacritty/"
   
   # Backup Dunst config
   echo "Backing up Dunst configuration..."
   mkdir -p "$DOTFILES_DIR/dunst/.config/dunst"
   cp -r ~/.config/dunst/* "$DOTFILES_DIR/dunst/.config/dunst/"
   
   # Backup Rofi config
   echo "Backing up Rofi configuration..."
   mkdir -p "$DOTFILES_DIR/rofi/.config/rofi"
   cp -r ~/.config/rofi/* "$DOTFILES_DIR/rofi/.config/rofi/"
   
   # Backup scripts
   echo "Backing up scripts..."
   cp -r ~/scripts/* "$DOTFILES_DIR/scripts/"
   
   # Backup wallpapers
   echo "Backing up wallpapers..."
   cp -r ~/Pictures/wallpapers/* "$DOTFILES_DIR/wallpapers/"
   
   # Create README if it doesn't exist
   if [ ! -f "$DOTFILES_DIR/README.md" ]; then
       echo "Creating README.md..."
       cat > "$DOTFILES_DIR/README.md" << EOF
   # Dotfiles
   
   These are my personal dotfiles for my Linux setup.
   
   ## Components
   
   - Window Manager: i3-gaps
   - Terminal: Alacritty
   - Notification Daemon: Dunst
   - Application Launcher: Rofi
   - Scripts: Custom utility scripts
   
   ## Installation
   
   \`\`\`bash
   # Install GNU Stow
   sudo pacman -S stow
   
   # Clone repository
   git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
   
   # Use stow to create symlinks
   cd ~/dotfiles
   stow i3 alacritty dunst rofi
   \`\`\`
   
   ## Screenshots
   
   [Add screenshots here]
   
   ## Acknowledgements
   
   This project was developed with assistance from Anthropic's Claude AI assistant, which helped with:
   - Documentation writing and organization
   - Code structure suggestions
   - Troubleshooting and debugging assistance
   
   Claude was used as a development aid while all final implementation decisions and review were performed by Joshua Michael Hall.
   EOF
   fi
   
   # Create install script
   echo "Creating install script..."
   cat > "$DOTFILES_DIR/install.sh" << 'EOF'
   #!/bin/bash
   
   # Check if GNU stow is installed
   if ! command -v stow &> /dev/null; then
       echo "GNU stow is required but not installed."
       echo "Install it with: sudo pacman -S stow"
       exit 1
   fi
   
   # Create backup directory
   mkdir -p ~/.dotfiles_backup
   
   # Backup existing configs
   if [ -d ~/.config/i3 ]; then
       echo "Backing up existing i3 config..."
       cp -r ~/.config/i3 ~/.dotfiles_backup/
   fi
   
   if [ -d ~/.config/alacritty ]; then
       echo "Backing up existing alacritty config..."
       cp -r ~/.config/alacritty ~/.dotfiles_backup/
   fi
   
   if [ -d ~/.config/dunst ]; then
       echo "Backing up existing dunst config..."
       cp -r ~/.config/dunst ~/.dotfiles_backup/
   fi
   
   if [ -d ~/.config/rofi ]; then
       echo "Backing up existing rofi config..."
       cp -r ~/.config/rofi ~/.dotfiles_backup/
   fi
   
   # Use stow to create symlinks
   echo "Creating symlinks with stow..."
   stow i3 alacritty dunst rofi
   
   # Copy scripts to ~/scripts
   echo "Copying scripts..."
   mkdir -p ~/scripts
   cp -r scripts/* ~/scripts/
   chmod +x ~/scripts/*
   
   # Copy wallpapers
   echo "Copying wallpapers..."
   mkdir -p ~/Pictures/wallpapers
   cp -r wallpapers/* ~/Pictures/wallpapers/
   
   echo "Installation complete!"
   echo "Log out and log back in to apply changes."
   EOF
   
   # Make install script executable
   chmod +x "$DOTFILES_DIR/install.sh"
   
   # Create uninstall script
   echo "Creating uninstall script..."
   cat > "$DOTFILES_DIR/uninstall.sh" << 'EOF'
   #!/bin/bash
   
   # Check if GNU stow is installed
   if ! command -v stow &> /dev/null; then
       echo "GNU stow is required but not installed."
       echo "Install it with: sudo pacman -S stow"
       exit 1
   fi
   
   # Use stow to remove symlinks
   echo "Removing symlinks..."
   stow -D i3 alacritty dunst rofi
   
   # Restore backups if they exist
   if [ -d ~/.dotfiles_backup ]; then
       echo "Restoring backups..."
       
       if [ -d ~/.dotfiles_backup/i3 ]; then
           cp -r ~/.dotfiles_backup/i3 ~/.config/
       fi
       
       if [ -d ~/.dotfiles_backup/alacritty ]; then
           cp -r ~/.dotfiles_backup/alacritty ~/.config/
       fi
       
       if [ -d ~/.dotfiles_backup/dunst ]; then
           cp -r ~/.dotfiles_backup/dunst ~/.config/
       fi
       
       if [ -d ~/.dotfiles_backup/rofi ]; then
           cp -r ~/.dotfiles_backup/rofi ~/.config/
       fi
   fi
   
   echo "Uninstallation complete!"
   echo "Log out and log back in to apply changes."
   EOF
   
   # Make uninstall script executable
   chmod +x "$DOTFILES_DIR/uninstall.sh"
   
   echo "Dotfiles backup complete!"
   cd "$DOTFILES_DIR"
   git status
   ```

   Make it executable:
   ```bash
   chmod +x ~/scripts/backup-dotfiles.sh
   ```

3. **Use GNU Stow for dotfile management**:

   ```bash
   # Install GNU Stow
   sudo pacman -S stow
   
   # Run the backup script
   ~/scripts/backup-dotfiles.sh
   
   # Add files to git
   cd ~/dotfiles
   git add .
   git commit -m "Initial dotfiles backup"
   ```

### Automation and Convenience Scripts

1. **Create a session management script**:

   ```bash
   nano ~/scripts/session-manager.sh
   ```

   Add content:
   ```bash
   #!/bin/bash
   
   # Session management script
   
   ACTION=$1
   PROJECT=$2
   SESSION_DIR="$HOME/.config/sessions"
   
   # Create sessions directory if it doesn't exist
   mkdir -p "$SESSION_DIR"
   
   case "$ACTION" in
     save)
       if [ -z "$PROJECT" ]; then
         echo "Error: Please provide a project name to save."
         echo "Usage: $0 save <project-name>"
         exit 1
       fi
       
       # Save current session
       echo "Saving session: $PROJECT"
       
       # Create session file
       SESSION_FILE="$SESSION_DIR/$PROJECT.session"
       
       # Save window manager state (i3 specific)
       i3-save-tree --workspace > "$SESSION_FILE"
       
       # Clean up the file for easier loading
       sed -i 's/^\s*\/\///' "$SESSION_FILE"
       sed -i '/^\s*"id"/d' "$SESSION_FILE"
       
       notify-send "Session Manager" "Session '$PROJECT' saved"
       ;;
       
     load)
       if [ -z "$PROJECT" ]; then
         echo "Error: Please provide a project name to load."
         echo "Usage: $0 load <project-name>"
         exit 1
       fi
       
       # Load saved session
       SESSION_FILE="$SESSION_DIR/$PROJECT.session"
       
       if [ ! -f "$SESSION_FILE" ]; then
         echo "Error: Session '$PROJECT' not found."
         notify-send "Session Manager" "Session '$PROJECT' not found"
         exit 1
       fi
       
       echo "Loading session: $PROJECT"
       
       # Restore session
       i3-msg "workspace 1; append_layout $SESSION_FILE"
       
       # Extract and launch applications
       grep -o 'class.*' "$SESSION_FILE" | awk -F'"' '{print $4}' | while read -r app; do
         i3-msg "exec $app" &>/dev/null
       done
       
       notify-send "Session Manager" "Session '$PROJECT' loaded"
       ;;
       
     list)
       echo "Available sessions:"
       ls -1 "$SESSION_DIR" | sed 's/\.session$//'
       ;;
       
     *)
       echo "Usage: $0 {save|load|list} [project-name]"
       exit 1
       ;;
   esac
   ```

   Make it executable:
   ```bash
   chmod +x ~/scripts/session-manager.sh
   ```

2. **Create a startup script**:

   ```bash
   nano ~/scripts/startup.sh
   ```

   Add content:
   ```bash
   #!/bin/bash
   
   # Startup script
   
   # Load environment variables
   if [ -f ~/.profile ]; then
     source ~/.profile
   fi
   
   # Start compositor
   if command -v picom &> /dev/null; then
     picom -b
   fi
   
   # Set wallpaper
   if command -v feh &> /dev/null; then
     feh --bg-fill ~/Pictures/wallpapers/wallpaper.jpg
   fi
   
   # Start notification daemon
   if command -v dunst &> /dev/null; then
     dunst &
   fi
   
   # Start network manager applet
   if command -v nm-applet &> /dev/null; then
     nm-applet &
   fi
   
   # Start clipboard manager
   if command -v clipmenud &> /dev/null; then
     clipmenud &
   fi
   
   # Start power manager
   if command -v xfce4-power-manager &> /dev/null; then
     xfce4-power-manager &
   fi
   
   # Apply display settings
   if [ -f ~/scripts/display-switcher.sh ]; then
     ~/scripts/display-switcher.sh auto
   fi
   
   # Set up keyboards
   setxkbmap -option caps:escape
   
   # Start applications
   sleep 5  # Wait for desktop to fully load
   
   # Start terminal
   alacritty &
   
   # Show welcome message
   notify-send "System" "Welcome back! Your desktop is ready."
   ```

   Make it executable:
   ```bash
   chmod +x ~/scripts/startup.sh
   ```

   Add to your i3 config:
   ```
   # Run startup script
   exec --no-startup-id ~/scripts/startup.sh
   ```

3. **Create a task management script**:

   ```bash
   nano ~/scripts/task-manager.sh
   ```

   Add content:
   ```bash
   #!/bin/bash
   
   # Simple task management script
   
   TASK_FILE="$HOME/.tasks.md"
   
   # Create task file if it doesn't exist
   if [ ! -f "$TASK_FILE" ]; then
     echo "# Tasks" > "$TASK_FILE"
     echo "" >> "$TASK_FILE"
     echo "## Todo" >> "$TASK_FILE"
     echo "" >> "$TASK_FILE"
     echo "## In Progress" >> "$TASK_FILE"
     echo "" >> "$TASK_FILE"
     echo "## Done" >> "$TASK_FILE"
     echo "" >> "$TASK_FILE"
   fi
   
   case "$1" in
     add)
       if [ -z "$2" ]; then
         echo "Error: Please provide a task description."
         echo "Usage: $0 add \"Task description\""
         exit 1
       fi
       
       echo "- [ ] $2" >> "$TASK_FILE"
       echo "Task added: $2"
       ;;
       
     list)
       cat "$TASK_FILE"
       ;;
       
     edit)
       if command -v nvim &> /dev/null; then
         nvim "$TASK_FILE"
       else
         nano "$TASK_FILE"
       fi
       ;;
       
     done)
       if [ -z "$2" ]; then
         echo "Error: Please provide a keyword to find the task."
         echo "Usage: $0 done \"keyword\""
         exit 1
       fi
       
       KEYWORD="$2"
       sed -i "s/- \[ \] \(.*$KEYWORD.*\)/- \[x\] \1/" "$TASK_FILE"
       echo "Marked tasks containing '$KEYWORD' as done."
       ;;
       
     clear)
       if [ "$2" = "done" ]; then
         grep -v "- \[x\] " "$TASK_FILE" > "$TASK_FILE.tmp"
         mv "$TASK_FILE.tmp" "$TASK_FILE"
         echo "Cleared completed tasks."
       else
         echo "Error: Only 'done' tasks can be cleared."
         echo "Usage: $0 clear done"
         exit 1
       fi
       ;;
       
     *)
       echo "Usage: $0 {add|list|edit|done|clear} [args]"
       echo ""
       echo "Commands:"
       echo "  add \"Task description\"  Add a new task"
       echo "  list                    List all tasks"
       echo "  edit                    Open task file in editor"
       echo "  done \"keyword\"          Mark tasks containing keyword as done"
       echo "  clear done              Remove completed tasks"
       exit 1
       ;;
   esac
   ```

   Make it executable:
   ```bash
   chmod +x ~/scripts/task-manager.sh
   ```

   Add aliases to your shell configuration:
   ```bash
   echo 'alias t="~/scripts/task-manager.sh"' >> ~/.zshrc
   ```

## Projects

### Project 1: Custom Desktop Environment

Create a fully customized desktop environment with consistent theming and efficient workflows.

1. **Plan your desktop environment**:
   - Choose a color scheme and design aesthetic
   - Select fonts and icons
   - Design your workflow and identify needed components

2. **Create a consistent theme across applications**:
   - Customize window manager appearance
   - Configure GTK and Qt themes
   - Set up icon and cursor themes
   - Configure terminal and editor colors

3. **Build efficient workflows**:
   - Design workspace layouts for different tasks
   - Create custom keybindings
   - Write automation scripts
   - Configure application launchers and menus

4. **Document your setup**:
   - Create a comprehensive README
   - Take screenshots showing different components
   - Document all keybindings and customizations
   - Create installation instructions

### Project 2: Dotfiles Repository

Create a version-controlled repository for your configuration files with easy deployment.

1. **Organize your dotfiles**:
   - Decide on a directory structure
   - Identify configuration files to include
   - Create a consistent naming scheme

2. **Set up version control**:
   - Initialize a git repository
   - Create a .gitignore file for sensitive information
   - Make an initial commit

3. **Create deployment scripts**:
   - Write an installation script
   - Set up GNU Stow for symlink management
   - Create a backup/restore system
   - Add environment-specific configuration options

4. **Document your repository**:
   - Create a detailed README
   - Add screenshots and usage examples
   - Document dependencies and requirements
   - Add license information

### Project 3: Status Bar Enhancement

Create a custom status bar with useful information and interactive elements.

1. **Design your status bar**:
   - Sketch the layout and components
   - Choose information to display
   - Plan interactive elements

2. **Implement custom modules**:
   - Create scripts for system information
   - Write weather and network monitors
   - Design workspace and window indicators
   - Build music player controls

3. **Style your status bar**:
   - Create a consistent color scheme
   - Design icons and indicators
   - Configure fonts and spacing
   - Add animations or transitions

4. **Add interactive functionality**:
   - Create clickable areas
   - Build dropdown menus
   - Add notification integration
   - Implement system control toggles

### Project 4: Workflow Automation Project

Create a comprehensive set of scripts to automate common development tasks.

1. **Identify repetitive tasks**:
   - List common development workflows
   - Identify time-consuming operations
   - Plan automation opportunities

2. **Create workflow scripts**:
   - Write project setup scripts
   - Create build and deployment automation
   - Design testing and validation tools
   - Build documentation generators

3. **Integrate with your environment**:
   - Add keybindings for scripts
   - Create menu entries and launchers
   - Configure automatic triggers
   - Set up notifications and logging

4. **Test and optimize**:
   - Validate scripts in different scenarios
   - Measure time savings
   - Refine and improve workflows
   - Document usage and examples

## Additional Resources

### Window Manager References

- **i3 Keyboard Shortcuts**:
  ```
  $mod+Return       # Open terminal
  $mod+d            # Open application launcher
  $mod+Shift+q      # Close window
  $mod+h/j/k/l      # Move focus
  $mod+Shift+h/j/k/l # Move windows
  $mod+v            # Split vertically
  $mod+b            # Split horizontally
  $mod+f            # Toggle fullscreen
  $mod+s            # Stacking layout
  $mod+w            # Tabbed layout
  $mod+e            # Toggle split layout
  $mod+Shift+space  # Toggle floating
  $mod+1-9          # Switch workspaces
  $mod+Shift+1-9    # Move window to workspace
  $mod+Shift+c      # Reload config
  $mod+Shift+r      # Restart i3
  ```

- **Sway Keyboard Shortcuts**:
  Similar to i3, with these additions:
  ```
  $mod+Shift+e      # Exit Sway
  $mod+Shift+minus  # Send to scratchpad
  $mod+minus        # Show scratchpad
  ```

### Desktop Configuration Checklist

- **Input Devices**:
  - [ ] Configure keyboard layout and options
  - [ ] Set up touchpad with natural scrolling
  - [ ] Configure mouse acceleration and button mapping
  - [ ] Set up any special input devices

- **Display**:
  - [ ] Configure monitor resolution and refresh rate
  - [ ] Set up multi-monitor arrangement
  - [ ] Configure scaling for HiDPI displays
  - [ ] Set up night light/color temperature

- **Audio**:
  - [ ] Configure default input/output devices
  - [ ] Set up media key controls
  - [ ] Configure volume levels and mute settings
  - [ ] Set up audio notifications

- **Appearance**:
  - [ ] Install and configure theme
  - [ ] Set up icon theme
  - [ ] Configure fonts and rendering
  - [ ] Set wallpaper and lock screen

- **Applications**:
  - [ ] Configure default applications
  - [ ] Set up application autostart
  - [ ] Configure workspace assignments
  - [ ] Set up launcher and menus

### Theme Resources

- **Color Scheme Generators**:
  - [Adobe Color](https://color.adobe.com/)
  - [Coolors](https://coolors.co/)
  - [Color Space](https://mycolor.space/)

- **Icon Themes**:
  - Papirus
  - Numix
  - Arc
  - Breeze

- **GTK Themes**:
  - Arc
  - Adapta
  - Materia
  - Nordic

- **Fonts**:
  - JetBrains Mono
  - Fira Code
  - Noto Sans/Serif
  - Roboto

## Reflection Questions

After completing the exercises and projects, reflect on these questions:

1. How does using a tiling window manager change your workflow compared to a traditional desktop environment?

2. What are the advantages and disadvantages of keyboard-driven workflows versus mouse-driven workflows?

3. How does a customized desktop environment improve your productivity?

4. What principles did you follow when designing your keybindings and shortcuts?

5. How does your custom desktop environment balance aesthetics with functionality?

6. What were the most challenging aspects of configuring your desktop environment?

7. How will you maintain and update your configuration over time?

8. What additional tools or scripts would further enhance your desktop environment?

## Answers to Self-Assessment Quiz

1. A tiling window manager automatically arranges windows in a non-overlapping pattern, while a floating window manager allows windows to overlap freely like in traditional desktop environments.

2. X11 is older with better compatibility but poorer security and performance, while Wayland is newer with improved security, better HiDPI support, and smoother graphics but has some compatibility issues.

3. Use the `assign` directive in the window manager config, e.g., `assign [class="Firefox"] 2` to assign Firefox to workspace 2.

4. `flameshot gui` or configured key binding like `bindsym Print exec flameshot gui`.

5. Add `exec` or `exec --no-startup-id` commands to the window manager config file.

6. A compositor manages visual effects like transparency and animations, reducing screen tearing and improving visual appearance.

7. Add output configuration to Sway config: `output HDMI-A-1 resolution 1920x1080 position 1920,0`.

8. It displays system information, workspace status, and notifications, providing feedback about the system state.

9. Add a keybinding to window manager config: `bindsym $mod+b exec firefox`.

10. Use lxappearance for GTK and qt5ct for Qt applications to maintain consistent themes across both toolkits.

## Next Steps

After completing the Month 3 exercises, consider these activities to further enhance your skills:

1. **Learn advanced window manager features** like scratchpads, marks, and custom layouts

2. **Explore alternative window managers** like bspwm, awesome, or qtile

3. **Create advanced polybar or waybar configurations** with custom modules

4. **Design color schemes from scratch** instead of using pre-made themes

5. **Contribute to open-source desktop environment projects**

6. **Share your dotfiles on GitHub** and engage with the customization community

7. **Learn about compositor effects** for eye candy and functionality

8. **Create custom application themes** for programs you use frequently

Remember that mastering your desktop environment is an ongoing process. Keep refining and optimizing as your needs and preferences evolve!

## Acknowledgements

These exercises were developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Exercise structure and organization
- Resource recommendations
- Project suggestions

Claude was used as a development aid while all final implementation decisions and verification were performed by Joshua Michael Hall.

## Disclaimer

These exercises are provided "as is", without warranty of any kind. Always back up important data before making system changes.
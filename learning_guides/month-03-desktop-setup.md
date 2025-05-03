# Month 3: Desktop Environment and Workflow Setup

This month focuses on transforming your base Arch Linux installation into a customized, efficient desktop environment for professional software development. You'll learn to configure window managers, essential desktop applications, and optimize your workflow.

## Time Commitment: ~10 hours/week for 4 weeks

## Learning Objectives

By the end of this month, you should be able to:

1. Install and configure a window manager (i3, Sway, or Hyprland)
2. Set up a complete desktop environment with essential applications
3. Configure display, audio, and input devices
4. Customize visual appearance with themes and fonts
5. Create efficient keyboard-driven workflows
6. Optimize system resource usage for desktop applications

## Week 1: X11/Wayland and Window Manager Basics

### Core Learning Activities

1. **Understanding Display Servers** (2 hours)
   - Learn about X11 vs. Wayland
   - Understand the display server architecture
   - Choose between X11 and Wayland for your setup
   - Study the role of the display server in the graphics stack
   - Learn about the history and future of display servers

2. **Window Manager Concepts** (2 hours)
   - Understand tiling vs. floating window managers
   - Learn about compositor functions
   - Differentiate between window managers and desktop environments
   - Explore stacking, tiling, and dynamic window management paradigms
   - Study window manager components and architecture

3. **Installing Your Window Manager** (3 hours)
   - Choose between i3, Sway, or Hyprland
   - Install the necessary packages
   - Set up initial configuration files
   - Configure a display manager (LightDM, SDDM)
   - Understand window manager initialization

4. **Basic Window Manager Usage** (3 hours)
   - Learn core keybindings and commands
   - Practice window management operations
   - Understand workspaces and layouts
   - Master basic navigation
   - Create and switch between window arrangements

### Practical Exercises

#### Install and Configure i3 Window Manager (X11)

1. Install i3 and related packages:

```bash
sudo pacman -S i3-gaps i3status i3blocks dmenu feh picom xorg-xrandr xorg-xinit
```

2. Create a basic .xinitrc file:

```bash
echo '#!/bin/bash
exec i3' > ~/.xinitrc
chmod +x ~/.xinitrc
```

3. Install and configure a display manager:

```bash
sudo pacman -S lightdm lightdm-gtk-greeter
sudo systemctl enable lightdm
```

4. Create the default i3 configuration:

```bash
mkdir -p ~/.config/i3
cp /etc/i3/config ~/.config/i3/config
```

5. Edit the i3 configuration:

```bash
nano ~/.config/i3/config
```

Add or modify these essential configurations:

```
# Set modifier key (Mod1=Alt, Mod4=Windows key)
set $mod Mod4

# Start a terminal
bindsym $mod+Return exec alacritty

# Kill focused window
bindsym $mod+Shift+q kill

# Start dmenu (program launcher)
bindsym $mod+d exec dmenu_run

# Change focus
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right

# Move focused window
bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right

# Split in horizontal orientation
bindsym $mod+b split h

# Split in vertical orientation
bindsym $mod+v split v

# Enter fullscreen mode
bindsym $mod+f fullscreen toggle

# Change container layout
bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split

# Toggle tiling / floating
bindsym $mod+Shift+space floating toggle

# Change focus between tiling / floating windows
bindsym $mod+space focus mode_toggle

# Workspaces
bindsym $mod+1 workspace 1
bindsym $mod+2 workspace 2
# ... (additional workspaces)

# Move focused container to workspace
bindsym $mod+Shift+1 move container to workspace 1
bindsym $mod+Shift+2 move container to workspace 2
# ... (additional workspaces)

# Reload/restart i3
bindsym $mod+Shift+c reload
bindsym $mod+Shift+r restart

# Exit i3
bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'Exit i3?' -B 'Yes' 'i3-msg exit'"

# Resize mode
mode "resize" {
        bindsym h resize shrink width 10 px or 10 ppt
        bindsym j resize grow height 10 px or 10 ppt
        bindsym k resize shrink height 10 px or 10 ppt
        bindsym l resize grow width 10 px or 10 ppt
        
        # Back to normal
        bindsym Return mode "default"
        bindsym Escape mode "default"
        bindsym $mod+r mode "default"
}
bindsym $mod+r mode "resize"

# Startup applications
exec --no-startup-id picom -b
exec --no-startup-id feh --bg-fill ~/Pictures/wallpaper.jpg
exec --no-startup-id nm-applet
```

#### Install and Configure Sway (Wayland)

1. Install Sway and related packages:

```bash
sudo pacman -S sway swaylock swayidle waybar wofi wl-clipboard
```

2. Create the configuration directory:

```bash
mkdir -p ~/.config/sway
cp /etc/sway/config ~/.config/sway/
```

3. Edit the Sway configuration:

```bash
nano ~/.config/sway/config
```

Add or modify these essential configurations:

```
# Set modifier key (Mod1=Alt, Mod4=Windows key)
set $mod Mod4

# Terminal emulator
set $term alacritty

# Application launcher
set $menu wofi --show=drun

# Output configuration (monitors)
output * bg ~/Pictures/wallpaper.jpg fill

# Example output configuration:
# output HDMI-A-1 resolution 1920x1080 position 1920,0

# Input configuration
input type:touchpad {
    tap enabled
    natural_scroll enabled
    middle_emulation enabled
}

input type:keyboard {
    xkb_layout us
    xkb_options caps:escape
}

# Key bindings
bindsym $mod+Return exec $term
bindsym $mod+Shift+q kill
bindsym $mod+d exec $menu

# Drag floating windows
floating_modifier $mod normal

# Reload configuration
bindsym $mod+Shift+c reload

# Exit sway
bindsym $mod+Shift+e exec swaynag -t warning -m 'Exit sway?' -b 'Yes' 'swaymsg exit'

# Moving around
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right

# Move focused window
bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right

# Workspaces
bindsym $mod+1 workspace number 1
bindsym $mod+2 workspace number 2
# ... (additional workspaces)

# Move focused container to workspace
bindsym $mod+Shift+1 move container to workspace number 1
bindsym $mod+Shift+2 move container to workspace number 2
# ... (additional workspaces)

# Layout
bindsym $mod+b splith
bindsym $mod+v splitv
bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split
bindsym $mod+f fullscreen
bindsym $mod+Shift+space floating toggle
bindsym $mod+space focus mode_toggle
bindsym $mod+a focus parent

# Status Bar
bar {
    swaybar_command waybar
}

# Idle configuration
exec swayidle -w \
         timeout 300 'swaylock -f -c 000000' \
         timeout 600 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
         before-sleep 'swaylock -f -c 000000'
```

4. Create a Waybar configuration:

```bash
mkdir -p ~/.config/waybar
nano ~/.config/waybar/config
```

Add this basic configuration:

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

5. Create Waybar style:

```bash
nano ~/.config/waybar/style.css
```

Add a basic style:

```css
* {
    border: none;
    border-radius: 0;
    font-family: "Source Code Pro", monospace;
    font-size: 14px;
    min-height: 0;
}

window#waybar {
    background-color: rgba(43, 48, 59, 0.9);
    color: #ffffff;
    transition-property: background-color;
    transition-duration: .5s;
}

#workspaces button {
    padding: 0 5px;
    background-color: transparent;
    color: #ffffff;
}

#workspaces button:hover {
    background: rgba(0, 0, 0, 0.2);
}

#workspaces button.focused {
    background-color: #64727D;
}

#mode {
    background-color: #64727D;
    border-bottom: 3px solid #ffffff;
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
    background-color: #ffbe6f;
    color: black;
}

#battery.critical {
    background-color: #f53c3c;
    color: #ffffff;
}

#network.disconnected {
    background-color: #f53c3c;
}
```

### Resources

- [ArchWiki - Xorg](https://wiki.archlinux.org/title/Xorg)
- [ArchWiki - Wayland](https://wiki.archlinux.org/title/Wayland)
- [ArchWiki - Window Managers](https://wiki.archlinux.org/title/Window_manager)
- [i3 User Guide](https://i3wm.org/docs/userguide.html)
- [Sway Wiki](https://github.com/swaywm/sway/wiki)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Display Server Architecture](https://wayland-book.com/)
- [X.org Documentation](https://www.x.org/wiki/Documentation/)

## Week 2: Desktop Environment Configuration

### Core Learning Activities

1. **Display Configuration** (2 hours)
   - Configure monitor resolution and arrangement
   - Set up HiDPI settings if needed
   - Configure refresh rates and color profiles
   - Set up screen locking and power management
   - Learn about display scaling and fractional scaling
   - Configure multiple monitor workflows

2. **Input Device Configuration** (2 hours)
   - Configure keyboard layouts and shortcuts
   - Set up mouse/touchpad settings
   - Configure special input devices if needed
   - Set up input method for multiple languages (if needed)
   - Optimize input device settings for productivity
   - Implement custom key mappings

3. **Audio Setup** (2 hours)
   - Configure PulseAudio or PipeWire
   - Set up audio devices and default output
   - Configure media keys
   - Troubleshoot common audio issues
   - Implement automated audio switching
   - Set up audio visualization tools

4. **Essential Desktop Applications** (4 hours)
   - Install and configure a terminal emulator (Alacritty, Kitty)
   - Set up application launcher (dmenu, rofi)
   - Configure file manager (pcmanfm, ranger)
   - Set up web browser with developer tools
   - Configure notification system (dunst)
   - Add system monitoring tools
   - Set up screenshot and screen recording applications

### Practical Exercises

#### Display Configuration

1. Install necessary tools:

```bash
sudo pacman -S arandr autorandr
```

2. For X11, create a display configuration script:

```bash
nano ~/.screenlayout/dual-monitor.sh
```

Add content (adapt to your setup):
```bash
#!/bin/bash
xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output HDMI-1 --mode 1920x1080 --pos 1920x0 --rotate normal
```

3. Make it executable:

```bash
chmod +x ~/.screenlayout/dual-monitor.sh
```

4. Add to i3 config to run at startup:

```bash
echo 'exec --no-startup-id ~/.screenlayout/dual-monitor.sh' >> ~/.config/i3/config
```

5. For Sway, add to configuration:

```
# Monitor configuration
output eDP-1 resolution 1920x1080 position 0,0
output HDMI-A-1 resolution 1920x1080 position 1920,0
```

6. For HiDPI scaling in X11, add to ~/.Xresources:

```
Xft.dpi: 144
```

7. For HiDPI in Sway:

```
output eDP-1 scale 1.5
```

#### Input Device Configuration

1. Configure keyboard layout in X11:

```bash
localectl set-x11-keymap us pc105 intl
```

2. For Sway, add to config:

```
input type:keyboard {
    xkb_layout "us"
    xkb_variant "intl"
    xkb_options "caps:escape"
}
```

3. Configure touchpad for X11:

```bash
sudo nano /etc/X11/xorg.conf.d/30-touchpad.conf
```

Add:
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

4. For Sway, add to config:

```
input type:touchpad {
    tap enabled
    natural_scroll enabled
    dwt enabled
    click_method clickfinger
}
```

#### Audio Configuration

1. Install audio packages:

```bash
sudo pacman -S pulseaudio pulseaudio-alsa pulsemixer pavucontrol
# Or for PipeWire:
sudo pacman -S pipewire pipewire-pulse wireplumber pavucontrol
```

2. Configure media keys in i3:

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

3. Set up default audio device:

```bash
nano ~/.config/pulse/default.pa
```

Add or modify:
```
set-default-sink alsa_output.pci-0000_00_1f.3.analog-stereo
set-default-source alsa_input.pci-0000_00_1f.3.analog-stereo
```

#### Essential Desktop Applications

1. Install a modern terminal emulator:

```bash
sudo pacman -S alacritty
```

2. Configure Alacritty:

```bash
mkdir -p ~/.config/alacritty
nano ~/.config/alacritty/alacritty.yml
```

Add basic configuration:
```yaml
window:
  padding:
    x: 10
    y: 10
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
  size: 12.0

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

3. Install and configure a file manager:

```bash
sudo pacman -S pcmanfm
```

4. Install and configure a notification daemon:

```bash
sudo pacman -S dunst
mkdir -p ~/.config/dunst
cp /etc/dunst/dunstrc ~/.config/dunst/
```

5. Edit dunstrc:

```bash
nano ~/.config/dunst/dunstrc
```

Customize with:
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
    min_icon_size = 0
    max_icon_size = 32
    sticky_history = yes
    history_length = 20
    browser = /usr/bin/firefox -new-tab
    always_run_script = true
    title = Dunst
    class = Dunst

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

6. Install and configure Rofi (modern application launcher):

```bash
sudo pacman -S rofi
mkdir -p ~/.config/rofi
nano ~/.config/rofi/config.rasi
```

Add configuration:
```css
configuration {
    modi: "drun,run,window,ssh";
    font: "JetBrains Mono 12";
    show-icons: true;
    icon-theme: "Papirus";
    terminal: "alacritty";
    drun-display-format: "{icon} {name}";
    location: 0;
    disable-history: false;
    hide-scrollbar: true;
    display-drun: "Applications";
    display-run: "Commands";
    display-window: "Windows";
    display-ssh: "SSH";
    sidebar-mode: true;
}

@theme "dracula"

element {
    padding: 8px;
    spacing: 10px;
}
```

7. Connect to i3 by updating config:

```
# Application launcher
bindsym $mod+d exec --no-startup-id rofi -show drun
```

### Resources

- [ArchWiki - HiDPI](https://wiki.archlinux.org/title/HiDPI)
- [ArchWiki - Xorg/Keyboard configuration](https://wiki.archlinux.org/title/Xorg/Keyboard_configuration)
- [ArchWiki - PulseAudio](https://wiki.archlinux.org/title/PulseAudio)
- [ArchWiki - PipeWire](https://wiki.archlinux.org/title/PipeWire)
- [Alacritty Documentation](https://github.com/alacritty/alacritty/blob/master/docs/features.md)
- [Rofi Documentation](https://github.com/davatorium/rofi/wiki)
- [Libinput Documentation](https://wayland.freedesktop.org/libinput/doc/latest/)
- [Dunst Documentation](https://dunst-project.org/documentation/)

## Week 3: Visual Customization and Workflow Optimization

### Core Learning Activities

1. **Theme Configuration** (2 hours)
   - Set up GTK and Qt themes
   - Configure icon themes
   - Apply consistent theming across applications
   - Customize borders, transparency, and animations
   - Create a cohesive visual experience
   - Implement theme switching mechanisms

2. **Font Configuration** (2 hours)
   - Install and configure system fonts
   - Set up font rendering
   - Configure monospace fonts for development
   - Implement proper Unicode and emoji support
   - Optimize font legibility and aesthetics
   - Ensure consistent font rendering across applications

3. **Status Bar and Widgets** (3 hours)
   - Configure status bar (i3status, waybar)
   - Add system information widgets
   - Create custom scripts for relevant data
   - Style status bar to match your theme
   - Implement interactive elements
   - Add notification indicators

4. **Workflow Optimization** (3 hours)
   - Create custom keybindings for frequent tasks
   - Configure application auto-start
   - Set up screen layout presets
   - Create workspace organization rules
   - Implement window placement rules
   - Create task-oriented workspace configurations

### Practical Exercises

#### Theme Configuration

1. Install themes and dependencies:

```bash
sudo pacman -S arc-gtk-theme papirus-icon-theme lxappearance qt5ct
```

2. Configure Qt applications to use GTK themes:

```bash
sudo nano /etc/environment
```

Add:
```
QT_QPA_PLATFORMTHEME=qt5ct
```

3. Configure GTK themes:

```bash
nano ~/.config/gtk-3.0/settings.ini
```

Add:
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

4. For older GTK applications:

```bash
nano ~/.gtkrc-2.0
```

Add:
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

5. Configure Qt themes (run `qt5ct` after logout/login):

```bash
qt5ct
```

Select matching themes and fonts in the Qt application.

#### Font Configuration

1. Install essential fonts:

```bash
sudo pacman -S ttf-dejavu ttf-liberation noto-fonts noto-fonts-emoji ttf-jetbrains-mono
```

2. Configure font rendering:

```bash
sudo nano /etc/fonts/local.conf
```

Add:
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

3. Update font cache:

```bash
fc-cache -fv
```

#### Status Bar Configuration

1. For i3, create a custom i3status configuration:

```bash
mkdir -p ~/.config/i3status
nano ~/.config/i3status/config
```

Add:
```
general {
    colors = true
    interval = 5
    color_good = "#2AA198"
    color_degraded = "#B58900"
    color_bad = "#DC322F"
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

2. Reference this in i3 config:

```
bar {
    status_command i3status -c ~/.config/i3status/config
    position top
    tray_output primary
    colors {
        background #282A36
        statusline #F8F8F2
        separator  #44475A

        # class            border  backgr. text
        focused_workspace  #44475A #44475A #F8F8F2
        active_workspace   #282A36 #44475A #F8F8F2
        inactive_workspace #282A36 #282A36 #BFBFBF
        urgent_workspace   #FF5555 #FF5555 #F8F8F2
        binding_mode       #FF5555 #FF5555 #F8F8F2
    }
}
```

3. Create a custom script for additional status info:

```bash
mkdir -p ~/scripts
nano ~/scripts/weather.sh
```

Add:
```bash
#!/bin/bash
# Simple weather script for status bar

LOCATION="YourCity"
WEATHER_INFO=$(curl -s "wttr.in/$LOCATION?format=%C+%t")

echo "$WEATHER_INFO"
```

Make executable:
```bash
chmod +x ~/scripts/weather.sh
```

4. Add to i3blocks configuration for more customization:

```bash
sudo pacman -S i3blocks
mkdir -p ~/.config/i3blocks
nano ~/.config/i3blocks/config
```

Add:
```
# i3blocks config file

# Global properties
command=$SCRIPT_DIR/$BLOCK_NAME
separator_block_width=15
markup=none

[weather]
command=~/scripts/weather.sh
interval=900
color=#A4C2F4

[cpu]
label=CPU
command=grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf "%.1f%\n", usage}'
interval=10
color=#00FF00

[memory]
label=MEM
command=free -h | awk '/^Mem:/ {print $3 "/" $2}'
interval=30
color=#FFFF00

[disk]
label=HOME
command=df -h | awk '/\/$/ {print $4}'
interval=30
color=#FFA500

[wifi]
label=WiFi
command=iwgetid -r || echo "disconnected"
interval=10
color=#00FFFF

[battery]
label=BAT
command=acpi | cut -d " " -f4 | sed 's/,//g'
interval=30
color=#FF69B4

[volume]
label=VOL
command=amixer get Master | grep -E -o '[0-9]{1,3}%' | head -1
interval=1
signal=10
color=#F8F8F2

[time]
command=date '+%Y-%m-%d %H:%M:%S'
interval=1
color=#FFFFFF
```

5. Update i3 config to use i3blocks:

```
bar {
    status_command i3blocks -c ~/.config/i3blocks/config
    position top
    # ... rest of bar configuration
}
```

#### Workflow Optimization

1. Create custom keybindings for applications:

```
# Application shortcuts
bindsym $mod+b exec firefox
bindsym $mod+n exec pcmanfm
bindsym $mod+m exec thunderbird
bindsym $mod+c exec code
bindsym $mod+Shift+s exec flameshot gui
```

2. Create workspace assignments for applications:

```
# Assign applications to specific workspaces
assign [class="Firefox"] 2
assign [class="code-oss"] 3
assign [class="Thunderbird"] 4
assign [class="Spotify"] 5
```

3. Create a script for predefined layouts:

```bash
nano ~/scripts/coding-layout.sh
```

Add:
```bash
#!/bin/bash
# Set up coding workspace layout

# Move to workspace 3
i3-msg workspace 3

# Start code editor
i3-msg exec code

# Split horizontally
i3-msg split h

# Start terminal
i3-msg exec alacritty

# Adjust split (60/40)
i3-msg resize grow width 20 px or 20 ppt
```

Make executable:
```bash
chmod +x ~/scripts/coding-layout.sh
```

4. Add a keybinding to activate the layout:

```
# Custom layout
bindsym $mod+Shift+l exec ~/scripts/coding-layout.sh
```

### Resources

- [ArchWiki - Uniform Look for Qt and GTK Applications](https://wiki.archlinux.org/title/Uniform_look_for_Qt_and_GTK_applications)
- [ArchWiki - Font Configuration](https://wiki.archlinux.org/title/Font_configuration)
- [i3status Documentation](https://i3wm.org/i3status/manpage.html)
- [i3blocks Documentation](https://github.com/vivien/i3blocks)
- [Waybar Wiki](https://github.com/Alexays/Waybar/wiki)
- [Reddit Community: r/unixporn](https://www.reddit.com/r/unixporn/)
- [Arc Theme Documentation](https://github.com/jnsh/arc-theme)
- [Font Rendering in Linux](https://wiki.archlinux.org/title/font_configuration)

## Week 4: Workflow Integration and Resource Management

### Core Learning Activities

1. **Application Integration** (3 hours)
   - Configure default applications
   - Set up application associations
   - Integrate clipboard managers
   - Configure screenshot and screen recording tools
   - Set up browser integration with system
   - Implement seamless file handling

2. **System Resource Optimization** (2 hours)
   - Monitor resource usage (htop, btop)
   - Optimize startup services for desktop usage
   - Configure swap and memory management
   - Balance performance and battery life
   - Implement power management profiles
   - Configure CPU scaling for different scenarios

3. **Backup and Restore Your Configuration** (2 hours)
   - Create a backup strategy for dotfiles
   - Learn about stow or other dotfile management tools
   - Set up a git repository for your configurations
   - Document your customizations
   - Implement versioning for configuration files
   - Create a restoration script

4. **Automation and Convenience Scripts** (3 hours)
   - Create scripts for recurring desktop tasks
   - Configure hotkeys for scripts
   - Implement screen layout management
   - Create session management scripts
   - Build task-specific automation
   - Develop notification integrations

### Practical Exercises

#### Default Application Configuration

1. Create a MIME applications file:

```bash
mkdir -p ~/.config/mimeapps.list
nano ~/.config/mimeapps.list
```

Add:
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

2. Install and configure a clipboard manager:

```bash
sudo pacman -S clipmenu
```

Add to i3 config:
```
# Clipboard manager
exec --no-startup-id clipmenud
bindsym $mod+p exec --no-startup-id clipmenu
```

3. Install and configure a screenshot tool:

```bash
sudo pacman -S flameshot
```

Add to i3 config:
```
# Screenshot
bindsym Print exec --no-startup-id flameshot gui
bindsym $mod+Print exec --no-startup-id flameshot full -c
```

#### System Resource Optimization

1. Install monitoring tools:

```bash
sudo pacman -S htop btop powertop
```

2. Create a power management script:

```bash
nano ~/scripts/power-profile.sh
```

Add:
```bash
#!/bin/bash

case "$1" in
    performance)
        sudo cpupower frequency-set -g performance
        # Set screen brightness to max
        xbacklight -set 100
        # Disable auto-suspend
        systemctl --user mask sleep.target suspend.target
        notify-send "Power Profile" "Set to Performance Mode"
        ;;
    balanced)
        sudo cpupower frequency-set -g schedutil
        # Set brightness to 70%
        xbacklight -set 70
        # Enable auto-suspend after 30 min
        systemctl --user unmask sleep.target suspend.target
        gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 1800
        notify-send "Power Profile" "Set to Balanced Mode"
        ;;
    powersave)
        sudo cpupower frequency-set -g powersave
        # Set brightness to 40%
        xbacklight -set 40
        # Enable auto-suspend after 10 min
        systemctl --user unmask sleep.target suspend.target
        gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 600
        notify-send "Power Profile" "Set to Power Saving Mode"
        ;;
    *)
        echo "Usage: $0 {performance|balanced|powersave}"
        exit 1
esac
```

Make executable:
```bash
chmod +x ~/scripts/power-profile.sh
```

Add keybindings to i3 config:
```
# Power profiles
bindsym $mod+F1 exec --no-startup-id ~/scripts/power-profile.sh performance
bindsym $mod+F2 exec --no-startup-id ~/scripts/power-profile.sh balanced
bindsym $mod+F3 exec --no-startup-id ~/scripts/power-profile.sh powersave
```

3. Optimize startup applications:

```bash
systemctl --user disable $(systemctl --user list-unit-files --state=enabled | grep -v "service\|target" | awk '{print $1}')
```

Then selectively enable only what you need:
```bash
systemctl --user enable pulseaudio.service
```

#### Dotfile Management with Stow

1. Install GNU Stow:

```bash
sudo pacman -S stow
```

2. Create a dotfiles structure:

```bash
mkdir -p ~/dotfiles/{i3,alacritty,zsh,neovim,tmux,dunst}
```

3. Move configuration files to this structure:

```bash
# For i3 config
mkdir -p ~/dotfiles/i3/.config/i3
cp ~/.config/i3/config ~/dotfiles/i3/.config/i3/

# For alacritty
mkdir -p ~/dotfiles/alacritty/.config/alacritty
cp ~/.config/alacritty/alacritty.yml ~/dotfiles/alacritty/.config/alacritty/

# Continue for other configs...
```

4. Use stow to create symlinks:

```bash
cd ~/dotfiles
stow i3 alacritty zsh neovim tmux dunst
```

5. Create a dotfiles Git repository:

```bash
cd ~/dotfiles
git init
git add .
git commit -m "Initial dotfiles commit"
```

6. Create a setup script:

```bash
nano ~/dotfiles/setup.sh
```

Add:
```bash
#!/bin/bash
# Dotfiles setup script

DOTFILES_DIR="$HOME/dotfiles"

# Check if stow is installed
if ! command -v stow &> /dev/null; then
    echo "GNU Stow is required. Please install it first."
    exit 1
fi

# Navigate to dotfiles directory
cd "$DOTFILES_DIR" || exit 1

# Create backup of existing configs
mkdir -p "$HOME/dotfiles_backup"
for dir in */; do
    dir=${dir%/}
    echo "Processing $dir..."
    for file in $(find "$dir" -type f | sed "s|$dir/||"); do
        target="$HOME/$file"
        if [ -e "$target" ]; then
            mkdir -p "$(dirname "$HOME/dotfiles_backup/$file")"
            mv "$target" "$HOME/dotfiles_backup/$file"
            echo "Backed up: $target"
        fi
    done
    
    # Stow the directory
    stow -v "$dir"
done

echo "Dotfiles setup complete!"
```

Make executable:
```bash
chmod +x ~/dotfiles/setup.sh
```

#### Automation Scripts

1. Create a workspace setup script:

```bash
nano ~/scripts/work-session.sh
```

Add:
```bash
#!/bin/bash
# Set up a complete work environment

# Move to workspace 1 (terminal)
i3-msg workspace 1
i3-msg exec alacritty

# Move to workspace 2 (browser)
i3-msg workspace 2
i3-msg exec firefox

# Move to workspace 3 (code)
i3-msg workspace 3
i3-msg exec code

# Move to workspace 4 (communication)
i3-msg workspace 4
i3-msg exec "thunderbird"
sleep 3
i3-msg exec "signal-desktop"

# Back to workspace 1
i3-msg workspace 1

# Notification
notify-send "Work Session" "Environment has been set up"
```

Make executable:
```bash
chmod +x ~/scripts/work-session.sh
```

2. Create a display management script:

```bash
nano ~/scripts/display-manager.sh
```

Add:
```bash
#!/bin/bash
# Display management script

EXTERNAL_MONITOR="HDMI-1"

function connect_display() {
    xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal \
           --output $EXTERNAL_MONITOR --mode 1920x1080 --pos 1920x0 --rotate normal
    # Move workspace 2 and 3 to external monitor
    i3-msg "workspace 2; move workspace to output $EXTERNAL_MONITOR"
    i3-msg "workspace 3; move workspace to output $EXTERNAL_MONITOR"
}

function disconnect_display() {
    # Move all workspaces back to primary
    for i in {1..9}; do
        i3-msg "workspace $i; move workspace to output eDP-1"
    done
    xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal \
           --output $EXTERNAL_MONITOR --off
}

function mirror_display() {
    xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal \
           --output $EXTERNAL_MONITOR --mode 1920x1080 --same-as eDP-1
}

case "$1" in
    connect)
        connect_display
        ;;
    disconnect)
        disconnect_display
        ;;
    mirror)
        mirror_display
        ;;
    auto)
        # Check if external monitor is connected
        if xrandr | grep "$EXTERNAL_MONITOR connected"; then
            connect_display
        else
            disconnect_display
        fi
        ;;
    *)
        echo "Usage: $0 {connect|disconnect|mirror|auto}"
        exit 1
esac

notify-send "Display Manager" "Display configuration applied"
```

Make executable:
```bash
chmod +x ~/scripts/display-manager.sh
```

Add to i3 config for automatic execution:
```
# Auto-detect displays on startup
exec --no-startup-id ~/scripts/display-manager.sh auto

# Display management keybindings
bindsym $mod+Shift+d exec --no-startup-id ~/scripts/display-manager.sh connect
bindsym $mod+Shift+a exec --no-startup-id ~/scripts/display-manager.sh disconnect
bindsym $mod+Shift+m exec --no-startup-id ~/scripts/display-manager.sh mirror
```

### Resources

- [ArchWiki - Default Applications](https://wiki.archlinux.org/title/Default_applications)
- [ArchWiki - Power Management](https://wiki.archlinux.org/title/Power_management)
- [GNU Stow Documentation](https://www.gnu.org/software/stow/manual/)
- [Example Dotfiles Repositories](https://github.com/topics/dotfiles)
- [i3wm User Guide - Scripting](https://i3wm.org/docs/user-contributed/swapping-workspaces.html)
- [ArchWiki - XDG MIME Applications](https://wiki.archlinux.org/title/XDG_MIME_Applications)
- [Dotfiles Management Guide](https://www.atlassian.com/git/tutorials/dotfiles)
- [Power Management in Linux](https://wiki.archlinux.org/title/CPU_frequency_scaling)

## Projects and Exercises

1. **Custom Desktop Environment**
   - Create a fully customized desktop environment
   - Implement consistent theming across applications
   - Configure efficient workflows with keybindings
   - Document your complete configuration
   - Create a demonstration video or screenshots

2. **Dotfiles Repository**
   - Create a Git repository for your configuration files
   - Implement a structure that works across systems
   - Add installation/bootstrap scripts
   - Document the purpose of each configuration file
   - Make it easy to deploy on a new system

3. **Status Bar Enhancement**
   - Create custom status bar modules for relevant information
   - Implement interactive elements (clickable areas)
   - Add weather, system stats, or other useful information
   - Ensure consistent styling with your desktop theme
   - Create a unique and functional status bar layout

4. **Workflow Automation Project**
   - Create scripts to automate common development tasks
   - Integrate with your window manager keybindings
   - Include project switching, terminal setup, etc.
   - Document usage and implementation
   - Build task-oriented workspace configurations

## Cross-References

- **Previous Month**: [Month 2: System Configuration and Package Management](month-02-system-config.md) - Foundation for desktop configuration
- **Next Month**: [Month 4: Terminal Tools and Shell Customization](month-04-terminal-tools.md) - Will build on your desktop environment with a powerful terminal setup
- **Related Guides**: 
  - [Troubleshooting Guide](/troubleshooting/README.md) - For resolving desktop environment issues
  - [Graphics Troubleshooting](/troubleshooting/graphics.md) - For graphics-related problems
  - [System Monitor Project](/projects/system-monitor/README.md) - A practical project that uses window management concepts
- **Reference Resources**:
  - [Linux Shortcuts & Commands Reference](linux-shortcuts.md) - For window manager shortcuts
  - [Linux Mastery Journey - Glossary](linux-glossary.md) - For desktop environment terminology

## Assessment

You should now be able to:

1. Configure and effectively use a window manager
2. Create a visually consistent desktop environment
3. Set up and customize all essential desktop applications
4. Optimize your workflow with keyboard shortcuts and automation
5. Manage system resources efficiently
6. Back up and version control your configurations

## Next Steps

In Month 4, we'll focus on:
- Advanced terminal usage and customization
- Shell scripting and automation
- Configuring the Z shell (Zsh) with frameworks
- Setting up Tmux for terminal multiplexing
- Creating an integrated terminal workflow

## Acknowledgements

This learning guide was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Learning path structure and organization
- Resource recommendations
- Project suggestions

Claude was used as a development aid while all final implementation decisions and verification were performed by Joshua Michael Hall.

## Disclaimer

This guide is provided "as is", without warranty of any kind. Follow all instructions carefully and always make backups before making system changes.

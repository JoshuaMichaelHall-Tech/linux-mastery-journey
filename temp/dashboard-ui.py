"""
Dashboard Module for Linux System Monitor

This module handles the rendering of the main dashboard UI.
"""

import time
from typing import Dict, List, Optional

from blessed import Terminal

from monitor.config import Config
from monitor.ui.layout_manager import LayoutManager
from monitor.ui.widgets.cpu_widget import CPUWidget
from monitor.ui.widgets.memory_widget import MemoryWidget
from monitor.ui.widgets.disk_widget import DiskWidget
from monitor.ui.widgets.network_widget import NetworkWidget
from monitor.ui.widgets.process_widget import ProcessWidget


class Dashboard:
    """
    Main dashboard UI for the system monitor.
    
    This class is responsible for:
    - Initializing and managing UI components
    - Rendering the dashboard layout
    - Handling user input and navigation
    - Coordinating updates across widgets
    """
    
    def __init__(self, term: Terminal, layout_manager: LayoutManager, config: Config):
        """
        Initialize the dashboard.
        
        Args:
            term: Blessed Terminal instance
            layout_manager: Layout manager for UI components
            config: Application configuration
        """
        self.term = term
        self.layout_manager = layout_manager
        self.config = config
        
        # Initialize widgets
        # Note: In a full implementation, these widgets would be created properly
        # For now, we'll use placeholder functions for rendering
        self.widgets = {
            "cpu": {
                "render": self._render_cpu_placeholder,
                "data": {},
            },
            "memory": {
                "render": self._render_memory_placeholder,
                "data": {},
            },
            "disk": {
                "render": self._render_disk_placeholder,
                "data": {},
            },
            "network": {
                "render": self._render_network_placeholder,
                "data": {},
            },
            "processes": {
                "render": self._render_processes_placeholder,
                "data": {},
            },
        }
        
        # Set the active widget (for navigation)
        self.active_widget = "cpu"
        
        # Initialize help panel data
        self.show_help = False
        
        # Initialize alert list
        self.alerts = []
    
    def update(self, data: Dict):
        """
        Update the dashboard with new data.
        
        Args:
            data: Dictionary containing processed system data
        """
        # Update each widget's data
        for widget_name in self.widgets:
            if widget_name in data:
                self.widgets[widget_name]["data"] = data[widget_name]
        
        # Update alerts
        if "alerts" in data:
            self.update_alerts(data["alerts"])
        
        # Render the dashboard
        self.render()
    
    def render(self):
        """Render the complete dashboard."""
        # Clear the screen
        print(self.term.clear)
        
        # Get screen dimensions
        height, width = self.term.height, self.term.width
        
        # Print header
        self._render_header()
        
        # Get layout for current display mode
        layout = self.layout_manager.get_layout(width, height)
        
        # Render each widget according to layout
        for widget_name, widget_layout in layout.items():
            if widget_name in self.widgets:
                # Set cursor position and render widget
                x, y, w, h = widget_layout
                with self.term.location(x, y):
                    self.widgets[widget_name]["render"](w, h, self.widgets[widget_name]["data"])
        
        # Render help panel if active
        if self.show_help:
            self._render_help_panel()
        
        # Render alerts if any
        if self.alerts:
            self._render_alerts()
        
        # Move cursor to bottom
        print(self.term.move(height - 1, 0))
    
    def update_alerts(self, alerts: Dict):
        """Update alert list from new data."""
        # Clear expired alerts
        current_time = time.time()
        self.alerts = [alert for alert in self.alerts if current_time - alert["time"] < 60]
        
        # Add new alerts
        for resource, alert_data in alerts.items():
            # Only add if level is warning or critical
            if alert_data["level"] in ["warning", "critical"]:
                self.alerts.append({
                    "resource": resource,
                    "level": alert_data["level"],
                    "message": alert_data["message"],
                    "time": current_time,
                })
    
    def _render_header(self):
        """Render the dashboard header."""
        # Get current time
        current_time = time.strftime("%H:%M:%S", time.localtime())
        current_date = time.strftime("%Y-%m-%d", time.localtime())
        
        # Create header
        header = f"Linux System Monitor  |  {current_date} {current_time}  |  Press 'q' to quit, 'h' for help"
        
        # Print centered header with background
        print(self.term.home + self.term.black_on_white + self.term.center(header) + self.term.normal)
    
    def _render_help_panel(self):
        """Render the help panel overlay."""
        # Create a centered box
        width = min(60, self.term.width - 4)
        height = min(15, self.term.height - 4)
        x = (self.term.width - width) // 2
        y = (self.term.height - height) // 2
        
        # Draw box
        with self.term.location(x, y):
            print(self.term.white_on_blue + " " * width)
            print(self.term.center("Help") + self.term.normal)
            
            # Print help content
            help_content = [
                "",
                "q - Quit the application",
                "h - Toggle help panel",
                "1-4 - Switch between different views",
                "↑/↓ - Navigate process list",
                "p - Sort processes by CPU usage",
                "m - Sort processes by memory usage",
                "d - Sort processes by disk I/O",
                "s - Take a snapshot of current stats",
                "c - Toggle color mode",
                "r - Reset statistics",
                "",
                "Press any key to close help"
            ]
            
            for i, line in enumerate(help_content):
                if i < height - 2:  # Ensure we don't go beyond the box
                    with self.term.location(x + 2, y + i + 2):
                        print(line)
    
    def _render_alerts(self):
        """Render alert notifications."""
        # Only show the last 3 alerts
        display_alerts = self.alerts[-3:]
        
        # Draw alert box at the bottom
        width = min(50, self.term.width - 4)
        height = len(display_alerts) + 2
        x = self.term.width - width - 2
        y = self.term.height - height - 1
        
        with self.term.location(x, y):
            # Title bar
            print(self.term.white_on_red + " " * width)
            print(self.term.center("Alerts") + self.term.normal)
            
            # Alert content
            for i, alert in enumerate(display_alerts):
                level_color = self.term.red if alert["level"] == "critical" else self.term.yellow
                with self.term.location(x + 1, y + i + 2):
                    print(f"{level_color}{alert['resource'].upper()}: {alert['message']}{self.term.normal}")
    
    # Placeholder rendering functions for widgets
    # In a full implementation, these would be replaced by proper widget classes
    
    def _render_cpu_placeholder(self, width: int, height: int, data: Dict):
        """Render CPU widget placeholder."""
        # Draw border
        print("┌" + "─" * (width - 2) + "┐")
        
        # Title
        title = " CPU Usage "
        padding = (width - len(title) - 2) // 2
        print("│" + " " * padding + self.term.bold(title) + " " * (width - 2 - padding - len(title)) + "│")
        
        # Usage bar
        usage_percent = data.get("usage_percent", 0)
        bar_width = width - 8
        filled = int(bar_width * usage_percent / 100)
        
        # Choose color based on usage
        if usage_percent > 90:
            bar_color = self.term.red
        elif usage_percent > 70:
            bar_color = self.term.yellow
        else:
            bar_color = self.term.green
        
        print("│ " + bar_color + "█" * filled + self.term.normal + "░" * (bar_width - filled) + f" {usage_percent:3.1f}% │")
        
        # Per-core info (if available)
        per_core = data.get("per_core_percent", [])
        if per_core and height > 6:
            print("│ " + " " * (width - 4) + " │")
            print("│ " + self.term.bold("Per Core:") + " " * (width - 12) + " │")
            
            # Display up to 4 cores per line
            cores_per_line = min(4, (width - 4) // 10)
            core_lines = (len(per_core) + cores_per_line - 1) // cores_per_line
            
            for i in range(min(core_lines, height - 7)):
                core_info = ""
                for j in range(cores_per_line):
                    core_idx = i * cores_per_line + j
                    if core_idx < len(per_core):
                        core_usage = per_core[core_idx]
                        core_info += f"C{core_idx}: {core_usage:4.1f}% "
                
                print("│ " + core_info + " " * (width - 2 - len(core_info)) + "│")
        
        # Draw bottom border
        for i in range(height - 5 - min(len(per_core) // 4 + 1, height - 7)):
            print("│" + " " * (width - 2) + "│")
        
        print("└" + "─" * (width - 2) + "┘")
    
    def _render_memory_placeholder(self, width: int, height: int, data: Dict):
        """Render memory widget placeholder."""
        # Draw border
        print("┌" + "─" * (width - 2) + "┐")
        
        # Title
        title = " Memory Usage "
        padding = (width - len(title) - 2) // 2
        print("│" + " " * padding + self.term.bold(title) + " " * (width - 2 - padding - len(title)) + "│")
        
        # Usage bar
        usage_percent = data.get("usage_percent", 0)
        bar_width = width - 8
        filled = int(bar_width * usage_percent / 100)
        
        # Choose color based on usage
        if usage_percent > 90:
            bar_color = self.term.red
        elif usage_percent > 70:
            bar_color = self.term.yellow
        else:
            bar_color = self.term.green
        
        print("│ " + bar_color + "█" * filled + self.term.normal + "░" * (bar_width - filled) + f" {usage_percent:3.1f}% │")
        
        # Memory details
        used = data.get("used", 0)
        total = data.get("total", 0)
        free = data.get("free", 0)
        
        print("│ " + " " * (width - 4) + " │")
        print(f"│ Used: {used:.1f} GB / Total: {total:.1f} GB " + " " * (width - 30) + " │")
        print(f"│ Free: {free:.1f} GB " + " " * (width - 17) + " │")
        
        # Draw bottom border
        for i in range(height - 7):
            print("│" + " " * (width - 2) + "│")
        
        print("└" + "─" * (width - 2) + "┘")
    
    def _render_disk_placeholder(self, width: int, height: int, data: Dict):
        """Render disk widget placeholder."""
        # Draw border
        print("┌" + "─" * (width - 2) + "┐")
        
        # Title
        title = " Disk I/O "
        padding = (width - len(title) - 2) // 2
        print("│" + " " * padding + self.term.bold(title) + " " * (width - 2 - padding - len(title)) + "│")
        
        # Usage percentage
        usage_percent = data.get("usage_percent", 0)
        print(f"│ Disk Usage: {usage_percent:.1f}% " + " " * (width - 19) + " │")
        
        # Read/Write speed
        read_speed = data.get("read_speed", 0)
        write_speed = data.get("write_speed", 0)
        
        print("│ " + " " * (width - 4) + " │")
        print(f"│ Read:  {read_speed:.1f} MB/s " + " " * (width - 19) + " │")
        print(f"│ Write: {write_speed:.1f} MB/s " + " " * (width - 19) + " │")
        
        # Draw bottom border
        for i in range(height - 8):
            print("│" + " " * (width - 2) + "│")
        
        print("└" + "─" * (width - 2) + "┘")
    
    def _render_network_placeholder(self, width: int, height: int, data: Dict):
        """Render network widget placeholder."""
        # Draw border
        print("┌" + "─" * (width - 2) + "┐")
        
        # Title
        title = " Network "
        padding = (width - len(title) - 2) // 2
        print("│" + " " * padding + self.term.bold(title) + " " * (width - 2 - padding - len(title)) + "│")
        
        # Download/Upload speed
        download_speed = data.get("download_speed", 0)
        upload_speed = data.get("upload_speed", 0)
        
        print("│ " + " " * (width - 4) + " │")
        print(f"│ ↓ Down: {download_speed:.2f} MB/s " + " " * (width - 20) + " │")
        print(f"│ ↑ Up:   {upload_speed:.2f} MB/s " + " " * (width - 20) + " │")
        
        # Draw bottom border
        for i in range(height - 7):
            print("│" + " " * (width - 2) + "│")
        
        print("└" + "─" * (width - 2) + "┘")
    
    def _render_processes_placeholder(self, width: int, height: int, data: Dict):
        """Render processes widget placeholder."""
        # Draw border
        print("┌" + "─" * (width - 2) + "┐")
        
        # Title
        title = " Processes "
        padding = (width - len(title) - 2) // 2
        print("│" + " " * padding + self.term.bold(title) + " " * (width - 2 - padding - len(title)) + "│")
        
        # Header
        print("│ " + self.term.bold("PID    CPU%  MEM%  Command") + " " * (width - 27) + " │")
        
        # Process list
        processes = data.get("processes", [])
        for i in range(min(len(processes), height - 5)):
            proc = processes[i]
            pid = proc.get("pid", 0)
            cpu = proc.get("cpu_percent", 0)
            mem = proc.get("memory_percent", 0)
            name = proc.get("name", "unknown")
            
            # Truncate name to fit
            max_name_len = width - 23
            if len(name) > max_name_len:
                name = name[:max_name_len - 3] + "..."
            
            print(f"│ {pid:5} {cpu:5.1f}% {mem:5.1f}% {name}" + " " * (width - 19 - len(name)) + " │")
        
        # Empty lines if fewer processes
        for i in range(height - 5 - min(len(processes), height - 5)):
            print("│" + " " * (width - 2) + "│")
        
        print("└" + "─" * (width - 2) + "┘")

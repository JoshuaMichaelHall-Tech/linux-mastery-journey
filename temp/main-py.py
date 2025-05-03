#!/usr/bin/env python3
"""
Linux System Monitor

A terminal-based system monitoring tool that provides real-time
visualization of system resources including CPU, memory, disk, and network usage.
"""

import os
import sys
import time
from typing import Dict, List, Optional, Union

import typer
from blessed import Terminal

# Import internal modules
from monitor.collectors.cpu import CPUCollector
from monitor.config import Config, expand_paths, validate_config
from monitor.processors.resource_processor import ResourceProcessor
from monitor.ui.dashboard import Dashboard
from monitor.ui.layout_manager import LayoutManager

# Create Typer app
app = typer.Typer(help="Terminal-based system monitoring tool for Linux")


@app.command()
def main(
    interval: float = typer.Option(1.0, "--interval", "-i", help="Update interval in seconds"),
    layout: str = typer.Option("detailed", "--layout", "-l", help="Layout type (detailed, compact, minimal)"),
    theme: str = typer.Option("dark", "--theme", "-t", help="Color theme (dark, light)"),
    config_path: Optional[str] = typer.Option(None, "--config", "-c", help="Path to configuration file"),
    log: bool = typer.Option(False, "--log", help="Enable logging to file"),
    export_csv: Optional[str] = typer.Option(None, "--export-csv", help="Export data to CSV file"),
):
    """
    Start the system monitor with the specified options.
    """
    # Initialize configuration
    config = Config(config_path=config_path)
    config.load()
    
    # Override config with command line arguments
    if interval != 1.0:
        config.general.update_interval = interval
    if layout != "detailed":
        config.display.layout = layout
    if theme != "dark":
        config.display.theme = theme
    if log:
        config.general.enable_logging = True
    
    # Expand path variables in configuration
    expand_paths(config)
    
    # Validate configuration
    errors = validate_config(config)
    if errors:
        for error in errors:
            typer.echo(f"Configuration error: {error}", err=True)
        sys.exit(1)
    
    # Initialize terminal
    term = Terminal()
    
    # Initialize collectors
    cpu_collector = CPUCollector()
    
    # TODO: Initialize other collectors:
    # - memory_collector = MemoryCollector()
    # - disk_collector = DiskCollector()
    # - network_collector = NetworkCollector()
    # - process_collector = ProcessCollector()
    
    # Initialize processor
    processor = ResourceProcessor()
    
    # Initialize layout manager
    layout_manager = LayoutManager(term, config.display.layout)
    
    # Initialize dashboard
    dashboard = Dashboard(term, layout_manager, config)
    
    try:
        # Print welcome message
        print(term.clear)
        print(term.home + term.white_on_blue + term.center("Linux System Monitor") + term.normal)
        print(term.center("Press 'q' to quit, 'h' for help") + "\n")
        
        # Main monitoring loop
        with term.cbreak(), term.hidden_cursor():
            while True:
                # Check for key presses
                if term.inkey(timeout=0) == 'q':
                    break
                
                # Collect system data
                cpu_data = cpu_collector.collect()
                
                # TODO: Collect other system data:
                # memory_data = memory_collector.collect()
                # disk_data = disk_collector.collect()
                # network_data = network_collector.collect()
                # process_data = process_collector.collect()
                
                # For now, use placeholder data
                memory_data = {"usage_percent": 45.2, "used": 4.5, "total": 15.8}
                disk_data = {"usage_percent": 32.8, "read_speed": 15.6, "write_speed": 8.3}
                network_data = {"download_speed": 1.2, "upload_speed": 0.4}
                process_data = {"processes": []}
                
                # Process data
                system_data = {
                    "cpu": cpu_data,
                    "memory": memory_data,
                    "disk": disk_data,
                    "network": network_data,
                    "processes": process_data,
                    "timestamp": time.time(),
                }
                processed_data = processor.process(system_data)
                
                # Update dashboard
                dashboard.update(processed_data)
                
                # Sleep for update interval
                time.sleep(config.general.update_interval)
    
    except KeyboardInterrupt:
        pass
    finally:
        # Clean up resources
        print(term.clear)
        print(term.home + "Linux System Monitor closed.")


if __name__ == "__main__":
    app()

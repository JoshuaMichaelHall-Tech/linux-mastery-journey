"""
Configuration Module for Linux System Monitor

This module handles loading, saving, and accessing application configuration.
"""

import os
from dataclasses import dataclass, field
from typing import Dict, List, Optional

# Try to import toml library, fallback to json if not available
try:
    import tomli as toml
    import tomli_w as toml_write
    USE_TOML = True
except ImportError:
    try:
        import toml
        USE_TOML = True
    except ImportError:
        import json
        USE_TOML = False


@dataclass
class GeneralConfig:
    """General application configuration settings."""
    update_interval: float = 1.0
    enable_logging: bool = True
    log_path: str = "~/.local/share/linux-system-monitor/logs"


@dataclass
class DisplayConfig:
    """Display and UI configuration settings."""
    theme: str = "dark"
    layout: str = "detailed"
    show_graphs: bool = True
    graph_history: int = 120
    process_count: int = 15
    enable_animations: bool = True
    compact_sidebar: bool = False
    color_mapping: Dict[str, str] = field(default_factory=lambda: {
        "cpu": "green",
        "memory": "blue",
        "disk": "yellow",
        "network": "magenta",
        "alert": "red"
    })


@dataclass
class AlertConfig:
    """Alert thresholds and notification settings."""
    cpu_threshold: float = 90.0
    memory_threshold: float = 85.0
    disk_threshold: float = 90.0
    network_threshold: float = 90.0
    enable_notifications: bool = True
    notification_sound: bool = False
    alert_log_path: str = "~/.local/share/linux-system-monitor/alerts.log"


@dataclass
class ExportConfig:
    """Data export and snapshot settings."""
    snapshot_path: str = "~/.local/share/linux-system-monitor/snapshots"
    csv_export_path: str = "~/.local/share/linux-system-monitor/exports"
    snapshot_format: str = "json"
    auto_snapshot_interval: int = 0  # 0 = disabled, otherwise in minutes


class Config:
    """
    Main configuration class that manages all settings.
    
    This class handles loading and saving configuration to disk,
    and provides access to the different configuration sections.
    """
    
    def __init__(self, config_path: Optional[str] = None):
        """
        Initialize configuration with default or loaded values.
        
        Args:
            config_path: Path to configuration file. If None, use default path.
        """
        # Set default configuration path
        if config_path is None:
            config_dir = os.path.expanduser("~/.config/linux-system-monitor")
            self.config_path = os.path.join(config_dir, "config.toml" if USE_TOML else "config.json")
        else:
            self.config_path = os.path.expanduser(config_path)
        
        # Initialize configuration sections with defaults
        self.general = GeneralConfig()
        self.display = DisplayConfig()
        self.alerts = AlertConfig()
        self.export = ExportConfig()
        
        # Custom settings not covered by the dataclasses
        self.custom_settings = {}
    
    def load(self) -> bool:
        """
        Load configuration from disk.
        
        Returns:
            True if configuration was loaded successfully, False otherwise.
        """
        # Check if configuration file exists
        if not os.path.exists(self.config_path):
            return self._create_default_config()
        
        try:
            # Load configuration from file
            if USE_TOML:
                with open(self.config_path, "rb") as f:
                    config_data = toml.load(f)
            else:
                with open(self.config_path, "r") as f:
                    config_data = json.load(f)
            
            # Update configuration sections
            self._update_section(self.general, config_data.get("general", {}))
            self._update_section(self.display, config_data.get("display", {}))
            self._update_section(self.alerts, config_data.get("alerts", {}))
            self._update_section(self.export, config_data.get("export", {}))
            
            # Store any custom settings
            if "custom" in config_data:
                self.custom_settings = config_data["custom"]
            
            return True
            
        except Exception as e:
            print(f"Error loading configuration: {str(e)}")
            # Fall back to defaults
            return False
    
    def save(self) -> bool:
        """
        Save configuration to disk.
        
        Returns:
            True if configuration was saved successfully, False otherwise.
        """
        try:
            # Create directory if it doesn't exist
            os.makedirs(os.path.dirname(self.config_path), exist_ok=True)
            
            # Prepare configuration data
            config_data = {
                "general": self._dataclass_to_dict(self.general),
                "display": self._dataclass_to_dict(self.display),
                "alerts": self._dataclass_to_dict(self.alerts),
                "export": self._dataclass_to_dict(self.export),
            }
            
            # Add custom settings
            if self.custom_settings:
                config_data["custom"] = self.custom_settings
            
            # Save configuration to file
            if USE_TOML:
                with open(self.config_path, "wb") as f:
                    if hasattr(toml, 'dump'):
                        toml.dump(config_data, f)
                    else:
                        f.write(toml_write.dumps(config_data))
            else:
                with open(self.config_path, "w") as f:
                    json.dump(config_data, f, indent=2)
            
            return True
            
        except Exception as e:
            print(f"Error saving configuration: {str(e)}")
            return False
    
    def reset(self):
        """Reset configuration to defaults."""
        self.general = GeneralConfig()
        self.display = DisplayConfig()
        self.alerts = AlertConfig()
        self.export = ExportConfig()
        self.custom_settings = {}
    
    def get_custom(self, key: str, default=None):
        """
        Get a custom configuration value.
        
        Args:
            key: The configuration key
            default: Default value if key doesn't exist
            
        Returns:
            The configuration value or default
        """
        return self.custom_settings.get(key, default)
    
    def set_custom(self, key: str, value):
        """
        Set a custom configuration value.
        
        Args:
            key: The configuration key
            value: The value to set
        """
        self.custom_settings[key] = value
    
    def _create_default_config(self) -> bool:
        """
        Create and save default configuration.
        
        Returns:
            True if successful, False otherwise.
        """
        return self.save()
    
    def _update_section(self, section, data):
        """
        Update a configuration section from loaded data.
        
        Args:
            section: The configuration section to update
            data: Dictionary with configuration values
        """
        for key, value in data.items():
            if hasattr(section, key):
                setattr(section, key, value)
    
    def _dataclass_to_dict(self, obj):
        """
        Convert a dataclass to a dictionary.
        
        Args:
            obj: The dataclass instance
            
        Returns:
            Dictionary representation of the dataclass
        """
        return {k: v for k, v in obj.__dict__.items()}


def expand_paths(config: Config):
    """
    Expand all path variables in the configuration.
    
    Args:
        config: The configuration object
    """
    # Expand paths in general section
    config.general.log_path = os.path.expanduser(config.general.log_path)
    
    # Expand paths in alerts section
    config.alerts.alert_log_path = os.path.expanduser(config.alerts.alert_log_path)
    
    # Expand paths in export section
    config.export.snapshot_path = os.path.expanduser(config.export.snapshot_path)
    config.export.csv_export_path = os.path.expanduser(config.export.csv_export_path)


def validate_config(config: Config) -> List[str]:
    """
    Validate configuration settings and return any issues.
    
    Args:
        config: The configuration object
        
    Returns:
        List of validation errors or empty list if no issues
    """
    errors = []
    
    # Validate general section
    if config.general.update_interval <= 0:
        errors.append("Update interval must be greater than 0")
    
    # Validate display section
    if config.display.theme not in ["dark", "light"]:
        errors.append("Theme must be either 'dark' or 'light'")
    
    if config.display.layout not in ["detailed", "compact", "minimal"]:
        errors.append("Layout must be one of: 'detailed', 'compact', 'minimal'")
    
    if config.display.graph_history <= 0:
        errors.append("Graph history must be greater than 0")
    
    if config.display.process_count <= 0:
        errors.append("Process count must be greater than 0")
    
    # Validate alert thresholds
    if not (0 <= config.alerts.cpu_threshold <= 100):
        errors.append("CPU threshold must be between 0 and 100")
    
    if not (0 <= config.alerts.memory_threshold <= 100):
        errors.append("Memory threshold must be between 0 and 100")
    
    if not (0 <= config.alerts.disk_threshold <= 100):
        errors.append("Disk threshold must be between 0 and 100")
    
    if not (0 <= config.alerts.network_threshold <= 100):
        errors.append("Network threshold must be between 0 and 100")
    
    # Validate export configuration
    if config.export.snapshot_format not in ["json", "yaml", "csv"]:
        errors.append("Snapshot format must be one of: 'json', 'yaml', 'csv'")
    
    if config.export.auto_snapshot_interval < 0:
        errors.append("Auto snapshot interval must be greater than or equal to 0")
    
    return errors

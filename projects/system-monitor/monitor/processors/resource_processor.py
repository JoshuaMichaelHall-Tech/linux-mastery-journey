"""
Resource Processor Module for Linux System Monitor

This module processes raw data from collectors and prepares it for visualization.
"""

import time
from typing import Dict, List, Optional, Union
import collections


class ResourceProcessor:
    """
    Processes raw system resource data and prepares it for visualization.
    
    This class is responsible for:
    - Converting raw data to appropriate display formats
    - Calculating derived metrics
    - Maintaining historical data for graphs
    - Detecting anomalies and setting alert states
    """
    
    def __init__(self, history_size: int = 120):
        """
        Initialize the resource processor.
        
        Args:
            history_size: Number of historical data points to maintain (default: 120)
        """
        self.history_size = history_size
        
        # Initialize history for different metrics
        self.cpu_history = collections.deque(maxlen=history_size)
        self.memory_history = collections.deque(maxlen=history_size)
        self.disk_io_history = collections.deque(maxlen=history_size)
        self.network_history = collections.deque(maxlen=history_size)
        
        # Initialize timestamps
        self.last_processed_time = time.time()
    
    def process(self, data: Dict) -> Dict:
        """
        Process raw data from collectors.
        
        Args:
            data: Dictionary containing raw data from collectors
            
        Returns:
            Processed data ready for visualization
        """
        current_time = time.time()
        time_delta = current_time - self.last_processed_time
        self.last_processed_time = current_time
        
        # Process CPU data
        processed_data = {
            "cpu": self._process_cpu_data(data.get("cpu", {})),
            "memory": self._process_memory_data(data.get("memory", {})),
            "disk": self._process_disk_data(data.get("disk", {}), time_delta),
            "network": self._process_network_data(data.get("network", {}), time_delta),
            "processes": self._process_process_data(data.get("processes", {})),
            "system": {
                "timestamp": data.get("timestamp", current_time),
                "uptime": self._get_uptime(),
                "hostname": self._get_hostname(),
            },
            "alerts": self._detect_alerts(data),
        }
        
        return processed_data
    
    def _process_cpu_data(self, cpu_data: Dict) -> Dict:
        """Process CPU data and update history."""
        if not cpu_data:
            # Return placeholder if no data available
            return {"usage_percent": 0, "per_core_percent": [], "history": list(self.cpu_history)}
        
        # Add current CPU usage to history
        self.cpu_history.append(cpu_data.get("usage_percent", 0))
        
        # Calculate CPU time spent in each state
        cpu_states = {
            "user": 0,
            "system": 0,
            "idle": 0,
            "iowait": 0,
            "other": 0,
        }
        
        # Return processed CPU data
        return {
            "usage_percent": cpu_data.get("usage_percent", 0),
            "per_core_percent": cpu_data.get("per_core_percent", []),
            "core_count": len(cpu_data.get("per_core_percent", [])),
            "load_avg": cpu_data.get("load_avg", {}),
            "states": cpu_states,
            "history": list(self.cpu_history),
            "frequency": cpu_data.get("frequency", {}),
            "temperature": cpu_data.get("temperature", None),
        }
    
    def _process_memory_data(self, memory_data: Dict) -> Dict:
        """Process memory data and update history."""
        if not memory_data:
            # Return placeholder if no data available
            return {"usage_percent": 0, "used": 0, "total": 0, "history": list(self.memory_history)}
        
        # Add current memory usage to history
        self.memory_history.append(memory_data.get("usage_percent", 0))
        
        # Return processed memory data
        return {
            "usage_percent": memory_data.get("usage_percent", 0),
            "used": memory_data.get("used", 0),
            "total": memory_data.get("total", 0),
            "free": memory_data.get("free", 0),
            "available": memory_data.get("available", 0),
            "swap_used": memory_data.get("swap_used", 0),
            "swap_total": memory_data.get("swap_total", 0),
            "swap_percent": memory_data.get("swap_percent", 0),
            "history": list(self.memory_history),
        }
    
    def _process_disk_data(self, disk_data: Dict, time_delta: float) -> Dict:
        """Process disk data and update history."""
        if not disk_data:
            # Return placeholder if no data available
            return {
                "usage_percent": 0,
                "read_speed": 0,
                "write_speed": 0,
                "history": list(self.disk_io_history),
            }
        
        # Calculate IO speed
        read_speed = disk_data.get("read_speed", 0)
        write_speed = disk_data.get("write_speed", 0)
        
        # Add current disk IO to history (read + write)
        self.disk_io_history.append(read_speed + write_speed)
        
        # Return processed disk data
        return {
            "usage_percent": disk_data.get("usage_percent", 0),
            "read_speed": read_speed,
            "write_speed": write_speed,
            "partitions": disk_data.get("partitions", {}),
            "history": list(self.disk_io_history),
        }
    
    def _process_network_data(self, network_data: Dict, time_delta: float) -> Dict:
        """Process network data and update history."""
        if not network_data:
            # Return placeholder if no data available
            return {
                "download_speed": 0,
                "upload_speed": 0,
                "history": list(self.network_history),
            }
        
        # Calculate network speeds
        download_speed = network_data.get("download_speed", 0)
        upload_speed = network_data.get("upload_speed", 0)
        
        # Add current network usage to history (download + upload)
        self.network_history.append(download_speed + upload_speed)
        
        # Return processed network data
        return {
            "download_speed": download_speed,
            "upload_speed": upload_speed,
            "interfaces": network_data.get("interfaces", {}),
            "history": list(self.network_history),
        }
    
    def _process_process_data(self, process_data: Dict) -> Dict:
        """Process process data."""
        if not process_data:
            # Return placeholder if no data available
            return {"processes": []}
        
        # Sort processes by CPU usage (descending)
        processes = sorted(
            process_data.get("processes", []),
            key=lambda p: p.get("cpu_percent", 0),
            reverse=True
        )
        
        # Return processed process data
        return {
            "processes": processes,
            "total": len(processes),
        }
    
    def _detect_alerts(self, data: Dict) -> Dict:
        """Detect alert conditions based on resource usage."""
        alerts = {}
        
        # CPU alerts
        cpu_data = data.get("cpu", {})
        if cpu_data.get("usage_percent", 0) > 90:
            alerts["cpu"] = {
                "level": "critical",
                "message": "CPU usage over 90%",
            }
        elif cpu_data.get("usage_percent", 0) > 75:
            alerts["cpu"] = {
                "level": "warning",
                "message": "CPU usage over 75%",
            }
        
        # Memory alerts
        memory_data = data.get("memory", {})
        if memory_data.get("usage_percent", 0) > 90:
            alerts["memory"] = {
                "level": "critical",
                "message": "Memory usage over 90%",
            }
        elif memory_data.get("usage_percent", 0) > 80:
            alerts["memory"] = {
                "level": "warning",
                "message": "Memory usage over 80%",
            }
        
        # Disk alerts
        disk_data = data.get("disk", {})
        if disk_data.get("usage_percent", 0) > 90:
            alerts["disk"] = {
                "level": "critical",
                "message": "Disk usage over 90%",
            }
        elif disk_data.get("usage_percent", 0) > 80:
            alerts["disk"] = {
                "level": "warning",
                "message": "Disk usage over 80%",
            }
        
        return alerts
    
    def _get_uptime(self) -> float:
        """Get system uptime in seconds."""
        try:
            with open('/proc/uptime', 'r') as f:
                uptime_seconds = float(f.readline().split()[0])
            return uptime_seconds
        except:
            return 0
    
    def _get_hostname(self) -> str:
        """Get system hostname."""
        try:
            with open('/proc/sys/kernel/hostname', 'r') as f:
                return f.read().strip()
        except:
            return "unknown"
    
    def reset_history(self):
        """Reset all historical data."""
        self.cpu_history.clear()
        self.memory_history.clear()
        self.disk_io_history.clear()
        self.network_history.clear()

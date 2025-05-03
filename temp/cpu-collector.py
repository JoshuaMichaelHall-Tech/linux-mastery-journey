"""
CPU Collector Module for Linux System Monitor

This module handles collecting CPU usage metrics from the system.
"""

import time
from typing import Dict, List, Optional, Union

import psutil


class CPUCollector:
    """Collector for CPU metrics including usage, load, frequency, and temperature."""
    
    def __init__(self):
        """Initialize the CPU collector with initial measurements."""
        # Cache the number of CPU cores
        self.cpu_count = psutil.cpu_count(logical=True)
        self.physical_cores = psutil.cpu_count(logical=False)
        
        # Initialize previous measurements for delta calculations
        self._prev_total = None
        self._prev_busy = None
        self._prev_time = time.time()
        
        # Take initial measurements
        self._init_measurements()
    
    def _init_measurements(self):
        """Take initial CPU measurements for delta calculations."""
        cpu_times = psutil.cpu_times()
        self._prev_busy = cpu_times.user + cpu_times.system + cpu_times.nice + cpu_times.irq + cpu_times.softirq
        self._prev_total = self._prev_busy + cpu_times.idle + cpu_times.iowait
    
    def collect(self) -> Dict[str, Union[float, Dict, List]]:
        """
        Collect current CPU metrics.
        
        Returns:
            Dict containing CPU metrics:
                - usage_percent: Overall CPU usage as a percentage
                - per_core_percent: List of per-core usage percentages
                - load_avg: 1, 5, and 15-minute load averages
                - frequency: Current, min, and max CPU frequencies
                - temperature: CPU temperature if available
                - context_switches: Number of context switches since last collection
                - interrupts: Number of interrupts since last collection
        """
        # Get current time for calculations
        current_time = time.time()
        elapsed = current_time - self._prev_time
        self._prev_time = current_time
        
        # Collect CPU metrics
        result = {
            "usage_percent": 0.0,
            "per_core_percent": [],
            "load_avg": {},
            "frequency": {},
            "temperature": None,
            "context_switches": 0,
            "interrupts": 0,
        }
        
        # Calculate CPU usage since last collection
        if self._prev_total is not None:
            cpu_times = psutil.cpu_times()
            current_busy = cpu_times.user + cpu_times.system + cpu_times.nice + cpu_times.irq + cpu_times.softirq
            current_total = current_busy + cpu_times.idle + cpu_times.iowait
            
            # Calculate the delta
            busy_delta = current_busy - self._prev_busy
            total_delta = current_total - self._prev_total
            
            # Update previous values for next collection
            self._prev_busy = current_busy
            self._prev_total = current_total
            
            # Calculate usage percentage
            if total_delta > 0:
                result["usage_percent"] = (busy_delta / total_delta) * 100
        else:
            # First collection - use psutil's measurement
            result["usage_percent"] = psutil.cpu_percent(interval=None)
            self._init_measurements()
        
        # Get per-core CPU usage
        result["per_core_percent"] = psutil.cpu_percent(interval=None, percpu=True)
        
        # Get load average (returns 1, 5, and 15-minute averages)
        load_avgs = psutil.getloadavg()
        result["load_avg"] = {
            "1min": load_avgs[0],
            "5min": load_avgs[1],
            "15min": load_avgs[2],
            # Normalize load by core count for better comparison
            "1min_normalized": load_avgs[0] / self.cpu_count,
            "5min_normalized": load_avgs[1] / self.cpu_count,
            "15min_normalized": load_avgs[2] / self.cpu_count,
        }
        
        # Get CPU frequency information if available
        try:
            freq = psutil.cpu_freq(percpu=False)
            if freq:
                result["frequency"] = {
                    "current_mhz": freq.current,
                    "min_mhz": freq.min if hasattr(freq, "min") else None,
                    "max_mhz": freq.max if hasattr(freq, "max") else None,
                }
        except (AttributeError, OSError):
            # CPU frequency info may not be available on all systems
            pass
        
        # Get CPU temperature information if available
        try:
            temp_info = self._get_cpu_temperature()
            if temp_info is not None:
                result["temperature"] = temp_info
        except (AttributeError, OSError):
            # Temperature info may not be available on all systems
            pass
        
        # Get context switches and interrupts
        try:
            cpu_stats = psutil.cpu_stats()
            result["context_switches"] = cpu_stats.ctx_switches
            result["interrupts"] = cpu_stats.interrupts
        except (AttributeError, OSError):
            pass
        
        # Additional processing
        self._enrich_data(result)
        
        return result
    
    def _get_cpu_temperature(self) -> Optional[Dict[str, float]]:
        """
        Attempt to get CPU temperature from sensors.
        
        Returns:
            Dict with temperature data or None if unavailable
        """
        try:
            # Try using psutil for temperature (if available)
            temps = psutil.sensors_temperatures()
            
            # Look for CPU temperature sensors
            cpu_temp = None
            
            # Check common temperature sensor names
            for sensor_name in ["coretemp", "k10temp", "zenpower", "acpitz"]:
                if sensor_name in temps:
                    # Get the highest temperature from the CPU cores
                    cpu_temp = max(temp.current for temp in temps[sensor_name])
                    break
            
            if cpu_temp is not None:
                return {
                    "celsius": cpu_temp,
                    "fahrenheit": (cpu_temp * 9/5) + 32,
                }
        except (AttributeError, OSError, KeyError):
            pass
        
        return None
    
    def _enrich_data(self, data: Dict):
        """
        Add derived metrics and additional context to the collected data.
        
        Args:
            data: The data dictionary to enrich
        """
        # Calculate overall system utilization level
        if data["usage_percent"] <= 30:
            data["utilization_level"] = "low"
        elif data["usage_percent"] <= 70:
            data["utilization_level"] = "moderate"
        else:
            data["utilization_level"] = "high"
        
        # Check for potential CPU bottlenecks
        if data["usage_percent"] > 90 and data["load_avg"]["1min_normalized"] > 1.0:
            data["potential_bottleneck"] = True
        else:
            data["potential_bottleneck"] = False
        
        # Calculate core imbalance (max difference between any two cores)
        if len(data["per_core_percent"]) > 1:
            core_min = min(data["per_core_percent"])
            core_max = max(data["per_core_percent"])
            data["core_imbalance"] = core_max - core_min
        else:
            data["core_imbalance"] = 0
    
    def reset(self):
        """Reset collector state, clearing any cached or accumulated data."""
        self._prev_total = None
        self._prev_busy = None
        self._prev_time = time.time()
        self._init_measurements()

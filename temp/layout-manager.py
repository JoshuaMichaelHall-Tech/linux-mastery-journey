"""
Layout Manager Module for Linux System Monitor

This module handles the layout of UI components based on terminal size and user preferences.
"""

from typing import Dict, Tuple


class LayoutManager:
    """
    Manages the layout of UI components in the dashboard.
    
    This class is responsible for:
    - Calculating widget positions and sizes based on terminal dimensions
    - Providing different layout options (detailed, compact, minimal)
    - Adjusting layouts for different screen sizes
    """
    
    def __init__(self, term, layout_type: str = "detailed"):
        """
        Initialize the layout manager.
        
        Args:
            term: Terminal instance for getting dimensions
            layout_type: Type of layout to use (detailed, compact, minimal)
        """
        self.term = term
        self.layout_type = layout_type
    
    def get_layout(self, width: int, height: int) -> Dict[str, Tuple[int, int, int, int]]:
        """
        Get the layout configuration for the current terminal dimensions.
        
        Args:
            width: Terminal width
            height: Terminal height
            
        Returns:
            Dictionary mapping widget names to their position/size tuples (x, y, width, height)
        """
        # Account for header
        content_height = height - 2
        
        if self.layout_type == "detailed":
            return self._get_detailed_layout(width, content_height)
        elif self.layout_type == "compact":
            return self._get_compact_layout(width, content_height)
        elif self.layout_type == "minimal":
            return self._get_minimal_layout(width, content_height)
        else:
            # Default to detailed layout
            return self._get_detailed_layout(width, content_height)
    
    def _get_detailed_layout(self, width: int, height: int) -> Dict[str, Tuple[int, int, int, int]]:
        """
        Generate a detailed layout with multiple widgets.
        
        The detailed layout includes:
        - CPU, memory, disk, and network widgets in a 2x2 grid
        - Process list at the bottom spanning the full width
        
        Args:
            width: Terminal width
            height: Terminal height
            
        Returns:
            Dictionary mapping widget names to their position/size tuples
        """
        # Calculate widget sizes
        top_height = min(height // 2, 10)  # Top row height
        middle_height = min(height // 2, 10)  # Middle row height
        bottom_height = height - top_height - middle_height  # Bottom row height
        
        left_width = width // 2  # Left column width
        right_width = width - left_width  # Right column width
        
        # Define widget positions and sizes
        layout = {
            "cpu": (0, 1, left_width, top_height),  # Top-left
            "memory": (left_width, 1, right_width, top_height),  # Top-right
            "disk": (0, 1 + top_height, left_width, middle_height),  # Middle-left
            "network": (left_width, 1 + top_height, right_width, middle_height),  # Middle-right
            "processes": (0, 1 + top_height + middle_height, width, bottom_height),  # Bottom full width
        }
        
        return layout
    
    def _get_compact_layout(self, width: int, height: int) -> Dict[str, Tuple[int, int, int, int]]:
        """
        Generate a compact layout with fewer, larger widgets.
        
        The compact layout includes:
        - Combined system stats (CPU, memory, disk, network) in the left column
        - Process list in the right column
        
        Args:
            width: Terminal width
            height: Terminal height
            
        Returns:
            Dictionary mapping widget names to their position/size tuples
        """
        # Calculate widget sizes
        left_width = width // 3  # Left column width
        right_width = width - left_width  # Right column width
        
        # Define widget positions and sizes
        cpu_height = height // 4
        memory_height = height // 4
        disk_height = height // 4
        network_height = height - cpu_height - memory_height - disk_height
        
        layout = {
            "cpu": (0, 1, left_width, cpu_height),  # Top-left
            "memory": (0, 1 + cpu_height, left_width, memory_height),  # Middle-top-left
            "disk": (0, 1 + cpu_height + memory_height, left_width, disk_height),  # Middle-bottom-left
            "network": (0, 1 + cpu_height + memory_height + disk_height, left_width, network_height),  # Bottom-left
            "processes": (left_width, 1, right_width, height),  # Right full height
        }
        
        return layout
    
    def _get_minimal_layout(self, width: int, height: int) -> Dict[str, Tuple[int, int, int, int]]:
        """
        Generate a minimal layout focused on the most important information.
        
        The minimal layout includes:
        - Combined system stats in a compact top bar
        - Process list taking up most of the screen
        
        Args:
            width: Terminal width
            height: Terminal height
            
        Returns:
            Dictionary mapping widget names to their position/size tuples
        """
        # Calculate widget sizes
        system_height = 5  # Top bar height
        process_height = height - system_height  # Process list height
        
        quarter_width = width // 4
        
        # Define widget positions and sizes
        layout = {
            "cpu": (0, 1, quarter_width, system_height),  # Top-left quarter
            "memory": (quarter_width, 1, quarter_width, system_height),  # Top-left-middle quarter
            "disk": (quarter_width * 2, 1, quarter_width, system_height),  # Top-right-middle quarter
            "network": (quarter_width * 3, 1, width - (quarter_width * 3), system_height),  # Top-right quarter
            "processes": (0, 1 + system_height, width, process_height),  # Bottom full width
        }
        
        return layout
    
    def set_layout_type(self, layout_type: str):
        """
        Change the current layout type.
        
        Args:
            layout_type: New layout type (detailed, compact, minimal)
        """
        if layout_type in ["detailed", "compact", "minimal"]:
            self.layout_type = layout_type

#!/bin/bash

# Script to move updated files from temp directory to their appropriate locations
# Author: Joshua Michael Hall
# Date: 2025-05-03

# Set source and base destination directories
TEMP_DIR="./temp"
BASE_DIR="."

# Create a function to handle file moves with appropriate checks
move_file() {
    local source="$1"
    local dest="$2"
    
    # Create destination directory if it doesn't exist
    mkdir -p "$(dirname "$dest")"
    
    # Check if destination exists
    if [ -f "$dest" ]; then
        echo "Replacing: $dest"
        # Backup existing file
        cp "$dest" "${dest}.bak"
    else
        echo "Adding new file: $dest"
    fi
    
    # Move the file
    cp "$source" "$dest"
    echo "✓ Successfully moved $source to $dest"
}

# Create necessary directories
mkdir -p "$BASE_DIR/projects/system-monitor/docs"
mkdir -p "$BASE_DIR/configuration/development/docs"
mkdir -p "$BASE_DIR/projects/system-monitor/monitor/ui/components"
mkdir -p "$BASE_DIR/projects/system-monitor/monitor/ui"
mkdir -p "$BASE_DIR/projects/system-monitor/monitor/processors"
mkdir -p "$BASE_DIR/learning_guides"

echo "Starting file migration process..."

# Learning guide files
move_file "$TEMP_DIR/improved-learning-guides-readme.txt" "$BASE_DIR/learning_guides/README.md"
move_file "$TEMP_DIR/improved-main-readme-continued.txt" "$BASE_DIR/README.md"
move_file "$TEMP_DIR/month-01-exercises-continued.txt" "$BASE_DIR/learning_guides/month-01-exercises.md"

# System monitor and UI files
move_file "$TEMP_DIR/dashboard-ui.py" "$BASE_DIR/projects/system-monitor/monitor/ui/dashboard.py"
move_file "$TEMP_DIR/dashboard-ui-fixed.tsx" "$BASE_DIR/projects/system-monitor/monitor/ui/components/dashboard.tsx"
move_file "$TEMP_DIR/layout-manager.py" "$BASE_DIR/projects/system-monitor/monitor/ui/layout_manager.py"
move_file "$TEMP_DIR/main-py.py" "$BASE_DIR/projects/system-monitor/monitor/__main__.py"
move_file "$TEMP_DIR/resource-processor.py" "$BASE_DIR/projects/system-monitor/monitor/processors/resource_processor.py"

# Documentation files
move_file "$TEMP_DIR/testing-strategy.txt" "$BASE_DIR/projects/system-monitor/docs/testing_strategy.md"
move_file "$TEMP_DIR/version-control-strategy.txt" "$BASE_DIR/configuration/development/docs/version_control_strategy.md"

echo "File migration complete!"
echo "Remember to review the changes and remove any backup files (.bak) once you've verified everything works correctly."

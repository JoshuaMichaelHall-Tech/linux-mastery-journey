#!/bin/bash
#
# Implementation script for Linux Mastery Journey repository reorganization
#
# This script will:
# 1. Update the main README file
# 2. Create learning_guides directory
# 3. Move files to appropriate locations
# 4. Clean up redundant or unnecessary files

set -e  # Exit immediately if a command exits with a non-zero status

# Print with colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting repository reorganization...${NC}"

# Create learning_guides directory if it doesn't exist
echo -e "${YELLOW}Creating learning_guides directory...${NC}"
mkdir -p learning_guides

# Update main README file
echo -e "${YELLOW}Updating main README file...${NC}"
cp "linux-journey-readme.md" "README.md"
echo -e "${GREEN}Main README updated successfully.${NC}"

# Create or update troubleshooting directory
echo -e "${YELLOW}Setting up troubleshooting directory...${NC}"
mkdir -p troubleshooting

# Files already exist in the correct location, so we don't need to move them
# Just ensure the files exist
if [ -f "troubleshooting/README.md" ] && [ -f "troubleshooting/graphics.md" ] && [ -f "troubleshooting/networking.md" ]; then
    echo -e "${GREEN}Troubleshooting files already in place.${NC}"
else
    echo -e "${YELLOW}Setting up troubleshooting files...${NC}"
    # Copy the files that might not exist
    cp -n troubleshooting/README.md troubleshooting/README.md 2>/dev/null || true
    cp -n troubleshooting/graphics.md troubleshooting/graphics.md 2>/dev/null || true
    cp -n troubleshooting/networking.md troubleshooting/networking.md 2>/dev/null || true
fi

# Check if learning guides are already created
if [ -f "learning_guides/month-01-base-system.md" ]; then
    echo -e "${YELLOW}Learning guides already exist. Skipping creation.${NC}"
else
    echo -e "${YELLOW}Creating placeholder learning guides...${NC}"
    
    # Create placeholder files for learning guides (month-01 through month-12)
    for i in $(seq -f "%02g" 1 12); do
        GUIDE_FILE="learning_guides/month-${i}-placeholder.md"
        
        # Create placeholder content based on month
        case $i in
            "01") TITLE="Base System Installation and Core Concepts" ;;
            "02") TITLE="System Configuration and Package Management" ;;
            "03") TITLE="Desktop Environment and Workflow Setup" ;;
            "04") TITLE="Terminal Tools and Shell Customization" ;;
            "05") TITLE="Programming Languages and Development Tools" ;;
            "06") TITLE="Containerization and Virtual Environments" ;;
            "07") TITLE="System Maintenance and Performance Tuning" ;;
            "08") TITLE="Networking and Security Fundamentals" ;;
            "09") TITLE="Automation and Scripting" ;;
            "10") TITLE="Cloud Integration and Remote Development" ;;
            "11") TITLE="NixOS and Declarative Configuration" ;;
            "12") TITLE="Career Portfolio and Advanced Projects" ;;
            *) TITLE="Learning Guide" ;;
        esac
        
        # Create placeholder content
        cat > $GUIDE_FILE << EOF
# Month ${i}: ${TITLE}

This is a placeholder for the Month ${i} learning guide. This file will be populated with detailed content as part of the Linux Mastery Journey.

## Overview

This guide will cover:

- Topic 1
- Topic 2
- Topic 3

## Learning Objectives

- Objective 1
- Objective 2
- Objective 3

## Resources

- Resource 1
- Resource 2
- Resource 3

---

> "Master the basics. Then practice them every day without fail." - John C. Maxwell
EOF
        
        echo -e "${GREEN}Created placeholder for month ${i}${NC}"
    done
    
    # Create README for learning_guides
    cat > learning_guides/README.md << EOF
# Learning Path Guides

This directory contains structured, month-by-month learning guides for mastering Linux (Arch and NixOS) as a professional software development environment.

## Learning Path Structure

### Phase 1: Foundations (Months 1-3)
- **Month 1:** [Base System Installation and Core Concepts](month-01-placeholder.md)
- **Month 2:** [System Configuration and Package Management](month-02-placeholder.md)
- **Month 3:** [Desktop Environment and Workflow Setup](month-03-placeholder.md)

### Phase 2: Development Environment (Months 4-6)
- **Month 4:** [Terminal Tools and Shell Customization](month-04-placeholder.md)
- **Month 5:** [Programming Languages and Development Tools](month-05-placeholder.md)
- **Month 6:** [Containerization and Virtual Environments](month-06-placeholder.md)

### Phase 3: System Administration (Months 7-9)
- **Month 7:** [System Maintenance and Performance Tuning](month-07-placeholder.md)
- **Month 8:** [Networking and Security Fundamentals](month-08-placeholder.md)
- **Month 9:** [Automation and Scripting](month-09-placeholder.md)

### Phase 4: Advanced Applications (Months 10-12)
- **Month 10:** [Cloud Integration and Remote Development](month-10-placeholder.md)
- **Month 11:** [NixOS and Declarative Configuration](month-11-placeholder.md)
- **Month 12:** [Career Portfolio and Advanced Projects](month-12-placeholder.md)

## Using These Guides

Each monthly guide is designed to be completed in approximately 10-15 hours per week. While the guides build on each other, you can adjust the pace to fit your schedule and needs.

The guides include:
- Core concepts to learn
- Hands-on exercises and projects
- Resource links for further reading
- Checkpoints to verify understanding

## Contributing

If you find errors or have suggestions for improving these guides, please see the [Contributing Guide](../CONTRIBUTING.md) for information on how to submit changes.

---

> "Master the basics. Then practice them every day without fail." - John C. Maxwell
EOF
    
    echo -e "${GREEN}Created README for learning_guides${NC}"
fi

# Verify all directories and files are in place
echo -e "${YELLOW}Verifying repository structure...${NC}"

# Check if key files exist
if [ -f "README.md" ] && [ -d "learning_guides" ] && [ -f "learning_guides/README.md" ]; then
    echo -e "${GREEN}Repository structure looks good!${NC}"
    
    # Clean up redundant or unnecessary files
    echo -e "${YELLOW}Cleaning up redundant files...${NC}"
    
    # List of files to be removed
    REMOVE_FILES=(
        "linux-journey-readme.md"
    )
    
    # Remove files
    for file in "${REMOVE_FILES[@]}"; do
        if [ -f "$file" ]; then
            rm "$file"
            echo -e "${GREEN}Removed $file${NC}"
        fi
    done
    
    echo -e "${GREEN}Cleanup completed!${NC}"
else
    echo -e "${RED}Repository structure verification failed. Please check manually.${NC}"
    exit 1
fi

echo -e "${BLUE}Implementation completed successfully!${NC}"
echo
echo -e "${BLUE}Next steps:${NC}"
echo "1. Review the learning guides and customize them to your needs"
echo "2. Verify all links in the README properly point to the new guides"
echo "3. Begin working through the Month 1 guide to start your Linux mastery journey"
echo

exit 0

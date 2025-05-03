#!/bin/bash

# Create the learning_guides directory
mkdir -p learning_guides

# Copy the monthly guide artifacts into the learning_guides directory
# Month 1
cp month-01-base-system learning_guides/month-01-base-system.md
# Month 2
cp month-02-system-config learning_guides/month-02-system-config.md
# Month 3
cp month-03-desktop-setup learning_guides/month-03-desktop-setup.md
# Month 4
cp month-04-terminal-tools learning_guides/month-04-terminal-tools.md
# Month 5
cp month-05-dev-tools learning_guides/month-05-dev-tools.md
# Month 6
cp month-06-containers learning_guides/month-06-containers.md
# Month 7
cp month-07-maintenance learning_guides/month-07-maintenance.md
# Month 8
cp month-08-networking learning_guides/month-08-networking.md
# Month 9
cp month-09-automation learning_guides/month-09-automation.md
# Month 10
cp month-10-cloud learning_guides/month-10-cloud.md
# Month 11
cp month-11-nixos learning_guides/month-11-nixos.md
# Month 12
cp month-12-portfolio learning_guides/month-12-portfolio.md

echo "Learning guides setup complete!"

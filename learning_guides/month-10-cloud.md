# Month 10: Cloud Integration and Remote Development

This month focuses on integrating your Linux system with cloud services, setting up remote development environments, and managing cloud resources. You'll learn to work seamlessly between local and cloud environments while maintaining your Linux workflow.

## Time Commitment: ~10 hours/week for 4 weeks

## Learning Objectives

By the end of this month, you should be able to:

1. Configure and use cloud service provider CLI tools
2. Set up and manage remote development environments
3. Implement Infrastructure as Code (IaC) principles
4. Connect local workflows to cloud resources
5. Secure communication between local and cloud systems
6. Manage cloud resources efficiently from Linux

## Week 1: Cloud Service Provider Integration

### Core Learning Activities

1. **Cloud Fundamentals** (2 hours)
   - Understand cloud service models (IaaS, PaaS, SaaS)
   - Learn about major cloud providers
   - Study common cloud concepts and terminology
   - Understand cloud networking fundamentals
   - Learn about shared responsibility models

2. **AWS CLI Setup and Configuration** (3 hours)
   - Install and configure AWS CLI
   - Set up IAM credentials and roles
   - Configure multiple profiles
   - Learn basic AWS CLI commands
   - Understand AWS regions and availability zones
   - Implement secure credential storage

3. **Azure/GCP CLI Tools** (3 hours)
   - Install Azure CLI or Google Cloud SDK
   - Configure authentication and projects
   - Set up environment variables
   - Learn basic command patterns
   - Manage cloud resources from CLI
   - Understand provider-specific concepts

4. **API Integration** (2 hours)
   - Understand RESTful API concepts
   - Learn to use curl and httpie for API calls
   - Work with JSON using jq
   - Set up API authentication
   - Test and debug API interactions
   - Create simple API wrapper scripts

### Practical Exercises

#### Installing and Configuring AWS CLI

1. Install AWS CLI:

```bash
# For Arch Linux
sudo pacman -S aws-cli

# Alternative installation method
pip install --user awscli
```

2. Configure AWS CLI:

```bash
aws configure
```

Enter your credentials when prompted:
```
AWS Access Key ID [None]: YOUR_ACCESS_KEY
AWS Secret Access Key [None]: YOUR_SECRET_KEY
Default region name [None]: us-east-1
Default output format [None]: json
```

3. Create multiple profiles:

```bash
aws configure --profile development
aws configure --profile production
```

4. Test the configuration:

```bash
# List S3 buckets using default profile
aws s3 ls

# List S3 buckets using specific profile
aws s3 ls --profile development
```

5. Configure credentials file:

```bash
# Edit credentials file
nano ~/.aws/credentials

# Example configuration with multiple profiles
[default]
aws_access_key_id = DEFAULT_ACCESS_KEY
aws_secret_access_key = DEFAULT_SECRET_KEY

[development]
aws_access_key_id = DEV_ACCESS_KEY
aws_secret_access_key = DEV_SECRET_KEY

[production]
aws_access_key_id = PROD_ACCESS_KEY
aws_secret_access_key = PROD_SECRET_KEY
```

6. Configure AWS CLI settings file:

```bash
# Edit config file
nano ~/.aws/config

# Example configuration with multiple profiles
[default]
region = us-east-1
output = json

[profile development]
region = us-west-2
output = json

[profile production]
region = eu-west-1
output = json
```

#### Installing and Using Google Cloud SDK

1. Install Google Cloud SDK:

```bash
# For Arch Linux
yay -S google-cloud-sdk

# Alternative installation method
curl https://sdk.cloud.google.com | bash
```

2. Initialize the Google Cloud SDK:

```bash
gcloud init
```

3. Authenticate with your Google account:

```bash
gcloud auth login
```

4. Set a default project:

```bash
gcloud config set project YOUR_PROJECT_ID
```

5. List available configurations:

```bash
gcloud config configurations list
```

6. Create and manage multiple configurations:

```bash
# Create a new configuration
gcloud config configurations create development

# Activate a configuration
gcloud config configurations activate development

# Set properties for current configuration
gcloud config set project dev-project-id
gcloud config set compute/region us-west1
gcloud config set compute/zone us-west1-a
```

#### Creating a Cloud Resource API Wrapper

1. Create a simple wrapper script for common AWS operations:

```bash
nano ~/scripts/aws-wrapper.sh
```

2. Add the following content:

```bash
#!/bin/bash
#
# AWS Operations Wrapper
# A simplified interface for common AWS operations
#

set -e

# Function to display help
function show_help() {
    echo "AWS Operations Wrapper"
    echo "Usage: aws-wrapper.sh [options] COMMAND"
    echo ""
    echo "Commands:"
    echo "  list-instances          List all EC2 instances"
    echo "  start-instance ID       Start an EC2 instance"
    echo "  stop-instance ID        Stop an EC2 instance"
    echo "  list-buckets            List all S3 buckets"
    echo "  create-bucket NAME      Create an S3 bucket"
    echo "  upload FILE BUCKET      Upload a file to an S3 bucket"
    echo ""
    echo "Options:"
    echo "  --profile PROFILE       Use specific AWS profile"
    echo "  --region REGION         Use specific AWS region"
    echo "  --help                  Show this help message"
}

# Default values
PROFILE="default"
REGION=""

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --profile)
            PROFILE="$2"
            shift 2
            ;;
        --region)
            REGION="$2"
            shift 2
            ;;
        --help)
            show_help
            exit 0
```

6. Make the script executable:

```bash
chmod +x ~/scripts/cloud-backup.sh
```

7. Use the script:

```bash
# Backup documents to S3
~/scripts/cloud-backup.sh backup ~/Documents s3:my-bucket/documents

# Sync project files with Google Drive
~/scripts/cloud-backup.sh sync ~/Projects gdrive:Projects

# Restore from backup
~/scripts/cloud-backup.sh restore s3:my-bucket/documents ~/Documents-restored
```

8. Set up a scheduled backup:

Create a systemd user service and timer:

```bash
mkdir -p ~/.config/systemd/user
```

Create the service file:

```bash
nano ~/.config/systemd/user/cloud-backup.service
```

Add the following content:

```ini
[Unit]
Description=Cloud Backup Service
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/home/username/scripts/cloud-backup.sh backup /home/username/Documents s3:my-bucket/documents
ExecStart=/home/username/scripts/cloud-backup.sh backup /home/username/Projects gdrive:Projects

[Install]
WantedBy=default.target
```

Create the timer file:

```bash
nano ~/.config/systemd/user/cloud-backup.timer
```

Add the following content:

```ini
[Unit]
Description=Run Cloud Backup Daily

[Timer]
OnCalendar=*-*-* 02:00:00
Persistent=true
RandomizedDelaySec=1800

[Install]
WantedBy=timers.target
```

Enable and start the timer:

```bash
systemctl --user enable cloud-backup.timer
systemctl --user start cloud-backup.timer
```

#### Cloud Database Connectivity

1. Install database clients:

```bash
# For Arch Linux
sudo pacman -S postgresql-libs mysql-clients

# Install Python database libraries
pip install --user psycopg2-binary pymysql SQLAlchemy
```

2. Create a database connection script:

```bash
nano ~/scripts/db-connect.sh
```

Add the following content:

```bash
#!/bin/bash
#
# Database Connection Utility
#

set -e

# Function to display help
function show_help() {
    echo "Database Connection Utility"
    echo "Usage: db-connect.sh [options] COMMAND"
    echo ""
    echo "Commands:"
    echo "  connect PROFILE     Connect to database using profile"
    echo "  list                List available profiles"
    echo "  add                 Add a new connection profile"
    echo "  remove PROFILE      Remove connection profile"
    echo "  backup PROFILE      Create a database backup"
    echo "  restore PROFILE FILE Restore a database from backup"
    echo ""
    echo "Options:"
    echo "  --help              Show this help message"
}

# Configuration directory
CONFIG_DIR="$HOME/.config/db-connect"
PROFILES_DIR="$CONFIG_DIR/profiles"

# Create configuration directories if they don't exist
mkdir -p "$PROFILES_DIR"

# Check if profile exists
function profile_exists() {
    [ -f "$PROFILES_DIR/$1.conf" ]
}

# Load profile
function load_profile() {
    if profile_exists "$1"; then
        source "$PROFILES_DIR/$1.conf"
    else
        echo "Error: Profile '$1' does not exist"
        exit 1
    fi
}

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            show_help
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

# Check if command is provided
if [ $# -lt 1 ]; then
    show_help
    exit 1
fi

COMMAND="$1"
shift

# Execute appropriate command
case "$COMMAND" in
    connect)
        if [ $# -lt 1 ]; then
            echo "Error: Profile name required"
            exit 1
        fi
        
        PROFILE="$1"
        load_profile "$PROFILE"
        
        echo "Connecting to $DB_TYPE database $DB_NAME on $DB_HOST..."
        
        case "$DB_TYPE" in
            postgres)
                PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME"
                ;;
            mysql)
                mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME"
                ;;
            *)
                echo "Error: Unsupported database type: $DB_TYPE"
                exit 1
                ;;
        esac
        ;;
        
    list)
        echo "Available database profiles:"
        for profile in "$PROFILES_DIR"/*.conf; do
            if [ -f "$profile" ]; then
                basename "$profile" .conf
            fi
        done
        ;;
        
    add)
        echo "Adding a new database connection profile"
        
        read -p "Profile name: " PROFILE
        
        if profile_exists "$PROFILE"; then
            read -p "Profile already exists. Overwrite? (y/n): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "Operation cancelled."
                exit 0
            fi
        fi
        
        read -p "Database type (postgres/mysql): " DB_TYPE
        read -p "Host: " DB_HOST
        read -p "Port: " DB_PORT
        read -p "Database name: " DB_NAME
        read -p "Username: " DB_USER
        read -p "Password: " -s DB_PASSWORD
        echo
        
        # Create profile file
        cat > "$PROFILES_DIR/$PROFILE.conf" << EOF
# Database connection profile for $PROFILE
DB_TYPE="$DB_TYPE"
DB_HOST="$DB_HOST"
DB_PORT="$DB_PORT"
DB_NAME="$DB_NAME"
DB_USER="$DB_USER"
DB_PASSWORD="$DB_PASSWORD"
EOF
        
        chmod 600 "$PROFILES_DIR/$PROFILE.conf"
        echo "Profile '$PROFILE' created."
        ;;
        
    remove)
        if [ $# -lt 1 ]; then
            echo "Error: Profile name required"
            exit 1
        fi
        
        PROFILE="$1"
        
        if profile_exists "$PROFILE"; then
            rm "$PROFILES_DIR/$PROFILE.conf"
            echo "Profile '$PROFILE' removed."
        else
            echo "Error: Profile '$PROFILE' does not exist"
            exit 1
        fi
        ;;
        
    backup)
        if [ $# -lt 1 ]; then
            echo "Error: Profile name required"
            exit 1
        fi
        
        PROFILE="$1"
        load_profile "$PROFILE"
        
        TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
        BACKUP_DIR="$HOME/db_backups"
        mkdir -p "$BACKUP_DIR"
        
        case "$DB_TYPE" in
            postgres)
                BACKUP_FILE="$BACKUP_DIR/${PROFILE}_${DB_NAME}_$TIMESTAMP.sql"
                echo "Creating PostgreSQL backup: $BACKUP_FILE"
                PGPASSWORD="$DB_PASSWORD" pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$BACKUP_FILE"
                ;;
            mysql)
                BACKUP_FILE="$BACKUP_DIR/${PROFILE}_${DB_NAME}_$TIMESTAMP.sql"
                echo "Creating MySQL backup: $BACKUP_FILE"
                mysqldump -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" > "$BACKUP_FILE"
                ;;
            *)
                echo "Error: Unsupported database type: $DB_TYPE"
                exit 1
                ;;
        esac
        
        echo "Backup completed: $BACKUP_FILE"
        ;;
        
    restore)
        if [ $# -lt 2 ]; then
            echo "Error: Profile name and backup file required"
            exit 1
        fi
        
        PROFILE="$1"
        BACKUP_FILE="$2"
        
        if [ ! -f "$BACKUP_FILE" ]; then
            echo "Error: Backup file does not exist: $BACKUP_FILE"
            exit 1
        fi
        
        load_profile "$PROFILE"
        
        read -p "This will overwrite the database '$DB_NAME'. Continue? (y/n): " -n 1 -r
        echo
        
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Operation cancelled."
            exit 0
        fi
        
        case "$DB_TYPE" in
            postgres)
                echo "Restoring PostgreSQL database: $DB_NAME"
                PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$BACKUP_FILE"
                ;;
            mysql)
                echo "Restoring MySQL database: $DB_NAME"
                mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < "$BACKUP_FILE"
                ;;
            *)
                echo "Error: Unsupported database type: $DB_TYPE"
                exit 1
                ;;
        esac
        
        echo "Restore completed."
        ;;
        
    *)
        echo "Error: Unknown command $COMMAND"
        show_help
        exit 1
        ;;
esac

exit 0
```

3. Make the script executable:

```bash
chmod +x ~/scripts/db-connect.sh
```

4. Add a database profile:

```bash
~/scripts/db-connect.sh add
```

5. Connect to a database:

```bash
~/scripts/db-connect.sh connect mydb
```

6. Create a database backup:

```bash
~/scripts/db-connect.sh backup mydb
```

7. Create a Python script to work with cloud databases:

```bash
nano ~/scripts/db-query.py
```

Add the following content:

```python
#!/usr/bin/env python3
"""
Database Query Utility

A simple utility for querying databases and exporting results.
"""

import argparse
import os
import sys
import csv
import json
import configparser
import getpass
from datetime import datetime
from pathlib import Path

try:
    import sqlalchemy
    from sqlalchemy import create_engine, text
except ImportError:
    print("Error: sqlalchemy is required. Install with: pip install sqlalchemy")
    sys.exit(1)

def load_profile(profile_name):
    """Load database connection profile."""
    config_dir = Path.home() / ".config" / "db-connect" / "profiles"
    profile_path = config_dir / f"{profile_name}.conf"
    
    if not profile_path.exists():
        print(f"Error: Profile '{profile_name}' does not exist")
        sys.exit(1)
    
    config = configparser.ConfigParser()
    with open(profile_path) as f:
        # Add a section header (required by configparser)
        config_str = '[profile]\n' + f.read()
    
    try:
        config.read_string(config_str)
        profile = config['profile']
        return {
            'type': profile['DB_TYPE'],
            'host': profile['DB_HOST'],
            'port': profile['DB_PORT'],
            'name': profile['DB_NAME'],
            'user': profile['DB_USER'],
            'password': profile['DB_PASSWORD'],
        }
    except Exception as e:
        print(f"Error loading profile: {e}")
        sys.exit(1)

def get_connection_string(profile):
    """Generate a database connection string."""
    if profile['type'] == 'postgres':
        return f"postgresql://{profile['user']}:{profile['password']}@{profile['host']}:{profile['port']}/{profile['name']}"
    elif profile['type'] == 'mysql':
        return f"mysql+pymysql://{profile['user']}:{profile['password']}@{profile['host']}:{profile['port']}/{profile['name']}"
    else:
        print(f"Error: Unsupported database type: {profile['type']}")
        sys.exit(1)

def export_results(results, format, output_file=None):
    """Export query results in the specified format."""
    if not results:
        print("No results to export")
        return
    
    # Get column names from the first result
    columns = results[0].keys()
    
    if format == 'csv':
        if output_file:
            with open(output_file, 'w', newline='') as f:
                writer = csv.DictWriter(f, fieldnames=columns)
                writer.writeheader()
                writer.writerows(results)
            print(f"Results exported to {output_file}")
        else:
            writer = csv.DictWriter(sys.stdout, fieldnames=columns)
            writer.writeheader()
            writer.writerows(results)
    
    elif format == 'json':
        json_data = json.dumps(results, default=str, indent=2)
        if output_file:
            with open(output_file, 'w') as f:
                f.write(json_data)
            print(f"Results exported to {output_file}")
        else:
            print(json_data)
    
    elif format == 'table':
        # Simple table format
        # Calculate column widths
        widths = {column: len(column) for column in columns}
        for row in results:
            for column in columns:
                value = str(row[column])
                widths[column] = max(widths[column], len(value))
        
        # Print header
        header = ' | '.join(column.ljust(widths[column]) for column in columns)
        separator = '-+-'.join('-' * widths[column] for column in columns)
        
        print(header)
        print(separator)
        
        # Print rows
        for row in results:
            row_str = ' | '.join(str(row[column]).ljust(widths[column]) for column in columns)
            print(row_str)
    
    else:
        print(f"Error: Unsupported export format: {format}")

def main():
    parser = argparse.ArgumentParser(description='Database Query Utility')
    parser.add_argument('profile', help='Database connection profile')
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('-q', '--query', help='SQL query to execute')
    group.add_argument('-f', '--file', help='File containing SQL query')
    parser.add_argument('-o', '--output', help='Output file (for CSV or JSON export)')
    parser.add_argument('-t', '--format', choices=['csv', 'json', 'table'], default='table',
                        help='Output format (default: table)')
    
    args = parser.parse_args()
    
    # Load the profile
    profile = load_profile(args.profile)
    
    # Get the query
    if args.query:
        query = args.query
    else:
        try:
            with open(args.file, 'r') as f:
                query = f.read()
        except Exception as e:
            print(f"Error reading query file: {e}")
            sys.exit(1)
    
    # Connect to the database
    try:
        engine = create_engine(get_connection_string(profile))
        with engine.connect() as connection:
            # Execute the query
            result = connection.execute(text(query))
            
            # Convert result to list of dictionaries
            results = [dict(row._mapping) for row in result]
            
            # Export results
            export_results(results, args.format, args.output)
    
    except Exception as e:
        print(f"Error executing query: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
```

8. Make the script executable:

```bash
chmod +x ~/scripts/db-query.py
```

9. Use the script:

```bash
# Run a simple query
~/scripts/db-query.py mydb -q "SELECT * FROM users LIMIT 10"

# Run a query and export to CSV
~/scripts/db-query.py mydb -q "SELECT * FROM orders WHERE order_date > '2023-01-01'" -t csv -o orders.csv

# Run a query from a file
echo "SELECT COUNT(*) AS total FROM products" > query.sql
~/scripts/db-query.py mydb -f query.sql -t json
```

#### Setting Up a CI/CD Pipeline with GitHub Actions

1. Create a simple Python web application:

```bash
mkdir -p ~/projects/flask-demo
cd ~/projects/flask-demo
```

2. Create a virtual environment:

```bash
python -m venv venv
source venv/bin/activate
```

3. Install required packages:

```bash
pip install flask pytest pytest-cov flake8 black
```

4. Create a simple Flask application:

```bash
mkdir -p app/templates
```

Create app/__init__.py:

```bash
nano app/__init__.py
```

Add the following content:

```python
from flask import Flask

def create_app():
    app = Flask(__name__)
    
    from app.routes import main
    app.register_blueprint(main)
    
    return app
```

Create app/routes.py:

```bash
nano app/routes.py
```

Add the following content:

```python
from flask import Blueprint, render_template, jsonify

main = Blueprint('main', __name__)

@main.route('/')
def index():
    return render_template('index.html')

@main.route('/api/health')
def health():
    return jsonify({'status': 'ok'})
```

Create a template:

```bash
nano app/templates/index.html
```

Add the following content:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Flask Demo</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            line-height: 1.6;
        }
        h1 {
            color: #333;
        }
    </style>
</head>
<body>
    <h1>Flask Demo App</h1>
    <p>Welcome to the Flask Demo App!</p>
    <p>This is a simple application deployed using CI/CD.</p>
</body>
</html>
```

5. Create a tests directory:

```bash
mkdir -p tests
```

Create tests/test_app.py:

```bash
nano tests/test_app.py
```

Add the following content:

```python
import pytest
from app import create_app

@pytest.fixture
def app():
    app = create_app()
    app.config.update({
        "TESTING": True,
    })
    yield app

@pytest.fixture
def client(app):
    return app.test_client()

def test_index_page(client):
    response = client.get('/')
    assert response.status_code == 200
    assert b"Flask Demo App" in response.data

def test_health_endpoint(client):
    response = client.get('/api/health')
    assert response.status_code == 200
    json_data = response.get_json()
    assert json_data['status'] == 'ok'
```

6. Create application entry point:

```bash
nano wsgi.py
```

Add the following content:

```python
from app import create_app

app = create_app()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

7. Create a requirements.txt file:

```bash
pip freeze > requirements.txt
```

8. Create a Dockerfile:

```bash
nano Dockerfile
```

Add the following content:

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "wsgi:app"]
```

9. Add gunicorn to requirements.txt:

```bash
echo "gunicorn" >> requirements.txt
```

10. Create a .github/workflows directory:

```bash
mkdir -p .github/workflows
```

11. Create a CI/CD workflow file:

```bash
nano .github/workflows/ci-cd.yml
```

Add the following content:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    name: Test
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        pip install pytest pytest-cov flake8 black
    
    - name: Lint with flake8
      run: |
        flake8 app tests
    
    - name: Check formatting with black
      run: |
        black --check app tests
    
    - name: Test with pytest
      run: |
        pytest --cov=app tests/
    
  build:
    name: Build and Push Docker Image
    needs: test
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
    
    - name: Login to DockerHub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
    
    - name: Build and push
      uses: docker/build-push-action@v3
      with:
        context: .
        push: true
        tags: yourusername/flask-demo:latest
    
  deploy:
    name: Deploy to Production
    needs: build
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to server
      uses: appleboy/ssh-action@master
      with:
        host: ${{ secrets.SSH_HOST }}
        username: ${{ secrets.SSH_USERNAME }}
        key: ${{ secrets.SSH_PRIVATE_KEY }}
        script: |
          cd /opt/flask-demo
          docker-compose pull
          docker-compose up -d --force-recreate
```

12. Create a simple docker-compose.yml for deployment:

```bash
nano docker-compose.yml
```

Add the following content:

```yaml
version: '3.8'

services:
  app:
    image: yourusername/flask-demo:latest
    restart: always
    ports:
      - "5000:5000"
    environment:
      - FLASK_ENV=production
```

13. Initialize a git repository:

```bash
git init
echo "__pycache__/" > .gitignore
echo "venv/" >> .gitignore
echo "*.pyc" >> .gitignore
git add .
git commit -m "Initial commit"
```

14. Create a simple deployment script:

```bash
nano deploy.sh
```

Add the following content:

```bash
#!/bin/bash
#
# Simple deployment script for Flask demo app
#

set -e

# Check if docker and docker-compose are installed
if ! command -v docker &> /dev/null; then
    echo "Error: docker is not installed"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "Error: docker-compose is not installed"
    exit 1
fi

# Pull the latest image
echo "Pulling the latest image..."
docker-compose pull

# Restart the containers
echo "Restarting the containers..."
docker-compose up -d --force-recreate

# Check if the service is running
echo "Checking if the service is running..."
if curl -s http://localhost:5000/api/health | grep -q "ok"; then
    echo "Deployment successful!"
else
    echo "Error: Service is not responding correctly"
    exit 1
fi
```

15. Make the deployment script executable:

```bash
chmod +x deploy.sh
```

16. Configure a local github actions workflow tester:

```bash
nano test-workflow.sh
```

Add the following content:

```bash
#!/bin/bash
#
# Local GitHub Actions workflow tester
#

set -e

# Function to display help
function show_help() {
    echo "Local GitHub Actions Workflow Tester"
    echo "Usage: test-workflow.sh [options] WORKFLOW"
    echo ""
    echo "Options:"
    echo "  --help              Show this help message"
}

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            show_help
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

# Check if workflow is provided
if [ $# -lt 1 ]; then
    echo "Error: Workflow file required"
    show_help
    exit 1
fi

WORKFLOW="$1"

if [ ! -f "$WORKFLOW" ]; then
    echo "Error: Workflow file does not exist: $WORKFLOW"
    exit 1
fi

# Extract jobs from workflow
echo "Testing workflow: $WORKFLOW"
echo ""

# Run linting
echo "Running linting..."
flake8 app tests || true

# Run formatting check
echo "Checking formatting..."
black --check app tests || true

# Run tests
echo "Running tests..."
pytest --cov=app tests/

# Build Docker image
echo ""
echo "Building Docker image..."
docker build -t flask-demo:test .

# Run the container
echo ""
echo "Running the container..."
docker run -d --name flask-demo-test -p 5000:5000 flask-demo:test

# Wait for the container to start
echo "Waiting for the container to start..."
sleep 5

# Test the API
echo ""
echo "Testing the API..."
if curl -s http://localhost:5000/api/health | grep -q "ok"; then
    echo "API test successful!"
else
    echo "Error: API test failed"
    docker logs flask-demo-test
fi

# Clean up
echo ""
echo "Cleaning up..."
docker stop flask-demo-test
docker rm flask-demo-test

echo ""
echo "Workflow test completed!"
```

17. Make the workflow tester executable:

```bash
chmod +x test-workflow.sh
```

18. Create a cost management script:

```bash
nano ~/scripts/cloud-cost-manager.sh
```

Add the following content:

```bash
#!/bin/bash
#
# Cloud Cost Management Script
#

set -e

# Function to display help
function show_help() {
    echo "Cloud Cost Management Script"
    echo "Usage: cloud-cost-manager.sh [options] COMMAND"
    echo ""
    echo "Commands:"
    echo "  analyze PROFILE       Analyze costs for the specified profile"
    echo "  optimize PROFILE      Suggest cost optimizations for the profile"
    echo "  list                  List available profiles"
    echo "  add                   Add a new cloud profile"
    echo "  remove PROFILE        Remove cloud profile"
    echo ""
    echo "Options:"
    echo "  --help                Show this help message"
}

# Configuration directory
CONFIG_DIR="$HOME/.config/cloud-manager"
PROFILES_DIR="$CONFIG_DIR/profiles"

# Create configuration directories if they don't exist
mkdir -p "$PROFILES_DIR"

# Check if profile exists
function profile_exists() {
    [ -f "$PROFILES_DIR/$1.conf" ]
}

# Load profile
function load_profile() {
    if profile_exists "$1"; then
        source "$PROFILES_DIR/$1.conf"
    else
        echo "Error: Profile '$1' does not exist"
        exit 1
    fi
}

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            show_help
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

# Check if command is provided
if [ $# -lt 1 ]; then
    show_help
    exit 1
fi

COMMAND="$1"
shift

# Execute appropriate command
case "$COMMAND" in
    analyze)
        if [ $# -lt 1 ]; then
            echo "Error: Profile name required"
            exit 1
        fi
        
        PROFILE="$1"
        load_profile "$PROFILE"
        
        echo "Analyzing costs for profile '$PROFILE'..."
        
        case "$CLOUD_PROVIDER" in
            aws)
                echo "AWS Cost Analysis"
                echo "=================="
                
                # Get current month's costs
                aws ce get-cost-and-usage \
                    --time-period Start=$(date -d "$(date +%Y-%m-01) -1 month" +%Y-%m-01),End=$(date -d "$(date +%Y-%m-01)" +%Y-%m-01) \
                    --granularity MONTHLY \
                    --metrics BlendedCost \
                    --profile "$AWS_PROFILE" \
                    --output json | jq -r '.ResultsByTime[0].Total.BlendedCost'
                
                # Get cost by service
                aws ce get-cost-and-usage \
                    --time-period Start=$(date -d "$(date +%Y-%m-01) -1 month" +%Y-%m-01),End=$(date -d "$(date +%Y-%m-01)" +%Y-%m-01) \
                    --granularity MONTHLY \
                    --group-by Type=DIMENSION,Key=SERVICE \
                    --metrics BlendedCost \
                    --profile "$AWS_PROFILE" \
                    --output table
                ;;
            
            azure)
                echo "Azure Cost Analysis"
                echo "=================="
                
                az account set --subscription "$AZURE_SUBSCRIPTION"
                
                # Get cost summary
                az consumption usage list \
                    --start-date $(date -d "$(date +%Y-%m-01) -1 month" +%Y-%m-01) \
                    --end-date $(date -d "$(date +%Y-%m-01)" +%Y-%m-01) \
                    --query "[].{service:consumedService, cost:pretaxCost}" \
                    --output table
                ;;
            
            gcp)
                echo "GCP Cost Analysis"
                echo "================="
                
                # Ensure gcloud is configured with the right project
                gcloud config set project "$GCP_PROJECT"
                
                # For GCP, you would typically use the billing API or export to BigQuery
                echo "GCP cost analysis requires additional setup."
                echo "Please visit: https://cloud.google.com/billing/docs/how-to/export-data-bigquery"
                ;;
            
            *)
                echo "Error: Unsupported cloud provider: $CLOUD_PROVIDER"
                exit 1
                ;;
        esac
        ;;
        
    optimize)
        if [ $# -lt 1 ]; then
            echo "Error: Profile name required"
            exit 1
        fi
        
        PROFILE="$1"
        load_profile "$PROFILE"
        
        echo "Generating cost optimization suggestions for profile '$PROFILE'..."
        
        case "$CLOUD_PROVIDER" in
            aws)
                echo "AWS Cost Optimization Suggestions"
                echo "================================"
                
                # List unattached EBS volumes
                echo "Checking for unattached EBS volumes..."
                aws ec2 describe-volumes \
                    --filters Name=status,Values=available \
                    --query 'Volumes[*].{ID:VolumeId,Size:Size,Type:VolumeType}' \
                    --profile "$AWS_PROFILE" \
                    --output table
                
                # List stopped EC2 instances
                echo "Checking for stopped EC2 instances..."
                aws ec2 describe-instances \
                    --filters Name=instance-state-name,Values=stopped \
                    --query 'Reservations[*].Instances[*].{ID:InstanceId,Type:InstanceType,Name:Tags[?Key==`Name`].Value|[0]}' \
                    --profile "$AWS_PROFILE" \
                    --output table
                
                # List unused Elastic IPs
                echo "Checking for unused Elastic IPs..."
                aws ec2 describe-addresses \
                    --query 'Addresses[?AssociationId==null]' \
                    --profile "$AWS_PROFILE" \
                    --output table
                
                # Check for under-utilized EC2 instances based on CloudWatch metrics
                echo "Checking for underutilized EC2 instances would require CloudWatch metrics analysis..."
                ;;
            
            azure)
                echo "Azure Cost Optimization Suggestions"
                echo "================================="
                
                az account set --subscription "$AZURE_SUBSCRIPTION"
                
                # List stopped VMs
                echo "Checking for stopped VMs..."
                az vm list \
                    --query "[?powerState=='VM deallocated'].{Name:name, ResourceGroup:resourceGroup, Size:hardwareProfile.vmSize}" \
                    --output table
                
                # List unattached disks
                echo "Checking for unattached disks..."
                az disk list \
                    --query "[?managedBy==null].{Name:name, Size:diskSizeGb, Type:sku.name, ResourceGroup:resourceGroup}" \
                    --output table
                
                # List unused public IPs
                echo "Checking for unused public IPs..."
                az network public-ip list \
                    --query "[?ipConfiguration==null].{Name:name, ResourceGroup:resourceGroup}" \
                    --output table
                ;;
            
            gcp)
                echo "GCP Cost Optimization Suggestions"
                echo "================================"
                
                # Ensure gcloud is configured with the right project
                gcloud config set project "$GCP_PROJECT"
                
                # List stopped instances
                echo "Checking for stopped instances..."
                gcloud compute instances list \
                    --filter="status:TERMINATED" \
                    --format="table(name,zone,machineType,status)"
                
                # List unattached disks
                echo "Checking for unattached disks..."
                gcloud compute disks list \
                    --filter="NOT users:*" \
                    --format="table(name,zone,sizeGb,type)"
                
                # List unused static IPs
                echo "Checking for unused static IPs..."
                gcloud compute addresses list \
                    --filter="status:RESERVED" \
                    --format="table(name,region,address,status)"
                ;;
            
            *)
                echo "Error: Unsupported cloud provider: $CLOUD_PROVIDER"
                exit 1
                ;;
        esac
        
        echo ""
        echo "General Optimization Suggestions:"
        echo "1. Consider reserved instances for consistent workloads"
        echo "2. Implement auto-scaling for variable workloads"
        echo "3. Schedule non-production environments to stop during off-hours"
        echo "4. Regularly review and clean up unused resources"
        echo "5. Use spot/preemptible instances for non-critical workloads"
        echo "6. Optimize storage usage (lifecycle policies, storage class)"
        echo "7. Implement proper tagging for cost allocation"
        ;;
        
    list)
        echo "Available cloud profiles:"
        for profile in "$PROFILES_DIR"/*.conf; do
            if [ -f "$profile" ]; then
                basename "$profile" .conf
            fi
        done
        ;;
        
    add)
        echo "Adding a new cloud profile"
        
        read -p "Profile name: " PROFILE
        
        if profile_exists "$PROFILE"; then
            read -p "Profile already exists. Overwrite? (y/n): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "Operation cancelled."
                exit 0
            fi
        fi
        
        read -p "Cloud provider (aws/azure/gcp): " CLOUD_PROVIDER
        
        case "$CLOUD_PROVIDER" in
            aws)
                read -p "AWS Profile: " AWS_PROFILE
                read -p "AWS Region: " AWS_REGION
                
                # Create profile file
                cat > "$PROFILES_DIR/$PROFILE.conf" << EOF
# Cloud profile for $PROFILE
CLOUD_PROVIDER="aws"
AWS_PROFILE="$AWS_PROFILE"
AWS_REGION="$AWS_REGION"
EOF
                ;;
            
            azure)
                read -p "Azure Subscription ID: " AZURE_SUBSCRIPTION
                
                # Create profile file
                cat > "$PROFILES_DIR/$PROFILE.conf" << EOF
# Cloud profile for $PROFILE
CLOUD_PROVIDER="azure"
AZURE_SUBSCRIPTION="$AZURE_SUBSCRIPTION"
EOF
                ;;
            
            gcp)
                read -p "GCP Project ID: " GCP_PROJECT
                
                # Create profile file
                cat > "$PROFILES_DIR/$PROFILE.conf" << EOF
# Cloud profile for $PROFILE
CLOUD_PROVIDER="gcp"
GCP_PROJECT="$GCP_PROJECT"
EOF
                ;;
            
            *)
                echo "Error: Unsupported cloud provider: $CLOUD_PROVIDER"
                exit 1
                ;;
        esac
        
        chmod 600 "$PROFILES_DIR/$PROFILE.conf"
        echo "Profile '$PROFILE' created."
        ;;
        
    remove)
        if [ $# -lt 1 ]; then
            echo "Error: Profile name required"
            exit 1
        fi
        
        PROFILE="$1"
        
        if profile_exists "$PROFILE"; then
            rm "$PROFILES_DIR/$PROFILE.conf"
            echo "Profile '$PROFILE' removed."
        else
            echo "Error: Profile '$PROFILE' does not exist"
            exit 1
        fi
        ;;
        
    *)
        echo "Error: Unknown command $COMMAND"
        show_help
        exit 1
        ;;
esac

exit 0
```

19. Make the cost management script executable:

```bash
chmod +x ~/scripts/cloud-cost-manager.sh
```

### Resources

- [Rclone Documentation](https://rclone.org/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Cloud Cost Optimization](https://www.cloudzero.com/blog/cloud-cost-optimization)
- [Database Migration Guide](https://docs.aws.amazon.com/dms/latest/userguide/Welcome.html)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Docker Documentation](https://docs.docker.com/)
- [SQLAlchemy Documentation](https://docs.sqlalchemy.org/)
- [Cloud Cost Management Best Practices](https://cloud.google.com/blog/topics/cost-management/best-practices-for-optimizing-your-cloud-costs)

## Projects and Exercises

1. **Multi-Environment Deployment Pipeline**
   - Create an automated deployment pipeline
   - Implement Infrastructure as Code with Terraform
   - Set up multiple environments (dev, staging, prod)
   - Configure testing and validation checks
   - Implement monitoring and alerting
   - Document the entire process

2. **Cloud-Based Development Environment**
   - Set up a complete cloud development environment
   - Configure persistent storage for code and data
   - Implement dotfile synchronization
   - Set up automated provisioning
   - Create start/stop automation for cost savings
   - Document usage and customization

3. **Hybrid Backup Solution**
   - Create a backup system using local and cloud storage
   - Implement versioning and retention policies
   - Configure automated scheduled backups
   - Add encryption for sensitive data
   - Implement restore testing
   - Document the backup and recovery procedures

4. **Personal Cloud Dashboard**
   - Build a dashboard for your cloud resources
   - Implement cost tracking and visualization
   - Add resource monitoring
   - Create management tools for common tasks
   - Configure alerting for important events
   - Document the dashboard components

## Cross-References

- **Previous Month**: [Month 9: Automation and Scripting](month-09-automation.md) - Foundational automation skills for cloud integration
- **Next Month**: [Month 11: NixOS and Declarative Configuration](month-11-nixos.md) - Will build on infrastructure as code concepts
- **Related Guides**: 
  - [Troubleshooting Guide](/troubleshooting/README.md) - For resolving cloud connectivity issues
  - [Development Environment Configuration](/configuration/development/README.md) - For integrating cloud with development environments
  - [System Monitor Project](/projects/system-monitor/README.md) - Can be extended to monitor cloud resources
- **Reference Resources**:
  - [Linux Shortcuts & Commands Reference](linux-shortcuts.md) - For cloud CLI shortcuts
  - [Linux Mastery Journey - Glossary](linux-glossary.md) - For cloud terminology

## Assessment

You should now be able to:

1. Use cloud provider CLI tools effectively
2. Set up and manage remote development environments
3. Implement infrastructure as code using Terraform
4. Connect local workflows to cloud resources seamlessly
5. Secure communication between local and cloud systems
6. Manage and optimize cloud resources from Linux

## Next Steps

In Month 11, we'll focus on:
- NixOS as a declarative Linux distribution
- Managing system configuration as code
- Implementing reproducible builds
- Creating custom NixOS modules
- Understanding the Nix package manager deeply

## Acknowledgements

This learning guide was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Learning path structure and organization
- Resource recommendations
- Project suggestions

Claude was used as a development aid while all final implementation decisions and verification were performed by Joshua Michael Hall.

## Disclaimer

This guide is provided "as is", without warranty of any kind. Follow all instructions carefully and always make backups before making system changes.
            ;;
        *)
            break
            ;;
    esac
done

# Check if command is provided
if [ $# -lt 1 ]; then
    echo "Error: No command specified"
    show_help
    exit 1
fi

COMMAND="$1"
shift

# Prepare profile and region parameters
PROFILE_PARAM="--profile $PROFILE"
REGION_PARAM=""
if [ -n "$REGION" ]; then
    REGION_PARAM="--region $REGION"
fi

# Execute appropriate AWS CLI command based on the wrapper command
case "$COMMAND" in
    list-instances)
        echo "Listing EC2 instances..."
        aws ec2 describe-instances $PROFILE_PARAM $REGION_PARAM \
            --query 'Reservations[].Instances[].[InstanceId,State.Name,InstanceType,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' \
            --output table
        ;;
        
    start-instance)
        if [ $# -lt 1 ]; then
            echo "Error: Instance ID required"
            exit 1
        fi
        INSTANCE_ID="$1"
        echo "Starting EC2 instance $INSTANCE_ID..."
        aws ec2 start-instances $PROFILE_PARAM $REGION_PARAM \
            --instance-ids "$INSTANCE_ID"
        ;;
        
    stop-instance)
        if [ $# -lt 1 ]; then
            echo "Error: Instance ID required"
            exit 1
        fi
        INSTANCE_ID="$1"
        echo "Stopping EC2 instance $INSTANCE_ID..."
        aws ec2 stop-instances $PROFILE_PARAM $REGION_PARAM \
            --instance-ids "$INSTANCE_ID"
        ;;
        
    list-buckets)
        echo "Listing S3 buckets..."
        aws s3 ls $PROFILE_PARAM
        ;;
        
    create-bucket)
        if [ $# -lt 1 ]; then
            echo "Error: Bucket name required"
            exit 1
        fi
        BUCKET_NAME="$1"
        echo "Creating S3 bucket $BUCKET_NAME..."
        aws s3 mb s3://$BUCKET_NAME $PROFILE_PARAM $REGION_PARAM
        ;;
        
    upload)
        if [ $# -lt 2 ]; then
            echo "Error: FILE and BUCKET parameters required"
            exit 1
        fi
        FILE="$1"
        BUCKET="$2"
        echo "Uploading $FILE to S3 bucket $BUCKET..."
        aws s3 cp "$FILE" s3://$BUCKET/ $PROFILE_PARAM
        ;;
        
    *)
        echo "Error: Unknown command $COMMAND"
        show_help
        exit 1
        ;;
esac

exit 0
```

3. Make the script executable:

```bash
chmod +x ~/scripts/aws-wrapper.sh
```

4. Create an alias in your .zshrc or .bashrc:

```bash
echo 'alias awsw="~/scripts/aws-wrapper.sh"' >> ~/.zshrc
source ~/.zshrc
```

5. Use the wrapper script:

```bash
# List EC2 instances
awsw list-instances

# Use with profile
awsw --profile development list-buckets

# Create a bucket
awsw create-bucket my-unique-bucket-name

# Upload a file
awsw upload myfile.txt my-unique-bucket-name
```

### Resources

- [AWS CLI Documentation](https://awscli.amazonaws.com/v2/documentation/api/latest/index.html)
- [Azure CLI Documentation](https://docs.microsoft.com/en-us/cli/azure/)
- [Google Cloud SDK Documentation](https://cloud.google.com/sdk/docs)
- [jq Tutorial](https://stedolan.github.io/jq/tutorial/)
- [Linux Academy Cloud Computing Basics](https://linuxacademy.com/course/cloud-computing-basics/)
- [AWS CLI Cheat Sheet](https://github.com/tldr-pages/tldr/blob/master/pages/common/aws.md)
- [Cloud Provider Comparison](https://www.datamation.com/cloud/aws-vs-azure-vs-google-cloud/)

## Week 2: Remote Development Environments

### Core Learning Activities

1. **SSH-Based Remote Development** (3 hours)
   - Configure SSH for remote development
   - Set up SSH keys and config
   - Use remote filesystem mounting (sshfs)
   - Configure VSCode Remote SSH
   - Implement Neovim remote editing
   - Study connection multiplexing and caching

2. **Container-Based Development** (3 hours)
   - Set up development containers
   - Configure Docker remote contexts
   - Use VSCode with remote containers
   - Implement multi-stage containers for dev/prod
   - Understand volume mounting strategies
   - Configure persistent storage for containers

3. **Cloud Development Environments** (2 hours)
   - Explore GitHub Codespaces
   - Set up Gitpod workspaces
   - Configure cloud IDE settings
   - Synchronize dotfiles and preferences
   - Manage cloud development costs
   - Implement secure access controls

4. **Remote Pair Programming** (2 hours)
   - Configure tmux for shared sessions
   - Set up tmate for instant sharing
   - Learn collaborative editing techniques
   - Configure screen sharing options
   - Establish communication channels
   - Implement security for collaborative sessions

### Practical Exercises

#### SSH-Based Remote Development Setup

1. Configure SSH for remote development:

```bash
# Create SSH key if needed
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy SSH key to remote server
ssh-copy-id username@remote-server
```

2. Create an enhanced SSH config file:

```bash
nano ~/.ssh/config
```

Add the following configuration:

```
# Default settings for all hosts
Host *
    # Reuse connections to the same server
    ControlMaster auto
    ControlPath ~/.ssh/control/%r@%h:%p
    ControlPersist 10m
    
    # Security settings
    Protocol 2
    HashKnownHosts yes
    IdentitiesOnly yes
    
    # Keep connection alive
    ServerAliveInterval 60
    ServerAliveCountMax 10

# Development server
Host dev
    HostName dev-server.example.com
    User devuser
    Port 22
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent yes
    
# Production server
Host prod
    HostName prod-server.example.com
    User produser
    Port 22
    IdentityFile ~/.ssh/id_ed25519_prod
    ForwardAgent no
    
# GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_github
    
# AWS instance
Host aws-dev
    HostName ec2-xx-xx-xx-xx.compute-1.amazonaws.com
    User ec2-user
    IdentityFile ~/.ssh/aws-key.pem
    
# Jump host configuration
Host internal-server
    HostName 10.0.0.5
    User internaluser
    ProxyJump jumpuser@jump.example.com:22
    IdentityFile ~/.ssh/id_ed25519
```

3. Create control directory for connection sharing:

```bash
mkdir -p ~/.ssh/control
chmod 700 ~/.ssh/control
```

4. Mount remote filesystem using sshfs:

```bash
# Install sshfs
sudo pacman -S sshfs

# Create mount point
mkdir -p ~/remote-projects

# Mount remote directory
sshfs dev:/home/devuser/projects ~/remote-projects

# To unmount
fusermount -u ~/remote-projects
```

5. Create a script to manage remote mounts:

```bash
nano ~/scripts/remote-mount.sh
```

Add the following content:

```bash
#!/bin/bash
#
# Remote Directory Mount Manager
#

set -e

# Function to display help
function show_help() {
    echo "Remote Directory Mount Manager"
    echo "Usage: remote-mount.sh [options] COMMAND"
    echo ""
    echo "Commands:"
    echo "  mount HOST:PATH      Mount remote directory"
    echo "  unmount DIR          Unmount directory"
    echo "  list                 List mounted directories"
    echo "  check DIR            Check if directory is mounted"
    echo ""
    echo "Options:"
    echo "  --mountpoint DIR     Local directory for mounting (default: ~/remote-mounts/HOST)"
    echo "  --help               Show this help message"
}

# Default values
MOUNTPOINT=""

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --mountpoint)
            MOUNTPOINT="$2"
            shift 2
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

# Check if command is provided
if [ $# -lt 1 ]; then
    echo "Error: No command specified"
    show_help
    exit 1
fi

COMMAND="$1"
shift

# Execute appropriate command
case "$COMMAND" in
    mount)
        if [ $# -lt 1 ]; then
            echo "Error: HOST:PATH required"
            exit 1
        fi
        
        # Parse the HOST:PATH format
        REMOTE="$1"
        HOST=$(echo "$REMOTE" | cut -d: -f1)
        PATH_REMOTE=$(echo "$REMOTE" | cut -d: -f2-)
        
        # Set default mountpoint if not specified
        if [ -z "$MOUNTPOINT" ]; then
            MOUNTPOINT="$HOME/remote-mounts/$HOST"
        fi
        
        # Create mountpoint if it doesn't exist
        mkdir -p "$MOUNTPOINT"
        
        echo "Mounting $HOST:$PATH_REMOTE to $MOUNTPOINT..."
        sshfs "$HOST:$PATH_REMOTE" "$MOUNTPOINT" -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3
        
        echo "Mount successful. Access files at $MOUNTPOINT"
        ;;
        
    unmount)
        if [ $# -lt 1 ]; then
            echo "Error: Directory required"
            exit 1
        fi
        
        DIR="$1"
        echo "Unmounting $DIR..."
        fusermount -u "$DIR"
        echo "Unmount successful."
        ;;
        
    list)
        echo "Currently mounted remote directories:"
        mount | grep fuse.sshfs
        ;;
        
    check)
        if [ $# -lt 1 ]; then
            echo "Error: Directory required"
            exit 1
        fi
        
        DIR="$1"
        if mount | grep "on $DIR type fuse.sshfs" > /dev/null; then
            echo "$DIR is currently mounted."
            exit 0
        else
            echo "$DIR is not mounted."
            exit 1
        fi
        ;;
        
    *)
        echo "Error: Unknown command $COMMAND"
        show_help
        exit 1
        ;;
esac

exit 0
```

6. Make the script executable:

```bash
chmod +x ~/scripts/remote-mount.sh
```

7. Configure VSCode for Remote SSH development:

```bash
# Install VSCode if needed
sudo pacman -S code

# Install Remote Development extension pack from VSCode marketplace
code --install-extension ms-vscode-remote.vscode-remote-extensionpack
```

Then in VSCode:
- Press F1 and run "Remote-SSH: Connect to Host..."
- Select a host from your SSH config
- Wait for the connection to be established
- Start editing remote files directly

#### Container-Based Development Environment

1. Create a development container for Python projects:

```bash
mkdir -p ~/projects/python-dev-container
cd ~/projects/python-dev-container
```

2. Create a Dockerfile:

```bash
nano Dockerfile
```

Add the following content:

```dockerfile
FROM python:3.11-slim AS base

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on

WORKDIR /app

# Create a non-root user
RUN groupadd -g 1000 developer && \
    useradd -u 1000 -g developer -s /bin/bash -m developer && \
    chown -R developer:developer /app

# Development stage with additional tools
FROM base AS development

# Install development tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    vim \
    zsh \
    sudo \
    less \
    procps \
    tmux \
    && rm -rf /var/lib/apt/lists/*

# Install development packages
RUN pip install --upgrade pip && \
    pip install poetry pytest pytest-cov black isort mypy flake8 ipython

# Add developer to sudoers
RUN echo "developer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/developer

# Switch to developer user
USER developer

# Configure Poetry
RUN poetry config virtualenvs.in-project true

# Set up Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.zshrc && \
    chsh -s /bin/zsh

# Set the default shell to zsh
SHELL ["/bin/zsh", "-c"]

# Keep the container running
CMD ["tail", "-f", "/dev/null"]
```

3. Create a docker-compose.yml file:

```bash
nano docker-compose.yml
```

Add the following content:

```yaml
version: '3.8'

services:
  dev:
    build:
      context: .
      target: development
    volumes:
      - .:/app
      - ~/.gitconfig:/home/developer/.gitconfig:ro
      - ~/.ssh:/home/developer/.ssh:ro
      - python-venv:/app/.venv
    ports:
      - "8000:8000"
    environment:
      - TERM=xterm-256color
    command: tail -f /dev/null

volumes:
  python-venv:
```

4. Create a development startup script:

```bash
nano dev.sh
```

Add the following content:

```bash
#!/bin/bash
#
# Python Development Container Manager
#

set -e

# Function to display help
function show_help() {
    echo "Python Development Container Manager"
    echo "Usage: dev.sh COMMAND"
    echo ""
    echo "Commands:"
    echo "  start       Start development container"
    echo "  stop        Stop development container"
    echo "  shell       Open a shell in the running container"
    echo "  exec CMD    Execute a command in the container"
    echo "  build       Rebuild the container"
    echo "  logs        Show container logs"
    echo "  status      Check container status"
}

# Check if command is provided
if [ $# -lt 1 ]; then
    show_help
    exit 1
fi

COMMAND="$1"
shift

# Execute appropriate command
case "$COMMAND" in
    start)
        echo "Starting development container..."
        docker-compose up -d
        echo "Container started. Use './dev.sh shell' to open a shell."
        ;;
        
    stop)
        echo "Stopping development container..."
        docker-compose down
        ;;
        
    shell)
        echo "Opening shell in development container..."
        docker-compose exec dev zsh
        ;;
        
    exec)
        if [ $# -lt 1 ]; then
            echo "Error: Command required"
            exit 1
        fi
        
        docker-compose exec dev "$@"
        ;;
        
    build)
        echo "Rebuilding development container..."
        docker-compose build
        ;;
        
    logs)
        docker-compose logs -f
        ;;
        
    status)
        if docker-compose ps | grep -q "Up"; then
            echo "Development container is running."
        else
            echo "Development container is not running."
        fi
        ;;
        
    *)
        echo "Error: Unknown command $COMMAND"
        show_help
        exit 1
        ;;
esac

exit 0
```

5. Make the script executable:

```bash
chmod +x dev.sh
```

6. Start and use the development container:

```bash
# Build and start the container
./dev.sh build
./dev.sh start

# Open a shell in the container
./dev.sh shell

# Execute a command in the container
./dev.sh exec python --version
```

7. Configure VSCode to connect to development container:

Install the Remote - Containers extension in VSCode, then:
- Open the project folder
- Click on the green icon in the lower left corner
- Select "Remote-Containers: Reopen in Container"

#### Remote Pair Programming with Tmate

1. Install tmate:

```bash
# For Arch Linux
sudo pacman -S tmate

# Alternative installation
git clone https://github.com/tmate-io/tmate.git
cd tmate
./autogen.sh
./configure
make
sudo make install
```

2. Create a tmate configuration file:

```bash
nano ~/.tmate.conf
```

Add the following content:

```
# Set terminal type
set -g default-terminal "screen-256color"

# Set prefix (same as tmux for muscle memory)
set -g prefix C-a
unbind-key C-b
bind-key C-a send-prefix

# Mouse mode
set -g mouse on

# Set easier window split keys
bind-key v split-window -h
bind-key h split-window -v

# Easy config reload
bind-key r source-file ~/.tmate.conf \; display-message "~/.tmate.conf reloaded."

# Custom status bar
set -g status-bg black
set -g status-fg white
set -g status-left-length 30
set -g status-left '#[fg=green](#S) #(whoami)'
set -g status-right '#[fg=yellow]#(cut -d " " -f 1-3 /proc/loadavg)#[default] #[fg=white]%H:%M#[default]'
```

3. Create a pair programming script:

```bash
nano ~/scripts/pair.sh
```

Add the following content:

```bash
#!/bin/bash
#
# Remote Pair Programming Session Manager
#

set -e

# Function to display help
function show_help() {
    echo "Remote Pair Programming Session Manager"
    echo "Usage: pair.sh COMMAND [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  start           Start a new pair programming session"
    echo "  stop            Stop current session"
    echo "  info            Show current session information"
    echo ""
    echo "Options for start:"
    echo "  --read-only     Create a read-only session"
    echo "  --directory DIR Start session in specific directory (default: current directory)"
    echo ""
    echo "Examples:"
    echo "  pair.sh start              # Start a new session in current directory"
    echo "  pair.sh start --read-only  # Start a read-only session"
    echo "  pair.sh info               # Show current session information"
}

# Default values
SESSION_TYPE="read-write"
DIRECTORY="$(pwd)"

# Parse command
if [ $# -lt 1 ]; then
    show_help
    exit 1
fi

COMMAND="$1"
shift

# Parse options for start command
if [ "$COMMAND" = "start" ]; then
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --read-only)
                SESSION_TYPE="read-only"
                shift
                ;;
            --directory)
                DIRECTORY="$2"
                shift 2
                ;;
            *)
                echo "Error: Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
fi

# Create session log file
LOGFILE="${HOME}/.pair_session.log"

# Execute appropriate command
case "$COMMAND" in
    start)
        # Change to target directory
        cd "$DIRECTORY"
        
        echo "Starting pair programming session in $DIRECTORY..."
        if [ "$SESSION_TYPE" = "read-only" ]; then
            echo "Creating read-only session..."
            tmate -F -f ~/.tmate.conf new-session -d -s pair "tmate set-option read-only;exec bash"
        else
            echo "Creating read-write session..."
            tmate -F -f ~/.tmate.conf new-session -d -s pair
        fi
        
        # Wait for connection information
        echo "Waiting for session information..."
        sleep 3
        
        # Get and display connection strings
        SSH_RO=$(tmate -S /tmp/tmate-1000/pair display -p '#{tmate_ssh_ro}')
        SSH_RW=$(tmate -S /tmp/tmate-1000/pair display -p '#{tmate_ssh}')
        WEB_RO=$(tmate -S /tmp/tmate-1000/pair display -p '#{tmate_web_ro}')
        WEB=$(tmate -S /tmp/tmate-1000/pair display -p '#{tmate_web}')
        
        echo ""
        echo "Session created! Share these connection details with your peers:"
        echo ""
        echo "SSH read-only: $SSH_RO"
        
        if [ "$SESSION_TYPE" != "read-only" ]; then
            echo "SSH read-write: $SSH_RW"
        fi
        
        echo "Web read-only: $WEB_RO"
        
        if [ "$SESSION_TYPE" != "read-only" ]; then
            echo "Web read-write: $WEB"
        fi
        
        # Save session information
        echo "timestamp: $(date)" > "$LOGFILE"
        echo "directory: $DIRECTORY" >> "$LOGFILE"
        echo "type: $SESSION_TYPE" >> "$LOGFILE"
        echo "ssh_ro: $SSH_RO" >> "$LOGFILE"
        echo "ssh_rw: $SSH_RW" >> "$LOGFILE"
        echo "web_ro: $WEB_RO" >> "$LOGFILE"
        echo "web: $WEB" >> "$LOGFILE"
        
        echo ""
        echo "Session information saved to $LOGFILE"
        echo "To connect to the session yourself, run: tmate -S /tmp/tmate-1000/pair attach"
        ;;
        
    stop)
        echo "Stopping pair programming session..."
        if pkill -f "tmate -F" > /dev/null 2>&1; then
            echo "Session stopped successfully."
            rm -f "$LOGFILE"
        else
            echo "No active session found."
        fi
        ;;
        
    info)
        if [ -f "$LOGFILE" ]; then
            echo "Current pair programming session:"
            echo ""
            cat "$LOGFILE" | grep -v "^web\|^ssh" | sed 's/^/  /'
            echo ""
            echo "Connection information:"
            echo ""
            if grep -q "type: read-only" "$LOGFILE"; then
                echo "  SSH read-only: $(grep ssh_ro "$LOGFILE" | cut -d ' ' -f 2-)"
                echo "  Web read-only: $(grep web_ro "$LOGFILE" | cut -d ' ' -f 2-)"
            else
                echo "  SSH read-only: $(grep ssh_ro "$LOGFILE" | cut -d ' ' -f 2-)"
                echo "  SSH read-write: $(grep ssh_rw "$LOGFILE" | cut -d ' ' -f 2-)"
                echo "  Web read-only: $(grep web_ro "$LOGFILE" | cut -d ' ' -f 2-)"
                echo "  Web read-write: $(grep web "$LOGFILE" | grep -v web_ro | cut -d ' ' -f 2-)"
            fi
            echo ""
            echo "To connect to the session yourself, run: tmate -S /tmp/tmate-1000/pair attach"
        else
            echo "No active session information found."
        fi
        ;;
        
    *)
        echo "Error: Unknown command $COMMAND"
        show_help
        exit 1
        ;;
esac

exit 0
```

4. Make the script executable:

```bash
chmod +x ~/scripts/pair.sh
```

5. Use the pair programming script:

```bash
# Start a new session
~/scripts/pair.sh start

# Start a read-only session
~/scripts/pair.sh start --read-only

# Check session information
~/scripts/pair.sh info

# Stop the session
~/scripts/pair.sh stop
```

### Resources

- [VSCode Remote Development](https://code.visualstudio.com/docs/remote/remote-overview)
- [GitHub Codespaces Documentation](https://docs.github.com/en/codespaces)
- [Docker Development Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Tmate Documentation](https://tmate.io/)
- [SSHFS Usage Guide](https://wiki.archlinux.org/title/SSHFS)
- [VSCode Remote Containers](https://code.visualstudio.com/docs/remote/containers)
- [Gitpod Documentation](https://www.gitpod.io/docs)
- [SSH Configuration Guide](https://www.ssh.com/academy/ssh/config)

## Week 3: Infrastructure as Code

### Core Learning Activities

1. **Infrastructure as Code Concepts** (2 hours)
   - Understand IaC principles and benefits
   - Learn about declarative vs. imperative approaches
   - Study state management concepts
   - Understand idempotency and convergence
   - Learn about drift detection and remediation

2. **Terraform Basics** (3 hours)
   - Install and configure Terraform
   - Learn HCL (HashiCorp Configuration Language)
   - Understand Terraform workflow
   - Create basic infrastructure definitions
   - Manage state files properly
   - Implement modular Terraform configurations

3. **Cloud-Specific IaC Tools** (3 hours)
   - Learn AWS CloudFormation or
   - Explore Azure Resource Manager or
   - Study Google Cloud Deployment Manager
   - Understand provider-specific features
   - Compare with provider-agnostic tools
   - Practice deployment and updates

4. **GitOps Workflow** (2 hours)
   - Understand GitOps principles
   - Configure CI/CD for infrastructure changes
   - Implement infrastructure testing
   - Set up change management processes
   - Learn about drift detection
   - Study approval workflows

### Practical Exercises

#### Terraform Installation and Basic Configuration

1. Install Terraform:

```bash
# For Arch Linux
sudo pacman -S terraform

# Alternative installation method
curl -fsSL https://releases.hashicorp.com/terraform/1.5.5/terraform_1.5.5_linux_amd64.zip -o terraform.zip
unzip terraform.zip
sudo mv terraform /usr/local/bin/
rm terraform.zip
```

2. Verify installation:

```bash
terraform version
```

3. Create a basic Terraform project for AWS:

```bash
mkdir -p ~/terraform-projects/aws-basic
cd ~/terraform-projects/aws-basic
```

4. Create provider configuration:

```bash
nano provider.tf
```

Add the following content:

```hcl
# Provider configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  
  # Optional backend configuration for remote state
  backend "local" {
    path = "terraform.tfstate"
  }
}

# Configure the AWS provider
provider "aws" {
  region = var.aws_region
  
  # Optional: explicitly set the profile
  # profile = "development"
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}
```

5. Create variables file:

```bash
nano variables.tf
```

Add the following content:

```hcl
# Input variables
variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-demo"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "CIDR blocks for the subnets"
  type        = map(string)
  default = {
    public_1  = "10.0.1.0/24"
    public_2  = "10.0.2.0/24"
    private_1 = "10.0.3.0/24"
    private_2 = "10.0.4.0/24"
  }
}
```

6. Create a terraform.tfvars file:

```bash
nano terraform.tfvars
```

Add the following content:

```hcl
aws_region   = "us-west-2"
environment  = "dev"
project_name = "terraform-demo"
vpc_cidr     = "10.0.0.0/16"
```

7. Create main infrastructure file:

```bash
nano main.tf
```

Add the following content:

```hcl
# Create a VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Create a public subnet in the first AZ
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidrs["public_1"]
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.project_name}-public-1"
  }
}

# Create a public subnet in the second AZ
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidrs["public_2"]
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.project_name}-public-2"
  }
}

# Create a private subnet in the first AZ
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidrs["private_1"]
  availability_zone = "${var.aws_region}a"
  
  tags = {
    Name = "${var.project_name}-private-1"
  }
}

# Create a private subnet in the second AZ
resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidrs["private_2"]
  availability_zone = "${var.aws_region}b"
  
  tags = {
    Name = "${var.project_name}-private-2"
  }
}

# Create a route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Associate the public route table with public subnets
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# Create a security group for the web servers
resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # In production, restrict to your IP
    description = "SSH"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  
  tags = {
    Name = "${var.project_name}-web-sg"
  }
}
```

8. Create an outputs file:

```bash
nano outputs.tf
```

Add the following content:

```hcl
# Output values
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]
}

output "web_security_group_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}
```

9. Initialize Terraform:

```bash
terraform init
```

10. Validate the configuration:

```bash
terraform validate
```

11. Create an execution plan:

```bash
terraform plan -out=tfplan
```

12. Apply the plan (if you have AWS credentials configured):

```bash
terraform apply tfplan
```

13. Destroy the infrastructure when done:

```bash
terraform destroy
```

#### Creating a Terraform Module

1. Create a module directory structure:

```bash
mkdir -p ~/terraform-projects/modules/vpc
cd ~/terraform-projects/modules/vpc
```

2. Create module files:

```bash
# Create main file
nano main.tf

# Create variables file
nano variables.tf

# Create outputs file
nano outputs.tf
```

3. Add content to main.tf:

```hcl
# VPC Module
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  
  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  count = var.create_igw ? 1 : 0
  
  vpc_id = aws_vpc.this.id
  
  tags = merge(
    {
      "Name" = "${var.name}-igw"
    },
    var.tags
  )
}

# Public Subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnets)
  
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch
  
  tags = merge(
    {
      "Name" = "${var.name}-public-${count.index + 1}"
    },
    var.tags
  )
}

# Private Subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnets)
  
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = element(var.azs, count.index)
  
  tags = merge(
    {
      "Name" = "${var.name}-private-${count.index + 1}"
    },
    var.tags
  )
}

# Public Route Table
resource "aws_route_table" "public" {
  count = length(var.public_subnets) > 0 ? 1 : 0
  
  vpc_id = aws_vpc.this.id
  
  tags = merge(
    {
      "Name" = "${var.name}-public-rt"
    },
    var.tags
  )
}

# Public Routes
resource "aws_route" "public_internet_gateway" {
  count = var.create_igw && length(var.public_subnets) > 0 ? 1 : 0
  
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
  
  timeouts {
    create = "5m"
  }
}

# Private Route Tables
resource "aws_route_table" "private" {
  count = length(var.private_subnets) > 0 ? 1 : 0
  
  vpc_id = aws_vpc.this.id
  
  tags = merge(
    {
      "Name" = "${var.name}-private-rt"
    },
    var.tags
  )
}

# Associate Public Subnets with Route Table
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)
  
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public[0].id
}

# Associate Private Subnets with Route Table
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)
  
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private[0].id
}
```

4. Add content to variables.tf:

```hcl
variable "name" {
  description = "Name to be used on all resources as prefix"
  type        = string
}

variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "create_igw" {
  description = "Controls if an Internet Gateway is created for public subnets"
  type        = bool
  default     = true
}

variable "azs" {
  description = "A list of availability zones in the region"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "map_public_ip_on_launch" {
  description = "Should be true if you want to auto-assign public IP on launch"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
```

5. Add content to outputs.tf:

```hcl
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = length(aws_route_table.public) > 0 ? aws_route_table.public[0].id : null
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = length(aws_route_table.private) > 0 ? aws_route_table.private[0].id : null
}

output "igw_id" {
  description = "ID of the Internet Gateway"
  value       = length(aws_internet_gateway.this) > 0 ? aws_internet_gateway.this[0].id : null
}
```

6. Create a project that uses the module:

```bash
mkdir -p ~/terraform-projects/aws-module-test
cd ~/terraform-projects/aws-module-test
```

7. Create the main.tf file:

```bash
nano main.tf
```

Add the following content:

```hcl
provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source = "../modules/vpc"
  
  name       = "my-vpc"
  cidr_block = "10.0.0.0/16"
  
  azs            = ["us-west-2a", "us-west-2b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
  
  tags = {
    Environment = "dev"
    Project     = "terraform-module-test"
  }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}
```

8. Initialize and validate:

```bash
terraform init
terraform validate
```

9. Create a plan:

```bash
terraform plan
```

#### Creating a Terraform Project Structure

1. Create a project directory structure:

```bash
mkdir -p ~/terraform-projects/webapp-infrastructure/{environments/{dev,staging,prod},modules}
cd ~/terraform-projects/webapp-infrastructure
```

2. Create a structure for the dev environment:

```bash
cd environments/dev
mkdir -p {main,variables,outputs,terraform}.tf
```

3. Create a main.tf file:

```bash
nano main.tf
```

Add the following content:

```hcl
provider "aws" {
  region = var.region
  profile = "development"
}

module "vpc" {
  source = "../../modules/vpc"
  
  name       = "${var.project_name}-vpc"
  cidr_block = var.vpc_cidr
  
  azs             = var.availability_zones
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

module "web_servers" {
  source = "../../modules/web_servers"
  
  name               = "${var.project_name}-web"
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnet_ids
  instance_type      = var.web_instance_type
  ami_id             = var.web_ami_id
  key_name           = var.ssh_key_name
  instance_count     = var.web_instance_count
  root_volume_size   = var.web_root_volume_size
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

module "database" {
  source = "../../modules/database"
  
  name               = "${var.project_name}-db"
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  db_instance_class  = var.db_instance_class
  db_engine          = var.db_engine
  db_engine_version  = var.db_engine_version
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
```

4. Create a variables.tf file:

```bash
nano variables.tf
```

Add the following content:

```hcl
variable "region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "webapp"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "web_instance_type" {
  description = "Instance type for web servers"
  type        = string
  default     = "t3.micro"
}

variable "web_ami_id" {
  description = "AMI ID for web servers"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI (update with actual ID)
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "dev-key"
}

variable "web_instance_count" {
  description = "Number of web server instances"
  type        = number
  default     = 2
}

variable "web_root_volume_size" {
  description = "Size of the root volume for web servers"
  type        = number
  default     = 20
}

variable "db_instance_class" {
  description = "Instance class for the RDS instance"
  type        = string
  default     = "db.t3.small"
}

variable "db_engine" {
  description = "Database engine"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0"
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "webapp"
}

variable "db_username" {
  description = "Username for the database"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "db_password" {
  description = "Password for the database"
  type        = string
  sensitive   = true
}
```

5. Create terraform.tfvars:

```bash
nano terraform.tfvars
```

Add the following content:

```hcl
region = "us-west-2"
environment = "dev"
project_name = "webapp"

vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

web_instance_type = "t3.micro"
web_ami_id = "ami-0c55b159cbfafe1f0"  # Update with actual AMI ID
ssh_key_name = "dev-key"
web_instance_count = 2
web_root_volume_size = 20

db_instance_class = "db.t3.small"
db_engine = "mysql"
db_engine_version = "8.0"
db_name = "webapp"
db_username = "admin"
db_password = "ChangeMe123!"  # Use secrets management in production
```

6. Create an outputs.tf file:

```bash
nano outputs.tf
```

Add the following content:

```hcl
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "web_server_public_ips" {
  description = "Public IPs of web servers"
  value       = module.web_servers.public_ips
}

output "web_server_private_ips" {
  description = "Private IPs of web servers"
  value       = module.web_servers.private_ips
}

output "database_endpoint" {
  description = "Endpoint of the database"
  value       = module.database.endpoint
}

output "database_port" {
  description = "Port of the database"
  value       = module.database.port
}
```

7. Create a backend configuration:

```bash
nano terraform.tf
```

Add the following content:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  
  # For production, use a remote backend
  # For local development, this local backend is sufficient
  backend "local" {
    path = "terraform.tfstate"
  }
  
  # Example S3 backend configuration (for production)
  # backend "s3" {
  #   bucket         = "terraform-state-bucket"
  #   key            = "webapp/dev/terraform.tfstate"
  #   region         = "us-west-2"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }
}
```

8. Create the web_servers module structure:

```bash
mkdir -p ../../modules/web_servers
cd ../../modules/web_servers
touch {main,variables,outputs}.tf
```

9. Create a database module structure:

```bash
mkdir -p ../database
cd ../database
touch {main,variables,outputs}.tf
```

### Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS CloudFormation Guide](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html)
- [Azure Resource Manager Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/overview)
- [Google Cloud Deployment Manager](https://cloud.google.com/deployment-manager/docs)
- [GitOps Principles](https://www.gitops.tech/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [Infrastructure as Code Tutorial](https://learn.hashicorp.com/collections/terraform/modules)
- [Terraform Module Registry](https://registry.terraform.io/browse/modules)

## Week 4: Cloud Resource Management and Workflows

### Core Learning Activities

1. **Cloud Storage Integration** (2 hours)
   - Set up S3 or equivalent cloud storage
   - Configure rclone for cloud storage access
   - Implement backup to cloud storage
   - Sync files between local and cloud
   - Understand encryption options
   - Implement access control policies

2. **Database Connectivity** (3 hours)
   - Connect to cloud databases
   - Configure secure access methods
   - Set up local development databases
   - Implement database migrations
   - Manage database credentials securely
   - Create database backup and restore procedures

3. **CI/CD Pipelines** (3 hours)
   - Understand CI/CD concepts
   - Configure GitHub Actions or similar
   - Implement testing in pipelines
   - Set up deployment automation
   - Manage environments (dev, staging, prod)
   - Implement approval workflows

4. **Cost Management and Optimization** (2 hours)
   - Understand cloud pricing models
   - Implement resource tagging
   - Set up budget alerts
   - Learn cost optimization strategies
   - Configure automated scaling
   - Implement resource scheduling

### Practical Exercises

#### Setting Up Rclone for Cloud Storage

1. Install rclone:

```bash
# For Arch Linux
sudo pacman -S rclone

# Alternative installation
curl https://rclone.org/install.sh | sudo bash
```

2. Configure rclone for AWS S3:

```bash
rclone config
```

Follow the interactive prompts:
- Choose `n` for new remote
- Name: `s3`
- Storage type: Choose `AWS S3`
- Provider: Choose `AWS`
- Access key ID: Enter your AWS access key
- Secret access key: Enter your AWS secret key
- Region: Enter your AWS region (e.g., `us-west-2`)
- Endpoint: Leave blank for S3
- Location constraint: Leave blank
- ACL: Choose `private`
- Say `y` to accept the configuration

3. Configure rclone for Google Drive:

```bash
rclone config
```

Follow the interactive prompts:
- Choose `n` for new remote
- Name: `gdrive`
- Storage type: Choose `Google Drive`
- Client ID: Leave blank for default
- Client Secret: Leave blank for default
- Scope: Choose `1` for full access
- Root folder ID: Leave blank
- Service account file: Leave blank
- Edit advanced config: `n`
- Use auto config: Choose `y` (this will open a browser for authentication)
- Complete the authentication in your browser
- Say `y` to accept the configuration

4. Test the configurations:

```bash
# List S3 buckets
rclone lsd s3:

# List files in Google Drive
rclone lsd gdrive:
```

5. Create a cloud backup script:

```bash
nano ~/scripts/cloud-backup.sh
```

Add the following content:

```bash
#!/bin/bash
#
# Cloud Backup Script
#

set -e

# Function to display help
function show_help() {
    echo "Cloud Backup Script"
    echo "Usage: cloud-backup.sh [options] COMMAND SOURCE DESTINATION"
    echo ""
    echo "Commands:"
    echo "  backup      Backup SOURCE to DESTINATION"
    echo "  sync        Sync SOURCE with DESTINATION (bi-directional)"
    echo "  restore     Restore from DESTINATION to SOURCE"
    echo ""
    echo "Options:"
    echo "  --dry-run          Show what would be transferred without actually transferring"
    echo "  --exclude PATTERN  Exclude files matching PATTERN"
    echo "  --include PATTERN  Include files matching PATTERN"
    echo "  --help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  cloud-backup.sh backup ~/Documents s3:my-bucket/documents"
    echo "  cloud-backup.sh sync ~/Projects gdrive:Projects"
    echo "  cloud-backup.sh restore s3:my-bucket/documents ~/Documents"
}

# Default values
DRY_RUN=false
EXCLUDE_PATTERNS=()
INCLUDE_PATTERNS=()

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --exclude)
            EXCLUDE_PATTERNS+=("$2")
            shift 2
            ;;
        --include)
            INCLUDE_PATTERNS+=("$2")
            shift 2
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

# Check if command is provided
if [ $# -lt 3 ]; then
    echo "Error: Not enough arguments"
    show_help
    exit 1
fi

COMMAND="$1"
SOURCE="$2"
DESTINATION="$3"

# Prepare rclone options
RCLONE_OPTS=("--progress")

if [ "$DRY_RUN" = true ]; then
    RCLONE_OPTS+=("--dry-run")
fi

for pattern in "${EXCLUDE_PATTERNS[@]}"; do
    RCLONE_OPTS+=("--exclude" "$pattern")
done

for pattern in "${INCLUDE_PATTERNS[@]}"; do
    RCLONE_OPTS+=("--include" "$pattern")
done

# Add timestamp to log file
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="$HOME/cloud-backup-$TIMESTAMP.log"

# Execute appropriate command
case "$COMMAND" in
    backup)
        echo "Backing up $SOURCE to $DESTINATION..."
        echo "Started: $(date)" | tee -a "$LOG_FILE"
        
        rclone copy "$SOURCE" "$DESTINATION" "${RCLONE_OPTS[@]}" 2>&1 | tee -a "$LOG_FILE"
        
        echo "Backup completed: $(date)" | tee -a "$LOG_FILE"
        echo "Log saved to $LOG_FILE"
        ;;
        
    sync)
        echo "Syncing $SOURCE with $DESTINATION..."
        echo "Started: $(date)" | tee -a "$LOG_FILE"
        
        rclone sync "$SOURCE" "$DESTINATION" "${RCLONE_OPTS[@]}" 2>&1 | tee -a "$LOG_FILE"
        
        echo "Sync completed: $(date)" | tee -a "$LOG_FILE"
        echo "Log saved to $LOG_FILE"
        ;;
        
    restore)
        echo "Restoring from $SOURCE to $DESTINATION..."
        echo "Started: $(date)" | tee -a "$LOG_FILE"
        
        read -p "This will overwrite files in $DESTINATION. Continue? (y/n): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rclone copy "$SOURCE" "$DESTINATION" "${RCLONE_OPTS[@]}" 2>&1 | tee -a "$LOG_FILE"
            echo "Restore completed: $(date)" | tee -a "$LOG_FILE"
        else
            echo "Restore cancelled." | tee -a "$LOG_FILE"
        fi
        
        echo "Log saved to $LOG_FILE"
        ;;
        
    *)
        echo "Error: Unknown command $COMMAND"
        show_help
        exit 1
        ;;
esac

exit 0
# Month 10: Cloud Integration and Remote Development - Exercises

This document contains practical exercises to accompany the Month 10 learning guide. Complete these exercises to solidify your understanding of cloud service integration, remote development, infrastructure as code, and cloud resource management.

## Exercise 1: Cloud Provider CLI Setup and Usage

This exercise will help you get comfortable with cloud provider command-line tools and basic resource management.

### Cloud Provider Account Setup

Before starting, you'll need access to at least one cloud provider. If you don't have an account yet:

1. **Create a free tier account**:
   - AWS: https://aws.amazon.com/free/
   - Azure: https://azure.microsoft.com/free/
   - GCP: https://cloud.google.com/free/

2. **Install the appropriate CLI tool**:

   ```bash
   # For AWS CLI
   sudo pacman -S aws-cli
   # OR via pip
   pip install --user awscli
   
   # For Azure CLI
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   # Arch Linux
   sudo pacman -S azure-cli
   
   # For Google Cloud SDK
   curl https://sdk.cloud.google.com | bash
   # Arch Linux
   yay -S google-cloud-sdk
   ```

3. **Configure the CLI with your credentials**:

   ```bash
   # AWS
   aws configure
   
   # Azure
   az login
   
   # GCP
   gcloud init
   ```

### Tasks

1. **Cloud Resource Inventory**:
   ```bash
   # Create a script to inventory your cloud resources
   mkdir -p ~/cloud-exercises/inventory
   cd ~/cloud-exercises/inventory
   
   # Create the inventory script
   nano cloud-inventory.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Cloud Resource Inventory
   #
   
   OUTPUT_DIR="$PWD/inventory-$(date +'%Y-%m-%d')"
   mkdir -p "$OUTPUT_DIR"
   
   echo "Gathering cloud resource inventory to $OUTPUT_DIR..."
   
   # AWS Inventory
   if command -v aws &> /dev/null; then
     echo "=== AWS Resources ===" > "$OUTPUT_DIR/aws-inventory.txt"
     
     echo -e "\n== EC2 Instances ==" >> "$OUTPUT_DIR/aws-inventory.txt"
     aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,InstanceType,State.Name,Tags[?Key==`Name`].Value | [0]]' --output table >> "$OUTPUT_DIR/aws-inventory.txt" 2>/dev/null || echo "No EC2 instances found or not configured" >> "$OUTPUT_DIR/aws-inventory.txt"
     
     echo -e "\n== S3 Buckets ==" >> "$OUTPUT_DIR/aws-inventory.txt"
     aws s3 ls >> "$OUTPUT_DIR/aws-inventory.txt" 2>/dev/null || echo "No S3 buckets found or not configured" >> "$OUTPUT_DIR/aws-inventory.txt"
     
     echo -e "\n== Lambda Functions ==" >> "$OUTPUT_DIR/aws-inventory.txt"
     aws lambda list-functions --query 'Functions[*].[FunctionName,Runtime,MemorySize,Timeout]' --output table >> "$OUTPUT_DIR/aws-inventory.txt" 2>/dev/null || echo "No Lambda functions found or not configured" >> "$OUTPUT_DIR/aws-inventory.txt"
     
     echo -e "\n== RDS Databases ==" >> "$OUTPUT_DIR/aws-inventory.txt"
     aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,Engine,DBInstanceClass,DBInstanceStatus]' --output table >> "$OUTPUT_DIR/aws-inventory.txt" 2>/dev/null || echo "No RDS instances found or not configured" >> "$OUTPUT_DIR/aws-inventory.txt"
   else
     echo "AWS CLI not installed or not in PATH. Skipping AWS inventory." > "$OUTPUT_DIR/aws-inventory.txt"
   fi
   
   # Azure Inventory
   if command -v az &> /dev/null; then
     echo "=== Azure Resources ===" > "$OUTPUT_DIR/azure-inventory.txt"
     
     echo -e "\n== Resource Groups ==" >> "$OUTPUT_DIR/azure-inventory.txt"
     az group list --query '[*].name' -o table >> "$OUTPUT_DIR/azure-inventory.txt" 2>/dev/null || echo "No resource groups found or not configured" >> "$OUTPUT_DIR/azure-inventory.txt"
     
     echo -e "\n== Virtual Machines ==" >> "$OUTPUT_DIR/azure-inventory.txt"
     az vm list --query '[*].[name,resourceGroup,location,hardwareProfile.vmSize,powerState]' -o table >> "$OUTPUT_DIR/azure-inventory.txt" 2>/dev/null || echo "No VMs found or not configured" >> "$OUTPUT_DIR/azure-inventory.txt"
     
     echo -e "\n== Storage Accounts ==" >> "$OUTPUT_DIR/azure-inventory.txt"
     az storage account list --query '[*].[name,resourceGroup,location,kind]' -o table >> "$OUTPUT_DIR/azure-inventory.txt" 2>/dev/null || echo "No storage accounts found or not configured" >> "$OUTPUT_DIR/azure-inventory.txt"
     
     echo -e "\n== App Services ==" >> "$OUTPUT_DIR/azure-inventory.txt"
     az webapp list --query '[*].[name,resourceGroup,location,state]' -o table >> "$OUTPUT_DIR/azure-inventory.txt" 2>/dev/null || echo "No app services found or not configured" >> "$OUTPUT_DIR/azure-inventory.txt"
   else
     echo "Azure CLI not installed or not in PATH. Skipping Azure inventory." > "$OUTPUT_DIR/azure-inventory.txt"
   fi
   
   # GCP Inventory
   if command -v gcloud &> /dev/null; then
     echo "=== Google Cloud Resources ===" > "$OUTPUT_DIR/gcp-inventory.txt"
     
     echo -e "\n== Current Project ==" >> "$OUTPUT_DIR/gcp-inventory.txt"
     gcloud config get-value project >> "$OUTPUT_DIR/gcp-inventory.txt" 2>/dev/null || echo "No project set or not configured" >> "$OUTPUT_DIR/gcp-inventory.txt"
     
     echo -e "\n== Compute Instances ==" >> "$OUTPUT_DIR/gcp-inventory.txt"
     gcloud compute instances list >> "$OUTPUT_DIR/gcp-inventory.txt" 2>/dev/null || echo "No compute instances found or not configured" >> "$OUTPUT_DIR/gcp-inventory.txt"
     
     echo -e "\n== Storage Buckets ==" >> "$OUTPUT_DIR/gcp-inventory.txt"
     gsutil ls >> "$OUTPUT_DIR/gcp-inventory.txt" 2>/dev/null || echo "No storage buckets found or not configured" >> "$OUTPUT_DIR/gcp-inventory.txt"
     
     echo -e "\n== Cloud Functions ==" >> "$OUTPUT_DIR/gcp-inventory.txt"
     gcloud functions list --format="table(name,status,trigger,runtime)" >> "$OUTPUT_DIR/gcp-inventory.txt" 2>/dev/null || echo "No cloud functions found or not configured" >> "$OUTPUT_DIR/gcp-inventory.txt"
   else
     echo "Google Cloud SDK not installed or not in PATH. Skipping GCP inventory." > "$OUTPUT_DIR/gcp-inventory.txt"
   fi
   
   echo "Inventory complete! Results stored in $OUTPUT_DIR/"
   ```

   Make the script executable:
   ```bash
   chmod +x cloud-inventory.sh
   ```

   Run the script:
   ```bash
   ./cloud-inventory.sh
   ```

2. **Create a Simple Resource with CLI**:

   ```bash
   # Create a simple storage bucket 
   
   # For AWS S3
   aws s3 mb s3://my-cloud-exercises-bucket-$(date +%Y%m%d)
   
   # For Azure Storage
   az storage account create --name myexercisesstg$(date +%Y%m%d) --resource-group myResourceGroup --location eastus --sku Standard_LRS
   
   # For GCP Cloud Storage
   gsutil mb -l us-central1 gs://my-cloud-exercises-bucket-$(date +%Y%m%d)
   ```

3. **Create a Resource Tag Management Script**:

   ```bash
   nano tag-manager.sh
   ```

   Add the following content:
   ```bash
   #!/bin/bash
   #
   # Cloud Resource Tag Manager
   #
   
   set -e
   
   # Function to display help
   function show_help() {
     echo "Cloud Resource Tag Manager"
     echo "Usage: $0 COMMAND PROVIDER RESOURCE [options]"
     echo ""
     echo "Commands:"
     echo "  list      List tags for a resource"
     echo "  add       Add a tag to a resource"
     echo "  remove    Remove a tag from a resource"
     echo ""
     echo "Providers:"
     echo "  aws       Amazon Web Services"
     echo "  azure     Microsoft Azure"
     echo "  gcp       Google Cloud Platform"
     echo ""
     echo "Options:"
     echo "  --key KEY       Tag key (required for add)"
     echo "  --value VALUE   Tag value (required for add)"
     echo ""
     echo "Examples:"
     echo "  $0 list aws i-1234567890abcdef"
     echo "  $0 add aws i-1234567890abcdef --key Environment --value Development"
     echo "  $0 remove azure /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myResourceGroup --key Owner"
   }
   
   # Check if we have enough arguments
   if [ $# -lt 3 ]; then
     show_help
     exit 1
   fi
   
   COMMAND=$1
   PROVIDER=$2
   RESOURCE=$3
   shift 3
   
   # Parse additional options
   TAG_KEY=""
   TAG_VALUE=""
   
   while [[ $# -gt 0 ]]; do
     case "$1" in
       --key)
         TAG_KEY="$2"
         shift 2
         ;;
       --value)
         TAG_VALUE="$2"
         shift 2
         ;;
       *)
         echo "Unknown option: $1"
         show_help
         exit 1
         ;;
     esac
   done
   
   # AWS tag management
   function aws_list_tags() {
     local resource=$1
     
     if [[ $resource == i-* ]]; then
       # EC2 instance
       aws ec2 describe-tags --filters "Name=resource-id,Values=$resource" --output table
     elif [[ $resource == s3://* ]]; then
       # S3 bucket
       bucket=$(echo $resource | sed 's|s3://||')
       aws s3api get-bucket-tagging --bucket $bucket --output table 2>/dev/null || echo "No tags found or bucket doesn't exist"
     else
       echo "Unsupported resource type for AWS. Supported types: EC2 instances (i-*), S3 buckets (s3://*)"
     fi
   }
   
   function aws_add_tag() {
     local resource=$1
     local key=$2
     local value=$3
     
     if [[ -z "$key" || -z "$value" ]]; then
       echo "Error: Both key and value are required for adding a tag"
       exit 1
     fi
     
     if [[ $resource == i-* ]]; then
       # EC2 instance
       aws ec2 create-tags --resources $resource --tags "Key=$key,Value=$value"
       echo "Tag added to EC2 instance $resource"
     elif [[ $resource == s3://* ]]; then
       # S3 bucket
       bucket=$(echo $resource | sed 's|s3://||')
       # First get existing tags, if any
       existing_tags=$(aws s3api get-bucket-tagging --bucket $bucket 2>/dev/null || echo '{"TagSet": []}')
       
       # Create a temporary file for the new tag set
       tmp_file=$(mktemp)
       
       if [[ $existing_tags == *"TagSet"* ]]; then
         # Extract TagSet and add the new tag
         echo $existing_tags | jq ".TagSet += [{\"Key\": \"$key\", \"Value\": \"$value\"}]" > $tmp_file
         aws s3api put-bucket-tagging --bucket $bucket --tagging file://$tmp_file
       else
         # Create a new TagSet with just this tag
         echo "{\"TagSet\": [{\"Key\": \"$key\", \"Value\": \"$value\"}]}" > $tmp_file
         aws s3api put-bucket-tagging --bucket $bucket --tagging file://$tmp_file
       fi
       
       rm $tmp_file
       echo "Tag added to S3 bucket $bucket"
     else
       echo "Unsupported resource type for AWS. Supported types: EC2 instances (i-*), S3 buckets (s3://*)"
     fi
   }
   
   function aws_remove_tag() {
     local resource=$1
     local key=$2
     
     if [[ -z "$key" ]]; then
       echo "Error: Key is required for removing a tag"
       exit 1
     fi
     
     if [[ $resource == i-* ]]; then
       # EC2 instance
       aws ec2 delete-tags --resources $resource --tags "Key=$key"
       echo "Tag with key '$key' removed from EC2 instance $resource"
     elif [[ $resource == s3://* ]]; then
       # S3 bucket
       bucket=$(echo $resource | sed 's|s3://||')
       # First get existing tags
       existing_tags=$(aws s3api get-bucket-tagging --bucket $bucket 2>/dev/null)
       
       if [[ -z "$existing_tags" ]]; then
         echo "No tags found on bucket $bucket"
         exit 0
       fi
       
       # Create a temporary file for the new tag set
       tmp_file=$(mktemp)
       
       # Filter out the tag to remove
       echo $existing_tags | jq ".TagSet = [.TagSet[] | select(.Key != \"$key\")]" > $tmp_file
       
       # Check if any tags remain
       remaining_tags=$(jq '.TagSet | length' $tmp_file)
       
       if [[ $remaining_tags -eq 0 ]]; then
         # If no tags remain, remove all tagging
         aws s3api delete-bucket-tagging --bucket $bucket
         echo "Removed all tags from S3 bucket $bucket"
       else
         # Otherwise, update with the new tag set
         aws s3api put-bucket-tagging --bucket $bucket --tagging file://$tmp_file
         echo "Tag with key '$key' removed from S3 bucket $bucket"
       fi
       
       rm $tmp_file
     else
       echo "Unsupported resource type for AWS. Supported types: EC2 instances (i-*), S3 buckets (s3://*)"
     fi
   }
   
   # Azure tag management
   function azure_list_tags() {
     local resource=$1
     
     az tag list --resource-id $resource -o table
   }
   
   function azure_add_tag() {
     local resource=$1
     local key=$2
     local value=$3
     
     if [[ -z "$key" || -z "$value" ]]; then
       echo "Error: Both key and value are required for adding a tag"
       exit 1
     fi
     
     az tag update --resource-id $resource --operation merge --tags "$key=$value"
     echo "Tag added to Azure resource $resource"
   }
   
   function azure_remove_tag() {
     local resource=$1
     local key=$2
     
     if [[ -z "$key" ]]; then
       echo "Error: Key is required for removing a tag"
       exit 1
     fi
     
     # First get the current tags
     current_tags=$(az tag list --resource-id $resource --query "properties.tags" -o json)
     
     # Remove the specified tag
     updated_tags=$(echo $current_tags | jq "del(.[\"$key\"])")
     
     # Update the resource with the new tags
     az tag update --resource-id $resource --operation replace --tags "$updated_tags"
     echo "Tag with key '$key' removed from Azure resource $resource"
   }
   
   # GCP tag management
   function gcp_list_tags() {
     local resource=$1
     
     if [[ $resource == gs://* ]]; then
       # GCS bucket
       bucket=$(echo $resource | sed 's|gs://||')
       gsutil label get gs://$bucket
     elif [[ $resource == projects/* ]]; then
       # Project
       gcloud beta resource-manager tags bindings list --parent=$resource
     else
       echo "Unsupported resource type for GCP. Supported types: GCS buckets (gs://*), Projects (projects/*)"
     fi
   }
   
   function gcp_add_tag() {
     local resource=$1
     local key=$2
     local value=$3
     
     if [[ -z "$key" || -z "$value" ]]; then
       echo "Error: Both key and value are required for adding a tag"
       exit 1
     fi
     
     if [[ $resource == gs://* ]]; then
       # GCS bucket
       bucket=$(echo $resource | sed 's|gs://||')
       
       # Get current labels
       tmp_file=$(mktemp)
       gsutil label get gs://$bucket > $tmp_file 2>/dev/null || echo "{}" > $tmp_file
       
       # Add the new label
       cat $tmp_file | jq ". + {\"$key\": \"$value\"}" > ${tmp_file}.new
       
       # Update bucket labels
       gsutil label set ${tmp_file}.new gs://$bucket
       rm $tmp_file ${tmp_file}.new
       
       echo "Label added to GCS bucket gs://$bucket"
     else
       echo "Unsupported resource type for GCP. Supported types: GCS buckets (gs://*)"
     fi
   }
   
   function gcp_remove_tag() {
     local resource=$1
     local key=$2
     
     if [[ -z "$key" ]]; then
       echo "Error: Key is required for removing a tag"
       exit 1
     fi
     
     if [[ $resource == gs://* ]]; then
       # GCS bucket
       bucket=$(echo $resource | sed 's|gs://||')
       
       # Get current labels
       tmp_file=$(mktemp)
       gsutil label get gs://$bucket > $tmp_file 2>/dev/null
       
       if [[ ! -s $tmp_file ]]; then
         echo "No labels found on bucket gs://$bucket"
         rm $tmp_file
         exit 0
       fi
       
       # Remove the label
       cat $tmp_file | jq "del(.[\"$key\"])" > ${tmp_file}.new
       
       # Update bucket labels
       gsutil label set ${tmp_file}.new gs://$bucket
       rm $tmp_file ${tmp_file}.new
       
       echo "Label with key '$key' removed from GCS bucket gs://$bucket"
     else
       echo "Unsupported resource type for GCP. Supported types: GCS buckets (gs://*)"
     fi
   }
   
   # Execute the requested command
   case "$PROVIDER" in
     aws)
       case "$COMMAND" in
         list)
           aws_list_tags "$RESOURCE"
           ;;
         add)
           aws_add_tag "$RESOURCE" "$TAG_KEY" "$TAG_VALUE"
           ;;
         remove)
           aws_remove_tag "$RESOURCE" "$TAG_KEY"
           ;;
         *)
           echo "Unknown command: $COMMAND"
           show_help
           exit 1
           ;;
       esac
       ;;
     azure)
       case "$COMMAND" in
         list)
           azure_list_tags "$RESOURCE"
           ;;
         add)
           azure_add_tag "$RESOURCE" "$TAG_KEY" "$TAG_VALUE"
           ;;
         remove)
           azure_remove_tag "$RESOURCE" "$TAG_KEY"
           ;;
         *)
           echo "Unknown command: $COMMAND"
           show_help
           exit 1
           ;;
       esac
       ;;
     gcp)
       case "$COMMAND" in
         list)
           gcp_list_tags "$RESOURCE"
           ;;
         add)
           gcp_add_tag "$RESOURCE" "$TAG_KEY" "$TAG_VALUE"
           ;;
         remove)
           gcp_remove_tag "$RESOURCE" "$TAG_KEY"
           ;;
         *)
           echo "Unknown command: $COMMAND"
           show_help
           exit 1
           ;;
       esac
       ;;
     *)
       echo "Unknown provider: $PROVIDER"
       show_help
       exit 1
       ;;
   esac
   ```

   Make the script executable:
   ```bash
   chmod +x tag-manager.sh
   ```

   Test the script with your resources:
   ```bash
   # For AWS
   ./tag-manager.sh list aws s3://my-cloud-exercises-bucket-YYYYMMDD
   ./tag-manager.sh add aws s3://my-cloud-exercises-bucket-YYYYMMDD --key Project --value CloudExercises
   
   # For Azure
   # First, get the resource ID
   RESOURCE_ID=$(az storage account show --name myexercisesstgYYYYMMDD --resource-group myResourceGroup --query id -o tsv)
   ./tag-manager.sh list azure $RESOURCE_ID
   ./tag-manager.sh add azure $RESOURCE_ID --key Project --value CloudExercises
   
   # For GCP
   ./tag-manager.sh list gcp gs://my-cloud-exercises-bucket-YYYYMMDD
   ./tag-manager.sh add gcp gs://my-cloud-exercises-bucket-YYYYMMDD --key project --value cloud-exercises
   ```

4. **Clean up** (Optional - do this after completing all exercises):

   ```bash
   # AWS
   aws s3 rb s3://my-cloud-exercises-bucket-YYYYMMDD --force
   
   # Azure
   az storage account delete --name myexercisesstgYYYYMMDD --resource-group myResourceGroup -y
   
   # GCP
   gsutil rm -r gs://my-cloud-exercises-bucket-YYYYMMDD
   ```

## Exercise 2: Remote Development Environment Setup

This exercise will guide you through setting up efficient remote development environments.

### SSH-Based Remote Development

1. **Configure SSH for Remote Development**:

   ```bash
   # Create a dedicated key for remote development
   ssh-keygen -t ed25519 -C "remote-dev-key" -f ~/.ssh/remote_dev_key
   
   # Create an SSH config file (if it doesn't exist)
   touch ~/.ssh/config
   chmod 600 ~/.ssh/config
   
   # Add a configuration for your remote server
   nano ~/.ssh/config
   ```

   Add the following configuration (replace placeholders with your actual values):
   ```
   # Default settings for all hosts
   Host *
       ControlMaster auto
       ControlPath ~/.ssh/control/%r@%h:%p
       ControlPersist 10m
       ServerAliveInterval 60
       ServerAliveCountMax 5
       
   # Development server
   Host dev-server
       HostName your-server-ip-or-hostname
       User your-username
       Port 22
       IdentityFile ~/.ssh/remote_dev_key
       ForwardAgent yes
       
   # GitHub with dedicated key
   Host github.com
       HostName github.com
       User git
       IdentityFile ~/.ssh/github_key
       IdentitiesOnly yes
   ```

2. **Set up a Remote Mount with SSHFS**:

   ```bash
   # Install SSHFS if not already installed
   sudo pacman -S sshfs
   
   # Create a mount point
   mkdir -p ~/remote-projects
   
   # Mount the remote directory
   sshfs dev-server:/home/your-username/projects ~/remote-projects -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3
   ```

3. **Create a Remote Mount Management Script**:

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

   Make the script executable:
   ```bash
   chmod +x ~/scripts/remote-mount.sh
   ```

   Test the script:
   ```bash
   ~/scripts/remote-mount.sh mount dev-server:/home/your-username/projects
   ~/scripts/remote-mount.sh list
   ~/scripts/remote-mount.sh check ~/remote-mounts/dev-server
   ~/scripts/remote-mount.sh unmount ~/remote-mounts/dev-server
   ```

### Container-Based Development

1. **Create a Python Development Container**:

   ```bash
   # Create a project directory
   mkdir -p ~/projects/python-dev-container
   cd ~/projects/python-dev-container
   
   # Create a Dockerfile
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

2. **Create a Docker Compose file**:

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

3. **Create a Development Container Management Script**:

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

   Make the script executable:
   ```bash
   chmod +x dev.sh
   ```

   Use the script:
   ```bash
   ./dev.sh build
   ./dev.sh start
   ./dev.sh shell
   ```

4. **Create a simple Python project in the container**:

   Inside the container shell, initialize a Python project:
   ```bash
   # Inside container
   mkdir -p hello_app
   cd hello_app
   
   # Create a simple Flask application
   poetry init -n
   poetry add flask
   poetry add --dev pytest
   
   # Create a simple app file
   echo 'from flask import Flask
   
   app = Flask(__name__)
   
   @app.route("/")
   def hello():
       return "Hello from containerized development environment!"
   
   if __name__ == "__main__":
       app.run(host="0.0.0.0", port=8000, debug=True)
   ' > app.py
   
   # Create a test file
   mkdir -p tests
   echo 'import pytest
   from app import app
   
   @pytest.fixture
   def client():
       app.config["TESTING"] = True
       with app.test_client() as client:
           yield client
   
   def test_hello(client):
       response = client.get("/")
       assert response.status_code == 200
       assert b"Hello from containerized development environment!" in response.data
   ' > tests/test_app.py
   
   # Run the tests
   poetry run pytest
   
   # Run the application
   poetry run python app.py
   ```

   In a different terminal, test the application:
   ```bash
   curl http://localhost:8000/
   ```

## Exercise 3: Infrastructure as Code with Terraform

This exercise will introduce you to Infrastructure as Code using Terraform.

### Terraform Basics

1. **Install Terraform**:

   ```bash
   # For Arch Linux
   sudo pacman -S terraform
   
   # Alternative installation method
   curl -fsSL https://releases.hashicorp.com/terraform/1.5.5/terraform_1.5.5_linux_amd64.zip -o terraform.zip
   unzip terraform.zip
   sudo mv terraform /usr/local/bin/
   rm terraform.zip
   ```

2. **Create a Basic Terraform Project**:

   ```bash
   # Create a directory for your Terraform project
   mkdir -p ~/terraform-projects/first-project
   cd ~/terraform-projects/first-project
   
   # Create provider configuration
   nano provider.tf
   ```

   Add the following content (adjust for your preferred cloud provider):
   ```hcl
   # AWS Provider Configuration
   terraform {
     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = "~> 4.0"
       }
     }
   }
   
   provider "aws" {
     region = var.aws_region
     
     # Uncomment to specify a profile
     # profile = "default"
     
     default_tags {
       tags = {
         Environment = var.environment
         Project     = var.project_name
         ManagedBy   = "Terraform"
       }
     }
   }
   ```

3. **Create Variables File**:

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
     default     = "terraform-exercise"
   }
   
   variable "vpc_cidr" {
     description = "CIDR block for the VPC"
     type        = string
     default     = "10.0.0.0/16"
   }
   
   variable "public_subnet_cidr" {
     description = "CIDR block for the public subnet"
     type        = string
     default     = "10.0.1.0/24"
   }
   ```

4. **Create Main Infrastructure File**:

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
   
   # Create a public subnet
   resource "aws_subnet" "public" {
     vpc_id                  = aws_vpc.main.id
     cidr_block              = var.public_subnet_cidr
     map_public_ip_on_launch = true
     availability_zone       = "${var.aws_region}a"
     
     tags = {
       Name = "${var.project_name}-public-subnet"
     }
   }
   
   # Create a route table
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
   
   # Associate the route table with the subnet
   resource "aws_route_table_association" "public" {
     subnet_id      = aws_subnet.public.id
     route_table_id = aws_route_table.public.id
   }
   
   # Create a security group
   resource "aws_security_group" "web" {
     name        = "${var.project_name}-web-sg"
     description = "Allow web traffic"
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
       cidr_blocks = ["0.0.0.0/0"]  # For production, restrict to your IP
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

5. **Create Outputs File**:

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
   
   output "public_subnet_id" {
     description = "ID of the public subnet"
     value       = aws_subnet.public.id
   }
   
   output "security_group_id" {
     description = "ID of the security group"
     value       = aws_security_group.web.id
   }
   ```

6. **Initialize Terraform**:

   ```bash
   terraform init
   ```

7. **Create a Plan**:

   ```bash
   terraform plan -out=tfplan
   ```

8. **Apply the Plan** (If you want to actually create the resources):

   ```bash
   terraform apply tfplan
   ```

9. **Create a Terraform Module**:

   ```bash
   # Create a modules directory
   mkdir -p ~/terraform-projects/modules/vpc
   cd ~/terraform-projects/modules/vpc
   
   # Create module files
   nano main.tf
   ```

   Add the following content:
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

10. **Create Variables File for the Module**:

    ```bash
    nano variables.tf
    ```

    Add the following content:
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

11. **Create Outputs File for the Module**:

    ```bash
    nano outputs.tf
    ```

    Add the following content:
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

12. **Create a Project Using the Module**:

    ```bash
    mkdir -p ~/terraform-projects/module-test
    cd ~/terraform-projects/module-test
    
    # Create main.tf
    nano main.tf
    ```

    Add the following content:
    ```hcl
    provider "aws" {
      region = "us-west-2"
    }
    
    module "vpc" {
      source = "../modules/vpc"
      
      name       = "module-test"
      cidr_block = "10.0.0.0/16"
      
      azs             = ["us-west-2a", "us-west-2b"]
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

13. **Initialize and Test the Module Project**:

    ```bash
    terraform init
    terraform validate
    terraform plan
    ```

14. **Clean Up** (if you applied the Terraform plan):

    ```bash
    terraform destroy
    ```

## Exercise 4: Cloud Resource Management and Workflows

This exercise will help you implement cloud storage integration, CI/CD pipelines, and cost management strategies.

### Cloud Storage Integration

1. **Install and Configure Rclone**:

   ```bash
   # Install rclone
   sudo pacman -S rclone
   
   # Configure for your cloud provider
   rclone config
   ```

   Follow the interactive prompts to set up your cloud storage provider.

2. **Create a Cloud Backup Script**:

   ```bash
   mkdir -p ~/scripts
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
   ```

   Make the script executable:
   ```bash
   chmod +x ~/scripts/cloud-backup.sh
   ```

   Test the script:
   ```bash
   # Create a test directory with some files
   mkdir -p ~/cloud-backup-test
   echo "Test file 1" > ~/cloud-backup-test/file1.txt
   echo "Test file 2" > ~/cloud-backup-test/file2.txt
   
   # Backup to your cloud storage (adjust the destination)
   ~/scripts/cloud-backup.sh backup ~/cloud-backup-test your-remote:backup-test
   ```

3. **Set up a Scheduled Backup**:

   ```bash
   # Create a systemd user service and timer
   mkdir -p ~/.config/systemd/user
   
   # Create service file
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
   ExecStart=/home/username/scripts/cloud-backup.sh backup /home/username/Documents your-remote:Documents
   ExecStart=/home/username/scripts/cloud-backup.sh backup /home/username/Projects your-remote:Projects
   
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

### CI/CD Pipeline Setup

1. **Create a Simple Flask Application**:

   ```bash
   mkdir -p ~/projects/flask-demo
   cd ~/projects/flask-demo
   
   # Create a virtual environment
   python -m venv venv
   source venv/bin/activate
   
   # Install dependencies
   pip install flask pytest gunicorn
   ```

2. **Create the Flask Application Files**:

   ```bash
   mkdir -p app/templates
   ```

   Create app/__init__.py:
   ```bash
   nano app/__init__.py
   ```

   Add the following content:
   ```python
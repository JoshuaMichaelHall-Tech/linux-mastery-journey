# Month 6: Containerization and Virtual Environments

This month focuses on containerization with Docker, managing virtual environments, and creating reproducible development setups. You'll learn to isolate development environments, manage dependencies consistently, and create efficient workflows for multi-service applications.

## Time Commitment: ~10 hours/week for 4 weeks

## Learning Objectives

By the end of this month, you should be able to:

1. Understand containerization concepts and benefits
2. Create and manage Docker containers for development
3. Build custom Docker images for your applications
4. Set up multi-container environments with Docker Compose
5. Implement development/production parity
6. Use virtual environments effectively for different languages

## Week 1: Docker Fundamentals

### Core Learning Activities

1. **Containerization Concepts** (2 hours)
   - Understand containers vs. virtual machines
   - Learn about container isolation and security
   - Study container networking basics
   - Understand the Docker architecture and components
   - Compare containerization with traditional deployment

2. **Docker Installation and Setup** (2 hours)
   - Install Docker on Arch Linux
     ```bash
     sudo pacman -S docker
     sudo systemctl enable docker
     sudo systemctl start docker
     sudo usermod -aG docker $(whoami)
     ```
   - Configure user permissions and access
   - Set up Docker daemon options in `/etc/docker/daemon.json`
   - Verify installation with `docker info` and `docker version`
   - Test with `docker run hello-world`

3. **Basic Docker Commands** (3 hours)
   - Run and manage containers:
     ```bash
     # Run a container
     docker run -it --name my-container ubuntu bash
     
     # List running containers
     docker ps
     
     # List all containers
     docker ps -a
     
     # Stop a container
     docker stop my-container
     
     # Start a stopped container
     docker start my-container
     
     # Remove a container
     docker rm my-container
     ```
   - Work with container images:
     ```bash
     # List images
     docker images
     
     # Pull an image
     docker pull python:3.11-slim
     
     # Remove an image
     docker rmi python:3.9-slim
     ```
   - Understand container lifecycle (created, running, paused, stopped, deleted)
   - Practice container resource limitations:
     ```bash
     # Limit memory and CPU
     docker run -it --memory="512m" --cpus="1.0" ubuntu bash
     ```

4. **Docker Volumes and Networking** (3 hours)
   - Create and manage volumes:
     ```bash
     # Create a volume
     docker volume create my-data
     
     # List volumes
     docker volume ls
     
     # Use a volume with a container
     docker run -it -v my-data:/data ubuntu bash
     ```
   - Understand bind mounts for development:
     ```bash
     # Mount local directory into container
     docker run -it -v $(pwd):/app python:3.11-slim bash
     ```
   - Configure basic network settings:
     ```bash
     # Create a network
     docker network create my-network
     
     # Run container on the network
     docker run -it --network my-network --name container1 ubuntu bash
     ```
   - Practice connecting containers:
     ```bash
     # Run second container and ping first container
     docker run -it --network my-network --name container2 ubuntu bash
     # Inside container2: ping container1
     ```

### Resources

- [Docker Documentation](https://docs.docker.com/)
- [ArchWiki - Docker](https://wiki.archlinux.org/title/Docker)
- [Docker Curriculum](https://docker-curriculum.com/)
- [Docker Networking Overview](https://docs.docker.com/network/)

## Week 2: Building and Managing Docker Images

### Core Learning Activities

1. **Dockerfile Basics** (3 hours)
   - Learn Dockerfile syntax and directives:
     ```dockerfile
     # Basic Dockerfile structure
     FROM python:3.11-slim
     
     WORKDIR /app
     
     COPY requirements.txt .
     RUN pip install --no-cache-dir -r requirements.txt
     
     COPY . .
     
     CMD ["python", "app.py"]
     ```
   - Understand base images and layering
   - Create efficient Dockerfiles with minimal layers
   - Implement multi-stage builds:
     ```dockerfile
     # Multi-stage build example
     FROM node:16 AS build
     WORKDIR /app
     COPY package*.json ./
     RUN npm install
     COPY . .
     RUN npm run build
     
     FROM nginx:alpine
     COPY --from=build /app/build /usr/share/nginx/html
     EXPOSE 80
     CMD ["nginx", "-g", "daemon off;"]
     ```

2. **Building Custom Images** (3 hours)
   - Build images for different languages:
     ```bash
     # Build an image
     docker build -t my-python-app:1.0 .
     
     # Build with build arguments
     docker build -t my-app:1.0 --build-arg ENV=development .
     ```
   - Optimize image size with `.dockerignore`:
     ```
     # .dockerignore example
     .git
     .env
     __pycache__
     *.pyc
     *.pyo
     *.pyd
     .Python
     env/
     venv/
     ```
   - Implement caching strategies for faster builds:
     ```dockerfile
     # Optimize caching
     COPY requirements.txt .
     RUN pip install --no-cache-dir -r requirements.txt
     
     # Copy code after dependencies (changes less frequently)
     COPY . .
     ```
   - Tag and version images:
     ```bash
     docker tag my-app:1.0 my-app:latest
     ```

3. **Docker Image Best Practices** (2 hours)
   - Implement security considerations:
     ```dockerfile
     # Create non-root user
     RUN adduser --disabled-password --gecos "" appuser
     USER appuser
     ```
   - Minimize image size:
     ```dockerfile
     # Combine commands to reduce layers
     RUN apt-get update && \
         apt-get install -y --no-install-recommends package && \
         rm -rf /var/lib/apt/lists/*
     ```
   - Set healthchecks:
     ```dockerfile
     HEALTHCHECK --interval=30s --timeout=3s \
       CMD curl -f http://localhost/ || exit 1
     ```
   - Configure proper signal handling:
     ```dockerfile
     # Use ENTRYPOINT with exec form
     ENTRYPOINT ["python", "app.py"]
     ```

4. **Docker Registry Usage** (2 hours)
   - Push images to Docker Hub:
     ```bash
     # Login to Docker Hub
     docker login
     
     # Tag with username
     docker tag my-app:1.0 username/my-app:1.0
     
     # Push image
     docker push username/my-app:1.0
     ```
   - Work with private registries:
     ```bash
     # Login to private registry
     docker login registry.example.com
     
     # Tag for private registry
     docker tag my-app:1.0 registry.example.com/my-app:1.0
     
     # Push to private registry
     docker push registry.example.com/my-app:1.0
     ```
   - Implement image signing with Docker Content Trust:
     ```bash
     # Enable content trust
     export DOCKER_CONTENT_TRUST=1
     
     # Push signed image
     docker push username/my-app:1.0
     ```
   - Manage registry authentication in configuration files

### Resources

- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Multi-Stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Docker Security](https://docs.docker.com/engine/security/)
- [Docker Hub Documentation](https://docs.docker.com/docker-hub/)

## Week 3: Docker Compose and Multi-Container Applications

### Core Learning Activities

1. **Docker Compose Basics** (3 hours)
   - Understand Docker Compose file format:
     ```yaml
     # docker-compose.yml
     version: '3.8'
     
     services:
       web:
         build: ./web
         ports:
           - "5000:5000"
         volumes:
           - ./web:/app
         environment:
           - FLASK_ENV=development
       
       db:
         image: postgres:13
         volumes:
           - postgres_data:/var/lib/postgresql/data
         environment:
           - POSTGRES_PASSWORD=mysecretpassword
           - POSTGRES_USER=myuser
           - POSTGRES_DB=mydb
     
     volumes:
       postgres_data:
     ```
   - Learn about services, networks, and volumes
   - Create basic multi-container setups
   - Run and manage Compose applications:
     ```bash
     # Start services
     docker-compose up
     
     # Start in detached mode
     docker-compose up -d
     
     # Stop services
     docker-compose down
     
     # Stop and remove volumes
     docker-compose down -v
     ```

2. **Development Environments with Compose** (3 hours)
   - Set up local development stacks:
     ```yaml
     # development.docker-compose.yml
     version: '3.8'
     
     services:
       web:
         build: 
           context: ./web
           dockerfile: Dockerfile.dev
         ports:
           - "5000:5000"
         volumes:
           - ./web:/app
         environment:
           - FLASK_ENV=development
           - DEBUG=True
         command: flask run --host=0.0.0.0 --reload
     ```
   - Configure environment variables:
     ```yaml
     # Using .env file
     services:
       web:
         env_file:
           - .env.development
     ```
   - Implement volume mounting for code:
     ```yaml
     volumes:
       - ./web:/app  # Code changes reflect instantly
       - /app/node_modules  # Don't override node_modules
     ```
   - Enable live reloading for development

3. **Managing Application Dependencies** (2 hours)
   - Connect multiple services:
     ```yaml
     services:
       web:
         depends_on:
           - db
           - redis
     ```
   - Configure service dependencies with health checks:
     ```yaml
     services:
       db:
         healthcheck:
           test: ["CMD", "pg_isready", "-U", "postgres"]
           interval: 5s
           timeout: 5s
           retries: 5
       
       web:
         depends_on:
           db:
             condition: service_healthy
     ```
   - Set up shared network communication:
     ```yaml
     services:
       web:
         networks:
           - frontend
           - backend
       
       db:
         networks:
           - backend
     
     networks:
       frontend:
       backend:
     ```
   - Manage service discovery using container names

4. **Data Persistence Strategies** (2 hours)
   - Configure database containers:
     ```yaml
     services:
       db:
         image: postgres:13
         volumes:
           - postgres_data:/var/lib/postgresql/data
           - ./init-scripts:/docker-entrypoint-initdb.d
     ```
   - Implement data volumes for persistence:
     ```yaml
     volumes:
       postgres_data:
         driver: local
     ```
   - Set up backup strategies:
     ```yaml
     services:
       backup:
         image: postgres:13
         volumes:
           - postgres_data:/source_data:ro
           - ./backups:/backups
         command: bash -c "pg_dump -h db -U postgres mydb > /backups/backup-$$(date +%Y-%m-%d-%H-%M).sql"
         depends_on:
           - db
     ```
   - Handle persistent data across rebuilds and container restarts

### Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Compose File Reference](https://docs.docker.com/compose/compose-file/)
- [Docker Volumes](https://docs.docker.com/storage/volumes/)
- [Example Compose Applications](https://github.com/docker/awesome-compose)

## Week 4: Language-Specific Virtual Environments and Workflow Integration

### Core Learning Activities

1. **Python Virtual Environments in Docker** (2 hours)
   - Create Python development containers:
     ```dockerfile
     # Python development Dockerfile
     FROM python:3.11-slim
     
     RUN pip install --no-cache-dir poetry
     
     WORKDIR /app
     
     COPY pyproject.toml poetry.lock* ./
     RUN poetry config virtualenvs.create false && \
         poetry install --no-interaction --no-ansi
     
     COPY . .
     
     CMD ["python", "app.py"]
     ```
   - Configure Poetry/Pipenv with Docker:
     ```yaml
     # docker-compose.yml for Python project
     services:
       app:
         build: .
         volumes:
           - .:/app
         environment:
           - PYTHONPATH=/app
           - POETRY_VIRTUALENVS_CREATE=false
     ```
   - Set up debugger integration:
     ```yaml
     # For remote debugging
     services:
       app:
         ports:
           - "5678:5678"  # For debugpy
         command: python -m debugpy --listen 0.0.0.0:5678 app.py
     ```
   - Implement testing in containers:
     ```bash
     # Run tests in container
     docker-compose run --rm app pytest
     ```

2. **Node.js Development Containers** (2 hours)
   - Set up Node.js containers:
     ```dockerfile
     # Node.js development Dockerfile
     FROM node:18
     
     WORKDIR /app
     
     COPY package*.json ./
     RUN npm install
     
     COPY . .
     
     CMD ["npm", "start"]
     ```
   - Configure npm/yarn caching:
     ```yaml
     # docker-compose.yml
     services:
       app:
         volumes:
           - .:/app
           - node_modules:/app/node_modules
     
     volumes:
       node_modules:
     ```
   - Implement hot reloading:
     ```yaml
     # For React development
     services:
       app:
         environment:
           - CHOKIDAR_USEPOLLING=true
           - WDS_SOCKET_PORT=0
     ```
   - Optimize for frontend development with volume mounts

3. **Database Containers** (3 hours)
   - Set up PostgreSQL containers:
     ```yaml
     services:
       db:
         image: postgres:13
         environment:
           - POSTGRES_PASSWORD=password
           - POSTGRES_USER=user
           - POSTGRES_DB=mydb
         volumes:
           - postgres_data:/var/lib/postgresql/data
           - ./init-scripts:/docker-entrypoint-initdb.d
         ports:
           - "5432:5432"
     ```
   - Configure MongoDB containers:
     ```yaml
     services:
       mongo:
         image: mongo:5
         environment:
           - MONGO_INITDB_ROOT_USERNAME=root
           - MONGO_INITDB_ROOT_PASSWORD=password
         volumes:
           - mongo_data:/data/db
         ports:
           - "27017:27017"
     ```
   - Implement backup and restore procedures:
     ```bash
     # Backup PostgreSQL
     docker exec -t container_name pg_dump -U username dbname > backup.sql
     
     # Restore PostgreSQL
     docker exec -i container_name psql -U username dbname < backup.sql
     ```
   - Set up database admin tools:
     ```yaml
     services:
       pgadmin:
         image: dpage/pgadmin4
         environment:
           - PGADMIN_DEFAULT_EMAIL=admin@example.com
           - PGADMIN_DEFAULT_PASSWORD=password
         ports:
           - "5050:80"
         depends_on:
           - db
     ```

4. **Development Workflow Integration** (3 hours)
   - Connect editor with containers (VS Code Remote Containers)
   - Set up debugging inside containers:
     ```json
     // .vscode/launch.json
     {
       "version": "0.2.0",
       "configurations": [
         {
           "name": "Python: Remote Attach",
           "type": "python",
           "request": "attach",
           "connect": {
             "host": "localhost",
             "port": 5678
           },
           "pathMappings": [
             {
               "localRoot": "${workspaceFolder}",
               "remoteRoot": "/app"
             }
           ]
         }
       ]
     }
     ```
   - Configure container-based testing and CI:
     ```yaml
     # .github/workflows/test.yml
     jobs:
       test:
         runs-on: ubuntu-latest
         steps:
           - uses: actions/checkout@v3
           - name: Run tests in container
             run: docker-compose -f docker-compose.test.yml up --exit-code-from app
     ```
   - Streamline local-to-container workflows with scripts:
     ```bash
     #!/bin/bash
     # dev.sh
     if [ "$1" = "up" ]; then
       docker-compose up -d
     elif [ "$1" = "down" ]; then
       docker-compose down
     elif [ "$1" = "test" ]; then
       docker-compose run --rm app pytest
     fi
     ```

### Resources

- [VSCode Remote Containers](https://code.visualstudio.com/docs/remote/containers)
- [Python Docker Development](https://www.docker.com/blog/containerized-python-development-part-1/)
- [Node.js Docker Development](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/)
- [PostgreSQL Docker Image](https://hub.docker.com/_/postgres)

## Projects and Exercises

1. **Development Environment Container**
   - Create a complete development environment container with your preferred tools
   - Include language-specific tools (Python, JS, etc.), Neovim, and Git
   - Configure volume mounting for projects
   - Add persistent configuration
   - Document setup with a README

2. **Multi-Service Web Application**
   - Create a web application with frontend, backend, and database
   - Implement Docker Compose for the complete stack
   - Configure development-specific optimizations
   - Add proper service dependencies
   - Implement data persistence

3. **Language-Specific Development Templates**
   - Create Dockerfile templates for Python, Node.js, and another language
   - Implement development/production configuration variants
   - Add proper documentation
   - Create setup scripts for initialization

4. **Containerized CI/CD Pipeline**
   - Set up a testing pipeline using Docker
   - Implement automated testing with GitHub Actions
   - Configure build and deployment steps
   - Create proper test isolation
   - Simulate different environments (dev/test/prod)

## Assessment

You should now be able to:

1. Create and manage Docker containers effectively
2. Build optimized Docker images for different applications
3. Configure multi-container environments with Docker Compose
4. Set up language-specific development containers
5. Implement proper volume and networking configurations
6. Create reproducible development environments

## Next Steps

In [Month 7: System Maintenance and Performance Tuning](month-07-maintenance.md), we'll focus on:
- System monitoring and resource optimization
- Implementing backup strategies
- Managing logs and troubleshooting
- Automating maintenance tasks
- Configuring long-term system health

## Acknowledgements

This learning guide was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Learning path structure and organization
- Resource recommendations
- Project suggestions

Claude was used as a development aid while all final implementation decisions and verification were performed by Joshua Michael Hall.

## Disclaimer

This guide is provided "as is", without warranty of any kind. Follow all instructions carefully and always make backups before making system changes.
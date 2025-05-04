# Month 6: Containerization and Virtual Environments - Exercises

This document contains practical exercises to accompany the Month 6 learning guide. Complete these exercises to solidify your understanding of Docker, containerization, multi-container applications, and development workflows with containers.

## Exercise 1: Docker Fundamentals

This exercise focuses on understanding container basics, running containers, and exploring Docker networking and volumes.

### Docker Installation and Setup

1. **Install and configure Docker**:
   ```bash
   # Install Docker
   sudo pacman -S docker
   
   # Start and enable Docker service
   sudo systemctl start docker
   sudo systemctl enable docker
   
   # Add your user to the docker group (to use Docker without sudo)
   sudo usermod -aG docker $(whoami)
   
   # Log out and log back in for the group changes to take effect
   # Or use this command to apply changes in current shell
   newgrp docker
   
   # Test Docker installation
   docker run hello-world
   ```

2. **Verify Docker installation and explore system**:
   ```bash
   # Check Docker version
   docker --version
   
   # Get more detailed Docker info
   docker info
   
   # Create a directory for Docker exercises
   mkdir -p ~/docker-exercises
   cd ~/docker-exercises
   ```

### Container Basics

1. **Run your first interactive container**:
   ```bash
   # Run an interactive Ubuntu container
   docker run -it --name my-ubuntu ubuntu:latest bash
   
   # Inside the container, run some commands
   cat /etc/os-release
   ls -la
   apt update
   apt install -y neofetch
   neofetch
   
   # Exit the container
   exit
   ```

2. **Container lifecycle management**:
   ```bash
   # List all containers (including stopped ones)
   docker ps -a
   
   # Start the stopped container
   docker start my-ubuntu
   
   # Attach to the running container
   docker attach my-ubuntu
   
   # Exit but keep container running (press Ctrl+P then Ctrl+Q)
   
   # Execute a command in a running container
   docker exec my-ubuntu cat /etc/hostname
   
   # Stop the container
   docker stop my-ubuntu
   
   # Remove the container
   docker rm my-ubuntu
   ```

3. **Working with container images**:
   ```bash
   # List available images
   docker images
   
   # Pull several images to explore
   docker pull nginx:alpine
   docker pull python:3.11-slim
   docker pull postgres:14-alpine
   
   # Inspect an image's details
   docker image inspect nginx:alpine
   ```

### Docker Networking

1. **Explore default networks**:
   ```bash
   # List Docker networks
   docker network ls
   
   # Inspect the bridge network
   docker network inspect bridge
   ```

2. **Create and use custom networks**:
   ```bash
   # Create a custom bridge network
   docker network create my-network
   
   # Run containers on the custom network
   docker run -d --name web --network my-network nginx:alpine
   docker run -it --name client --network my-network alpine sh
   
   # Inside the client container, ping the web container by name
   ping web
   wget -O- http://web
   
   # Exit the container
   exit
   
   # Clean up
   docker stop web client
   docker rm web client
   docker network rm my-network
   ```

### Docker Volumes

1. **Named volumes**:
   ```bash
   # Create a named volume
   docker volume create my-data
   
   # Run a container with the volume mounted
   docker run -it --name vol-test -v my-data:/data alpine sh
   
   # Inside the container, create a file in the volume
   echo "Hello from Docker volume" > /data/test.txt
   ls -la /data
   exit
   
   # Run another container with the same volume
   docker run -it --name vol-test2 -v my-data:/app-data alpine sh
   
   # Check that the file exists
   cat /app-data/test.txt
   exit
   
   # Clean up
   docker rm vol-test vol-test2
   ```

2. **Bind mounts**:
   ```bash
   # Create a local directory with a test file
   mkdir -p ~/docker-exercises/local-data
   echo "Local file content" > ~/docker-exercises/local-data/local-file.txt
   
   # Mount the local directory in a container
   docker run -it --name bind-test -v ~/docker-exercises/local-data:/container-data alpine sh
   
   # Inside the container, verify the file exists and create a new file
   ls -la /container-data
   cat /container-data/local-file.txt
   echo "Created from container" > /container-data/container-file.txt
   exit
   
   # Verify the container-created file exists on the host
   ls -la ~/docker-exercises/local-data
   cat ~/docker-exercises/local-data/container-file.txt
   
   # Clean up
   docker rm bind-test
   ```

### Storage and Resource Limitations

1. **Limit container resources**:
   ```bash
   # Run a container with memory and CPU limits
   docker run -d --name limited-nginx \
     --memory="256m" \
     --cpus="0.5" \
     -p 8080:80 \
     nginx:alpine
   
   # Check container's resource usage
   docker stats limited-nginx --no-stream
   
   # Clean up
   docker stop limited-nginx
   docker rm limited-nginx
   ```

## Exercise 2: Building and Managing Docker Images

This exercise focuses on creating custom Docker images, optimizing Dockerfiles, and working with image registries.

### Basic Dockerfile

1. **Create your first Dockerfile**:
   ```bash
   # Create a directory for the Dockerfile
   mkdir -p ~/docker-exercises/basic-image
   cd ~/docker-exercises/basic-image
   
   # Create a simple Python application
   cat > app.py << EOF
   import socket
   import os
   
   hostname = socket.gethostname()
   
   print(f"Hello from container: {hostname}")
   print(f"Environment: {os.environ.get('APP_ENV', 'development')}")
   EOF
   
   # Create a Dockerfile
   cat > Dockerfile << EOF
   FROM python:3.11-slim
   
   WORKDIR /app
   
   COPY app.py .
   
   ENV APP_ENV=production
   
   CMD ["python", "app.py"]
   EOF
   ```

2. **Build and run the image**:
   ```bash
   # Build the image
   docker build -t my-python-app:1.0 .
   
   # Check that the image was created
   docker images
   
   # Run a container from the image
   docker run --name python-test my-python-app:1.0
   
   # Override the environment variable
   docker run -e APP_ENV=staging my-python-app:1.0
   
   # Clean up
   docker rm python-test
   ```

### Optimized Dockerfile

1. **Create an optimized Python application Dockerfile**:
   ```bash
   # Create a directory for the optimized Dockerfile
   mkdir -p ~/docker-exercises/optimized-image
   cd ~/docker-exercises/optimized-image
   
   # Create requirements.txt
   cat > requirements.txt << EOF
   flask==2.2.2
   requests==2.28.1
   EOF
   
   # Create a simple Flask application
   cat > app.py << EOF
   from flask import Flask, jsonify
   import socket
   
   app = Flask(__name__)
   
   @app.route('/')
   def hello():
       hostname = socket.gethostname()
       return jsonify({
           "message": "Hello from Flask!",
           "hostname": hostname
       })
   
   if __name__ == '__main__':
       app.run(host='0.0.0.0', port=5000)
   EOF
   
   # Create .dockerignore
   cat > .dockerignore << EOF
   __pycache__
   *.pyc
   *.pyo
   .git
   .env
   .venv
   venv/
   *.md
   EOF
   
   # Create optimized Dockerfile
   cat > Dockerfile << EOF
   FROM python:3.11-slim
   
   WORKDIR /app
   
   # Install dependencies first (better layer caching)
   COPY requirements.txt .
   RUN pip install --no-cache-dir -r requirements.txt
   
   # Copy application code
   COPY . .
   
   # Create non-root user for security
   RUN adduser --disabled-password --gecos "" appuser && \
       chown -R appuser:appuser /app
   
   USER appuser
   
   # Health check
   HEALTHCHECK --interval=30s --timeout=3s \
     CMD curl -f http://localhost:5000/ || exit 1
   
   # Expose port
   EXPOSE 5000
   
   # Use exec form of CMD
   CMD ["python", "app.py"]
   EOF
   ```

2. **Build and run the optimized image**:
   ```bash
   # Build the image
   docker build -t flask-app:1.0 .
   
   # Run the container
   docker run -d --name flask-container -p 5000:5000 flask-app:1.0
   
   # Test the container
   curl http://localhost:5000
   
   # Check container health
   docker inspect --format '{{.State.Health.Status}}' flask-container
   
   # Clean up
   docker stop flask-container
   docker rm flask-container
   ```

### Multi-Stage Build

1. **Create a multi-stage build for a Node.js application**:
   ```bash
   # Create a directory for the multi-stage build
   mkdir -p ~/docker-exercises/multi-stage/src
   cd ~/docker-exercises/multi-stage
   
   # Create package.json
   cat > package.json << EOF
   {
     "name": "multi-stage-demo",
     "version": "1.0.0",
     "description": "Demo for multi-stage Docker builds",
     "main": "index.js",
     "scripts": {
       "build": "echo 'Building application...' && mkdir -p dist && cp src/index.js dist/",
       "start": "node dist/index.js"
     }
   }
   EOF
   
   # Create source file
   cat > src/index.js << EOF
   console.log('Hello from multi-stage build!');
   console.log('Current date and time:', new Date().toISOString());
   EOF
   
   # Create multi-stage Dockerfile
   cat > Dockerfile << EOF
   # Build stage
   FROM node:18 AS build
   
   WORKDIR /app
   
   COPY package*.json ./
   RUN npm install
   
   COPY . .
   RUN npm run build
   
   # Runtime stage
   FROM node:18-alpine
   
   WORKDIR /app
   
   # Copy only what's needed from the build stage
   COPY --from=build /app/dist ./dist
   COPY --from=build /app/package*.json ./
   
   # Install only production dependencies
   RUN npm install --only=production
   
   USER node
   
   CMD ["npm", "start"]
   EOF
   ```

2. **Build and run the multi-stage image**:
   ```bash
   # Build the image
   docker build -t multi-stage-app:1.0 .
   
   # Check image size
   docker images multi-stage-app:1.0
   
   # Run the container
   docker run --name multi-stage-container multi-stage-app:1.0
   
   # Clean up
   docker rm multi-stage-container
   ```

### Working with Docker Hub

1. **Create a Docker Hub account** (if you don't already have one):
   - Go to https://hub.docker.com/ and sign up

2. **Tag and push an image to Docker Hub**:
   ```bash
   # Replace 'yourusername' with your Docker Hub username
   docker tag flask-app:1.0 yourusername/flask-app:1.0
   
   # Login to Docker Hub
   docker login
   
   # Push the image
   docker push yourusername/flask-app:1.0
   
   # Log out when done
   docker logout
   ```

3. **Pull your image from Docker Hub**:
   ```bash
   # Remove local image first
   docker rmi yourusername/flask-app:1.0
   
   # Pull the image from Docker Hub
   docker pull yourusername/flask-app:1.0
   
   # Run the container from the pulled image
   docker run -d --name hub-container -p 5001:5000 yourusername/flask-app:1.0
   
   # Test the container
   curl http://localhost:5001
   
   # Clean up
   docker stop hub-container
   docker rm hub-container
   ```

## Exercise 3: Docker Compose and Multi-Container Applications

This exercise focuses on creating and managing multi-container applications with Docker Compose.

### Basic Docker Compose

1. **Create a simple web/database setup**:
   ```bash
   # Create a directory for the Docker Compose project
   mkdir -p ~/docker-exercises/basic-compose
   cd ~/docker-exercises/basic-compose
   
   # Create docker-compose.yml
   cat > docker-compose.yml << EOF
   version: '3.8'
   
   services:
     web:
       image: nginx:alpine
       ports:
         - "8080:80"
       volumes:
         - ./web-content:/usr/share/nginx/html
       depends_on:
         - db
   
     db:
       image: postgres:14-alpine
       environment:
         - POSTGRES_USER=myuser
         - POSTGRES_PASSWORD=mypassword
         - POSTGRES_DB=mydb
       volumes:
         - postgres_data:/var/lib/postgresql/data
   
   volumes:
     postgres_data:
   EOF
   
   # Create a custom index.html file
   mkdir -p web-content
   cat > web-content/index.html << EOF
   <!DOCTYPE html>
   <html>
   <head>
     <title>Docker Compose Demo</title>
     <style>
       body {
         font-family: Arial, sans-serif;
         margin: 40px;
         background-color: #f5f5f5;
       }
       .container {
         background-color: white;
         padding: 20px;
         border-radius: 5px;
         box-shadow: 0 2px 5px rgba(0,0,0,0.1);
       }
       h1 {
         color: #333;
       }
     </style>
   </head>
   <body>
     <div class="container">
       <h1>Docker Compose Demo</h1>
       <p>This page is being served by Nginx in a Docker container.</p>
       <p>There's also a PostgreSQL database container running in the background.</p>
     </div>
   </body>
   </html>
   EOF
   ```

2. **Run and manage the Docker Compose application**:
   ```bash
   # Start the Docker Compose application
   docker-compose up -d
   
   # Check that the containers are running
   docker-compose ps
   
   # View container logs
   docker-compose logs
   
   # Test the web service
   curl http://localhost:8080
   
   # Connect to the PostgreSQL database
   docker-compose exec db psql -U myuser -d mydb
   
   # Inside PostgreSQL, run some commands
   CREATE TABLE test (id SERIAL PRIMARY KEY, name VARCHAR(50));
   INSERT INTO test (name) VALUES ('Docker Compose');
   SELECT * FROM test;
   \q
   
   # Stop the application but keep volumes
   docker-compose down
   
   # Start it again (data should persist)
   docker-compose up -d
   
   # Verify data still exists
   docker-compose exec db psql -U myuser -d mydb -c "SELECT * FROM test;"
   
   # Clean up completely (removes volumes too)
   docker-compose down -v
   ```

### Development Environment with Docker Compose

1. **Create a development environment for a Python Flask application**:
   ```bash
   # Create a directory for the development environment
   mkdir -p ~/docker-exercises/flask-dev
   cd ~/docker-exercises/flask-dev
   
   # Create a simple Flask application
   mkdir -p app
   
   cat > app/requirements.txt << EOF
   flask==2.2.2
   psycopg2-binary==2.9.5
   python-dotenv==0.21.0
   EOF
   
   cat > app/app.py << EOF
   import os
   import socket
   from flask import Flask, jsonify
   import psycopg2
   from dotenv import load_dotenv
   
   load_dotenv()
   
   app = Flask(__name__)
   
   @app.route('/')
   def hello():
       hostname = socket.gethostname()
       return jsonify({
           "message": "Hello from Flask Development Environment!",
           "hostname": hostname,
           "environment": os.environ.get("FLASK_ENV", "development")
       })
   
   @app.route('/db')
   def db_check():
       try:
           conn = psycopg2.connect(
               host=os.environ.get("DB_HOST", "db"),
               database=os.environ.get("DB_NAME", "devdb"),
               user=os.environ.get("DB_USER", "devuser"),
               password=os.environ.get("DB_PASSWORD", "devpassword")
           )
           conn.close()
           return jsonify({"db_connection": "successful"})
       except Exception as e:
           return jsonify({"db_connection": "failed", "error": str(e)})
   
   if __name__ == '__main__':
       app.run(host='0.0.0.0', port=5000, debug=True)
   EOF
   
   # Create Dockerfile for development
   cat > app/Dockerfile.dev << EOF
   FROM python:3.11-slim
   
   WORKDIR /app
   
   # Install development tools
   RUN apt-get update && apt-get install -y \\
       curl \\
       gcc \\
       && rm -rf /var/lib/apt/lists/*
   
   # Install dependencies
   COPY requirements.txt .
   RUN pip install --no-cache-dir -r requirements.txt
   
   # Install development dependencies
   RUN pip install --no-cache-dir debugpy
   
   # Copy application code
   COPY . .
   
   # Keep container running
   CMD ["python", "app.py"]
   EOF
   
   # Create .env file for development
   cat > .env.dev << EOF
   FLASK_ENV=development
   DB_HOST=db
   DB_NAME=devdb
   DB_USER=devuser
   DB_PASSWORD=devpassword
   EOF
   
   # Create docker-compose.yml for development
   cat > docker-compose.yml << EOF
   version: '3.8'
   
   services:
     web:
       build:
         context: ./app
         dockerfile: Dockerfile.dev
       ports:
         - "5000:5000"
         - "5678:5678"  # For remote debugging
       volumes:
         - ./app:/app
       env_file:
         - .env.dev
       environment:
         - FLASK_DEBUG=1
       depends_on:
         db:
           condition: service_healthy
       command: >
         sh -c "python -m debugpy --listen 0.0.0.0:5678 app.py"
   
     db:
       image: postgres:14-alpine
       environment:
         - POSTGRES_USER=devuser
         - POSTGRES_PASSWORD=devpassword
         - POSTGRES_DB=devdb
       volumes:
         - dev_postgres_data:/var/lib/postgresql/data
       healthcheck:
         test: ["CMD-SHELL", "pg_isready -U devuser -d devdb"]
         interval: 5s
         timeout: 5s
         retries: 5
   
   volumes:
     dev_postgres_data:
   EOF
   ```

2. **Run and test the development environment**:
   ```bash
   # Start the development environment
   docker-compose up -d
   
   # Check that the containers are running
   docker-compose ps
   
   # Test the application
   curl http://localhost:5000
   curl http://localhost:5000/db
   
   # Make a modification to the code (the change will be reflected instantly)
   sed -i 's/Hello from Flask Development Environment!/Hello from HOT RELOADED Flask App!/' app/app.py
   
   # Test to see the change
   curl http://localhost:5000
   
   # Clean up
   docker-compose down -v
   ```

### Multi-Container Application with Custom Networks

1. **Create a more complex application with frontend, backend, and database**:
   ```bash
   # Create a directory for the multi-container application
   mkdir -p ~/docker-exercises/multi-app/{frontend,backend}
   cd ~/docker-exercises/multi-app
   
   # Create backend application
   cat > backend/requirements.txt << EOF
   flask==2.2.2
   flask-cors==3.0.10
   redis==4.3.4
   EOF
   
   cat > backend/app.py << EOF
   from flask import Flask, jsonify
   from flask_cors import CORS
   import redis
   import socket
   import os
   
   app = Flask(__name__)
   CORS(app)
   
   redis_client = redis.Redis(host=os.environ.get('REDIS_HOST', 'redis'), port=6379)
   
   @app.route('/api/info')
   def info():
       # Increment view counter
       views = redis_client.incr('views')
       
       return jsonify({
           "service": "backend-api",
           "hostname": socket.gethostname(),
           "views": views
       })
   
   if __name__ == '__main__':
       app.run(host='0.0.0.0', port=5000)
   EOF
   
   cat > backend/Dockerfile << EOF
   FROM python:3.11-slim
   
   WORKDIR /app
   
   COPY requirements.txt .
   RUN pip install --no-cache-dir -r requirements.txt
   
   COPY . .
   
   CMD ["python", "app.py"]
   EOF
   
   # Create frontend application
   cat > frontend/index.html << EOF
   <!DOCTYPE html>
   <html>
   <head>
     <title>Multi-Container Demo</title>
     <style>
       body {
         font-family: Arial, sans-serif;
         margin: 40px;
         background-color: #f5f5f5;
       }
       .container {
         background-color: white;
         padding: 20px;
         border-radius: 5px;
         box-shadow: 0 2px 5px rgba(0,0,0,0.1);
       }
       #info {
         margin-top: 20px;
         padding: 15px;
         background-color: #f0f0f0;
         border-radius: 5px;
       }
       button {
         padding: 8px 16px;
         background-color: #4CAF50;
         color: white;
         border: none;
         border-radius: 4px;
         cursor: pointer;
       }
     </style>
   </head>
   <body>
     <div class="container">
       <h1>Multi-Container Application</h1>
       <p>This is the frontend container that communicates with a separate backend API container.</p>
       <button id="fetchButton">Fetch Backend Info</button>
       <div id="info">Click the button to fetch information from the backend.</div>
     </div>
     
     <script>
       document.getElementById('fetchButton').addEventListener('click', function() {
         fetch('http://localhost:5000/api/info')
           .then(response => response.json())
           .then(data => {
             document.getElementById('info').innerHTML = 
               '<strong>Service:</strong> ' + data.service + '<br>' +
               '<strong>Hostname:</strong> ' + data.hostname + '<br>' +
               '<strong>Views:</strong> ' + data.views;
           })
           .catch(error => {
             document.getElementById('info').innerHTML = 'Error: ' + error.message;
           });
       });
     </script>
   </body>
   </html>
   EOF
   
   cat > frontend/Dockerfile << EOF
   FROM nginx:alpine
   
   COPY index.html /usr/share/nginx/html/
   EOF
   
   # Create docker-compose.yml with custom networks
   cat > docker-compose.yml << EOF
   version: '3.8'
   
   services:
     frontend:
       build: ./frontend
       ports:
         - "8080:80"
       networks:
         - frontend-network
   
     backend:
       build: ./backend
       ports:
         - "5000:5000"
       networks:
         - frontend-network
         - backend-network
       depends_on:
         - redis
       environment:
         - REDIS_HOST=redis
   
     redis:
       image: redis:alpine
       networks:
         - backend-network
       volumes:
         - redis_data:/data
   
   networks:
     frontend-network:
     backend-network:
   
   volumes:
     redis_data:
   EOF
   ```

2. **Run and test the multi-container application**:
   ```bash
   # Start the multi-container application
   docker-compose up -d
   
   # Check that the containers are running
   docker-compose ps
   
   # Test the Redis connection
   docker-compose exec redis redis-cli ping
   
   # Open the application in a web browser: http://localhost:8080
   # If you don't have a browser, you can test with curl:
   curl http://localhost:8080
   
   # Test the backend API
   curl http://localhost:5000/api/info
   
   # Clean up
   docker-compose down -v
   ```

### Testing and Scaling

1. **Create a setup with load balancing**:
   ```bash
   # Create a directory for the scalable application
   mkdir -p ~/docker-exercises/scaling
   cd ~/docker-exercises/scaling
   
   # Create a simple web service that reports its container ID
   mkdir -p web-service
   
   cat > web-service/app.py << EOF
   from flask import Flask
   import socket
   import os
   
   app = Flask(__name__)
   
   @app.route('/')
   def hello():
       hostname = socket.gethostname()
       return f"<h1>Hello from {hostname}</h1><p>This is service instance {os.environ.get('SERVICE_INSTANCE', 'unknown')}</p>"
   
   if __name__ == '__main__':
       app.run(host='0.0.0.0', port=5000)
   EOF
   
   cat > web-service/requirements.txt << EOF
   flask==2.2.2
   EOF
   
   cat > web-service/Dockerfile << EOF
   FROM python:3.11-slim
   
   WORKDIR /app
   
   COPY requirements.txt .
   RUN pip install --no-cache-dir -r requirements.txt
   
   COPY . .
   
   CMD ["python", "app.py"]
   EOF
   
   # Create docker-compose.yml for scaling
   cat > docker-compose.yml << EOF
   version: '3.8'
   
   services:
     web:
       build: ./web-service
       environment:
         - SERVICE_INSTANCE=\${HOSTNAME}
       deploy:
         replicas: 3
       networks:
         - web-network
   
     nginx:
       image: nginx:alpine
       volumes:
         - ./nginx.conf:/etc/nginx/conf.d/default.conf
       ports:
         - "8080:80"
       depends_on:
         - web
       networks:
         - web-network
   
   networks:
     web-network:
   EOF
   
   # Create NGINX load balancer configuration
   cat > nginx.conf << EOF
   upstream web-service {
       server web:5000;
   }
   
   server {
       listen 80;
       
       location / {
           proxy_pass http://web-service;
           proxy_set_header Host \$host;
           proxy_set_header X-Real-IP \$remote_addr;
       }
   }
   EOF
   ```

2. **Run and test the scalable application**:
   ```bash
   # Start the application
   docker-compose up -d
   
   # Check that the containers are running (should see 3 web containers)
   docker-compose ps
   
   # Test the load balancer (run multiple times to see different backends)
   for i in {1..10}; do curl -s http://localhost:8080 | grep "Hello from"; done
   
   # Scale the web service up to 5 instances
   docker-compose up -d --scale web=5
   
   # Check the containers again
   docker-compose ps
   
   # Test again to see more instances
   for i in {1..10}; do curl -s http://localhost:8080 | grep "Hello from"; done
   
   # Scale down to 2 instances
   docker-compose up -d --scale web=2
   
   # Clean up
   docker-compose down
   ```

## Exercise 4: Language-Specific Virtual Environments and Workflow Integration

This exercise focuses on setting up language-specific development environments and integrating your editor with containerized workflows.

### Python Development Environment

1. **Create a Python development environment with Poetry**:
   ```bash
   # Create a directory for the Python development environment
   mkdir -p ~/docker-exercises/python-dev
   cd ~/docker-exercises/python-dev
   
   # Initialize Poetry project
   cat > pyproject.toml << EOF
   [tool.poetry]
   name = "python-dev-project"
   version = "0.1.0"
   description = "Python development environment in Docker"
   authors = ["Your Name <your.email@example.com>"]
   
   [tool.poetry.dependencies]
   python = "^3.11"
   flask = "^2.2.2"
   requests = "^2.28.1"
   
   [tool.poetry.dev-dependencies]
   pytest = "^7.2.0"
   black = "^22.10.0"
   isort = "^5.10.1"
   flake8 = "^6.0.0"
   
   [build-system]
   requires = ["poetry-core>=1.0.0"]
   build-backend = "poetry.core.masonry.api"
   EOF
   
   # Create a simple Flask application with tests
   mkdir -p app tests
   
   cat > app/__init__.py << EOF
   from flask import Flask
   
   app = Flask(__name__)
   
   from app import routes
   EOF
   
   cat > app/routes.py << EOF
   from app import app
   from flask import jsonify
   
   
   @app.route('/')
   def index():
       return jsonify({"message": "Hello from Python Development Environment"})
   
   
   @app.route('/add/<int:a>/<int:b>')
   def add(a, b):
       return jsonify({"result": a + b})
   EOF
   
   cat > app/main.py << EOF
   from app import app
   
   if __name__ == '__main__':
       app.run(host='0.0.0.0', port=5000, debug=True)
   EOF
   
   cat > tests/test_routes.py << EOF
   import json
   import pytest
   from app import app
   
   
   @pytest.fixture
   def client():
       app.testing = True
       with app.test_client() as client:
           yield client
   
   
   def test_index(client):
       response = client.get('/')
       data = json.loads(response.data)
       assert response.status_code == 200
       assert data['message'] == 'Hello from Python Development Environment'
   
   
   def test_add(client):
       response = client.get('/add/2/3')
       data = json.loads(response.data)
       assert response.status_code == 200
       assert data['result'] == 5
   EOF
   
   # Create Dockerfile for Python development
   cat > Dockerfile << EOF
   FROM python:3.11-slim
   
   WORKDIR /app
   
   # Install system dependencies
   RUN apt-get update && apt-get install -y \\
       curl \\
       make \\
       && rm -rf /var/lib/apt/lists/*
   
   # Install Poetry
   RUN curl -sSL https://install.python-poetry.org | python3 -
   ENV PATH="/root/.local/bin:${PATH}"
   
   # Copy poetry configuration
   COPY pyproject.toml ./
   
   # Install dependencies
   RUN poetry config virtualenvs.create false && \\
       poetry install --no-interaction --no-ansi
   
   # Copy application code
   COPY . .
   
   # Set up debugging
   RUN pip install debugpy
   
   # Command to run app
   CMD ["python", "app/main.py"]
   EOF
   
   # Create docker-compose.yml
   cat > docker-compose.yml << EOF
   version: '3.8'
   
   services:
     app:
       build: .
       ports:
         - "5000:5000"
         - "5678:5678"  # For debugging
       volumes:
         - .:/app
       environment:
         - FLASK_DEBUG=1
       command: python -m debugpy --listen 0.0.0.0:5678 app/main.py
   EOF
   
   # Create Makefile for common commands
   cat > Makefile << EOF
   .PHONY: build up down test lint format shell
   
   build:
       docker-compose build
   
   up:
       docker-compose up
   
   down:
       docker-compose down
   
   test:
       docker-compose run --rm app pytest
   
   lint:
       docker-compose run --rm app flake8 app/
   
   format:
       docker-compose run --rm app black app/
       docker-compose run --rm app isort app/
   
   shell:
       docker-compose run --rm app /bin/bash
   EOF
   ```

2. **Use the Python development environment**:
   ```bash
   # Build the development environment
   make build
   
   # Start the application
   make up
   
   # In another terminal, test the API
   curl http://localhost:5000
   curl http://localhost:5000/add/10/20
   
   # Run tests
   make test
   
   # Format code
   make format
   
   # Run linting
   make lint
   
   # Get a shell in the container
   make shell
   
   # Clean up
   make down
   ```

### Node.js Development Environment

1. **Create a Node.js development environment**:
   ```bash
   # Create a directory for the Node.js development environment
   mkdir -p ~/docker-exercises/node-dev
   cd ~/docker-exercises/node-dev
   
   # Create package.json
   cat > package.json << EOF
   {
     "name": "node-dev-project",
     "version": "1.0.0",
     "description": "Node.js development environment in Docker",
     "main": "src/index.js",
     "scripts": {
       "start": "nodemon src/index.js",
       "test": "jest",
       "lint": "eslint src/**/*.js"
     },
     "dependencies": {
       "express": "^4.18.2"
     },
     "devDependencies": {
       "eslint": "^8.28.0",
       "jest": "^29.3.1",
       "nodemon": "^2.0.20",
       "supertest": "^6.3.1"
     }
   }
   EOF
   
   # Create .eslintrc.json
   cat > .eslintrc.json << EOF
   {
     "env": {
       "node": true,
       "jest": true,
       "es6": true
     },
     "extends": "eslint:recommended",
     "parserOptions": {
       "ecmaVersion": 2020
     },
     "rules": {
       "indent": ["error", 2],
       "linebreak-style": ["error", "unix"],
       "quotes": ["error", "single"],
       "semi": ["error", "always"]
     }
   }
   EOF
   
   # Create a simple Express application
   mkdir -p src
   
   cat > src/index.js << EOF
   const express = require('express');
   const app = express();
   const port = process.env.PORT || 3000;
   
   app.get('/', (req, res) => {
     res.json({ message: 'Hello from Node.js Development Environment' });
   });
   
   app.get('/add/:a/:b', (req, res) => {
     const a = parseInt(req.params.a);
     const b = parseInt(req.params.b);
     res.json({ result: a + b });
   });
   
   // Only start the server if the file is run directly
   if (require.main === module) {
     app.listen(port, () => {
       console.log(\`Server running at http://localhost:\${port}/\`);
     });
   }
   
   module.exports = app; // Export for testing
   EOF
   
   # Create a test file
   mkdir -p tests
   
   cat > tests/index.test.js << EOF
   const request = require('supertest');
   const app = require('../src/index');
   
   describe('API Endpoints', () => {
     it('GET / should return a welcome message', async () => {
       const res = await request(app).get('/');
       expect(res.statusCode).toEqual(200);
       expect(res.body).toHaveProperty('message');
       expect(res.body.message).toEqual('Hello from Node.js Development Environment');
     });
   
     it('GET /add/:a/:b should add two numbers', async () => {
       const res = await request(app).get('/add/2/3');
       expect(res.statusCode).toEqual(200);
       expect(res.body).toHaveProperty('result');
       expect(res.body.result).toEqual(5);
     });
   });
   EOF
   
   # Create .dockerignore
   cat > .dockerignore << EOF
   node_modules
   npm-debug.log
   .git
   .gitignore
   README.md
   .env
   *.test.js
   EOF
   
   # Create Dockerfile for Node.js development
   cat > Dockerfile << EOF
   FROM node:18
   
   WORKDIR /app
   
   # Copy package.json and package-lock.json
   COPY package*.json ./
   
   # Install dependencies
   RUN npm install
   
   # Copy the rest of the code
   COPY . .
   
   # Expose the application port
   EXPOSE 3000
   
   # Run the application in development mode
   CMD ["npm", "start"]
   EOF
   
   # Create docker-compose.yml
   cat > docker-compose.yml << EOF
   version: '3.8'
   
   services:
     app:
       build: .
       ports:
         - "3000:3000"
         - "9229:9229"  # For debugging
       volumes:
         - .:/app
         - node_modules:/app/node_modules
       environment:
         - NODE_ENV=development
       command: nodemon --inspect=0.0.0.0:9229 src/index.js
   
   volumes:
     node_modules:
   EOF
   
   # Create npm run script
   cat > dev.sh << EOF
   #!/bin/bash
   case "\$1" in
     build)
       docker-compose build
       ;;
     up)
       docker-compose up
       ;;
     down)
       docker-compose down
       ;;
     test)
       docker-compose run --rm app npm test
       ;;
     lint)
       docker-compose run --rm app npm run lint
       ;;
     shell)
       docker-compose run --rm app /bin/bash
       ;;
     *)
       echo "Usage: ./dev.sh {build|up|down|test|lint|shell}"
       ;;
   esac
   EOF
   
   chmod +x dev.sh
   ```

2. **Use the Node.js development environment**:
   ```bash
   # Build the development environment
   ./dev.sh build
   
   # Start the application
   ./dev.sh up
   
   # In another terminal, test the API
   curl http://localhost:3000
   curl http://localhost:3000/add/10/20
   
   # Run tests
   ./dev.sh test
   
   # Run linting
   ./dev.sh lint
   
   # Get a shell in the container
   ./dev.sh shell
   
   # Clean up
   ./dev.sh down
   ```

### Database Integration

1. **Create a full-stack development environment with database**:
   ```bash
   # Create a directory for the full-stack development environment
   mkdir -p ~/docker-exercises/fullstack/{backend,frontend}
   cd ~/docker-exercises/fullstack
   
   # Create backend with database connection
   cat > backend/requirements.txt << EOF
   flask==2.2.2
   flask-cors==3.0.10
   flask-sqlalchemy==3.0.2
   psycopg2-binary==2.9.5
   EOF
   
   cat > backend/app.py << EOF
   from flask import Flask, jsonify, request
   from flask_cors import CORS
   from flask_sqlalchemy import SQLAlchemy
   import os
   
   app = Flask(__name__)
   CORS(app)
   
   # Database configuration
   app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL', 'postgresql://user:password@db:5432/appdb')
   app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
   
   db = SQLAlchemy(app)
   
   # Define models
   class Task(db.Model):
       id = db.Column(db.Integer, primary_key=True)
       title = db.Column(db.String(100), nullable=False)
       completed = db.Column(db.Boolean, default=False)
       
       def to_dict(self):
           return {
               'id': self.id,
               'title': self.title,
               'completed': self.completed
           }
   
   # Create database tables
   with app.app_context():
       db.create_all()
   
   # API routes
   @app.route('/api/tasks', methods=['GET'])
   def get_tasks():
       tasks = Task.query.all()
       return jsonify([task.to_dict() for task in tasks])
   
   @app.route('/api/tasks', methods=['POST'])
   def add_task():
       data = request.get_json()
       if not data or 'title' not in data:
           return jsonify({'error': 'Title is required'}), 400
           
       task = Task(title=data['title'])
       db.session.add(task)
       db.session.commit()
       return jsonify(task.to_dict()), 201
   
   @app.route('/api/tasks/<int:task_id>', methods=['PUT'])
   def update_task(task_id):
       task = Task.query.get_or_404(task_id)
       data = request.get_json()
       
       if 'title' in data:
           task.title = data['title']
       if 'completed' in data:
           task.completed = data['completed']
           
       db.session.commit()
       return jsonify(task.to_dict())
   
   @app.route('/api/tasks/<int:task_id>', methods=['DELETE'])
   def delete_task(task_id):
       task = Task.query.get_or_404(task_id)
       db.session.delete(task)
       db.session.commit()
       return jsonify({'result': 'Task deleted'})
   
   if __name__ == '__main__':
       app.run(host='0.0.0.0', port=5000, debug=True)
   EOF
   
   cat > backend/Dockerfile << EOF
   FROM python:3.11-slim
   
   WORKDIR /app
   
   COPY requirements.txt .
   RUN pip install --no-cache-dir -r requirements.txt
   
   COPY . .
   
   CMD ["python", "app.py"]
   EOF
   
   # Create a simple frontend
   cat > frontend/index.html << EOF
   <!DOCTYPE html>
   <html>
   <head>
     <title>Task Manager</title>
     <style>
       body {
         font-family: Arial, sans-serif;
         max-width: 800px;
         margin: 0 auto;
         padding: 20px;
       }
       .task-item {
         display: flex;
         align-items: center;
         padding: 10px;
         border-bottom: 1px solid #eee;
       }
       .task-title {
         flex-grow: 1;
         margin-left: 10px;
       }
       .completed {
         text-decoration: line-through;
         color: #888;
       }
       .task-form {
         display: flex;
         margin-bottom: 20px;
       }
       .task-form input[type="text"] {
         flex-grow: 1;
         padding: 8px;
         margin-right: 10px;
       }
       .task-form button {
         padding: 8px 16px;
       }
     </style>
   </head>
   <body>
     <h1>Task Manager</h1>
     
     <div class="task-form">
       <input type="text" id="newTask" placeholder="Add a new task">
       <button onclick="addTask()">Add</button>
     </div>
     
     <div id="taskList">
       <!-- Tasks will be loaded here -->
     </div>
     
     <script>
       const API_URL = 'http://localhost:5000/api';
       
       // Load tasks
       function loadTasks() {
         fetch(\`\${API_URL}/tasks\`)
           .then(response => response.json())
           .then(tasks => {
             const taskList = document.getElementById('taskList');
             taskList.innerHTML = '';
             
             tasks.forEach(task => {
               const taskEl = document.createElement('div');
               taskEl.className = 'task-item';
               
               const checkbox = document.createElement('input');
               checkbox.type = 'checkbox';
               checkbox.checked = task.completed;
               checkbox.onchange = () => toggleTaskCompleted(task.id, checkbox.checked);
               
               const titleEl = document.createElement('span');
               titleEl.className = task.completed ? 'task-title completed' : 'task-title';
               titleEl.textContent = task.title;
               
               const deleteBtn = document.createElement('button');
               deleteBtn.textContent = 'Delete';
               deleteBtn.onclick = () => deleteTask(task.id);
               
               taskEl.appendChild(checkbox);
               taskEl.appendChild(titleEl);
               taskEl.appendChild(deleteBtn);
               
               taskList.appendChild(taskEl);
             });
           })
           .catch(error => console.error('Error loading tasks:', error));
       }
       
       // Add a new task
       function addTask() {
         const input = document.getElementById('newTask');
         const title = input.value.trim();
         
         if (title) {
           fetch(\`\${API_URL}/tasks\`, {
             method: 'POST',
             headers: {
               'Content-Type': 'application/json'
             },
             body: JSON.stringify({ title })
           })
           .then(response => response.json())
           .then(() => {
             input.value = '';
             loadTasks();
           })
           .catch(error => console.error('Error adding task:', error));
         }
       }
       
       // Toggle task completed status
       function toggleTaskCompleted(taskId, completed) {
         fetch(\`\${API_URL}/tasks/\${taskId}\`, {
           method: 'PUT',
           headers: {
             'Content-Type': 'application/json'
           },
           body: JSON.stringify({ completed })
         })
         .then(() => loadTasks())
         .catch(error => console.error('Error updating task:', error));
       }
       
       // Delete a task
       function deleteTask(taskId) {
         fetch(\`\${API_URL}/tasks/\${taskId}\`, {
           method: 'DELETE'
         })
         .then(() => loadTasks())
         .catch(error => console.error('Error deleting task:', error));
       }
       
       // Load tasks when page loads
       document.addEventListener('DOMContentLoaded', loadTasks);
     </script>
   </body>
   </html>
   EOF
   
   cat > frontend/Dockerfile << EOF
   FROM nginx:alpine
   
   COPY index.html /usr/share/nginx/html/
   
   EXPOSE 80
   EOF
   
   # Create docker-compose.yml
   cat > docker-compose.yml << EOF
   version: '3.8'
   
   services:
     frontend:
       build: ./frontend
       ports:
         - "8080:80"
   
     backend:
       build: ./backend
       ports:
         - "5000:5000"
       environment:
         - DATABASE_URL=postgresql://user:password@db:5432/appdb
       volumes:
         - ./backend:/app
       depends_on:
         db:
           condition: service_healthy
   
     db:
       image: postgres:14-alpine
       environment:
         - POSTGRES_USER=user
         - POSTGRES_PASSWORD=password
         - POSTGRES_DB=appdb
       volumes:
         - postgres_data:/var/lib/postgresql/data
       healthcheck:
         test: ["CMD-SHELL", "pg_isready -U user -d appdb"]
         interval: 5s
         timeout: 5s
         retries: 5
       ports:
         - "5432:5432"
   
     pgadmin:
       image: dpage/pgadmin4
       environment:
         - PGADMIN_DEFAULT_EMAIL=admin@example.com
         - PGADMIN_DEFAULT_PASSWORD=admin
       ports:
         - "5050:80"
       depends_on:
         - db
   
   volumes:
     postgres_data:
   EOF
   ```

2. **Run and use the full-stack environment**:
   ```bash
   # Start the full-stack environment
   docker-compose up -d
   
   # Open the application in a browser: http://localhost:8080
   # Access pgAdmin at: http://localhost:5050 (login with admin@example.com/admin)
   
   # In pgAdmin, add a new server:
   # - Name: Local Development
   # - Host: db
   # - Port: 5432
   # - Username: user
   # - Password: password
   
   # Test the API
   curl http://localhost:5000/api/tasks
   
   # Add a task
   curl -X POST -H "Content-Type: application/json" \
     -d '{"title":"Learn Docker"}' \
     http://localhost:5000/api/tasks
   
   # Get all tasks
   curl http://localhost:5000/api/tasks
   
   # Update a task (replace 1 with the actual task ID)
   curl -X PUT -H "Content-Type: application/json" \
     -d '{"completed":true}' \
     http://localhost:5000/api/tasks/1
   
   # Clean up
   docker-compose down -v
   ```

## Projects

### Project 1: Development Environment Container [Beginner] (4-6 hours)

Create a comprehensive development environment container for your preferred programming language and tools.

#### Requirements:

1. Create a Dockerfile that includes:
   - Your preferred programming language(s)
   - Neovim with language server support
   - Git and other version control tools
   - Development utilities (curl, wget, make, etc.)
   - Debugging tools
   - Testing frameworks

2. Configure persistent storage:
   - Mount your projects directory
   - Set up persistent configuration for Neovim, Git, etc.
   - Create a volume for package caches

3. Documentation:
   - Create a detailed README with setup instructions
   - Document all installed tools and their purpose
   - Add examples of common development workflows

4. Create a shell script to launch the container with the correct mounts and environment variables

### Project 2: Multi-Service Web Application [Intermediate] (8-10 hours)

Build a containerized web application with multiple services using Docker Compose.

#### Requirements:

1. Create a web application with at least these components:
   - Frontend (e.g., React, Vue, or simple HTML/JS)
   - Backend API (e.g., Flask, Express)
   - Database (e.g., PostgreSQL, MongoDB)
   - Cache (e.g., Redis)

2. Implement proper networking:
   - Separate frontend and backend networks
   - Expose only necessary ports

3. Set up data persistence:
   - Database volumes
   - Configure proper backup mechanisms

4. Development environments:
   - Hot reloading for frontend and backend
   - Debug configurations
   - Separate development and production configurations

5. Documentation:
   - Architecture diagram
   - Setup and usage instructions
   - Development workflow guide

### Project 3: Language-Specific Development Templates [Intermediate] (6-8 hours)

Create reusable Dockerfile and Docker Compose templates for multiple programming languages.

#### Requirements:

1. Create development templates for at least 3 languages:
   - Python (with virtual environment management)
   - Node.js (with npm/yarn management)
   - Choose a third language (Go, Ruby, Java, etc.)

2. For each template, implement:
   - Development and production configurations
   - Proper dependency management
   - Testing setup
   - Linting and formatting
   - Debugging configuration

3. Create initialization scripts:
   - Project scaffolding
   - Development environment setup
   - Common development tasks

4. Documentation:
   - Detailed usage instructions
   - Best practices for each language
   - Examples of extending the templates

### Project 4: Containerized CI/CD Pipeline [Advanced] (10-12 hours)

Set up a complete CI/CD pipeline using Docker for a sample application.

#### Requirements:

1. Create a sample application with tests:
   - Any language/framework of your choice
   - Unit and integration tests
   - Multiple environments (dev, test, prod)

2. Implement Docker-based CI:
   - Automated testing with GitHub Actions or GitLab CI
   - Linting and code quality checks
   - Image building and tagging

3. Create deployment configurations:
   - Development environment for local testing
   - Staging environment that mimics production
   - Production-ready configuration

4. Implement security best practices:
   - Image scanning
   - Non-root users
   - Minimal base images
   - Secret management

5. Documentation:
   - CI/CD pipeline diagram
   - Deployment instructions
   - Security considerations

## Additional Resources

### Docker Command Cheatsheet

```
# Container Management
docker run            # Create and start a container
docker start          # Start a stopped container
docker stop           # Stop a running container
docker restart        # Restart a container
docker pause          # Pause a running container
docker unpause        # Unpause a paused container
docker rm             # Remove a container
docker ps             # List running containers
docker ps -a          # List all containers
docker logs           # View container logs
docker exec           # Run a command in a container
docker attach         # Attach to a running container
docker port           # List port mappings

# Image Management
docker images         # List images
docker pull           # Pull an image from a registry
docker push           # Push an image to a registry
docker build          # Build an image from a Dockerfile
docker rmi            # Remove an image
docker tag            # Tag an image
docker history        # Show image history
docker inspect        # Show detailed information
docker save           # Save an image to a tar archive
docker load           # Load an image from a tar archive

# Volume Management
docker volume create  # Create a volume
docker volume ls      # List volumes
docker volume rm      # Remove a volume
docker volume inspect # Show volume details

# Network Management
docker network create # Create a network
docker network ls     # List networks
docker network rm     # Remove a network
docker network inspect # Show network details
docker network connect # Connect a container to a network
docker network disconnect # Disconnect a container from a network

# Docker Compose
docker-compose up     # Create and start containers
docker-compose down   # Stop and remove containers
docker-compose start  # Start containers
docker-compose stop   # Stop containers
docker-compose restart # Restart containers
docker-compose ps     # List containers
docker-compose logs   # View logs
docker-compose exec   # Run a command in a container
docker-compose build  # Build or rebuild services
docker-compose pull   # Pull service images
```

### Docker Networking Models

```
┌───────────────────────────────────────────────────────────────┐
│ Docker Networking Models                                      │
├───────────────┬───────────────────────────────────────────────┤
│ Bridge        │ Default network driver                        │
│               │ Containers can communicate on the same host   │
│               │ Maps container ports to host ports            │
├───────────────┼───────────────────────────────────────────────┤
│ Host          │ Uses host's network directly                  │
│               │ No network isolation                          │
│               │ No port mapping needed                        │
├───────────────┼───────────────────────────────────────────────┤
│ None          │ No networking                                 │
│               │ Containers are isolated                       │
├───────────────┼───────────────────────────────────────────────┤
│ Overlay       │ Connect containers across multiple hosts      │
│               │ Used with Docker Swarm or custom driver       │
├───────────────┼───────────────────────────────────────────────┤
│ Macvlan       │ Assign MAC address to containers              │
│               │ Appear as physical devices on the network     │
├───────────────┼───────────────────────────────────────────────┤
│ Custom        │ Third-party network plugins                   │
└───────────────┴───────────────────────────────────────────────┘
```

### Dockerfile Best Practices

1. **Use specific base image tags** instead of `latest`
2. **Minimize the number of layers** by combining related commands
3. **Use multi-stage builds** to reduce final image size
4. **Place infrequently changing lines first** in the Dockerfile
5. **Use `.dockerignore`** to exclude unnecessary files
6. **Run as a non-root user** for better security
7. **Set proper WORKDIR** instead of using absolute paths
8. **Use COPY instead of ADD** unless you specifically need ADD's features
9. **Include health checks** for service containers
10. **Clean up package caches** in the same RUN step

### Docker Volume Types

```
┌────────────────────────────────────────────────────────────────┐
│ Docker Volume Types                                            │
├────────────────┬───────────────────────────────────────────────┤
│ Named Volumes  │ docker volume create my-volume                │
│                │ docker run -v my-volume:/path                 │
│                │ Managed by Docker                             │
│                │ Persistent across container lifecycle         │
├────────────────┼───────────────────────────────────────────────┤
│ Bind Mounts    │ docker run -v /host/path:/container/path     │
│                │ Maps host directory to container              │
│                │ Good for development                          │
│                │ Host-dependent                                │
├────────────────┼───────────────────────────────────────────────┤
│ tmpfs Mounts   │ docker run --tmpfs /container/path           │
│                │ Stored in host memory only                    │
│                │ No persistence, high performance              │
│                │ Good for sensitive data                       │
└────────────────┴───────────────────────────────────────────────┘
```

## Reflection Questions

After completing the exercises and projects, reflect on these questions:

1. How does containerization change your approach to development environment setup and dependency management?

2. What advantages does Docker Compose provide for multi-container applications compared to managing containers individually?

3. What are the main differences in how you would configure containers for development versus production environments?

4. How do Docker volumes solve the data persistence challenge, and what volume types are best for different use cases?

5. What are the security implications of running applications in containers, and how can you address them?

6. How would you approach debugging applications running inside containers?

7. In what ways can containerization improve collaboration among development teams?

8. How does your containerization approach differ between stateful and stateless applications?

## Answers to Self-Assessment Quiz

1. The main difference between containers and virtual machines is that containers share the host system's kernel and isolate the application processes, while virtual machines run a complete operating system with its own kernel on top of a hypervisor.

2. `docker ps -a` is used to list all containers, including those that aren't running.

3. To create a named volume and mount it in a container:
   ```bash
   docker volume create my-volume
   docker run -v my-volume:/path/in/container image-name
   ```

4. The `.dockerignore` file specifies which files and directories should be excluded when building an image, reducing build context size and avoiding including sensitive files.

5. `CMD` provides default commands that can be overridden when starting a container, while `ENTRYPOINT` specifies the executable that will run when the container starts and is less easily overridden (parameters passed to docker run are appended to the entrypoint).

6. A multi-stage build uses multiple FROM statements in a Dockerfile, where each FROM begins a new stage. It's used to create smaller production images by copying only necessary artifacts from build stages, leaving build tools behind.

7. Docker Compose facilitates multi-container applications by allowing you to define, configure, and run multiple containers as a single service with a YAML file. It manages networking, volumes, and dependencies between containers.

8. The `depends_on` directive in Docker Compose establishes startup order dependencies between services, ensuring that dependent services start after their dependencies.

9. To implement health checks for a containerized service, you can add a HEALTHCHECK instruction in the Dockerfile or use the healthcheck configuration in Docker Compose. This allows Docker to monitor the container's health and restart it if needed.

10. Advantages of running development environments in containers include: consistent environments across team members, isolation from the host system, easy onboarding for new developers, ability to match production closely, and simple cleanup without affecting the host system.

## Next Steps

After completing Month 6 exercises, consider these activities to further enhance your containerization skills:

1. **Explore Kubernetes basics** for container orchestration at scale
2. **Learn about Docker security scanning tools** like Trivy or Clair
3. **Create containerized monitoring solutions** with Prometheus and Grafana
4. **Implement container logging strategies** with tools like Fluentd or Loki
5. **Optimize your container images** to reduce size and improve security
6. **Experiment with GitLab or GitHub CI/CD** for containerized applications
7. **Explore Docker extensions for VS Code or Neovim** to improve your development workflow
8. **Set up a private Docker registry** for your custom images

## Acknowledgements

This exercise guide was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Exercise structure and organization
- Resource recommendations
- Script development suggestions

Claude was used as a development aid while all final implementation decisions and review were performed by Joshua Michael Hall.

## Disclaimer

These exercises are provided "as is", without warranty of any kind. Always make backups before making system changes. Practice containerization in isolated environments before implementing in production scenarios.
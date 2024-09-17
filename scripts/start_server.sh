#!/bin/bash

# Get Docker Hub credentials from Secrets Manager
DOCKER_USERNAME=$(aws secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:us-east-1:339712721384:secret:docker-us-JYDQoe --query SecretString --output text | jq -r '.username')
DOCKER_PASSWORD=$(aws secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:us-east-1:339712721384:secret:docker-us-JYDQoe --query SecretString --output text | jq -r '.password')

# Log in to Docker Hub
echo "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USERNAME" --password-stdin

# Pull the latest Docker image from Docker Hub
docker pull "$DOCKER_USERNAME"/my-webapp-repo:${DEPLOYMENT_ID}

# Stop any running containers of this app
docker stop my-webapp || true
docker rm my-webapp || true

# Run the new container
docker run -d --name my-webapp -p 80:80 "$DOCKER_USERNAME"/my-webapp-repo:${DEPLOYMENT_ID}

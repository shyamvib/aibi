#!/bin/bash

# Script to set up and run ngrok tunnel for Evidence dashboard

# Function to display help message
show_help() {
  echo "Usage: ./ngrok-setup.sh [OPTION]"
  echo "Set up and run ngrok tunnel for Evidence dashboard."
  echo ""
  echo "Options:"
  echo "  setup     Set up ngrok auth token and credentials"
  echo "  start     Start the Evidence dashboard with ngrok tunnel"
  echo "  stop      Stop the running containers"
  echo "  status    Check the status of the ngrok tunnel"
  echo "  help      Display this help message"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
  echo "Docker is not installed. Please install Docker first."
  exit 1
fi

# Check if Docker Compose is installed
if ! docker compose version &> /dev/null; then
  echo "Docker Compose is not installed. Please install Docker Compose first."
  exit 1
fi

# Setup function
setup_ngrok() {
  echo "Setting up ngrok for Evidence dashboard..."
  
  # Check if .env file exists
  if [ ! -f .env ]; then
    echo "Creating .env file..."
    cp .env.example .env
    echo ""
    echo "Please edit the .env file and add your ngrok auth token."
    echo "You can get your auth token from https://dashboard.ngrok.com/get-started/your-authtoken"
    echo ""
    echo "Also, you can change the basic auth username and password in docker-compose.yml"
    echo "Current default is: admin / password123"
  else
    echo ".env file already exists."
  fi
}

# Start function
start_services() {
  echo "Starting Evidence dashboard with ngrok tunnel..."
  
  # Check if .env file exists
  if [ ! -f .env ]; then
    echo "Error: .env file not found. Please run './ngrok-setup.sh setup' first."
    exit 1
  fi
  
  # Stop any running containers
  docker compose down
  
  # Start the services
  docker compose up -d
  
  echo ""
  echo "Evidence dashboard and ngrok tunnel are starting..."
  echo "You can check the ngrok tunnel URL by running: './ngrok-setup.sh status'"
  echo "The ngrok admin interface is available at: http://localhost:4040"
}

# Status function
check_status() {
  echo "Checking ngrok tunnel status..."
  
  # Check if ngrok container is running
  if ! docker compose ps | grep -q "ngrok"; then
    echo "Error: ngrok container is not running. Please start the services first."
    exit 1
  fi
  
  # Get the public URL from ngrok API
  echo ""
  echo "Ngrok tunnel information:"
  TUNNEL_INFO=$(curl -s http://localhost:4040/api/tunnels)
  if [[ $TUNNEL_INFO == *"public_url"* ]]; then
    echo "$TUNNEL_INFO" | grep -o '"public_url":"[^"]*' | sed 's/"public_url":"/Public URL: /'
  else
    echo "No active tunnels found. The ngrok service might still be starting up."
    echo "Please wait a few seconds and try again."
    echo "You can check the ngrok logs with: docker compose logs ngrok"
  fi
  
  echo ""
  echo "Access credentials:"
  echo "Username: rsm"
  echo "Password: vibrantbi"
  echo ""
  echo "You can change these credentials in the docker-compose.yml file."
}

# Parse command line arguments
case "$1" in
  setup)
    setup_ngrok
    ;;
  start)
    start_services
    ;;
  stop)
    echo "Stopping containers..."
    docker compose down
    ;;
  status)
    check_status
    ;;
  help|"")
    show_help
    ;;
  *)
    echo "Unknown option: $1"
    show_help
    exit 1
    ;;
esac

#!/bin/bash

# Script to run the Evidence dashboard in Docker

# Function to display help message
show_help() {
  echo "Usage: ./docker-run.sh [OPTION]"
  echo "Run the Evidence dashboard in Docker."
  echo ""
  echo "Options:"
  echo "  dev       Run in development mode (default)"
  echo "  build     Build the Docker image"
  echo "  sources   Generate source files from ClickHouse"
  echo "  stop      Stop the running containers"
  echo "  clean     Remove containers and volumes"
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

# Parse command line arguments
case "$1" in
  build)
    echo "Building Docker image..."
    docker compose build
    ;;
  sources)
    echo "Generating source files from ClickHouse..."
    docker compose run --rm evidence-dashboard npm run sources:all
    ;;
  stop)
    echo "Stopping containers..."
    docker compose down
    ;;
  clean)
    echo "Cleaning up containers and volumes..."
    docker compose down -v
    ;;
  help)
    show_help
    ;;
  dev|"")
    echo "Starting Evidence dashboard in development mode..."
    docker compose up
    ;;
  *)
    echo "Unknown option: $1"
    show_help
    exit 1
    ;;
esac

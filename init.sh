#!/bin/bash

# Initialization script for ClickHouse to Parquet Evidence Dashboard
# Version 1.0.0

echo "Initializing ClickHouse to Parquet Evidence Dashboard..."

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "npm is not installed. Please install Node.js and npm first."
    exit 1
fi

# Install dependencies
echo "Installing dependencies..."
npm install

# Create necessary directories
echo "Creating directory structure..."
mkdir -p sources/parquet_files

# Check if ClickHouse connection is configured
if [ ! -f "sources/business_intelligence/connection.yaml" ]; then
    echo "ClickHouse connection not configured."
    echo "Please edit sources/business_intelligence/connection.yaml with your ClickHouse credentials."
    
    # Create template connection file
    mkdir -p sources/business_intelligence
    cat > sources/business_intelligence/connection.yaml << EOL
name: business_intelligence
type: clickhouse
options:
  url: http://YOUR_CLICKHOUSE_HOST:PORT
  username: YOUR_USERNAME
  password: YOUR_PASSWORD
  database: YOUR_DATABASE
  request_timeout: 60000
EOL
    
    echo "Created template connection file at sources/business_intelligence/connection.yaml"
fi

# Create parquet_files connection
echo "Configuring parquet files connection..."
cat > sources/parquet_files/connection.yaml << EOL
name: parquet_files
type: parquet
options:
  directory: $(pwd)/sources/parquet_files
EOL

echo "Initialization complete!"
echo ""
echo "Next steps:"
echo "1. Configure your ClickHouse connection in sources/business_intelligence/connection.yaml"
echo "2. Run 'npm run sources:all' to generate parquet files"
echo "3. Run 'npm run dev' to start the dashboard"

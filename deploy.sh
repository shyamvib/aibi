#!/bin/bash

# Deployment script for ClickHouse to Parquet Evidence Dashboard
# Version 1.0.0

# Check if server address is provided
if [ -z "$1" ]; then
  echo "Usage: ./deploy.sh SERVER_ADDRESS [SSH_USER]"
  echo "Example: ./deploy.sh example.com user"
  exit 1
fi

SERVER_ADDRESS=$1
SSH_USER=${2:-$(whoami)}  # Default to current user if not specified

echo "Deploying to $SSH_USER@$SERVER_ADDRESS..."

# Build the project
echo "Building the project..."
npm run sources:all
npm run build

# Check if build was successful
if [ ! -d ".evidence/template" ]; then
  echo "Build failed. Check for errors above."
  exit 1
fi

# Create a deployment package
echo "Creating deployment package..."
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DEPLOY_DIR="deploy_$TIMESTAMP"
mkdir -p $DEPLOY_DIR

# Copy necessary files
cp -r .evidence/template/* $DEPLOY_DIR/
cp README.md $DEPLOY_DIR/
cp package.json $DEPLOY_DIR/
cp -r sources $DEPLOY_DIR/
cp flatten_parquet_files.sh $DEPLOY_DIR/

# Create version file
echo "Version 1.0.0" > $DEPLOY_DIR/VERSION
echo "Deployed on $(date)" >> $DEPLOY_DIR/VERSION

# Create deployment archive
DEPLOY_ARCHIVE="clickhouse_evidence_dashboard_$TIMESTAMP.tar.gz"
tar -czf $DEPLOY_ARCHIVE $DEPLOY_DIR

# Deploy to server
echo "Deploying to server..."
scp $DEPLOY_ARCHIVE $SSH_USER@$SERVER_ADDRESS:~/
ssh $SSH_USER@$SERVER_ADDRESS "mkdir -p ~/evidence_dashboard && tar -xzf ~/$DEPLOY_ARCHIVE -C ~/evidence_dashboard && rm ~/$DEPLOY_ARCHIVE"

# Cleanup
rm -rf $DEPLOY_DIR
rm $DEPLOY_ARCHIVE

echo "Deployment complete!"
echo "The dashboard is now available at http://$SERVER_ADDRESS/evidence_dashboard/$DEPLOY_DIR/"
echo "You may need to configure your web server to serve this directory."
echo ""
echo "To run the dashboard on the server:"
echo "1. SSH into the server: ssh $SSH_USER@$SERVER_ADDRESS"
echo "2. Navigate to the dashboard directory: cd ~/evidence_dashboard/$DEPLOY_DIR"
echo "3. Install dependencies: npm install"
echo "4. Start the server: npm run preview"

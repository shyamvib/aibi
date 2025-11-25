#!/bin/bash

# Script to create a release package for ClickHouse to Parquet Evidence Dashboard
# Version 1.0.0

echo "Creating release package for ClickHouse to Parquet Evidence Dashboard v1.0.0..."

# Create release directory
RELEASE_DIR="clickhouse_evidence_dashboard_v1.0.0"
rm -rf $RELEASE_DIR
mkdir -p $RELEASE_DIR

# Copy necessary files
echo "Copying project files..."
cp -r sources $RELEASE_DIR/
cp -r pages $RELEASE_DIR/
cp package.json $RELEASE_DIR/
cp evidence.config.yaml $RELEASE_DIR/
cp README.md $RELEASE_DIR/
cp TROUBLESHOOTING.md $RELEASE_DIR/
cp VERSION $RELEASE_DIR/
cp init.sh $RELEASE_DIR/
cp deploy.sh $RELEASE_DIR/
cp flatten_parquet_files.sh $RELEASE_DIR/
mkdir -p $RELEASE_DIR/.evidence
cp .evidence/sources.yaml $RELEASE_DIR/.evidence/

# Remove any sensitive information
echo "Sanitizing configuration files..."
sed -i '' 's/vibrant/YOUR_PASSWORD/g' $RELEASE_DIR/sources/business_intelligence/connection.yaml
sed -i '' 's/10.6.2.34/YOUR_CLICKHOUSE_HOST/g' $RELEASE_DIR/sources/business_intelligence/connection.yaml

# Create a release archive
echo "Creating release archive..."
RELEASE_ARCHIVE="clickhouse_evidence_dashboard_v1.0.0.tar.gz"
tar -czf $RELEASE_ARCHIVE $RELEASE_DIR

# Cleanup
rm -rf $RELEASE_DIR

echo "Release package created: $RELEASE_ARCHIVE"
echo "You can distribute this package to deploy on other servers."

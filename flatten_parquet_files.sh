#!/bin/bash

echo "Flattening parquet file structure..."

# Create the directory if it doesn't exist
mkdir -p /app/sources/parquet_files

# Copy all parquet files from .evidence to sources/parquet_files
find /app/.evidence/template/static/data -name "*.parquet" -exec cp {} /app/sources/parquet_files/ \;

# List the copied files
echo "Copied files:"
ls -la /app/sources/parquet_files/

echo "Done."

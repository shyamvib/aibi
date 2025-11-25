#!/bin/bash

# This script flattens the parquet file structure by copying files from subdirectories to the main directory

# Source directory where Evidence stores the generated parquet files
SOURCE_DIR="/Users/shyam.n/dsa/aibi/sources/parquet_files"

# Find all parquet files in subdirectories and copy them to the main directory
echo "Flattening parquet file structure..."

find "$SOURCE_DIR" -mindepth 2 -name "*.parquet" | while read file; do
    # Get the directory name (which is the query name)
    dir_name=$(basename "$(dirname "$file")")
    
    # Copy the file to the main directory with the directory name as the filename
    cp "$file" "$SOURCE_DIR/$dir_name.parquet"
    echo "Copied $file to $SOURCE_DIR/$dir_name.parquet"
done

echo "Done."

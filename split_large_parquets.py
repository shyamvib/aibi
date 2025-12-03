#!/usr/bin/env python3
"""
Script to split large parquet files into smaller chunks to prevent DuckDB timeout issues.
"""

import os
import pandas as pd
import glob
import argparse
from pathlib import Path

def split_parquet_file(file_path, max_rows=10000, output_dir=None):
    """Split a large parquet file into smaller chunks."""
    if output_dir is None:
        output_dir = os.path.dirname(file_path)
    
    file_name = os.path.basename(file_path)
    file_base = os.path.splitext(file_name)[0]
    
    print(f"Processing {file_path}...")
    
    # Read the parquet file
    try:
        df = pd.read_parquet(file_path)
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return False
    
    # If file is small enough, no need to split
    if len(df) <= max_rows:
        print(f"File {file_name} has {len(df)} rows, no need to split.")
        return True
    
    # Split the dataframe into chunks
    total_rows = len(df)
    num_chunks = (total_rows + max_rows - 1) // max_rows  # Ceiling division
    
    print(f"Splitting {file_name} ({total_rows} rows) into {num_chunks} chunks...")
    
    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    
    # Create a backup of the original file
    backup_path = os.path.join(output_dir, f"{file_base}_original.parquet")
    try:
        df.to_parquet(backup_path)
        print(f"Created backup at {backup_path}")
    except Exception as e:
        print(f"Warning: Could not create backup: {e}")
    
    # Split and write chunks
    for i in range(num_chunks):
        start_idx = i * max_rows
        end_idx = min((i + 1) * max_rows, total_rows)
        
        chunk = df.iloc[start_idx:end_idx]
        chunk_path = os.path.join(output_dir, f"{file_base}_part{i+1}.parquet")
        
        try:
            chunk.to_parquet(chunk_path)
            print(f"Created chunk {i+1}/{num_chunks}: {chunk_path} ({len(chunk)} rows)")
        except Exception as e:
            print(f"Error writing chunk {i+1}: {e}")
            return False
    
    return True

def process_directory(directory, max_rows=10000, min_size_mb=10):
    """Process all parquet files in a directory."""
    parquet_files = glob.glob(os.path.join(directory, "*.parquet"))
    
    if not parquet_files:
        print(f"No parquet files found in {directory}")
        return
    
    print(f"Found {len(parquet_files)} parquet files in {directory}")
    
    # Convert min_size_mb to bytes
    min_size_bytes = min_size_mb * 1024 * 1024
    
    for file_path in parquet_files:
        # Check file size
        file_size = os.path.getsize(file_path)
        if file_size < min_size_bytes:
            print(f"Skipping {os.path.basename(file_path)} (size: {file_size/1024/1024:.2f} MB, below threshold)")
            continue
        
        print(f"Processing {os.path.basename(file_path)} (size: {file_size/1024/1024:.2f} MB)")
        split_parquet_file(file_path, max_rows=max_rows, output_dir=directory)

def main():
    parser = argparse.ArgumentParser(description="Split large parquet files into smaller chunks")
    parser.add_argument("--directory", "-d", default="./sources/parquet_files", 
                        help="Directory containing parquet files (default: ./sources/parquet_files)")
    parser.add_argument("--max-rows", "-r", type=int, default=10000, 
                        help="Maximum rows per chunk (default: 10000)")
    parser.add_argument("--min-size", "-s", type=float, default=10, 
                        help="Minimum file size in MB to process (default: 10)")
    
    args = parser.parse_args()
    
    process_directory(args.directory, args.max_rows, args.min_size)

if __name__ == "__main__":
    main()

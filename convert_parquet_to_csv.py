#!/usr/bin/env python3
"""
Script to convert parquet files to CSV format.
"""

import os
import pandas as pd
import glob
import argparse
from pathlib import Path

def convert_parquet_to_csv(file_path, output_dir=None):
    """Convert a parquet file to CSV format."""
    if output_dir is None:
        output_dir = os.path.join(os.path.dirname(file_path), "csv")
    
    file_name = os.path.basename(file_path)
    file_base = os.path.splitext(file_name)[0]
    csv_path = os.path.join(output_dir, f"{file_base}.csv")
    
    print(f"Converting {file_path} to CSV...")
    
    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    
    # Read the parquet file
    try:
        df = pd.read_parquet(file_path)
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return False
    
    # Write to CSV
    try:
        df.to_csv(csv_path, index=False)
        print(f"Created CSV file: {csv_path} ({len(df)} rows)")
        return True
    except Exception as e:
        print(f"Error writing CSV file: {e}")
        return False

def process_directory(directory, output_dir=None):
    """Process all parquet files in a directory."""
    if output_dir is None:
        output_dir = os.path.join(directory, "csv")
    
    parquet_files = glob.glob(os.path.join(directory, "*.parquet"))
    
    if not parquet_files:
        print(f"No parquet files found in {directory}")
        return
    
    print(f"Found {len(parquet_files)} parquet files in {directory}")
    
    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    
    success_count = 0
    for file_path in parquet_files:
        if convert_parquet_to_csv(file_path, output_dir):
            success_count += 1
    
    print(f"Successfully converted {success_count} out of {len(parquet_files)} files to CSV format.")
    print(f"CSV files are available in: {output_dir}")

def main():
    parser = argparse.ArgumentParser(description="Convert parquet files to CSV format")
    parser.add_argument("--directory", "-d", default="./sources/parquet_files", 
                        help="Directory containing parquet files (default: ./sources/parquet_files)")
    parser.add_argument("--output", "-o", default=None, 
                        help="Output directory for CSV files (default: ./sources/csv)")
    
    args = parser.parse_args()
    
    if args.output is None:
        args.output = os.path.join(os.path.dirname(args.directory), "csv")
    
    process_directory(args.directory, args.output)

if __name__ == "__main__":
    main()

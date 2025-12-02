#!/usr/bin/env python3
import pandas as pd
import os
from pathlib import Path

def convert_parquet_to_csv(parquet_dir, csv_dir):
    """Convert parquet files to CSV format."""
    # Create the CSV directory if it doesn't exist
    os.makedirs(csv_dir, exist_ok=True)
    
    # Get a list of all subdirectories in the parquet directory
    parquet_subdirs = [d for d in os.listdir(parquet_dir) if os.path.isdir(os.path.join(parquet_dir, d))]
    
    for subdir in parquet_subdirs:
        parquet_file = os.path.join(parquet_dir, subdir, f"{subdir}.parquet")
        if os.path.exists(parquet_file):
            try:
                # Read the parquet file
                df = pd.read_parquet(parquet_file)
                
                # Create a subdirectory in the CSV directory
                csv_subdir = os.path.join(csv_dir, subdir)
                os.makedirs(csv_subdir, exist_ok=True)
                
                # Write to CSV
                csv_file = os.path.join(csv_subdir, f"{subdir}.csv")
                df.to_csv(csv_file, index=False)
                print(f"Converted {parquet_file} to {csv_file}")
            except Exception as e:
                print(f"Error converting {parquet_file}: {e}")

if __name__ == "__main__":
    parquet_dir = "/app/.evidence/template/static/data/myclickhouse"
    csv_dir = "/app/sources/csv_data"
    convert_parquet_to_csv(parquet_dir, csv_dir)

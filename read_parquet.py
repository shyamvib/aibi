#!/usr/bin/env python3
import pandas as pd
import os
import sys
from pathlib import Path

def list_parquet_files(directory):
    """List all parquet files in the given directory and its subdirectories."""
    parquet_files = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.parquet'):
                parquet_files.append(os.path.join(root, file))
    return parquet_files

def read_parquet_file(file_path):
    """Read a parquet file and return its contents as a pandas DataFrame."""
    try:
        df = pd.read_parquet(file_path)
        return df
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return None

def main():
    # Define the directory containing the parquet files
    base_dir = Path("/app/.evidence/template/static/data/myclickhouse")
    
    # If a specific file is provided as an argument, read only that file
    if len(sys.argv) > 1:
        query_name = sys.argv[1]
        file_path = base_dir / query_name / f"{query_name}.parquet"
        if file_path.exists():
            df = read_parquet_file(file_path)
            if df is not None:
                print(f"\n=== Contents of {query_name} ===")
                print(df)
                print(f"\nShape: {df.shape}")
                print(f"Columns: {df.columns.tolist()}")
        else:
            print(f"File not found: {file_path}")
            print("Available queries:")
            for dir_path in base_dir.iterdir():
                if dir_path.is_dir():
                    print(f"  - {dir_path.name}")
    else:
        # List all parquet files
        print("Available queries:")
        for dir_path in base_dir.iterdir():
            if dir_path.is_dir():
                print(f"  - {dir_path.name}")
        
        print("\nUsage: python read_parquet.py [query_name]")
        print("Example: python read_parquet.py check_table_exists")

if __name__ == "__main__":
    main()

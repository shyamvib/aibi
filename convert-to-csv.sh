#!/bin/bash

# Script to convert parquet files to CSV format using Docker

echo "Converting parquet files to CSV format..."

# Run the Python script in a Docker container
docker run --rm -v "$(pwd):/app" -w /app python:3.9 bash -c "
    pip install pandas pyarrow &&
    python /app/convert_parquet_to_csv.py --directory /app/sources/parquet_files --output /app/sources/csv
"

echo ""
echo "Conversion complete! You can now use CSV files as data sources for your dashboard."
echo "CSV files are available in: ./sources/csv"

#!/bin/bash

# Script to split large parquet files using Docker

echo "Splitting large parquet files to avoid timeout issues..."

# Run the Python script in a Docker container
docker run --rm -v "$(pwd):/app" -w /app python:3.9 bash -c "
    pip install pandas pyarrow &&
    python /app/split_large_parquets.py --directory /app/sources/parquet_files --max-rows 10000 --min-size 10
"

echo ""
echo "Splitting complete! You should now have smaller parquet files that are less likely to cause timeout issues."
echo "Remember to commit these new files to GitHub for deployment."

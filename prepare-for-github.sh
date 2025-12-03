#!/bin/bash

# Script to prepare the parquet files for GitHub deployment

# Function to display help message
show_help() {
  echo "Usage: ./prepare-for-github.sh"
  echo "Prepare the parquet files for GitHub deployment."
  echo ""
  echo "This script will:"
  echo "1. Ensure parquet files are properly tracked by Git"
  echo "2. Update .gitignore to allow parquet files"
  echo "3. Create a .gitattributes file to handle parquet files properly"
}

# Check if Git is installed
if ! command -v git &> /dev/null; then
  echo "Git is not installed. Please install Git first."
  exit 1
fi

# Check if we're in a Git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
  echo "Not in a Git repository. Please run this script from within a Git repository."
  exit 1
fi

# Update .gitignore to allow parquet files
echo "Updating .gitignore to allow parquet files..."
if grep -q "*.parquet" .gitignore; then
  # Remove the line that ignores parquet files
  sed -i '/\*\.parquet/d' .gitignore
  echo "Removed *.parquet from .gitignore"
else
  echo "No need to update .gitignore, parquet files are not being ignored."
fi

# Create .gitattributes file to handle parquet files properly
echo "Creating .gitattributes file..."
cat > .gitattributes << EOL
# Handle parquet files properly
*.parquet binary
EOL
echo "Created .gitattributes file"

# Ensure the sources/parquet_files directory exists
mkdir -p sources/parquet_files

# Check if parquet files exist
if [ -z "$(find sources/parquet_files -name '*.parquet' 2>/dev/null)" ]; then
  echo "No parquet files found in sources/parquet_files directory."
  echo "Please run './docker-run.sh sources' first to generate the parquet files."
  exit 1
fi

echo ""
echo "Preparation complete!"
echo "Now you can commit and push the changes to GitHub:"
echo "git add sources/parquet_files/*.parquet .gitignore .gitattributes"
echo "git commit -m \"Add parquet files for GitHub Pages deployment\""
echo "git push origin main"
echo ""
echo "After pushing, GitHub Actions will build and deploy your Evidence dashboard."

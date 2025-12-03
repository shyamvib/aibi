# GitHub Pages Deployment Guide

This guide explains how to deploy the Evidence dashboard to GitHub Pages.

## Prerequisites

- A GitHub account
- A GitHub repository for this project
- Git installed on your local machine

## Setup Steps

1. **Configure Evidence for GitHub Pages**
   - The `evidence.config.yaml` file has been updated with the base path: `/aibi`
   - The `package.json` file has been updated to set the build directory: `./build/aibi`

2. **Prepare Parquet Files for GitHub**
   - Run the preparation script: `./prepare-for-github.sh`
   - This script will:
     - Update `.gitignore` to allow parquet files
     - Create `.gitattributes` to handle parquet files properly
     - Provide instructions for committing the changes

3. **Push to GitHub**
   - Commit the changes: `git add sources/parquet_files/*.parquet .gitignore .gitattributes`
   - Add a commit message: `git commit -m "Add parquet files for GitHub Pages deployment"`
   - Push to GitHub: `git push origin main`

4. **Enable GitHub Pages**
   - Go to your GitHub repository
   - Click on "Settings"
   - Scroll down to "Pages"
   - Under "Source", select "GitHub Actions"
   - The workflow file `.github/workflows/deploy.yml` will handle the deployment

5. **Access Your Dashboard**
   - Once deployed, your dashboard will be available at: `https://[your-username].github.io/aibi/`

## Updating the Dashboard

To update the dashboard:

1. Make your changes locally
2. If you've updated the data sources:
   - Run `./docker-run.sh sources` to regenerate the parquet files
   - Commit the updated parquet files
3. Push the changes to GitHub
4. GitHub Actions will automatically rebuild and redeploy the dashboard

## Troubleshooting

- If the deployment fails, check the GitHub Actions logs for errors
- Ensure that GitHub Pages is enabled in your repository settings
- Verify that the parquet files are properly committed to the repository

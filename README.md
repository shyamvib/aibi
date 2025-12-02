# ClickHouse to Parquet Evidence Dashboard

## Version 1.0.0

This project demonstrates how to connect to a ClickHouse database, query data, and store the results as parquet files for fast and efficient data visualization using Evidence.

## Architecture

This project uses a two-tier architecture:

1. **Data Tier**: ClickHouse database connection that generates parquet files
2. **Visualization Tier**: Evidence dashboard that reads from parquet files

This approach provides several benefits:
- Reduced load on the ClickHouse server
- Faster dashboard performance
- Ability to work offline once data is cached
- Simplified deployment

## Setup Instructions

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure ClickHouse Connection

Edit the connection details in `/sources/business_intelligence/connection.yaml`:

```yaml
name: business_intelligence
type: clickhouse
options:
  url: http://YOUR_CLICKHOUSE_HOST:PORT
  username: YOUR_USERNAME
  password: YOUR_PASSWORD
  database: YOUR_DATABASE
  request_timeout: 60000
```

### 3. Generate Parquet Files

```bash
npm run sources:all
```

This command:
- Runs all SQL queries against the ClickHouse database
- Generates parquet files in the `/sources/parquet_files` directory
- Flattens the directory structure for easier access

### 4. Start the Dashboard

```bash
npm run dev
```

Access the dashboard at http://localhost:3000

## Deployment

### GitHub Pages Deployment with Self-Hosted ClickHouse

Since your ClickHouse server is self-hosted and not accessible from GitHub Actions, we'll use pre-generated parquet files:

1. **Generate parquet files locally**:
   ```bash
   npm run sources:all
   ```

2. **Add and commit the parquet files**:
   ```bash
   git add sources/parquet_files/*.parquet sources/parquet_files/**/*.parquet sources/parquet_files/**/*.schema.json
   git commit -m "Add pre-generated parquet files"
   ```

3. **Push your code to GitHub**:
   ```bash
   git push
   ```

4. **Enable GitHub Pages**:
   - Go to your repository settings
   - Click on "Pages" in the left sidebar
   - Under "Build and deployment", select "GitHub Actions" as the source

5. The GitHub Action will build and deploy your dashboard without needing to connect to your ClickHouse server

6. Your dashboard will be available at `https://[your-username].github.io/aibi`

**Note**: Whenever you want to update the data, you have two options:

1. If you have access to the ClickHouse server:
   ```bash
   npm run sources:all
   git add sources/parquet_files/*.parquet sources/parquet_files/**/*.parquet sources/parquet_files/**/*.schema.json
   git commit -m "Update parquet files"
   git push
   ```

2. If you want to use sample data (for testing or demo purposes):
   ```bash
   python create_sample_parquet.py
   git add sources/parquet_files/*.parquet sources/parquet_files/**/*.parquet sources/parquet_files/**/*.schema.json
   git commit -m "Update sample parquet files"
   git push
   ```

### Manual Deployment

To deploy this dashboard to another server manually:

1. Clone this repository
2. Install dependencies: `npm install`
3. Configure the ClickHouse connection
4. Generate parquet files: `npm run sources:all`
5. Build the static site: `npm run build`
6. Deploy the contents of the `build/aibi` directory to your web server

Alternatively, use the included deployment script:

```bash
./deploy.sh YOUR_SERVER_ADDRESS
```

## Project Structure

- `/sources/business_intelligence/`: ClickHouse connection and SQL queries
- `/sources/parquet_files/`: Generated parquet files
- `/pages/`: Evidence dashboard pages
- `flatten_parquet_files.sh`: Script to flatten parquet file structure

## Troubleshooting

If you encounter issues with SQL queries, check the [Evidence SQL Wrapping Solution](cci:7://file:///Users/shyam.n/dsa/aibi/sources/myclickhouse/describe_table.sql:0:0-0:0) memory for details on how to work around Evidence's SQL query wrapping.

## Learning More

- [Evidence Docs](https://docs.evidence.dev/)
- [ClickHouse Docs](https://clickhouse.com/docs/)
- [Parquet Format](https://parquet.apache.org/)
- [DuckDB](https://duckdb.org/) (used by Evidence to query parquet files)

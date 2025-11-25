# Troubleshooting Guide

## ClickHouse Connection Issues

### Connection String Format

If you're having issues connecting to ClickHouse, try using the connection string format in the URL:

```yaml
name: business_intelligence
type: clickhouse
options:
  url: http://username:password@host:port/database
```

This format embeds the username, password, and database directly in the URL, which is sometimes required by the ClickHouse connector.

### SQL Query Wrapping

Evidence wraps user SQL queries in a `SELECT * FROM (your_query)` statement, which can cause issues with certain SQL commands like `DESCRIBE TABLE`.

#### Solution for Regular SELECT Queries

Wrap your queries in a subquery:

```sql
SELECT * FROM (
    SELECT * FROM business_intelligence.integrated_orders LIMIT 5
) AS sample_data
```

#### Solution for Special Commands

Replace special commands with equivalent SELECT queries:

```sql
-- Instead of: DESCRIBE TABLE business_intelligence.integrated_orders
SELECT 
    name AS column_name,
    type AS data_type,
    default_expression,
    comment
FROM system.columns
WHERE database = 'business_intelligence' AND table = 'integrated_orders'
```

## Parquet Files Issues

### Missing Tables

If you're getting "Table does not exist" errors when querying parquet files, make sure:

1. The parquet files are in the correct location (`/sources/parquet_files/`)
2. The flattening script has been run (`npm run flatten`)
3. The table names in your SQL queries match the parquet file names (without the .parquet extension)

### Schema Issues

If you're getting schema-related errors:

1. Check that the schema files (.schema.json) exist alongside the parquet files
2. Make sure the schema files correctly describe the data in the parquet files
3. Try regenerating the parquet files with `npm run sources:all`

## Deployment Issues

### Missing Dependencies

If you get dependency-related errors after deploying:

```bash
npm install
```

### Path Issues

If paths are incorrect after deployment, update the directory paths in:

1. `/sources/parquet_files/connection.yaml`
2. `/.evidence/sources.yaml`

### Permission Issues

Make sure the scripts have execute permissions:

```bash
chmod +x *.sh
```

## Getting Help

If you continue to experience issues:

1. Check the [Evidence documentation](https://docs.evidence.dev/)
2. Check the [ClickHouse documentation](https://clickhouse.com/docs/)
3. Open an issue in the project repository

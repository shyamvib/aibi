---
title: ClickHouse Data (Parquet View)
---

# ClickHouse Data from Parquet Files

This page displays data from the ClickHouse database using parquet files.

## Monthly Orders Analysis

```sql monthly_orders
SELECT * FROM monthly_orders
```

<DataTable 
  data={monthly_orders} 
  title="Monthly Orders" 
/>

<BarChart
  data={monthly_orders}
  title="Monthly Order Count"
  x=month
  y=order_count
/>

<LineChart
  data={monthly_orders}
  title="Monthly Sales Trend"
  x=month
  y=total_amount
/>

## Integrated Orders Table Structure

```sql describe_table
SELECT * FROM describe_table
```

<DataTable 
  data={describe_table} 
  title="Integrated Orders Table Structure" 
/>

## Sample Data

```sql sample_data
SELECT * FROM sample_data
```

<DataTable 
  data={sample_data} 
  title="Sample Data from Integrated Orders" 
  search=true
/>

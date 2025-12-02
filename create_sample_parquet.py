#!/usr/bin/env python3
import pandas as pd
import os
import numpy as np
from datetime import datetime, timedelta

def create_directory(path):
    """Create directory if it doesn't exist"""
    if not os.path.exists(path):
        os.makedirs(path)

def create_monthly_orders():
    """Create sample monthly orders data"""
    # Create a date range for the last 12 months
    end_date = datetime.now()
    start_date = end_date - timedelta(days=365)
    
    # Create monthly data
    months = pd.date_range(start=start_date, end=end_date, freq='M')
    
    # Generate sample data
    data = {
        'month': [m.strftime('%Y-%m') for m in months],
        'order_count': np.random.randint(100, 1000, size=len(months)),
        'total_amount': np.random.uniform(10000, 50000, size=len(months)),
        'avg_order_value': np.random.uniform(50, 200, size=len(months))
    }
    
    # Create DataFrame
    df = pd.DataFrame(data)
    
    # Create directory
    dir_path = 'sources/parquet_files/monthly_orders'
    create_directory(dir_path)
    
    # Save as parquet
    df.to_parquet(f'{dir_path}/monthly_orders.parquet', index=False)
    
    # Also save flattened version
    df.to_parquet('sources/parquet_files/monthly_orders.parquet', index=False)
    
    # Create schema file
    schema = {
        "fields": [
            {"name": "month", "type": "string"},
            {"name": "order_count", "type": "integer"},
            {"name": "total_amount", "type": "number"},
            {"name": "avg_order_value", "type": "number"}
        ]
    }
    
    # Save schema as JSON
    import json
    with open(f'{dir_path}/monthly_orders.schema.json', 'w') as f:
        json.dump(schema, f, indent=2)
    
    return df

def create_sample_data():
    """Create sample order data"""
    # Generate sample data
    n_rows = 5
    data = {
        'order_id': [f'ORD-{i:04d}' for i in range(1, n_rows + 1)],
        'customer_id': [f'CUST-{i:04d}' for i in range(1, n_rows + 1)],
        'order_date': [(datetime.now() - timedelta(days=i*7)).strftime('%Y-%m-%d') for i in range(n_rows)],
        'total': np.random.uniform(50, 500, size=n_rows),
        'status': np.random.choice(['Completed', 'Processing', 'Shipped'], size=n_rows)
    }
    
    # Create DataFrame
    df = pd.DataFrame(data)
    
    # Create directory
    dir_path = 'sources/parquet_files/sample_data'
    create_directory(dir_path)
    
    # Save as parquet
    df.to_parquet(f'{dir_path}/sample_data.parquet', index=False)
    
    # Also save flattened version
    df.to_parquet('sources/parquet_files/sample_data.parquet', index=False)
    
    # Create schema file
    schema = {
        "fields": [
            {"name": "order_id", "type": "string"},
            {"name": "customer_id", "type": "string"},
            {"name": "order_date", "type": "string"},
            {"name": "total", "type": "number"},
            {"name": "status", "type": "string"}
        ]
    }
    
    # Save schema as JSON
    import json
    with open(f'{dir_path}/sample_data.schema.json', 'w') as f:
        json.dump(schema, f, indent=2)
    
    return df

def create_describe_table():
    """Create sample table description"""
    # Generate sample data
    data = {
        'column_name': ['order_id', 'customer_id', 'order_date', 'total', 'status'],
        'data_type': ['String', 'String', 'Date', 'Float64', 'String'],
        'default_expression': ['', '', '', '', ''],
        'comment': ['Order identifier', 'Customer identifier', 'Date of order', 'Order total amount', 'Order status']
    }
    
    # Create DataFrame
    df = pd.DataFrame(data)
    
    # Create directory
    dir_path = 'sources/parquet_files/describe_table'
    create_directory(dir_path)
    
    # Save as parquet
    df.to_parquet(f'{dir_path}/describe_table.parquet', index=False)
    
    # Also save flattened version
    df.to_parquet('sources/parquet_files/describe_table.parquet', index=False)
    
    # Create schema file
    schema = {
        "fields": [
            {"name": "column_name", "type": "string"},
            {"name": "data_type", "type": "string"},
            {"name": "default_expression", "type": "string"},
            {"name": "comment", "type": "string"}
        ]
    }
    
    # Save schema as JSON
    import json
    with open(f'{dir_path}/describe_table.schema.json', 'w') as f:
        json.dump(schema, f, indent=2)
    
    return df

def create_show_tables():
    """Create sample show tables data"""
    # Generate sample data
    data = {
        'name': ['integrated_orders']
    }
    
    # Create DataFrame
    df = pd.DataFrame(data)
    
    # Create directory
    dir_path = 'sources/parquet_files/show_tables'
    create_directory(dir_path)
    
    # Save as parquet
    df.to_parquet(f'{dir_path}/show_tables.parquet', index=False)
    
    # Also save flattened version
    df.to_parquet('sources/parquet_files/show_tables.parquet', index=False)
    
    # Create schema file
    schema = {
        "fields": [
            {"name": "name", "type": "string"}
        ]
    }
    
    # Save schema as JSON
    import json
    with open(f'{dir_path}/show_tables.schema.json', 'w') as f:
        json.dump(schema, f, indent=2)
    
    return df

if __name__ == "__main__":
    print("Creating sample parquet files...")
    
    # Create main directory
    create_directory('sources/parquet_files')
    
    # Create sample data
    monthly_orders = create_monthly_orders()
    sample_data = create_sample_data()
    describe_table = create_describe_table()
    show_tables = create_show_tables()
    
    print("Sample parquet files created successfully!")
    print(f"Monthly orders: {len(monthly_orders)} rows")
    print(f"Sample data: {len(sample_data)} rows")
    print(f"Describe table: {len(describe_table)} rows")
    print(f"Show tables: {len(show_tables)} rows")

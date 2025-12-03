// DuckDB configuration for Evidence
export default {
  // Increase timeout to 120 seconds (default is 30)
  timeout: 120000,
  
  // Increase memory limit if needed
  memory_limit: '4GB',
  
  // Other DuckDB options
  options: {
    // Allow parallel execution
    enable_external_access: true,
    enable_object_cache: true
  }
}

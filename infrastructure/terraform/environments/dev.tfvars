# Development environment configuration

project_name = "mathfacts"
environment  = "dev"
location     = "canadacentral" # Canada Central region

tags = {
  Project     = "MathFacts"
  Environment = "dev"
  ManagedBy   = "Terraform"
  Owner       = "Development Team"
  DataResidency = "Canada"
}

# Security: CORS configuration
allowed_origins = ["*"] # Will be restricted after Static Web App deployment

# Security: Management access IPs (add your IPs for storage/key vault access)
# management_ip_addresses = ["your.ip.address.here"]

# B2C configuration (fill in after creating B2C tenant)
# b2c_tenant_name = "your-tenant-name"
# b2c_client_id   = "your-client-id"
# b2c_policy_name = "B2C_1_signupsignin"

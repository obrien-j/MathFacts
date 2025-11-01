# Production environment configuration

project_name = "mathfacts"
environment  = "prod"
location     = "canadacentral" # Canada Central region

tags = {
  Project     = "MathFacts"
  Environment = "prod"
  ManagedBy   = "Terraform"
  Owner       = "Production Team"
  DataResidency = "Canada"
}

# Security: CORS configuration (restrict to your domain)
# allowed_origins = ["https://your-domain.com", "https://www.your-domain.com"]

# Security: Management access IPs
# management_ip_addresses = ["your.management.ip.here"]

# B2C configuration (fill in after creating B2C tenant)
# b2c_tenant_name = "your-prod-tenant-name"
# b2c_client_id   = "your-prod-client-id"
# b2c_policy_name = "B2C_1_signupsignin"

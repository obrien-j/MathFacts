# Development environment configuration

project_name = "mathfacts"
environment  = "dev"
location     = "canadacentral" # Canada Central region

tags = {
  Project     = "MathFacts"
  Environment = "dev"
  ManagedBy   = "Terraform"
  Owner       = "boardom_ca"
  DataResidency = "Canada"
}

# Security: CORS configuration
allowed_origins = ["https://red-plant-077d31610.3.azurestaticapps.net"] # Will be restricted after Static Web App deployment

# Security: Management access IPs (add your IPs for storage/key vault access)
# management_ip_addresses = ["184.147.198.222"]

# Microsoft Entra External ID configuration
entra_tenant_id = "f13f4b52-a95e-4af4-8c6d-373a94bfc94c"
entra_client_id = "1dfb7e4c-d266-4161-9d7b-e918339269b2"
entra_authority = "https://login.microsoftonline.com/f13f4b52-a95e-4af4-8c6d-373a94bfc94c"

# Variables for MathFacts infrastructure

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "mathfacts"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region for resources (Canada regions only)"
  type        = string
  default     = "canadacentral"
  
  validation {
    condition     = can(regex("^canada(central|east)$", var.location))
    error_message = "Location must be a Canadian region: canadacentral or canadaeast"
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "MathFacts"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# Azure AD B2C variables (optional, configure after B2C setup)
variable "b2c_tenant_name" {
  description = "Azure AD B2C tenant name"
  type        = string
  default     = ""
  sensitive   = false
}

variable "b2c_client_id" {
  description = "Azure AD B2C client ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "b2c_policy_name" {
  description = "Azure AD B2C sign-up/sign-in policy name"
  type        = string
  default     = "B2C_1_signupsignin"
}

# Security variables
variable "allowed_origins" {
  description = "Allowed CORS origins for Function App"
  type        = list(string)
  default     = ["*"] # Restrict to specific domains in production
}

variable "management_ip_addresses" {
  description = "IP addresses allowed to access storage and key vault for management"
  type        = list(string)
  default     = [] # Add your IP addresses here
}

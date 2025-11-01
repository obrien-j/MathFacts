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

# Microsoft Entra External ID variables (for customer authentication)
variable "entra_tenant_id" {
  description = "Microsoft Entra External ID tenant ID"
  type        = string
  default     = ""
  sensitive   = false
}

variable "entra_client_id" {
  description = "Microsoft Entra External ID application (client) ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "entra_authority" {
  description = "Microsoft Entra External ID authority URL"
  type        = string
  default     = ""
  sensitive   = false
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

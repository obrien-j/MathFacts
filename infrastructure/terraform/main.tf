# Main Terraform configuration for MathFacts Azure infrastructure

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Optional: Configure remote state storage (recommended for team collaboration)
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstatemathfacts"
    container_name       = "tfstate"
    key                  = "mathfacts.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-${var.environment}-rg"
  location = var.location
  
  tags = var.tags
}

# Storage Account (for Table Storage and Functions)
resource "azurerm_storage_account" "main" {
  name                     = "${lower(replace(var.project_name, "-", ""))}${var.environment}sa"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  # Security: Require HTTPS for all connections
  https_traffic_only_enabled = true
  
  # Security: Use TLS 1.2 minimum
  min_tls_version = "TLS1_2"
  
  # Security: Disable public blob access by default
  allow_nested_items_to_be_public = false
  
  # Security: Enable infrastructure encryption
  infrastructure_encryption_enabled = true
  
  # Security: Network rules (restrict to Azure services by default)
  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = var.management_ip_addresses # Add your IPs for management access
    virtual_network_subnet_ids = []
  }
  
  tags = var.tags
}

# Table Storage for user progress data
resource "azurerm_storage_table" "user_progress" {
  name                 = "userprogress"
  storage_account_name = azurerm_storage_account.main.name
}

# Application Insights for monitoring
resource "azurerm_application_insights" "main" {
  name                = "${var.project_name}-${var.environment}-ai"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
  
  tags = var.tags
}

# App Service Plan for Azure Functions (Consumption plan)
resource "azurerm_service_plan" "functions" {
  name                = "${var.project_name}-${var.environment}-asp"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = "Y1" # Y1 = Consumption (free tier)
  
  tags = var.tags
}

# Azure Functions App
resource "azurerm_linux_function_app" "main" {
  name                       = "${var.project_name}-${var.environment}-func"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  service_plan_id            = azurerm_service_plan.functions.id
  storage_account_name       = azurerm_storage_account.main.name
  storage_account_access_key = azurerm_storage_account.main.primary_access_key
  
  # Security: Enable HTTPS only
  https_only = true
  
  # Security: Enable managed identity
  identity {
    type = "SystemAssigned"
  }
  
  site_config {
    application_stack {
      node_version = "18" # Or use python_version = "3.11" for Python
    }
    
    # Security: CORS configuration (restrict in production)
    cors {
      allowed_origins     = var.allowed_origins
      support_credentials = true
    }
    
    # Security: Minimum TLS version
    minimum_tls_version = "1.2"
    
    # Security: Disable FTP
    ftps_state = "Disabled"
    
    # Security: HTTP2 enabled
    http2_enabled = true
  }
  
  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"       = "node" # or "python"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.main.instrumentation_key
    "TABLE_STORAGE_CONNECTION"       = azurerm_storage_account.main.primary_connection_string
    "AzureWebJobsStorage"            = azurerm_storage_account.main.primary_connection_string
    
    # Security: Disable remote debugging
    "REMOTE_DEBUGGING_ENABLED" = "false"
    
    # Azure AD B2C settings (configure these after B2C setup)
    # "B2C_TENANT_NAME"              = var.b2c_tenant_name
    # "B2C_CLIENT_ID"                = var.b2c_client_id
    # "B2C_POLICY_NAME"              = var.b2c_policy_name
  }
  
  tags = var.tags
}

# Grant Function App access to Storage Account using Managed Identity
resource "azurerm_role_assignment" "function_storage_table" {
  scope                = azurerm_storage_account.main.id
  role_definition_name = "Storage Table Data Contributor"
  principal_id         = azurerm_linux_function_app.main.identity[0].principal_id
}

# Static Web App for Flutter web hosting
resource "azurerm_static_web_app" "main" {
  name                = "${var.project_name}-${var.environment}-swa"
  location            = "Central US" # Static Web Apps don't support Canada yet, but data stays regional
  resource_group_name = azurerm_resource_group.main.name
  sku_tier            = "Free"
  sku_size            = "Free"
  
  tags = var.tags
}

# Security: Key Vault for storing secrets
resource "azurerm_key_vault" "main" {
  name                       = "${var.project_name}-${var.environment}-kv"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  
  # Security: Soft delete enabled (cannot be disabled once enabled)
  soft_delete_retention_days = 7
  purge_protection_enabled   = false # Enable in production
  
  # Security: Network ACLs
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = var.management_ip_addresses # Add your IPs for management
  }
  
  # Security: Enable RBAC instead of access policies
  enable_rbac_authorization = true
  
  tags = var.tags
}

# Grant Function App access to Key Vault
resource "azurerm_role_assignment" "function_keyvault_secrets" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_function_app.main.identity[0].principal_id
}

# Data source to get current Azure client configuration
data "azurerm_client_config" "current" {}

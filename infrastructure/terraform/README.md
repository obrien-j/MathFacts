# MathFacts Infrastructure - Terraform

This directory contains Terraform configuration for deploying the MathFacts app infrastructure to Azure.

## Architecture

- **Azure Static Web Apps**: Hosts the Flutter web application
- **Azure Functions (Consumption Plan)**: Serverless backend API
- **Azure Table Storage**: Stores user progress data
- **Azure Application Insights**: Monitoring and telemetry
- **Azure AD B2C**: User authentication (configured separately)

## Prerequisites

1. **Install Terraform**: [Download here](https://www.terraform.io/downloads)
   ```powershell
   # Or use Chocolatey on Windows
   choco install terraform
   ```

2. **Install Azure CLI**: [Download here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
   ```powershell
   # Or use winget
   winget install Microsoft.AzureCLI
   ```

3. **Login to Azure**:
   ```powershell
   az login
   az account set --subscription "Your Subscription Name or ID"
   ```

## Quick Start

### 1. Initialize Terraform
```powershell
cd infrastructure/terraform
terraform init
```

### 2. Plan Deployment (Preview changes)
```powershell
# For dev environment
terraform plan -var-file="environments/dev.tfvars"

# For prod environment
terraform plan -var-file="environments/prod.tfvars"
```

### 3. Deploy Infrastructure
```powershell
# Deploy to dev
terraform apply -var-file="environments/dev.tfvars"

# Deploy to prod
terraform apply -var-file="environments/prod.tfvars"
```

### 4. View Outputs
```powershell
terraform output
terraform output -json

# Get specific output (e.g., function app URL)
terraform output function_app_url
```

### 5. Destroy Infrastructure (when needed)
```powershell
terraform destroy -var-file="environments/dev.tfvars"
```

## File Structure

```
infrastructure/terraform/
├── main.tf              # Main infrastructure resources
├── variables.tf         # Variable definitions
├── outputs.tf           # Output definitions
├── environments/
│   ├── dev.tfvars      # Dev environment variables
│   └── prod.tfvars     # Prod environment variables
└── modules/             # Custom modules (future use)
```

## Configuration

### Environment Variables

Edit `environments/dev.tfvars` or `environments/prod.tfvars` to customize:

- `project_name`: Name prefix for all resources
- `environment`: Environment name (dev, staging, prod)
- `location`: Azure region (eastus, westus, etc.)
- `tags`: Resource tags for organization

### Azure AD B2C Setup

After creating your B2C tenant:

1. Create a B2C tenant in Azure Portal
2. Register an application
3. Create sign-up/sign-in user flow
4. Update `environments/*.tfvars` with B2C values:
   ```hcl
   b2c_tenant_name = "your-tenant-name"
   b2c_client_id   = "your-client-id"
   b2c_policy_name = "B2C_1_signupsignin"
   ```

## Remote State (Optional but Recommended)

For team collaboration, store Terraform state in Azure:

1. Create a storage account for state:
   ```powershell
   az group create --name terraform-state-rg --location eastus
   az storage account create --name tfstatemathfacts --resource-group terraform-state-rg --sku Standard_LRS
   az storage container create --name tfstate --account-name tfstatemathfacts
   ```

2. Uncomment the `backend "azurerm"` block in `main.tf`

3. Initialize with backend:
   ```powershell
   terraform init -backend-config="storage_account_name=tfstatemathfacts"
   ```

## Cost Estimate

**Dev Environment**:
- Static Web App (Free tier): $0/month
- Azure Functions (Consumption): ~$0/month (1M free executions)
- Table Storage: ~$0.10-1/month
- Application Insights: ~$0-2/month (5GB free)
- **Total: ~$0-3/month**

**Prod Environment**:
- Similar to dev, scales based on usage
- Monitor with Azure Cost Management

## Useful Commands

```powershell
# Format Terraform files
terraform fmt

# Validate configuration
terraform validate

# Show current state
terraform show

# List resources
terraform state list

# Get specific resource details
terraform state show azurerm_linux_function_app.main

# Refresh state
terraform refresh -var-file="environments/dev.tfvars"
```

## Next Steps

1. Deploy infrastructure: `terraform apply -var-file="environments/dev.tfvars"`
2. Note the output URLs (function app, static web app)
3. Set up Azure Functions code in `functions/` directory
4. Configure GitHub Actions for CI/CD deployment
5. Set up Azure AD B2C for authentication

## Troubleshooting

**Issue**: "Error: A resource with the ID already exists"
- **Solution**: Resource names must be globally unique. Change `project_name` in tfvars.

**Issue**: "Insufficient permissions"
- **Solution**: Ensure you have Contributor role on the subscription.

**Issue**: "Provider not found"
- **Solution**: Run `terraform init` again.

## Support

For issues or questions:
- Check [Terraform Azure Provider docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- Review [Azure Functions docs](https://docs.microsoft.com/en-us/azure/azure-functions/)
- Open an issue in the GitHub repo

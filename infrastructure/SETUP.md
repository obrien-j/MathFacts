# MathFacts Azure Infrastructure - Manual Setup Guide

This guide walks you through the initial manual deployment of the MathFacts infrastructure to Azure.

## Prerequisites

### 1. Install Required Tools

**Azure CLI** (Required):
```powershell
# Install via winget
winget install Microsoft.AzureCLI

# Or download from: https://aka.ms/installazurecliwindows
```

**Terraform** (Required):
```powershell
# Install via Chocolatey
choco install terraform

# Or download from: https://www.terraform.io/downloads
```

**Verify installations**:
```powershell
az --version
terraform --version
```

### 2. Azure Subscription

You need:
- ✅ An Azure subscription (free trial works: https://azure.microsoft.com/free/)
- ✅ Contributor access to the subscription
- ✅ Ability to create resources in Canada Central region

---

## Step 1: Azure Login & Subscription Setup

### Login to Azure
```powershell
# Login interactively
az login

# This will open a browser for authentication
# Select your account and complete the login
```

### List and Select Your Subscription
```powershell
# List all subscriptions
az account list --output table

# Set the subscription you want to use
az account set --subscription "Your Subscription Name or ID"

# Verify the active subscription
az account show --output table
```

### Get Your Subscription ID (you'll need this later)
```powershell
az account show --query id --output tsv
```

**Save this subscription ID** - you'll need it for GitHub Actions later.

---

## Step 2: Create Terraform State Storage (Recommended)

Terraform needs to store its state file. For production use, store it in Azure (not locally).

```powershell
# Set variables
$RESOURCE_GROUP = "terraform-state-rg"
$STORAGE_ACCOUNT = "tfstatemathfacts"
$CONTAINER_NAME = "tfstate"
$LOCATION = "canadacentral"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create storage account
az storage account create `
  --name $STORAGE_ACCOUNT `
  --resource-group $RESOURCE_GROUP `
  --location $LOCATION `
  --sku Standard_LRS `
  --encryption-services blob `
  --https-only true `
  --min-tls-version TLS1_2

# Get storage account key
$ACCOUNT_KEY = az storage account keys list `
  --resource-group $RESOURCE_GROUP `
  --account-name $STORAGE_ACCOUNT `
  --query '[0].value' `
  --output tsv

# Create blob container for state
az storage container create `
  --name $CONTAINER_NAME `
  --account-name $STORAGE_ACCOUNT `
  --account-key $ACCOUNT_KEY
```

### Configure Terraform Backend

Uncomment the backend block in `infrastructure/terraform/main.tf`:

```hcl
backend "azurerm" {
  resource_group_name  = "terraform-state-rg"
  storage_account_name = "tfstatemathfacts"
  container_name       = "tfstate"
  key                  = "mathfacts.terraform.tfstate"
}
```

---

## Step 3: Configure Your IP Address (Optional but Recommended)

For security, storage and Key Vault block all public access by default. To access them for management, add your IP:

### Get Your Public IP
```powershell
# Get your public IP
$MY_IP = (Invoke-WebRequest -Uri "https://api.ipify.org").Content
Write-Host "Your public IP: $MY_IP"
```

### Add IP to Configuration

Edit `infrastructure/terraform/environments/dev.tfvars`:

```hcl
# Security: Management access IPs
management_ip_addresses = ["YOUR_IP_HERE/32"]  # Replace with your IP
```

**Note**: If you skip this, you can still deploy, but you won't be able to directly access Storage or Key Vault from your local machine.

---

## Step 4: Review and Customize Configuration

### Review Dev Environment Settings

Edit `infrastructure/terraform/environments/dev.tfvars`:

```hcl
project_name = "mathfacts"  # Change if you want different resource names
environment  = "dev"
location     = "canadacentral"  # Or "canadaeast"

# Verify these settings
tags = {
  Project       = "MathFacts"
  Environment   = "dev"
  ManagedBy     = "Terraform"
  Owner         = "Your Name"
  DataResidency = "Canada"
}

# CORS: Keep as * for now, will restrict after deployment
allowed_origins = ["*"]
```

### Verify Storage Account Name Uniqueness

Storage account names must be globally unique. If `mathfactsdevsa` is taken, change `project_name` in the tfvars file.

---

## Step 5: Initialize Terraform

Navigate to the terraform directory and initialize:

```powershell
# Navigate to terraform directory
cd infrastructure/terraform

# Initialize Terraform (downloads providers, sets up backend)
terraform init

# If using remote backend, you'll see: "Successfully configured the backend"
```

**Expected output**:
```
Initializing the backend...
Successfully configured the backend "azurerm"!

Initializing provider plugins...
- Finding hashicorp/azurerm versions matching "~> 3.0"...
- Installing hashicorp/azurerm v3.x.x...

Terraform has been successfully initialized!
```

---

## Step 6: Plan the Deployment (Preview Changes)

Preview what Terraform will create:

```powershell
# Run plan with dev environment
terraform plan -var-file="environments/dev.tfvars"
```

**Review the output carefully**. You should see:
- ✅ ~10-12 resources to be created
- ✅ Resource group: `mathfacts-dev-rg`
- ✅ Storage account: `mathfactsdevsa`
- ✅ Function App: `mathfacts-dev-func`
- ✅ Static Web App: `mathfacts-dev-swa`
- ✅ Key Vault: `mathfacts-dev-kv`
- ✅ Application Insights: `mathfacts-dev-ai`
- ✅ Table Storage: `userprogress`

**Look for errors**:
- ❌ Name conflicts (storage account name taken)
- ❌ Permission issues
- ❌ Region issues

---

## Step 7: Deploy Infrastructure

If the plan looks good, apply it:

```powershell
# Apply the configuration
terraform apply -var-file="environments/dev.tfvars"

# Terraform will show the plan again and ask for confirmation
# Type: yes
```

**This will take 3-5 minutes.** Terraform will:
1. Create resource group
2. Create storage account and table
3. Create Key Vault
4. Create Application Insights
5. Create App Service Plan
6. Create Function App with Managed Identity
7. Assign RBAC roles
8. Create Static Web App

**Expected output**:
```
Apply complete! Resources: 12 added, 0 changed, 0 destroyed.

Outputs:

function_app_url = "https://mathfacts-dev-func.azurewebsites.net"
static_web_app_url = "https://[random].azurestaticapps.net"
storage_account_name = "mathfactsdevsa"
...
```

---

## Step 8: Verify Deployment

### View Outputs
```powershell
# View all outputs
terraform output

# View specific output
terraform output function_app_url
terraform output static_web_app_url

# Get sensitive output (like connection string)
terraform output -raw table_storage_connection_string
```

### Verify in Azure Portal

1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to resource group: `mathfacts-dev-rg`
3. Verify all resources are created:
   - Storage account
   - Function App
   - Static Web App
   - Key Vault
   - Application Insights

### Test Function App

```powershell
# Get Function App URL
$FUNCTION_URL = terraform output -raw function_app_url

# Test the endpoint (will return 404 until we deploy function code)
Invoke-WebRequest -Uri "$FUNCTION_URL/api/health" -Method GET
```

**Note**: This will fail with 404 until we deploy function code - that's expected!

---

## Step 9: Save Important Values

Create a file to save important values for later use:

```powershell
# Create a local file with outputs (DO NOT COMMIT THIS)
terraform output -json > outputs.json

# Or save specific values
$FUNCTION_APP = terraform output -raw function_app_name
$STATIC_WEB_APP = terraform output -raw static_web_app_name
$STORAGE_ACCOUNT = terraform output -raw storage_account_name
$RESOURCE_GROUP = terraform output -raw resource_group_name

Write-Host "Resource Group: $RESOURCE_GROUP"
Write-Host "Function App: $FUNCTION_APP"
Write-Host "Static Web App: $STATIC_WEB_APP"
Write-Host "Storage Account: $STORAGE_ACCOUNT"
```

**Add `outputs.json` to `.gitignore`** (already done in infrastructure/.gitignore).

---

## Step 10: Configure CORS for Function App

After deployment, update CORS to restrict to your Static Web App:

```powershell
# Get Static Web App URL
$SWA_URL = terraform output -raw static_web_app_url

# Update CORS in dev.tfvars
# allowed_origins = ["https://YOUR-SWA-URL.azurestaticapps.net"]

# Re-apply
terraform apply -var-file="environments/dev.tfvars"
```

---

## Step 11: Set Up Microsoft Entra External ID (Authentication)

### Create External ID Tenant (If Not Done)

If you haven't created the External ID tenant yet:

1. Go to [Azure Portal](https://portal.azure.com)
2. Search for "Microsoft Entra External ID"
3. Click "Create" → "External ID for customers"
4. Fill in:
   - **Tenant name**: MathFacts
   - **Domain name**: mathfacts (or unique name)
   - **Location**: Canada
5. Click "Review + Create"
6. Wait 2 minutes for creation
7. **Copy the Tenant ID** from the Overview page

### Register Application (Manual - Required)

**Important**: For External ID for customers tenants, app registration must be done through the Azure Portal.

1. **Switch to your External ID tenant**:
   - Click your profile icon (top right)
   - Click "Switch directory"
   - Select your External ID tenant (Tenant ID: `f13f4b52-a95e-4af4-8c6d-373a94bfc94c`)

2. **Navigate to App registrations**:
   - Search for "Microsoft Entra ID" or "Entra ID"
   - Click "App registrations"
   - Click "New registration"

3. **Configure the registration**:
   - **Name**: `MathFacts Web App`
   - **Supported account types**: "Accounts in this organizational directory only"
   - **Platform**: Select "Single-page application (SPA)"
   - **Redirect URI**: `https://red-plant-077d31610.3.azurestaticapps.net/`
   - Click "Register"

4. **Save the Client ID**:
   - Copy the **Application (client) ID** from the Overview page
   - You'll need this for configuration

5. **Add localhost redirect** (for development):
   - Go to "Authentication"
   - Under "Single-page application", click "Add URI"
   - Add: `http://localhost:3000/`
   - Click "Save"

6. **Enable tokens**:
   - Still in "Authentication"
   - Under "Implicit grant and hybrid flows":
     - ✅ Check "Access tokens"
     - ✅ Check "ID tokens"
   - Click "Save"

7. **Configure API permissions**:
   - Go to "API permissions"
   - The app already has `User.Read` - this is sufficient
   - (Optional) Add additional permissions if needed:
     - Click "Add a permission" → "Microsoft Graph" → "Delegated permissions"
     - Add: `email`, `profile`, `openid` (usually included by default)
   - Click "Add permissions"

8. **Grant admin consent** (Required):
   - Click "Grant admin consent for [Your Tenant Name]"
   - Click "Yes"
   - Verify green checkmarks ✅ appear next to all permissions

### Update Terraform Configuration

Edit `environments/dev.tfvars` with the values from the portal:

```hcl
# Microsoft Entra External ID configuration
entra_tenant_id = "f13f4b52-a95e-4af4-8c6d-373a94bfc94c"
entra_client_id = "YOUR-CLIENT-ID-FROM-PORTAL"  # From step 4 above
entra_authority = "https://login.microsoftonline.com/f13f4b52-a95e-4af4-8c6d-373a94bfc94c"
```

### Enable Entra in Function App

Uncomment the Entra settings in `infrastructure/terraform/main.tf` (around line 175):

```hcl
# Microsoft Entra External ID settings
"ENTRA_TENANT_ID"  = var.entra_tenant_id
"ENTRA_CLIENT_ID"  = var.entra_client_id
"ENTRA_AUTHORITY"  = var.entra_authority
```

Then re-apply Terraform:

```powershell
terraform apply -var-file="environments/dev.tfvars"
```

### Verify Setup

1. In Azure Portal, navigate to your External ID tenant
2. Go to "App registrations" → "MathFacts Web App"
3. Verify:
   - ✅ Redirect URIs configured
   - ✅ API permissions granted with admin consent
   - ✅ Client ID matches your tfvars file

**Note**: The service principal (Enterprise App) is automatically created when you register the app - no manual action needed.

---

## Troubleshooting

### Issue: "Storage account name already exists"

**Solution**: Change `project_name` in `dev.tfvars` to something unique:
```hcl
project_name = "mathfacts-johndoe"  # Add your initials or unique suffix
```

### Issue: "Insufficient permissions"

**Solution**: Verify you have Contributor role:
```powershell
az role assignment list --assignee $(az account show --query user.name -o tsv) --query "[?roleDefinitionName=='Contributor']"
```

### Issue: "Region not available"

**Solution**: Try `canadaeast` instead of `canadacentral`:
```hcl
location = "canadaeast"
```

### Issue: "Backend configuration error"

**Solution**: If not using remote backend yet, comment out the backend block in `main.tf` and re-run `terraform init`.

### Issue: "Cannot access storage account or Key Vault"

**Solution**: Add your IP address to `management_ip_addresses` in tfvars and re-apply.

---

## Next Steps

Now that infrastructure is deployed:

1. ✅ **Create Azure Functions code** - Backend API implementation
2. ✅ **Integrate B2C in Flutter app** - User authentication
3. ✅ **Deploy Function App code** - Upload API functions
4. ✅ **Deploy Static Web App** - Upload Flutter web build
5. ✅ **Set up GitHub Actions** - Automate future deployments

---

## Useful Commands Reference

```powershell
# View current state
terraform show

# List all resources
terraform state list

# View specific resource
terraform state show azurerm_linux_function_app.main

# Refresh state from Azure
terraform refresh -var-file="environments/dev.tfvars"

# Destroy everything (BE CAREFUL!)
terraform destroy -var-file="environments/dev.tfvars"

# Format Terraform files
terraform fmt -recursive

# Validate configuration
terraform validate
```

---

## Cost Monitoring

Monitor your costs in Azure Portal:

1. Go to [Cost Management](https://portal.azure.com/#view/Microsoft_Azure_CostManagement/Menu/~/overview)
2. Select your subscription
3. View costs by resource group: `mathfacts-dev-rg`

**Expected costs**: $0-3/month (mostly free tier)

---

## Security Checklist

After deployment:

- [ ] Storage account: Public access blocked ✅
- [ ] Key Vault: Network rules enabled ✅
- [ ] Function App: HTTPS only ✅
- [ ] Function App: Managed Identity enabled ✅
- [ ] CORS: Will be restricted after Static Web App deployment ⏳
- [ ] Azure AD B2C: Configured and tested ⏳
- [ ] Secrets: Stored in Key Vault only ✅

---

## Support

- **Terraform Docs**: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
- **Azure Functions**: https://docs.microsoft.com/en-us/azure/azure-functions/
- **Azure AD B2C**: https://docs.microsoft.com/en-us/azure/active-directory-b2c/

**Questions?** Review `ARCHITECTURE.md` for detailed security architecture.

---

**Last Updated**: October 31, 2025  
**Version**: 1.0

# Microsoft Entra External ID Setup for MathFacts

## Quick Reference: Manual vs Terraform

### What You MUST Do Manually
❌ **Create the External ID Tenant** - Cannot be automated via Terraform
   - Go to Azure Portal → "Microsoft Entra External ID" → Create
   - Choose "External ID for customers"
   - Location: Canada
   - Copy the **Tenant ID** after creation

### What You CAN Do with Terraform
✅ **App Registration** - Fully automated
✅ **API Permissions** - Configured in code
✅ **Redirect URIs** - Managed in Terraform
✅ **Service Principal** - Auto-created

---

## Recommended Workflow

### Step 1: Create Tenant (Manual - One Time)
```
1. Azure Portal → Search "Microsoft Entra External ID"
2. Click "Create" → "External ID for customers"
3. Tenant name: MathFacts
4. Domain: mathfacts (or unique name)
5. Location: Canada
6. Create (takes 2 minutes)
7. Copy Tenant ID from Overview page
```

### Step 2: Let Terraform Handle the Rest

**Edit `environments/dev.tfvars`:**
```hcl
entra_tenant_id = "12345678-1234-1234-1234-123456789abc"  # Your tenant ID
```

**Run Terraform:**
```powershell
cd infrastructure/terraform
terraform init -upgrade  # Install azuread provider
terraform apply -var-file="environments/dev.tfvars"
```

**Get your Client ID:**
```powershell
terraform output entra_app_client_id
```

### Step 3: Grant Admin Consent (Manual - One Time)

This is the only post-Terraform manual step:

```
1. Go to Azure Portal → Your Entra External ID tenant
2. Navigate to "App registrations"
3. Find "mathfacts-dev-web"
4. Click "API permissions"
5. Click "Grant admin consent for [Tenant]"
6. Click "Yes"
```

Done! ✅

---

## What Terraform Creates

When you provide `entra_tenant_id` in tfvars, Terraform automatically creates:

### App Registration
- **Name**: `mathfacts-dev-web`
- **Type**: Single-page application (SPA)
- **Redirect URIs**: 
  - Your Static Web App URL
  - `http://localhost:3000` (for local dev)

### API Permissions
- Microsoft Graph → User.Read (delegated)
- Microsoft Graph → email (delegated)
- Microsoft Graph → profile (delegated)
- Microsoft Graph → openid (delegated)

### Authentication Settings
- Access tokens enabled
- ID tokens enabled
- Implicit grant flow configured

### Service Principal
- Automatically created for the app registration

---

## Configuration in Your App

After Terraform completes, use these values in your Flutter app:

```dart
// Get from Terraform outputs or Azure Portal
final String tenantId = "YOUR-TENANT-ID";
final String clientId = "FROM: terraform output entra_app_client_id";
final String authority = "https://login.microsoftonline.com/$tenantId";

// Scopes
final List<String> scopes = [
  "openid",
  "profile", 
  "email",
  "User.Read"
];
```

---

## Terraform Outputs Reference

After running `terraform apply`, you can get these values:

```powershell
# Get client ID
terraform output entra_app_client_id

# Get authority URL
terraform output entra_authority_url

# Get all values
terraform output
```

---

## Troubleshooting

### "azuread provider not found"
**Solution**: Run `terraform init -upgrade` to install the azuread provider

### "Insufficient privileges to complete the operation"
**Solution**: Make sure you're logged into the **External ID tenant**, not your main Azure subscription. Run:
```powershell
az login --tenant YOUR-TENANT-ID
```

### "Application already exists"
**Solution**: Terraform will detect and import the existing app. Or manually import:
```powershell
terraform import azuread_application.mathfacts_web[0] <object-id>
```

### "Cannot grant admin consent via Terraform"
**Solution**: This is expected. Admin consent must be granted manually in the portal (Step 3 above).

---

## Cleaning Up

To remove the app registration:

```powershell
# This will delete the app registration and service principal
terraform destroy -var-file="environments/dev.tfvars"
```

**Note**: The External ID tenant itself must be deleted manually from Azure Portal.

---

## Benefits of This Approach

✅ **Infrastructure as Code** - App registration is version controlled
✅ **Repeatable** - Easy to create dev/staging/prod environments
✅ **No manual clicks** - After initial tenant creation, everything is automated
✅ **Self-documenting** - Configuration is in code, not portal screenshots
✅ **Easy updates** - Change permissions, redirect URIs, etc. in code

---

**Last Updated**: October 31, 2025

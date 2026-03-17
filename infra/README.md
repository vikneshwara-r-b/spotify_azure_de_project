# Spotify Azure Data Engineering - Infrastructure Documentation

Complete Terraform infrastructure for deploying Azure data engineering resources for the Spotify analytics project.

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Resources Deployed](#resources-deployed)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Deployment Guide](#detailed-deployment-guide)
- [Post-Deployment Configuration](#post-deployment-configuration)
- [Outputs & Verification](#outputs--verification)
- [Troubleshooting](#troubleshooting)
- [Cost Estimation](#cost-estimation)
- [Cleanup](#cleanup)

---

## 🏗️ Architecture Overview

This Terraform configuration deploys a complete data engineering infrastructure on Azure with the following components:

```
┌─────────────────────────────────────────────────────────────────┐
│                    Resource Group (US-East)                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────┐      ┌─────────────────────────────────┐ │
│  │ Azure Data       │      │ Azure Databricks (Premium)       │ │
│  │ Factory          │◄────►│ + Unity Catalog Ready            │ │
│  │ (System MI)      │      │                                  │ │
│  └──────────────────┘      └─────────────────────────────────┘ │
│         │                              │                         │
│         │                              │                         │
│         ▼                              ▼                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │          ADLS Gen2 Storage Account                        │  │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐                  │  │
│  │  │ bronze  │  │ silver  │  │  gold   │                  │  │
│  │  └─────────┘  └─────────┘  └─────────┘                  │  │
│  └──────────────────────────────────────────────────────────┘  │
│         ▲                                                        │
│         │ (5 RBAC Roles)                                        │
│         │                                                        │
│  ┌──────────────────────────────────────────┐                  │
│  │ Access Connector for Azure Databricks    │                  │
│  │ (Managed Identity for Unity Catalog)     │                  │
│  └──────────────────────────────────────────┘                  │
│                                                                   │
│  ┌──────────────────┐      ┌─────────────────────────────────┐ │
│  │ Azure SQL        │      │ Azure Key Vault                  │ │
│  │ Server + DB      │◄────►│ - ADLS keys                      │ │
│  │                  │      │ - SQL passwords                  │ │
│  └──────────────────┘      └─────────────────────────────────┘ │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📦 Resources Deployed

| Resource | Purpose | Key Features |
|----------|---------|--------------|
| **Resource Group** | Container for all resources | US-East location |
| **Azure Data Factory** | ETL/ELT orchestration | System-assigned MI, GitHub integration |
| **ADLS Gen2** | Data lake storage | Hierarchical namespace, bronze/silver/gold containers |
| **Azure Databricks** | Data processing & analytics | Premium SKU, Unity Catalog ready |
| **Access Connector** | Databricks managed identity | 5 RBAC roles on ADLS |
| **Azure SQL Database** | Relational data storage | Basic tier, Azure services access |
| **Azure Key Vault** | Secrets management | RBAC-enabled, soft delete |

### RBAC Assignments

The Access Connector is automatically assigned these roles on the ADLS Storage Account:
1. ✅ Storage Blob Data Contributor
2. ✅ Storage Queue Data Contributor
3. ✅ Storage Account Contributor
4. ✅ EventGrid Data Contributor
5. ✅ EventGrid EventSubscription Contributor

---

## ✅ Prerequisites

### Required Tools

1. **Azure CLI** (>= 2.50.0)
   ```bash
   # Check version
   az --version
   
   # Install/Update
   # macOS: brew update && brew install azure-cli
   # Windows: https://aka.ms/installazurecliwindows
   # Linux: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   ```

2. **Terraform** (>= 1.0)
   ```bash
   # Check version
   terraform version
   
   # Install/Update
   # macOS: brew tap hashicorp/tap && brew install hashicorp/tap/terraform
   # Windows: choco install terraform
   # Linux: https://www.terraform.io/downloads
   ```

### Azure Requirements

- Active Azure subscription
- Appropriate permissions to create resources (Contributor role or higher)
- Azure CLI authenticated

---

## 🚀 Quick Start

```bash
# 1. Authenticate to Azure
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"

# 2. Navigate to infrastructure directory
cd infra

# 3. Create your configuration file
cp terraform.tfvars.example terraform.tfvars

# 4. Edit terraform.tfvars with your settings
# IMPORTANT: Update resource_suffix and sql_admin_password
nano terraform.tfvars  # or use your preferred editor

# 5. Initialize Terraform
terraform init

# 6. Review the execution plan
terraform plan

# 7. Deploy the infrastructure
terraform apply

# 8. View outputs
terraform output
```

---

## 📖 Detailed Deployment Guide

### Step 1: Azure Authentication

```bash
# Login to Azure
az login

# List available subscriptions
az account list --output table

# Set the subscription you want to use
az account set --subscription "YOUR_SUBSCRIPTION_ID"

# Verify current subscription
az account show
```

### Step 2: Configure Variables

Create `terraform.tfvars` from the example:

```bash
cp terraform.tfvars.example terraform.tfvars
```

**Required Changes:**

```hcl
# Ensure global uniqueness (use today's date: YYYYMMDD)
resource_suffix = "20260316"

# Set a strong password (minimum 8 characters, uppercase, lowercase, number, special char)
sql_admin_password = "YourStrongPassword123!"

# Update owner information
tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
  Project     = "SpotifyDataEngineering"
  Owner       = "Your Name"
}
```

**Optional: GitHub Integration for ADF**

If you want ADF source control:
```hcl
enable_adf_github     = true
adf_github_account    = "your-github-username"
adf_github_repository = "spotify_azure_de_project"
```

> **Note:** You'll need to configure a GitHub Personal Access Token (PAT) in ADF Studio after deployment.

### Step 3: Initialize Terraform

```bash
cd infra
terraform init
```

This will:
- Download the Azure provider (~4.0)
- Initialize the backend
- Prepare the working directory

### Step 4: Plan the Deployment

```bash
terraform plan -out=tfplan
```

Review the plan carefully. You should see:
- **6 main resources** to be created
- **Multiple RBAC assignments** (8 role assignments)
- **4 Key Vault secrets**
- **3 ADLS containers**

### Step 5: Apply the Configuration

```bash
terraform apply tfplan
```

Or for interactive approval:
```bash
terraform apply
```

⏱️ **Expected Duration:** 5-10 minutes

### Step 6: View Outputs

```bash
# All outputs
terraform output

# Specific output
terraform output databricks_workspace_url

# Formatted summary
terraform output deployment_summary

# Unity Catalog setup guide
terraform output unity_catalog_setup_guide
```

---

## 🔧 Post-Deployment Configuration

### 1. Unity Catalog Setup

After Terraform deployment, configure Unity Catalog in Databricks:

```bash
# View the detailed setup guide
terraform output unity_catalog_setup_guide
```

**Key Steps:**
1. Create Unity Catalog Metastore (Databricks Account Console)
2. Create Storage Credential using Access Connector
3. Create External Locations for bronze, silver, gold
4. Create Catalogs and Schemas

**Required Information (from outputs):**
```bash
# Access Connector Principal ID (for storage credential)
terraform output access_connector_principal_id

# Access Connector ID
terraform output access_connector_id

# ADLS endpoint
terraform output storage_account_primary_dfs_endpoint
```

### 2. Databricks Asset Bundles Configuration

Use these values in your `databricks.yml`:

```yaml
workspace:
  host: https://<databricks_workspace_url>

resources:
  storage_credentials:
    spotify_adls_credential:
      name: spotify_adls_credential
      azure_managed_identity:
        access_connector_id: <access_connector_id>
  
  external_locations:
    bronze:
      name: spotify_bronze
      url: <storage_account_primary_dfs_endpoint>bronze
      credential_name: spotify_adls_credential
```

Get values:
```bash
terraform output -json | jq '{
  workspace_url: .databricks_workspace_url.value,
  access_connector_id: .access_connector_id.value,
  storage_endpoint: .storage_account_primary_dfs_endpoint.value
}'
```

### 3. Azure Data Factory Configuration

Access ADF Studio:
```bash
terraform output adf_studio_url
```

**Optional Tasks:**
- Configure GitHub PAT (if GitHub integration enabled)
- Create linked services (ADLS, SQL, Databricks)
- Import or create pipelines

### 4. Verify Key Vault Secrets

```bash
# List secrets
az keyvault secret list --vault-name $(terraform output -raw key_vault_name)

# View secret names (not values)
terraform output key_vault_secrets
```

---

## 📊 Outputs & Verification

### View All Outputs

```bash
terraform output
```

### Key Outputs

| Output | Description | Usage |
|--------|-------------|-------|
| `databricks_workspace_url` | Databricks workspace URL | Access Databricks UI |
| `access_connector_principal_id` | Principal ID for Unity Catalog | Storage credential configuration |
| `adf_studio_url` | ADF Studio URL | Access ADF UI |
| `storage_account_name` | ADLS account name | Data access |
| `key_vault_name` | Key Vault name | Secrets management |
| `sql_server_fqdn` | SQL Server FQDN | Database connections |

### Verify Deployment

```bash
# Verify resource group
az group show --name rg-spotify-dataeng

# Verify storage account
az storage account show --name $(terraform output -raw storage_account_name) --resource-group rg-spotify-dataeng

# List containers
az storage fs list --account-name $(terraform output -raw storage_account_name) --auth-mode login

# Verify Databricks workspace
az databricks workspace show --name $(terraform output -raw databricks_workspace_name) --resource-group rg-spotify-dataeng

# Verify RBAC assignments
az role assignment list --scope $(terraform output -raw storage_account_id) --output table
```

---

## 🔍 Troubleshooting

### Common Issues

#### 1. Resource Name Already Exists

**Error:** `"StorageAccountAlreadyTaken"` or `"ServerNameNotAvailable"`

**Solution:** Change `resource_suffix` in `terraform.tfvars` to a unique value.

```hcl
resource_suffix = "20260316a"  # Add a letter or change date
```

#### 2. Authentication Failed

**Error:** `"No subscription found"`

**Solution:**
```bash
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

#### 3. Insufficient Permissions

**Error:** `"AuthorizationFailed"`

**Solution:** Ensure you have Contributor or Owner role on the subscription:
```bash
az role assignment list --assignee $(az account show --query user.name -o tsv)
```

#### 4. Key Vault Access Denied

**Error:** `"Forbidden"` when creating secrets

**Solution:** This is expected during first apply. Terraform creates RBAC roles then creates secrets. If it fails, run `terraform apply` again.

#### 5. GitHub Configuration Failed

**Error:** GitHub integration issues

**Solution:** Set `enable_adf_github = false` in `terraform.tfvars` and configure GitHub later in ADF Studio.

### Debug Commands

```bash
# Enable detailed logging
export TF_LOG=DEBUG
terraform apply

# Validate configuration
terraform validate

# Check state
terraform state list

# Refresh state
terraform refresh
```

---

## 💰 Cost Estimation

### Monthly Cost Estimate (US East)

| Resource | SKU | Estimated Monthly Cost |
|----------|-----|------------------------|
| Azure Databricks | Premium | ~$100-500 (depends on usage) |
| ADLS Gen2 | Standard LRS | ~$5-20 (depends on storage) |
| Azure SQL Database | Basic | ~$5 |
| Azure Data Factory | Pay-per-use | ~$10-50 (depends on pipelines) |
| Key Vault | Standard | ~$1 |
| Access Connector | Free | $0 |
| **Total** | | **~$120-575/month** |

> **Note:** Costs vary based on usage. Databricks is the most significant cost component.

### Cost Optimization Tips

1. **Databricks:** Use cluster autoscaling, set auto-termination
2. **ADLS:** Enable lifecycle management policies
3. **SQL Database:** Use Basic tier for dev/test, scale up for production
4. **ADF:** Minimize pipeline runs, use triggers efficiently

---

## 🧹 Cleanup

### Destroy All Resources

```bash
# Preview what will be destroyed
terraform plan -destroy

# Destroy all resources
terraform destroy

# Confirm with: yes
```

⚠️ **Warning:** This will permanently delete all resources and data!

### Selective Cleanup

To remove specific resources, use `terraform state rm`:
```bash
# Remove from state without destroying
terraform state rm azurerm_databricks_workspace.main

# Then run apply to remove from cloud
terraform apply
```

### Manual Cleanup (if needed)

If Terraform destroy fails:
```bash
# Delete resource group (deletes all resources)
az group delete --name rg-spotify-dataeng --yes --no-wait
```

---

## 📚 Additional Resources

### Documentation

- [Azure Databricks Unity Catalog](https://learn.microsoft.com/en-us/azure/databricks/data-governance/unity-catalog/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Data Factory](https://learn.microsoft.com/en-us/azure/data-factory/)
- [ADLS Gen2](https://learn.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-introduction)

### Support

For issues with:
- **Terraform configuration:** Check [variables.tf](./variables.tf) and [main.tf](./main.tf)
- **Azure resources:** Review [Azure Status](https://status.azure.com)
- **Unity Catalog:** See `terraform output unity_catalog_setup_guide`

---

## 📝 File Structure

```
infra/
├── providers.tf               # Terraform & provider configuration
├── variables.tf               # Input variable definitions
├── main.tf                    # Main resource definitions
├── outputs.tf                 # Output values
├── terraform.tfvars.example   # Example configuration
├── README.md                  # This file
└── .gitignore                 # Git ignore rules
```

---

## 🤝 Contributing

Feel free to submit issues or pull requests to improve this infrastructure code.

---

## 📄 License

This project is provided as-is for educational and development purposes.

---

**Last Updated:** March 16, 2026  
**Terraform Version:** >= 1.0  
**Azure Provider Version:** ~> 4.0

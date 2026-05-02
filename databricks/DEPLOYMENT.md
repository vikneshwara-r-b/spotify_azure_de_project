# Databricks Asset Bundle Deployment Guide

> 📖 **Quick Start**: See [../README.md](../README.md) for project overview and [../ARCHITECTURE.md](../ARCHITECTURE.md) for system design.

## 📋 Prerequisites

1. **Databricks CLI installed**:
   ```bash
   pip install databricks-cli
   # or
   brew install databricks
   ```

2. **Terraform infrastructure deployed**:
   ```bash
   cd ../infra
   terraform apply
   ```
   
   > ⚠️ **Important**: Ensure Terraform completes successfully. The storage credential (`spotify_adls_credential`) must exist before deploying the bundle, as `base_resources_setup.yml` references it.

3. **Authentication configured**:
   ```bash
   databricks configure
   # Enter your Databricks workspace URL and PAT token
   ```

---

## 🔧 Deployment Method 1: Using --var Flag (RECOMMENDED)

This is the canonical deployment command for this project:

```bash
cd databricks

databricks bundle deploy --target prod \
  --var="adls_storage_container_name=<your-adls-storage-account-name>"
```

Get the storage account name from Terraform:
```bash
cd ../infra && terraform output -raw storage_account_name
```

**For dev target:**
```bash
cd databricks

databricks bundle deploy --target dev \
  --var="adls_storage_container_name=<your-adls-storage-account-name>"
```

---

## 🔧 Deployment Method 2: Using Environment Variables

### Step 1: Set Required Variables

```bash
export DATABRICKS_HOST="https://$(cd ../infra && terraform output -raw databricks_workspace_url)"
export ADLS_STORAGE_CONTAINER_NAME=$(cd ../infra && terraform output -raw storage_account_name)
```

### Step 2: Deploy Bundle

```bash
cd databricks

# Deploy to dev
databricks bundle deploy --target dev

# Deploy to prod
databricks bundle deploy --target prod
```

---

## 🔧 Deployment Method 3: Using .env File

### Step 1: Create .env File

```bash
cd databricks

# Copy template
cp .env.example .env

# Edit .env with your actual ADLS storage account name
# Get value from: cd ../infra && terraform output -raw storage_account_name
```

### Step 2: Load and Deploy

```bash
cd databricks

# Load environment variables
export $(grep -v '^#' .env | xargs)

# Deploy
databricks bundle deploy --target dev
```

---

## 🔧 Deployment Method 4: Using Shell Substitution

```bash
cd databricks

STORAGE_CONTAINER=$(cd ../infra && terraform output -raw storage_account_name)

databricks bundle deploy --target dev \
  --var="adls_storage_container_name=${STORAGE_CONTAINER}"
```

---

## 🚀 Complete One-Liner (Prod Deployment)

```bash
cd databricks && \
databricks bundle deploy --target prod \
  --var="adls_storage_container_name=$(cd ../infra && terraform output -raw storage_account_name)"
```

---

## 📊 Variable Summary

| Variable | Description | Required | Get From |
|----------|-------------|----------|----------|
| `DATABRICKS_HOST` | Workspace URL | ✅ Yes | `terraform output -raw databricks_workspace_url` |
| `ADLS_STORAGE_CONTAINER_NAME` | Storage account name | ✅ Yes | `terraform output -raw storage_account_name` |

> **Note**: `USER_EMAIL` and `ADF_SERVICE_PRINCIPAL_ID` are no longer required. The bundle `databricks.yml` no longer defines `permissions` blocks — job permissions are managed separately.

---

## ✅ Validation & Testing

### 1. Validate Bundle Before Deployment

```bash
cd databricks
databricks bundle validate --target dev
```

### 2. Deploy and Run

```bash
# Deploy
databricks bundle deploy --target dev \
  --var="adls_storage_container_name=<storage-account-name>"

# Run the job
databricks bundle run spotify_etl_job --target dev
```

### 3. Monitor Job Execution

```bash
# List all jobs
databricks jobs list

# Get job runs
databricks jobs list-runs --job-id <job-id>

# Get run details
databricks jobs get-run --run-id <run-id>
```

---

## 📦 What Gets Deployed

The bundle deploys the following resources to Databricks:

### From `resources/base_resources_setup.yml`
- **Unity Catalog** (`spotify_catalog`)
- **Schemas**: `bronze`, `silver`, `gold`
- **External Locations**: `spotify_ext_bronze`, `spotify_ext_silver`, `spotify_ext_gold`
  - All reference the storage credential `spotify_adls_credential` (created by Terraform)

### From `resources/spotify_dab.job.yml`
- **Workflow Job** (`spotify_etl_workflow`)
  - Task 1: `silver_transformation_task` → `src/silver_dimensions.ipynb`
  - Task 2: `gold_transformation_tasks` (for-each) → `src/gold_dimensions.ipynb`
  - Compute: Serverless (auto-provisioned)
  - Performance: STANDARD mode

---

## 🔍 Troubleshooting

### Error: Reference to undeclared resource

**Cause**: Environment variables not set or not exported

**Fix**: Use `--var` flags:
```bash
databricks bundle deploy --target dev \
  --var="adls_storage_container_name=<storage-account-name>"
```

### Error: Storage credential not found

**Cause**: Terraform hasn't been applied yet, or `spotify_adls_credential` doesn't exist in workspace

**Fix**:
```bash
cd ../infra && terraform apply
# Then re-deploy bundle
```

### Error: 3200 from ADF

**Cause**: Missing Azure RBAC Contributor role on Databricks workspace

**Fix**: Run `terraform apply` — the role assignment is already in `infra/main.tf`

### Error: 9512 (Test Connection in ADF)

**Cause**: DatabricksJob activity doesn't need cluster config for test

**Fix**: Skip Test Connection — the pipeline will work correctly at runtime

---

## 📝 Quick Reference Commands

```bash
# Validate
cd databricks && databricks bundle validate --target prod

# Deploy to prod
cd databricks && databricks bundle deploy --target prod \
  --var="adls_storage_container_name=$(cd ../infra && terraform output -raw storage_account_name)"

# Run job
cd databricks && databricks bundle run spotify_etl_job --target prod

# Destroy bundle resources
cd databricks && databricks bundle destroy --target dev
```

---

## 🎯 Deployment Checklist

- [ ] Terraform infrastructure deployed (`terraform apply`)
- [ ] Storage credential `spotify_adls_credential` exists in Databricks workspace
- [ ] Databricks CLI installed and configured (`databricks configure`)
- [ ] Bundle validated (`databricks bundle validate`)
- [ ] Bundle deployed successfully
- [ ] Unity Catalog resources verified (catalog, schemas, external locations)
- [ ] Job visible in Databricks Workflows UI
- [ ] ADF pipeline tested successfully

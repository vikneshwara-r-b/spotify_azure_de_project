# Databricks Asset Bundle Deployment Guide

## 📋 Prerequisites

1. **Databricks CLI installed**:
   ```bash
   pip install databricks-cli
   # or
   brew install databricks
   ```

2. **Terraform infrastructure deployed**:
   ```bash
   cd ../../infra
   terraform apply
   ```

3. **Authentication configured**:
   ```bash
   databricks configure
   ```

---

## 🔧 Deployment Method 1: Using Environment Variables (RECOMMENDED)

### Step 1: Get Values from Terraform

```bash
cd ../../infra

# Get all required values
export DATABRICKS_HOST="https://$(terraform output -raw databricks_workspace_url)"
export ADLS_STORAGE_CONTAINER_NAME=$(terraform output -raw storage_account_name)
export ADF_SERVICE_PRINCIPAL_ID=$(terraform output -raw adf_managed_identity_application_id)
export USER_EMAIL="your-email@company.com"  # Replace with your email
```

### Step 2: Deploy Bundle

```bash
cd ../databricks/spotify_dab

# Deploy to dev
databricks bundle deploy --target dev

# Deploy to prod
databricks bundle deploy --target prod
```

---

## 🔧 Deployment Method 2: Using .env File

### Step 1: Create .env File

```bash
cd databricks/spotify_dab

# Copy template
cp .env.example .env

# Edit .env with your actual values
# You can get values from Terraform outputs
```

### Step 2: Get Terraform Values

```bash
cd ../../infra

echo "DATABRICKS_HOST=https://$(terraform output -raw databricks_workspace_url)"
echo "ADLS_STORAGE_CONTAINER_NAME=$(terraform output -raw storage_account_name)"
echo "ADF_SERVICE_PRINCIPAL_ID=$(terraform output -raw adf_managed_identity_application_id)"
```

### Step 3: Update .env and Deploy

```bash
cd ../databricks/spotify_dab

# Load environment variables
export $(grep -v '^#' .env | xargs)

# Deploy
databricks bundle deploy --target dev
```

---

## 🔧 Deployment Method 3: Using --var Flags (MOST RELIABLE)

Get all values from Terraform and use them directly:

```bash
cd databricks/spotify_dab

# Get values from Terraform
WORKSPACE_URL=$(cd ../../infra && terraform output -raw databricks_workspace_url)
STORAGE_CONTAINER=$(cd ../../infra && terraform output -raw storage_account_name)
ADF_SP_ID=$(cd ../../infra && terraform output -raw adf_managed_identity_application_id)

# Deploy with all variables
databricks bundle deploy --target dev \
  --var="user_email=your-email@company.com" \
  --var="adls_storage_container_name=${STORAGE_CONTAINER}" \
  --var="adf_service_principal_id=${ADF_SP_ID}"
```

---

## 🔧 Deployment Method 4: Using variable-overrides.json

### Step 1: Create variable-overrides.json

```bash
cd databricks/spotify_dab

cat > variable-overrides.json <<EOF
{
  "dev": {
    "user_email": "developer@company.com",
    "adls_storage_container_name": "adlsspotifyv1",
    "adf_service_principal_id": "677878f6-17a1-41ad-b8bd-aef1efa9f1dd"
  },
  "prod": {
    "user_email": "admin@company.com",
    "adls_storage_container_name": "adlsspotifyv1",
    "adf_service_principal_id": "677878f6-17a1-41ad-b8bd-aef1efa9f1dd"
  }
}
EOF
```

### Step 2: Add to .gitignore

```bash
echo "variable-overrides.json" >> .gitignore
```

### Step 3: Deploy

```bash
databricks bundle deploy --target dev
# Variables are automatically loaded from variable-overrides.json
```

---

## 🚀 Complete Deployment Command Examples

### For Development Environment

```bash
databricks bundle deploy --target dev \
  --var="user_email=dev@company.com" \
  --var="adls_storage_container_name=adlsspotifyv1" \
  --var="adf_service_principal_id=677878f6-17a1-41ad-b8bd-aef1efa9f1dd"
```

### For Production Environment

```bash
databricks bundle deploy --target prod \
  --var="user_email=admin@company.com" \
  --var="adls_storage_container_name=adlsspotifyv1" \
  --var="adf_service_principal_id=677878f6-17a1-41ad-b8bd-aef1efa9f1dd"
```

---

## 📊 Variable Summary

| Variable | Description | Required | Get From |
|----------|-------------|----------|----------|
| `DATABRICKS_HOST` | Workspace URL | ✅ Yes | `terraform output databricks_workspace_url` |
| `USER_EMAIL` | User permissions | For prod | Your email |
| `ADLS_STORAGE_CONTAINER_NAME` | Storage container | ✅ Yes | `terraform output storage_account_name` |
| `ADF_SERVICE_PRINCIPAL_ID` | ADF Managed Identity | For permissions | `terraform output adf_managed_identity_application_id` |

---

## ✅ Validation & Testing

### 1. Validate Bundle Before Deployment

```bash
databricks bundle validate --target dev
```

### 2. Preview Deployment

```bash
databricks bundle deploy --target dev --dry-run
```

### 3. Deploy and Run

```bash
# Deploy
databricks bundle deploy --target dev

# Run the job
databricks bundle run spotify_etl_job --target dev
```

### 4. Monitor Job Execution

```bash
# List all jobs
databricks jobs list

# Get job runs
databricks jobs list-runs --job-id <job-id>

# Get run details
databricks jobs get-run --run-id <run-id>
```

---

## 🔍 Troubleshooting

### Error: Reference to undeclared resource

**Cause**: Environment variables not set or not exported

**Fix**: Use `--var` flags instead of environment variables

### Error: 3200 from ADF

**Cause**: Missing Azure RBAC Contributor role on Databricks workspace

**Fix**: Run `terraform apply` to add the role assignment (already in main.tf)

### Error: 9512 (Test Connection)

**Cause**: DatabricksJob activity doesn't need cluster config

**Fix**: This is expected - skip Test Connection, pipeline will work at runtime

---

## 📝 Quick Reference Commands

```bash
# One-liner deployment with Terraform outputs
cd databricks/spotify_dab && \
databricks bundle deploy --target dev \
  --var="adls_storage_container_name=$(cd ../../infra && terraform output -raw storage_account_name)" \
  --var="adf_service_principal_id=$(cd ../../infra && terraform output -raw adf_managed_identity_application_id)" \
  --var="user_email=your-email@company.com"
```

---

## 🎯 Deployment Checklist

- [ ] Terraform infrastructure deployed (`terraform apply`)
- [ ] Databricks CLI installed and configured
- [ ] Environment variables set OR using --var flags
- [ ] Bundle validated (`databricks bundle validate`)
- [ ] Bundle deployed (`databricks bundle deploy`)
- [ ] Job permissions verified in Databricks UI
- [ ] ADF pipeline tested successfully


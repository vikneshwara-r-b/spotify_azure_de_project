# Spotify Azure Data Engineering Infrastructure - Main Configuration

# ============================================================================
# Data Source - Current Azure Client Configuration
# ============================================================================

data "azurerm_client_config" "current" {}

# ============================================================================
# Resource Group
# ============================================================================

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ============================================================================
# Azure Data Lake Storage Gen2 (ADLS Gen2)
# ============================================================================

resource "azurerm_storage_account" "adls" {
  name                     = "${var.storage_account_name}${var.resource_suffix}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  # Enable hierarchical namespace for ADLS Gen2
  is_hns_enabled = true

  # Enable access keys for backward compatibility
  shared_access_key_enabled = true

  tags = var.tags
}

# Create ADLS Gen2 containers (bronze, silver, gold)
resource "azurerm_storage_data_lake_gen2_filesystem" "containers" {
  for_each           = toset(var.adls_containers)
  name               = each.value
  storage_account_id = azurerm_storage_account.adls.id

  depends_on = [azurerm_storage_account.adls]
}

# ============================================================================
# Azure Data Factory v2
# ============================================================================

resource "azurerm_data_factory" "main" {
  name                = "${var.adf_name}-${var.resource_suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Enable system-assigned managed identity for authentication
  identity {
    type = "SystemAssigned"
  }

  # Optional: GitHub integration for source control
  dynamic "github_configuration" {
    for_each = var.enable_adf_github && var.adf_github_account != "" && var.adf_github_repository != "" ? [1] : []
    content {
      account_name       = var.adf_github_account
      branch_name        = var.adf_github_branch
      git_url            = "https://github.com"
      repository_name    = var.adf_github_repository
      root_folder        = var.adf_github_root_folder
      publishing_enabled = true
    }
  }

  tags = var.tags
}

# ============================================================================
# Azure Databricks Workspace
# ============================================================================

resource "azurerm_databricks_workspace" "main" {
  name                = "${var.databricks_name}-${var.resource_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = var.databricks_sku

  # Managed resource group for Databricks-managed resources
  managed_resource_group_name = "${var.resource_group_name}-databricks-managed-${var.resource_suffix}"

  tags = var.tags
}

# ============================================================================
# Access Connector for Azure Databricks
# ============================================================================

resource "azurerm_databricks_access_connector" "main" {
  name                = "${var.access_connector_name}-${var.resource_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# ============================================================================
# RBAC - Access Connector to ADLS Gen2 Storage Account
# ============================================================================

# 1. Storage Blob Data Contributor
resource "azurerm_role_assignment" "access_connector_blob_contributor" {
  scope                = azurerm_storage_account.adls.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.main.identity[0].principal_id

  depends_on = [
    azurerm_databricks_access_connector.main,
    azurerm_storage_account.adls
  ]
}

# 2. Storage Queue Data Contributor
resource "azurerm_role_assignment" "access_connector_queue_contributor" {
  scope                = azurerm_storage_account.adls.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_databricks_access_connector.main.identity[0].principal_id

  depends_on = [
    azurerm_databricks_access_connector.main,
    azurerm_storage_account.adls
  ]
}

# 3. Storage Account Contributor
resource "azurerm_role_assignment" "access_connector_account_contributor" {
  scope                = azurerm_storage_account.adls.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_databricks_access_connector.main.identity[0].principal_id

  depends_on = [
    azurerm_databricks_access_connector.main,
    azurerm_storage_account.adls
  ]
}

# 4. EventGrid Data Contributor
resource "azurerm_role_assignment" "access_connector_eventgrid_data_contributor" {
  scope                = azurerm_storage_account.adls.id
  role_definition_name = "EventGrid Data Contributor"
  principal_id         = azurerm_databricks_access_connector.main.identity[0].principal_id

  depends_on = [
    azurerm_databricks_access_connector.main,
    azurerm_storage_account.adls
  ]
}

# 5. EventGrid EventSubscription Contributor
resource "azurerm_role_assignment" "access_connector_eventgrid_subscription_contributor" {
  scope                = azurerm_storage_account.adls.id
  role_definition_name = "EventGrid EventSubscription Contributor"
  principal_id         = azurerm_databricks_access_connector.main.identity[0].principal_id

  depends_on = [
    azurerm_databricks_access_connector.main,
    azurerm_storage_account.adls
  ]
}

# ============================================================================
# RBAC - ADF Managed Identity to ADLS Gen2
# ============================================================================

# Grant ADF access to read/write data in ADLS Gen2
resource "azurerm_role_assignment" "adf_storage_blob_contributor" {
  scope                = azurerm_storage_account.adls.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_factory.main.identity[0].principal_id

  depends_on = [
    azurerm_data_factory.main,
    azurerm_storage_account.adls
  ]
}

# ============================================================================
# Azure SQL Server
# ============================================================================

resource "azurerm_mssql_server" "main" {
  name                         = "${var.sql_server_name}-${var.resource_suffix}"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password

  tags = var.tags
}

# Firewall rule to allow Azure services to access the SQL server
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Azure SQL Database
resource "azurerm_mssql_database" "main" {
  name                 = var.sql_database_name
  server_id            = azurerm_mssql_server.main.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb          = var.sql_database_max_size_gb
  sku_name             = var.sql_database_sku
  zone_redundant       = false
  storage_account_type = "Local" # Locally-redundant backup storage (LRS)

  tags = var.tags
}

# ============================================================================
# Azure Key Vault
# ============================================================================

resource "azurerm_key_vault" "main" {
  name                = "${var.key_vault_name}-${var.resource_suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.key_vault_sku

  # Enable RBAC authorization (recommended approach)
  rbac_authorization_enabled = true

  # Security features
  soft_delete_retention_days = 7
  purge_protection_enabled   = false # Set to true for production

  # Network settings
  public_network_access_enabled = true

  tags = var.tags
}

# ============================================================================
# Key Vault RBAC - Grant Permissions
# ============================================================================

# Grant ADF Managed Identity access to read secrets from Key Vault
resource "azurerm_role_assignment" "adf_keyvault_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_data_factory.main.identity[0].principal_id

  depends_on = [
    azurerm_key_vault.main,
    azurerm_data_factory.main
  ]
}

# Grant current user/service principal admin access to manage secrets
resource "azurerm_role_assignment" "user_keyvault_administrator" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id

  depends_on = [azurerm_key_vault.main]
}

# ============================================================================
# Key Vault Secrets - ADLS Gen2 Connection Details
# ============================================================================

# Store ADLS Gen2 storage account key
resource "azurerm_key_vault_secret" "adls_storage_account_key" {
  name         = "adls-storage-account-key"
  value        = azurerm_storage_account.adls.primary_access_key
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [
    azurerm_role_assignment.user_keyvault_administrator,
    azurerm_storage_account.adls
  ]
}

# Store ADLS Gen2 storage account name
resource "azurerm_key_vault_secret" "adls_storage_account_name" {
  name         = "adls-storage-account-name"
  value        = azurerm_storage_account.adls.name
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [
    azurerm_role_assignment.user_keyvault_administrator,
    azurerm_storage_account.adls
  ]
}

# ============================================================================
# Key Vault Secrets - SQL Server Credentials
# ============================================================================

# Store SQL Server admin password
resource "azurerm_key_vault_secret" "sql_admin_password" {
  name         = "sql-admin-password"
  value        = var.sql_admin_password
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [
    azurerm_role_assignment.user_keyvault_administrator
  ]
}

# Store SQL Server admin username
resource "azurerm_key_vault_secret" "sql_admin_username" {
  name         = "sql-admin-username"
  value        = var.sql_admin_username
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [
    azurerm_role_assignment.user_keyvault_administrator
  ]
}

# ============================================================================
# Azure Data Factory - Global Parameters
# ============================================================================

# NOTE: The AzureRM provider does not currently support creating ADF global parameters via Terraform.
# Global parameters must be created manually in ADF Studio after deployment.
#
# To create global parameters in ADF Studio:
# 1. Open ADF Studio (use the URL from terraform outputs: adf_studio_url)
# 2. Go to Manage → Global parameters
# 3. Click "+ New" and add the following parameters:
#
# Parameter: adls_source_url
#   Type: String
#   Value: (see output: storage_account_primary_dfs_endpoint)
#
# Parameter: key_vault_url
#   Type: String
#   Value: (see output: key_vault_uri)
#
# Parameter: sql_source_server_name
#   Type: String
#   Value: (see output: sql_server_fqdn)
#
# Parameter: sql_source_database_name
#   Type: String
#   Value: (see output: sql_database_name)
#
# The values will be available in terraform outputs after deployment.

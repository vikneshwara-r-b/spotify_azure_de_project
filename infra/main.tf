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

# Store Logic App trigger URL (for Azure Table interaction)
resource "azurerm_key_vault_secret" "logic_app_trigger_url" {
  name         = "azure-table-interaction-endpoint"
  value        = azurerm_logic_app_trigger_http_request.main.callback_url
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [
    azurerm_role_assignment.user_keyvault_administrator,
    azurerm_logic_app_trigger_http_request.main
  ]
}

# ============================================================================
# Key Vault Secrets - Additional Configuration Values
# ============================================================================

# Store ADLS Source URL (DFS endpoint)
resource "azurerm_key_vault_secret" "adls_source_url" {
  name         = "adls-source-url"
  value        = azurerm_storage_account.adls.primary_dfs_endpoint
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [
    azurerm_role_assignment.user_keyvault_administrator,
    azurerm_storage_account.adls
  ]
}

# Store SQL Server FQDN
resource "azurerm_key_vault_secret" "sql_source_server_name" {
  name         = "sql-source-server-name"
  value        = azurerm_mssql_server.main.fully_qualified_domain_name
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [
    azurerm_role_assignment.user_keyvault_administrator,
    azurerm_mssql_server.main
  ]
}

# ============================================================================
# Azure Data Factory - Global Parameters
# ============================================================================

# NOTE: The AzureRM provider does not currently support creating ADF global parameters via Terraform.
# Global parameters must be created manually in ADF Studio after deployment.
#
# To create global parameter in ADF Studio:
# 1. Open ADF Studio (use the URL from terraform outputs: adf_studio_url)
# 2. Go to Manage → Global parameters
# 3. Click "+ New" and add this parameter:
#
# Parameter: key_vault_url
#   Type: String
#   Value: (see output: key_vault_uri)
#
# All other configuration values are stored in Key Vault secrets:
# - adls-source-url (ADLS DFS endpoint)
# - sql-source-server-name (SQL Server FQDN)
# - sql-admin-username (SQL username)
# - sql-admin-password (SQL password)
# - adls-storage-account-key (ADLS access key)
# - adls-storage-account-name (ADLS account name)
# - azure-table-interaction-endpoint (Logic App trigger URL)
#
# Access these from ADF pipelines using Key Vault Linked Service.
# Example: @linkedService().secretName or use Web Activity with Key Vault integration

# ============================================================================
# Azure Table Storage (for Metadata)
# ============================================================================

resource "azurerm_storage_table" "metadata" {
  name                 = var.azure_table_name
  storage_account_name = azurerm_storage_account.adls.name

  depends_on = [azurerm_storage_account.adls]
}

# ============================================================================
# Azure Logic App - API Connection for Azure Tables
# ============================================================================

resource "azurerm_api_connection" "azuretables" {
  name                = var.logic_app_connection_name
  resource_group_name = azurerm_resource_group.main.name
  managed_api_id      = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Web/locations/${var.location}/managedApis/azuretables"
  display_name        = "sample_connection"

  parameter_values = {
    storageaccount = azurerm_storage_account.adls.name
    sharedkey      = azurerm_storage_account.adls.primary_access_key
  }

  tags = var.tags

  depends_on = [azurerm_storage_account.adls]
}

# ============================================================================
# Azure Logic App Workflow
# ============================================================================

resource "azurerm_logic_app_workflow" "metadata_handler" {
  name                = "${var.logic_app_name}-${var.resource_suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  workflow_parameters = {
    "$connections" = jsonencode({
      defaultValue = {}
      type         = "Object"
    })
  }

  parameters = {
    "$connections" = jsonencode({
      azuretables = {
        connectionId         = azurerm_api_connection.azuretables.id
        connectionName       = azurerm_api_connection.azuretables.name
        connectionProperties = {}
        id                   = azurerm_api_connection.azuretables.managed_api_id
      }
    })
  }

  tags = var.tags

  depends_on = [azurerm_api_connection.azuretables]
}

# Logic App Trigger - HTTP Request
resource "azurerm_logic_app_trigger_http_request" "main" {
  name         = "When_an_HTTP_request_is_received"
  logic_app_id = azurerm_logic_app_workflow.metadata_handler.id

  schema = <<SCHEMA
{
  "type": "object",
  "properties": {
    "PartitionKey": {
      "type": "string"
    },
    "RowKey": {
      "type": "string"
    },
    "OperationType": {
      "type": "string"
    },
    "LastWatermarkValue": {
      "type": "string"
    }
  }
}
SCHEMA

  method = "POST"
}

# Logic App Action - Condition (Fetch or Merge)
resource "azurerm_logic_app_action_custom" "condition" {
  name         = "Condition"
  logic_app_id = azurerm_logic_app_workflow.metadata_handler.id

  body = jsonencode({
    type = "If"
    expression = {
      and = [{
        equals = [
          "@triggerBody()?['OperationType']",
          "fetch"
        ]
      }]
    }
    actions = {
      Fetch_row = {
        type = "ApiConnection"
        inputs = {
          host = {
            connection = {
              name = "@parameters('$connections')['azuretables']['connectionId']"
            }
          }
          method = "get"
          path   = "/v2/storageAccounts/@{encodeURIComponent(encodeURIComponent('AccountNameFromSettings'))}/tables/@{encodeURIComponent('${var.azure_table_name}')}/entities(PartitionKey='@{encodeURIComponent(triggerBody()?['PartitionKey'])}',RowKey='@{encodeURIComponent(triggerBody()?['RowKey'])}')"
        }
      }
      Table_Fetch_Response = {
        type = "Response"
        kind = "Http"
        inputs = {
          statusCode = 200
          body = {
            PartitionKey = "@{body('Fetch_row')?['PartitionKey']}"
            RowKey       = "@{body('Fetch_row')?['RowKey']}"
            Entity       = "@body('Fetch_row')"
            message      = "Fetched row from @{triggerBody()?['PartitionKey']} and @{triggerBody()?['RowKey']}"
          }
        }
        runAfter = {
          Fetch_row = ["Succeeded"]
        }
      }
    }
    else = {
      actions = {
        Merge_row = {
          type = "ApiConnection"
          inputs = {
            host = {
              connection = {
                name = "@parameters('$connections')['azuretables']['connectionId']"
              }
            }
            method = "patch"
            path   = "/v2/storageAccounts/@{encodeURIComponent(encodeURIComponent('AccountNameFromSettings'))}/tables/@{encodeURIComponent('${var.azure_table_name}')}/entities(PartitionKey='@{encodeURIComponent(triggerBody()?['PartitionKey'])}',RowKey='@{encodeURIComponent(triggerBody()?['RowKey'])}')"
            body = {
              LastWatermarkValue = "@{triggerBody()?['LastWatermarkValue']}"
            }
          }
        }
        Table_Merge_Response = {
          type = "Response"
          kind = "Http"
          inputs = {
            statusCode = 200
            body = {
              PartitionKey       = "@{triggerBody()?['PartitionKey']}"
              RowKey             = "@{triggerBody()?['RowKey']}"
              LastWatermarkValue = "@{triggerBody()?['LastWatermarkValue']}"
              message            = "Value is inserted or updated"
            }
          }
          runAfter = {
            Merge_row = ["Succeeded"]
          }
        }
      }
    }
  })

  depends_on = [
    azurerm_logic_app_trigger_http_request.main,
    azurerm_logic_app_workflow.metadata_handler
  ]
}

# ============================================================================
# Databricks Unity Catalog - Storage Credential
# ============================================================================

resource "databricks_storage_credential" "spotify_adls" {
  name    = var.unity_catalog_storage_credential_name
  comment = "Storage credential for Spotify ADLS Gen2 using Access Connector managed identity"

  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.main.id
  }

  depends_on = [
    azurerm_databricks_workspace.main,
    azurerm_databricks_access_connector.main,
    azurerm_role_assignment.access_connector_blob_contributor
  ]
}

# ============================================================================
# Databricks Unity Catalog - External Locations
# ============================================================================

# Create external locations dynamically for each container
resource "databricks_external_location" "layers" {
  for_each = toset(var.adls_containers)

  name            = "spotify_${each.value}"
  url             = "abfss://${each.value}@${azurerm_storage_account.adls.name}.dfs.core.windows.net/"
  credential_name = databricks_storage_credential.spotify_adls.name
  comment         = "${title(each.value)} layer for Spotify data"

  depends_on = [
    databricks_storage_credential.spotify_adls,
    azurerm_storage_data_lake_gen2_filesystem.containers
  ]
}

# ============================================================================
# Databricks Unity Catalog - Catalog
# ============================================================================

resource "databricks_catalog" "spotify" {
  name    = var.unity_catalog_name
  comment = "Main catalog for Spotify data engineering project"

  depends_on = [
    databricks_storage_credential.spotify_adls,
    databricks_external_location.layers
  ]
}

# ============================================================================
# Databricks Unity Catalog - Schemas
# ============================================================================

# Create schemas dynamically for each container (excluding bronze)
resource "databricks_schema" "layers" {
  for_each = toset([for container in var.adls_containers : container if container != "bronze"])

  catalog_name = databricks_catalog.spotify.name
  name         = each.value
  comment      = "${title(each.value)} layer schema for Spotify data"
  storage_root = "abfss://${each.value}@${azurerm_storage_account.adls.name}.dfs.core.windows.net/"

  depends_on = [
    databricks_catalog.spotify,
    databricks_external_location.layers
  ]
}

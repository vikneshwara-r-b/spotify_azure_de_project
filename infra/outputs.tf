# Outputs for Spotify Azure Data Engineering Infrastructure

# ============================================================================
# Resource Group
# ============================================================================

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "location" {
  description = "Azure region where resources are deployed"
  value       = azurerm_resource_group.main.location
}

# ============================================================================
# Azure Data Factory
# ============================================================================

output "adf_name" {
  description = "Name of the Azure Data Factory"
  value       = azurerm_data_factory.main.name
}

output "adf_id" {
  description = "ID of the Azure Data Factory"
  value       = azurerm_data_factory.main.id
}

output "adf_principal_id" {
  description = "Principal ID (Object ID) of the ADF managed identity"
  value       = azurerm_data_factory.main.identity[0].principal_id
}

output "adf_studio_url" {
  description = "URL to access Azure Data Factory Studio"
  value       = "https://adf.azure.com/en-us/home?factory=/subscriptions/${split("/", azurerm_data_factory.main.id)[2]}/resourceGroups/${azurerm_resource_group.main.name}/providers/Microsoft.DataFactory/factories/${azurerm_data_factory.main.name}"
}

output "adf_global_parameters_values" {
  description = "Value to use for ADF global parameter (must be created manually in ADF Studio). All other values are stored in Key Vault."
  value = {
    key_vault_url = azurerm_key_vault.main.vault_uri
  }
}

# ============================================================================
# Storage Account (ADLS Gen2)
# ============================================================================

output "storage_account_name" {
  description = "Name of the ADLS Gen2 storage account"
  value       = azurerm_storage_account.adls.name
}

output "storage_account_id" {
  description = "ID of the ADLS Gen2 storage account"
  value       = azurerm_storage_account.adls.id
}

output "storage_account_primary_dfs_endpoint" {
  description = "Primary DFS endpoint of the storage account"
  value       = azurerm_storage_account.adls.primary_dfs_endpoint
}

output "storage_account_primary_blob_endpoint" {
  description = "Primary Blob endpoint of the storage account"
  value       = azurerm_storage_account.adls.primary_blob_endpoint
}

output "adls_containers" {
  description = "List of ADLS Gen2 containers created"
  value       = [for container in azurerm_storage_data_lake_gen2_filesystem.containers : container.name]
}

# ============================================================================
# Azure Databricks
# ============================================================================

output "databricks_workspace_name" {
  description = "Name of the Azure Databricks workspace"
  value       = azurerm_databricks_workspace.main.name
}

output "databricks_workspace_id" {
  description = "ID of the Azure Databricks workspace"
  value       = azurerm_databricks_workspace.main.id
}

output "databricks_workspace_url" {
  description = "URL of the Databricks workspace"
  value       = azurerm_databricks_workspace.main.workspace_url
}

output "databricks_workspace_resource_id" {
  description = "Azure Resource ID of the Databricks workspace"
  value       = azurerm_databricks_workspace.main.workspace_id
}

# ============================================================================
# Access Connector for Azure Databricks
# ============================================================================

output "access_connector_name" {
  description = "Name of the Access Connector for Azure Databricks"
  value       = azurerm_databricks_access_connector.main.name
}

output "access_connector_id" {
  description = "ID of the Access Connector"
  value       = azurerm_databricks_access_connector.main.id
}

output "access_connector_principal_id" {
  description = "Principal ID (Object ID) of the Access Connector managed identity - USE THIS FOR UNITY CATALOG STORAGE CREDENTIAL"
  value       = azurerm_databricks_access_connector.main.identity[0].principal_id
}

output "access_connector_tenant_id" {
  description = "Tenant ID of the Access Connector managed identity"
  value       = azurerm_databricks_access_connector.main.identity[0].tenant_id
}

# ============================================================================
# Azure SQL Server & Database
# ============================================================================

output "sql_server_name" {
  description = "Name of the Azure SQL Server"
  value       = azurerm_mssql_server.main.name
}

output "sql_server_id" {
  description = "ID of the Azure SQL Server"
  value       = azurerm_mssql_server.main.id
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL server"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "sql_database_name" {
  description = "Name of the SQL database"
  value       = azurerm_mssql_database.main.name
}

output "sql_database_id" {
  description = "ID of the SQL database"
  value       = azurerm_mssql_database.main.id
}

output "sql_connection_string" {
  description = "SQL Server connection string (without password)"
  value       = "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.main.name};User ID=${var.sql_admin_username};Password=<from_key_vault>;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  sensitive   = true
}

# ============================================================================
# Azure Key Vault
# ============================================================================

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "key_vault_secrets" {
  description = "List of secrets stored in Key Vault"
  value = {
    adls_storage_account_key         = azurerm_key_vault_secret.adls_storage_account_key.name
    adls_storage_account_name        = azurerm_key_vault_secret.adls_storage_account_name.name
    adls_source_url                  = azurerm_key_vault_secret.adls_source_url.name
    sql_admin_password               = azurerm_key_vault_secret.sql_admin_password.name
    sql_admin_username               = azurerm_key_vault_secret.sql_admin_username.name
    sql_source_server_name           = azurerm_key_vault_secret.sql_source_server_name.name
    azure_table_interaction_endpoint = azurerm_key_vault_secret.logic_app_trigger_url.name
    databricks_workspace_resource_id = azurerm_key_vault_secret.databricks_workspace_resource_id.name
    databricks_workspace_url         = azurerm_key_vault_secret.databricks_workspace_url.name
  }
}

# ============================================================================
# Azure Table Storage & Logic App
# ============================================================================

output "azure_table_name" {
  description = "Name of the Azure Table for metadata"
  value       = azurerm_storage_table.metadata.name
}

output "logic_app_name" {
  description = "Name of the Logic App"
  value       = azurerm_logic_app_workflow.metadata_handler.name
}

output "logic_app_id" {
  description = "ID of the Logic App"
  value       = azurerm_logic_app_workflow.metadata_handler.id
}

output "logic_app_trigger_url" {
  description = "Logic App HTTP trigger URL - USE THIS FOR ADF GLOBAL PARAMETER 'azure_table_interaction_endpoint'"
  value       = azurerm_logic_app_trigger_http_request.main.callback_url
  sensitive   = true
}

output "logic_app_access_endpoint" {
  description = "Logic App access endpoint"
  value       = "https://prod-82.eastus.logic.azure.com:443/workflows/${azurerm_logic_app_workflow.metadata_handler.name}"
}

output "api_connection_name" {
  description = "Name of the Azure Tables API connection"
  value       = azurerm_api_connection.azuretables.name
}

# ============================================================================
# Databricks Unity Catalog
# ============================================================================

output "storage_credential_name" {
  description = "Name of the Unity Catalog storage credential"
  value       = databricks_storage_credential.spotify_adls.name
}

output "storage_credential_id" {
  description = "ID of the Unity Catalog storage credential"
  value       = databricks_storage_credential.spotify_adls.id
}

output "external_locations" {
  description = "All Unity Catalog external locations"
  value = {
    for key, location in databricks_external_location.layers : key => {
      name = location.name
      url  = location.url
    }
  }
}

output "unity_catalog_name" {
  description = "Name of the Unity Catalog"
  value       = databricks_catalog.spotify.name
}

output "unity_catalog_id" {
  description = "ID of the Unity Catalog"
  value       = databricks_catalog.spotify.id
}

output "unity_catalog_schemas" {
  description = "Unity Catalog schemas"
  value = {
    for key, schema in databricks_schema.layers : key => schema.name
  }
}

# ============================================================================
# ADF → Databricks Integration
# ============================================================================

output "adf_databricks_service_principal_id" {
  description = "ADF Managed Identity registered as Databricks service principal"
  value       = databricks_service_principal.adf.id
}

output "adf_databricks_application_id" {
  description = "ADF Managed Identity Application ID in Databricks"
  value       = databricks_service_principal.adf.application_id
}

output "databricks_workspace_resource_id_for_linked_service" {
  description = "Databricks workspace resource ID - USE THIS when creating ADF Databricks Linked Service (also stored in Key Vault)"
  value       = azurerm_databricks_workspace.main.id
}

# ============================================================================
# ADF Managed Identity for Databricks Bundle
# ============================================================================

output "adf_managed_identity_application_id" {
  description = "ADF Managed Identity Application ID - USE THIS for Databricks bundle permissions"
  value       = azurerm_data_factory.main.identity[0].principal_id
}

# ============================================================================
# Summary Output
# ============================================================================

output "deployment_summary" {
  description = "Summary of all deployed resources"
  value = {
    resource_group               = azurerm_resource_group.main.name
    location                     = azurerm_resource_group.main.location
    data_factory                 = azurerm_data_factory.main.name
    storage_account              = azurerm_storage_account.adls.name
    containers                   = [for container in azurerm_storage_data_lake_gen2_filesystem.containers : container.name]
    azure_table                  = azurerm_storage_table.metadata.name
    databricks_workspace         = azurerm_databricks_workspace.main.name
    access_connector             = azurerm_databricks_access_connector.main.name
    storage_credential           = databricks_storage_credential.spotify_adls.name
    external_locations           = [for location in databricks_external_location.layers : location.name]
    unity_catalog                = databricks_catalog.spotify.name
    unity_catalog_schemas        = [for schema in databricks_schema.layers : schema.name]
    sql_server                   = azurerm_mssql_server.main.name
    sql_database                 = azurerm_mssql_database.main.name
    key_vault                    = azurerm_key_vault.main.name
    logic_app                    = azurerm_logic_app_workflow.metadata_handler.name
    api_connection               = azurerm_api_connection.azuretables.name
    adf_databricks_service_principal = databricks_service_principal.adf.display_name
  }
}

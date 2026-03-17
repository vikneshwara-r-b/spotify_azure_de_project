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
  description = "Values to use for ADF global parameters (must be created manually in ADF Studio)"
  value = {
    adls_source_url          = azurerm_storage_account.adls.primary_dfs_endpoint
    key_vault_url            = azurerm_key_vault.main.vault_uri
    sql_source_server_name   = azurerm_mssql_server.main.fully_qualified_domain_name
    sql_source_database_name = azurerm_mssql_database.main.name
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
    adls_storage_account_key  = azurerm_key_vault_secret.adls_storage_account_key.name
    adls_storage_account_name = azurerm_key_vault_secret.adls_storage_account_name.name
    sql_admin_password        = azurerm_key_vault_secret.sql_admin_password.name
    sql_admin_username        = azurerm_key_vault_secret.sql_admin_username.name
  }
}

# ============================================================================
# Summary Output
# ============================================================================

output "deployment_summary" {
  description = "Summary of all deployed resources"
  value = {
    resource_group       = azurerm_resource_group.main.name
    location             = azurerm_resource_group.main.location
    data_factory         = azurerm_data_factory.main.name
    storage_account      = azurerm_storage_account.adls.name
    containers           = [for container in azurerm_storage_data_lake_gen2_filesystem.containers : container.name]
    databricks_workspace = azurerm_databricks_workspace.main.name
    access_connector     = azurerm_databricks_access_connector.main.name
    sql_server           = azurerm_mssql_server.main.name
    sql_database         = azurerm_mssql_database.main.name
    key_vault            = azurerm_key_vault.main.name
  }
}

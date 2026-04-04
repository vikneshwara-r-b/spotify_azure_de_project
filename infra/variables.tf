# Variables for Spotify Azure Data Engineering Infrastructure

# ============================================================================
# General Configuration
# ============================================================================

variable "location" {
  description = "Azure region for all resources (US-East)"
  type        = string
  default     = "eastus"
}

variable "resource_suffix" {
  description = "Unique suffix for resource names to ensure global uniqueness (e.g., '20260316', 'dev01')"
  type        = string
  default     = "001"
}

variable "project_name" {
  description = "Project name for resource naming (e.g., 'spotify')"
  type        = string
  default     = "spotify"
}

variable "environment" {
  description = "Environment name (e.g., dev, test, prod)"
  type        = string
  default     = "dev"
}

# ============================================================================
# Resource Group
# ============================================================================

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-spotify-dataeng"
}

# ============================================================================
# Azure Data Factory
# ============================================================================

variable "adf_name" {
  description = "Name of the Azure Data Factory (will be appended with suffix)"
  type        = string
  default     = "adf-spotify"
}

variable "adf_github_account" {
  description = "GitHub account name for ADF integration (optional)"
  type        = string
  default     = ""
}

variable "adf_github_repository" {
  description = "GitHub repository name for ADF (optional)"
  type        = string
  default     = ""
}

variable "adf_github_branch" {
  description = "GitHub branch name for ADF collaboration (optional)"
  type        = string
  default     = "main"
}

variable "adf_github_root_folder" {
  description = "Root folder in repository for ADF artifacts (optional)"
  type        = string
  default     = "/"
}

variable "enable_adf_github" {
  description = "Enable GitHub integration for ADF (requires GitHub PAT)"
  type        = bool
  default     = false
}

# ============================================================================
# Azure Data Lake Storage Gen2 (ADLS)
# ============================================================================

variable "storage_account_name" {
  description = "Name of the ADLS Gen2 storage account (must be globally unique, lowercase, no hyphens, will be appended with suffix)"
  type        = string
  default     = "adlsspotify"
}

variable "adls_containers" {
  description = "List of container names to create in ADLS Gen2"
  type        = list(string)
  default     = ["bronze", "silver", "gold"]
}

# ============================================================================
# Azure Databricks
# ============================================================================

variable "databricks_name" {
  description = "Name of the Azure Databricks workspace (will be appended with suffix)"
  type        = string
  default     = "dbw-spotify"
}

variable "databricks_sku" {
  description = "SKU for Azure Databricks (standard, premium, or trial)"
  type        = string
  default     = "premium"
}

variable "enable_unity_catalog" {
  description = "Enable Unity Catalog for Databricks (requires premium SKU)"
  type        = bool
  default     = true
}

# ============================================================================
# Access Connector for Azure Databricks
# ============================================================================

variable "access_connector_name" {
  description = "Name of the Access Connector for Azure Databricks"
  type        = string
  default     = "ac-databricks"
}

# ============================================================================
# Azure SQL Server & Database
# ============================================================================

variable "sql_server_name" {
  description = "Name of the Azure SQL Server (must be globally unique, will be appended with suffix)"
  type        = string
  default     = "sql-spotify"
}

variable "sql_admin_username" {
  description = "Admin username for SQL Server"
  type        = string
  default     = "sqladmin"
  sensitive   = true
}

variable "sql_admin_password" {
  description = "Admin password for SQL Server (must meet complexity requirements)"
  type        = string
  sensitive   = true
}

variable "sql_database_name" {
  description = "Name of the SQL database"
  type        = string
  default     = "spotifydb"
}

variable "sql_database_sku" {
  description = "SKU for SQL database (Basic, S0, S1, etc.)"
  type        = string
  default     = "Basic"
}

variable "sql_database_max_size_gb" {
  description = "Maximum size of the SQL database in GB"
  type        = number
  default     = 2
}

# ============================================================================
# Azure Key Vault
# ============================================================================

variable "key_vault_name" {
  description = "Name of the Azure Key Vault (will be appended with suffix)"
  type        = string
  default     = "kv-spotify"
}

variable "key_vault_sku" {
  description = "SKU for Azure Key Vault (standard or premium)"
  type        = string
  default     = "standard"
}

# ============================================================================
# Azure Table Storage
# ============================================================================

variable "azure_table_name" {
  description = "Name of the Azure Table for metadata storage"
  type        = string
  default     = "ingestionmetadata"
}

# ============================================================================
# Azure Logic App
# ============================================================================

variable "logic_app_name" {
  description = "Name of the Azure Logic App (will be appended with suffix)"
  type        = string
  default     = "logicappspotifyde"
}

variable "logic_app_connection_name" {
  description = "Name of the API connection for Azure Tables"
  type        = string
  default     = "azuretables"
}

# ============================================================================
# Databricks Unity Catalog
# ============================================================================

variable "unity_catalog_storage_credential_name" {
  description = "Name of the Unity Catalog storage credential"
  type        = string
  default     = "spotify_adls_credential"
}

variable "unity_catalog_external_location_bronze" {
  description = "Name of the Bronze layer external location"
  type        = string
  default     = "spotify_bronze"
}

variable "unity_catalog_external_location_silver" {
  description = "Name of the Silver layer external location"
  type        = string
  default     = "spotify_silver"
}

variable "unity_catalog_external_location_gold" {
  description = "Name of the Gold layer external location"
  type        = string
  default     = "spotify_gold"
}

variable "unity_catalog_name" {
  description = "Name of the Unity Catalog"
  type        = string
  default     = "spotify_catalog"
}

variable "unity_catalog_schema_bronze" {
  description = "Name of the Bronze schema in Unity Catalog"
  type        = string
  default     = "bronze"
}

variable "unity_catalog_schema_silver" {
  description = "Name of the Silver schema in Unity Catalog"
  type        = string
  default     = "silver"
}

variable "unity_catalog_schema_gold" {
  description = "Name of the Gold schema in Unity Catalog"
  type        = string
  default     = "gold"
}

# ============================================================================
# Tags
# ============================================================================

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "SpotifyDataEngineering"
  }
}

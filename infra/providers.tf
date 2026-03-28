# Terraform Configuration for Spotify Azure Data Engineering Project

terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Databricks provider - uses Azure CLI authentication by default
provider "databricks" {
  host = "https://${azurerm_databricks_workspace.main.workspace_url}"
  # Authentication via Azure CLI or environment variables:
  # - Azure CLI: az login
  # - Or set: DATABRICKS_TOKEN, DATABRICKS_HOST
  # - Or use azure_workspace_resource_id for automatic auth
  azure_workspace_resource_id = azurerm_databricks_workspace.main.id
}

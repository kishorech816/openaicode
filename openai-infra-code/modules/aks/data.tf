data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

data "azurerm_user_assigned_identity" "uami_cp_aks" {
  name                = var.uami_cp_aks
  resource_group_name = var.uami_resource_group
} 

data "azurerm_user_assigned_identity" "uami_rt_aks" {
  name                = var.uami_rt_aks
  resource_group_name = var.uami_resource_group
} 

data "azurerm_subnet" "aks_subnet" {
    name                 = var.aks_subnet_name
    virtual_network_name = var.vnet_name
    resource_group_name  = var.vnet_name_resource_grp_name
}

data "azurerm_key_vault" "aksvault" {
    name                = var.key_vault_name
    resource_group_name = var.key_vault_rg_name
}

data "azurerm_disk_encryption_set" "main" {
    name                = var.disk_encryption_set_name
    resource_group_name = var.resource_group_name
}

data "azurerm_log_analytics_workspace" "main" {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.law_resource_group_name
}
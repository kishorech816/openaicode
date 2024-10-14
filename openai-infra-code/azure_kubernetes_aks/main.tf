## Data Resources

data "azurerm_log_analytics_workspace" "law" {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.law_resource_group_name
}

data "azurerm_user_assigned_identity" "uami_shared_des" {
   name                 = var.uami_shared_des
   resource_group_name  = var.uami_resource_group
}

######3
module "aks_oi_dev_rg" {
    source = "../modules/resourcegroups"
    # Resource Group Variables
    az_rg_name      = "rg_oi_dev_aks_ne_01"
    az_rg_location  = "northeurope"
    az_tags         = {
        Role 		    = "DEV AKS"
        Owner 		    = "IT DevOps"
        Environment	    = "DEV"
        Criticality     = "Moderate"
    }
}
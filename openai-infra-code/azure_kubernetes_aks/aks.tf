
locals {
  vnet_name                       = local.settings.General.vnet_name
  vnet_name_resource_grp_name     = local.settings.General.vnet_name_resource_grp_name
  resource_group_name             = local.settings.General.app_resource_group_name
  app_subnet_name                 = local.settings.General.app_subnet_name
  shared_resource_group_name      = local.settings.General.shared_resource_group_name
  #Prometheus
  amw_dcr_name                    = local.settings.General.amw_dcr_name
  amw_dcp_name                    = local.settings.General.amw_dcp_name
  amw_resource_group_name         = local.settings.General.amw_resource_group_name

  enable_ip_configuration         = local.settings.Applications.keyvault.enable_ip_configuration
  private_endpoint_subnet_name    = local.settings.Applications.keyvault.private_endpoint_subnet_name
  private_endpoint_name           = local.settings.Applications.keyvault.private_endpoint_name
  private_service_connection_name = local.settings.Applications.keyvault.private_service_connection_name
  subresource_name                = local.settings.Applications.keyvault.subresource_name
  private_endpoint_ip             = local.settings.Applications.keyvault.private_endpoint_ip
  private_dns_zones_name          = local.settings.Applications.keyvault.private_dns_zones_name
  private_dns_zone_group_name     = local.settings.Applications.keyvault.private_dns_zone_group_name
  key_vault_name                  = local.settings.Applications.keyvault.name
  key_vault_rg_name               = local.settings.General.app_resource_group_name
  sku_name                        = can(local.settings.Applications.keyvault.sku_name) ? local.settings.Applications.keyvault.sku_name : var.sku_name
  soft_delete_retention_days      = local.settings.Applications.keyvault.soft_delete_retention_days
  admin_objects_ids               = local.settings.Applications.keyvault.admin_objects_ids
  reader_objects_ids              = local.settings.Applications.keyvault.reader_objects_ids
  private_dns_resource_group_name = local.settings.Applications.keyvault.private_dns_resource_group_name

  #LAW
  log_analytics_workspace_name                 = local.settings.Applications.keyvault.log_analytics_workspace_name
  log_analytics_workspace_resource_grp_name    = local.settings.Applications.keyvault.log_analytics_workspace_resource_grp_name
  log_analytics_workspace_enabled              = local.settings.Applications.aks.log_analytics_workspace_enabled
  #UAMI
  uami_shared_des_name = local.settings.General.uami_shared_des_name

  #AKS
  cluster_name          = local.settings.Applications.aks.cluster_name
  kubernetes_version    = local.settings.Applications.aks.kubernetes_version
  sku_tier              = local.settings.Applications.aks.sku_tier
  admin_group_object_id = local.settings.Applications.aks.admin_group_object_id
  uami_aks_cp           = local.settings.Applications.aks.uami_aks_cp
  uami_aks_rt           = local.settings.Applications.aks.uami_aks_rt
  uami_resource_group   = local.settings.Applications.aks.uami_resource_group


  tags = merge(var.tags, {
    Criticality = "Moderate"
    Application = "oi-dev-aks-ne"
    Environment = var.environment   
  })
}

module "aks" {
  source = "../modules/aks"
  resource_group_name           = module.aks_oi_dev_rg.rg_name
  vnet_name                     = local.vnet_name
  vnet_name_resource_grp_name   = local.vnet_name_resource_grp_name
  cluster_name                  = local.cluster_name
  kubernetes_version            = local.kubernetes_version
  sku_tier                      = local.sku_tier
  aks_subnet_name               = local.app_subnet_name
  environment                   = var.environment
  stack                         = ""
  admin_group_object_id         = local.admin_group_object_id
  key_vault_name                = local.key_vault_name
  key_vault_rg_name             = local.key_vault_rg_name
  uami_cp_aks                   = local.uami_aks_cp
  uami_rt_aks                   = local.uami_aks_rt
  uami_resource_group           = local.uami_resource_group
  log_analytics_workspace_name  = local.log_analytics_workspace_name
  law_resource_group_name       = local.log_analytics_workspace_resource_grp_name
  log_analytics_workspace_enabled = local.log_analytics_workspace_enabled
  defender_enabled              = true
  defender_law_id               = data.azurerm_log_analytics_workspace.defender_law_dev[0].id
  node_os_channel_upgrade       = var.node_os_channel_upgrade
  automatic_channel_upgrade     = var.automatic_channel_upgrade
  amw_dcr_name                  = local.amw_dcr_name
  amw_dcp_name                  = local.amw_dcp_name
  amw_resource_group_name       = local.amw_resource_group_name
 
  system_node_pool              = var.system_node_pool
  aks_app_node_pools            = var.aks_app_node_pools
  aks_spot_app_node_pools       = var.aks_spot_app_node_pools
  
  tags = local.tags

  depends_on = [ module.keyvault, module.private_endpoint]
}
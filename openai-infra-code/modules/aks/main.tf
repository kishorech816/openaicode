
resource "azurerm_kubernetes_cluster" "akscluster" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kubernetes_version  = var.kubernetes_version
  sku_tier            = var.sku_tier
  dns_prefix          = join ("", [var.cluster_name, "k8s"])
  private_cluster_enabled             = true
  private_cluster_public_fqdn_enabled = true
  private_dns_zone_id                 = "None"
  azure_policy_enabled                = var.azure_policy_enabled
  role_based_access_control_enabled   = true
  disk_encryption_set_id              = data.azurerm_disk_encryption_set.main.id
  local_account_disabled              = true
  oidc_issuer_enabled                 = true
  workload_identity_enabled           = true
  automatic_channel_upgrade           = var.automatic_channel_upgrade
  node_os_channel_upgrade             = var.node_os_channel_upgrade

  node_resource_group                 = join("_",["MC", var.cluster_name ])

  auto_scaler_profile {
    balance_similar_node_groups = true
    expander                    = "priority"
  }

  default_node_pool {
    name                = var.system_node_pool["name"]
    max_count           = var.system_node_pool["max_count"]
    min_count           = var.system_node_pool["min_count"]
    enable_auto_scaling = var.system_node_pool["enable_auto_scaling"]
    vm_size             = var.system_node_pool["vm_size"]
    os_sku              = var.system_node_pool["os_sku"]
    os_disk_size_gb     = var.system_node_pool["os_disk_size_gb"]
    max_pods            = var.system_node_pool["max_pods"]
    node_taints         = var.system_node_pool["node_taints"]
    zones               = var.system_node_pool["zones"]
    vnet_subnet_id      = data.azurerm_subnet.aks_subnet.id
    type                = "VirtualMachineScaleSets"
    temporary_name_for_rotation = "temppool"
    enable_host_encryption      = true
    orchestrator_version = var.kubernetes_version
    only_critical_addons_enabled = true
    

    upgrade_settings {
      max_surge = var.system_node_pool["upgrade_max_surge"]
    }   

  }

  # Control Plan UAMI
  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.uami_cp_aks.id]
  }

  # Kubelet UAMI
  kubelet_identity {
     client_id = data.azurerm_user_assigned_identity.uami_rt_aks.client_id
     object_id = data.azurerm_user_assigned_identity.uami_rt_aks.principal_id
     user_assigned_identity_id = data.azurerm_user_assigned_identity.uami_rt_aks.id
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
    secret_rotation_interval = "6h"
  }

  network_profile {
    network_plugin              = var.network_profile["network_plugin"]
    network_plugin_mode         = var.network_profile["network_plugin_mode"]
    ebpf_data_plane             = var.network_profile["ebpf_data_plane"]
    #network_policy              = var.network_profile["network_policy"]
    load_balancer_sku           = var.network_profile["load_balancer_sku"]
    pod_cidr                    = var.network_profile["pod_cidr"]
    service_cidr                = var.network_profile["service_cidr"]
    dns_service_ip              = var.network_profile["dns_service_ip"]
    outbound_type               = var.network_profile["outbound_type"]  
  }

  azure_active_directory_role_based_access_control {
    managed = true
    tenant_id = data.azurerm_client_config.current.tenant_id
    admin_group_object_ids = tolist([var.admin_group_object_id])
    azure_rbac_enabled = true
  }

  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_enabled ? ["oms_agent"] : []

    content {
      log_analytics_workspace_id = data.azurerm_log_analytics_workspace.main.id
      msi_auth_for_monitoring_enabled = true
    }
  }

  dynamic "microsoft_defender" {
    for_each = var.defender_enabled ? ["microsoft_defender"] : []

    content {
      log_analytics_workspace_id = var.defender_law_id
    }  
  }

  lifecycle {
    ignore_changes = [ 
        default_node_pool[0].node_count,
        tags,
     ]
  }

  tags = merge(var.tags, {
    Operational-Schedule = "Yes"
  })
}

resource "azurerm_monitor_diagnostic_setting" "example" {
  name                        = "ds-aks-logs"
  target_resource_id          = azurerm_kubernetes_cluster.akscluster.id
  log_analytics_workspace_id  = data.azurerm_log_analytics_workspace.main.id

  enabled_log  {
    category = "cluster-autoscaler"
  }
  enabled_log {
    category = "kube-audit-admin" 
  }
  metric {
    category = "AllMetrics"
    enabled  = false
  }          
}

resource "azurerm_kubernetes_cluster_node_pool" "appnodepools" {
  for_each = var.aks_app_node_pools

  name                  = each.key
  vm_size               = each.value["vm_size"]
  max_count             = each.value["max_count"]
  min_count             = each.value["min_count"]
  enable_auto_scaling   = each.value["enable_auto_scaling"]
  os_sku                = each.value["os_sku"]
  os_disk_size_gb       = each.value["os_disk_size_gb"]
  max_pods              = each.value["max_pods"]
  mode                  = each.value["mode"]
  priority              = each.value["priority"]
  node_taints           = each.value["node_taints"]
  zones                 = each.value["zones"]
  node_labels           = each.value["node_labels"]

  upgrade_settings {
    max_surge = each.value["upgrade_max_surge"]
  }

  kubernetes_cluster_id = azurerm_kubernetes_cluster.akscluster.id
  vnet_subnet_id        = data.azurerm_subnet.aks_subnet.id
  orchestrator_version  = var.kubernetes_version

  depends_on = [ azurerm_kubernetes_cluster.akscluster ]

  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "spot_appnodepools" {
  for_each = var.aks_spot_app_node_pools

  name                  = each.key
  vm_size               = each.value["vm_size"]
  max_count             = each.value["max_count"]
  min_count             = each.value["min_count"]
  enable_auto_scaling   = each.value["enable_auto_scaling"]
  os_sku                = each.value["os_sku"]
  os_disk_size_gb       = each.value["os_disk_size_gb"]
  max_pods              = each.value["max_pods"]
  mode                  = each.value["mode"]
  priority              = each.value["priority"]
  eviction_policy       = "Delete"
  node_taints           = each.value["node_taints"]
  zones                 = each.value["zones"]
  node_labels           = each.value["node_labels"]

  kubernetes_cluster_id = azurerm_kubernetes_cluster.akscluster.id
  vnet_subnet_id        = data.azurerm_subnet.aks_subnet.id
  orchestrator_version  = var.kubernetes_version

  depends_on = [ azurerm_kubernetes_cluster.akscluster ]

  tags = var.tags
}
module "keyvault" {
    source              = "../modules/key_vault"
    location            = module.aks_oi_dev_rg.rg_location
    custom_name         = "kv-oi-dev-aks-ne-01"
    sku_name            = "standard"
    resource_group_name = module.aks_oi_dev_rg.rg_name
    environment         = var.environment

    public_network_access_enabled = false
    rbac_authorization_enabled = true
    enabled_for_disk_encryption = true

    # WebApp or other applications Object IDs
    reader_objects_ids = [ 
      data.azurerm_user_assigned_identity.uami_shared_des.principal_id
    ]
    # key vault admin group id
    admin_objects_ids = [
      "xxxxxxxxxxxxxxxxxxxxxx"
    ]
    logs_destinations_ids = [data.azurerm_log_analytics_workspace.law.id]

    # Specify Network ACLs
    network_acls = {
      bypass         = "AzureServices"
      default_action = "Deny"
      ip_rules       = ["x.x.x.x/32"]  ## your org public ip's
      #virtual_network_subnet_ids = var.subnet_ids
    }
  
    extra_tags = var.extra_tags
}

module "private_endpoint" {
  source = "../modules/privateendpoint"
  providers = { azurerm.hub-subscription = azurerm.hub-subscription
    azurerm = azurerm
  }
  private_dns_resource_group_name = var.private_dns_resource_group_name
  location                        = module.aks_oi_dev_rg.rg_location
  resource_group_name             = module.aks_oi_dev_rg.rg_name
  vnet_name                       = var.vnet_name
  vnet_name_resource_grp_name     = var.vnet_name_resource_grp_name
  private_endpoint_subnet_name    = var.private_endpoint_subnet_name
  target_resource                 = module.keyvault.key_vault_id
  private_endpoint_name           = var.private_endpoint_name
  enable_ip_configuration         = var.enable_ip_configuration
  private_endpoint_ip             = var.private_endpoint_ip
  subresource_name                = var.subresource_name
  private_service_connection_name = var.private_service_connection_name
  private_dns_zones_name          = var.private_dns_zones_name
  private_dns_zone_group_name     = var.private_dns_zone_group_name
  tags                            = var.extra_tags
}


resource "azurerm_key_vault_key" "this" {
  name         = "des-dev-oi-aks-key"
  key_vault_id = module.keyvault.key_vault_id
  key_type     = "RSA"
  key_size     = 2048

  depends_on = [ module.keyvault ]

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

resource "azurerm_disk_encryption_set" "main" {
  name                = "OSDiskEncryptionCMK"
  resource_group_name = module.aks_oi_dev_rg.rg_name
  location            = module.aks_oi_dev_rg.rg_location
  key_vault_key_id    = azurerm_key_vault_key.this.id

  identity {
    type = "UserAssigned"
    identity_ids = [
       data.azurerm_user_assigned_identity.uami_shared_des.id,
      ]
  }
  depends_on = [ module.keyvault ]
  tags                = var.default_tags
}
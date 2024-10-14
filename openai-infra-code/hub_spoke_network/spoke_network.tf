# Resource Group Module is Used to Create Resource Groups

module "np_spk_dev_resourcegroup" {
    source = "../modules/resourcegroups"
    # Resource Group Variables
    az_rg_name      = "rg_oi_dev_spknet_ne_01"
    az_rg_location  = "northeurope"
    az_tags         = {
        Role 		    = "Network"
        Owner 		    = "IT Network"
        Environment	    = "DEV"
        Criticality     = "Moderate"
    }
}

# vnet Module is used to create Virtual Networks and Subnets
module "dev_vnet" {
source = "../modules/vnet"

virtual_network_name              = "vnet_oi_dev_ne_01"
resource_group_name               = module.np_spk_dev_resourcegroup.rg_name
location                          = module.np_spk_dev_resourcegroup.rg_location
virtual_network_address_space     = ["10.244.0.0/16"]

subnet_names = {
    "snet_dev_aks_ne_01" = {
        subnet_name = "snet_dev_aks_ne_01"
        address_prefixes = ["10.244.1.0/24"]
        route_table_name = ""
        snet_delegation  = ""
        },
    "snet_dev_db_ne_01" = {
        subnet_name = "snet_dev_db_ne_01"
        address_prefixes = ["10.244.2.0/24"]
        route_table_name = ""
        snet_delegation  = ""
        }
    "snet_dev_pe_ne_01" = {
        subnet_name = "snet_dev_pe_ne_01"
        address_prefixes = ["10.244.3.0/24"]
        route_table_name = ""
        snet_delegation  = ""
        }
    }   
    az_tags         = {
        Role 		    = "Network"
        Owner 		    = "IT Network"
        Environment	    = "DEV"
        Criticality     = "Moderate"
    }
}


# routetables Module is used to create route tables and associate them with Subnets created by Virtual Networks
module "dev_route_tables_01" {
source = "../modules/spoke_routetables"
depends_on = [ module.dev_vnet ]

route_table_name              = "rt_snet_dev_aks_ne_01"
location                      = module.np_spk_dev_resourcegroup.rg_location
resource_group_name           = module.np_spk_dev_resourcegroup.rg_name
bgp_route_propagation_enabled = false

  routes = [
    {
      name                   = "ToAzureFirewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = module.azure_firewall_01.azure_firewall_private_ip
    },
    {
      name                   = "VNet"
      address_prefix         = "10.244.0.0/16"
      next_hop_type          = "VnetLocal"
    }
  ]
  subnet_ids     = [
    module.dev_vnet.vnet_subnet_id[0]
  ]
}

module "dev_nsg_01" {
  source              = "../modules/nsg"
  nsg_name            = "nsg_snet_dev_aks_ne_01"
  location            = module.np_spk_dev_resourcegroup.rg_location
  resource_group_name = module.np_spk_dev_resourcegroup.rg_name

  nsg_rules = [
    {
      name                        = "Allow-SSH"
      priority                    = 200
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "22"
      source_address_prefix       = "10.243.4.0/24"
      destination_address_prefix  = "*"
    },
  ]
  subnet_ids = [
    module.dev_vnet.vnet_subnet_id[0]
  ]
}


module "dev_route_tables_02" {
source = "../modules/spoke_routetables"
depends_on = [ module.dev_vnet ]

route_table_name              = "rt_snet_dev_db_ne_01"
location                      = module.np_spk_dev_resourcegroup.rg_location
resource_group_name           = module.np_spk_dev_resourcegroup.rg_name
bgp_route_propagation_enabled = false

  routes = [
    {
      name                   = "ToAzureFirewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = module.azure_firewall_01.azure_firewall_private_ip
    }
  ]
  subnet_ids     = [
    module.dev_vnet.vnet_subnet_id[1]
  ]
}

module "dev_nsg_02" {
  source              = "../modules/nsg"
  nsg_name            = "nsg_snet_dev_db_ne_01"
  location            = module.np_spk_dev_resourcegroup.rg_location
  resource_group_name = module.np_spk_dev_resourcegroup.rg_name

  nsg_rules = [
    {
      name                        = "Allow-SSH"
      priority                    = 200
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "22"
      source_address_prefix       = "10.243.4.0/24"
      destination_address_prefix  = "*"
    },
  ]
  subnet_ids = [
    module.dev_vnet.vnet_subnet_id[1]
  ]
}

#### AKS Pre-Prequisites Resources ####

module "np_dev_shared_rg" {
    source = "../modules/resourcegroups"
    # Resource Group Variables
    az_rg_name      = "rg_oi_dev_shared_ne_01"
    az_rg_location  = "northeurope"
    az_tags         = {
        Role 		        = "Shared Resources"
        Owner 		      = "IT DevOps"
        Environment	    = "DEV"
        Criticality     = "High"
    }
}
resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-spk-dev-shared-ne-001"
  location            = module.np_dev_shared_rg.rg_location
  resource_group_name = module.np_dev_shared_rg.rg_name
  retention_in_days   = 90
}
## User Assigned Managed Identity of AKS control Plane and Worker Nodes
data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

resource "azurerm_user_assigned_identity" "uami_cp_aks" {
  name                = "UAMI_AKS_CP_DEV_NE_01"
  location            = module.np_dev_shared_rg.rg_location
  resource_group_name = module.np_dev_shared_rg.rg_name
}
resource "azurerm_user_assigned_identity" "uami_rt_aks" {
  name                =  "UAMI_AKS_RT_DEV_NE_01"
  location            = module.np_dev_shared_rg.rg_location
  resource_group_name = module.np_dev_shared_rg.rg_name
}
resource "azurerm_user_assigned_identity" "uami_shared_des" {
  name                = "UAMI_AKS_Shared_DEV_NE_01"
  location            = module.np_dev_shared_rg.rg_location
  resource_group_name = module.np_dev_shared_rg.rg_name
}

resource "azurerm_role_assignment" "uami_shared_des_01" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_user_assigned_identity.uami_shared_des.principal_id
}

#### Reader Permissions on Disk Encryption set's  Resource Group level
resource "azurerm_role_assignment" "uami_cp_aks_01" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/rg_oi_dev_shared_ne_01"
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.uami_cp_aks.principal_id
  depends_on = [ module.np_dev_shared_rg ]
}
## Managed Identity Operator Permissions on UAMI Resource group level
resource "azurerm_role_assignment" "uami_cp_aks_02" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/rg_oi_dev_shared_ne_01"
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.uami_cp_aks.principal_id
  depends_on = [ module.np_dev_shared_rg ]
}
## Network contributor Permissions on Virtual network Resource group level
resource "azurerm_role_assignment" "uami_cp_aks_03" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/rg_oi_dev_shared_ne_01"
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.uami_cp_aks.principal_id
  depends_on = [ module.np_spk_dev_resourcegroup ]
}
##UAMI RT AcrPull permissions on ACR level
resource "azurerm_role_assignment" "uami_rt_aks_01" {
  scope                = "/subscriptions/37da16dc-bccb-4a99-8daf-ab4f98d69736/resourceGroups/rg-oi-dev-shared-uaen-01"
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.uami_rt_aks.principal_id
  depends_on = [ module.np_dev_shared_rg ]
}

module spk_key_vault {
  source = "../modules/key_vault"
  client_name         = ""
  location            = module.np_dev_shared_rg.rg_location
  custom_name         = "kv-dev-shard-ne-01"
  sku_name            = "standard"
  resource_group_name = module.np_dev_shared_rg.rg_name
  environment         = "DEV"
  stack               = "shardser"

  public_network_access_enabled = false
  rbac_authorization_enabled = true
  # WebApp or other applications Object IDs
  reader_objects_ids = []
  # key vauly admin group id
  admin_objects_ids = [
    "xxxxx-xxxxxx-xxxxxxx-xxxxxx"
  ]
  logs_destinations_ids = [azurerm_log_analytics_workspace.law.id]
 # Specify Network ACLs
  network_acls = {
    bypass         = "AzureServices"
    default_action = "Deny"
    #virtual_network_subnet_ids = var.subnet_ids
  }
}
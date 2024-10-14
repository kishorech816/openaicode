
# Resource Group Module is Used to Create Resource Groups
module "np_hub_resourcegroup" {
    source = "../modules/resourcegroups"
    # Resource Group Variables
    az_rg_name      = "rg-oi-hub-net-uaen-01"
    az_rg_location  = "northeurope"
    az_tags         = {
        Role 		    = "Network"
        Owner 		    = "IT Network"
        Environment	    = "DEVHUB"
        Criticality     = "High"
    }
}

# vnet Module is used to create Virtual Networks and Subnets
module "hub-vnet" {
source = "../modules/vnet"

virtual_network_name              = "vnet_np_hub_ne_01"
resource_group_name               = module.np_hub_resourcegroup.rg_name
location                          = module.np_hub_resourcegroup.rg_location
virtual_network_address_space     = ["10.243.0.0/16"]
# Subnets are used in Index for other modules to refer
# module.hub-vnet.vnet_subnet_id[0] = ApplicationGatewaySubnet   - Alphabetical Order
# module.hub-vnet.vnet_subnet_id[1] = AzureBastionSubnet         - Alphabetical Order
# module.hub-vnet.vnet_subnet_id[2] = AzureFirewallSubnet        - Alphabetical Order
# module.hub-vnet.vnet_subnet_id[3] = GatewaySubnet              - Alphabetical Order
# module.hub-vnet.vnet_subnet_id[4] = JumpboxSubnet              - Alphabetical Order

subnet_names = {
    "ApplicationGatewaySubnet" = {
        subnet_name = "ApplicationGatewaySubnet"
        address_prefixes = ["10.243.3.0/24"]
        route_table_name = ""
        snet_delegation  = ""
       }
    "AzureBastionSubnet" = {
        subnet_name = "AzureBastionSubnet"
        address_prefixes = ["10.243.4.0/24"]
        route_table_name = ""
        snet_delegation  = ""
       }
    "AzureFirewallSubnet" = {
        subnet_name = "AzureFirewallSubnet"
        address_prefixes = ["10.243.2.0/24"]
        route_table_name = ""
        snet_delegation  = ""
    },
    "GatewaySubnet" = {
        subnet_name = "GatewaySubnet"
        address_prefixes = ["10.243.1.0/24"]
        route_table_name = ""
        snet_delegation  = ""
    },
    }
    
    az_tags         = {
        Role 		    = "Network"
        Owner 		    = "IT Network"
        Environment	    = "DEVHUB"
        Criticality     = "High"
    }
}

# routetables Module is used to create route tables and associate them with Subnets created by Virtual Networks
module "fw_route_tables" {
source = "../modules/hub_routetables"
depends_on = [ module.hub-vnet ]

route_table_name              = "rt_np_hub_fw_ne_01"
location                      = module.np_hub_resourcegroup.rg_location
resource_group_name           = module.np_hub_resourcegroup.rg_name
bgp_route_propagation_enabled = false

  routes = [
    {
      name                   = "internet"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "Internet"
    }
  ]
  subnet_ids                    = [
    module.hub-vnet.vnet_subnet_id[2]
  ]
}

# azurefirewall Module is used to create Azure Firewall 

module "np_hub_resourcegroup_azfw" {
    source = "../modules/resourcegroups"
    # Resource Group Variables
    az_rg_name      = "rg-oi-hub-azfw-uaen-01"
    az_rg_location  = "northeurope"
    az_tags         = {
        Role 		    = "Firewall"
        Owner 		    = "IT Network"
        Environment	    = "DEVHUB"
        Criticality     = "High"
    }
}

# publicip Module is used to create Public IP Address
module "public_ip_01" {
source = "../modules/publicip"

# Used for Azure Firewall 
public_ip_name      = "pip-np-hub-afw-ne-01"
resource_group_name = module.np_hub_resourcegroup_azfw.rg_name
location            = module.np_hub_resourcegroup_azfw.rg_location
allocation_method   = "Static"
sku                 = "Standard"
}

module "azure_firewall_01" {
source = "../modules/azurefirewall"
depends_on = [module.hub-vnet]

  azure_firewall_name = "afw-np-hub-ne-01"
  resource_group_name = module.np_hub_resourcegroup_azfw.rg_name
  location            = module.np_hub_resourcegroup_azfw.rg_location
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ipconfig_name        = "configuration"
  subnet_id            = module.hub-vnet.vnet_subnet_id[2]
  public_ip_address_id = module.public_ip_01.public_ip_address_id

  azure_firewall_policy_coll_group_name  = "afw-np-hub-ne-01-coll-pol01" 
  azure_firewall_policy_name             = "afw-np-hub-ne-01-pol01"  
  priority                               = 100 

  network_rule_coll_name_01     = "Allowed_Network_Rules"
  network_rule_coll_priority_01 = "3000"
  network_rule_coll_action_01   = "Allow"
  network_rules_01 = [   
        {    
            name                  = "Allowed_Network_rule_1"
            source_addresses      = ["10.1.0.0/16"]
            destination_addresses = ["172.21.1.10", "8.10.4.4"]
            destination_ports     = [11]
            protocols             = ["TCP"]
        }
    ]  

 application_rule_coll_name     = "Allowed_websites"
 application_rule_coll_priority = "4000"
 application_rule_coll_action   = "Allow"
 application_rules = [   
        {    
            name                  = "Allowed_website_01"
            source_addresses      = ["*"]
            destination_fqdns     = ["bing.co.uk"]
        },
        {    
            name                  = "Allowed_website_02"
            source_addresses      = ["*"]
            destination_fqdns     = ["*.bing.com"]
        }
    ]  
 application_protocols = [   
        {    
            type = "Http"
            port = 80
        },
        {
            type = "Https"
            port = 443
        }
    ]
}   


### bastion host

module "np_hub_resourcegroup_bastion" {
    source = "../modules/resourcegroups"
    # Resource Group Variables
    az_rg_name      = "rg-oi-hub-bastion-uaen-01"
    az_rg_location  = "northeurope"
    az_tags         = {
        Role 		    = "Bastion"
        Owner 		    = "IT Network"
        Environment	    = "DEVHUB"
        Criticality     = "High"
    }
}

# publicip Module is used to create Public IP Address
module "public_ip_02" {
source = "../modules/publicip"

# Used for Azure Bastion
public_ip_name      = "pip-np-hub-bastion-ne-01"
resource_group_name = module.np_hub_resourcegroup_bastion.rg_name
location            = module.np_hub_resourcegroup_bastion.rg_location
allocation_method   = "Static"
sku                 = "Standard"
}

module "vm-bastion" {
source = "../modules/bastion"

bastion_host_name              = "bation-np-hub-ne-jmp-01"
resource_group_name            = module.np_hub_resourcegroup_bastion.rg_name
location                       = module.np_hub_resourcegroup_bastion.rg_location

ipconfig_name                  =  "configuration"        
subnet_id                      =  module.hub-vnet.vnet_subnet_id[1]
public_ip_address_id           =  module.public_ip_02.public_ip_address_id

depends_on = [module.hub-vnet ]
}

##
module "np_hub_resourcegroup_dnszone" {
    source = "../modules/resourcegroups"
    # Resource Group Variables
    az_rg_name      = "rg-Shared_PrivateDNSzone_hub-ne-001"
    az_rg_location  = "northeurope"
    az_tags         = {
        Role 		    = "DNSZONES"
        Owner 		    = "IT Network"
        Environment	    = "DEVHUB"
        Criticality     = "High"
    }
}


module "private_dns_zone" {
  source              = "../modules/privatednszone"
  dns_zone_name       = "privatelink.blob.core.windows.net"
  resource_group_name = module.np_hub_resourcegroup_dnszone.rg_name

  virtual_network_links = [
    {
      link_name            = "vnet-link-1"
      virtual_network_id   = module.hub-vnet.vnet_id
      registration_enabled = false
    },
    {
      link_name            = "vnet-link-2"
      virtual_network_id   = module.dev_vnet.vnet_id
      registration_enabled = false
    }
  ]
  depends_on = [module.hub-vnet, module.dev_vnet, module.np_hub_resourcegroup_dnszone ]
}

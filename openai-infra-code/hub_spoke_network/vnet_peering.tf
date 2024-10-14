# vnet-peering Module is used to create peering between Virtual Networks
module "hub_to_dev_spoke_01" {
source = "../modules/vnet-peering"
depends_on = [module.hub-vnet, module.dev_vnet ]
#depends_on = [module.hub-vnet , module.spoke1-vnet , module.application_gateway, module.vpn_gateway , module.azure_firewall_01]

virtual_network_peering_name = "vnet_np_hub_ne_01_to_vnet_oi_dev_ne_01"
resource_group_name          = module.np_hub_resourcegroup.rg_name
virtual_network_name         = module.hub-vnet.vnet_name
remote_virtual_network_id    = module.dev_vnet.vnet_id
allow_virtual_network_access = "true"
allow_forwarded_traffic      = "true"
allow_gateway_transit        = "true"
use_remote_gateways          = "false"
}

# vnet-peering Module is used to create peering between Virtual Networks
module "dev_spoke_to_hub_01" {
source = "../modules/vnet-peering"
depends_on = [module.hub-vnet, module.dev_vnet ]

virtual_network_peering_name = "vnet_oi_dev_ne_01_to_vnet_np_hub_ne_01"
resource_group_name          = module.np_spk_dev_resourcegroup.rg_name
virtual_network_name         = module.dev_vnet.vnet_name
remote_virtual_network_id    = module.hub-vnet.vnet_id
allow_virtual_network_access = "true"
allow_forwarded_traffic      = "true"
allow_gateway_transit        = "false"
# As there is no gateway while testing - Setting to False
#use_remote_gateways   = "true"
use_remote_gateways          = "false"
}
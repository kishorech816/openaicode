locals {
  resource_alias              = length(regexall("^([a-z0-9\\-]+)\\.([a-z0-9\\-]+)\\.([a-z]+)\\.(azure)\\.(privatelinkservice)$", var.target_resource)) == 1 ? var.target_resource : null
  resource_id                 = length(regexall("^\\/(subscriptions)\\/([a-z0-9\\-]+)\\/(resourceGroups)\\/([A-Za-z0-9\\-_]+)\\/(providers)\\/([A-Za-z\\.]+)\\/([A-Za-z]+)\\/([A-Za-z0-9\\-]+)$", var.target_resource)) == 1 ? var.target_resource : null
  is_not_private_link_service = local.resource_alias == null && !contains(try(split("/", local.resource_id), []), "privateLinkServices")
}

data "azurerm_virtual_network" "vnet_name" {
  name                = var.vnet_name
  resource_group_name = var.vnet_name_resource_grp_name
}

data "azurerm_subnet" "subnet_name" {
  name                 = var.private_endpoint_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_name_resource_grp_name
}

data "azurerm_private_dns_zone" "private_dns_zone" {
  provider = azurerm.hub-subscription
  name                = var.private_dns_zones_name
  resource_group_name = var.private_dns_resource_group_name
}


resource "azurerm_private_endpoint" "private_endpoint" {
  name                = var.private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.subnet_name.id
  tags                = var.tags

  dynamic "private_dns_zone_group" {
    for_each = local.is_not_private_link_service ? ["private_dns_zone_group"] : []
    content {
      name                 = var.private_dns_zone_group_name
      private_dns_zone_ids = [
        data.azurerm_private_dns_zone.private_dns_zone.id
      ]
    }
  }

  private_service_connection {
    name                              = var.private_service_connection_name
    is_manual_connection              = var.is_manual_connection
    request_message                   = var.is_manual_connection ? var.request_message : null
    private_connection_resource_id    = local.resource_id
    private_connection_resource_alias = local.resource_alias
    subresource_names                 = [var.subresource_name]
  }
  dynamic "ip_configuration" {
    for_each = var.enable_ip_configuration ? ["ip_configuration"] : []
    content {
      name               = "${var.private_endpoint_name}-ip"
      private_ip_address = var.private_endpoint_ip
      subresource_name   = var.subresource_name
    }
  }
}

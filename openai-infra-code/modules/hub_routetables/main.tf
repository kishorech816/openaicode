resource "azurerm_route_table" "hub_route_table" {
    name                          = var.route_table_name
    location                      = var.location
    resource_group_name           = var.resource_group_name
    bgp_route_propagation_enabled = var.bgp_route_propagation_enabled

  dynamic "route" {
    for_each = var.routes
    content {
      name                   = route.value["name"]
      address_prefix         = route.value["address_prefix"]
      next_hop_type          = route.value["next_hop_type"]
      next_hop_in_ip_address = lookup(route.value, "next_hop_in_ip_address", null)
    }
  }
}

resource "azurerm_subnet_route_table_association" "rt_subnet_assoc" {
  count          = length(var.subnet_ids)
  subnet_id      = var.subnet_ids[count.index]
  route_table_id = azurerm_route_table.hub_route_table.id
}
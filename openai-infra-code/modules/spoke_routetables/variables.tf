variable "route_table_name" {
  type        = string
  description = "The name of the resource group in which to create the virtual network peering."
}

variable "location" {
  type        = string
  description = "The name of the resource group in which to create the virtual network peering."
}

variable "resource_group_name" {

  description = "The full Azure resource ID of the remote virtual network."
}

variable "bgp_route_propagation_enabled" {

  description = "The full Azure resource ID of the remote virtual network."
}

variable "subnet_ids" {
  description = "The full Azure resource ID of the remote virtual network."
  default     = ""
}

variable "routes" {
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
}
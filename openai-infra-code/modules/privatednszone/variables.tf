variable "dns_zone_name" {
  description = "The name of the DNS zone to create"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the DNS zone"
  type        = string
}

variable "virtual_network_links" {
  description = "List of virtual networks to link to the DNS zone"
  type = list(object({
    link_name            = string
    virtual_network_id   = string
    registration_enabled = bool
  }))
}

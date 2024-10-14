#V.net variables
variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
}

variable "vnet_name_resource_grp_name" {
  description = "Name of the Resource of the Virtual Network."
  type        = string
}

variable "private_endpoint_subnet_name" {
  description = "Name of the subnet which private endpoint should create."
  type        = string 
}

### Generic variables 
variable "location" {
  description = "Azure location."
  type        = string
}

variable "private_dns_resource_group_name" {
  description = "Resource group for private DNS"
  type        = string
  default     = ""

}
variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "private_endpoint_name" {
  type        = string
  description = "Private Endpoint name"
  default     = ""
}

variable "enable_ip_configuration" {
  type        = bool
  description = "Enable IP Configuration"
  default     = false
}

variable "private_endpoint_ip" {
  type        = string
  description = "Private Endpoint IP"
  default     = ""
}

variable "private_dns_zone_group_name" {
  type        = string
  description = "Private DNS Zone Group name"
  default     = ""
}

variable "private_service_connection_name" {
  type        = string
  description = "Private Service Connection name"
  default     = ""
}

variable "is_manual_connection" {
  description = "Does the Private Endpoint require manual approval from the remote resource owner? Default to `false`."
  type        = bool
  default     = false
}

variable "request_message" {
  description = "A message passed to the owner of the remote resource when the Private Endpoint attempts to establish the connection to the remote resource. Only valid if `is_manual_connection` is set to `true`."
  type        = string
  default     = "Private Endpoint Deployment"
}

variable "target_resource" {
  description = "Private Link Service Alias or ID of the target resource."
  type        = string

  validation {
    condition     = length(regexall("^([a-z0-9\\-]+)\\.([a-z0-9\\-]+)\\.([a-z]+)\\.(azure)\\.(privatelinkservice)$", var.target_resource)) == 1 || length(regexall("^\\/(subscriptions)\\/([a-z0-9\\-]+)\\/(resourceGroups)\\/([A-Za-z0-9\\-_]+)\\/(providers)\\/([A-Za-z\\.]+)\\/([A-Za-z]+)\\/([A-Za-z0-9\\-]+)$", var.target_resource)) == 1
    error_message = "The `target_resource` variable must be a Private Link Service Alias or a resource ID."
  }
}

variable "subresource_name" {
  description = "Name of the subresource corresponding to the target Azure resource. Only valid if `target_resource` is not a Private Link Service."
  type        = string
  default     = ""
}

variable "use_existing_private_dns_zones" {
  description = "Boolean to create the Private DNS Zones corresponding to the Private Endpoint. If you wish to centralize the Private DNS Zones in another Resource Group that could belong to another subscription, set this option to `true` and use the `private-dns-zone` submodule directly."
  type        = bool
  default     = false
}

variable "private_dns_zones_ids" {
  description = "IDs of the Private DNS Zones in which a new record will be created for the Private Endpoint. Only valid if `use_existing_private_dns_zones` is set to `true` and `target_resource` is not a Private Link Service. One of `private_dns_zones_ids` or `private_dns_zones_names` must be specified."
  type        = list(string)
  default     = []
}

variable "private_dns_zones_name" {
  description = "Private DNS Zone names"
  type        = string
  default     = ""
}

variable "private_dns_zones_vnets_ids" {
  description = "IDs of the VNets to link to the Private DNS Zones. Only valid if `use_existing_private_dns_zones` is set to `false` and `target_resource` is not a Private Link Service."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags"
  type        = map(string)
}

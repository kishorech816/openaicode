variable "environment" {
    description = "Please provide the environment name"
    type        = string
}


### Data Resource variables ####3
variable "uami_shared_des" {
    description = "please provide the disk encryption set uami name"
    type = string
}
variable "uami_resource_group" {
    description = "please provide the disk encryption set uami corresponding resource group"
    type = string
}

variable "log_analytics_workspace_name" {
  description = "Please provide the log analytics worksapce name."
  type = string
}

variable "law_resource_group_name" {
  description = "Please provide the log analytcis resource group name."
  type = string
}

#############
# Network
variable "vnet_name" {
  type = string
  description = "Please provide virtual network"  
}
variable "vnet_name_resource_grp_name" {
  type = string
  description = "Please provide virtual network resource group."  
}

# Private Endpoint
variable "private_endpoint_subnet_name" {
  type        = string
  description = "The ID of the subnet to which the private endpoint should be attached"
}
variable "private_endpoint_name" {
  type        = string
  description = "The name of the private endpoint"
}
variable "enable_ip_configuration" {
  type        = bool
  description = "Whether to enable IP configuration"
  default     = false
}
variable "private_service_connection_name" {
  type        = string
  description = "The name of the private service connection"
}
variable "private_endpoint_ip" {
  type        = string
  description = "The IP address of the private endpoint"
}
variable "sa_private_endpoint_ip" {
  type        = string
  description = "The IP address of the private endpoint"
}
variable "subresource_name" {
  type        = string
  description = "The name of the subresource"
}
variable "private_dns_zones_name" {
  type        = string
  description = "The name of the private DNS zone"
}
variable "private_dns_zone_group_name" {
  type        = string
  description = "The name of the private DNS zone group"
}
variable "private_dns_resource_group_name" {
  type        = string
  description = "The name of the private DNS zone Resource Group."
}
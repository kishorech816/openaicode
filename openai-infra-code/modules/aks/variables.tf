variable "vnet_name_resource_grp_name" {
  type    = string
}

variable "vnet_name" {
  type    = string  
}

variable "aks_subnet_name" {
  type    = string
}

variable "resource_group_name" {
  type    = string
}
variable "uami_resource_group" {
  type = string
}

variable "location" {
  type    = string
  default = "uaenorth"
}

variable "location_short" {
  description = "Short string for Azure location."
  type        = string
  default = "uaen"
}

variable "environment" {
  description = "Project environment."
  type        = string
}

variable "stack" {
  description = "Project stack name."
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

###############################################
## Kubernetes Variables ####

variable "kubernetes_version" {
  type = string
}
variable "sku_tier" {
  type = string
}

variable "cluster_name" {
  description = "Custom Azure Container Registry name, generated if not set"
  type        = string

  validation {
    condition     = can(regex("aks_*", var.cluster_name))
    error_message = "The variable must start with 'aks'"
  } 
}

variable "uami_cp_aks" {
  description = "Please provide the AKS Control Plane User Managed Identity"
  type = string

  validation {
    condition     = can(regex("UAMI_*", var.uami_cp_aks))
    error_message = "The variable must start with 'UAMI'"
  }  
}

variable "uami_rt_aks" {
  description = "Please provide the AKS Control Plane User Managed Identity"
  type = string

  validation {
    condition     = can(regex("UAMI_*", var.uami_rt_aks))
    error_message = "The variable must start with 'UAMI'"
  } 
}

variable "azure_policy_enabled" {
  type = bool  
  default = true
}

variable "system_node_pool" {
 description = "Default System node pool"
 type = object({
    name      = string
    max_count = number
    min_count = number
    enable_auto_scaling = bool
    vm_size             = string
    os_sku             = string
    os_disk_size_gb     = number
    max_pods            = number
    node_taints         = list(string)
    zones               = list(string)
    upgrade_max_surge   = number
 })
 default = {
    name = "systempool"
    max_count           = 3
    min_count           = 2
    enable_auto_scaling = true
    vm_size             = "Standard_D2ds_v5"
    os_sku             = "AzureLinux"
    os_disk_size_gb     = 50
    max_pods            = 30
    node_taints         = []
    zones               = ["1","2","3"]
    upgrade_max_surge   = 1
 }  
}

variable "aks_app_node_pools" {
 description = "Additional user / app node pools"
 type = map(object({
   max_count           = number
   min_count           = number
   enable_auto_scaling = bool
   vm_size             = string
   os_sku              = string
   os_disk_size_gb     = number
   max_pods            = number
   mode                = string
   priority            = string
   node_taints         = list(string)
   zones               = list(string)
   node_labels         = map(string)
   upgrade_max_surge   = number
 }))
}

variable "aks_spot_app_node_pools" {
 description = "Additional user / app node pools"
 type = map(object({
   max_count           = number
   min_count           = number
   enable_auto_scaling = bool
   vm_size             = string
   os_sku              = string
   os_disk_size_gb     = number
   max_pods            = number
   mode                = string
   priority            = string
   node_taints         = list(string)
   zones               = list(string)
   node_labels         = map(string)
 }))
}

variable "network_profile" {
  description = "Set Kubernetes cluster network profile."
  type = object({
    network_plugin       = string
    network_plugin_mode  = string
    ebpf_data_plane      = string
    #network_policy      = string
    load_balancer_sku    = string
    pod_cidr             = string
    service_cidr         = string
    dns_service_ip       = string
    outbound_type        = string
    
  })
  default = {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    ebpf_data_plane     = "cilium"
    #network_policy     = "calico"
    load_balancer_sku   = "standard"
    pod_cidr            = "172.24.0.0/16"
    service_cidr        = "10.0.0.0/16"
    dns_service_ip      = "10.0.0.10"
    outbound_type       = "userDefinedRouting"
  }         
}

variable "admin_group_object_id" {
  description = "A Object ID of AAD Group which have k8s cluster admin permissions."
  type        =  string
  validation {
    condition = contains(
      [ "cfb0943e-777e-4106-b7c0-248795de1026", "400880f3-79d6-40a6-b0ef-d43b8eee0453", "ad66b0b2-1f37-4727-a9be-a0dc2ca7f573", "8ec12bd5-3a9b-4cb2-a092-db738b93498c"], var.admin_group_object_id)
    error_message = "Invalid Admin Group ID's"
  }
}

variable "automatic_channel_upgrade" {
  description = "The upgrade channel for this Kubernetes Cluster. Possible values are patch, rapid, node-image and stable"
  type = string
}

variable "node_os_channel_upgrade" {
  description = "The upgrade channel for this Kubernetes Cluster Nodes' OS Image. Possible values are Unmanaged, SecurityPatch, NodeImage and None"
  type = string
}

variable "key_vault_name" {
  type = string
  description = "Provide the Key Vault Name where SSH and Disk Encryption Set Created." 
}

variable "key_vault_rg_name" {
  type = string
  description = "Provide the Key Vault Resource Group Name." 
}

variable "disk_encryption_set_name" {
  type = string
  description = "Provide OSDisk Encryption Set Name."
  default = "OSDiskEncryptionCMK"
}

variable "log_analytics_workspace_enabled" {
  description = "enable log analytics workspace."
  type = bool
  default = false
}

variable "defender_enabled" {
  description = "enable log analytics workspace."
  type = bool
  default = true
}

variable "log_analytics_workspace_name" {
  description = "Please provide the log analytics worksapce name."
  type = string
  default = ""
}

variable "law_resource_group_name" {
  description = "Please provide the log analytcis resource group name."
  type = string
  default = ""  
}

variable "amw_dcp_name" {
  description = "Please provide the Promethues corresponding DCP name"
  type = string
  default = ""  
}

variable "amw_dcr_name" {
  description = "Please provide the Promethues corresponding DCR name"
  type = string
  default = ""  
}

variable "amw_resource_group_name" {
  description = "Please provide the Promethues corresponding DCR Resource Group."
  type = string
  default = ""  
}

variable "defender_law_id" {
  type        = string
  description = "Name of the defender log analytics for all resources."
}

#################### tags ##############
variable "default_tags_enabled" {
  description = "Option to enable or disable default tags."
  type        = bool
  default     = true
}

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

variable "automatic_channel_upgrade" {
  description = "The upgrade channel for this Kubernetes Cluster. Possible values are patch, rapid, node-image and stable"
  type = string
  default = "node-image"
}

variable "node_os_channel_upgrade" {
  description = "The upgrade channel for this Kubernetes Cluster Nodes' OS Image. Possible values are Unmanaged, SecurityPatch, NodeImage and None"
  type = string
  default = "NodeImage"
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
    max_count           = 2
    min_count           = 1
    enable_auto_scaling = true
    vm_size             = "Standard_D4lds_v5"
    os_sku             = "AzureLinux"
    os_disk_size_gb     = 75
    max_pods            = 40
    node_taints         = []
    zones               = ["1","2","3"]
    upgrade_max_surge   = 1
 }  
}

variable "aks_app_node_pools" {
 description = "Additional Regular user / app node pools"
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
 default = {
 }
}

variable "aks_spot_app_node_pools" {
 description = "Additional spot user / app node pools"
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
 default = {
 }
}

variable "defender_enabled" {
  description = "enable log analytics workspace."
  type = bool
  default = true
}
variable "defender_law_name" {
  type        = string
  description = "Name of the defender log analytics for all resources."
}

variable "defender_law_rg_name" {
  type        = string
  description = "Resource Group name of the defender log analytics for all resources."
}
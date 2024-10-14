
data "azurerm_client_config" "current_config" {}

data "azurecaf_name" "keyvault" {
  name          = var.stack
  resource_type = "azurerm_key_vault"
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.client_name, var.location_short, var.environment, local.name_suffix, var.use_caf_naming ? "" : "kv"])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}

#############################################################
locals {
  tenant_id = coalesce(
    var.tenant_id,
    data.azurerm_client_config.current_config.tenant_id,
  )
}

locals {
  # Naming locals/constants
  name_prefix = lower(var.name_prefix)
  name_suffix = lower(var.name_suffix)

  name     = coalesce(var.custom_name, data.azurecaf_name.keyvault.result)
}

locals {
  default_tags = var.default_tags_enabled ? {
    env   = var.environment
    stack = var.stack
  } : {}
}
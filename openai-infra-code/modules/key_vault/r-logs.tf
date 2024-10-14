
resource "azurerm_monitor_diagnostic_setting" "main" {
  name               = var.custom_diagnostic_settings_name
  target_resource_id = one(concat(azurerm_key_vault.keyvault[*].id))

  log_analytics_workspace_id     = coalescelist([for r in var.logs_destinations_ids : r if contains(split("/", lower(r)), "microsoft.operationalinsights")], [null])[0]
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category_group = "audit"
  }

  metric {
    category = "AllMetrics"
    enabled  = false
  }

  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }
}
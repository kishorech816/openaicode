################### Vault RBAC ##########
resource "azurerm_role_assignment" "rbac_keyvault_administrator" {
  for_each = toset(var.rbac_authorization_enabled ? var.admin_objects_ids : [])

  scope                = one(azurerm_key_vault.keyvault[*].id)
  role_definition_name = "Key Vault Administrator"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "rbac_keyvault_secrets_users" {
  for_each = toset(var.rbac_authorization_enabled ? var.reader_objects_ids : [])

  scope                = one(azurerm_key_vault.keyvault[*].id)
  role_definition_name = "Key Vault Secrets User"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "rbac_keyvault_reader" {
  for_each = toset(var.rbac_authorization_enabled ? var.reader_objects_ids : [])

  scope                = one(azurerm_key_vault.keyvault[*].id)
  role_definition_name = "Key Vault Reader"
  principal_id         = each.value
}


############ Vault Policies ##########


resource "azurerm_key_vault_access_policy" "readers_policy" {
  for_each = toset(var.rbac_authorization_enabled ? [] : var.reader_objects_ids)

  object_id    = each.value
  tenant_id    = local.tenant_id
  key_vault_id = one(azurerm_key_vault.keyvault[*].id)

  key_permissions = [
    "Get",
    "List",
  ]

  secret_permissions = [
    "Get",
    "List",
  ]

  certificate_permissions = [
    "Get",
    "List",
  ]
}

resource "azurerm_key_vault_access_policy" "admin_policy" {
  for_each = toset(var.rbac_authorization_enabled ? [] : var.admin_objects_ids)

  object_id    = each.value
  tenant_id    = local.tenant_id
  key_vault_id = one(azurerm_key_vault.keyvault[*].id)

  key_permissions = [
    "Backup",
    "Create",
    "Decrypt",
    "Delete",
    "Encrypt",
    "Get",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Sign",
    "UnwrapKey",
    "Update",
    "Verify",
    "WrapKey",
  ]

  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set",
  ]

  certificate_permissions = [
    "Backup",
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get",
    "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "ManageContacts",
    "ManageIssuers",
    "Purge",
    "Recover",
    "Restore",
    "SetIssuers",
    "Update",
  ]
}
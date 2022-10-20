resource "azurerm_key_vault" "stamp" {
  name                = "${local.prefix}-kv"
  location            = azurerm_resource_group.stamp.location
  resource_group_name = azurerm_resource_group.stamp.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"
}

resource "azurerm_key_vault_access_policy" "devops_pipeline_all" {
  key_vault_id = azurerm_key_vault.stamp.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get", "List", "Delete", "Purge", "Set", "Backup", "Restore", "Recover"
  ]
}

resource "azurerm_key_vault_access_policy" "aks_msi" {
  key_vault_id = azurerm_key_vault.stamp.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_kubernetes_cluster.stamp.kubelet_identity.0.object_id

  secret_permissions = [
    "Get", "List"
  ]
}

resource "azurerm_key_vault_secret" "sample" {
  name         = "sample"
  value        = "samplevalue"
  key_vault_id = azurerm_key_vault.stamp.id
}

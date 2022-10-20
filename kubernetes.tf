resource "azurerm_kubernetes_cluster" "stamp" {
  name                = "${local.prefix}-aks"
  location            = azurerm_resource_group.stamp.location
  resource_group_name = azurerm_resource_group.stamp.name
  dns_prefix          = "${local.prefix}aks"
  kubernetes_version  = "1.24.6"
  sku_tier            = "Paid"

  automatic_channel_upgrade = "node-image"

  role_based_access_control_enabled = true

  default_node_pool {
    name                = "systempool"
    vm_size             = "Standard_F4s_v2"
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 4
    vnet_subnet_id      = azurerm_subnet.kubernetes.id
    os_disk_type        = "Ephemeral"
    os_disk_size_gb     = 30

    zones = [1, 2, 3]
  }

  network_profile {
    network_plugin = "azure"
    network_mode   = "transparent"
    network_policy = "calico"

    outbound_type = "userDefinedRouting"
  }

  identity {
    type = "SystemAssigned"
  }

  # Enable the Azure Policy Addon for AKS
  azure_policy_enabled = true

  # Enable and configure the Azure Monitor (container insights) addon for AKS
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.stamp.id
  }

  # Enable and configure the Azure KeyVault Secrets Provider addon for AKS
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "5m"
  }
}

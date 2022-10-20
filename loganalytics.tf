resource "azurerm_log_analytics_workspace" "stamp" {
  name                = "${local.prefix}-log"
  location            = azurerm_resource_group.stamp.location
  resource_group_name = azurerm_resource_group.stamp.name
  sku                 = "PerGB2018"
  retention_in_days   = 30 # has to be between 30 and 730
  daily_quota_gb      = 30
}
resource "azurerm_virtual_network" "stamp" {
  name                = "${local.prefix}-vnet"
  resource_group_name = azurerm_resource_group.stamp.name
  location            = azurerm_resource_group.stamp.location
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_network_security_group" "default" {
  name                = "${local.prefix}-nsg"
  location            = azurerm_resource_group.stamp.location
  resource_group_name = azurerm_resource_group.stamp.name
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.stamp.name
  virtual_network_name = azurerm_virtual_network.stamp.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_subnet" "kubernetes" {
  name                 = "kubernetes"
  resource_group_name  = azurerm_resource_group.stamp.name
  virtual_network_name = azurerm_virtual_network.stamp.name
  address_prefixes     = ["10.10.2.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "kubernetess" {
  subnet_id                 = azurerm_subnet.kubernetes.id
  network_security_group_id = azurerm_network_security_group.default.id
}

resource "azurerm_route_table" "default" {
  name                          = "${local.prefix}-rt"
  location                      = azurerm_resource_group.stamp.location
  resource_group_name           = azurerm_resource_group.stamp.name
  disable_bgp_route_propagation = false
}

resource "azurerm_route" "default" {
  name                   = "defaultRoute"
  resource_group_name    = azurerm_resource_group.stamp.name
  route_table_name       = azurerm_route_table.default.name
  address_prefix         = "0.0.0.0/0"
  next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
  next_hop_type          = "VirtualAppliance"
}

resource "azurerm_subnet_route_table_association" "default-to-kubernetes" {
  subnet_id      = azurerm_subnet.kubernetes.id
  route_table_id = azurerm_route_table.default.id
}
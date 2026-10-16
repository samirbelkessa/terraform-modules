resource "azurerm_virtual_network_peering" "forward" {
  virtual_network_name         = var.vnet_name_forward
  use_remote_gateways          = false
  resource_group_name          = var.rg_name_forward
  remote_virtual_network_id    = var.remote_vnet_id_forward
  name                         = var.peering_name_forward
  allow_virtual_network_access = true
  allow_gateway_transit        = var.allow_gateway_transit
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "reverse" {
  virtual_network_name         = var.vnet_name_reverse
  use_remote_gateways          = false
  resource_group_name          = var.rg_name_reverse
  remote_virtual_network_id    = var.remote_vnet_id_reverse
  name                         = var.peering_name_reverse
  allow_virtual_network_access = true
  allow_gateway_transit        = var.allow_gateway_transit
  allow_forwarded_traffic      = true
}


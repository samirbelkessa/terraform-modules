output "peering_forward_id" {
  value = azurerm_virtual_network_peering.forward.id
}

output "peering_reverse_id" {
  value = azurerm_virtual_network_peering.reverse.id
}


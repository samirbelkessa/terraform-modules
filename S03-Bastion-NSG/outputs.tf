output "nsg_id" {
  description = "Resource ID of the Bastion NSG."
  value       = azurerm_network_security_group.this.id
}

output "nsg_name" {
  description = "Name of the Bastion NSG."
  value       = azurerm_network_security_group.this.name
}


output "application_rule_collection_group_id" {
  description = "Resource ID of the Application rule collection group (P:300)."
  value       = azurerm_firewall_policy_rule_collection_group.application.id
}

output "dnat_rule_collection_group_id" {
  description = "Resource ID of the DNAT rule collection group (P:100)."
  value       = try(azurerm_firewall_policy_rule_collection_group.dnat[0].id, null)
}

output "network_rule_collection_group_id" {
  description = "Resource ID of the Network rule collection group (P:200)."
  value       = azurerm_firewall_policy_rule_collection_group.network.id
}


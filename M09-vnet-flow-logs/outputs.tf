output "flow_log_ids" {
  description = "Map of flow log key to resource ID."
  value       = { for k, v in azurerm_network_watcher_flow_log.this : k => v.id }
}

output "flow_log_names" {
  description = "Map of flow log key to resource name."
  value       = { for k, v in azurerm_network_watcher_flow_log.this : k => v.name }
}


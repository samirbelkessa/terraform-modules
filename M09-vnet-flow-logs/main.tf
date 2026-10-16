resource "azurerm_network_watcher_flow_log" "this" {
  target_resource_id   = each.value.target_resource_id
  tags                 = var.tags
  storage_account_id   = var.storage_account_id
  resource_group_name  = var.network_watcher_resource_group_name
  network_watcher_name = var.network_watcher_name
  name                 = each.value.name
  for_each             = var.flow_log_configurations
  enabled              = each.value.enabled

  retention_policy {
    enabled = var.retention_policy_enabled
    days    = var.retention_days
  }

  dynamic "traffic_analytics" {
    for_each = var.enable_traffic_analytics ? [1] : []
    content {
      enabled               = true
      workspace_id          = var.traffic_analytics_workspace_id
      workspace_region      = var.traffic_analytics_workspace_region
      workspace_resource_id = var.traffic_analytics_workspace_resource_id
      interval_in_minutes   = var.traffic_analytics_interval_minutes
    }
  }
}


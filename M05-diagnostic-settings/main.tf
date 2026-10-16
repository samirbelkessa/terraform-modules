resource "azurerm_monitor_diagnostic_setting" "this" {
  target_resource_id             = var.target_resource_id
  storage_account_id             = var.storage_account_id
  name                           = local.diagnostic_setting_name
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = var.log_analytics_workspace_id != null ? var.log_analytics_destination_type : null
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id

  lifecycle {
    prevent_destroy = false

    precondition {
      error_message = "At least one destination must be specified (log_analytics_workspace_id, storage_account_id, or eventhub_authorization_rule_id)."
      condition     = local.has_destination
    }
  }

  dynamic "enabled_log" {
    for_each = local.selected_log_categories

    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = local.selected_metric_categories
    content {
      category = enabled_metric.value
    }
  }
}

data "azurerm_monitor_diagnostic_categories" "this" {
  resource_id = var.target_resource_id
}


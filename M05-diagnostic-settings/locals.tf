locals {
  default_tags = {
    Module = "M05-diagnostic-settings"
  }

  diagnostic_setting_name = coalesce(
    var.name,
    "diag-${local.resource_name}"
  )

  enable_logs = var.enabled_log_categories == null ? true : !contains(var.enabled_log_categories, "none")

  enable_metrics = var.enabled_metric_categories == null ? true : !contains(var.enabled_metric_categories, "none")

  has_destination = (
    var.log_analytics_workspace_id != null ||
    var.storage_account_id != null ||
    var.eventhub_authorization_rule_id != null
  )

  resource_name = element(split("/", var.target_resource_id), length(split("/", var.target_resource_id)) - 1)

  selected_log_categories = local.enable_logs ? (
    var.enabled_log_categories == null ? data.azurerm_monitor_diagnostic_categories.this.log_category_types : (
      length(var.enabled_log_categories) > 0 ?
      [for category in data.azurerm_monitor_diagnostic_categories.this.log_category_types :
        category if contains(var.enabled_log_categories, category)
      ] :
      data.azurerm_monitor_diagnostic_categories.this.log_category_types
    )
  ) : []

  selected_metric_categories = local.enable_metrics ? (
    var.enabled_metric_categories == null ? data.azurerm_monitor_diagnostic_categories.this.metrics : (
      length(var.enabled_metric_categories) > 0 ?
      [for category in data.azurerm_monitor_diagnostic_categories.this.metrics :
        category if contains(var.enabled_metric_categories, category)
      ] :
      data.azurerm_monitor_diagnostic_categories.this.metrics
    )
  ) : []

  tags = merge(local.default_tags, var.tags)

}

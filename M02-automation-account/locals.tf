locals {
  automation_account_name = var.custom_name != null ? var.custom_name : module.naming.name

  create_linked_service = var.create_la_linked_service && var.log_analytics_workspace_id != null && var.log_analytics_workspace_id != ""

  diagnostic_logs = var.enable_diagnostic_settings ? [
    for category in var.diagnostic_log_categories : {
      category = category
      enabled  = true
    }
  ] : []

  diagnostic_metrics = var.enable_diagnostic_settings ? [
    for category in var.diagnostic_metric_categories : {
      category = category
      enabled  = true
    }
  ] : []

  enable_diagnostics = var.enable_diagnostic_settings && var.log_analytics_workspace_id != null && var.log_analytics_workspace_id != ""

  identity_ids = var.identity_type == "SystemAssigned" ? null : var.identity_ids

  tags = merge(
    var.tags,
    {
      Module = "M02-automation-account"
    }
  )

}

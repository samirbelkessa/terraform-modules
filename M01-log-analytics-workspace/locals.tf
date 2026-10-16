locals {
  archive_retention_days = var.total_retention_in_days - var.retention_in_days

  diagnostic_logs = [
    for category in var.diagnostic_categories : {
      category = category
      enabled  = true
    }
  ]

  enable_diagnostics = var.enable_diagnostic_settings

  secondary_workspace_name = "${local.workspace_name}-dr"

  solutions_to_deploy = var.deploy_solutions ? {
    for sol in var.solutions : "${sol.name}-${sol.publisher}" => sol
  } : {}

  tags = merge(
    var.tags,
    {
      Module = "M01-log-analytics-workspace"
    }
  )

  use_capacity_reservation = var.sku == "CapacityReservation"

  workspace_name = var.custom_name != null ? var.custom_name : module.naming.name

}

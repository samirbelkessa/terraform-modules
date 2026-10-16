# Brainboard auto-generated file.

resource "azurerm_log_analytics_workspace" "this" {
  tags                               = local.tags
  sku                                = var.sku
  retention_in_days                  = var.retention_in_days
  resource_group_name                = var.resource_group_name
  reservation_capacity_in_gb_per_day = local.use_capacity_reservation ? var.reservation_capacity_in_gb_per_day : null
  name                               = local.workspace_name
  location                           = var.location
  local_authentication_enabled       = var.local_authentication_enabled
  internet_query_access_type         = var.internet_query_access_type
  internet_ingestion_access_type     = var.internet_ingestion_access_type
  daily_quota_gb                     = var.daily_quota_gb

  lifecycle {
    prevent_destroy = false
  }
}

resource "time_sleep" "wait_for_workspace" {
  depends_on = [
    azurerm_log_analytics_workspace.this,
  ]
  create_duration = "60s"
}

resource "azurerm_log_analytics_workspace_table" "archive" {
  workspace_id            = azurerm_log_analytics_workspace.this.id
  total_retention_in_days = each.value
  retention_in_days       = var.retention_in_days
  name                    = each.key
  for_each = var.enable_table_level_archive ? {
    for k, v in var.archive_tables : k => v
    if k != "AzureDiagnostics"
  } : {}

  depends_on = [
    azurerm_log_analytics_solution.solutions,
    time_sleep.wait_for_solutions,
  ]
}

resource "azurerm_log_analytics_solution" "solutions" {
  workspace_resource_id = azurerm_log_analytics_workspace.this.id
  workspace_name        = azurerm_log_analytics_workspace.this.name
  tags                  = local.tags
  solution_name         = each.value.name
  resource_group_name   = var.resource_group_name
  location              = var.location
  for_each              = local.solutions_to_deploy

  depends_on = [
    time_sleep.wait_for_workspace,
  ]

  plan {
    publisher = each.value.publisher
    product   = "OMSGallery/${each.value.name}"
  }
}

resource "time_sleep" "wait_for_solutions" {
  depends_on = [
    azurerm_log_analytics_solution.solutions,
  ]
  create_duration = "120s"
}

resource "azurerm_log_analytics_workspace" "secondary" {
  tags = merge(local.tags, {
    Purpose = "DR-Secondary"
  })
  sku                            = "PerGB2018"
  retention_in_days              = var.secondary_retention_in_days
  resource_group_name            = var.resource_group_name
  name                           = local.secondary_workspace_name
  location                       = var.secondary_location
  local_authentication_enabled   = var.local_authentication_enabled
  internet_query_access_type     = var.internet_query_access_type
  internet_ingestion_access_type = var.internet_ingestion_access_type
  count                          = var.enable_cross_region_workspace ? 1 : 0
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  target_resource_id         = azurerm_log_analytics_workspace.this.id
  storage_account_id         = var.diagnostic_storage_account_id
  name                       = "diag-${local.workspace_name}"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  count                      = local.enable_diagnostics ? 1 : 0

  depends_on = [
    time_sleep.wait_for_workspace,
  ]

  enabled_metric {
    category = "AllMetrics"
  }

  lifecycle {
    ignore_changes = [
      name,
    ]
  }

  dynamic "enabled_log" {
    for_each = local.diagnostic_logs
    content {
      category = enabled_log.value.category
    }
  }
}

module "naming" {
  source = "git::https://github.com/Experteq-MSP/terraform-modules//F02-naming-convention?ref=main"


  workload      = var.workload
  resource_type = "log"
  region        = var.region
  instance      = var.instance
  environment   = var.environment

}


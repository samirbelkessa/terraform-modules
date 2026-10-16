resource "azurerm_automation_account" "this" {
  tags                          = local.tags
  sku_name                      = var.sku_name
  resource_group_name           = var.resource_group_name
  public_network_access_enabled = var.public_network_access_enabled
  name                          = local.automation_account_name
  location                      = var.location
  local_authentication_enabled  = var.local_authentication_enabled

  lifecycle {
    prevent_destroy = false
  }

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = local.identity_ids
    }
  }
}

resource "azurerm_log_analytics_linked_service" "this" {
  workspace_id        = var.log_analytics_workspace_id
  resource_group_name = var.log_analytics_resource_group_name
  read_access_id      = azurerm_automation_account.this.id
  count               = var.create_la_linked_service ? 1 : 0
}

resource "azurerm_automation_runbook" "runbooks" {
  tags                    = merge(local.tags, each.value.tags)
  runbook_type            = each.value.runbook_type
  resource_group_name     = var.resource_group_name
  name                    = each.key
  log_verbose             = false
  log_progress            = false
  location                = var.location
  for_each                = var.runbooks
  description             = each.value.description
  content                 = each.value.content
  automation_account_name = azurerm_automation_account.this.name

  dynamic "publish_content_link" {
    for_each = each.value.uri != null ? [1] : []
    content {
      uri     = each.value.uri
      version = each.value.version

      dynamic "hash" {
        for_each = each.value.hash_value != null ? [1] : []
        content {
          algorithm = "SHA256"
          value     = each.value.hash_value
        }
      }
    }
  }
}

resource "azurerm_automation_schedule" "schedules" {
  week_days               = length(each.value.week_days) > 0 ? each.value.week_days : null
  timezone                = each.value.timezone
  start_time              = timeadd(timestamp(), "10m")
  resource_group_name     = var.resource_group_name
  name                    = each.key
  month_days              = length(each.value.month_days) > 0 ? each.value.month_days : null
  interval                = each.value.interval
  frequency               = each.value.frequency
  for_each                = var.schedules
  expiry_time             = each.value.expiry_time
  description             = each.value.description
  automation_account_name = azurerm_automation_account.this.name

  lifecycle {
    ignore_changes = [
      start_time,
    ]
  }
}

resource "azurerm_automation_credential" "credentials" {
  username                = var.credentials[each.key].username
  resource_group_name     = var.resource_group_name
  password                = var.credentials[each.key].password
  name                    = each.key
  for_each                = nonsensitive(toset(keys(var.credentials)))
  description             = var.credentials[each.key].description
  automation_account_name = azurerm_automation_account.this.name
}

resource "azurerm_automation_variable_string" "variables" {
  value                   = each.value.value
  resource_group_name     = var.resource_group_name
  name                    = each.key
  for_each                = var.variables_string
  encrypted               = each.value.encrypted
  description             = each.value.description
  automation_account_name = azurerm_automation_account.this.name
}

resource "azurerm_automation_variable_int" "variables" {
  value                   = each.value.value
  resource_group_name     = var.resource_group_name
  name                    = each.key
  for_each                = var.variables_int
  encrypted               = each.value.encrypted
  description             = each.value.description
  automation_account_name = azurerm_automation_account.this.name
}

resource "azurerm_automation_variable_bool" "variables" {
  value                   = each.value.value
  resource_group_name     = var.resource_group_name
  name                    = each.key
  for_each                = var.variables_bool
  encrypted               = each.value.encrypted
  description             = each.value.description
  automation_account_name = azurerm_automation_account.this.name
}

resource "azurerm_automation_module" "modules" {
  resource_group_name     = var.resource_group_name
  name                    = each.key
  for_each                = var.powershell_modules
  automation_account_name = azurerm_automation_account.this.name

  module_link {
    uri = each.value.uri
  }
}

resource "azurerm_automation_dsc_configuration" "configurations" {
  tags                    = local.tags
  resource_group_name     = var.resource_group_name
  name                    = each.key
  location                = var.location
  for_each                = var.dsc_configurations
  description             = each.value.description
  content_embedded        = each.value.content_embedded
  automation_account_name = azurerm_automation_account.this.name
}

resource "azurerm_automation_webhook" "webhooks" {
  runbook_name            = var.webhooks[each.key].runbook_name
  run_on_worker_group     = var.webhooks[each.key].run_on_worker_group
  resource_group_name     = var.resource_group_name
  parameters              = var.webhooks[each.key].parameters
  name                    = each.key
  for_each                = nonsensitive(toset(keys(var.webhooks)))
  expiry_time             = var.webhooks[each.key].expiry_time
  enabled                 = var.webhooks[each.key].enabled
  automation_account_name = azurerm_automation_account.this.name

  depends_on = [
    azurerm_automation_runbook.runbooks,
  ]
}

resource "time_sleep" "wait_for_policies" {
  depends_on = [
    azurerm_automation_account.this,
  ]
  create_duration = "120s"
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  target_resource_id         = azurerm_automation_account.this.id
  storage_account_id         = var.diagnostic_storage_account_id
  name                       = "diag-${local.automation_account_name}"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  count                      = var.enable_diagnostic_settings ? 1 : 0

  depends_on = [
    time_sleep.wait_for_policies,
  ]

  dynamic "enabled_log" {
    for_each = local.diagnostic_logs
    content {
      category = enabled_log.value.category
    }
  }

  dynamic "metric" {
    for_each = local.diagnostic_metrics
    content {
      category = metric.value.category
      enabled  = metric.value.enabled
    }
  }
}

module "naming" {
  source = "git::https://github.com/samirbelkessa/terraform-modules//F02-naming-convention?ref=main"


  workload      = var.workload
  resource_type = "aa"
  region        = var.region
  instance      = var.instance
  environment   = var.environment

}


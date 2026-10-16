resource "azurerm_monitor_activity_log_alert" "service_health" {
  tags                = local.tags
  scopes              = local.default_scope
  resource_group_name = data.azurerm_resource_group.this.name
  name                = local.service_health_alert_name
  location            = "global"
  enabled             = true
  description         = local.service_health_config.description
  count               = local.create_service_health_alert ? 1 : 0

  criteria {
    category = "ServiceHealth"

    service_health {
      services  = length(local.service_health_config.services) > 0 ? local.service_health_config.services : null
      locations = local.service_health_config.regions
      events    = local.service_health_config.event_types
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  dynamic "action" {
    for_each = lookup(local.get_action_group_for_severity, local.service_health_config.severity, null) != null ? [1] : []
    content {
      action_group_id = local.get_action_group_for_severity[local.service_health_config.severity]
    }
  }
}

resource "azurerm_monitor_activity_log_alert" "resource_health" {
  tags                = local.tags
  scopes              = local.default_scope
  resource_group_name = data.azurerm_resource_group.this.name
  name                = local.resource_health_alert_name
  location            = "global"
  enabled             = true
  description         = local.resource_health_config.description
  count               = local.create_resource_health_alert ? 1 : 0

  criteria {
    category = "ResourceHealth"

    resource_health {
      reason   = local.resource_health_config.reason_types
      previous = local.resource_health_config.previous_states
      current  = local.resource_health_config.current_states
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  dynamic "action" {
    for_each = lookup(local.get_action_group_for_severity, local.service_health_config.severity, null) != null ? [1] : []
    content {
      action_group_id = local.get_action_group_for_severity[local.service_health_config.severity]
    }
  }
}

resource "azurerm_monitor_activity_log_alert" "admin_delete" {
  tags                = local.tags
  scopes              = local.admin_alert_scope
  resource_group_name = data.azurerm_resource_group.this.name
  name                = local.activity_admin_alert_name
  location            = "global"
  enabled             = true
  description         = local.activity_log_admin_config.description
  count               = local.create_activity_admin_alert ? 1 : 0

  criteria {
    operation_name = local.activity_log_admin_config.operation_names[0]
    level          = "Critical"
    category       = "Administrative"
  }

  lifecycle {
    create_before_destroy = true
  }

  dynamic "action" {
    for_each = lookup(local.get_action_group_for_severity, local.activity_log_admin_config.severity, null) != null ? [1] : []
    content {
      action_group_id = local.get_action_group_for_severity[local.activity_log_admin_config.severity]
    }
  }
}

resource "azurerm_monitor_activity_log_alert" "admin_delete_operations" {
  tags                = local.tags
  scopes              = local.admin_alert_scope
  resource_group_name = data.azurerm_resource_group.this.name
  name                = "${local.name_prefix}-admin-delete-${replace(replace(lower(each.key), "microsoft.", ""), "/", "-")}"
  location            = "global"
  for_each            = local.create_activity_admin_alert ? toset(slice(local.activity_log_admin_config.operation_names, 1, length(local.activity_log_admin_config.operation_names))) : toset([])
  enabled             = true
  description         = "Alert for: ${each.value}"

  criteria {
    operation_name = each.value
    category       = "Administrative"
  }

  lifecycle {
    create_before_destroy = true
  }

  dynamic "action" {
    for_each = lookup(local.get_action_group_for_severity, local.activity_log_admin_config.severity, null) != null ? [1] : []
    content {
      action_group_id = local.get_action_group_for_severity[local.activity_log_admin_config.severity]
    }
  }
}

resource "azurerm_monitor_activity_log_alert" "security" {
  tags                = local.tags
  scopes              = local.admin_alert_scope
  resource_group_name = data.azurerm_resource_group.this.name
  name                = local.activity_security_alert_name
  location            = "global"
  enabled             = true
  description         = local.activity_log_security_config.description
  count               = local.create_activity_security_alert ? 1 : 0

  criteria {
    operation_name = local.activity_log_security_config.operation_names[0]
    category       = "Security"
  }

  lifecycle {
    create_before_destroy = true
  }

  dynamic "action" {
    for_each = lookup(local.get_action_group_for_severity, local.activity_log_security_config.severity, null) != null ? [1] : []
    content {
      action_group_id = local.get_action_group_for_severity[local.activity_log_security_config.severity]
    }
  }
}

resource "azurerm_monitor_activity_log_alert" "security_operations" {
  tags                = local.tags
  scopes              = local.admin_alert_scope
  resource_group_name = data.azurerm_resource_group.this.name
  name                = "${local.name_prefix}-security-${replace(replace(lower(each.key), "microsoft.", ""), "/", "-")}"
  location            = "global"
  for_each            = local.create_activity_security_alert ? toset(slice(local.activity_log_security_config.operation_names, 1, length(local.activity_log_security_config.operation_names))) : toset([])
  enabled             = true
  description         = "Security alert for: ${each.value}"

  criteria {
    operation_name = each.value
    category       = "Security"
  }

  lifecycle {
    create_before_destroy = true
  }

  dynamic "action" {
    for_each = lookup(local.get_action_group_for_severity, local.activity_log_security_config.severity, null) != null ? [1] : []
    content {
      action_group_id = local.get_action_group_for_severity[local.activity_log_security_config.severity]
    }
  }
}

resource "azurerm_monitor_activity_log_alert" "custom" {
  tags                = local.tags
  scopes              = each.value.resolved_scopes
  resource_group_name = data.azurerm_resource_group.this.name
  name                = "${local.name_prefix}-${each.key}"
  location            = "global"
  for_each            = { for k, v in local.custom_activity_alerts_resolved : k => v if v.enabled }
  enabled             = true
  description         = each.value.description

  lifecycle {
    create_before_destroy = true
  }

  criteria {
    status         = each.value.status
    operation_name = each.value.operation_name
    level          = each.value.level
    category       = each.value.category

    dynamic "resource_health" {
      for_each = each.value.category == "ResourceHealth" ? [1] : []
      content {
        current  = ["Degraded", "Unavailable"]
        previous = ["Available"]
      }
    }
  }

  dynamic "action" {
    for_each = each.value.resolved_action_group_ids
    content {
      action_group_id = action.value
    }
  }
}

resource "azurerm_monitor_metric_alert" "custom" {
  window_size              = each.value.window_size
  target_resource_type     = each.value.target_resource_type
  target_resource_location = each.value.target_resource_location
  tags                     = local.tags
  severity                 = each.value.severity_level
  scopes                   = each.value.resolved_scopes
  resource_group_name      = data.azurerm_resource_group.this.name
  name                     = "${local.name_prefix}-metric-${each.key}"
  frequency                = each.value.frequency
  for_each                 = { for k, v in local.custom_metric_alerts_resolved : k => v if v.enabled }
  enabled                  = true
  description              = each.value.description
  auto_mitigate            = each.value.auto_mitigate

  lifecycle {
    create_before_destroy = true
  }

  dynamic "criteria" {
    for_each = each.value.criteria
    content {
      metric_namespace       = criteria.value.metric_namespace
      metric_name            = criteria.value.metric_name
      aggregation            = criteria.value.aggregation
      operator               = criteria.value.operator
      threshold              = criteria.value.threshold
      skip_metric_validation = criteria.value.skip_metric_validation

      dynamic "dimension" {
        for_each = criteria.value.dimension
        content {
          name     = dimension.value.name
          operator = dimension.value.operator
          values   = dimension.value.values
        }
      }
    }
  }

  dynamic "dynamic_criteria" {
    for_each = each.value.dynamic_criteria
    content {
      metric_namespace         = dynamic_criteria.value.metric_namespace
      metric_name              = dynamic_criteria.value.metric_name
      aggregation              = dynamic_criteria.value.aggregation
      operator                 = dynamic_criteria.value.operator
      alert_sensitivity        = dynamic_criteria.value.alert_sensitivity
      evaluation_total_count   = dynamic_criteria.value.evaluation_total_count
      evaluation_failure_count = dynamic_criteria.value.evaluation_failure_count
      ignore_data_before       = dynamic_criteria.value.ignore_data_before
      skip_metric_validation   = dynamic_criteria.value.skip_metric_validation

      dynamic "dimension" {
        for_each = dynamic_criteria.value.dimension
        content {
          name     = dimension.value.name
          operator = dimension.value.operator
          values   = dimension.value.values
        }
      }
    }
  }

  dynamic "action" {
    for_each = each.value.resolved_action_group_ids
    content {
      action_group_id = action.value
    }
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "custom" {
  workspace_alerts_storage_enabled  = each.value.workspace_alerts_storage_enabled
  window_duration                   = each.value.window_duration
  tags                              = local.tags
  skip_query_validation             = each.value.skip_query_validation
  severity                          = each.value.severity_level
  scopes                            = each.value.resolved_scopes
  resource_group_name               = data.azurerm_resource_group.this.name
  name                              = "${local.name_prefix}-log-${each.key}"
  mute_actions_after_alert_duration = each.value.mute_actions_after_alert_duration
  location                          = each.value.location
  for_each = {
    for k, v in var.custom_log_query_alerts : k => local.custom_log_alerts_resolved[k]
    if try(v.enabled, true)
  }
  evaluation_frequency    = each.value.evaluation_frequency
  enabled                 = true
  description             = each.value.description
  auto_mitigation_enabled = each.value.auto_mitigation_enabled

  criteria {
    query                   = each.value.query
    time_aggregation_method = each.value.time_aggregation_method
    threshold               = each.value.threshold
    operator                = each.value.operator
    metric_measure_column   = each.value.metric_measure_column
    resource_id_column      = each.value.resource_id_column

    dynamic "dimension" {
      for_each = each.value.dimension != null ? each.value.dimension : []
      content {
        name     = dimension.value.name
        operator = dimension.value.operator
        values   = dimension.value.values
      }
    }

    dynamic "failing_periods" {
      for_each = each.value.failing_periods != null ? [each.value.failing_periods] : []
      content {
        minimum_failing_periods_to_trigger_alert = failing_periods.value.minimum_failing_periods_to_trigger_alert
        number_of_evaluation_periods             = failing_periods.value.number_of_evaluation_periods
      }
    }
  }

  dynamic "action" {
    for_each = each.value.resolved_action_group_ids
    content {
      action_groups = [action.value]
    }
  }

  lifecycle {
    create_before_destroy = true
  }


}

data "azurerm_client_config" "current" {
}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}


# M04 — Monitor Alerts

## Overview

Creates Azure Monitor alerts for platform-level monitoring. Provides 4 categories of default alerts (Service Health, Resource Health, Admin Delete, Security Policy) plus 3 types of custom alerts (Activity Log, Metric, Log Query). Uses a severity-to-action-group routing system.

**Module path:** `modules/Management/M04-monitor-alerts/`

## Resources Created

| Resource | Mode | Description |
|----------|------|-------------|
| `azurerm_monitor_activity_log_alert.service_health` | count 0–1 | Service Health incidents and maintenance |
| `azurerm_monitor_activity_log_alert.resource_health` | count 0–1 | Resource Health degradation |
| `azurerm_monitor_activity_log_alert.admin_delete` | count 0–1 | Primary admin delete alert |
| `azurerm_monitor_activity_log_alert.admin_delete_operations` | for_each | Per-operation delete alerts |
| `azurerm_monitor_activity_log_alert.security` | count 0–1 | Primary security policy alert |
| `azurerm_monitor_activity_log_alert.security_operations` | for_each | Per-operation security alerts |
| `azurerm_monitor_activity_log_alert.custom` | for_each | Custom activity log alerts |
| `azurerm_monitor_metric_alert.custom` | for_each | Custom metric alerts (static + dynamic thresholds) |
| `azurerm_monitor_scheduled_query_rules_alert_v2.custom` | for_each | Custom KQL log query alerts |

## Default Alert Categories

| Category | Monitors | Default Severity |
|----------|----------|-----------------|
| **Service Health** | Incident + Maintenance in AU + Global | Critical |
| **Resource Health** | Degraded + Unavailable states | Warning |
| **Admin Delete** | 7 delete operation types | Warning |
| **Security** | 4 security policy operations | Security |

## Inputs

### Required

| Variable | Type | Description |
|----------|------|-------------|
| `workload` | `string` | Workload name |
| `environment` | `string` | Environment code |
| `resource_group_name` | `string` | Target resource group |

### Action Group Routing

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `action_group_ids` | `map(string)` | `{}` | IDs keyed by severity (critical, warning, info, security) |
| `severity_action_group_mapping` | `map(string)` | critical→critical, warning→warning, info→info, security→security | Severity to action group routing |

### Alert Toggles

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `create_default_alerts` | `bool` | `true` | Create all 4 default alert types |
| `service_health_alert_config` | `object` | Enabled | Service Health configuration |
| `resource_health_alert_config` | `object` | Enabled | Resource Health configuration |
| `activity_log_admin_alert_config` | `object` | Enabled | Admin delete configuration |
| `activity_log_security_alert_config` | `object` | Enabled | Security policy configuration |

### Custom Alerts

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `custom_activity_log_alerts` | `map(object)` | `{}` | Custom Activity Log alerts |
| `custom_metric_alerts` | `map(object)` | `{}` | Custom Metric alerts (static + dynamic thresholds + dimensions) |
| `custom_log_query_alerts` | `map(object)` | `{}` | Custom KQL query alerts (Scheduled Query Rules v2) |

## Outputs

| Output | Description |
|--------|-------------|
| `service_health_alert_id` / `resource_health_alert_id` / `admin_delete_alert_id` / `security_alert_id` | Default alert IDs |
| `custom_activity_alert_ids` / `custom_metric_alert_ids` / `custom_log_alert_ids` | Custom alert ID maps |
| `all_alert_ids` | Flat map of every alert |
| `alert_count` | Total count |

## How to Use in the Orchestrator

Deployed conditionally via `local.m04_can_deploy` (requires M03 action groups + M01 LAW).

```hcl
module "m04_monitor_alerts" {
  source = "git::https://github.com/samirbelkessa/Landing-Zone//Terraform-Azure-LZ/modules/Management/M04-monitor-alerts?ref=main"

  # ── Required ──
  workload            = var.management_project_name
  environment         = var.environment
  resource_group_name = try(module.l01-subscription-vending-v2.resource_groups_by_subscription["management"]["monitoring"].name, "")

  # ── Naming ──
  custom_name_prefix = var.alerts_custom_name_prefix
  region             = local.primary_region
  instance           = "01"

  # ── Action Groups (from M03) ──
  action_group_ids              = module.m03_action_groups[0].outputs_for_m04.action_group_ids
  severity_action_group_mapping = var.severity_action_group_mapping    # {critical→critical, warning→warning, ...}

  # ── LAW for Log Query Alerts ──
  log_analytics_workspace_id = module.m01_log_analytics[0].id

  # ── Monitored Subscriptions ──
  subscription_ids = local.management_monitored_subscriptions    # All platform + client subscription IDs

  # ── Default Alerts ──
  create_default_alerts              = var.create_default_alerts
  service_health_alert_config        = var.service_health_alert_config
  resource_health_alert_config       = var.resource_health_alert_config
  activity_log_admin_alert_config    = var.activity_log_admin_alert_config
  activity_log_security_alert_config = var.activity_log_security_alert_config

  # ── Custom Alerts ──
  custom_log_query_alerts    = merge(local.platform_log_query_alerts, var.custom_log_query_alerts)
  custom_metric_alerts       = var.custom_metric_alerts
  custom_activity_log_alerts = var.custom_activity_log_alerts

  # ── Conditional ──
  count = local.m04_can_deploy ? 1 : 0
  tags  = local.tags_management

  depends_on = [module.m01_log_analytics, module.m03_action_groups]
  providers  = { azurerm = azurerm.management }
}
```

### Options Guide

| Option | When to change | Impact |
|--------|---------------|--------|
| `create_default_alerts = true` | Standard platform monitoring | Service Health + Resource Health + Admin Delete + Security alerts |
| `create_default_alerts = false` | Custom alerts only | No default alerts, define all manually |
| `custom_log_query_alerts = {...}` | KQL-based alerting | Scheduled Query Rules v2 on LAW data |
| `custom_metric_alerts = {...}` | Resource metric thresholds | Static or dynamic threshold alerts |
| `severity_action_group_mapping` | Custom severity routing | Route alert severity to different action groups |
| `subscription_ids = {...}` | Scope monitored subscriptions | Expand/restrict activity log alert scope |

## Dependencies

- **Upstream:** M03 (provides `action_group_ids`)
- **Downstream:** M05 (optional diagnostics)

## Implementation Notes

- **Severity routing:** Alert severity (e.g. "critical") maps to action group key via `severity_action_group_mapping`
- **Operation fan-out:** First operation creates primary alert; remaining operations each get individual alerts via `for_each`
- **Dynamic criteria:** Metric alerts support both static thresholds and ML-based dynamic thresholds (`alert_sensitivity`)
- **`create_before_destroy = true`** prevents alert gaps during updates

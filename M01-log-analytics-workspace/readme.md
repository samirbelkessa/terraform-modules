# M01 — Log Analytics Workspace

## Overview

Creates the central Log Analytics Workspace for the entire landing zone. Supports table-level archive configuration, LA solutions (including SecurityInsights for Sentinel), an optional secondary DR workspace, and self-diagnostic settings. Integrates with F02 (naming) and F03 (tags).

**Module path:** `modules/Management/M01-log-analytics-workspace/`

## Resources Created

| Resource | Mode | Description |
|----------|------|-------------|
| `module "naming"` (F02) | 1 | Generates CAF-compliant name (resource type `log`) |
| `azurerm_log_analytics_workspace.this` | 1 | Primary LAW |
| `time_sleep.wait_for_workspace` | 1 | 60s delay for API propagation |
| `azurerm_log_analytics_workspace_table.archive` | for_each | Table-level archive retention |
| `azurerm_log_analytics_solution.solutions` | for_each | OMS solutions (SecurityInsights, VMInsights, etc.) |
| `time_sleep.wait_for_solutions` | 1 | 120s delay after solutions |
| `azurerm_log_analytics_workspace.secondary` | count 0–1 | Optional DR workspace |
| `azurerm_monitor_diagnostic_setting.this` | count 0–1 | Self-diagnostic settings |

## Inputs

### Required

| Variable | Type | Description |
|----------|------|-------------|
| `workload` | `string` | Workload name for F02 naming (2–30 chars) |
| `environment` | `string` | Environment code |
| `resource_group_name` | `string` | Target resource group |
| `location` | `string` | Azure region |

### Retention & Capacity

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `retention_in_days` | `number` | `90` | Interactive retention (30–730) |
| `total_retention_in_days` | `number` | `400` | Total retention incl. archive (90–2556) |
| `sku` | `string` | `"PerGB2018"` | Workspace SKU |
| `daily_quota_gb` | `number` | `-1` | Daily ingestion quota (-1 = unlimited) |

### Table Archive

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_table_level_archive` | `bool` | `true` | Enable per-table archive |
| `archive_tables` | `map(number)` | SecurityEvent=400, Syslog=400, AzureActivity=400, SigninLogs=400, AuditLogs=400, Perf=180, AzureMetrics=180 | Tables with custom archive retention |

### Solutions

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `deploy_solutions` | `bool` | `true` | Deploy LA solutions |
| `solutions` | `list(object)` | 7 solutions | SecurityInsights, AzureActivity, VMInsights, Updates, ChangeTracking, ServiceMap, AgentHealthAssessment |

### Security

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `local_authentication_enabled` | `bool` | `false` | Local auth disabled by default (AAD-only) |
| `internet_ingestion_enabled` | `bool` | `true` | Allow public ingestion |
| `internet_query_enabled` | `bool` | `true` | Allow public queries |

### DR & Diagnostics

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_cross_region_workspace` | `bool` | `false` | Create secondary DR workspace |
| `secondary_location` | `string` | `var.secondary_location` | DR region |
| `enable_diagnostic_settings` | `bool` | `false` | Self-diagnostic settings |

## Outputs

| Output | Description |
|--------|-------------|
| `id` | Workspace resource ID |
| `workspace_id` | Workspace GUID (for agent configuration) |
| `name` | Workspace name |
| `primary_shared_key` / `secondary_shared_key` | Shared keys (sensitive) |
| `retention_in_days` / `total_retention_in_days` | Retention config |
| `solutions` | Map of deployed solutions |
| `archive_tables` | Tables with archive config |
| `secondary_workspace_id` | DR workspace ID (or null) |
| `outputs_for_m02` / `outputs_for_m05` / `outputs_for_m07` / `outputs_for_s01` / `outputs_for_s02` | Pre-formatted for downstream modules |
| `ready` | Boolean signal with depends_on |

## How to Use in the Orchestrator

The orchestrator deploys **two M01 instances**: one for Sentinel (security sub) and one for Monitor (management sub).

```hcl
# ── LAW Sentinel (primary, in Security subscription) ──
module "m01_log_analytics" {
  source = "git::https://github.com/samirbelkessa/Landing-Zone//...M01-log-analytics-workspace?ref=main"

  # ── Required ──
  workload            = var.management_project_name      # e.g. "lza"
  environment         = var.environment                  # "prod"
  resource_group_name = try(module.l01-subscription-vending-v2.resource_groups_by_subscription["security"]["sentinel"].name)
  location            = var.default_location

  # ── Naming ──
  custom_name = local.tas_naming_management.log_analytics  # TAS-generated name
  region      = local.primary_region                        # "aue"
  instance    = "01"

  # ── Retention ──
  retention_in_days       = var.log_analytics_retention_days        # 90
  total_retention_in_days = var.log_analytics_total_retention_days  # 401
  sku                     = var.log_analytics_sku                   # "PerGB2018"

  # ── Table archive (160+ tables at 401 days) ──
  enable_table_level_archive = true
  archive_tables = {
    SecurityEvent = 401
    Syslog        = 401
    AzureActivity = 401
    # ... 160+ tables in real config
  }

  # ── Solutions ──
  deploy_solutions = true
  solutions = [
    { publisher = "Microsoft", name = "SecurityInsights" },  # Required for Sentinel
    { publisher = "Microsoft", name = "AzureActivity" },
    { publisher = "Microsoft", name = "VMInsights" },
    { publisher = "Microsoft", name = "Updates" },
    { publisher = "Microsoft", name = "ChangeTracking" },
    { publisher = "Microsoft", name = "ServiceMap" },
    { publisher = "Microsoft", name = "AgentHealthAssessment" },
  ]

  # ── DR & Diagnostics (optional) ──
  enable_cross_region_workspace = var.enable_log_analytics_dr       # false by default
  secondary_location            = var.secondary_location
  enable_diagnostic_settings    = var.deploy_m08_diagnostics_storage && var.enable_m01_archive_to_storage
  diagnostic_storage_account_id = var.deploy_m08_diagnostics_storage ? module.m08_diagnostics_storage[0].id : null

  # ── Conditional deployment ──
  count = var.deploy_m01_log_analytics ? 1 : 0
  tags  = local.tags_management

  depends_on = [module.l01-subscription-vending-v2, module.m08_diagnostics_storage]
  providers  = { azurerm = azurerm.security }
}

# ── LAW Monitor (secondary, in Management subscription) ──
module "m01_log_analytics_monitor" {
  source = "...M01-log-analytics-workspace?ref=main"
  # Same structure but: fewer solutions (no SecurityInsights),
  # fewer archive tables, deployed in management sub
  count = var.deploy_m01_log_analytics_monitor ? 1 : 0
  providers = { azurerm = azurerm.management }
}
```

### Options Guide

| Option | When to change | Impact |
|--------|---------------|--------|
| `deploy_m01_log_analytics = false` | Skip LAW entirely (unlikely) | No central logging |
| `enable_cross_region_workspace = true` | Need DR workspace | Creates secondary LAW in AUSE |
| `enable_table_level_archive = false` | Don't need long-term archive | Saves cost, loses 401-day retention |
| `deploy_m01_log_analytics_monitor = true` | Separate monitoring from Sentinel | Second LAW for operational data |
| Solutions list | Different monitoring needs | Add/remove OMS solutions |

## Dependencies

- **Upstream:** M08 (diagnostics storage account, optional)
- **Downstream:** M02, M05, M07, S01, S02 (via pre-formatted outputs)

## Implementation Notes

- **AzureDiagnostics table excluded** from archive configuration (not supported)
- **Time delays:** 60s after workspace creation, 120s after solutions — Azure API eventual consistency
- **Local authentication disabled** by default for AAD-only auth
- **Pre-formatted outputs** reduce coupling with downstream modules

# M05 — Diagnostic Settings

## Overview

Generic, reusable module for configuring diagnostic settings on **any Azure resource**. Auto-discovers available log and metric categories via the Azure API, then enables selected (or all) categories. Supports three destination types: Log Analytics Workspace, Storage Account, and Event Hub.

**Module path:** `modules/Management/M05-diagnostic-settings/`

> **This module is instantiated many times** across the orchestrator for different target resources (LAW, Automation Account, Storage Accounts, connectivity resources, management resources, etc.).

## Resources Created

| Resource | Mode | Description |
|----------|------|-------------|
| `data.azurerm_monitor_diagnostic_categories.this` | 1 | Discovers available log/metric categories for the target resource |
| `azurerm_monitor_diagnostic_setting.this` | 1 | Diagnostic setting on the target resource |

## Inputs

### Required

| Variable | Type | Description |
|----------|------|-------------|
| `target_resource_id` | `string` | Azure resource ID to configure diagnostics on (ARM ID validated) |

### Destinations (at least one required)

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `log_analytics_workspace_id` | `string` | `null` | LAW destination |
| `storage_account_id` | `string` | `null` | Storage Account destination |
| `eventhub_authorization_rule_id` | `string` | `null` | Event Hub destination |
| `eventhub_name` | `string` | `null` | Event Hub name |

### Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `name` | `string` | `null` | Custom name (auto-generated as `diag-<resource-name>` if null) |
| `enabled_log_categories` | `list(string)` | `null` | Log categories to enable (null = all, `["none"]` = disable) |
| `enabled_metric_categories` | `list(string)` | `null` | Metric categories to enable (null = all, `["none"]` = disable) |
| `log_analytics_destination_type` | `string` | `"Dedicated"` | Dedicated tables vs AzureDiagnostics |
| `logs_retention_days` | `number` | `90` | Log retention for Storage destination |
| `metrics_retention_days` | `number` | `90` | Metric retention for Storage destination |

## Outputs

| Output | Description |
|--------|-------------|
| `id` | Diagnostic setting resource ID |
| `name` | Diagnostic setting name |
| `target_resource_id` | Target resource |
| `enabled_log_categories` / `enabled_metric_categories` | Enabled categories |
| `available_log_categories` / `available_metric_categories` | All discovered categories |

## How to Use in the Orchestrator

M05 is instantiated **many times** for different target resources. Examples from the orchestrator:

```hcl
# ── LAW self-diagnostics ──
module "m05_law_diagnostics" {
  source             = "...M05-diagnostic-settings?ref=main"
  target_resource_id = module.m01_log_analytics[0].id
  name               = "diag-${module.m01_log_analytics[0].name}-storage"
  log_analytics_workspace_id = module.m01_log_analytics[0].id
  count = var.enable_diagnostic_settings && var.deploy_m01_log_analytics ? 1 : 0
  providers = { azurerm = azurerm.management }
}

# ── Storage account diagnostics (with specific categories) ──
module "m05_storage_diagnostics" {
  source             = "...M05-diagnostic-settings?ref=main"
  target_resource_id = module.m08_diagnostics_storage[0].id
  name               = "diag-${module.m08_diagnostics_storage[0].name}"
  log_analytics_workspace_id     = module.m01_log_analytics[0].id
  log_analytics_destination_type = "Dedicated"
  enabled_metric_categories = ["Transaction", "Capacity"]
  count = local.m08_self_diagnostics_can_deploy ? 1 : 0
  providers = { azurerm = azurerm.management }
}

# ── Blob service diagnostics (with specific log categories) ──
module "m05_blob_diagnostics" {
  source             = "...M05-diagnostic-settings?ref=main"
  target_resource_id = "${module.m08_diagnostics_storage[0].id}/blobServices/default"
  enabled_log_categories    = ["StorageRead", "StorageWrite", "StorageDelete"]
  enabled_metric_categories = ["Transaction", "Capacity"]
  count = local.m08_self_diagnostics_can_deploy ? 1 : 0
  providers = { azurerm = azurerm.management }
}

# ── Connectivity diagnostics (dynamic for_each) ──
module "m05_connectivity_diagnostics" {
  source                    = "...M05-diagnostic-settings?ref=main"
  for_each                  = local.connectivity_diagnostics  # Dynamic map from locals
  target_resource_id        = each.value.target_resource_id
  name                      = "${each.value.name}-storage"
  storage_account_id        = each.value.storage_account_id
  enabled_log_categories    = each.value.log_categories
  enabled_metric_categories = each.value.metric_categories
  providers = { azurerm = azurerm.connectivity }
}
```

### Options Guide

| Option | When to change | Impact |
|--------|---------------|--------|
| `enabled_log_categories = null` | Send all available logs | Auto-discovers and enables everything |
| `enabled_log_categories = ["none"]` | Disable all logs (metrics only) | No log data sent |
| `log_analytics_destination_type = "AzureDiagnostics"` | Legacy table format needed | Routes to shared AzureDiagnostics table |
| `storage_account_id` | Archive to storage | Long-term storage destination |

## Dependencies

- **Upstream:** Any resource to monitor + M01 (LAW ID) + M08 (storage account ID)
- **Downstream:** None

## Implementation Notes

- **Auto-discovery:** Uses `azurerm_monitor_diagnostic_categories` to query Azure for available categories — no hardcoded category lists
- **Selective filtering:** Specified categories intersected with discovered ones (only valid categories configured)
- **Disable pattern:** `["none"]` disables all logs or metrics
- **Destination precondition:** Fails early if no destination configured
- **No F02/F03 integration** — lightweight generic utility
- **Dedicated tables by default** — routes to resource-specific tables instead of legacy AzureDiagnostics

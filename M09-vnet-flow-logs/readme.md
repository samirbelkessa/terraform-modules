# M09 — VNet Flow Logs

## Overview

Creates Azure Virtual Network Flow Logs via Network Watcher. Replaces the deprecated NSG Flow Logs (retired June 2025). Supports optional Traffic Analytics integration with Log Analytics for network traffic visualisation and analysis.

**Module path:** `modules/Management/M09-vnet-flow-logs/`

## Resources Created

| Resource | Mode | Description |
|----------|------|-------------|
| `azurerm_network_watcher_flow_log.this` | for_each | VNet flow log resources |

## Inputs

### Required

| Variable | Type | Description |
|----------|------|-------------|
| `flow_log_configurations` | `map(object)` | Flow log configs: name, target_resource_id, optional enabled flag |
| `network_watcher_name` | `string` | Network Watcher resource name |
| `network_watcher_resource_group_name` | `string` | Network Watcher resource group |
| `storage_account_id` | `string` | Storage account for flow log data (typically from M08) |

### Retention

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `retention_policy_enabled` | `bool` | `true` | Enable retention |
| `retention_days` | `number` | `90` | Retention days |

### Traffic Analytics

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_traffic_analytics` | `bool` | `true` | Enable Traffic Analytics |
| `traffic_analytics_workspace_id` | `string` | `null` | LAW GUID |
| `traffic_analytics_workspace_region` | `string` | `null` | LAW region |
| `traffic_analytics_workspace_resource_id` | `string` | `null` | LAW resource ID |
| `traffic_analytics_interval_minutes` | `number` | `10` | Processing interval (10 or 60 only) |

## Outputs

| Output | Description |
|--------|-------------|
| `flow_log_ids` | Map of flow log key to resource ID |
| `flow_log_names` | Map of flow log key to name |

## How to Use in the Orchestrator

M09 is used **inside the ClientLZ module** (for spoke VNet flow logs) and **inline in the orchestrator** (for hub VNet flow logs). The orchestrator creates a dedicated storage account for flow logs.

### Hub VNet Flow Logs (inline in orchestrator)

```hcl
# Dedicated storage account for flow logs
resource "azurerm_storage_account" "flow_logs" {
  provider = azurerm.management
  name                          = var.flow_logs_storage_account_name
  resource_group_name           = try(module.l01-subscription-vending-v2.resource_groups_by_subscription["management"]["monitoring"].name, "")
  location                      = var.default_location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = false
  count = (var.deploy_hub_vnet_flow_log || var.deploy_spoke_vnet_flow_logs) ? 1 : 0
}

# Hub VNet flow log
resource "azurerm_network_watcher_flow_log" "hub_aue" {
  provider             = azurerm.connectivity
  name                 = "${module.naming_connectivity_aue.base_prefix}nwflhub01"
  target_resource_id   = module.alz_connectivity.virtual_network_resource_ids[var.default_location]
  storage_account_id   = azurerm_storage_account.flow_logs[0].id
  network_watcher_name = data.azurerm_network_watcher.connectivity_aue[0].name
  resource_group_name  = data.azurerm_network_watcher.connectivity_aue[0].resource_group_name
  location             = var.default_location
  enabled              = true
  count                = var.deploy_hub_vnet_flow_log && var.deploy_connectivity ? 1 : 0

  retention_policy { enabled = true; days = var.flow_logs_retention_days }

  dynamic "traffic_analytics" {
    for_each = var.flow_logs_enable_traffic_analytics ? [1] : []
    content {
      enabled               = true
      workspace_id          = try(module.m01_log_analytics[0].workspace_id, null)
      workspace_region      = var.default_location
      workspace_resource_id = try(module.m01_log_analytics[0].id, null)
      interval_in_minutes   = 10
    }
  }
}
```

### Spoke VNet Flow Logs (via ClientLZ)

```hcl
module "client_<client>_dev" {
  source = "...ClientLZ?ref=main"
  # ...
  enable_vnet_flow_logs        = var.deploy_spoke_vnet_flow_logs
  flow_logs_storage_account_id = var.deploy_spoke_vnet_flow_logs ? azurerm_storage_account.flow_logs[0].id : ""
  enable_traffic_analytics     = var.flow_logs_enable_traffic_analytics
}
```

### Options Guide

| Option | When to change | Impact |
|--------|---------------|--------|
| `deploy_hub_vnet_flow_log = true` | Enable hub VNet flow logging | Hub network traffic captured |
| `deploy_spoke_vnet_flow_logs = true` | Enable spoke VNet flow logging | Spoke traffic captured (via ClientLZ) |
| `flow_logs_enable_traffic_analytics = true` | Network visualisation | Traffic Analytics in LAW (10-min interval) |
| `flow_logs_retention_days = 90` | Adjust retention | Storage cost vs compliance |

## Dependencies

- **Upstream:** M08 (storage account), M01 (LAW for Traffic Analytics), Network Watcher
- **Downstream:** None

## Implementation Notes

- **Minimal and focused** — single resource type, no F02/F03 integration
- **Replaces NSG Flow Logs** (retired June 2025) — VNet-level monitoring
- **Shared retention** across all flow logs (module-level, not per-flow-log)
- **Interval validation:** Only 10 or 60 minutes accepted
- **Traffic Analytics conditional** via `for_each = var.enable_traffic_analytics ? [1] : []`

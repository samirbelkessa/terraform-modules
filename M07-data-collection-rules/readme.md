# M07 — Data Collection Rules

## Overview

Generic, zero-hardcoding wrapper for Azure Monitor Data Collection Rules (DCR) used with Azure Monitor Agent (AMA). All configuration is injected from the orchestrator — the module contains no default DCR configurations. Supports the full DCR feature set: performance counters, Windows event logs, Linux syslog, IIS logs, custom log files, extensions, Prometheus forwarder, and platform telemetry.

**Module path:** `modules/Management/M07-data-collection-rules/`

## Resources Created

| Resource | Mode | Description |
|----------|------|-------------|
| `azurerm_monitor_data_collection_rule.this` | for_each | Data Collection Rules |
| `azurerm_monitor_data_collection_rule_association.this` | for_each | Optional DCR-to-VM associations (when `enable_associations = true`) |

## Inputs

### Required

| Variable | Type | Description |
|----------|------|-------------|
| `data_collection_rules` | `map(object)` | DCR definitions with location, RG, kind, destinations, data_flows, data_sources |

### DCR Configuration Structure

Each DCR entry supports:
- **Destinations:** Log Analytics, Azure Monitor Metrics, Storage Blob, Event Hub, Event Hub Direct
- **Data Sources:** performance_counter, windows_event_log, syslog, iis_log, log_file, extension, prometheus_forwarder, platform_telemetry
- **Data Flows:** streams, destinations, KQL transforms, output_stream
- **Identity:** SystemAssigned or UserAssigned
- **Stream Declarations:** for custom log tables

### Optional

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `data_collection_rule_associations` | `map(object)` | `{}` | DCR-to-VM associations |
| `enable_associations` | `bool` | `false` | Toggle associations (use Policy for greenfield) |
| `tags` | `map(string)` | `{}` | Global tags merged with per-DCR tags |

## Outputs

| Output | Description |
|--------|-------------|
| `dcr_ids` | Map of DCR names to resource IDs |
| `dcr_immutable_ids` | Map of DCR names to immutable IDs (for AMA) |
| `dcr_names` | Map of DCR keys to names |
| `association_ids` | Association resource IDs |
| `outputs_for_g03` | Pre-formatted for G03 (vm_insights_windows/linux DCR IDs) |
| `ready` | Boolean completion signal |

## How to Use in the Orchestrator

M07 is instantiated **twice** in the orchestrator — once for management DCRs (azurerm.management) and once for security DCRs (azurerm.security). All DCR configurations are injected from `locals.tf`.

```hcl
# ── Management DCRs (VM Insights, Performance Counters, etc.) ──
module "m07_data_collection_rules" {
  source = "git::https://github.com/samirbelkessa/Landing-Zone//Terraform-Azure-LZ/modules/Management/M07-data-collection-rules?ref=main"

  data_collection_rules             = local.management_dcr_configurations    # Defined in locals.tf
  data_collection_rule_associations = var.enable_dcr_associations ? {} : {}
  enable_associations               = var.enable_dcr_associations
  count                             = local.m07_can_deploy ? 1 : 0
  tags                              = local.tags_management

  depends_on = [module.m01_log_analytics]
  providers  = { azurerm = azurerm.management }
}

# ── Security DCRs (Windows Security Events, Syslog, etc.) ──
module "m07_data_collection_rules_security" {
  source = "git::https://github.com/samirbelkessa/Landing-Zone//Terraform-Azure-LZ/modules/Management/M07-data-collection-rules?ref=main"

  data_collection_rules             = local.security_dcr_configurations    # Defined in locals.tf
  data_collection_rule_associations = var.enable_dcr_associations ? {} : {}
  enable_associations               = var.enable_dcr_associations
  count                             = local.m07_can_deploy ? 1 : 0
  tags                              = local.tags_security

  depends_on = [module.m01_log_analytics, module.s02_sentinel]
  providers  = { azurerm = azurerm.security }
}
```

### DCR Configuration Pattern (in locals.tf)

```hcl
# All DCR definitions are built in locals.tf using naming from F02-naming-TAP
locals {
  management_dcr_configurations = {
    "${module.naming_dcr_management.data_collection_rule.name}-vmInsightsWindows" = {
      location            = var.default_location
      resource_group_name = "monitoring-rg"
      kind                = "Windows"
      destinations = {
        log_analytics = [{
          workspace_resource_id = module.m01_log_analytics[0].id
          name                  = "law-destination"
        }]
      }
      data_flows = [{ streams = ["Microsoft-InsightsMetrics"], destinations = ["law-destination"] }]
      data_sources = {
        performance_counter = [{ ... }]
      }
    }
    # ... more DCR definitions
  }
}
```

### Options Guide

| Option | When to change | Impact |
|--------|---------------|--------|
| `enable_associations = true` | Direct VM-to-DCR binding (brownfield) | Associates DCRs to specific VMs |
| `enable_associations = false` | Use Policy for DCR distribution (greenfield) | G03 policy assigns DCRs automatically |
| `data_collection_rules = {...}` | Custom telemetry requirements | Full control over data sources and destinations |
| Second instance (security) | Separate security telemetry pipeline | Security Events → Sentinel LAW vs Perf → Monitor LAW |

## Dependencies

- **Upstream:** M01 (LAW destination), M08 (Storage destination)
- **Downstream:** G03 (DCR IDs for policy assignments)

## Implementation Notes

- **Zero hardcoding:** All data sources, destinations, and data flows injected from orchestrator
- **Deeply nested dynamic blocks** for 7 destination types and 8 data source types
- **Association resolution:** Keys resolved to actual resource IDs with null filtering for resilience
- **Convention-based G03 integration:** Looks for keys named `dcr-vm-insights-windows` and `dcr-vm-insights-linux`
- **KQL transform support** for in-pipeline data transformation
- **`create_before_destroy = true`** on both DCRs and associations

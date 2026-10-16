# M08 — Diagnostics Storage Account

## Overview

Creates a hardened Azure Storage Account purpose-built for storing diagnostic data (boot diagnostics, archived logs, archived metrics). Includes default containers, lifecycle management policies (Hot → Cool → Archive → Delete tiering), self-diagnostic settings, and comprehensive security configuration.

**Module path:** `modules/Management/M08-diagnostics-storage-account/`

## Resources Created

| Resource | Mode | Description |
|----------|------|-------------|
| `module "naming"` (F02) | 1 | Generates name via Git-sourced F02 (resource type `st`) |
| `azurerm_storage_account.this` | 1 | Diagnostics storage account (name truncated to 22 chars + `c1` suffix) |
| `azurerm_storage_container.containers` | for_each | Storage containers (default + additional) |
| `azurerm_storage_management_policy.this` | count 0–1 | Lifecycle management policy |
| `azurerm_monitor_diagnostic_setting.storage_account` | count 0–1 | Self-diagnostics on the storage account |
| `azurerm_monitor_diagnostic_setting.blob_service` | count 0–1 | Self-diagnostics on blob service |

## Default Containers

| Container | Purpose |
|-----------|---------|
| `bootdiagnostics` | VM boot diagnostics |
| `insights-logs` | Azure Monitor archived logs |
| `insights-metrics` | Azure Monitor archived metrics |

## Default Lifecycle Policy

| Stage | Days | Action |
|-------|------|--------|
| Hot | 0–30 | Default access tier |
| Cool | 30 | Tier to Cool |
| Archive | 90 | Tier to Archive |
| Delete | 400 | Delete blob (~1.1 years) |

## Inputs

### Required

| Variable | Type | Description |
|----------|------|-------------|
| `workload` | `string` | Workload name (2–15 chars, lowercase alphanumeric) |
| `environment` | `string` | Environment code |
| `resource_group_name` | `string` | Target resource group |
| `location` | `string` | Azure region |

### Security (Hardened Defaults)

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `min_tls_version` | `string` | `"TLS1_2"` | Minimum TLS |
| `https_traffic_only_enabled` | `bool` | `true` | Force HTTPS |
| `allow_nested_items_to_be_public` | `bool` | `false` | Block public blob access |
| `default_to_oauth_authentication` | `bool` | `true` | Default to Entra ID |
| `infrastructure_encryption_enabled` | `bool` | `false` | Double encryption |

### Storage Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `replication_type` | `string` | `null` | Auto-selects: GRS for prod, LRS for non-prod |
| `account_tier` | `string` | `"Standard"` | Standard or Premium |
| `access_tier` | `string` | `"Hot"` | Default access tier |
| `enable_lifecycle_management` | `bool` | `true` | Enable blob lifecycle |
| `blob_soft_delete_retention_days` | `number` | `7` | Soft delete retention |

## Outputs

| Output | Description |
|--------|-------------|
| `id` / `name` | Storage account identifiers |
| `primary_access_key` / `primary_connection_string` | Access credentials (sensitive) |
| `primary_blob_endpoint` | Blob endpoint |
| `container_ids` / `container_names` | Container details |
| `outputs_for_m05` / `outputs_for_m07` / `outputs_for_b01` | Pre-formatted for downstream modules |
| `ready` | Boolean completion signal |

## How to Use in the Orchestrator

Deployed in the **Management subscription** before M01. Can be deployed twice for primary + secondary regions.

```hcl
module "m08_diagnostics_storage" {
  source = "git::https://github.com/samirbelkessa/Landing-Zone//...M08-diagnostics-storage-account?ref=main"

  # ── Required ──
  workload            = var.management_project_name
  environment         = var.environment
  resource_group_name = try(module.l01-subscription-vending-v2.resource_groups_by_subscription["management"]["monitoring"].name, "")
  location            = var.default_location

  # ── Naming ──
  custom_name = local.tas_naming_management.storage_account
  region      = local.primary_region
  instance    = "01"

  # ── Storage configuration ──
  account_tier    = var.diagnostics_storage_account_tier    # "Standard"
  account_kind    = var.diagnostics_storage_account_kind    # "StorageV2"
  access_tier     = var.diagnostics_storage_access_tier     # "Hot"
  replication_type = var.diagnostics_storage_replication_type  # null = auto (GRS prod / LRS non-prod)

  # ── Lifecycle management ──
  enable_lifecycle_management            = var.diagnostics_storage_enable_lifecycle   # true
  default_lifecycle_tier_to_cool_days    = var.diagnostics_storage_tier_to_cool_days    # 30
  default_lifecycle_tier_to_archive_days = var.diagnostics_storage_tier_to_archive_days # 90
  default_lifecycle_delete_days          = var.diagnostics_storage_delete_days          # 400

  # ── Containers ──
  create_default_containers = var.diagnostics_storage_create_default_containers  # true
  additional_containers     = var.diagnostics_storage_additional_containers       # {}

  # ── Security ──
  https_traffic_only_enabled        = true
  allow_nested_items_to_be_public   = false
  default_to_oauth_authentication   = true
  shared_access_key_enabled         = var.diagnostics_storage_shared_access_key_enabled
  infrastructure_encryption_enabled = var.diagnostics_storage_infrastructure_encryption

  # ── Conditional deployment ──
  count = var.deploy_m08_diagnostics_storage ? 1 : 0
  tags  = local.tags_management

  depends_on = [module.l01-subscription-vending-v2]
  providers  = { azurerm = azurerm.management }
}
```

### Options Guide

| Option | When to change | Impact |
|--------|---------------|--------|
| `replication_type = "LRS"` | Non-production / cost savings | No geo-redundancy |
| `enable_lifecycle_management = false` | Keep all data in Hot tier | Higher cost, faster access |
| `create_default_containers = false` | Custom container layout | No bootdiagnostics/insights containers |
| `infrastructure_encryption_enabled = true` | High security requirements | Double encryption |

## Dependencies

- **Upstream:** None (one of the first resources deployed)
- **Downstream:** M01 (diagnostic storage), M05 (Storage destination), M07 (blob destination), M09 (flow log storage)

## Implementation Notes

- **Name generation:** Strips hyphens from F02 pattern, truncates to 22 chars + `c1` suffix (24-char Azure limit)
- **Environment-based replication:** Auto-selects GRS for production, LRS for non-production when `replication_type = null`
- **F02 sourced via Git** (not local path) unlike some other modules
- **Self-diagnostic loop:** Storage account monitors itself by sending logs/metrics to LAW

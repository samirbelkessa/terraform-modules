# S02 — Sentinel

## Overview

Onboards Microsoft Sentinel (SIEM/SOAR) onto a Log Analytics Workspace and configures data connectors for Microsoft security services. Supports 8 native connectors, multi-subscription Defender for Cloud connector, watchlists, and UEBA.

**Module path:** `modules/Security/S02-sentinel/`

## Data Connectors

| Connector | Resource Type | Prerequisites |
|-----------|---------------|---------------|
| **Entra ID** | `azurerm_sentinel_data_connector_azure_active_directory` | Entra ID P1/P2 |
| **Defender for Cloud** | `azurerm_sentinel_data_connector_azure_security_center` | Per-subscription (for_each) |
| **Threat Intelligence** | `azurerm_sentinel_data_connector_threat_intelligence` | — |
| **MCAS** | `azurerm_sentinel_data_connector_microsoft_cloud_app_security` | Alerts + discovery logs |
| **Office 365** | `azurerm_sentinel_data_connector_office_365` | Exchange + SharePoint + Teams |
| **M365 Defender** | `azurerm_sentinel_data_connector_microsoft_defender_advanced_threat_protection` | E5 licence |
| **Defender for Identity** | `azurerm_sentinel_data_connector_azure_advanced_threat_protection` | — |
| **Dynamics 365** | `azurerm_sentinel_data_connector_dynamics_365` | — |

### Connectors Tracked But Deployed Elsewhere

These are managed via AMA DCRs, azapi, diagnostic settings, or Logic Apps:
- Windows Security Events, Syslog via AMA, Windows Server DNS
- Entra ID Protection (via azapi), Azure SQL Database
- NSG logs, MISP2Sentinel

## Resources Created

| Resource | Mode | Description |
|----------|------|-------------|
| `azurerm_sentinel_log_analytics_workspace_onboarding.this` | 1 | Sentinel onboarding |
| 8× data connectors | conditional | Various Sentinel connectors |
| `azurerm_sentinel_watchlist.this` | for_each | Watchlists |
| `time_sleep.wait_for_sentinel_onboarding` | 1 | 120s wait after onboarding |

## Inputs

### Required

| Variable | Type | Description |
|----------|------|-------------|
| `log_analytics_workspace_id` | `string` | LAW resource ID |
| `log_analytics_workspace_name` | `string` | LAW name |
| `resource_group_name` | `string` | LAW resource group |

### Connectors

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `data_connectors` | `object` (16 fields) | Most disabled | Feature flags per connector |
| `defender_for_cloud_subscriptions` | `map(string)` | `{}` | Sub name → sub ID for multi-sub Defender connector |

### Features

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `watchlists` | `map(object)` | `{}` | Watchlist definitions |
| `customer_managed_key_enabled` | `bool` | `false` | CMK for Sentinel |
| `enable_ueba` | `bool` | `false` | UEBA toggle |
| `ueba_data_sources` | `list(string)` | AuditLogs, AzureActivity, SigninLogs | UEBA sources |

## Outputs

| Output | Description |
|--------|-------------|
| `sentinel_onboarding_id` | Onboarding resource ID |
| `data_connectors_status` | Map of all 15 connectors to enabled/disabled |
| `enabled_connectors` | List of enabled connector names |
| `connector_ids` | Map of connector name to resource IDs |
| `watchlist_ids` | Watchlist name to ID map |
| `configuration_summary` | Full summary with counts |

## How to Use in the Orchestrator

Deployed conditionally via `local.s02_can_deploy` (requires M01 LAW). Deployed in the **security subscription** scope.

```hcl
module "s02_sentinel" {
  source = "git::https://github.com/samirbelkessa/Landing-Zone//Terraform-Azure-LZ/modules/Security/S02-sentinel?ref=main"

  # ── LAW (Sentinel workspace) ──
  log_analytics_workspace_id   = module.m01_log_analytics[0].id
  log_analytics_workspace_name = module.m01_log_analytics[0].name
  resource_group_name          = module.m01_log_analytics[0].resource_group_name

  # ── Data Connectors ──
  data_connectors = var.sentinel_data_connectors
  # Example:
  # {
  #   entra_id             = true
  #   defender_for_cloud   = true
  #   threat_intelligence  = true
  #   mcas                 = true
  #   office_365           = true
  #   m365_defender        = true
  #   defender_for_identity = false
  #   dynamics_365         = false
  # }

  # ── Multi-Subscription Defender Connector ──
  defender_for_cloud_subscriptions = {
    security     = var.existing_subscriptions["security"].subscription_id
    management   = var.existing_subscriptions["management"].subscription_id
    identity     = var.existing_subscriptions["identity"].subscription_id
    connectivity = var.existing_subscriptions["connectivity"].subscription_id
    client-prod  = var.existing_subscriptions["client-prod"].subscription_id
    client-dev   = var.existing_subscriptions["client-dev"].subscription_id
  }

  # ── UEBA ──
  enable_ueba       = var.sentinel_enable_ueba          # true
  ueba_data_sources = var.sentinel_ueba_data_sources     # ["AuditLogs", "AzureActivity", "SigninLogs"]

  # ── Watchlists ──
  watchlists = var.sentinel_watchlists    # {}

  # ── Conditional ──
  count = local.s02_can_deploy ? 1 : 0
  tags  = local.tags_management

  depends_on = [module.m01_log_analytics, module.l01-subscription-vending-v2, time_sleep.wait_for_security_rg]
  providers  = { azurerm = azurerm.security }
}
```

### Additional Connectors (via azapi, outside S02)

Some connectors require `azapi` for deployment. Example: Entra ID Protection:

```hcl
resource "azapi_resource_action" "sentinel_entra_id_protection" {
  provider    = azapi.security
  type        = "Microsoft.SecurityInsights/dataConnectors@2024-03-01"
  resource_id = "${module.m01_log_analytics[0].id}/providers/Microsoft.SecurityInsights/dataConnectors/EntraIDProtection"
  method      = "PUT"
  body = {
    kind = "AzureActiveDirectory"
    properties = {
      tenantId = var.root_parent_id
      dataTypes = { alerts = { state = "Enabled" } }
    }
  }
  count = local.s02_can_deploy && var.sentinel_data_connectors.entra_id_protection ? 1 : 0
}
```

### Options Guide

| Option | When to change | Impact |
|--------|---------------|--------|
| `enable_ueba = true` | User behaviour analytics | UEBA anomaly detection on sign-in/activity |
| `data_connectors.office_365 = true` | Microsoft 365 security | Exchange + SharePoint + Teams logs |
| `data_connectors.m365_defender = true` | M365 Defender integration | Endpoint detection alerts in Sentinel |
| `defender_for_cloud_subscriptions` | Add new client subscriptions | Per-sub Defender connector to Sentinel |
| `watchlists = {...}` | Threat intelligence lists | Custom watchlists for hunting queries |
| `customer_managed_key_enabled = true` | CMK requirement | Encrypts Sentinel data with customer key |

## Dependencies

- **Upstream:** M01 (LAW with SecurityInsights solution), S01 (Defender status)
- **Downstream:** None

## Implementation Notes

- **120s `time_sleep`** after onboarding — Sentinel takes time to fully initialise
- **Defender for Cloud connector uses `for_each`** on `defender_for_cloud_subscriptions` — one connector per subscription
- **All connectors `depends_on`** the onboarding or time_sleep resource
- **Office 365** enables all three sources: Exchange, SharePoint, Teams
- **16 boolean flags** in `data_connectors` but only 8 deployed natively — remainder tracked for status

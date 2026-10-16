# S01 — Defender for Cloud

## Overview

Configures Microsoft Defender for Cloud on a subscription: enables/disables 14 Defender plans (with subplan selection), sets up security contacts, configures auto-provisioning of the Log Analytics agent, and exports Defender data to a Log Analytics workspace.

**Module path:** `modules/Security/S01-defender-for-cloud/`

## 14 Defender Plans

| Plan | Resource Name | Subplan |
|------|---------------|---------|
| Virtual Machines | `virtual_machines` | P1 or P2 |
| Storage Accounts | `storage_accounts` | V2 |
| SQL Servers | `sql_servers` | — |
| SQL Server VMs | `sql_server_vms` | — |
| App Services | `app_services` | — |
| Key Vaults | `key_vaults` | — |
| Resource Manager | `arm` | PerApiCall |
| DNS | `dns` | — |
| Containers | `containers` | — |
| Open Source Databases | `oss_databases` | — |
| Cosmos DB | `cosmos_db` | — |
| Cloud Posture (CSPM) | `cloud_posture` | — |
| APIs | `api` | — |
| AI Services | `ai_services` | — |

## Resources Created

| Resource | Mode | Description |
|----------|------|-------------|
| 14× `azurerm_security_center_subscription_pricing.*` | 1 each | Individual Defender plan pricing |
| `azurerm_security_center_contact.this` | 1 | Security contact for alert notifications |
| `azurerm_security_center_auto_provisioning.this` | 1 | LA agent auto-provisioning |
| `azurerm_security_center_workspace.this` | 1 | Workspace for data export |

## Inputs

### Required

| Variable | Type | Description |
|----------|------|-------------|
| `security_contact_email` | `string` | Email for alerts (regex validated) |
| `log_analytics_workspace_id` | `string` | LAW resource ID |

### Optional

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `defender_plans` | `map(object)` | All 14 enabled | Map of plan → {enabled, subplan} |
| `security_contact_phone` | `string` | `null` | Phone number |
| `security_contact_name` | `string` | `"Security Team"` | Contact display name |
| `enable_auto_provisioning` | `bool` | `true` | Auto-provision LA agent |
| `alert_notifications_state` | `string` | `"On"` | Email alerts On/Off |
| `alerts_to_admins_state` | `string` | `"On"` | Alerts to subscription admins |
| `alert_notifications_min_severity` | `string` | `"Medium"` | Min notification severity |

## Outputs

| Output | Description |
|--------|-------------|
| `defender_plans_status` | Map of all 14 plans to tier (Standard/Free) |
| `enabled_plans` / `disabled_plans` | Lists of plan names |
| `security_contact_id` / `security_contact_email` | Contact details |
| `auto_provisioning_status` | On/Off |
| `outputs_for_s02` | Pre-formatted for S02-Sentinel |
| `configuration_summary` | Full summary object |

## How to Use in the Orchestrator

S01 is **not called directly** in the Full Orchestrator. Instead, Defender for Cloud is deployed **via Azure Policy** through the **G03 module** (`deploy_defender_for_cloud = true`). This ensures Defender is enabled on all current and future subscriptions via policy enforcement at the root management group.

### Policy-Based Deployment (recommended, via G03)

```hcl
module "policy_assignments" {
  source = "...G03-policy-assignments?ref=main"

  # ── Enable Defender via Policy ──
  deploy_defender_for_cloud   = var.deploy_defender_for_cloud     # true
  defender_management_group_id = module.management_groups.root_mg_id
  defender_plans = var.defender_plans    # ["cspm", "servers", "containers", "storage", ...]
  deploy_defender_remediation = false     # Handled by separate remediation batches

  # Custom policy IDs for plans not covered by built-in policies
  custom_defender_policy_ids = {
    api = module.policy_definitions.policy_definition_ids["deploy-defender-for-api"]
    ai  = module.policy_definitions.policy_definition_ids["deploy-defender-for-ai"]
  }
}
```

### Standalone Deployment (per-subscription, if needed)

```hcl
module "s01_defender" {
  source = "git::https://github.com/samirbelkessa/Landing-Zone//Terraform-Azure-LZ/modules/Security/S01-defender-for-cloud?ref=main"

  # ── Required ──
  security_contact_email     = "security@company.com"
  log_analytics_workspace_id = module.m01_log_analytics[0].id

  # ── Plans (all enabled by default) ──
  defender_plans = {
    virtual_machines = { enabled = true, subplan = "P2" }
    storage_accounts = { enabled = true, subplan = "V2" }
    containers       = { enabled = true }
    key_vaults       = { enabled = true }
    # ... 14 plans total
  }

  # ── Auto-Provisioning ──
  enable_auto_provisioning = true

  providers = { azurerm = azurerm.management }
}
```

### Options Guide

| Option | When to change | Impact |
|--------|---------------|--------|
| `deploy_defender_for_cloud = true` (G03) | Policy-based deployment | Defender on all subs via policy (recommended) |
| Per-subscription S01 call | Granular control needed | Per-sub plan configuration |
| `defender_plans.virtual_machines.subplan = "P1"` | Cost reduction | Basic VM protection (vs P2 full) |
| `enable_auto_provisioning = false` | Use AMA instead of MMA | Stops legacy LA agent deployment |

## Dependencies

- **Upstream:** M01 (LAW ID)
- **Downstream:** S02 (via `outputs_for_s02`), G03 (Defender via policy is an alternative path)

## Implementation Notes

- **Individual resources per plan** (not a dynamic loop) — explicit control and readability
- **Subplans conditional:** Only set when tier is "Standard" (prevents API errors)
- **Scoped to current subscription** via `data.azurerm_client_config.current`

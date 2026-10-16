# M03 — Monitor Action Groups

## Overview

Creates Azure Monitor Action Groups for alert notification channels. Supports 10 receiver types and pre-built default action groups (Critical, Warning, Info). Consumed downstream by M04 (Monitor Alerts).

**Module path:** `modules/Management/M03-monitor-action-groups/`

## Resources Created

| Resource | Mode | Description |
|----------|------|-------------|
| `module "naming"` (F02) | 1 | Generates base name (resource type `ag`) |
| `azurerm_monitor_action_group.action_groups` | for_each | Action groups (merged custom + defaults) |

## 10 Supported Receiver Types

| Receiver | Key Features |
|----------|-------------|
| `email_receiver` | Email address, common alert schema |
| `sms_receiver` | Country code + phone number |
| `webhook_receiver` | Service URI, optional AAD auth |
| `azure_function_receiver` | Function App resource + trigger URL |
| `logic_app_receiver` | Logic App resource + callback URL |
| `automation_runbook_receiver` | Automation Account + runbook |
| `voice_receiver` | Country code + phone number |
| `arm_role_receiver` | Azure RBAC role ID |
| `event_hub_receiver` | Event Hub namespace + name |
| `itsm_receiver` | ITSM workspace + connection + ticket config |

## Inputs

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `workload` | `string` | (required) | Workload name (2–30 chars) |
| `environment` | `string` | (required) | Environment code |
| `resource_group_name` | `string` | (required) | Target resource group |
| `action_groups` | `map(object)` | `{}` | Action group definitions (10 receiver types) |
| `create_default_action_groups` | `bool` | `false` | Create Critical/Warning/Info defaults |
| `default_email_receivers` | `list(object)` | `[]` | Default email addresses |
| `default_webhook_url` | `string` | `null` | Default webhook URL |

## Outputs

| Output | Description |
|--------|-------------|
| `action_group_ids` | Map of action group IDs |
| `critical_action_group_id` / `warning_action_group_id` / `info_action_group_id` | Default group IDs |
| `outputs_for_m04` | Pre-formatted for M04 (action_group_ids, critical/warning/info, resource_group) |

## How to Use in the Orchestrator

Deployed conditionally via `var.deploy_m03_action_groups`. Creates the notification channels consumed by M04 alerts.

```hcl
module "m03_action_groups" {
  source = "git::https://github.com/samirbelkessa/Landing-Zone//Terraform-Azure-LZ/modules/Management/M03-monitor-action-groups?ref=main"

  # ── Required ──
  workload            = var.management_project_name
  environment         = var.environment
  resource_group_name = try(module.l01-subscription-vending-v2.resource_groups_by_subscription["management"]["monitoring"].name, "")

  # ── Naming ──
  custom_name = local.tas_naming_management.action_group
  region      = local.primary_region
  instance    = "01"

  # ── Default Action Groups ──
  create_default_action_groups = var.create_default_action_groups    # true = creates Critical/Warning/Info groups
  default_email_receivers      = var.default_email_receivers          # [{name, email_address}]
  default_webhook_url          = var.default_webhook_url              # Optional webhook (Teams, PagerDuty, etc.)

  # ── Custom Action Groups ──
  action_groups = var.custom_action_groups    # Additional groups with any of the 10 receiver types

  # ── Conditional ──
  count = var.deploy_m03_action_groups ? 1 : 0
  tags  = local.tags_management

  depends_on = [module.l01-subscription-vending-v2]
  providers  = { azurerm = azurerm.management }
}
```

### Options Guide

| Option | When to change | Impact |
|--------|---------------|--------|
| `create_default_action_groups = true` | Standard alert routing needed | Creates Critical/Warning/Info groups |
| `create_default_action_groups = false` | Custom groups only | No default groups, define all in `action_groups` |
| `default_email_receivers = [...]` | Set email notification targets | Emails on Critical/Warning/Info alerts |
| `default_webhook_url = "https://..."` | Teams/Slack/PagerDuty integration | Webhook notifications on all severities |
| `action_groups = {...}` | Custom receivers (SMS, Logic App, Function) | Full control over notification channels |

## Dependencies

- **Upstream:** None (standalone)
- **Downstream:** M04 (alert action group binding)

## Implementation Notes

- **short_name** enforced to ≤12 characters (Azure SMS/alert display limitation)
- **Webhook AAD auth** supports `object_id`, `identifier_uri`, `tenant_id`
- Naming: `${base_name}-${each.key}` pattern

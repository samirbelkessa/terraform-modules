# M02 — Automation Account

## Overview

Creates an Azure Automation Account for runbook execution, DSC configuration, scheduled tasks, and Log Analytics integration (linked service for Update Management and Change Tracking). Supports runbooks, schedules, credentials, variables, PowerShell modules, DSC configurations, and webhooks.

**Module path:** `modules/Management/M02-automation-account/`

## Resources Created

| Resource | Mode | Description |
|----------|------|-------------|
| `module "naming"` (F02) | 1 | Generates name (resource type `aa`) |
| `azurerm_automation_account.this` | 1 | Automation Account with managed identity |
| `azurerm_log_analytics_linked_service.this` | count 0–1 | Links AA to LAW |
| `azurerm_automation_runbook.runbooks` | for_each | Runbooks (PowerShell, Python, Graph) |
| `azurerm_automation_schedule.schedules` | for_each | Execution schedules |
| `azurerm_automation_credential.credentials` | for_each | Stored credentials (sensitive) |
| `azurerm_automation_variable_string/int/bool` | for_each | Typed variables |
| `azurerm_automation_module.modules` | for_each | PowerShell modules |
| `azurerm_automation_dsc_configuration.configurations` | for_each | DSC configurations |
| `azurerm_automation_webhook.webhooks` | for_each | Webhook triggers (sensitive) |
| `time_sleep.wait_for_policies` | 1 | 120s delay for policy propagation |
| `azurerm_monitor_diagnostic_setting.this` | count 0–1 | Diagnostic settings |

## Inputs

### Required

| Variable | Type | Description |
|----------|------|-------------|
| `workload` | `string` | Workload name (2–30 chars) |
| `environment` | `string` | Environment code |
| `resource_group_name` | `string` | Target resource group |
| `location` | `string` | Azure region |

### Key Optional

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `log_analytics_workspace_id` | `string` | `null` | LAW to link |
| `create_la_linked_service` | `bool` | `true` | Create LAW linked service |
| `identity_type` | `string` | `"SystemAssigned"` | Managed identity type |
| `runbooks` | `map(object)` | `{}` | Runbook definitions |
| `schedules` | `map(object)` | `{}` | Schedule definitions |
| `credentials` | `map(object)` | `{}` | Credentials (sensitive) |
| `powershell_modules` | `map(object)` | `{}` | PowerShell module URIs |

## Outputs

| Output | Description |
|--------|-------------|
| `id` / `name` | Automation Account identifiers |
| `principal_id` | System-assigned managed identity principal ID |
| `linked_service_id` | LAW linked service ID |
| `runbooks` / `schedules` / `webhooks` | Maps of deployed components |
| `outputs_for_m06` | Pre-formatted for M06 Update Management |
| `ready` | Boolean signal with depends_on |

## How to Use in the Orchestrator

Deployed conditionally via `local.m02_can_deploy` (requires M01 LAW + subscription vending).

```hcl
module "m02_automation_account" {
  source = "git::https://github.com/samirbelkessa/Landing-Zone//Terraform-Azure-LZ/modules/Management/M02-automation-account?ref=main"

  # ── Required ──
  workload            = var.management_project_name
  environment         = var.environment
  location            = var.default_location
  resource_group_name = try(module.l01-subscription-vending-v2.resource_groups_by_subscription["management"]["automation"].name)

  # ── Naming ──
  custom_name = local.tas_naming_management.automation_account
  region      = local.primary_region
  instance    = "01"

  # ── Identity & Configuration ──
  identity_type                 = "SystemAssigned"
  local_authentication_enabled  = true
  public_network_access_enabled = var.automation_public_access

  # ── LAW Integration ──
  log_analytics_workspace_id        = module.m01_log_analytics[0].id
  log_analytics_resource_group_name = module.m01_log_analytics[0].resource_group_name
  create_la_linked_service          = false    # Set true for Update Management integration

  # ── Runbooks & Schedules ──
  schedules = local.management_default_schedules    # From locals.tf
  runbooks  = local.management_default_runbooks     # From locals.tf

  # ── Diagnostics ──
  enable_diagnostic_settings = false    # Use M05 instead for dedicated diagnostic settings

  # ── Conditional ──
  count = local.m02_can_deploy ? 1 : 0
  tags  = local.tags_management

  depends_on = [module.m01_log_analytics]
  providers  = { azurerm = azurerm.management }
}
```

### Options Guide

| Option | When to change | Impact |
|--------|---------------|--------|
| `create_la_linked_service = true` | Need Update Management/Change Tracking via LAW | Links AA to LAW |
| `enable_diagnostic_settings = true` | Self-diagnostics (alternative to M05) | Sends AA logs to LAW |
| `public_network_access_enabled = false` | Private-only access | Blocks public API access |
| `runbooks = {}` | No automation scripts needed | Empty AA (add later) |
| `schedules = {}` | No scheduled tasks | Empty schedule list |
| `identity_type = "UserAssigned"` | Need specific identity | Changes managed identity type |

## Dependencies

- **Upstream:** M01 (provides `log_analytics_workspace_id`)
- **Downstream:** M06 (Update Management integration)

## Implementation Notes

- **Sensitive handling:** `credentials` and `webhooks` use `nonsensitive(toset(keys(...)))` for iteration
- **Runbook dual sources:** Inline `content` or remote `uri` with SHA256 hash verification
- **120s policy wait** between AA creation and diagnostic settings
- **LA Linked Service** uses AA as `read_access_id` (standard for Update Management)

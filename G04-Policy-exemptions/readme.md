# G04 — Policy Exemptions

## Overview

Creates **Azure Policy Exemptions** at four scopes: management group, subscription, resource group, and individual resource. Supports two categories (Waiver and Mitigated), pre-built **brownfield migration** exemptions (Fortinet NGFW migration), and **sandbox relaxation**. Enforces governance guardrails including mandatory expiration dates on Waiver exemptions.

**Module path:** `modules/Governance/G04-Policy-exemptions/`

## Resources Created

| Resource | Mode | Description |
|----------|------|-------------|
| `terraform_data.waiver_expiration_validation` | conditional | Plan-time check: Waiver exemptions must have expiration dates |
| `azurerm_management_group_policy_exemption.exemptions` | for_each | MG-scope exemptions |
| `azurerm_subscription_policy_exemption.exemptions` | for_each | Subscription-scope exemptions |
| `azurerm_resource_group_policy_exemption.exemptions` | for_each | RG-scope exemptions |
| `azurerm_resource_policy_exemption.exemptions` | for_each | Resource-level exemptions |

## Inputs

### Exemption Variables (per scope)

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `management_group_exemptions` | `map(object)` | `{}` | MG-scope exemptions |
| `subscription_exemptions` | `map(object)` | `{}` | Subscription-scope exemptions |
| `resource_group_exemptions` | `map(object)` | `{}` | RG-scope exemptions |
| `resource_exemptions` | `map(object)` | `{}` | Resource-level exemptions |

Each exemption object: `policy_assignment_id`, `exemption_category` (Waiver/Mitigated), `display_name`, optional `description`, `expires_on`, `policy_definition_reference_ids`, `metadata`.

### Brownfield Migration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_brownfield_exemptions` | `bool` | `false` | Enable Fortinet NGFW migration exemptions |
| `brownfield_migration_end_date` | `string` | `null` | Expiration for all brownfield exemptions |
| `brownfield_subscriptions` | `map(object)` | `{}` | Subscriptions needing brownfield exemptions |
| `brownfield_resource_groups` | `map(object)` | `{}` | RGs needing brownfield exemptions |

### Sandbox Relaxation

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_sandbox_exemptions` | `bool` | `false` | Enable relaxed Sandbox exemptions |
| `sandbox_management_group_id` | `string` | `""` | Sandbox MG ID |
| `sandbox_exempted_policy_assignments` | `list(string)` | `[]` | Policy assignments to exempt in Sandbox |

### Governance Controls

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `require_expiration_for_waivers` | `bool` | `true` | Enforce expiration on Waiver exemptions |
| `max_waiver_duration_days` | `number` | `365` | Maximum waiver duration |

## Outputs

| Output | Description |
|--------|-------------|
| `all_exemption_ids` | Merged map of all exemption IDs (prefixed by scope) |
| `brownfield_exemption_ids` | Brownfield migration exemptions by scope |
| `sandbox_exemption_ids` | Sandbox exemptions |
| `exemptions_by_category` | Organised by Waiver vs Mitigated |
| `waivers_without_expiration` | Compliance warning list |
| `audit_report` | Full audit report with `requires_attention` flag per exemption |
| `summary` | Counts by scope, category, brownfield/sandbox status |

## How to Use in the Orchestrator

```hcl
module "policy_exemptions" {
  source = "git::https://github.com/samirbelkessa/Landing-Zone.git//...G04-Policy-exemptions?ref=main"
  count  = var.deploy_exemptions ? 1 : 0

  # ── Exemptions per scope ──
  management_group_exemptions = var.management_group_exemptions  # {}
  subscription_exemptions     = var.subscription_exemptions      # {}
  resource_group_exemptions   = var.resource_group_exemptions    # {}
  resource_exemptions         = var.resource_exemptions          # {}

  # ── Brownfield migration ──
  enable_brownfield_exemptions  = var.enable_brownfield_exemptions   # false
  brownfield_migration_end_date = var.brownfield_migration_end_date  # null
  brownfield_subscriptions      = var.brownfield_subscriptions       # {}
  brownfield_resource_groups    = var.brownfield_resource_groups     # {}

  # ── Sandbox relaxation ──
  enable_sandbox_exemptions           = var.enable_sandbox_exemptions
  sandbox_management_group_id         = module.management_groups.sandbox_mg_id
  sandbox_exempted_policy_assignments = []  # Policy assignment IDs to exempt

  # ── Governance controls ──
  require_expiration_for_waivers = var.require_expiration_for_waivers  # true
  max_waiver_duration_days       = var.max_waiver_duration_days        # 365

  depends_on = [module.policy_assignments]
}
```

### Options Guide

| Option | When to change | Impact |
|--------|---------------|--------|
| `enable_brownfield_exemptions = true` | Migrating from legacy (Fortinet, etc.) | Temporary exemptions with end date |
| `enable_sandbox_exemptions = true` | Relaxed Sandbox policies | Exempts sandbox from strict enforcement |
| `require_expiration_for_waivers = false` | Allow permanent waivers | Reduces governance strictness |
| `resource_exemptions` | Exempt specific resources | Granular per-resource exemptions |

## Dependencies

- **Upstream:** G03 (provides `policy_assignment_id` for exemptions)
- **Downstream:** None — terminal module in governance chain

## Implementation Notes

- **Exemption name truncation:** All names truncated to 64 characters (Azure limitation)
- **Selective policy exemption:** `policy_definition_reference_ids` allows exempting specific policies within an initiative
- **Brownfield pattern:** Temporary exemptions with shared end date for legacy infrastructure migration
- **Audit report output:** Flags each exemption with `requires_attention` for Waiver without expiration
- **`create_before_destroy = true`** on all exemptions
- **Four-scope coverage** (MG, subscription, RG, resource) — most comprehensive scope support in the governance chain

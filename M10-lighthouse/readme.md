# M10 — Lighthouse (MSP Delegation)

## Overview

Deploys Azure Lighthouse managed service definitions and assignments for MSP cross-tenant delegation. Enables a managing tenant (service provider) to manage customer subscriptions through delegated access. Supports both permanent RBAC authorisations and eligible (Just-In-Time) authorisations with MFA and approval workflows.

**Module path:** `modules/Management/M10-lighthouse/`

## Resources Created

| Resource | Mode | Description |
|----------|------|-------------|
| `azurerm_lighthouse_definition.this` | for_each | Per-subscription Lighthouse definition (when `enable_lighthouse = true`) |
| `azurerm_lighthouse_assignment.this` | for_each | Per-subscription Lighthouse assignment (when `enable_lighthouse = true`) |

## Inputs

### Required

| Variable | Type | Description |
|----------|------|-------------|
| `msp_offer_name` | `string` | Display name of the managed service offer |
| `managing_tenant_id` | `string` | MSP tenant ID (UUID validated) |
| `subscription_ids` | `map(string)` | Subscription names to IDs (at least one) |
| `authorizations` | `list(object)` | Permanent RBAC authorisations (at least one) |

Each authorisation: `principal_id`, `role_definition_id`, `principal_display_name`

### Optional

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_lighthouse` | `bool` | `false` | Feature flag — zero resources when disabled |
| `msp_offer_description` | `string` | `""` | Offer description |
| `eligible_authorizations` | `list(object)` | `[]` | JIT authorisations with MFA + approval |

### JIT Access Policy (per eligible authorisation)

| Field | Default | Description |
|-------|---------|-------------|
| `multi_factor_auth_provider` | `"Azure"` | MFA provider |
| `maximum_activation_duration` | `"PT4H"` | Max activation (4 hours) |
| `approvers` | `[]` | Optional approval list |

## Outputs

| Output | Description |
|--------|-------------|
| `definition_ids` | Map of subscription names to Lighthouse Definition IDs |
| `assignment_ids` | Map of subscription names to Lighthouse Assignment IDs |
| `configuration` | Summary: enabled, offer_name, tenant_id, auth counts |

## How to Use in the Orchestrator

Deployed conditionally via `var.enable_lighthouse`. No provider alias needed (uses default provider).

```hcl
module "m10_lighthouse" {
  source = "git::https://github.com/samirbelkessa/Landing-Zone//Terraform-Azure-LZ/modules/Management/M10-lighthouse?ref=main"

  # ── Feature Toggle ──
  enable_lighthouse = var.enable_lighthouse    # false = zero resources

  # ── MSP Configuration ──
  msp_offer_name        = var.lighthouse_msp_offer_name           # "Experteq Managed Services"
  msp_offer_description = var.lighthouse_msp_offer_description    # Display text in Azure Portal
  managing_tenant_id    = var.lighthouse_managing_tenant_id        # MSP Azure AD tenant ID

  # ── Subscriptions to Delegate ──
  subscription_ids = var.lighthouse_subscription_ids    # { management = "xxx-xxx", connectivity = "yyy-yyy" }

  # ── Permanent Authorisations ──
  authorizations = var.lighthouse_authorizations
  # Example:
  # [{
  #   principal_id           = "aaa-bbb-ccc"
  #   role_definition_id     = "b24988ac-6180-42a0-ab88-20f7382dd24c"    # Contributor
  #   principal_display_name = "Experteq L3 Engineers"
  # }]

  # ── JIT Authorisations (Optional) ──
  eligible_authorizations = var.lighthouse_eligible_authorizations
  # Example:
  # [{
  #   principal_id           = "ddd-eee-fff"
  #   role_definition_id     = "acdd72a7-3385-48ef-bd42-f606fba81ae7"    # Reader
  #   principal_display_name = "Experteq L1 Support"
  #   just_in_time_access_policy = {
  #     multi_factor_auth_provider  = "Azure"
  #     maximum_activation_duration = "PT4H"
  #   }
  # }]
}
```

### Options Guide

| Option | When to change | Impact |
|--------|---------------|--------|
| `enable_lighthouse = true` | MSP needs cross-tenant management | Creates definitions + assignments per subscription |
| `enable_lighthouse = false` | No MSP delegation | Zero resources deployed |
| `eligible_authorizations = [...]` | JIT access with MFA | Time-limited, approval-based access |
| `subscription_ids = {...}` | Add/remove delegated subscriptions | Controls which subs are managed |

## Dependencies

- **Upstream:** L01 (subscription IDs)
- **Downstream:** None

## Implementation Notes

- **Feature flag pattern:** Entire module gated by `enable_lighthouse` — `for_each = var.enable_lighthouse ? var.subscription_ids : {}`
- **Per-subscription definitions:** One Lighthouse definition per subscription (scope-bound)
- **No F02/F03 integration** — Lighthouse resources do not support Azure tags
- **Assignment name = subscription ID** for idempotent identity

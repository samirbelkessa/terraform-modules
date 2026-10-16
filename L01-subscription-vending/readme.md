# L01 — Subscription Vending

## Overview

Automates Azure subscription lifecycle management: creates new subscriptions (greenfield), places existing subscriptions into management groups (brownfield), or both (hybrid). Handles billing scope resolution (MCA/MPA), subscription budgets, RBAC assignments, resource group creation, and resource provider registration.

**Module path:** `modules/LandingZone/L01-subscription-vending/`

## Resources Created

| Resource | Mode | Description |
|----------|------|-------------|
| `azurerm_subscription.this` | for_each | New subscriptions (greenfield/hybrid mode) |
| `time_sleep.wait_for_subscription` | 1 | 60s delay for Azure propagation |
| `azurerm_management_group_subscription_association.new_subscriptions` | for_each | MG placement for new subscriptions |
| `azurerm_management_group_subscription_association.existing_subscriptions` | for_each | MG placement for existing subscriptions (brownfield) |
| `azurerm_consumption_budget_subscription.this` | for_each | Subscription budgets |
| `azurerm_role_assignment.default` | for_each | RBAC assignments |
| `azapi_resource.resource_groups` | for_each | Cross-subscription RGs (via AzAPI) |
| `azapi_resource_action.register_providers` | for_each | Resource provider registration |

## Three Deployment Modes

| Mode | Creates New | Places Existing | Use Case |
|------|-------------|-----------------|----------|
| `greenfield` | Yes | No | New subscriptions only |
| `brownfield` | No | Yes | Existing subscriptions into MGs |
| `hybrid` | Yes | Yes | Both (default) |

## Inputs

### Required

| Variable | Type | Description |
|----------|------|-------------|
| `subscriptions` | `map(object)` | Subscription definitions: display_name, archetype, workload_type, owner, tags, budget |
| `billing_account_name` | `string` | Billing account name (EA/MCA) |
| `management_group_ids` | `map(string)` | MG IDs from F01 |

### Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `billing_type` | `string` | `"MCA"` | MCA or MPA billing |
| `deployment_mode` | `string` | `"hybrid"` | greenfield/brownfield/hybrid |
| `existing_subscriptions` | `map(object)` | `{}` | Existing subs for brownfield placement |
| `default_role_assignments` | `map(object)` | `{}` | Default RBAC for all subs |
| `resource_groups` | `map(object)` | `{}` | Resource groups to create |
| `required_providers` | `list(string)` | 19 providers | Resource provider namespaces to register |

## Outputs

| Output | Description |
|--------|-------------|
| `subscription_ids` / `subscription_names` | Maps of key to subscription attributes |
| `subscriptions` | Full details with resource_id, archetype, MG, etc. |
| `subscriptions_by_archetype` | Grouped by archetype |
| `corp_prod_subscription_ids` / `online_prod_subscription_ids` / etc. | Archetype-specific lists |
| `resource_groups_by_subscription` | RGs grouped by subscription |
| `summary` | Total counts by archetype |

## How to Use in the Orchestrator

L01 is one of the **earliest modules deployed** — almost everything depends on it for subscription IDs and resource group references.

```hcl
module "l01-subscription-vending-v2" {
  source = "git::https://github.com/samirbelkessa/Landing-Zone//Terraform-Azure-LZ/modules/LandingZone/L01-subscription-vending?ref=main"

  # ── Deployment Mode ──
  deployment_mode = var.deployment_mode    # "brownfield" (existing subs) / "greenfield" / "hybrid"

  # ── Existing Subscriptions (brownfield) ──
  existing_subscriptions = var.existing_subscriptions
  # {
  #   management   = { subscription_id = "xxx", management_group = "management" }
  #   connectivity = { subscription_id = "yyy", management_group = "connectivity" }
  #   identity     = { subscription_id = "zzz", management_group = "identity" }
  #   security     = { subscription_id = "aaa", management_group = "management" }
  #   client-dev   = { subscription_id = "bbb", management_group = "corp_nonprod" }
  #   client-prod  = { subscription_id = "ccc", management_group = "corp_prod" }
  # }

  # ── New Subscriptions (greenfield) ──
  subscriptions = var.subscriptions    # New subscription definitions

  # ── Billing ──
  billing_type         = var.billing_type           # "MCA" or "MPA"
  billing_account_name = var.billing_account_name
  billing_profile_name = var.billing_profile_name
  invoice_section_name = var.invoice_section_name

  # ── MG Placement ──
  management_group_ids = module.management_groups.all_mg_ids

  # ── Resource Groups ──
  resource_groups  = local.effective_connectivity_resource_groups
  custom_rg_names  = local.tas_custom_rg_names    # TAS naming convention
  customer_name    = var.customer_name
  root_id          = var.root_id
  default_location = var.default_location

  # ── TAS Naming ──
  enable_tas_naming = true    # Generates RG names via TAS convention

  depends_on = [module.management_groups]
}
```

### Key Outputs Used Everywhere

```hcl
# Resource group references (used by 15+ downstream modules)
module.l01-subscription-vending-v2.resource_groups_by_subscription["management"]["monitoring"].name
module.l01-subscription-vending-v2.resource_groups_by_subscription["connectivity"]["network-aue"].name
module.l01-subscription-vending-v2.resource_groups_by_subscription["management"]["automation"].name
```

### Options Guide

| Option | When to change | Impact |
|--------|---------------|--------|
| `deployment_mode = "brownfield"` | All subscriptions pre-exist | No new subscriptions created, only MG placement |
| `deployment_mode = "greenfield"` | All subscriptions new | Creates subscriptions via billing API |
| `deployment_mode = "hybrid"` | Mix of existing and new | Both paths active (default) |
| `enable_tas_naming = true` | TAS naming standard | Auto-generates RG names from convention |
| `billing_type = "MPA"` | CSP/Partner billing | Different billing scope resolution |
| `custom_rg_names = {...}` | Override auto-generated RG names | Manual RG naming |

## Dependencies

- **Upstream:** F01 (management group IDs for placement)
- **Downstream:** All modules that need subscription IDs

## Implementation Notes

- **Dual billing support:** MCA (own tenant) and MPA (CSP/partner) via conditional data sources
- **60s propagation wait** before MG placement
- **RGs via AzAPI** (not `azurerm_resource_group`) to support cross-subscription from a single provider context
- **Resource provider registration** via `azapi_resource_action` cross-product of subscriptions × namespaces
- **12 valid archetypes** enforced at variable level
- **Budget start_date** uses `formatdate(timestamp())` with `ignore_changes`

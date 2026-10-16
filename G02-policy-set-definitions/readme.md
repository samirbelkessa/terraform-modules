# G02 — Policy Set Definitions (Initiatives)

## Overview

Groups individual policy definitions (from G01) into **Azure Policy Initiatives**. Creates 7 CAF-aligned baseline initiatives (security, network, monitoring, governance, backup, cost, identity) and 6 archetype-specific initiatives (online-prod/nonprod, corp-prod/nonprod, sandbox, decommissioned). Supports custom initiatives.

**Module path:** `modules/Governance/G02-policy-set-definitions/`

## Resources Created

| Resource | Mode | Description |
|----------|------|-------------|
| `azurerm_policy_set_definition.caf_initiatives` | for_each | CAF-aligned initiatives from G01 policy definitions |
| `azurerm_policy_set_definition.custom_initiatives` | for_each | User-provided custom initiatives |

## Inputs

### Required

| Variable | Type | Description |
|----------|------|-------------|
| `management_group_id` | `string` | Target MG for initiative definitions |
| `policy_definition_ids` | `map(string)` | Policy definition IDs from G01 |

### Optional — From G01

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `builtin_policy_ids` | `map(string)` | `{}` | Built-in policy IDs from G01 |
| `builtin_initiative_ids` | `map(string)` | `{}` | Built-in initiative IDs from G01 |

### Baseline Toggles

| Variable | Default | Description |
|----------|---------|-------------|
| `deploy_caf_initiatives` | `true` | Master toggle |
| `deploy_security_initiative` | `true` | Security baseline |
| `deploy_network_initiative` | `true` | Network baseline |
| `deploy_monitoring_initiative` | `true` | Monitoring baseline |
| `deploy_governance_initiative` | `true` | Governance baseline |
| `deploy_backup_initiative` | `true` | Backup baseline |
| `deploy_cost_initiative` | `true` | Cost management |
| `deploy_identity_initiative` | `true` | Identity baseline |
| `deploy_waf_policies` | `true` | WAF policies in Online initiatives |

### Archetype Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `deploy_archetype_initiatives` | `bool` | `true` | Toggle archetype-specific initiatives |
| `archetypes_to_deploy` | `list(string)` | 6 archetypes | Which archetypes get specific initiatives |

### Built-in Compliance Toggles

| Variable | Default | Description |
|----------|---------|-------------|
| `include_azure_security_benchmark` | `true` | Azure Security Benchmark |
| `include_vm_insights` | `true` | VM Insights initiative |
| `include_nist_initiative` | `false` | NIST SP 800-53 Rev. 5 |
| `include_iso27001_initiative` | `false` | ISO 27001:2013 |
| `include_cis_initiative` | `false` | CIS Azure Foundations Benchmark |

## Outputs

| Output | Description |
|--------|-------------|
| `caf_initiative_ids` | Map of CAF initiative names to resource IDs |
| `builtin_initiatives_for_assignment` | Built-in initiative IDs for direct G03 assignment |
| `archetype_initiative_ids` | Archetype-specific initiative IDs |
| `baseline_initiative_ids` | Baseline initiative IDs |
| `all_initiative_ids` | Merged map of all initiative IDs |
| `summary` | Counts, enabled built-ins, deployed archetypes |

## How to Use in the Orchestrator

```hcl
module "policy_set_definitions" {
  source = "git::https://github.com/samirbelkessa/Landing-Zone.git//...G02-policy-set-definitions?ref=main"

  # ── Required (from G01 + F01) ──
  management_group_id   = module.management_groups.root_mg_id
  policy_definition_ids = module.policy_definitions.policy_definition_ids
  builtin_policy_ids    = module.policy_definitions.builtin_policy_ids
  builtin_initiative_ids = module.policy_definitions.builtin_initiative_ids

  # ── Baseline initiative toggles (all default true) ──
  deploy_caf_initiatives       = var.deploy_caf_initiatives
  deploy_security_initiative   = var.deploy_security_initiative
  deploy_network_initiative    = var.deploy_network_initiative
  deploy_monitoring_initiative = var.deploy_monitoring_initiative
  deploy_governance_initiative = var.deploy_governance_initiative
  deploy_backup_initiative     = var.deploy_backup_initiative
  deploy_cost_initiative       = var.deploy_cost_initiative
  deploy_identity_initiative   = var.deploy_identity_initiative

  # ── Archetype initiatives ──
  deploy_archetype_initiatives = var.deploy_archetype_initiatives
  archetypes_to_deploy         = var.archetypes_to_deploy

  # ── Built-in compliance frameworks ──
  include_azure_security_benchmark = var.include_azure_security_benchmark  # true
  include_vm_insights              = var.include_vm_insights               # true
  include_nist_initiative          = var.include_nist_initiative            # false
  include_iso27001_initiative      = var.include_iso27001_initiative        # false

  # ── WAF ──
  deploy_waf_policies = var.deploy_waf_policies  # false if using external WAF (Cloudflare)

  depends_on = [module.policy_definitions, time_sleep.wait_for_rbac_propagation]
}
```

### Options Guide

| Option | When to change | Impact |
|--------|---------------|--------|
| `deploy_waf_policies = false` | Using external WAF (Cloudflare, etc.) | Removes WAF policies from Online initiatives |
| `include_nist_initiative = true` | NIST compliance required | Adds NIST SP 800-53 for direct assignment |
| `deploy_archetype_initiatives = false` | Only baseline, no per-archetype | Simpler but less granular enforcement |
| `custom_policy_set_definitions` | Add custom initiatives | Merged with CAF initiatives |

## Dependencies

- **Upstream:** G01 (provides `policy_definition_ids`, `builtin_policy_ids`)
- **Downstream:** G03 (consumes `caf_initiative_ids`, `builtin_initiatives_for_assignment`)

## Implementation Notes

- **Azure limitation:** Built-in initiatives (Security Benchmark, VM Insights, NIST, ISO) cannot be nested in custom initiatives — must be assigned directly via G03
- **`create_before_destroy = true`** on all initiatives to maintain enforcement continuity
- **Dynamic `policy_definition_reference` blocks** for variable numbers of policies per initiative
- **Metadata** stamped with version, category, source, and project

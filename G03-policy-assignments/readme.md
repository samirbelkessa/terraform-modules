# G03 — Policy Assignments

## Overview

The most complex governance module. **Assigns policies and initiatives** (from G01/G02) at three scopes: management group, subscription, and resource group. Handles managed identity creation for DeployIfNotExists/Modify policies, automatic role assignments, and includes a dedicated **Defender for Cloud** sub-module that activates Defender plans via policy-based deployment.

**Module path:** `modules/Governance/G03-policy-assignments/`

## Resources Created

### main.tf

| Resource | Mode | Description |
|----------|------|-------------|
| `azurerm_management_group_policy_assignment.assignments` | for_each | MG-scope policy assignments |
| `azurerm_subscription_policy_assignment.assignments` | for_each | Subscription-scope assignments |
| `azurerm_resource_group_policy_assignment.assignments` | for_each | RG-scope assignments |
| `azurerm_role_assignment.mg_policy_identity` | conditional | Roles for MG policy managed identities |
| `azurerm_role_assignment.sub_policy_identity` | conditional | Roles for subscription policy identities |
| `azurerm_role_assignment.rg_policy_identity` | conditional | Roles for RG policy identities |

### defender_for_cloud.tf

| Resource | Mode | Description |
|----------|------|-------------|
| `azurerm_management_group_policy_assignment.defender` | for_each | Per-plan Defender assignments at Root MG |
| `azurerm_role_assignment.defender_security_admin` | for_each | Security Admin role per plan identity |
| `azurerm_role_assignment.defender_contributor` | for_each | Contributor role per plan identity |
| `azurerm_management_group_policy_remediation.defender` | conditional | Remediation tasks for existing subscriptions |

**Formula:** Per Defender plan = 1 assignment + 2 role assignments + 1 remediation = **4 resources**

## Inputs

### Assignment Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `management_group_assignments` | `map(object)` | `{}` | MG-scope assignments (policy_definition_id OR policy_set_definition_id, mutually exclusive) |
| `subscription_assignments` | `map(object)` | `{}` | Subscription-scope assignments |
| `resource_group_assignments` | `map(object)` | `{}` | RG-scope assignments |

### CAF Automatic Assignments

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `deploy_caf_assignments` | `bool` | `false` | Enable automatic CAF assignments |
| `caf_management_groups` | `map(string)` | `{}` | CAF MG IDs from F01 |
| `caf_initiative_ids` | `map(string)` | `{}` | Initiative IDs from G02 |
| `caf_builtin_initiative_ids` | `map(string)` | `{}` | Built-in initiative IDs |

### Defender for Cloud

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `deploy_defender_for_cloud` | `bool` | `false` | Enable Defender via policy |
| `defender_plans` | `list(string)` | 12 plans | Plans to enable (cspm, servers, containers, etc.) |
| `defender_management_group_id` | `string` | `""` | Root MG for Defender assignments |
| `deploy_defender_remediation` | `bool` | `true` | Create remediation tasks |

### Deny Resource Types (per MG scope)

| Variable | Default Count | Description |
|----------|---------------|-------------|
| `deny_resource_types_corp` | 16 types | Blocked in Corp LZs (VPN, ExpressRoute, Firewall, etc.) |
| `deny_resource_types_online` | 10 types | Blocked in Online LZs |
| `deny_resource_types_connectivity` | 7 types | Blocked in Connectivity sub |
| `deny_resource_types_identity` | 10 types | Blocked in Identity sub |
| `deny_resource_types_security` | 10 types | Blocked in Security sub |
| `deny_resource_types_management` | 10 types | Blocked in Management sub |

## Outputs

| Output | Description |
|--------|-------------|
| `mg_assignment_ids` / `sub_assignment_ids` / `rg_assignment_ids` | Per-scope assignment ID maps |
| `all_assignment_ids` | Merged map of all assignment IDs |
| `all_assignment_principal_ids` | All assignments with managed identity principal IDs |
| `role_assignment_ids` | All role assignment IDs (prefixed mg-/sub-/rg-) |
| `remediation_commands` | Ready-to-run Azure CLI commands for manual remediation |
| `defender_assignment_ids` / `defender_principal_ids` / `defender_remediation_ids` | Defender-specific IDs |
| `defender_summary` | Defender deployment summary |

## How to Use in the Orchestrator

Deployed conditionally via `deploy_policy_assignments`.

```hcl
module "policy_assignments" {
  source = "git::https://github.com/samirbelkessa/Landing-Zone.git//...G03-policy-assignments?ref=main"
  count  = var.deploy_policy_assignments ? 1 : 0

  # ── From upstream modules ──
  caf_initiative_ids         = module.policy_set_definitions.all_initiative_ids
  caf_builtin_initiative_ids = module.policy_set_definitions.builtin_initiatives_for_assignment
  log_analytics_workspace_id = try(module.m01_log_analytics[0].id, "")
  defender_management_group_id = module.management_groups.root_mg_id

  # ── CAF automatic assignments ──
  deploy_caf_assignments = var.deploy_caf_assignments
  caf_management_groups = {
    root           = module.management_groups.root_mg_id
    platform       = module.management_groups.platform_mg_id
    landing_zones  = module.management_groups.landing_zones_mg_id
    corp_prod      = module.management_groups.corp_prod_mg_id
    # ... all 12 MG IDs
  }

  # ── Assignments (merged with locals for DCR/LAW policies) ──
  management_group_assignments = merge(
    var.management_group_assignments,
    local.ama_dcr_policy_assignments,       # AMA DCR policies
    local.law_table_retention_assignment    # LAW retention policy
  )
  subscription_assignments   = var.subscription_assignments
  resource_group_assignments = var.resource_group_assignments

  # ── Defender for Cloud ──
  deploy_defender_for_cloud   = var.deploy_defender_for_cloud
  deploy_defender_remediation = false  # Handled by separate remediation batches
  defender_plans              = var.defender_plans
  custom_defender_policy_ids = {
    api = module.policy_definitions.policy_definition_ids["deploy-defender-for-api"]
    ai  = module.policy_definitions.policy_definition_ids["deploy-defender-for-ai"]
  }

  # ── Deny resource types ──
  deploy_deny_resource_types = var.deploy_deny_resource_types
  create_role_assignments    = var.create_role_assignments
  allowed_regions            = var.allowed_regions

  depends_on = [module.policy_set_definitions, time_sleep.wait_for_rbac_propagation]
}
```

### Options Guide

| Option | When to change | Impact |
|--------|---------------|--------|
| `deploy_policy_assignments = false` | Skip all policy assignments (testing) | No policy enforcement |
| `deploy_caf_assignments = true` | Enable automatic CAF baseline assignments | Assigns initiatives to MGs automatically |
| `deploy_defender_for_cloud = true` | Enable Defender via policy (at Root MG) | Defender on all subscriptions |
| `deploy_deny_resource_types = true` | Block specific resource types per MG | Prevents resource sprawl |
| `management_group_assignments` | Custom MG-scope assignments | Add your own policy assignments |

## Dependencies

- **Upstream:** F01 (MG IDs), G01 (policy definition IDs), G02 (initiative IDs)
- **Downstream:** G04 (consumes `mg_assignment_ids` for exemptions)

## Implementation Notes

- **Assignment name truncation:** All names truncated to 24 characters (Azure limitation)
- **Mutual exclusivity validation:** Each assignment must use either `policy_definition_id` OR `policy_set_definition_id`, never both
- **Dynamic identity blocks:** Managed identity rendered only when `identity_type != "None"`
- **Automatic role assignment:** SystemAssigned identities auto-receive Contributor role (customisable)
- **Defender plan catalogue:** 12 plans with built-in policy GUIDs; `api` and `ai` use custom policy IDs
- **Remediation dependency chain:** Remediation depends on both Security Admin and Contributor roles
- **`create_before_destroy = true`** on all assignments

# F03 — Tags

## Overview

Utility module (creates no Azure infrastructure) that standardises tag generation for all Azure resources. Enforces 7 mandatory tags, adds conditional and automation tags, computes environment/criticality metadata, and derives backup/retention recommendations.

**Module path:** `modules/Fondations/F03-tags/`

## Mandatory Tags

| Tag | Source | Description |
|-----|--------|-------------|
| `Environment` | `var.environment` | Production, PreProduction, Development, Test, Sandbox, DR |
| `Owner` | `var.owner` | Email address of resource owner |
| `CostCenter` | `var.cost_center` | Cost center code (3–20 chars) |
| `Application` | `var.application` | Application/workload name |
| `Criticality` | `var.criticality` | Critical, High, Medium, Low |
| `DataClassification` | `var.data_classification` | Public, Internal, Confidential, Restricted |
| `ManagedBy` | hardcoded | Always `"Terraform"` |

## Resources Created

| Resource | Mode | Description |
|----------|------|-------------|
| `terraform_data.sandbox_expiration_check` | count 0–1 | Fails plan if Sandbox lacks expiration date |
| `terraform_data.tag_validation` | 1 | Validates mandatory tag values are non-empty |

## Inputs

### Required

| Variable | Type | Description |
|----------|------|-------------|
| `environment` | `string` | Production, PreProduction, Development, Test, Sandbox, DR |
| `owner` | `string` | Email address (regex validated) |
| `cost_center` | `string` | Cost center code (3–20 chars) |
| `application` | `string` | Application name (2–50 chars) |

### Optional

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `criticality` | `string` | `"Medium"` | Business criticality |
| `data_classification` | `string` | `"Internal"` | Data classification |
| `expiration_date` | `string` | `null` | YYYY-MM-DD (required for Sandbox) |
| `project` | `string` | `null` | Project name |
| `department` | `string` | `null` | Department/business unit |
| `compliance` | `string` | `null` | Compliance frameworks (comma-separated) |
| `maintenance_window` | `string` | `null` | Preferred maintenance window |
| `created_by` | `string` | `null` | Creator identity or pipeline |
| `additional_tags` | `map(string)` | `{}` | Custom tags to merge in |
| `enforce_sandbox_expiration` | `bool` | `true` | Enforce expiration for Sandbox |

## Outputs

### Tag Maps

| Output | Description |
|--------|-------------|
| `all_tags` | Complete merged map (mandatory + conditional + automation + additional) |
| `mandatory_tags` | Only the 7 mandatory tags |
| `security_tags` | Security/compliance subset |
| `cost_tags` | Cost allocation subset |
| `operational_tags` | Operational/monitoring subset |

### Derived Metadata

| Output | Description |
|--------|-------------|
| `environment_short` | 3-char code (prd, dev, sbx, etc.) |
| `is_production` | `true` for Production, PreProduction, DR |
| `is_sandbox` | `true` for Sandbox |
| `is_critical` | `true` for Critical or High |
| `is_sensitive` | `true` for Confidential or Restricted |
| `recommended_backup_tier` | `GRS` or `LRS` based on environment + criticality |
| `recommended_retention_tier` | `long`, `standard`, or `minimal` based on criticality |
| `expiration_date` | Effective date (auto-set to +90 days for Sandbox) |

## How to Use in the Orchestrator

F03 is called **internally** by other modules and also used in the orchestrator's `locals.tf` to produce tag sets for each subscription scope. You do not call F03 directly per resource — instead, the orchestrator creates tag locals that are passed to every module.

```hcl
# In locals.tf — tag sets produced for each subscription scope
locals {
  tags_management = {
    Environment        = var.environment
    Owner              = var.owner
    CostCenter         = var.cost_center
    Application        = var.management_project_name
    Criticality        = "High"
    DataClassification = "Internal"
    ManagedBy          = "Terraform"
    Project            = var.root_id
  }

  tags_security = merge(local.tags_management, {
    Application = "Security"
    Criticality = "Critical"
  })

  connectivity_tags = merge(local.tags_management, {
    Application = "Connectivity"
  })
}

# Every module receives its scope-appropriate tag set
module "m01_log_analytics" {
  # ...
  tags = local.tags_management
}

module "s02_sentinel" {
  # ...
  tags = local.tags_management
}
```

### Options Guide

| Option | When to change | Impact |
|--------|---------------|--------|
| `criticality = "Critical"` | Production workloads | Sets GRS backup recommendation |
| `data_classification = "Confidential"` | Sensitive workloads | Flags `is_sensitive = true` |
| `enforce_sandbox_expiration = true` | Sandbox environments | Fails plan without expiration date |
| `additional_tags = {...}` | Client/project-specific tags | Merged into all tag outputs |

## Implementation Notes

- **Tag layering:** 4 layers merged in order: mandatory → conditional → automation (CreatedDate) → additional_tags (user overrides)
- **Sandbox enforcement:** Fails at plan time if Sandbox environment lacks expiration date; auto-generates 90-day default if not provided
- **Backup tier logic:** Production + Critical/High → GRS; Production + any → GRS; Non-production → LRS
- **Retention tier logic:** Critical → long; High → standard; everything else → minimal

# F02 — Naming Convention (CAF Standard)

## Overview

Pure utility module (creates no Azure infrastructure) that generates resource names following the CAF naming convention. Pattern: `{slug}-{workload}-{env}-{region}-{instance}-{suffix}`. Handles case transformation, character restrictions, length truncation, and optional random suffix for globally unique names.

**Module path:** `modules/Fondations/F02-naming-convention/`

> **Note:** This module is the original CAF naming module. The project primarily uses **F02-naming-TAP** (TAS standard) for the Full Orchestrator. This module remains available for backwards compatibility.

## Resources Created

| Resource | Mode | Description |
|----------|------|-------------|
| `random_string.suffix` | count 0–1 | Random string for globally unique names (only if `random_suffix_length > 0`) |

## Inputs

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_type` | `string` | (required) | Azure resource type abbreviation (e.g. `"rg"`, `"vnet"`, `"st"`) |
| `workload` | `string` | (required) | Workload/app name (2–30 chars) |
| `environment` | `string` | (required) | Environment: `prod`, `dev`, `test`, `uat`, `stg`, `sandbox` |
| `region` | `string` | `"aue"` | Azure region abbreviation |
| `instance` | `string` | `null` | Instance number (e.g. `"001"`) |
| `suffix` | `string` | `null` | Custom suffix |
| `use_slug` | `bool` | `true` | Include resource type slug in name |
| `separator` | `string` | `"-"` | Separator character |
| `random_suffix_length` | `number` | `0` | Random suffix length (0–8) |
| `custom_name` | `string` | `null` | Bypass all conventions |

## Outputs

| Output | Description |
|--------|-------------|
| `name` | Primary generated resource name |
| `name_unique` | Name with uniqueness suffix |
| `slug` | Resource type slug/prefix |
| `max_length` | Max allowed length for this resource type |
| `is_valid` | Whether name meets all constraints |
| `validation_message` | Validation result message |
| `resource_definitions` | Full map of 160+ supported resource types |
| `region_abbreviations` | Map of 40+ Azure regions to abbreviations |
| `environment_abbreviations` | Map of 7 environments to abbreviations |

## How to Use in the Orchestrator

> **Note:** The Full Orchestrator uses **F02-naming-TAP** (TAS standard) exclusively. This module is available for custom deployments or other orchestrators that prefer CAF naming.

F02-naming-convention is called **internally** by other modules (M01, M02, M03, M08, etc.) — you do not call it directly from the orchestrator. Each module that uses F02 passes `workload`, `environment`, `region`, and `instance` and receives the generated name.

If you need to generate a name outside a module:

```hcl
module "naming_custom" {
  source = "git::https://github.com/samirbelkessa/Landing-Zone//Terraform-Azure-LZ/modules/Fondations/F02-naming-convention?ref=main"

  resource_type = "rg"         # Resource type abbreviation
  workload      = "myapp"      # Application/workload name
  environment   = "prod"       # prod, dev, test, uat, stg, sandbox
  region        = "aue"        # Azure region abbreviation
  instance      = "001"        # Instance number
}
# Output: rg-myapp-prd-aue-001
```

### Options Guide

| Option | When to change | Impact |
|--------|---------------|--------|
| `use_slug = false` | Remove resource type prefix | Name becomes `myapp-prd-aue-001` |
| `random_suffix_length = 4` | Need globally unique names (storage) | Appends random chars |
| `custom_name` | Bypass all conventions | Uses exact string provided |
| `separator = ""` | Alphanumeric-only resources (auto-detected) | No hyphens in name |

## Implementation Notes

- **160+ resource type definitions** with slug, max_length, lowercase/alphanum requirements, and scope
- **Automatic separator override:** Alphanumeric-only resources (e.g. storage accounts) force separator to `""`
- **Dual uniqueness modes:** Random suffix (configurable) or MD5-based deterministic 4-char suffix
- **Self-validation:** `is_valid` and `validation_message` outputs for downstream checks
- **7 environment abbreviations:** prod=prd, nonprod=npd, dev=dev, test=tst, uat=uat, stg=stg, sandbox=sbx

# F02 — Naming TAP (TAS Standard)

## Overview

Alternative naming convention module following the **TAS (Technology Advisory Services) standard**. Unlike the CAF-based F02, this module uses a concatenated format without separators and generates names for **every resource type simultaneously** in a single call.

**Module path:** `modules/Fondations/F02-naming-TAP/`

**Naming pattern:** `{customer}{env}{region}{tier}{slug}{landing_zone}{context1}{context2}`

Example: `isvpaea0vnethub001` → customer=isv, env=p(rod), region=aea, tier=0, slug=vnet, context1=hub, context2=001

> **This is the primary naming module used by the Full Orchestrator.** It is instantiated 20+ times for different resource naming contexts.

## Resources Created

| Resource | Mode | Description |
|----------|------|-------------|
| `random_string.unique` | 1 (always) | Alphanumeric random string for unique names |
| `random_string.unique_alpha` | 1 (always) | Alpha-only random string (no digits) |
| `null_resource.validate_region` | count 0–1 | Region validation check |

## Inputs

### Required

| Variable | Type | Description |
|----------|------|-------------|
| `customer` | `string` | Customer short code (e.g. `"isv"`) |
| `environment` | `string` | Environment short code: `p`, `n`, `i`, `l` |
| `region` | `string` | Region short code (e.g. `"aea"` for Australia East) |

### Optional

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `tier` | `number` | `1` | Resource tier 0–3 (Platform, Critical, Shared, Application) |
| `context1` | `string` | `""` | Primary context (e.g. `"hub"`, `"mgmt"`) |
| `context2` | `string` | `"001"` | Secondary context / instance number |
| `landing_zone` | `string` | `""` | CAF landing zone: `c`, `o`, `sec`, `idt`, `mgt`, `cnt` |
| `unique_length` | `number` | `4` | Random suffix length (2–8) |
| `unique_seed` | `string` | `""` | Custom seed for reproducibility |
| `use_separator_for_rg` | `bool` | `false` | Use hyphens in resource group names |

### Maps (Extensible)

| Variable | Default Entries | Description |
|----------|-----------------|-------------|
| `customer_map` | 5 entries | Customer code lookup |
| `environment_map` | 4 entries (p/n/i/l) | Environment codes with descriptions |
| `region_map` | 8 entries | Region codes with Azure names and paired regions |
| `tier_map` | 4 entries (0–3) | Tier descriptions |
| `landing_zone_map` | 6 entries | Landing zone codes |
| `resource_map` | 65+ entries | Resource type slugs, max lengths, regex patterns |
| `reserved_names` | 6 entries | Azure reserved subnet names |

## Outputs

One call produces outputs for **every resource type** (65+). Each output is an object: `{ name, name_unique, slug, max_length, scope, regex }`.

### Key Output Categories

| Category | Outputs |
|----------|---------|
| **Foundation** | `resource_group`, `management_group`, `subscription`, `policy`, `identity` |
| **Networking** | `virtual_network`, `subnet`, `network_security_group`, `route_table`, `public_ip`, `nat_gateway`, `private_endpoint`, `private_dns_zone` |
| **Firewall** | `firewall`, `firewall_policy`, `firewall_public_ip`, `waf_policy` |
| **Gateways** | `vpn_gateway`, `express_route_gateway`, `application_gateway`, `bastion` |
| **Storage** | `storage_account`, `storage_container`, `file_share` |
| **Key Vault** | `key_vault`, `key_vault_key`, `key_vault_secret` |
| **Monitoring** | `log_analytics_workspace`, `automation_account`, `monitor_action_group`, `data_collection_rule` |
| **Compute** | `virtual_machine` (15-char Windows limit), `virtual_machine_linux`, `kubernetes_cluster` |
| **Metadata** | `base_prefix`, `unique_seed`, `unique_suffix`, `reserved_subnet_names`, `all_resources` |

## How to Use in the Orchestrator

F02-naming-TAP is instantiated **20+ times** with different contexts. Each instance produces names for all resource types. Key pattern:

```hcl
# ── Connectivity hub (primary region) ──
module "naming_connectivity_aue" {
  source       = "git::https://github.com/samirbelkessa/Landing-Zone//...F02-naming-TAP?ref=main"
  customer     = var.root_id           # "isv"
  environment  = local.tas_environment_code  # "p" for production
  region       = "aea"                 # Australia East
  tier         = 1                     # Critical
  landing_zone = "cnt"                 # Connectivity
  context1     = "hub"
  context2     = "01"
}
# → module.naming_connectivity_aue.virtual_network.name = "isvpaea1cntvnethub01"

# ── Security sentinel ──
module "naming_security" {
  source       = "...F02-naming-TAP?ref=main"
  customer     = var.root_id
  environment  = local.tas_environment_code
  region       = "aea"
  tier         = 1
  landing_zone = "sec"
  context1     = "sec"
  context2     = "01"
}

# ── Management monitoring ──
module "naming_management" {
  source       = "...F02-naming-TAP?ref=main"
  customer     = var.root_id
  environment  = local.tas_environment_code
  region       = "aea"
  tier         = 1
  landing_zone = "mgt"
  context1     = "sentinel"
  context2     = "01"
}

# ── Firewall policy (no landing_zone) ──
module "naming_fwpol_aue" {
  source      = "...F02-naming-TAP?ref=main"
  customer    = var.root_id
  environment = local.tas_environment_code
  region      = "aea"
  tier        = 1
  context1    = "icy"      # policy context
  context2    = "01"
}
```

### Naming Instances in the Orchestrator

| Instance | landing_zone | context1 | Purpose |
|----------|-------------|----------|---------|
| `naming_connectivity_aue` | `cnt` | `hub` | Hub resources AUE |
| `naming_connectivity_ase` | `cnt` | `hub` | Hub resources AUSE |
| `naming_management` | `mgt` | `sentinel` | Management/Sentinel resources |
| `naming_security` | `sec` | `sec` | Security resources |
| `naming_identity` | `idt` | `id` | Identity resources |
| `naming_rg_cnt_network_aue` | `cnt` | `network` | Connectivity network RG |
| `naming_rg_cnt_dns_aue` | `cnt` | `dns` | Connectivity DNS RG |
| `naming_rg_sec_sentinel` | `sec` | `sen` | Security Sentinel RG |
| `naming_fw_aue` | (none) | (none) | Firewall name |
| `naming_fwpol_aue` | (none) | `icy` | Firewall policy name |
| `naming_fwpol_global` | (none) | `icy` | Global firewall policy |
| `naming_bastion_nsg_aue` | `cnt` | `bstn` | Bastion NSG |
| `naming_law_sentinel` | (none) | `sentinel` | LAW Sentinel name |
| `naming_law_monitor` | (none) | `monitor` | LAW Monitor name |
| `naming_dcr_security` | (none) | `azure` | Security DCR name |

### Options Guide

| Parameter | Values | Impact |
|-----------|--------|--------|
| `tier` | 0=Platform, 1=Critical, 2=Shared, 3=Application | First digit after region in name |
| `landing_zone` | `c`/`o`/`sec`/`idt`/`mgt`/`cnt`/`""` | Landing zone segment (can be empty) |
| `context1` | Free-form string | Primary context (e.g. `"hub"`, `"sentinel"`, `"dns"`) |
| `context2` | Instance number | Usually `"01"` |
| `region` | `aea`/`asa`/`gbl` | Region code for the resource name |

## Implementation Notes

- **One call = all names:** Unlike F02-naming-convention (one call per resource type), this iterates over the entire `resource_map` in a single `for` expression
- **No separators:** TAS standard concatenates all components without separators except RG names (optional hyphens)
- **Keepers-based random:** Random strings use `keepers` tied to `unique_seed` for reproducibility
- **Special handling:** Storage accounts strip dashes, VM names truncate to 15 chars (Windows hostname limit), container registries remove dashes
- **Reserved names:** Exposes Azure reserved subnet names (AzureBastionSubnet, GatewaySubnet, AzureFirewallSubnet, etc.)

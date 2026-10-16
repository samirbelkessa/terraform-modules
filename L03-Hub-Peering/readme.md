# L03 — Hub Peering

## Overview

Minimal utility module that creates a **bidirectional VNet peering** between two virtual networks (typically hub-to-hub or any two VNets). Used when the full L02-Spoke module is not needed (e.g. for hub-to-hub peering between primary and secondary regions).

**Module path:** `modules/LandingZone/L03-Hub-Peering/`

## Resources Created

| Resource | Mode | Description |
|----------|------|-------------|
| `azurerm_virtual_network_peering.forward` | 1 | Forward direction peering |
| `azurerm_virtual_network_peering.reverse` | 1 | Reverse direction peering |

## Inputs

All variables are **required** except `allow_gateway_transit`:

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `peering_name_forward` | `string` | (required) | Name for forward peering |
| `peering_name_reverse` | `string` | (required) | Name for reverse peering |
| `rg_name_forward` | `string` | (required) | RG for forward VNet |
| `rg_name_reverse` | `string` | (required) | RG for reverse VNet |
| `vnet_name_forward` | `string` | (required) | Forward VNet name |
| `vnet_name_reverse` | `string` | (required) | Reverse VNet name |
| `remote_vnet_id_forward` | `string` | (required) | Remote VNet ID for forward |
| `remote_vnet_id_reverse` | `string` | (required) | Remote VNet ID for reverse |
| `allow_gateway_transit` | `bool` | `false` | Gateway transit on both sides |

## Outputs

| Output | Description |
|--------|-------------|
| `peering_forward_id` | Forward peering resource ID |
| `peering_reverse_id` | Reverse peering resource ID |

## How to Use in the Orchestrator

Used for **hub-to-hub peering** between primary (AUE) and secondary (AUSE) regions. Only deployed when both connectivity and secondary region are enabled.

```hcl
module "hub_to_hub_peering" {
  source = "git::https://github.com/samirbelkessa/Landing-Zone.git//Terraform-Azure-LZ/modules/LandingZone/L03-Hub-Peering?ref=main"

  # ── Forward: AUE → AUSE ──
  peering_name_forward   = "${local.hub_aue_vnet_name}-to-${local.hub_ause_vnet_name}"
  vnet_name_forward      = local.hub_aue_vnet_name
  rg_name_forward        = local.hub_aue_rg_name
  remote_vnet_id_forward = try(module.alz_connectivity.virtual_network_resource_ids[var.secondary_location])

  # ── Reverse: AUSE → AUE ──
  peering_name_reverse   = "${local.hub_ause_vnet_name}-to-${local.hub_aue_vnet_name}"
  vnet_name_reverse      = local.hub_ause_vnet_name
  rg_name_reverse        = local.hub_ause_rg_name
  remote_vnet_id_reverse = try(module.alz_connectivity.virtual_network_resource_ids[var.default_location])

  # ── Options ──
  allow_gateway_transit = false

  # ── Conditional ──
  count = var.deploy_connectivity && var.enable_secondary_region ? 1 : 0

  depends_on = [module.alz_connectivity]
  providers  = { azurerm = azurerm.connectivity }
}
```

### Options Guide

| Option | When to change | Impact |
|--------|---------------|--------|
| `allow_gateway_transit = true` | Share VPN gateway between hubs | Gateway transit in both directions |
| `allow_gateway_transit = false` | Independent gateways per hub | No gateway sharing (default) |
| `enable_secondary_region = false` | Single-region deployment | Skips hub-to-hub peering entirely |

## Dependencies

- **Upstream:** AVM Connectivity module (provides VNet IDs)
- **Downstream:** None

## Implementation Notes

- **Symmetric configuration:** Both peerings set `allow_virtual_network_access = true` and `allow_forwarded_traffic = true`
- **`use_remote_gateways = false`** on both sides — gateway transit not handled (unlike L02-Spoke)
- **No provider aliasing** — both peerings must be in the same provider context
- **Minimal validation** compared to other modules

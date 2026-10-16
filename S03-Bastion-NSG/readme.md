# S03 — Bastion NSG

## Overview

Creates the mandatory Network Security Group for the AzureBastionSubnet with all 10 required rules per Microsoft's official documentation (5 inbound + 5 outbound).

**Module path:** `modules/Security/S03-Bastion-NSG/`

## Security Rules

### Inbound (5)

| Priority | Name | Source | Dest Port | Protocol | Description |
|----------|------|--------|-----------|----------|-------------|
| 1000 | `AzureBastionInBound` | Internet | 443 | TCP | HTTPS from Internet |
| 1001 | `AzureBastionControlInBound` | GatewayManager | 443 | TCP | Gateway Manager control plane |
| 1002 | `AzureBastionHostCommunicationInbound` | VirtualNetwork | 5701, 8080 | * | Bastion data plane |
| 1003 | `AzureLoadBalancerInbound` | AzureLoadBalancer | 443 | TCP | ALB health probes |
| 4096 | `Default_Deny_InBound_Override` | * | * | * | **Deny-all override** |

### Outbound (5)

| Priority | Name | Dest | Dest Port | Protocol | Description |
|----------|------|------|-----------|----------|-------------|
| 1000 | `AzureBastionOutBound` | VirtualNetwork | 22, 3389 | * | SSH/RDP to target VMs |
| 1001 | `AzureBastionAzureCloudOutBound` | AzureCloud | 443 | TCP | Azure management |
| 1002 | `AzureBastionHostCommunicationOutBound` | VirtualNetwork | 5701, 8080 | * | Data plane |
| 1003 | `AzureBastionGetSessionInformationOutBound` | Internet | 80 | * | Session/cert validation |
| 4096 | `Default_Deny_OutBound_Override` | * | * | * | **Deny-all override** |

## Resources Created

| Resource | Mode | Description |
|----------|------|-------------|
| `azurerm_network_security_group.this` | 1 | NSG with 10 inline security rules |
| `azurerm_subnet_network_security_group_association.this` | count 0–1 | NSG-to-subnet association |

## Inputs

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `nsg_name` | `string` | (required) | NSG name |
| `location` | `string` | (required) | Azure region |
| `resource_group_name` | `string` | (required) | Resource group |
| `bastion_subnet_id` | `string` | `""` | AzureBastionSubnet ID |
| `create_association` | `bool` | `true` | NSG-to-subnet binding |
| `tags` | `map(string)` | `{}` | Tags |

## Outputs

| Output | Description |
|--------|-------------|
| `nsg_id` | NSG resource ID |
| `nsg_name` | NSG name |

## How to Use in the Orchestrator

Deployed in the connectivity subscription. The NSG name is generated via F02-naming-TAP. `create_association = false` because the AVM Connectivity module handles subnet association.

```hcl
# ── NSG Name via F02-naming-TAP ──
module "naming_bastion_nsg_aue" {
  source = "git::https://github.com/samirbelkessa/Landing-Zone//Terraform-Azure-LZ/modules/Fondations/F02-naming-TAP?ref=main"

  tier         = 1
  region       = "aea"
  landing_zone = "cnt"
  environment  = local.tas_environment_code
  customer     = var.root_id
  context1     = "bstn"
  context2     = "01"
}

# ── Bastion NSG ──
module "bastion_nsg_aue" {
  source = "git::https://github.com/samirbelkessa/Landing-Zone.git//Terraform-Azure-LZ/modules/Security/S03-Bastion-NSG?ref=main"

  nsg_name            = module.naming_bastion_nsg_aue.network_security_group.name
  location            = local.primary_location
  resource_group_name = try(module.l01-subscription-vending-v2.resource_groups_by_subscription["connectivity"]["network-aue"].name)

  # ── Association ──
  create_association = false    # AVM Connectivity module handles subnet-NSG binding
  # bastion_subnet_id = "..."   # Only needed when create_association = true

  count = var.deploy_connectivity ? 1 : 0
  tags  = local.connectivity_tags

  providers = { azurerm = azurerm.connectivity }
}
```

### Options Guide

| Option | When to change | Impact |
|--------|---------------|--------|
| `create_association = true` | Manage NSG-to-subnet binding here | Auto-associates NSG with AzureBastionSubnet |
| `create_association = false` | AVM module handles association | NSG created without binding (default in orchestrator) |
| `bastion_subnet_id = "..."` | Need explicit association | Required when `create_association = true` |

## Dependencies

- **Upstream:** AVM Connectivity module (provides AzureBastionSubnet)
- **Downstream:** None

## Implementation Notes

- **All 10 rules inline** within the NSG resource (not separate `azurerm_network_security_rule`) — static Microsoft-mandated rules
- **`create_association` flag** allows NSG creation without association when the AVM module handles it
- **Priority 4096 deny-all** overrides Azure's default `AllowVnetInBound`/`AllowVnetOutBound` for security hardening

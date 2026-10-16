# C13 — Application Gateway

## Overview

Deploys an Azure Application Gateway with WAF v2 capabilities, including Public IP, WAF policy (OWASP-based), diagnostic settings, SSL/TLS termination, backend pools, health probes, listeners, routing rules, private link configurations, and managed identity integration for Key Vault certificate access.

**Module path:** `modules/Connectivity/C13-application-gateway/`

## Resources Created

| Resource | Mode | Description |
|----------|------|-------------|
| `azurerm_public_ip.this` | count 0–1 | Public IP for frontend (conditional via `create_public_ip`) |
| `azurerm_web_application_firewall_policy.this` | count 0–1 | WAF v2 policy with OWASP rules (only if WAF SKU + `waf_enabled` + no external policy) |
| `azurerm_application_gateway.this` | 1 | Main Application Gateway |
| `azurerm_monitor_diagnostic_setting.this` | count 0–1 | AppGW diagnostics |
| `azurerm_monitor_diagnostic_setting.public_ip` | count 0–1 | Public IP diagnostics (DDoS, flow logs) |

## Inputs

### Required

| Variable | Type | Description |
|----------|------|-------------|
| `name` | `string` | Must start with `agw-`, 8–80 chars |
| `resource_group_name` | `string` | Target resource group |
| `subnet_id` | `string` | Subnet resource ID (ARM ID validated) |

### SKU & Scaling

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `sku_name` / `sku_tier` | `string` | `"WAF_v2"` | Standard_v2 or WAF_v2 |
| `autoscale_enabled` | `bool` | `true` | Autoscaling |
| `min_capacity` / `max_capacity` | `number` | 2 / 10 | Autoscale bounds |

### WAF Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `waf_enabled` | `bool` | `true` | WAF toggle |
| `waf_mode` | `string` | `"Prevention"` | Detection or Prevention |
| `waf_rule_set_version` | `string` | `"3.2"` | OWASP version |
| `ssl_policy_name` | `string` | `"AppGwSslPolicy20220101S"` | TLS 1.2 minimum |

### Routing

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `backend_address_pools` | `list(object)` | Default pool | Backend pool definitions (FQDNs/IPs) |
| `http_listeners` | `list(object)` | Default HTTP listener | Listener definitions |
| `request_routing_rules` | `list(object)` | Default basic rule | Routing rules |
| `health_probes` | `list(object)` | `[]` | Custom health probes |
| `ssl_certificates` | `list(object)` | `[]` | SSL certs (Key Vault or inline, sensitive) |

### Identity & Diagnostics

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `identity_ids` | `list(string)` | `[]` | User-assigned identity IDs for Key Vault |
| `private_link_configurations` | `list(object)` | `[]` | Private link configurations |
| `log_analytics_workspace_id` | `string` | `null` | LAW for diagnostics |

## Outputs

| Output | Description |
|--------|-------------|
| `id` / `name` | AppGW identifiers |
| `public_ip_id` / `public_ip_address` / `public_ip_fqdn` | Public IP details |
| `waf_policy_id` | WAF policy (created or external) |
| `backend_address_pool_ids` / `http_listener_ids` / `request_routing_rule_ids` | Component ID maps |
| `identity_principal_id` | Managed identity principal ID |
| `is_waf_enabled` / `zones` / `sku_name` | Computed values |

## How to Use in the Orchestrator

C13 is **not directly invoked** in the current Full Orchestrator — the Application Gateway subnet is created inline, and C13 would be used when deploying the Application Gateway resource itself. To use it:

```hcl
# Step 1: Subnet (already in orchestrator)
resource "azurerm_subnet" "application_gateway" {
  virtual_network_name = module.alz_connectivity.virtual_network_resource_names[var.default_location]
  resource_group_name  = try(module.l01-subscription-vending-v2.resource_groups_by_subscription["connectivity"]["network-aue"].name)
  name                 = "ApplicationGatewaySubnet"
  address_prefixes     = [var.application_gateway_subnet_address_prefix]
  count                = var.enable_application_gateway ? 1 : 0
}

# Step 2: Application Gateway via C13
module "application_gateway" {
  source = "git::https://github.com/samirbelkessa/Landing-Zone//Terraform-Azure-LZ/modules/Connectivity/C13-application-gateway?ref=main"

  # ── Required ──
  name                = "agw-${var.root_id}-hub-${local.primary_region}-001"
  resource_group_name = try(module.l01-subscription-vending-v2.resource_groups_by_subscription["connectivity"]["network-aue"].name)
  subnet_id           = azurerm_subnet.application_gateway[0].id

  # ── SKU & Scaling ──
  sku_name         = "WAF_v2"
  sku_tier         = "WAF_v2"
  autoscale_enabled = true
  min_capacity     = var.application_gateway_autoscale.min_capacity
  max_capacity     = var.application_gateway_autoscale.max_capacity

  # ── WAF Configuration ──
  waf_enabled          = true
  waf_mode             = var.waf_mode
  waf_rule_set_version = var.waf_rule_set_version

  # ── Backend Pools (spoke resources — adapt per client) ──
  backend_address_pools = [
    { name = "<client>-dev-aks", fqdns = ["<client>-dev.internal"], ip_addresses = [] },
    { name = "<client>-prod-aks", fqdns = ["<client>-prod.internal"], ip_addresses = [] }
  ]

  # ── Diagnostics ──
  log_analytics_workspace_id = module.m01_log_analytics[0].id

  # ── Identity (for Key Vault SSL certs) ──
  identity_ids = [azurerm_user_assigned_identity.appgw[0].id]

  count = var.enable_application_gateway ? 1 : 0
  tags  = local.connectivity_tags

  providers = { azurerm = azurerm.connectivity }
}
```

### Options Guide

| Option | When to change | Impact |
|--------|---------------|--------|
| `sku_tier = "Standard_v2"` | No WAF needed | Removes WAF capability, lower cost |
| `waf_mode = "Detection"` | Testing WAF rules | Logs but doesn't block traffic |
| `autoscale_enabled = false` | Fixed capacity | Uses `capacity` instead of min/max |
| `identity_ids = [...]` | Key Vault SSL certificates | Managed identity for cert access |
| `ssl_certificates = [...]` | HTTPS listeners | TLS termination at AppGW |
| `private_link_configurations = [...]` | Private frontend | Access AppGW via private endpoint |

## Dependencies

- **Upstream:** AVM Connectivity module (provides subnet), F02-naming-TAP (AppGW subnet naming)
- **Downstream:** ClientLZ (backend pool targets in spokes)

## Implementation Notes

- **Heavy use of dynamic blocks** for all repeatable sub-resources (frontends, backends, listeners, probes, SSL certs, routing rules, private links)
- **WAF policy conditionally created:** Only when SKU is WAF_v2 + `waf_enabled = true` + no external `firewall_policy_id`
- **`create_before_destroy`** on Public IP and WAF policy for zero-downtime updates
- **`ignore_changes`** on `tags["CreatedDate"]` for externally managed metadata
- **Extensive input validation** with regex patterns on nearly every variable

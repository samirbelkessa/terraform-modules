locals {
  autoscale_config = var.autoscale_enabled ? {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  } : null

  backend_http_settings_map = { for setting in var.backend_http_settings : setting.name => setting }

  backend_pools_map = { for pool in var.backend_address_pools : pool.name => pool }

  diagnostic_settings_name = "diag-${var.name}"

  enabled_logs = var.enable_diagnostic_settings ? [
    for category in var.diagnostic_logs_categories : {
      category = category
      enabled  = true
    }
  ] : []

  enabled_metrics = var.enable_diagnostic_settings ? [
    for category in var.diagnostic_metrics_categories : {
      category = category
      enabled  = true
    }
  ] : []

  fixed_capacity = var.autoscale_enabled ? null : var.capacity

  frontend_ip_configuration_name = "public-frontend-ip"

  frontend_ports_map = { for port in var.frontend_port_settings : port.name => port }

  health_probes_map = { for probe in var.health_probes : probe.name => probe }

  http_listeners_map = { for listener in var.http_listeners : listener.name => listener }

  identity_config = length(var.identity_ids) > 0 || var.identity_type != "UserAssigned" ? {
    type         = var.identity_type
    identity_ids = var.identity_type == "SystemAssigned" ? [] : var.identity_ids
  } : null

  is_waf_sku = var.sku_name == "WAF_v2"

  public_ip_id = var.create_public_ip ? azurerm_public_ip.this[0].id : var.existing_public_ip_id

  public_ip_name = replace(var.name, "agw-", "pip-agw-")

  routing_rules_map = { for rule in var.request_routing_rules : rule.name => rule }

  sku_config = {
    name = var.sku_name
    tier = var.sku_tier
  }

  ssl_certificates_map = { for cert in var.ssl_certificates : cert.name => cert }

  ssl_policy = {
    policy_type = var.ssl_policy_type
    policy_name = var.ssl_policy_type == "Predefined" ? var.ssl_policy_name : null
  }

  tags = merge(
    var.tags,
    {
      Module = "C13-application-gateway"
    }
  )

  waf_config = local.is_waf_sku && var.waf_enabled ? {
    enabled                  = true
    firewall_mode            = var.waf_mode
    rule_set_type            = var.waf_rule_set_type
    rule_set_version         = var.waf_rule_set_version
    file_upload_limit_mb     = var.waf_file_upload_limit_mb
    max_request_body_size_kb = var.waf_max_request_body_size_kb
  } : null

  waf_policy_name = replace(var.name, "agw-", "waf-")

}

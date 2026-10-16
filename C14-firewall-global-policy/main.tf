resource "azurerm_firewall_policy" "this" {
  threat_intelligence_mode          = var.threat_intelligence_mode
  tags                              = var.tags
  sku                               = var.sku
  resource_group_name               = var.resource_group_name
  name                              = var.name
  location                          = var.location
  base_policy_id                    = var.base_policy_id
  auto_learn_private_ranges_enabled = var.auto_learn_private_ranges_enabled

  dns {
    proxy_enabled = var.dns_proxy_enabled
  }

  dynamic "intrusion_detection" {
    for_each = var.sku == "Premium" ? [1] : []
    content {
      mode = var.idps_mode
    }
  }
}


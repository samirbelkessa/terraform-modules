resource "azurerm_firewall_policy_rule_collection_group" "dnat" {
  priority           = 100
  name               = "DefaultDnatRuleCollectionGroup"
  firewall_policy_id = var.firewall_policy_id
  count              = var.deploy_dnat_rules ? 1 : 0

  nat_rule_collection {
    name     = "DefaultDnatRuleCollection"
    priority = 100
    action   = "Dnat"

    dynamic "rule" {
      for_each = var.dnat_rules
      content {
        name                = rule.value.name
        protocols           = rule.value.protocols
        source_addresses    = rule.value.source_addresses
        destination_address = rule.value.destination_address
        destination_ports   = rule.value.destination_ports
        translated_address  = rule.value.translated_address
        translated_port     = rule.value.translated_port
      }
    }
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "network" {
  priority           = 200
  name               = "DefaultNetworkRuleCollectionGroup"
  firewall_policy_id = var.firewall_policy_id

  network_rule_collection {
    name     = "DefaultNetworkRuleCollection"
    priority = 100
    action   = "Allow"

    dynamic "rule" {
      for_each = var.network_rules
      content {
        name                  = rule.value.name
        source_addresses      = var.source_addresses
        protocols             = rule.value.protocols
        destination_ports     = rule.value.destination_ports
        destination_addresses = rule.value.destination_addresses
      }
    }
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "application" {
  priority           = 300
  name               = "DefaultApplicationRuleCollectionGroup"
  firewall_policy_id = var.firewall_policy_id

  depends_on = [
    azurerm_firewall_policy_rule_collection_group.network,
  ]

  application_rule_collection {
    name     = "DefaultApplicationRule"
    priority = 100
    action   = "Allow"

    dynamic "rule" {
      for_each = var.application_rules
      content {
        name                  = rule.value.name
        source_addresses      = var.source_addresses
        destination_fqdns     = length(rule.value.destination_fqdns) > 0 ? rule.value.destination_fqdns : null
        destination_fqdn_tags = length(rule.value.destination_fqdn_tags) > 0 ? rule.value.destination_fqdn_tags : null

        dynamic "protocols" {
          for_each = rule.value.protocols
          content {
            type = protocols.value.type
            port = protocols.value.port
          }
        }
      }
    }
  }
}


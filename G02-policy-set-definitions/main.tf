# =============================================================================
# MOVED BLOCKS — Migration from azurerm_policy_set_definition (AzureRM v4)
#                to azurerm_management_group_policy_set_definition (AzureRM v5)
# =============================================================================

moved {
  from = azurerm_policy_set_definition.caf_initiatives["caf-backup-baseline"]
  to   = azurerm_management_group_policy_set_definition.caf_initiatives["caf-backup-baseline"]
}

moved {
  from = azurerm_policy_set_definition.caf_initiatives["caf-corp-nonprod"]
  to   = azurerm_management_group_policy_set_definition.caf_initiatives["caf-corp-nonprod"]
}

moved {
  from = azurerm_policy_set_definition.caf_initiatives["caf-corp-prod"]
  to   = azurerm_management_group_policy_set_definition.caf_initiatives["caf-corp-prod"]
}

moved {
  from = azurerm_policy_set_definition.caf_initiatives["caf-cost-baseline"]
  to   = azurerm_management_group_policy_set_definition.caf_initiatives["caf-cost-baseline"]
}

moved {
  from = azurerm_policy_set_definition.caf_initiatives["caf-decommissioned"]
  to   = azurerm_management_group_policy_set_definition.caf_initiatives["caf-decommissioned"]
}

moved {
  from = azurerm_policy_set_definition.caf_initiatives["caf-governance-baseline"]
  to   = azurerm_management_group_policy_set_definition.caf_initiatives["caf-governance-baseline"]
}

moved {
  from = azurerm_policy_set_definition.caf_initiatives["caf-identity-baseline"]
  to   = azurerm_management_group_policy_set_definition.caf_initiatives["caf-identity-baseline"]
}

moved {
  from = azurerm_policy_set_definition.caf_initiatives["caf-monitoring-baseline"]
  to   = azurerm_management_group_policy_set_definition.caf_initiatives["caf-monitoring-baseline"]
}

moved {
  from = azurerm_policy_set_definition.caf_initiatives["caf-network-baseline"]
  to   = azurerm_management_group_policy_set_definition.caf_initiatives["caf-network-baseline"]
}

moved {
  from = azurerm_policy_set_definition.caf_initiatives["caf-online-nonprod"]
  to   = azurerm_management_group_policy_set_definition.caf_initiatives["caf-online-nonprod"]
}

moved {
  from = azurerm_policy_set_definition.caf_initiatives["caf-online-prod"]
  to   = azurerm_management_group_policy_set_definition.caf_initiatives["caf-online-prod"]
}

moved {
  from = azurerm_policy_set_definition.caf_initiatives["caf-sandbox"]
  to   = azurerm_management_group_policy_set_definition.caf_initiatives["caf-sandbox"]
}

moved {
  from = azurerm_policy_set_definition.caf_initiatives["caf-security-baseline"]
  to   = azurerm_management_group_policy_set_definition.caf_initiatives["caf-security-baseline"]
}

moved {
  from = azurerm_policy_set_definition.custom_initiatives
  to   = azurerm_management_group_policy_set_definition.custom_initiatives
}

# =============================================================================
# CAF INITIATIVES
# =============================================================================

resource "azurerm_management_group_policy_set_definition" "caf_initiatives" {
  policy_type = "Custom"
  name        = each.key
  metadata = jsonencode({
    version  = "1.0.0"
    category = each.value.category
    source   = "CAF Landing Zone - Terraform"
    project  = "Australia Landing Zone"
  })
  management_group_id = var.management_group_id
  for_each            = local.all_caf_initiatives
  display_name        = each.value.display_name
  description         = each.value.description

  lifecycle {
    create_before_destroy = true
  }

  dynamic "policy_definition_reference" {
    for_each = each.value.policies

    content {
      policy_definition_id = policy_definition_reference.value.policy_definition_id
      reference_id         = policy_definition_reference.value.reference_id
      parameter_values     = policy_definition_reference.value.parameter_values
    }
  }
}

resource "azurerm_management_group_policy_set_definition" "custom_initiatives" {
  policy_type         = "Custom"
  parameters          = each.value.parameters
  name                = each.key
  metadata            = each.value.metadata
  management_group_id = var.management_group_id
  for_each            = var.custom_policy_set_definitions
  display_name        = each.value.display_name
  description         = each.value.description

  lifecycle {
    create_before_destroy = true
  }

  dynamic "policy_definition_reference" {
    for_each = each.value.policy_definition_references

    content {
      policy_definition_id = policy_definition_reference.value.policy_definition_id
      parameter_values     = policy_definition_reference.value.parameter_values
      reference_id         = policy_definition_reference.value.reference_id
    }
  }
}


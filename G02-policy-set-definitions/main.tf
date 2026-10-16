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


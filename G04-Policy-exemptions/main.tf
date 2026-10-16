resource "terraform_data" "waiver_expiration_validation" {
  count = var.require_expiration_for_waivers && length(local.waivers_without_expiration) > 0 ? 1 : 0

  lifecycle {
    precondition {
      error_message = "The following Waiver exemptions do not have an expiration date: ${join(", ", local.waivers_without_expiration)}. Set expires_on or disable require_expiration_for_waivers."
      condition     = length(local.waivers_without_expiration) == 0
    }
  }

}

resource "azurerm_management_group_policy_exemption" "exemptions" {
  policy_definition_reference_ids = length(each.value.policy_definition_reference_ids) > 0 ? each.value.policy_definition_reference_ids : null
  policy_assignment_id            = each.value.policy_assignment_id
  name                            = substr(each.key, 0, 64)
  metadata                        = each.value.metadata != null ? each.value.metadata : local.standard_metadata
  management_group_id             = each.value.management_group_id
  for_each                        = local.all_mg_exemptions
  expires_on                      = each.value.expires_on
  exemption_category              = each.value.exemption_category
  display_name                    = each.value.display_name
  description                     = each.value.description != "" ? each.value.description : null

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_subscription_policy_exemption" "exemptions" {
  subscription_id                 = each.value.subscription_id
  policy_definition_reference_ids = length(each.value.policy_definition_reference_ids) > 0 ? each.value.policy_definition_reference_ids : null
  policy_assignment_id            = each.value.policy_assignment_id
  name                            = substr(each.key, 0, 64)
  metadata                        = each.value.metadata != null ? each.value.metadata : local.standard_metadata
  for_each                        = local.all_subscription_exemptions
  expires_on                      = each.value.expires_on
  exemption_category              = each.value.exemption_category
  display_name                    = each.value.display_name
  description                     = each.value.description != "" ? each.value.description : null

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_resource_group_policy_exemption" "exemptions" {
  resource_group_id               = each.value.resource_group_id
  policy_definition_reference_ids = length(each.value.policy_definition_reference_ids) > 0 ? each.value.policy_definition_reference_ids : null
  policy_assignment_id            = each.value.policy_assignment_id
  name                            = substr(each.key, 0, 64)
  metadata                        = each.value.metadata != null ? each.value.metadata : local.standard_metadata
  for_each                        = local.all_rg_exemptions
  expires_on                      = each.value.expires_on
  exemption_category              = each.value.exemption_category
  display_name                    = each.value.display_name
  description                     = each.value.description != "" ? each.value.description : null

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_resource_policy_exemption" "exemptions" {
  resource_id                     = each.value.resource_id
  policy_definition_reference_ids = length(each.value.policy_definition_reference_ids) > 0 ? each.value.policy_definition_reference_ids : null
  policy_assignment_id            = each.value.policy_assignment_id
  name                            = substr(each.key, 0, 64)
  metadata                        = each.value.metadata != null ? each.value.metadata : local.standard_metadata
  for_each                        = var.resource_exemptions
  expires_on                      = each.value.expires_on
  exemption_category              = each.value.exemption_category
  display_name                    = each.value.display_name
  description                     = each.value.description != "" ? each.value.description : null

  lifecycle {
    create_before_destroy = true
  }
}


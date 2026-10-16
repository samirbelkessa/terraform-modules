resource "azurerm_management_group_policy_assignment" "defender" {
  policy_definition_id = each.value.policy_definition_id
  name                 = "enable-def-${each.key}"
  management_group_id  = var.defender_management_group_id
  location             = var.default_location
  for_each             = local.defender_active_plans
  enforce              = true
  display_name         = each.value.display_name
  description          = each.value.description

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "defender_security_admin" {
  skip_service_principal_aad_check = true
  scope                            = var.defender_management_group_id
  role_definition_name             = "Security Admin"
  principal_id                     = azurerm_management_group_policy_assignment.defender[each.key].identity[0].principal_id
  for_each                         = local.defender_active_plans
}

resource "azurerm_role_assignment" "defender_contributor" {
  skip_service_principal_aad_check = true
  scope                            = var.defender_management_group_id
  role_definition_name             = "Contributor"
  principal_id                     = azurerm_management_group_policy_assignment.defender[each.key].identity[0].principal_id
  for_each                         = local.defender_active_plans
}

resource "azurerm_management_group_policy_remediation" "defender" {
  policy_assignment_id = azurerm_management_group_policy_assignment.defender[each.key].id
  name                 = "remediate-def-${each.key}"
  management_group_id  = var.defender_management_group_id
  for_each             = var.deploy_defender_remediation ? local.defender_active_plans : {}

  depends_on = [
    azurerm_role_assignment.defender_security_admin,
    azurerm_role_assignment.defender_contributor,
  ]
}


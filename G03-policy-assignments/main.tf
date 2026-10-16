resource "azurerm_management_group_policy_assignment" "assignments" {
  policy_definition_id = each.value.policy_set_definition_id != null ? each.value.policy_set_definition_id : each.value.policy_definition_id
  parameters           = each.value.parameters
  not_scopes           = each.value.not_scopes
  name                 = substr(each.key, 0, 24)
  metadata             = each.value.metadata != null ? each.value.metadata : local.standard_metadata
  management_group_id  = each.value.management_group_id
  location             = each.value.identity_type != "None" ? coalesce(each.value.location, var.default_location) : null
  for_each             = local.all_mg_assignments
  enforce              = each.value.enforce
  display_name         = each.value.display_name
  description          = each.value.description != "" ? each.value.description : null

  lifecycle {
    create_before_destroy = true
  }

  dynamic "identity" {
    for_each = each.value.identity_type != "None" ? [1] : []
    content {
      type         = each.value.identity_type
      identity_ids = each.value.identity_type == "UserAssigned" ? each.value.identity_ids : null
    }
  }

  dynamic "non_compliance_message" {
    for_each = each.value.non_compliance_message != null ? [1] : []
    content {
      content = each.value.non_compliance_message
    }
  }
}

resource "azurerm_subscription_policy_assignment" "assignments" {
  subscription_id      = each.value.subscription_id
  policy_definition_id = each.value.policy_set_definition_id != null ? each.value.policy_set_definition_id : each.value.policy_definition_id
  parameters           = each.value.parameters
  not_scopes           = each.value.not_scopes
  name                 = substr(each.key, 0, 24)
  metadata             = each.value.metadata != null ? each.value.metadata : local.standard_metadata
  location             = each.value.identity_type != "None" ? coalesce(each.value.location, var.default_location) : null
  for_each             = var.subscription_assignments
  enforce              = each.value.enforce
  display_name         = each.value.display_name
  description          = each.value.description != "" ? each.value.description : null

  lifecycle {
    create_before_destroy = true
  }

  dynamic "identity" {
    for_each = each.value.identity_type != "None" ? [1] : []
    content {
      type         = each.value.identity_type
      identity_ids = each.value.identity_type == "UserAssigned" ? each.value.identity_ids : null
    }
  }

  dynamic "non_compliance_message" {
    for_each = each.value.non_compliance_message != null ? [1] : []
    content {
      content = each.value.non_compliance_message
    }
  }
}

resource "azurerm_resource_group_policy_assignment" "assignments" {
  resource_group_id    = each.value.resource_group_id
  policy_definition_id = each.value.policy_set_definition_id != null ? each.value.policy_set_definition_id : each.value.policy_definition_id
  parameters           = each.value.parameters
  not_scopes           = each.value.not_scopes
  name                 = substr(each.key, 0, 24)
  metadata             = each.value.metadata != null ? each.value.metadata : local.standard_metadata
  location             = each.value.identity_type != "None" ? coalesce(each.value.location, var.default_location) : null
  for_each             = var.resource_group_assignments
  enforce              = each.value.enforce
  display_name         = each.value.display_name
  description          = each.value.description != "" ? each.value.description : null

  lifecycle {
    create_before_destroy = true
  }

  dynamic "identity" {
    for_each = each.value.identity_type != "None" ? [1] : []
    content {
      type         = each.value.identity_type
      identity_ids = each.value.identity_type == "UserAssigned" ? each.value.identity_ids : null
    }
  }

  dynamic "non_compliance_message" {
    for_each = each.value.non_compliance_message != null ? [1] : []
    content {
      content = each.value.non_compliance_message
    }
  }
}

resource "azurerm_role_assignment" "mg_policy_identity" {
  skip_service_principal_aad_check = true
  scope                            = each.value.management_group_id
  role_definition_id               = lookup(var.role_definition_ids, each.key, [var.default_role_definition_id])[0]
  principal_id                     = azurerm_management_group_policy_assignment.assignments[each.key].identity[0].principal_id
  for_each = var.create_role_assignments ? {
    for k, v in local.mg_assignments_with_identity : k => v
    if v.identity_type == "SystemAssigned"
  } : {}

  depends_on = [
    azurerm_management_group_policy_assignment.assignments,
  ]
}

resource "azurerm_role_assignment" "sub_policy_identity" {
  skip_service_principal_aad_check = true
  scope                            = each.value.subscription_id
  role_definition_id               = lookup(var.role_definition_ids, each.key, [var.default_role_definition_id])[0]
  principal_id                     = azurerm_subscription_policy_assignment.assignments[each.key].identity[0].principal_id
  for_each = var.create_role_assignments ? {
    for k, v in local.sub_assignments_with_identity : k => v
    if v.identity_type == "SystemAssigned"
  } : {}

  depends_on = [
    azurerm_subscription_policy_assignment.assignments,
  ]
}

resource "azurerm_role_assignment" "rg_policy_identity" {
  skip_service_principal_aad_check = true
  scope                            = each.value.resource_group_id
  role_definition_id               = lookup(var.role_definition_ids, each.key, [var.default_role_definition_id])[0]
  principal_id                     = azurerm_resource_group_policy_assignment.assignments[each.key].identity[0].principal_id
  for_each = var.create_role_assignments ? {
    for k, v in local.rg_assignments_with_identity : k => v
    if v.identity_type == "SystemAssigned"
  } : {}

  depends_on = [
    azurerm_resource_group_policy_assignment.assignments,
  ]
}


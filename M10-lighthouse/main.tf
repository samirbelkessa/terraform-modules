resource "azurerm_lighthouse_definition" "this" {
  scope              = "/subscriptions/${each.value}"
  name               = var.msp_offer_name
  managing_tenant_id = var.managing_tenant_id
  for_each           = var.enable_lighthouse ? var.subscription_ids : {}
  description        = var.msp_offer_description

  dynamic "authorization" {
    for_each = var.authorizations
    content {
      principal_id           = authorization.value.principal_id
      role_definition_id     = authorization.value.role_definition_id
      principal_display_name = authorization.value.principal_display_name
    }
  }

  dynamic "eligible_authorization" {
    for_each = var.eligible_authorizations
    content {
      principal_id           = eligible_authorization.value.principal_id
      role_definition_id     = eligible_authorization.value.role_definition_id
      principal_display_name = eligible_authorization.value.principal_display_name

      just_in_time_access_policy {
        multi_factor_auth_provider  = eligible_authorization.value.multi_factor_auth_provider
        maximum_activation_duration = eligible_authorization.value.maximum_activation_duration

        dynamic "approver" {
          for_each = eligible_authorization.value.approvers
          content {
            principal_id           = approver.value.principal_id
            principal_display_name = approver.value.principal_display_name
          }
        }
      }
    }
  }
}

resource "azurerm_lighthouse_assignment" "this" {
  scope                    = "/subscriptions/${each.value}"
  name                     = each.value
  lighthouse_definition_id = azurerm_lighthouse_definition.this[each.key].id
  for_each                 = var.enable_lighthouse ? var.subscription_ids : {}

  timeouts {
    delete = "60m"
    create = "60m"
  }
}


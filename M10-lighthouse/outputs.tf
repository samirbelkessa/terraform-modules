output "assignment_ids" {
  description = "Map of subscription names to Lighthouse Assignment IDs."
  value = {
    for k, v in azurerm_lighthouse_assignment.this : k => v.id
  }
}

output "configuration" {
  description = "M10 Lighthouse configuration summary."
  value = {
    enabled             = var.enable_lighthouse
    msp_offer_name      = var.msp_offer_name
    managing_tenant_id  = var.managing_tenant_id
    subscriptions       = var.subscription_ids
    authorization_count = length(var.authorizations)
    eligible_auth_count = length(var.eligible_authorizations)
  }
}

output "definition_ids" {
  description = "Map of subscription names to Lighthouse Definition IDs."
  value = {
    for k, v in azurerm_lighthouse_definition.this : k => v.id
  }
}

output "definition_names" {
  description = "Map of subscription names to Lighthouse Definition display names."
  value = {
    for k, v in azurerm_lighthouse_definition.this : k => v.name
  }
}


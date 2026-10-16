resource "azurerm_subscription" "this" {
  workload          = each.value.workload_type
  tags              = each.value.tags
  subscription_name = each.value.display_name
  for_each          = var.deployment_mode != "brownfield" ? local.subscriptions_to_create : {}
  billing_scope_id  = local.billing_scope_id
  alias             = each.value.alias_name

  lifecycle {
    prevent_destroy = false

    ignore_changes = [
      billing_scope_id,
    ]
  }
}

resource "time_sleep" "wait_for_subscription" {
  for_each = var.deployment_mode != "brownfield" ? local.subscriptions_to_create : {}

  depends_on = [
    azurerm_subscription.this,
  ]
  triggers = {
    subscription_id = azurerm_subscription.this[each.key].subscription_id
  }
  create_duration = var.wait_for_subscription_creation
}

resource "azurerm_management_group_subscription_association" "new_subscriptions" {
  subscription_id     = "/subscriptions/${azurerm_subscription.this[each.key].subscription_id}"
  management_group_id = each.value.management_group_id
  for_each            = var.deployment_mode != "brownfield" && var.enable_subscription_placement ? local.subscriptions_to_create : {}

  depends_on = [
    time_sleep.wait_for_subscription,
  ]
}

resource "azurerm_management_group_subscription_association" "existing_subscriptions" {
  subscription_id     = "/subscriptions/${each.value.subscription_id}"
  management_group_id = local.archetype_to_mg[each.value.archetype]
  for_each            = var.deployment_mode != "greenfield" && var.enable_subscription_placement ? var.existing_subscriptions : {}
}

resource "azurerm_consumption_budget_subscription" "this" {
  time_grain      = each.value.time_grain
  subscription_id = "/subscriptions/${azurerm_subscription.this[each.key].subscription_id}"
  name            = "budget-${each.key}"
  for_each        = local.subscription_budgets
  amount          = each.value.amount

  depends_on = [
    time_sleep.wait_for_subscription,
  ]

  time_period {
    start_date = each.value.start_date != null ? each.value.start_date : formatdate("YYYY-MM-01'T'00:00:00Z", timestamp())
    end_date   = each.value.end_date
  }

  lifecycle {
    ignore_changes = [
      time_period[0].start_date,
    ]
  }

  dynamic "notification" {
    for_each = each.value.notifications != null ? each.value.notifications : {}

    content {
      enabled        = notification.value.enabled
      threshold      = notification.value.threshold
      operator       = notification.value.operator
      threshold_type = "Actual"

      contact_emails = notification.value.contact_emails
      contact_roles  = notification.value.contact_roles
    }
  }
}

resource "azurerm_role_assignment" "default" {
  scope                = "/subscriptions/${azurerm_subscription.this[each.value.subscription_key].subscription_id}"
  role_definition_name = each.value.role_definition_name
  principal_type       = each.value.principal_type
  principal_id         = each.value.principal_id
  for_each             = local.role_assignments_map

  depends_on = [
    time_sleep.wait_for_subscription,
  ]
}

resource "azapi_resource" "resource_groups" {
  tags     = each.value.tags
  for_each = local.resource_groups_config

  depends_on = [
    time_sleep.wait_for_subscription,
  ]
  type      = "Microsoft.Resources/resourceGroups@2023-07-01"
  parent_id = "/subscriptions/${each.value.subscription_id}"
  name      = each.value.name
  location  = each.value.location
}

resource "azapi_resource_action" "register_providers" {
  for_each = {
    for entry in flatten([
      for sub_key, sub_id in local.all_subscription_ids : [
        for namespace in var.required_providers : {
          key       = "${sub_key}-${namespace}"
          sub_id    = sub_id
          namespace = namespace
        }
      ]
    ]) : entry.key => entry
  }
  type        = "Microsoft.Resources/subscriptions@2022-12-01"
  resource_id = "/subscriptions/${each.value.sub_id}"
  method      = "POST"
  action      = "providers/${each.value.namespace}/register"
}

data "azurerm_billing_mpa_account_scope" "this" {
  customer_name        = var.customer_name
  count                = var.billing_type == "MPA" ? 1 : 0
  billing_account_name = var.billing_account_name
}

data "azurerm_billing_mca_account_scope" "this" {
  invoice_section_name = var.invoice_section_name
  count                = var.billing_type == "MCA" ? 1 : 0
  billing_profile_name = var.billing_profile_name
  billing_account_name = var.billing_account_name
}


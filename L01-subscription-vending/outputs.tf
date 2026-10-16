output "budget_ids" {
  description = "Map of subscription keys to their budget resource IDs."
  value = {
    for key, budget in azurerm_consumption_budget_subscription.this : key => budget.id
  }
}

output "corp_nonprod_subscription_ids" {
  description = "List of subscription IDs in the Corp-NonProd archetype."
  value = [
    for key, sub in azurerm_subscription.this :
    sub.subscription_id
    if local.subscriptions_to_create[key].archetype == "corp_nonprod"
  ]
}

output "corp_prod_subscription_ids" {
  description = "List of subscription IDs in the Corp-Prod archetype."
  value = [
    for key, sub in azurerm_subscription.this :
    sub.subscription_id
    if local.subscriptions_to_create[key].archetype == "corp_prod"
  ]
}

output "existing_subscriptions_placed" {
  description = "Map of existing subscriptions that were placed into management groups."
  value = {
    for key, assoc in azurerm_management_group_subscription_association.existing_subscriptions : key => {
      subscription_id     = assoc.subscription_id
      management_group_id = assoc.management_group_id
      archetype           = local.existing_subscriptions_to_place[key].archetype
    }
  }
}

output "management_group_associations" {
  description = "Map of subscription keys to their management group associations."
  value = {
    for key, assoc in azurerm_management_group_subscription_association.new_subscriptions : key => {
      subscription_id     = assoc.subscription_id
      management_group_id = assoc.management_group_id
    }
  }
}

output "online_nonprod_subscription_ids" {
  description = "List of subscription IDs in the Online-NonProd archetype."
  value = [
    for key, sub in azurerm_subscription.this :
    sub.subscription_id
    if local.subscriptions_to_create[key].archetype == "online_nonprod"
  ]
}

output "online_prod_subscription_ids" {
  description = "List of subscription IDs in the Online-Prod archetype."
  value = [
    for key, sub in azurerm_subscription.this :
    sub.subscription_id
    if local.subscriptions_to_create[key].archetype == "online_prod"
  ]
}

output "platform_subscription_ids" {
  description = "Map of platform subscription IDs (management, connectivity, identity)."
  value = {
    management = [
      for key, sub in azurerm_subscription.this :
      sub.subscription_id
      if local.subscriptions_to_create[key].archetype == "management"
    ]
    connectivity = [
      for key, sub in azurerm_subscription.this :
      sub.subscription_id
      if local.subscriptions_to_create[key].archetype == "connectivity"
    ]
    identity = [
      for key, sub in azurerm_subscription.this :
      sub.subscription_id
      if local.subscriptions_to_create[key].archetype == "identity"
    ]
  }
}

output "resource_groups_by_subscription" {
  description = "Resource groups grouped by subscription."
  value = {
    for sub_key in distinct([for k, v in local.resource_groups_config : v.subscription_key]) :
    sub_key => {
      for key, config in local.resource_groups_config :
      config.rg_key => {
        id       = try(azapi_resource.resource_groups[key].id, null)
        name     = try(azapi_resource.resource_groups[key].name, null)
        location = try(azapi_resource.resource_groups[key].location, null)
      }
      if config.subscription_key == sub_key && contains(keys(azapi_resource.resource_groups), key)
    }
  }
}

output "sandbox_subscription_ids" {
  description = "List of subscription IDs in the Sandbox archetype."
  value = [
    for key, sub in azurerm_subscription.this :
    sub.subscription_id
    if local.subscriptions_to_create[key].archetype == "sandbox"
  ]
}

output "subscription_ids" {
  description = "Map of subscription keys to their subscription IDs."
  value = {
    for key, sub in azurerm_subscription.this : key => sub.subscription_id
  }
}

output "subscription_names" {
  description = "Map of subscription keys to their display names."
  value = {
    for key, sub in azurerm_subscription.this : key => sub.subscription_name
  }
}

output "subscription_tenant_ids" {
  description = "Map of subscription keys to their tenant IDs."
  value = {
    for key, sub in azurerm_subscription.this : key => sub.tenant_id
  }
}

output "subscriptions" {
  description = "Full details of all created subscriptions."
  value = {
    for key, sub in azurerm_subscription.this : key => {
      subscription_id     = sub.subscription_id
      subscription_name   = sub.subscription_name
      tenant_id           = sub.tenant_id
      alias               = sub.alias
      archetype           = local.subscriptions_to_create[key].archetype
      management_group_id = local.subscriptions_to_create[key].management_group_id
      workload_type       = local.subscriptions_to_create[key].workload_type
      tags                = sub.tags
      resource_id         = "/subscriptions/${sub.subscription_id}"
    }
  }
}

output "subscriptions_by_archetype" {
  description = "Map of archetypes to lists of subscription IDs."
  value = {
    for archetype in distinct([for k, v in local.subscriptions_to_create : v.archetype]) :
    archetype => [
      for key, sub in azurerm_subscription.this :
      sub.subscription_id
      if local.subscriptions_to_create[key].archetype == archetype
    ]
  }
}

output "summary" {
  description = "Summary of all subscription operations."
  value = {
    total_subscriptions_created = length(azurerm_subscription.this)
    total_existing_placed       = length(azurerm_management_group_subscription_association.existing_subscriptions)
    total_budgets_created       = length(azurerm_consumption_budget_subscription.this)

    by_archetype = {
      for archetype in distinct(concat(
        [for k, v in local.subscriptions_to_create : v.archetype],
        [for k, v in local.existing_subscriptions_to_place : v.archetype]
      )) :
      archetype => {
        new_subscriptions = length([
          for k, v in local.subscriptions_to_create : k
          if v.archetype == archetype
        ])
        existing_placed = length([
          for k, v in local.existing_subscriptions_to_place : k
          if v.archetype == archetype
        ])
      }
    }
  }
}


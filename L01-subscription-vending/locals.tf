locals {
  all_role_assignments = flatten([
    for sub_key, sub in var.subscriptions : [
      for role_key, role in var.default_role_assignments : {
        key                  = "${sub_key}-${role_key}"
        subscription_key     = sub_key
        role_definition_name = role.role_definition_name
        principal_id         = role.principal_id
        principal_type       = role.principal_type
      }
    ]
  ])

  all_subscription_ids = (
    var.deployment_mode == "greenfield" ? local.greenfield_subscription_ids :
    var.deployment_mode == "brownfield" ? local.brownfield_subscription_ids :
    merge(local.greenfield_subscription_ids, local.brownfield_subscription_ids)
  )

  archetype_to_mg = {
    root           = lookup(var.management_group_ids, "root", null)
    platform       = lookup(var.management_group_ids, "platform", null)
    management     = lookup(var.management_group_ids, "management", null)
    connectivity   = lookup(var.management_group_ids, "connectivity", null)
    identity       = lookup(var.management_group_ids, "identity", null)
    security       = lookup(var.management_group_ids, "security", null)
    landing_zones  = lookup(var.management_group_ids, "landing_zones", null)
    corp_prod      = lookup(var.management_group_ids, "corp_prod", null)
    corp_nonprod   = lookup(var.management_group_ids, "corp_nonprod", null)
    online_prod    = lookup(var.management_group_ids, "online_prod", null)
    online_nonprod = lookup(var.management_group_ids, "online_nonprod", null)
    sandbox        = lookup(var.management_group_ids, "sandbox", null)
    decommissioned = lookup(var.management_group_ids, "decommissioned", null)
  }

  billing_scope_id = (
    var.deployment_mode == "brownfield" ? "" :
    var.billing_type == "MPA" ? data.azurerm_billing_mpa_account_scope.this[0].id :
    var.billing_type == "MCA" ? data.azurerm_billing_mca_account_scope.this[0].id :
    var.billing_scope
  )

  brownfield_subscription_ids = {
    for key, sub in var.existing_subscriptions : key => sub.subscription_id
  }

  default_tags = merge(
    {
      ManagedBy = "Terraform"
      Module    = "L01-subscription-vending"
    },
    var.default_tags
  )

  essential_resource_providers = [
    "Microsoft.Compute",
    "Microsoft.Storage",
    "Microsoft.Network",
    "Microsoft.KeyVault",
    "Microsoft.ManagedIdentity",
    "Microsoft.Authorization",
    "Microsoft.Resources",
    "Microsoft.OperationalInsights",
    "Microsoft.OperationsManagement",
    "Microsoft.Insights",
    "Microsoft.Security",
    "Microsoft.Advisor",
    "Microsoft.AlertsManagement",
    "Microsoft.RecoveryServices"
  ]

  existing_subscriptions_to_place = {
    for key, sub in var.existing_subscriptions : key => {
      subscription_id     = sub.subscription_id
      management_group_id = local.archetype_to_mg[sub.archetype]
      archetype           = sub.archetype
    }
    if local.archetype_to_mg[sub.archetype] != null
  }

  greenfield_subscription_ids = {
    for key, sub in azurerm_subscription.this : key => sub.subscription_id
  }

  location_short = {
    australiaeast      = "aue"
    australiasoutheast = "ause"
    westeurope         = "weu"
    northeurope        = "neu"
    eastus             = "eus"
    westus             = "wus"
  }

  resource_groups_config = {
    for rg_key, rg in local.resource_groups_parsed : rg_key => {
      subscription_key = rg.subscription_key
      subscription_id  = local.all_subscription_ids[rg.subscription_key]
      rg_key           = rg.rg_key
      name             = var.enable_tas_naming && contains(keys(var.custom_rg_names), rg_key) ? var.custom_rg_names[rg_key] : "rg-${var.root_id}-${rg.subscription_key}-${rg.rg_key}-${lookup(local.location_short, rg.location, "aue")}-001"
      location         = rg.location
      tags             = merge(var.default_tags, { Subscription = rg.subscription_key, Purpose = rg.rg_key }, rg.tags)
    }
    if contains(keys(local.all_subscription_ids), rg.subscription_key)
  }

  resource_groups_parsed = {
    for key, rg in var.resource_groups : key => {
      subscription_key = split(".", key)[0]
      rg_key           = split(".", key)[1]
      location         = coalesce(rg.location, var.default_location)
      tags             = rg.tags
    }
  }

  role_assignments_map = {
    for ra in local.all_role_assignments : ra.key => ra
  }

  subscription_budgets = {
    for key, sub in var.subscriptions : key => sub.budget
    if sub.budget != null
  }

  subscriptions_to_create = {
    for key, sub in var.subscriptions : key => {
      alias_name          = "${var.subscription_alias_prefix}-${key}"
      display_name        = sub.display_name
      workload_type       = sub.workload_type
      billing_scope       = var.billing_scope
      management_group_id = local.archetype_to_mg[sub.archetype]
      archetype           = sub.archetype
      owner_object_id     = sub.owner_object_id
      tags = merge(local.default_tags, sub.tags, {
        Archetype   = sub.archetype
        Environment = sub.workload_type == "Production" ? "Production" : "NonProduction"
      })
      budget = sub.budget
    }
  }

}

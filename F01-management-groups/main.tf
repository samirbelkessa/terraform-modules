resource "azurerm_management_group" "root" {
  parent_management_group_id = local.root_parent_management_group_id
  name                       = local.mg_names.root
  display_name               = local.mg_display_names.root

  timeouts {
    update = var.timeouts.update
    read   = var.timeouts.read
    delete = var.timeouts.delete
    create = var.timeouts.create
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_management_group" "platform" {
  parent_management_group_id = azurerm_management_group.root.id
  name                       = local.mg_names.platform
  display_name               = local.mg_display_names.platform
  count                      = var.deploy_platform_mg ? 1 : 0

  lifecycle {
    ignore_changes = [
      subscription_ids,
    ]
  }

  timeouts {
    update = var.timeouts.update
    read   = var.timeouts.read
    delete = var.timeouts.delete
    create = var.timeouts.create
  }
}

resource "azurerm_management_group" "management" {
  parent_management_group_id = azurerm_management_group.platform[0].id
  name                       = local.mg_names.management
  display_name               = local.mg_display_names.management
  count                      = local.deploy_management ? 1 : 0

  lifecycle {
    ignore_changes = [
      subscription_ids,
    ]
  }

  timeouts {
    update = var.timeouts.update
    read   = var.timeouts.read
    delete = var.timeouts.delete
    create = var.timeouts.create
  }
}

resource "azurerm_management_group" "connectivity" {
  parent_management_group_id = azurerm_management_group.platform[0].id
  name                       = local.mg_names.connectivity
  display_name               = local.mg_display_names.connectivity
  count                      = local.deploy_connectivity ? 1 : 0

  lifecycle {
    ignore_changes = [
      subscription_ids,
    ]
  }

  timeouts {
    update = var.timeouts.update
    read   = var.timeouts.read
    delete = var.timeouts.delete
    create = var.timeouts.create
  }
}

resource "azurerm_management_group" "identity" {
  parent_management_group_id = azurerm_management_group.platform[0].id
  name                       = local.mg_names.identity
  display_name               = local.mg_display_names.identity
  count                      = local.deploy_identity ? 1 : 0

  lifecycle {
    ignore_changes = [
      subscription_ids,
    ]
  }

  timeouts {
    update = var.timeouts.update
    read   = var.timeouts.read
    delete = var.timeouts.delete
    create = var.timeouts.create
  }
}

resource "azurerm_management_group" "custom_platform" {
  parent_management_group_id = azurerm_management_group.platform[0].id
  name                       = "${var.root_id}-${each.key}"
  for_each                   = var.deploy_platform_mg ? var.custom_platform_children : {}
  display_name               = each.value.display_name

  lifecycle {
    ignore_changes = [
      subscription_ids,
    ]
  }

  timeouts {
    update = var.timeouts.update
    read   = var.timeouts.read
    delete = var.timeouts.delete
    create = var.timeouts.create
  }
}

resource "azurerm_management_group" "landing_zones" {
  parent_management_group_id = azurerm_management_group.root.id
  name                       = local.mg_names.landing_zones
  display_name               = local.mg_display_names.landing_zones
  count                      = var.deploy_landing_zones_mg ? 1 : 0

  lifecycle {
    ignore_changes = [
      subscription_ids,
    ]
  }

  timeouts {
    update = var.timeouts.update
    read   = var.timeouts.read
    delete = var.timeouts.delete
    create = var.timeouts.create
  }
}

resource "azurerm_management_group" "corp_prod" {
  parent_management_group_id = azurerm_management_group.landing_zones[0].id
  name                       = local.mg_names.corp_prod
  display_name               = local.mg_display_names.corp_prod
  count                      = local.deploy_corp_prod ? 1 : 0

  lifecycle {
    ignore_changes = [
      subscription_ids,
    ]
  }

  timeouts {
    update = var.timeouts.update
    read   = var.timeouts.read
    delete = var.timeouts.delete
    create = var.timeouts.create
  }
}

resource "azurerm_management_group" "corp_nonprod" {
  parent_management_group_id = azurerm_management_group.landing_zones[0].id
  name                       = local.mg_names.corp_nonprod
  display_name               = local.mg_display_names.corp_nonprod
  count                      = local.deploy_corp_nonprod ? 1 : 0

  lifecycle {
    ignore_changes = [
      subscription_ids,
    ]
  }

  timeouts {
    update = var.timeouts.update
    read   = var.timeouts.read
    delete = var.timeouts.delete
    create = var.timeouts.create
  }
}

resource "azurerm_management_group" "corp" {
  parent_management_group_id = azurerm_management_group.landing_zones[0].id
  name                       = local.mg_names.corp
  display_name               = local.mg_display_names.corp
  count                      = local.deploy_corp_single ? 1 : 0

  lifecycle {
    ignore_changes = [
      subscription_ids,
    ]
  }

  timeouts {
    update = var.timeouts.update
    read   = var.timeouts.read
    delete = var.timeouts.delete
    create = var.timeouts.create
  }
}

resource "azurerm_management_group" "online_prod" {
  parent_management_group_id = azurerm_management_group.landing_zones[0].id
  name                       = local.mg_names.online_prod
  display_name               = local.mg_display_names.online_prod
  count                      = local.deploy_online_prod ? 1 : 0

  lifecycle {
    ignore_changes = [
      subscription_ids,
    ]
  }

  timeouts {
    update = var.timeouts.update
    read   = var.timeouts.read
    delete = var.timeouts.delete
    create = var.timeouts.create
  }
}

resource "azurerm_management_group" "online_nonprod" {
  parent_management_group_id = azurerm_management_group.landing_zones[0].id
  name                       = local.mg_names.online_nonprod
  display_name               = local.mg_display_names.online_nonprod
  count                      = local.deploy_online_nonprod ? 1 : 0

  lifecycle {
    ignore_changes = [
      subscription_ids,
    ]
  }

  timeouts {
    update = var.timeouts.update
    read   = var.timeouts.read
    delete = var.timeouts.delete
    create = var.timeouts.create
  }
}

resource "azurerm_management_group" "online" {
  parent_management_group_id = azurerm_management_group.landing_zones[0].id
  name                       = local.mg_names.online
  display_name               = local.mg_display_names.online
  count                      = local.deploy_online_single ? 1 : 0

  lifecycle {
    ignore_changes = [
      subscription_ids,
    ]
  }

  timeouts {
    update = var.timeouts.update
    read   = var.timeouts.read
    delete = var.timeouts.delete
    create = var.timeouts.create
  }
}

resource "azurerm_management_group" "sandbox" {
  parent_management_group_id = azurerm_management_group.landing_zones[0].id
  name                       = local.mg_names.sandbox
  display_name               = local.mg_display_names.sandbox
  count                      = local.deploy_sandbox ? 1 : 0

  lifecycle {
    ignore_changes = [
      subscription_ids,
    ]
  }

  timeouts {
    update = var.timeouts.update
    read   = var.timeouts.read
    delete = var.timeouts.delete
    create = var.timeouts.create
  }
}

resource "azurerm_management_group" "custom_landing_zone" {
  parent_management_group_id = azurerm_management_group.landing_zones[0].id
  name                       = "${var.root_id}-${each.key}"
  for_each                   = var.deploy_landing_zones_mg ? var.custom_landing_zone_children : {}
  display_name               = each.value.display_name

  lifecycle {
    ignore_changes = [
      subscription_ids,
    ]
  }

  timeouts {
    update = var.timeouts.update
    read   = var.timeouts.read
    delete = var.timeouts.delete
    create = var.timeouts.create
  }
}

resource "azurerm_management_group" "decommissioned" {
  parent_management_group_id = azurerm_management_group.root.id
  name                       = local.mg_names.decommissioned
  display_name               = local.mg_display_names.decommissioned
  count                      = var.deploy_decommissioned_mg ? 1 : 0

  lifecycle {
    ignore_changes = [
      subscription_ids,
    ]
  }

  timeouts {
    update = var.timeouts.update
    read   = var.timeouts.read
    delete = var.timeouts.delete
    create = var.timeouts.create
  }
}

resource "azurerm_management_group_subscription_association" "associations" {
  subscription_id     = "/subscriptions/${each.value.subscription_id}"
  management_group_id = local.mg_key_to_id[each.value.mg_key]
  for_each            = local.subscription_associations_map
}


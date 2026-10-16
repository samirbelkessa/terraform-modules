resource "azurerm_storage_account" "this" {
  tags                              = local.tags
  shared_access_key_enabled         = var.shared_access_key_enabled
  resource_group_name               = var.resource_group_name
  public_network_access_enabled     = var.public_network_access_enabled
  name                              = "${substr(local.storage_account_name, 0, 22)}c1"
  min_tls_version                   = var.min_tls_version
  location                          = var.location
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  https_traffic_only_enabled        = var.https_traffic_only_enabled
  default_to_oauth_authentication   = var.default_to_oauth_authentication
  allow_nested_items_to_be_public   = var.allow_nested_items_to_be_public
  account_tier                      = var.account_tier
  account_replication_type          = local.account_replication_type
  account_kind                      = var.account_kind
  access_tier                       = var.access_tier

  blob_properties {
    versioning_enabled            = var.enable_versioning
    change_feed_retention_in_days = var.enable_change_feed ? var.change_feed_retention_in_days : null
    change_feed_enabled           = var.enable_change_feed

    container_delete_retention_policy {
      days = var.container_soft_delete_retention_days > 0 ? var.container_soft_delete_retention_days : null
    }

    delete_retention_policy {
      days = var.blob_soft_delete_retention_days > 0 ? var.blob_soft_delete_retention_days : null
    }
  }

  lifecycle {
    prevent_destroy = false
  }

  dynamic "network_rules" {
    for_each = var.network_rules != null ? [var.network_rules] : []
    content {
      default_action             = network_rules.value.default_action
      bypass                     = network_rules.value.bypass
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.virtual_network_subnet_ids
    }
  }
}

resource "azurerm_storage_container" "containers" {
  storage_account_id    = azurerm_storage_account.this.id
  name                  = each.key
  metadata              = each.value.metadata
  for_each              = local.all_containers
  container_access_type = each.value.container_access_type

  depends_on = [
    azurerm_storage_account.this,
  ]
}

resource "azurerm_storage_management_policy" "this" {
  storage_account_id = azurerm_storage_account.this.id
  count              = var.enable_lifecycle_management && length(local.lifecycle_rules) > 0 ? 1 : 0

  depends_on = [
    azurerm_storage_account.this,
  ]

  dynamic "rule" {
    for_each = local.lifecycle_rules
    content {
      name    = rule.key
      enabled = rule.value.enabled

      filters {
        prefix_match = length(rule.value.prefix_match) > 0 ? rule.value.prefix_match : null
        blob_types   = rule.value.blob_types
      }

      actions {
        # Base blob actions
        base_blob {
          # Tier to Cool
          tier_to_cool_after_days_since_modification_greater_than = rule.value.tier_to_cool_after_days

          # Tier to Cold (optional, for Cold tier storage)
          tier_to_cold_after_days_since_modification_greater_than = rule.value.tier_to_cold_after_days

          # Tier to Archive
          tier_to_archive_after_days_since_modification_greater_than = rule.value.tier_to_archive_after_days

          # Delete
          delete_after_days_since_modification_greater_than = rule.value.delete_after_days

          # Auto-tier from Cool to Hot based on access
          auto_tier_to_hot_from_cool_enabled = rule.value.auto_tier_to_hot_from_cool_enabled
        }

        # Snapshot actions
        snapshot {
          delete_after_days_since_creation_greater_than = rule.value.delete_snapshot_after_days
        }

        # Version actions (if versioning enabled)
        dynamic "version" {
          for_each = var.enable_versioning ? [1] : []
          content {
            delete_after_days_since_creation = rule.value.delete_after_days
          }
        }
      }
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage_account" {
  target_resource_id         = azurerm_storage_account.this.id
  name                       = "diag-${local.storage_account_name}"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  count                      = var.enable_diagnostic_settings && var.log_analytics_workspace_id != null ? 1 : 0

  depends_on = [
    azurerm_storage_account.this,
  ]

  dynamic "enabled_metric" {
    for_each = var.diagnostic_metric_categories
    content {
      category = enabled_metric.value
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "blob_service" {
  target_resource_id         = "${azurerm_storage_account.this.id}/blobServices/default"
  name                       = "diag-${local.storage_account_name}-blob"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  count                      = var.enable_diagnostic_settings && var.log_analytics_workspace_id != null ? 1 : 0

  depends_on = [
    azurerm_storage_account.this,
  ]

  dynamic "enabled_log" {
    for_each = local.blob_diagnostic_log_categories
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = local.blob_diagnostic_metric_categories
    content {
      category = enabled_metric.value
    }
  }
}

module "naming" {
  source = "git::https://github.com/Experteq-MSP/terraform-modules//F02-naming-convention?ref=main"


  workload      = var.workload
  resource_type = "st"
  region        = var.region
  instance      = var.instance
  environment   = var.environment

}


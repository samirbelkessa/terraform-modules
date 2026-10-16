locals {
  account_replication_type = local.replication_type

  all_containers = merge(local.default_containers, var.additional_containers)

  blob_diagnostic_log_categories = [
    "StorageRead",
    "StorageWrite",
    "StorageDelete"
  ]

  blob_diagnostic_metric_categories = [
    "Transaction",
    "Capacity"
  ]

  default_containers = var.create_default_containers ? {
    "bootdiagnostics" = {
      container_access_type = var.default_container_access_type
      metadata = {
        purpose = "VM Boot Diagnostics"
      }
    }
    "insights-logs" = {
      container_access_type = var.default_container_access_type
      metadata = {
        purpose = "Azure Monitor Archived Logs"
      }
    }
    "insights-metrics" = {
      container_access_type = var.default_container_access_type
      metadata = {
        purpose = "Azure Monitor Archived Metrics"
      }
    }
  } : {}

  default_lifecycle_rules = var.enable_lifecycle_management ? {
    "default-diagnostics-lifecycle" = {
      enabled                            = true
      prefix_match                       = [] # Apply to all blobs
      blob_types                         = ["blockBlob"]
      tier_to_cool_after_days            = var.default_lifecycle_tier_to_cool_days
      tier_to_archive_after_days         = var.default_lifecycle_tier_to_archive_days
      delete_after_days                  = var.default_lifecycle_delete_days
      delete_snapshot_after_days         = 90
      tier_to_cold_after_days            = null
      auto_tier_to_hot_from_cool_enabled = false
    }
  } : {}

  env_short = lookup(local.environment_map, var.environment, "dev")

  environment_map = {
    prod    = "prd"
    nonprod = "npd"
    dev     = "dev"
    test    = "tst"
    uat     = "uat"
    stg     = "stg"
    sandbox = "sbx"
  }

  generated_name = lower(replace(
    "st${var.workload}${local.env_short}${var.region}${var.instance}",
    "-", ""
  ))

  is_production = contains(["prod"], var.environment)

  lifecycle_rules = length(var.lifecycle_rules) > 0 ? var.lifecycle_rules : local.default_lifecycle_rules

  replication_type = var.replication_type != null ? var.replication_type : (
    local.is_production ? "GRS" : "LRS"
  )

  storage_account_name = var.custom_name != null ? var.custom_name : (
    length(local.generated_name) > 24 ? substr(local.generated_name, 0, 24) : local.generated_name
  )

  tags = merge(
    var.tags,
    {
      Module = "M08-diagnostics-storage-account"
    }
  )

}

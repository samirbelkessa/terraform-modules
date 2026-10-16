variable "Brainboard_IP_Range_List" {
  type    = list(string)
  default = ["3.18.12.57", "3.19.117.9", "3.12.21.31", "3.140.65.244", "18.223.219.168", "3.139.254.14", "3.109.176.247", "13.235.196.228", "3.108.102.235", "35.154.77.165", "159.196.14.175/32"]
}

variable "access_tier" {
  description = "Default access tier for blobs. Hot recommended for active diagnostics."
  type        = string
  default     = "Hot"

  validation {
    condition     = contains(["Hot", "Cool"], var.access_tier)
    error_message = "variable value does not match the validator"
  }
}

variable "account_kind" {
  description = "Storage Account kind. StorageV2 recommended for diagnostics."
  type        = string
  default     = "StorageV2"

  validation {
    condition     = contains(["StorageV2", "BlobStorage", "Storage"], var.account_kind)
    error_message = "variable value does not match the validator"
  }
}

variable "account_tier" {
  description = "Storage Account tier. Standard is sufficient for diagnostics."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "variable value does not match the validator"
  }
}

variable "additional_containers" {
  description = "Map of additional containers to create."
  type = map(object({
    container_access_type = optional(string, "private")
    metadata              = optional(map(string), {})
  }))
  default = {}
}

variable "allow_nested_items_to_be_public" {
  description = "Allow public access to blobs within containers. Disabled for security."
  type        = bool
  default     = false
}

variable "blob_soft_delete_retention_days" {
  description = "Days to retain deleted blobs. Set to 0 to disable."
  type        = number
  default     = 7

  validation {
    condition     = var.blob_soft_delete_retention_days >= 0 && var.blob_soft_delete_retention_days <= 365
    error_message = "variable value does not match the validator"
  }
}

variable "change_feed_retention_in_days" {
  description = "Days to retain change feed data."
  type        = number
  default     = 7

  validation {
    condition     = var.change_feed_retention_in_days >= 1 && var.change_feed_retention_in_days <= 146000
    error_message = "variable value does not match the validator"
  }
}

variable "container_soft_delete_retention_days" {
  description = "Days to retain deleted containers. Set to 0 to disable."
  type        = number
  default     = 7

  validation {
    condition     = var.container_soft_delete_retention_days >= 0 && var.container_soft_delete_retention_days <= 365
    error_message = "variable value does not match the validator"
  }
}

variable "create_default_containers" {
  description = "Create default diagnostic containers (bootdiagnostics, insights-logs, insights-metrics)."
  type        = bool
  default     = true
}

variable "custom_name" {
  description = "Custom name for Storage Account (bypasses F02 naming). Storage account names must be 3-24 characters, lowercase alphanumeric only."
  type        = string
  default     = null

  validation {
    condition     = var.custom_name == null || can(regex("^[a-z0-9]{3,24}$", var.custom_name))
    error_message = "variable value does not match the validator"
  }
}

variable "default_container_access_type" {
  description = "Default access type for containers. Private is strongly recommended."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["private", "blob", "container"], var.default_container_access_type)
    error_message = "variable value does not match the validator"
  }
}

variable "default_lifecycle_delete_days" {
  description = "Default days before deleting blobs. 400 days = ~1.1 years (per client requirements)."
  type        = number
  default     = 400

  validation {
    condition     = var.default_lifecycle_delete_days >= 1 && var.default_lifecycle_delete_days <= 2555
    error_message = "variable value does not match the validator"
  }
}

variable "default_lifecycle_tier_to_archive_days" {
  description = "Default days before tiering blobs from Cool to Archive tier."
  type        = number
  default     = 90

  validation {
    condition     = var.default_lifecycle_tier_to_archive_days >= 1 && var.default_lifecycle_tier_to_archive_days <= 730
    error_message = "variable value does not match the validator"
  }
}

variable "default_lifecycle_tier_to_cool_days" {
  description = "Default days before tiering blobs from Hot to Cool tier."
  type        = number
  default     = 30

  validation {
    condition     = var.default_lifecycle_tier_to_cool_days >= 1 && var.default_lifecycle_tier_to_cool_days <= 365
    error_message = "variable value does not match the validator"
  }
}

variable "default_to_oauth_authentication" {
  description = "Use Entra ID (OAuth) by default in the Azure Portal."
  type        = bool
  default     = true
}

variable "diagnostic_log_categories" {
  description = "Log categories to enable for Storage Account diagnostics."
  type        = list(string)
  default     = ["StorageRead", "StorageWrite", "StorageDelete"]
}

variable "diagnostic_logs_retention_days" {
  description = "Retention days for diagnostic logs (0 = unlimited)."
  type        = number
  default     = 90

  validation {
    condition     = var.diagnostic_logs_retention_days >= 0 && var.diagnostic_logs_retention_days <= 365
    error_message = "variable value does not match the validator"
  }
}

variable "diagnostic_metric_categories" {
  description = "Metric categories to enable for Storage Account diagnostics."
  type        = list(string)
  default     = ["Transaction", "Capacity"]
}

variable "enable_change_feed" {
  description = "Enable blob change feed for tracking changes."
  type        = bool
  default     = false
}

variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings on the Storage Account itself."
  type        = bool
  default     = false
}

variable "enable_lifecycle_management" {
  description = "Enable blob lifecycle management policies for automatic tiering and deletion."
  type        = bool
  default     = true
}

variable "enable_versioning" {
  description = "Enable blob versioning. Recommended for production diagnostics storage."
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environment for naming and tagging. Valid: prod, nonprod, dev, test, uat, stg, sandbox."
  type        = string

  validation {
    condition     = contains(["prod", "nonprod", "dev", "test", "uat", "stg", "sandbox"], var.environment)
    error_message = "variable value does not match the validator"
  }
}

variable "https_traffic_only_enabled" {
  description = "Force HTTPS for all connections."
  type        = bool
  default     = true
}

variable "infrastructure_encryption_enabled" {
  description = "Enable double encryption at infrastructure level."
  type        = bool
  default     = false
}

variable "instance" {
  description = "Instance number for multiple resources (e.g., '001')."
  type        = string
  default     = "001"

  validation {
    condition     = can(regex("^[0-9]{2,3}$", var.instance))
    error_message = "variable value does not match the validator"
  }
}

variable "lifecycle_rules" {
  description = "Custom lifecycle rules. If empty, default rules for diagnostic data will be used."
  type = map(object({
    enabled                            = optional(bool, true)
    prefix_match                       = optional(list(string), [])
    blob_types                         = optional(list(string), ["blockBlob"])
    tier_to_cool_after_days            = optional(number, 30)
    tier_to_archive_after_days         = optional(number, 90)
    delete_after_days                  = optional(number, 400)
    delete_snapshot_after_days         = optional(number, 90)
    tier_to_cold_after_days            = optional(number, null)
    auto_tier_to_hot_from_cool_enabled = optional(bool, false)
  }))
  default = {}
}

variable "location" {
  description = "Azure region for the Storage Account (e.g., 'australiaeast')."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostics. Required if enable_diagnostic_settings is true."
  type        = string
  default     = null
}

variable "min_tls_version" {
  description = "Minimum TLS version for the Storage Account."
  type        = string
  default     = "TLS1_2"

  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.min_tls_version)
    error_message = "variable value does not match the validator"
  }
}

variable "network_rules" {
  description = "Network rules for the Storage Account. Set to null for no restrictions (default)."
  type = object({
    default_action             = optional(string, "Deny")
    bypass                     = optional(list(string), ["AzureServices", "Logging", "Metrics"])
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = null
}

variable "public_network_access_enabled" {
  description = "Enable public network access. Can be disabled when using Private Endpoints."
  type        = bool
  default     = true
}

variable "region" {
  description = "Azure region abbreviation for naming (e.g., 'aue' for Australia East)."
  type        = string
  default     = "aue"

  validation {
    condition     = can(regex("^[a-z]{2,6}$", var.region))
    error_message = "variable value does not match the validator"
  }
}

variable "replication_type" {
  description = "Replication type. If null, automatically set based on environment (GRS for prod, LRS for non-prod)."
  type        = string
  default     = null

  validation {
    condition     = var.replication_type == null ? true : contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.replication_type)
    error_message = "variable value does not match the validator"
  }
}

variable "resource_group_name" {
  description = "Name of the resource group where the Storage Account will be created."
  type        = string
}

variable "shared_access_key_enabled" {
  description = "Allow access using storage account keys. Disable for enhanced security (use Entra ID auth instead)."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources created by this module."
  type        = map(string)
  default     = {}
}

variable "workload" {
  description = "Workload name for resource naming via F02 module (e.g., 'diag', 'platform')."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]+(-[a-z0-9]+)*$", var.workload)) && length(var.workload) >= 2 && length(var.workload) <= 15
    error_message = "variable value does not match the validator"
  }
}


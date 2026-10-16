variable "Brainboard_IP_Range_List" {
  type    = list(string)
  default = ["3.18.12.57", "3.19.117.9", "3.12.21.31", "3.140.65.244", "18.223.219.168", "3.139.254.14", "3.109.176.247", "13.235.196.228", "3.108.102.235", "35.154.77.165", "159.196.14.175/32"]
}

variable "additional_tags" {
  description = "Additional custom tags to merge with F03 generated tags."
  type        = map(string)
  default     = {}
}

variable "archive_tables" {
  description = "Map of tables to configure with specific archive retention."
  type        = map(number)
  default = {
    AuditLogs     = 400
    AzureActivity = 400
    AzureMetrics  = 180
    Perf          = 180
    SecurityEvent = 400
    SigninLogs    = 400
    Syslog        = 400
  }
}

variable "criticality" {
  description = "Business criticality level for F03 tags."
  type        = string
  default     = "Critical"

  validation {
    condition     = contains(["Critical", "High", "Medium", "Low"], var.criticality)
    error_message = "variable value does not match the validator"
  }
}

variable "custom_name" {
  description = "Custom name for workspace (bypasses F02 naming). Use sparingly for legacy resources."
  type        = string
  default     = null

  validation {
    condition     = var.custom_name == null || can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{2,61}[a-zA-Z0-9]$", var.custom_name))
    error_message = "variable value does not match the validator"
  }
}

variable "daily_quota_gb" {
  description = "Daily ingestion quota in GB. -1 for unlimited."
  type        = number
  default     = -1

  validation {
    condition     = var.daily_quota_gb == -1 || var.daily_quota_gb >= 1
    error_message = "variable value does not match the validator"
  }
}

variable "data_classification" {
  description = "Data classification for F03 tags."
  type        = string
  default     = "Internal"

  validation {
    condition     = contains(["Public", "Internal", "Confidential", "Restricted"], var.data_classification)
    error_message = "variable value does not match the validator"
  }
}

variable "department" {
  description = "Department for F03 tags."
  type        = string
  default     = null
}

variable "deploy_solutions" {
  description = "Deploy Log Analytics solutions."
  type        = bool
  default     = true
}

variable "diagnostic_categories" {
  description = "Categories of logs to capture in diagnostic settings."
  type        = list(string)
  default     = ["Audit", "SummaryLogs"]
}

variable "diagnostic_storage_account_id" {
  description = "Storage account ID for diagnostic logs archival."
  type        = string
  default     = null
}

variable "enable_cross_region_workspace" {
  description = "Create a secondary workspace in DR region."
  type        = bool
  default     = false
}

variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for the workspace itself."
  type        = bool
  default     = false
}

variable "enable_table_level_archive" {
  description = "Enable archive configuration at table level for specific tables."
  type        = bool
  default     = true
}

variable "environment" {
  description = "Environment for naming and tagging. Valid: prod, nonprod, dev, test, uat, stg, sandbox."
  type        = string

  validation {
    condition     = contains(["prod", "nonprod", "dev", "test", "uat", "stg", "sandbox"], var.environment)
    error_message = "variable value does not match the validator"
  }
}

variable "instance" {
  description = "Instance number for multiple resources (e.g., '001')."
  type        = string
  default     = "001"
}

variable "internet_ingestion_access_type" {
  description = "Allow data ingestion from public internet. Values: Enabled, Disabled."
  type        = string
  default     = "Enabled"
}

variable "internet_query_access_type" {
  description = "Allow queries from public internet. Values: Enabled, Disabled."
  type        = string
  default     = "Enabled"
}

variable "local_authentication_enabled" {
  description = "Enable local authentication (shared keys). When false, only AAD auth is allowed."
  type        = bool
  default     = false
}

variable "location" {
  description = "Azure region for the workspace (e.g., 'australiaeast')."
  type        = string

  validation {
    condition     = can(regex("^[a-z]+[a-z0-9]*$", var.location))
    error_message = "variable value does not match the validator"
  }
}

variable "project" {
  description = "Project name for F03 tags."
  type        = string
  default     = null
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

variable "reservation_capacity_in_gb_per_day" {
  description = "Capacity reservation in GB/day. Only used when SKU is CapacityReservation."
  type        = number
  default     = null

  validation {
    condition     = var.reservation_capacity_in_gb_per_day == null ? true : contains([100, 200, 300, 400, 500, 1000, 2000, 5000], var.reservation_capacity_in_gb_per_day)
    error_message = "variable value does not match the validator"
  }
}

variable "resource_group_name" {
  description = "Name of the resource group where the workspace will be created."
  type        = string
}

variable "retention_in_days" {
  description = "Interactive retention period in days (30-730). Data within this period is immediately queryable."
  type        = number
  default     = 90

  validation {
    condition     = var.retention_in_days >= 30 && var.retention_in_days <= 730
    error_message = "variable value does not match the validator"
  }
}

variable "secondary_location" {
  description = "Secondary region for DR workspace."
  type        = string
  default     = "australiasoutheast"
}

variable "secondary_retention_in_days" {
  description = "Retention for secondary workspace (can be lower for cost optimization)."
  type        = number
  default     = 30
}

variable "sku" {
  description = "SKU of the workspace: PerGB2018 or CapacityReservation."
  type        = string
  default     = "PerGB2018"

  validation {
    condition     = contains(["PerGB2018", "CapacityReservation"], var.sku)
    error_message = "variable value does not match the validator"
  }
}

variable "solutions" {
  description = "List of solutions to deploy."
  type = list(object({
    name      = string
    publisher = string
  }))
  default = [{ "name" : "SecurityInsights", "publisher" : "Microsoft" }, { "name" : "AzureActivity", "publisher" : "Microsoft" }, { "name" : "VMInsights", "publisher" : "Microsoft" }, { "name" : "Updates", "publisher" : "Microsoft" }, { "name" : "ChangeTracking", "publisher" : "Microsoft" }, { "name" : "ServiceMap", "publisher" : "Microsoft" }, { "name" : "AgentHealthAssessment", "publisher" : "Microsoft" }]
}

variable "tags" {
  description = "Tags to apply to all resources created by this module."
  type        = map(string)
  default     = {}
}

variable "total_retention_in_days" {
  description = "Total retention period including archive (90-2556 days / ~7 years)."
  type        = number
  default     = 400

  validation {
    condition     = var.total_retention_in_days >= 90 && var.total_retention_in_days <= 2556
    error_message = "variable value does not match the validator"
  }
}

variable "workload" {
  description = "Workload name for resource naming via F02 module (e.g., 'platform', 'management')."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]+(-[a-z0-9]+)*$", var.workload)) && length(var.workload) >= 2 && length(var.workload) <= 30
    error_message = "variable value does not match the validator"
  }
}


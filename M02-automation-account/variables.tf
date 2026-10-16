variable "Brainboard_IP_Range_List" {
  type    = list(string)
  default = ["3.18.12.57", "3.19.117.9", "3.12.21.31", "3.140.65.244", "18.223.219.168", "3.139.254.14", "3.109.176.247", "13.235.196.228", "3.108.102.235", "35.154.77.165", "159.196.14.175/32"]
}

variable "create_la_linked_service" {
  description = "Create the linked service between Automation Account and Log Analytics workspace."
  type        = bool
  default     = true
}

variable "credentials" {
  description = "Map of credentials to store securely in the Automation Account."
  type = map(object({
    username    = string
    password    = string
    description = optional(string)
  }))
  default   = {}
  sensitive = true
}

variable "custom_name" {
  description = "Custom name for Automation Account (bypasses F02 naming). Use sparingly for legacy resources."
  type        = string
  default     = null
}

variable "diagnostic_log_categories" {
  description = "Log categories to enable for diagnostics."
  type        = list(string)
  default     = ["JobLogs", "JobStreams", "DscNodeStatus", "AuditEvent"]
}

variable "diagnostic_metric_categories" {
  description = "Metric categories to enable for diagnostics."
  type        = list(string)
  default     = ["AllMetrics"]
}

variable "diagnostic_storage_account_id" {
  description = "Storage account ID for diagnostic logs archival."
  type        = string
  default     = null
}

variable "dsc_configurations" {
  description = "Map of DSC configurations to import."
  type = map(object({
    content_embedded = string
    description      = optional(string)
  }))
  default = {}
}

variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for the Automation Account."
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

variable "identity_ids" {
  description = "List of User Assigned Managed Identity IDs. Required if identity_type includes 'UserAssigned'."
  type        = list(string)
  default     = []
}

variable "identity_type" {
  description = "Type of managed identity: 'SystemAssigned', 'UserAssigned', or 'SystemAssigned, UserAssigned'."
  type        = string
  default     = "SystemAssigned"

  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "variable value does not match the validator"
  }
}

variable "instance" {
  description = "Instance number for multiple resources (e.g., '001')."
  type        = string
  default     = "001"
}

variable "local_authentication_enabled" {
  description = "Enable local authentication (shared keys). Disable for zero-trust environments."
  type        = bool
  default     = true
}

variable "location" {
  description = "Azure region for the Automation Account. Should match Log Analytics for linking."
  type        = string
}

variable "log_analytics_resource_group_name" {
  description = "Resource group name of the Log Analytics workspace (for linked service)."
  type        = string
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace to link for Update Management and Change Tracking."
  type        = string
  default     = null

  validation {
    condition     = var.log_analytics_workspace_id == null || can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/[^/]+/providers/Microsoft.OperationalInsights/workspaces/[^/]+$", var.log_analytics_workspace_id))
    error_message = "variable value does not match the validator"
  }
}

variable "powershell_modules" {
  description = "Map of PowerShell modules to import from PowerShell Gallery."
  type = map(object({
    uri     = string
    version = optional(string)
  }))
  default = {}
}

variable "public_network_access_enabled" {
  description = "Allow public network access to the Automation Account. Set to false for private-only."
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

variable "resource_group_name" {
  description = "Name of the resource group where the Automation Account will be created."
  type        = string
}

variable "runbooks" {
  description = "Map of PowerShell or Python runbooks to create."
  type = map(object({
    runbook_type = string
    description  = optional(string)
    content      = optional(string)
    uri          = optional(string)
    version      = optional(string)
    hash_value   = optional(string)
    tags         = optional(map(string))
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.runbooks : contains(["PowerShell", "PowerShell72", "Python3", "Graph", "PowerShellWorkflow"], v.runbook_type)
    ])
    error_message = "variable value does not match the validator"
  }
}

variable "schedules" {
  description = "Map of schedules for runbook automation."
  type = map(object({
    description = optional(string)
    start_time  = string
    frequency   = string
    interval    = optional(number, 1)
    timezone    = optional(string, "UTC")
    week_days   = optional(list(string))
    month_days  = optional(list(number))
    expiry_time = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.schedules : contains(["OneTime", "Day", "Hour", "Week", "Month"], v.frequency)
    ])
    error_message = "variable value does not match the validator"
  }
}

variable "sku_name" {
  description = "SKU of the Automation Account. Only 'Basic' is currently supported by Azure."
  type        = string
  default     = "Basic"

  validation {
    condition     = var.sku_name == "Basic"
    error_message = "variable value does not match the validator"
  }
}

variable "tags" {
  description = "Tags to apply to all resources created by this module."
  type        = map(string)
  default     = {}
}

variable "variables_bool" {
  description = "Map of boolean variables to store in the Automation Account."
  type = map(object({
    value       = bool
    encrypted   = optional(bool, false)
    description = optional(string)
  }))
  default = {}
}

variable "variables_int" {
  description = "Map of integer variables to store in the Automation Account."
  type = map(object({
    value       = number
    encrypted   = optional(bool, false)
    description = optional(string)
  }))
  default = {}
}

variable "variables_string" {
  description = "Map of string variables to store in the Automation Account."
  type = map(object({
    value       = string
    encrypted   = optional(bool, false)
    description = optional(string)
  }))
  default = {}
}

variable "webhooks" {
  description = "Map of webhooks for runbook triggering."
  type = map(object({
    runbook_name        = string
    expiry_time         = string
    enabled             = optional(bool, true)
    parameters          = optional(map(string))
    run_on_worker_group = optional(string)
  }))
  default   = {}
  sensitive = true
}

variable "workload" {
  description = "Workload name for resource naming via F02 module (e.g., 'platform', 'automation')."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]+(-[a-z0-9]+)*$", var.workload)) && length(var.workload) >= 2 && length(var.workload) <= 30
    error_message = "variable value does not match the validator"
  }
}


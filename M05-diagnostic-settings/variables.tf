variable "Brainboard_IP_Range_List" {
  type    = list(string)
  default = ["3.18.12.57", "3.19.117.9", "3.12.21.31", "3.140.65.244", "18.223.219.168", "3.139.254.14", "3.109.176.247", "13.235.196.228", "3.108.102.235", "35.154.77.165", "159.196.14.175/32"]
}

variable "enabled_log_categories" {
  description = "List of log categories to enable. If empty or null, all available log categories will be enabled. Use ['none'] to disable all logs."
  type        = list(string)
  default     = null
}

variable "enabled_metric_categories" {
  description = "List of metric categories to enable. If empty or null, all available metric categories will be enabled. Use ['none'] to disable all metrics."
  type        = list(string)
  default     = null
}

variable "eventhub_authorization_rule_id" {
  description = "The ID of the Event Hub authorization rule to stream diagnostics to. If not specified, logs/metrics will not be streamed to Event Hub."
  type        = string
  default     = null
}

variable "eventhub_name" {
  description = "The name of the Event Hub to stream diagnostics to. Required if eventhub_authorization_rule_id is specified."
  type        = string
  default     = null
}

variable "log_analytics_destination_type" {
  description = "When set to 'Dedicated' logs sent to Log Analytics will go into resource specific tables, instead of the legacy AzureDiagnostics table. Valid values: 'Dedicated', 'AzureDiagnostics', null."
  type        = string
  default     = "Dedicated"

  validation {
    condition     = var.log_analytics_destination_type == null || contains(["Dedicated", "AzureDiagnostics"], var.log_analytics_destination_type)
    error_message = "variable value does not match the validator"
  }
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace to send diagnostics to. If not specified, logs/metrics will not be sent to Log Analytics."
  type        = string
  default     = null
}

variable "logs_retention_days" {
  description = "The number of days to retain logs in the destination. Use 0 for unlimited retention. Note: This applies to Storage Account destination only; Log Analytics retention is configured at the workspace level."
  type        = number
  default     = 90

  validation {
    condition     = var.logs_retention_days >= 0 && var.logs_retention_days <= 365
    error_message = "variable value does not match the validator"
  }
}

variable "metrics_retention_days" {
  description = "The number of days to retain metrics in the destination. Use 0 for unlimited retention. Note: This applies to Storage Account destination only."
  type        = number
  default     = 90

  validation {
    condition     = var.metrics_retention_days >= 0 && var.metrics_retention_days <= 365
    error_message = "variable value does not match the validator"
  }
}

variable "name" {
  description = "The name of the diagnostic setting. If not specified, will be auto-generated as 'diag-<resource-name>'."
  type        = string
  default     = null
}

variable "storage_account_id" {
  description = "The ID of the Storage Account to archive diagnostics to. If not specified, logs/metrics will not be archived to storage."
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the diagnostic setting resource. Will be merged with default module tags."
  type        = map(string)
  default     = {}
}

variable "target_resource_id" {
  description = "The ID of the target resource on which to configure diagnostic settings. Can be any Azure resource that supports diagnostics (VMs, VNets, NSGs, Key Vaults, etc.)."
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/.+/providers/.+/.+$", var.target_resource_id))
    error_message = "variable value does not match the validator"
  }
}


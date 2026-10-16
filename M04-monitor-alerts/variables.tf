variable "Brainboard_IP_Range_List" {
  type    = list(string)
  default = ["3.18.12.57", "3.19.117.9", "3.12.21.31", "3.140.65.244", "18.223.219.168", "3.139.254.14", "3.109.176.247", "13.235.196.228", "3.108.102.235", "35.154.77.165", "159.196.14.175/32"]
}

variable "action_group_ids" {
  description = "Map of action group IDs by severity key from M03 module. Expected keys: critical, warning, info, security, backup, network."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for key in keys(var.action_group_ids) :
      contains(["critical", "warning", "info", "security", "backup", "network"], key)
    ])
    error_message = "variable value does not match the validator"
  }
}

variable "activity_log_admin_alert_config" {
  description = "Configuration for Activity Log Administrative alerts (delete operations)."
  type = object({
    enabled     = optional(bool, true)
    name        = optional(string, "Critical Resource Deletion Alert")
    description = optional(string, "Alert for delete operations on critical resources")
    operation_names = optional(list(string), [
      "Microsoft.Resources/subscriptions/resourceGroups/delete",
      "Microsoft.Compute/virtualMachines/delete",
      "Microsoft.Sql/servers/delete",
      "Microsoft.Storage/storageAccounts/delete",
      "Microsoft.KeyVault/vaults/delete",
      "Microsoft.Network/virtualNetworks/delete",
      "Microsoft.RecoveryServices/vaults/delete"
    ])
    severity = optional(string, "warning")
  })
  default = {}
}

variable "activity_log_security_alert_config" {
  description = "Configuration for Activity Log Security alerts (policy violations)."
  type = object({
    enabled     = optional(bool, true)
    name        = optional(string, "Security Policy Violation Alert")
    description = optional(string, "Alert for security-related events and policy violations")
    operation_names = optional(list(string), [
      "Microsoft.Authorization/policyAssignments/delete",
      "Microsoft.Authorization/policyExemptions/write",
      "Microsoft.Security/securityContacts/delete",
      "Microsoft.Security/pricings/write"
    ])
    categories = optional(list(string), ["Security", "Policy"])
    severity   = optional(string, "security")
  })
  default = {}
}

variable "create_default_alerts" {
  description = "Create default platform alerts (Service Health, Resource Health, Activity Log)."
  type        = bool
  default     = true
}

variable "custom_activity_log_alerts" {
  description = "Map of custom Activity Log alerts to create."
  type = map(object({
    description       = optional(string, "Custom Activity Log Alert")
    enabled           = optional(bool, true)
    scopes            = optional(list(string), [])
    operation_name    = optional(string, null)
    category          = optional(string, "Administrative")
    level             = optional(string, null)
    status            = optional(string, null)
    resource_provider = optional(string, null)
    resource_type     = optional(string, null)
    resource_group    = optional(string, null)
    resource_id       = optional(string, null)
    caller            = optional(string, null)
    severity          = optional(string, "warning")
    action_group_ids  = optional(list(string), [])
  }))
  default = {}
}

variable "custom_log_query_alerts" {
  description = "Map of custom Log Analytics query alerts to create."
  type = map(object({
    description                       = optional(string, "Custom Log Query Alert")
    enabled                           = optional(bool, true)
    location                          = optional(string, "australiaeast")
    scopes                            = list(string)
    severity_level                    = optional(number, 2)
    evaluation_frequency              = optional(string, "PT5M")
    window_duration                   = optional(string, "PT15M")
    query                             = string
    threshold                         = optional(number, 0)
    operator                          = optional(string, "GreaterThan")
    time_aggregation_method           = optional(string, "Count")
    metric_measure_column             = optional(string, null)
    resource_id_column                = optional(string, null)
    auto_mitigation_enabled           = optional(bool, true)
    workspace_alerts_storage_enabled  = optional(bool, false)
    skip_query_validation             = optional(bool, false)
    mute_actions_after_alert_duration = optional(string, null)
    dimension = optional(list(object({
      name     = string
      operator = string
      values   = list(string)
    })), [])
    failing_periods = optional(object({
      minimum_failing_periods_to_trigger_alert = number
      number_of_evaluation_periods             = number
    }), null)
    severity         = optional(string, "warning")
    action_group_ids = optional(list(string), [])
  }))
  default = {}
}

variable "custom_metric_alerts" {
  description = "Map of custom metric alerts to create."
  type = map(object({
    description              = optional(string, "Custom Metric Alert")
    enabled                  = optional(bool, true)
    scopes                   = list(string)
    severity_level           = optional(number, 2)
    frequency                = optional(string, "PT5M")
    window_size              = optional(string, "PT15M")
    auto_mitigate            = optional(bool, true)
    target_resource_type     = optional(string, null)
    target_resource_location = optional(string, null)
    criteria = list(object({
      metric_namespace       = string
      metric_name            = string
      aggregation            = string
      operator               = string
      threshold              = number
      skip_metric_validation = optional(bool, false)
      dimension = optional(list(object({
        name     = string
        operator = string
        values   = list(string)
      })), [])
    }))
    dynamic_criteria = optional(list(object({
      metric_namespace         = string
      metric_name              = string
      aggregation              = string
      operator                 = string
      alert_sensitivity        = string
      evaluation_total_count   = optional(number, 4)
      evaluation_failure_count = optional(number, 4)
      ignore_data_before       = optional(string, null)
      skip_metric_validation   = optional(bool, false)
      dimension = optional(list(object({
        name     = string
        operator = string
        values   = list(string)
      })), [])
    })), [])
    severity         = optional(string, "warning")
    action_group_ids = optional(list(string), [])
  }))
  default = {}
}

variable "custom_name_prefix" {
  description = "Custom name prefix for alerts (bypasses F02 naming if set)."
  type        = string
  default     = null
}

variable "default_scopes" {
  description = "Full resource IDs to use as alert scopes. Takes precedence over subscription_ids. If empty, falls back to subscription_ids or current subscription."
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "Environment for naming and tagging. Valid values: prod, nonprod, dev, test, sandbox."
  type        = string

  validation {
    condition     = contains(["prod", "nonprod", "dev", "test", "sandbox"], var.environment)
    error_message = "variable value does not match the validator"
  }
}

variable "instance" {
  description = "Instance number for multiple resources (e.g., '001', '002')."
  type        = string
  default     = "001"
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace for log-based alerts (from M01 module output)."
  type        = string
  default     = null
}

variable "region" {
  description = "Azure region abbreviation for naming (e.g., 'aue' for Australia East)."
  type        = string
  default     = "aue"
}

variable "resource_group_name" {
  description = "Name of the resource group where alerts will be created."
  type        = string
}

variable "resource_health_alert_config" {
  description = "Configuration for Resource Health alerts."
  type = object({
    enabled         = optional(bool, true)
    name            = optional(string, "Resource Health Alert")
    description     = optional(string, "Alert for Azure resource health degradation")
    current_states  = optional(list(string), ["Degraded", "Unavailable"])
    previous_states = optional(list(string), ["Available"])
    reason_types    = optional(list(string), ["PlatformInitiated", "Unknown"])
    severity        = optional(string, "warning")
  })
  default = {}
}

variable "service_health_alert_config" {
  description = "Configuration for Service Health alerts."
  type = object({
    enabled     = optional(bool, true)
    name        = optional(string, "Service Health Alert")
    description = optional(string, "Alert for Azure service health incidents and maintenance")
    event_types = optional(list(string), ["Incident", "Maintenance"])
    regions     = optional(list(string), ["Australia East", "Australia Southeast", "Global"])
    services    = optional(list(string), [])
    severity    = optional(string, "critical")
  })
  default = {}
}

variable "severity_action_group_mapping" {
  description = "Custom mapping of severity levels to action group keys. Defaults use standard mapping."
  type        = map(string)
  default = {
    backup   = "backup"
    critical = "critical"
    high     = "critical"
    info     = "info"
    low      = "info"
    medium   = "warning"
    network  = "network"
    security = "security"
    warning  = "warning"
  }
}

variable "subscription_ids" {
  description = "List of subscription IDs to monitor. If empty and default_scopes is empty, uses current subscription from provider context."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for id in var.subscription_ids :
      can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", id))
    ])
    error_message = "variable value does not match the validator"
  }
}

variable "tags" {
  description = "Tags to apply to all resources created by this module."
  type        = map(string)
  default     = {}
}

variable "workload" {
  description = "Workload name for resource naming via F02 module (e.g., 'platform', 'monitoring')."
  type        = string

  validation {
    condition     = length(var.workload) >= 2 && length(var.workload) <= 30
    error_message = "variable value does not match the validator"
  }
}


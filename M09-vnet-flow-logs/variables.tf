variable "Brainboard_IP_Range_List" {
  type    = list(string)
  default = ["3.18.12.57", "3.19.117.9", "3.12.21.31", "3.140.65.244", "18.223.219.168", "3.139.254.14", "3.109.176.247", "13.235.196.228", "3.108.102.235", "35.154.77.165", "159.196.14.175/32"]
}

variable "enable_traffic_analytics" {
  description = "Enable Traffic Analytics integration with Log Analytics."
  type        = bool
  default     = true
}

variable "flow_log_configurations" {
  description = "Map of VNet flow log configurations. Key = unique identifier, value = flow log settings."
  type = map(object({
    name               = string
    target_resource_id = string
    enabled            = optional(bool, true)
  }))
}

variable "network_watcher_name" {
  description = "Name of the Network Watcher resource."
  type        = string
}

variable "network_watcher_resource_group_name" {
  description = "Resource group name of the Network Watcher."
  type        = string
}

variable "retention_days" {
  description = "Number of days to retain flow log data in storage account."
  type        = number
  default     = 90
}

variable "retention_policy_enabled" {
  description = "Enable retention policy for flow logs."
  type        = bool
  default     = true
}

variable "storage_account_id" {
  description = "Resource ID of the storage account for flow log data."
  type        = string
}

variable "tags" {
  description = "Tags to apply to flow log resources."
  type        = map(string)
  default     = {}
}

variable "traffic_analytics_interval_minutes" {
  description = "Interval in minutes for Traffic Analytics processing (10 or 60)."
  type        = number
  default     = 10

  validation {
    condition     = contains([10, 60], var.traffic_analytics_interval_minutes)
    error_message = "variable value does not match the validator"
  }
}

variable "traffic_analytics_workspace_id" {
  description = "Workspace ID (GUID) of the Log Analytics workspace for Traffic Analytics."
  type        = string
  default     = null
}

variable "traffic_analytics_workspace_region" {
  description = "Azure region of the Log Analytics workspace."
  type        = string
  default     = null
}

variable "traffic_analytics_workspace_resource_id" {
  description = "Resource ID of the Log Analytics workspace for Traffic Analytics."
  type        = string
  default     = null
}


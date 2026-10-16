variable "Brainboard_IP_Range_List" {
  type    = list(string)
  default = ["3.18.12.57", "3.19.117.9", "3.12.21.31", "3.140.65.244", "18.223.219.168", "3.139.254.14", "3.109.176.247", "13.235.196.228", "3.108.102.235", "35.154.77.165", "159.196.14.175/32"]
}

variable "alert_rule_templates" {
  description = <<EOT
List of alert rule template GUIDs to enable.
Leave empty to skip alert rule creation.
    
Example templates:
- "5163A000-5160-5160-5160-5163A0000001" (example GUID)
EOT
  type        = list(string)
  default     = []
}

variable "customer_managed_key_enabled" {
  description = "Enable customer managed key for Sentinel."
  type        = bool
  default     = false
}

variable "data_connectors" {
  description = <<EOT
Map of data connectors to enable.
    
IMPORTANT LICENSING NOTES:
- azure_active_directory: Requires Azure AD Premium P1/P2 or Microsoft 365 E5
- office_365: Requires Office 365 license
- microsoft_365_defender: Requires Microsoft 365 E5 or Microsoft 365 E5 Security
- azure_advanced_threat_protection: Requires Microsoft Defender for Identity license
    
Without appropriate licenses, enabling these connectors will fail.
EOT
  type = object({
    azure_active_directory           = optional(bool, false)
    azure_activity                   = optional(bool, true)
    defender_for_cloud               = optional(bool, true)
    threat_intelligence              = optional(bool, true)
    microsoft_cloud_app_security     = optional(bool, false)
    office_365                       = optional(bool, false)
    microsoft_365_defender           = optional(bool, false)
    azure_advanced_threat_protection = optional(bool, false)
    microsoft_business_applications  = optional(bool, false)
    windows_security_events          = optional(bool, false) # Configured via AMA DCR
    syslog_via_ama                   = optional(bool, false) # Configured via AMA DCR
    entra_id_protection              = optional(bool, false) # Deployed via azapi in orchestrator
    azure_sql_database               = optional(bool, false) # Via diagnostic settings
    misp2sentinel                    = optional(bool, false) # Requires Logic App deployment
    windows_server_dns               = optional(bool, false) # Configured via AMA DCR
    network_security_groups          = optional(bool, false) # Via NSG Flow Logs
  })
  default = {

    azure_active_directory           = false # Requires license
    azure_activity                   = true
    defender_for_cloud               = true
    threat_intelligence              = true
    microsoft_cloud_app_security     = false # Requires license
    office_365                       = false # Requires license
    microsoft_365_defender           = false # Requires license
    azure_advanced_threat_protection = false # Requires license
    microsoft_business_applications  = false # Requires Dynamics 365 license
    windows_security_events          = false # Via AMA DCR
    syslog_via_ama                   = false # Via AMA DCR
    entra_id_protection              = false # Via azapi in orchestrator
    azure_sql_database               = false # Via diagnostic settings
    misp2sentinel                    = false # Via Logic App
    windows_server_dns               = false # Via AMA DCR
    network_security_groups          = false # Via NSG Flow Logs
  }
}

variable "defender_for_cloud_subscriptions" {
  description = "Map of subscription name => subscription ID for Defender for Cloud connector. Creates one connector per subscription."
  type        = map(string)
  default     = {}
}

variable "enable_default_alert_rules" {
  description = "Enable recommended Sentinel alert rules from templates."
  type        = bool
  default     = false
}

variable "enable_ueba" {
  description = "Enable User and Entity Behavior Analytics (UEBA)."
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace to onboard Sentinel to."
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/[^/]+/providers/Microsoft.OperationalInsights/workspaces/[^/]+$", var.log_analytics_workspace_id))
    error_message = "variable value does not match the validator"
  }
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group containing the Log Analytics Workspace."
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources that support tagging."
  type        = map(string)
  default     = {}
}

variable "ueba_data_sources" {
  description = "Data sources for UEBA. Possible values: AuditLogs, AzureActivity, SecurityEvent, SigninLogs."
  type        = list(string)
  default     = ["AuditLogs", "AzureActivity", "SigninLogs"]

  validation {
    condition     = alltrue([for source in var.ueba_data_sources : contains(["AuditLogs", "AzureActivity", "SecurityEvent", "SigninLogs"], source)])
    error_message = "variable value does not match the validator"
  }
}

variable "watchlists" {
  description = <<EOT
Map of watchlists to create.
    
Example:
{
  high_value_assets = {
    display_name = "High Value Assets"
    description  = "List of critical business assets"
    item_search_key = "AssetName"
    source       = "Local"
  }
}
EOT
  type = map(object({
    display_name    = string
    description     = optional(string, "")
    item_search_key = string
    source          = optional(string, "Local")
    labels          = optional(list(string), [])
  }))
  default = {}
}


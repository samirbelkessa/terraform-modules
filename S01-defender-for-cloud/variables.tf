variable "Brainboard_IP_Range_List" {
  type    = list(string)
  default = ["3.18.12.57", "3.19.117.9", "3.12.21.31", "3.140.65.244", "18.223.219.168", "3.139.254.14", "3.109.176.247", "13.235.196.228", "3.108.102.235", "35.154.77.165", "159.196.14.175/32"]
}

variable "alert_notifications_min_severity" {
  description = "Minimum severity level for alert notifications."
  type        = string
  default     = "Medium"

  validation {
    condition     = contains(["Low", "Medium", "High"], var.alert_notifications_min_severity)
    error_message = "variable value does not match the validator"
  }
}

variable "alert_notifications_state" {
  description = "Enable email notifications for security alerts."
  type        = string
  default     = "On"

  validation {
    condition     = contains(["On", "Off"], var.alert_notifications_state)
    error_message = "variable value does not match the validator"
  }
}

variable "alerts_to_admins_state" {
  description = "Send security alerts to subscription admins."
  type        = string
  default     = "On"

  validation {
    condition     = contains(["On", "Off"], var.alerts_to_admins_state)
    error_message = "variable value does not match the validator"
  }
}

variable "auto_provisioning_identity_type" {
  description = "Identity type for auto-provisioning. Possible values: SystemAssigned, UserAssigned."
  type        = string
  default     = "SystemAssigned"

  validation {
    condition     = contains(["SystemAssigned", "UserAssigned"], var.auto_provisioning_identity_type)
    error_message = "variable value does not match the validator"
  }
}

variable "defender_plans" {
  description = <<EOT
Map of Defender plans to enable with their configuration.
    
Supported plans:
- VirtualMachines: Server protection (P1 = basic, P2 = with EDR)
- StorageAccounts: Storage threat protection
- SqlServers: SQL Server protection
- SqlServerVirtualMachines: SQL on VMs
- AppServices: App Service protection
- KeyVaults: Key Vault protection
- Arm: Azure Resource Manager protection
- Dns: DNS protection
- Containers: Container protection
- OpenSourceRelationalDatabases: OSS databases protection
- CosmosDbs: Cosmos DB protection
- CloudPosture: CSPM features
EOT
  type = map(object({
    enabled = bool
    subplan = optional(string, null)
  }))
  default = {
    AI = {
      enabled = true
      subplan = null
    }
    Api = {
      enabled = true
      subplan = null
    }
    AppServices = {
      enabled = true
      subplan = null
    }
    Arm = {
      enabled = true
      subplan = "PerApiCall"
    }
    CloudPosture = {
      enabled = true
      subplan = null
    }
    Containers = {
      enabled = true
      subplan = null
    }
    CosmosDbs = {
      enabled = true
      subplan = null
    }
    Dns = {
      enabled = true
      subplan = null
    }
    KeyVaults = {
      enabled = true
      subplan = null
    }
    OpenSourceRelationalDatabases = {
      enabled = true
      subplan = null
    }
    SqlServerVirtualMachines = {
      enabled = true
      subplan = null
    }
    SqlServers = {
      enabled = true
      subplan = null
    }
    StorageAccounts = {
      enabled = true
      subplan = "DefenderForStorageV2"
    }
    VirtualMachines = {
      enabled = true
      subplan = "P2"
    }
  }
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace for Defender data export."
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/[^/]+/providers/Microsoft.OperationalInsights/workspaces/[^/]+$", var.log_analytics_workspace_id))
    error_message = "variable value does not match the validator"
  }
}

variable "security_contact_email" {
  description = "Email address for security alerts notifications."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.security_contact_email))
    error_message = "variable value does not match the validator"
  }
}

variable "security_contact_name" {
  description = "Name of the security contact."
  type        = string
  default     = "Security Team"
}

variable "security_contact_phone" {
  description = "Phone number for security alerts notifications."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources that support tagging."
  type        = map(string)
  default     = {}
}


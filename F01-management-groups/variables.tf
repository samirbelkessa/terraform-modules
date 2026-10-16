variable "Brainboard_IP_Range_List" {
  type    = list(string)
  default = ["3.18.12.57", "3.19.117.9", "3.12.21.31", "3.140.65.244", "18.223.219.168", "3.139.254.14", "3.109.176.247", "13.235.196.228", "3.108.102.235", "35.154.77.165", "159.196.14.175/32"]
}

variable "custom_landing_zone_children" {
  description = "Map of custom child management groups to create under Landing Zones. Key is the MG ID suffix, value contains display_name."
  type = map(object({
    display_name = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.custom_landing_zone_children : can(regex("^[a-zA-Z0-9-_]+$", k))
    ])
    error_message = "variable value does not match the validator"
  }
}

variable "custom_platform_children" {
  description = "Map of custom child management groups to create under Platform. Key is the MG ID suffix, value contains display_name."
  type = map(object({
    display_name = string
  }))
  default = {}
}

variable "default_location" {
  description = "Default Azure region for management group operations metadata."
  type        = string
  default     = "australiaeast"
}

variable "deploy_corp_landing_zones" {
  description = "Deploy Corp landing zone archetypes (Corp-Prod and Corp-NonProd for internal workloads)."
  type        = bool
  default     = true
}

variable "deploy_decommissioned_mg" {
  description = "Deploy the Decommissioned management group for resources pending deletion."
  type        = bool
  default     = true
}

variable "deploy_landing_zones_mg" {
  description = "Deploy the Landing Zones management group and its children (Corp, Online, Sandbox archetypes)."
  type        = bool
  default     = true
}

variable "deploy_online_landing_zones" {
  description = "Deploy Online landing zone archetypes (Online-Prod and Online-NonProd for internet-facing workloads)."
  type        = bool
  default     = true
}

variable "deploy_platform_mg" {
  description = "Deploy the Platform management group and its children (Management, Connectivity, Identity)."
  type        = bool
  default     = true
}

variable "deploy_prod_nonprod_separation" {
  description = "Create separate Prod and NonProd management groups for each archetype. If false, creates single Corp and Online MGs."
  type        = bool
  default     = true
}

variable "deploy_sandbox_mg" {
  description = "Deploy the Sandbox management group under Landing Zones."
  type        = bool
  default     = true
}

variable "root_id" {
  description = "ID/Name for the root intermediate management group. Used in resource naming."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.root_id)) && length(var.root_id) >= 2 && length(var.root_id) <= 90
    error_message = "variable value does not match the validator"
  }
}

variable "root_name" {
  description = "Display name for the root intermediate management group (e.g., 'Contoso' or organization name)."
  type        = string

  validation {
    condition     = length(var.root_name) >= 2 && length(var.root_name) <= 90
    error_message = "variable value does not match the validator"
  }
}

variable "root_parent_id" {
  description = "The ID of the Tenant Root Group or parent management group. Use data.azurerm_client_config.current.tenant_id for tenant root."
  type        = string
  default     = "01c40c02-a3ca-49b1-a844-dd9c825be5eb"

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.root_parent_id)) || can(regex("^/providers/Microsoft.Management/managementGroups/", var.root_parent_id))
    error_message = "variable value does not match the validator"
  }
}

variable "subscription_ids_by_mg" {
  description = "Map of management group names to lists of subscription IDs to associate. Useful for initial brownfield migration."
  type        = map(list(string))
  default     = {}

  validation {
    condition = alltrue(flatten([
      for mg, subs in var.subscription_ids_by_mg : [
        for sub in subs : can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", sub))
      ]
    ]))
    error_message = "variable value does not match the validator"
  }
}

variable "timeouts" {
  description = "Timeout configuration for management group operations."
  type = object({
    create = optional(string, "30m")
    read   = optional(string, "5m")
    update = optional(string, "30m")
    delete = optional(string, "30m")
  })
  default = {}
}


variable "Brainboard_IP_Range_List" {
  type    = list(string)
  default = ["3.18.12.57", "3.19.117.9", "3.12.21.31", "3.140.65.244", "18.223.219.168", "3.139.254.14", "3.109.176.247", "13.235.196.228", "3.108.102.235", "35.154.77.165", "159.196.14.175/32"]
}

variable "authorizations" {
  description = "List of permanent RBAC authorizations for the MSP."
  type = list(object({
    principal_id           = string
    role_definition_id     = string
    principal_display_name = string
  }))

  validation {
    condition     = length(var.authorizations) > 0
    error_message = "variable value does not match the validator"
  }
}

variable "eligible_authorizations" {
  description = "List of eligible (Just-In-Time) RBAC authorizations for the MSP. Requires MFA activation."
  type = list(object({
    principal_id                = string
    role_definition_id          = string
    principal_display_name      = string
    multi_factor_auth_provider  = optional(string, "Azure")
    maximum_activation_duration = optional(string, "PT4H")
    approvers = optional(list(object({
      principal_id           = string
      principal_display_name = optional(string, null)
    })), [])
  }))
  default = []
}

variable "enable_lighthouse" {
  description = "Enable or disable Lighthouse MSP delegation. When false, no resources are created."
  type        = bool
  default     = false
}

variable "managing_tenant_id" {
  description = "Tenant ID of the managing MSP (service provider)."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.managing_tenant_id))
    error_message = "variable value does not match the validator"
  }
}

variable "msp_offer_description" {
  description = "Description of the Lighthouse managed service offer."
  type        = string
  default     = ""
}

variable "msp_offer_name" {
  description = "Display name of the Lighthouse managed service offer."
  type        = string
}

variable "subscription_ids" {
  description = "Map of subscription names to subscription IDs for Lighthouse assignment."
  type        = map(string)

  validation {
    condition     = length(var.subscription_ids) > 0
    error_message = "variable value does not match the validator"
  }
}


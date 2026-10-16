variable "Brainboard_IP_Range_List" {
  type    = list(string)
  default = ["3.18.12.57", "3.19.117.9", "3.12.21.31", "3.140.65.244", "18.223.219.168", "3.139.254.14", "3.109.176.247", "13.235.196.228", "3.108.102.235", "35.154.77.165", "159.196.14.175/32"]
}

variable "billing_account_name" {
  description = "The name of the billing account. For EA: enrollment account name. For MCA: billing account ID."
  type        = string
}

variable "billing_profile_name" {
  description = "Billing profile name for MCA billing"
  type        = string
  default     = ""
}

variable "billing_scope" {
  description = "Legacy - Use billing_type instead. Kept for backward compatibility."
  type        = string
  default     = ""
}

variable "billing_type" {
  description = "Type of billing: MCA or MPA"
  type        = string
  default     = "MCA"

  validation {
    condition     = contains(["MCA", "MPA"], var.billing_type)
    error_message = "variable value does not match the validator"
  }
}

variable "custom_rg_names" {
  type    = map(string)
  default = {}
}

variable "customer_name" {
  description = "Customer name for MPA billing (required if billing_type = MPA)"
  type        = string
  default     = ""
}

variable "default_location" {
  description = "Default location for resource groups."
  type        = string
  default     = "australiaeast"
}

variable "default_role_assignments" {
  description = "Default role assignments to apply to all subscriptions."
  type = map(object({
    role_definition_name = string
    principal_id         = string
    principal_type       = optional(string, "Group") # User, Group, ServicePrincipal
  }))
  default = {}
}

variable "default_tags" {
  description = "Default tags to apply to all subscriptions."
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Module    = "L01-subscription-vending"
  }
}

variable "deployment_mode" {
  description = "Deployment mode: greenfield (create new subs), brownfield (use existing subs), or hybrid (both)"
  type        = string
  default     = "hybrid"

  validation {
    condition     = contains(["greenfield", "brownfield", "hybrid"], var.deployment_mode)
    error_message = "variable value does not match the validator"
  }
}

variable "enable_subscription_placement" {
  description = "Enable automatic placement of subscriptions into management groups."
  type        = bool
  default     = true
}

variable "enable_tas_naming" {
  type    = bool
  default = false
}

variable "existing_subscriptions" {
  description = <<EOT
Map of existing subscriptions to place into management groups (brownfield scenario).
Use this to move existing subscriptions without creating new ones.
EOT
  type = map(object({
    subscription_id = string
    archetype       = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.existing_subscriptions : can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", v.subscription_id))
    ])
    error_message = "variable value does not match the validator"
  }
}

variable "invoice_section_name" {
  description = "Invoice section name for MCA billing"
  type        = string
  default     = ""
}

variable "management_group_ids" {
  description = <<EOT
Map of management group IDs from F01 module outputs. Expected keys:
- root, platform, management, connectivity, identity
- landing_zones, corp_prod, corp_nonprod, online_prod, online_nonprod
- sandbox, decommissioned
    
Pass module.management_groups.all_mg_ids or data.terraform_remote_state.foundation.outputs.all_mg_ids
EOT
  type        = map(string)

  validation {
    condition     = contains(keys(var.management_group_ids), "root")
    error_message = "variable value does not match the validator"
  }
}

variable "required_providers" {
  description = "List of Azure resource provider namespaces to register on all subscriptions."
  type        = list(string)
  default     = ["Microsoft.Cache", "Microsoft.Capacity", "Microsoft.Compute", "Microsoft.ContainerService", "Microsoft.EventHub", "Microsoft.KeyVault", "Microsoft.ManagedIdentity", "Microsoft.Network", "Microsoft.OperationalInsights", "Microsoft.OperationsManagement", "Microsoft.Resources", "Microsoft.Storage", "Microsoft.Sql", "Microsoft.Authorization", "Microsoft.Insights", "Microsoft.Security", "Microsoft.Advisor", "Microsoft.AlertsManagement", "Microsoft.RecoveryServices", "Microsoft.PolicyInsights"]
}

variable "resource_groups" {
  description = "Resource groups to create. Key format: subscription_key.rg_key"
  type = map(object({
    location = optional(string, null)
    tags     = optional(map(string), {})
  }))
  default = {}
}

variable "root_id" {
  description = "Root ID for naming convention."
  type        = string
  default     = ""
}

variable "subscription_alias_prefix" {
  description = "Prefix for subscription alias names."
  type        = string
  default     = "sub"
}

variable "subscriptions" {
  description = <<EOT
Map of subscriptions to create. Each subscription requires:
- display_name: The display name of the subscription
- archetype: The landing zone archetype (determines MG placement)
- workload_type: Production or DevTest (affects pricing)
- owner_object_id: Azure AD Object ID of the initial owner
    
Optional:
- tags: Additional tags for the subscription
- budget: Budget configuration
EOT
  type = map(object({
    display_name    = string
    archetype       = string                         # corp_prod, corp_nonprod, online_prod, online_nonprod, sandbox, management, connectivity, identity
    workload_type   = optional(string, "Production") # Production or DevTest
    owner_object_id = optional(string, null)

    tags = optional(map(string), {})

    budget = optional(object({
      amount     = number
      time_grain = optional(string, "Monthly")
      start_date = optional(string, null)
      end_date   = optional(string, null)
      notifications = optional(map(object({
        enabled        = optional(bool, true)
        threshold      = number
        operator       = optional(string, "GreaterThan")
        contact_emails = optional(list(string), [])
        contact_roles  = optional(list(string), ["Owner"])
      })), {})
    }), null)
  }))

  validation {
    condition = alltrue([
      for k, v in var.subscriptions :
      contains([
        "corp_prod", "corp_nonprod", "online_prod", "online_nonprod",
        "sandbox", "management", "connectivity", "identity",
        "landing_zones", "platform", "decommissioned", "root"
      ], v.archetype) &&
      contains(["Production", "DevTest"], v.workload_type)
    ])
    error_message = "variable value does not match the validator"
  }
}

variable "wait_for_subscription_creation" {
  description = "Time to wait after subscription creation before placement (handles Azure propagation delays)."
  type        = string
  default     = "60s"
}


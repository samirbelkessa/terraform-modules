variable "Brainboard_IP_Range_List" {
  type    = list(string)
  default = ["3.18.12.57", "3.19.117.9", "3.12.21.31", "3.140.65.244", "18.223.219.168", "3.139.254.14", "3.109.176.247", "13.235.196.228", "3.108.102.235", "35.154.77.165", "159.196.14.175/32"]
}

variable "additional_tags" {
  description = "Additional custom tags to merge with standard tags."
  type        = map(string)
  default     = {}
}

variable "application" {
  description = "Name of the application or workload."
  type        = string

  validation {
    condition     = length(var.application) >= 2 && length(var.application) <= 50
    error_message = "variable value does not match the validator"
  }
}

variable "archetype" {
  description = "Landing Zone archetype. Determines which policies and configurations apply. ok"
  type        = string
  default     = null
}

variable "compliance" {
  description = "Compliance frameworks applicable to the resource (comma-separated). OK"
  type        = string
  default     = null
}

variable "cost_center" {
  description = "Cost center code for billing and chargeback."
  type        = string

  validation {
    condition     = length(var.cost_center) >= 3 && length(var.cost_center) <= 20
    error_message = "variable value does not match the validator"
  }
}

variable "created_by" {
  description = "Identity or pipeline that created the resource."
  type        = string
  default     = null
}

variable "criticality" {
  description = "Business criticality level. Determines SLA, backup policies, and DR requirements."
  type        = string
  default     = "Medium"

  validation {
    condition     = contains(["Critical", "High", "Medium", "Low"], var.criticality)
    error_message = "variable value does not match the validator"
  }
}

variable "data_classification" {
  description = "Data classification for security and compliance."
  type        = string
  default     = "Internal"

  validation {
    condition     = contains(["Public", "Internal", "Confidential", "Restricted"], var.data_classification)
    error_message = "variable value does not match the validator"
  }
}

variable "department" {
  description = "Department or business unit name."
  type        = string
  default     = null

  validation {
    condition     = var.department == null || (length(var.department) >= 2 && length(var.department) <= 50)
    error_message = "variable value does not match the validator"
  }
}

variable "enforce_sandbox_expiration" {
  description = "When true, enforce expiration_date requirement for Sandbox environment."
  type        = bool
  default     = true
}

variable "environment" {
  description = "Environment name. Must be one of: Production, PreProduction, Development, Test, Sandbox, DR."
  type        = string

  validation {
    condition     = contains(["Production", "PreProduction", "Development", "Test", "Sandbox", "DR"], var.environment)
    error_message = "variable value does not match the validator"
  }
}

variable "expiration_date" {
  description = "Expiration date for temporary resources (required for Sandbox). Format: YYYY-MM-DD."
  type        = string
  default     = null

  validation {
    condition     = var.expiration_date == null || can(regex("^\\d{4}-\\d{2}-\\d{2}$", var.expiration_date))
    error_message = "variable value does not match the validator"
  }
}

variable "maintenance_window" {
  description = "Preferred maintenance window (e.g., 'Sun 02:00-06:00 AEST')."
  type        = string
  default     = null
}

variable "module_name" {
  description = "Name of the Terraform module creating this resource."
  type        = string
  default     = null
}

variable "owner" {
  description = "Email address of the resource owner (team or individual)."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.owner))
    error_message = "variable value does not match the validator"
  }
}

variable "project" {
  description = "Project name or code for grouping related resources."
  type        = string
  default     = null

  validation {
    condition     = var.project == null || (length(var.project) >= 2 && length(var.project) <= 50)
    error_message = "variable value does not match the validator"
  }
}

variable "terraform_workspace" {
  description = "Terraform workspace name (auto-populated if using workspaces)."
  type        = string
  default     = null
}


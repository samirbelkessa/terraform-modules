variable "Brainboard_IP_Range_List" {
  type    = list(string)
  default = ["3.18.12.57", "3.19.117.9", "3.12.21.31", "3.140.65.244", "18.223.219.168", "3.139.254.14", "3.109.176.247", "13.235.196.228", "3.108.102.235", "35.154.77.165", "159.196.14.175/32"]
}

variable "auto_learn_private_ranges_enabled" {
  type    = bool
  default = true
}

variable "base_policy_id" {
  type    = string
  default = null
}

variable "dns_proxy_enabled" {
  type    = bool
  default = true
}

variable "idps_mode" {
  description = "Azure Firewall IDPS mode. Valid values: Alert, Deny, Off."
  type        = string
  default     = "Alert"

  validation {
    condition     = contains(["Alert", "Deny", "Off"], var.idps_mode)
    error_message = "variable value does not match the validator"
  }
}

variable "location" {
  type    = string
  default = "australiaeast"
}

variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "sku" {
  type    = string
  default = "Premium"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "threat_intelligence_mode" {
  type    = string
  default = "Alert"
}


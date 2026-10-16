variable "Brainboard_IP_Range_List" {
  type    = list(string)
  default = ["3.18.12.57", "3.19.117.9", "3.12.21.31", "3.140.65.244", "18.223.219.168", "3.139.254.14", "3.109.176.247", "13.235.196.228", "3.108.102.235", "35.154.77.165", "159.196.14.175/32"]
}

variable "application_rules" {
  description = "Platform baseline application rules. Applied via ApplicationRuleCollectionGroup (P:300)."
  type = list(object({
    name                  = string
    destination_fqdns     = optional(list(string), [])
    destination_fqdn_tags = optional(list(string), [])
    protocols = list(object({
      type = string
      port = number
    }))
  }))
  default = []
}

variable "deploy_dnat_rules" {
  description = "Deploy DNAT rule collection group (P:100)."
  type        = bool
  default     = false
}

variable "dnat_rules" {
  description = "Platform DNAT firewall rules. Applied via DnatRuleCollectionGroup (P:100)."
  type = list(object({
    name                = string
    protocols           = list(string)
    source_addresses    = optional(list(string), ["*"])
    destination_address = string
    destination_ports   = list(string)
    translated_address  = string
    translated_port     = string
  }))
  default = []
}

variable "firewall_policy_id" {
  description = "Resource ID of the parent Azure Firewall Policy."
  type        = string
}

variable "network_rules" {
  description = "Platform baseline network rules. Applied via NetworkRuleCollectionGroup (P:200)."
  type = list(object({
    name                  = string
    protocols             = list(string)
    destination_ports     = list(string)
    destination_addresses = list(string)
  }))
  default = []
}

variable "source_addresses" {
  description = "Platform source address ranges applied to network and application rules."
  type        = list(string)
  default     = ["*"]
}


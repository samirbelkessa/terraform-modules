variable "Brainboard_IP_Range_List" {
  type    = list(string)
  default = ["3.18.12.57", "3.19.117.9", "3.12.21.31", "3.140.65.244", "18.223.219.168", "3.139.254.14", "3.109.176.247", "13.235.196.228", "3.108.102.235", "35.154.77.165", "159.196.14.175/32"]
}

variable "custom_name" {
  description = "If provided, this name will be used as-is, bypassing all naming conventions. Use sparingly for legacy or special requirements."
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment abbreviation. Valid values: 'prod', 'nonprod', 'dev', 'test', 'uat', 'stg', 'sandbox'."
  type        = string

  validation {
    condition     = contains(["prod", "nonprod", "dev", "test", "uat", "stg", "sandbox"], var.environment)
    error_message = "variable value does not match the validator"
  }
}

variable "instance" {
  description = "Instance number for multiple resources of the same type. Set to null or empty string to omit. Format: '001', '01', '1'."
  type        = string
  default     = null

  validation {
    condition     = var.instance == null || var.instance == "" || can(regex("^[0-9]+$", var.instance))
    error_message = "variable value does not match the validator"
  }
}

variable "random_suffix_length" {
  description = "Length of random suffix to add for uniqueness. Set to 0 to disable. Useful for globally unique names like Storage Accounts."
  type        = number
  default     = 0

  validation {
    condition     = var.random_suffix_length >= 0 && var.random_suffix_length <= 8
    error_message = "variable value does not match the validator"
  }
}

variable "region" {
  description = "Azure region abbreviation. Defaults to 'aue' (Australia East). Common values: 'aue' (Australia East), 'aus' (Australia Southeast), 'weu' (West Europe)."
  type        = string
  default     = "aue"

  validation {
    condition     = can(regex("^[a-z]{2,6}$", var.region))
    error_message = "variable value does not match the validator"
  }
}

variable "resource_type" {
  description = "Type of Azure resource to name. Use abbreviations matching locals.tf resource_definitions."
  type        = string

  validation {
    condition = contains([
      # Foundation
      "mg", "rg", "sub", "policy", "init", "role",

      # Networking
      "vnet", "snet", "nsg", "asg", "rt", "udr", "pip", "pipp", "lb", "lbi",
      "nat", "peer", "nic", "pdns", "pdnsz", "pdnszl",

      # Firewall & Security
      "afw", "afwp", "afwrcg", "afwrc", "waf", "wafp",

      # Gateways
      "vgw", "lgw", "cn", "ergw", "erc", "agw", "bas",

      # DNS & Traffic
      "dnsz", "traf", "fd", "cdn", "cdnep",

      # Storage
      "st", "stdiag", "dls",

      # Compute
      "vm", "vmss", "avail", "disk", "snap", "gal", "img", "ppg", "cg",

      # Containers
      "aks", "acr", "ci", "aci",

      # Databases
      "sql", "sqldb", "sqlelp", "cosmos", "mysql", "psql", "redis", "maria",

      # Security
      "kv", "id", "pep", "psc", "pls",

      # Management & Monitoring
      "log", "aa", "appi", "ag", "dcr", "dce", "ma", "diag", "budget", "lock",

      # Web & App Services
      "app", "plan", "func", "logic", "apim",

      # Backup & DR
      "rsv", "bkpol", "asr", "asrpol",

      # Integration
      "sb", "sbq", "sbt", "evh", "evhns", "eg", "egt", "egs", "relay",

      # Analytics
      "syn", "synsp", "syndp", "synlp", "adf", "adfp", "dbw", "dec", "aml",
      "amlw", "srch", "pbi", "pbie", "as",

      # IoT
      "iot", "iotc", "iotdps", "dtw", "tsi",

      # AI & ML
      "cog", "oai", "bot", "mlw",

      # Other
      "sigr", "ntf", "ntfns", "maps", "spatial", "ase", "asev3",

      # Full names (backward compatibility)
      "resource_group", "virtual_network", "subnet", "network_security_group",
      "route_table", "public_ip", "load_balancer", "application_gateway",
      "virtual_machine", "storage_account", "key_vault", "log_analytics_workspace",
      "automation_account", "recovery_services_vault", "azure_firewall",
      "azure_firewall_policy", "bastion_host", "private_endpoint",
      "private_dns_zone", "managed_identity", "action_group", "monitor_alert",
      "maintenance_configuration", "data_collection_rule", "container_registry",
      "kubernetes_cluster"
    ], var.resource_type)
    error_message = "variable value does not match the validator"
  }
}

variable "separator" {
  description = "Character to use as separator between name components. Default is hyphen. Some resources (like Storage Accounts) require no separator."
  type        = string
  default     = "-"

  validation {
    condition     = contains(["-", "", "_"], var.separator)
    error_message = "variable value does not match the validator"
  }
}

variable "suffix" {
  description = "Optional custom suffix to append to the resource name. Useful for unique identifiers or specific naming requirements."
  type        = string
  default     = null

  validation {
    condition     = var.suffix == null || can(regex("^[a-z0-9]+(-[a-z0-9]+)*$", var.suffix))
    error_message = "variable value does not match the validator"
  }
}

variable "use_slug" {
  description = "Whether to include the resource type slug/prefix in the name. Set to false for resources that don't support prefixes."
  type        = bool
  default     = true
}

variable "workload" {
  description = "Workload or application name (e.g., 'hub', 'erp', 'web'). Used as the main identifier in the resource name."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]+(-[a-z0-9]+)*$", var.workload)) && length(var.workload) >= 2 && length(var.workload) <= 30
    error_message = "variable value does not match the validator"
  }
}


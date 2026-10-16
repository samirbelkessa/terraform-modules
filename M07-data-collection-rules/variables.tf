variable "Brainboard_IP_Range_List" {
  type    = list(string)
  default = ["3.18.12.57", "3.19.117.9", "3.12.21.31", "3.140.65.244", "18.223.219.168", "3.139.254.14", "3.109.176.247", "13.235.196.228", "3.108.102.235", "35.154.77.165", "159.196.14.175/32"]
}

variable "data_collection_rule_associations" {
  description = <<EOT
Optional map of DCR associations to VMs/VMSS.
    
Leave empty ({}) for new Landing Zones - use Azure Policy (G03) instead for automatic associations.
Use this for brownfield migrations or manual associations to specific resources.
    
Structure:
{
  "association-name" = {
    target_resource_id      = "/subscriptions/.../virtualMachines/vm-01"
    data_collection_rule_id = "dcr-windows-performance"  # References key in var.data_collection_rules
    description             = "Optional description"
  }
}
EOT
  type = map(object({
    target_resource_id      = string
    data_collection_rule_id = string # Key reference to var.data_collection_rules
    description             = optional(string)
  }))
  default = {}

  validation {
    condition     = length(var.data_collection_rule_associations) >= 0
    error_message = "variable value does not match the validator"
  }
}

variable "data_collection_rules" {
  description = <<EOT
Map of Data Collection Rules to create. Structure matches azurerm_monitor_data_collection_rule.
All configurations are passed dynamically from orchestrator - NO hardcoded defaults.
    
Example structure:
{
  "dcr-windows-performance" = {
    location            = "australiaeast"
    resource_group_name = "rg-management"
    description         = "Performance counters for Windows VMs"
    kind                = "Windows"
    destinations        = { ... }
    data_sources        = { ... }
    data_flow           = [ ... ]
  }
}
EOT
  type = map(object({
    location            = string
    resource_group_name = string
    description         = optional(string)
    kind                = optional(string) # "Linux", "Windows", or null

    # Destinations - At least one required
    destinations = object({
      log_analytics = optional(map(object({
        workspace_resource_id = string
        name                  = optional(string)
      })))

      azure_monitor_metrics = optional(object({
        name = optional(string)
      }))

      storage_blob = optional(map(object({
        storage_account_id = string
        container_name     = string
        name               = optional(string)
      })))

      event_hub = optional(map(object({
        event_hub_id = string
        name         = optional(string)
      })))

      event_hub_direct = optional(map(object({
        event_hub_id = string
        name         = optional(string)
      })))
    })

    # Data flows - How data routes from sources to destinations
    data_flow = list(object({
      streams       = list(string)
      destinations  = list(string)
      transform_kql = optional(string)
      output_stream = optional(string)
    }))

    # Data sources - What to collect
    data_sources = optional(object({
      # Performance Counters (Windows/Linux)
      performance_counter = optional(list(object({
        streams                       = list(string)
        sampling_frequency_in_seconds = number
        counter_specifiers            = list(string)
        name                          = string
      })))

      # Windows Event Logs
      windows_event_log = optional(list(object({
        streams        = list(string)
        x_path_queries = list(string)
        name           = string
      })))

      # Linux Syslog
      syslog = optional(list(object({
        streams        = list(string)
        facility_names = list(string)
        log_levels     = list(string)
        name           = string
      })))

      # IIS Logs
      iis_log = optional(list(object({
        streams         = list(string)
        log_directories = optional(list(string))
        name            = string
      })))

      # Custom Log Files
      log_file = optional(list(object({
        streams       = list(string)
        file_patterns = list(string)
        format        = string
        name          = string
        settings = optional(object({
          text = optional(object({
            record_start_timestamp_format = string
          }))
        }))
      })))

      # Extensions (Dependency Agent, etc.)
      extension = optional(list(object({
        streams            = list(string)
        extension_name     = string
        extension_json     = optional(string)
        input_data_sources = optional(list(string))
        name               = string
      })))

      # Prometheus Forwarder
      prometheus_forwarder = optional(list(object({
        streams = list(string)
        label_include_filter = optional(list(object({
          label = string
          value = string
        })))
        name = string
      })))

      # Platform Telemetry
      platform_telemetry = optional(list(object({
        streams = list(string)
        name    = string
      })))
    }))

    # Identity (for certain data sources requiring authentication)
    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))

    # Stream declarations (for custom logs)
    stream_declaration = optional(list(object({
      stream_name = string
      column = list(object({
        name = string
        type = string
      }))
    })))

    # Tags (merged with global tags)
    tags = optional(map(string))
  }))
  default = {}

  validation {
    condition     = length(var.data_collection_rules) >= 0
    error_message = "variable value does not match the validator"
  }
}

variable "default_location" {
  description = "Default Azure region for all DCRs. Used when a DCR entry has location "
  type        = string
  default     = null
}

variable "default_resource_group_name" {
  description = "Default resource group name for all DCRs. Used when a DCR entry"
  type        = string
  default     = null
}

variable "default_workspace_resource_id" {
  description = "Default Log Analytics workspace resource ID. Injected into any log_analytics destination where workspace_resource_id is null."
  type        = string
  default     = null
}

variable "enable_associations" {
  description = <<EOT
Enable creation of DCR associations.
Set to false to create DCRs only (recommended for new Landing Zones with Azure Policy).
Set to true for brownfield environments or manual associations.
EOT
  type        = bool
  default     = false
}

variable "tags" {
  description = <<EOT
Tags to be applied to all DCR resources.
These tags are merged with DCR-specific tags defined in var.data_collection_rules.
    
Typically inherited from M01 Log Analytics module:
- ManagedBy = "Terraform"
- Module = "M07"
- Environment, Owner, CostCenter, Application (from F03 pattern)
EOT
  type        = map(string)
  default     = {}
}


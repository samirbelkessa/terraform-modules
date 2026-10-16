variable "Brainboard_IP_Range_List" {
  type    = list(string)
  default = ["3.18.12.57", "3.19.117.9", "3.12.21.31", "3.140.65.244", "18.223.219.168", "3.139.254.14", "3.109.176.247", "13.235.196.228", "3.108.102.235", "35.154.77.165", "159.196.14.175/32"]
}

variable "autoscale_enabled" {
  description = "Enable autoscaling for the Application Gateway. When enabled, min_capacity and max_capacity are used instead of capacity."
  type        = bool
  default     = true
}

variable "backend_address_pools" {
  description = "List of backend address pools for the Application Gateway."
  type = list(object({
    name         = string
    fqdns        = optional(list(string), [])
    ip_addresses = optional(list(string), [])
  }))
  default = [{ "fqdns" : [], "ip_addresses" : [], "name" : "default-backend-pool" }]
}

variable "backend_http_settings" {
  description = "List of backend HTTP settings for the Application Gateway."
  type = list(object({
    name                                = string
    port                                = number
    protocol                            = string
    cookie_based_affinity               = optional(string, "Disabled")
    affinity_cookie_name                = optional(string)
    path                                = optional(string)
    probe_name                          = optional(string)
    request_timeout                     = optional(number, 30)
    host_name                           = optional(string)
    pick_host_name_from_backend_address = optional(bool, false)
    trusted_root_certificate_names      = optional(list(string), [])
    connection_draining = optional(object({
      enabled           = bool
      drain_timeout_sec = number
    }))
  }))
  default = [{ "affinity_cookie_name" : null, "connection_draining" : null, "cookie_based_affinity" : "Disabled", "host_name" : null, "name" : "default-http-settings", "path" : null, "pick_host_name_from_backend_address" : false, "port" : 80, "probe_name" : null, "protocol" : "Http", "request_timeout" : 30, "trusted_root_certificate_names" : [] }]
}

variable "capacity" {
  description = "Number of instances for the Application Gateway (when autoscaling is disabled). Ignored if autoscaling is enabled."
  type        = number
  default     = 2

  validation {
    condition     = var.capacity >= 1 && var.capacity <= 125
    error_message = "variable value does not match the validator"
  }
}

variable "create_public_ip" {
  description = "Create a new Public IP for the Application Gateway. Set to false if using an existing Public IP."
  type        = bool
  default     = true
}

variable "diagnostic_logs_categories" {
  description = "List of log categories to enable for diagnostics."
  type        = list(string)
  default     = ["ApplicationGatewayAccessLog", "ApplicationGatewayPerformanceLog", "ApplicationGatewayFirewallLog"]
}

variable "diagnostic_metrics_categories" {
  description = "List of metric categories to enable for diagnostics."
  type        = list(string)
  default     = ["AllMetrics"]
}

variable "diagnostic_retention_days" {
  description = "Number of days to retain diagnostic logs. 0 means infinite retention."
  type        = number
  default     = 90
}

variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for the Application Gateway."
  type        = bool
  default     = true
}

variable "enable_http2" {
  description = "Enable HTTP/2 protocol support on the Application Gateway."
  type        = bool
  default     = true
}

variable "existing_public_ip_id" {
  description = "Resource ID of an existing Public IP to use. Only used when create_public_ip is false."
  type        = string
  default     = null
}

variable "fips_enabled" {
  description = "Enable FIPS-compliant cryptographic algorithms."
  type        = bool
  default     = false
}

variable "firewall_policy_id" {
  description = "Resource ID of an external WAF policy to associate. If not provided, a policy is created based on WAF settings."
  type        = string
  default     = null
}

variable "force_firewall_policy_association" {
  description = "Force association of WAF policy with the Application Gateway."
  type        = bool
  default     = true
}

variable "frontend_port_settings" {
  description = "List of frontend ports for the Application Gateway."
  type = list(object({
    name = string
    port = number
  }))
  default = [{ "name" : "port-80", "port" : 80 }, { "name" : "port-443", "port" : 443 }]
}

variable "health_probes" {
  description = "List of custom health probes for the Application Gateway."
  type = list(object({
    name                                      = string
    protocol                                  = string
    path                                      = string
    host                                      = optional(string)
    port                                      = optional(number)
    interval                                  = optional(number, 30)
    timeout                                   = optional(number, 30)
    unhealthy_threshold                       = optional(number, 3)
    pick_host_name_from_backend_http_settings = optional(bool, false)
    minimum_servers                           = optional(number, 0)
    match = optional(object({
      body        = optional(string)
      status_code = list(string)
    }))
  }))
  default = []
}

variable "http_listeners" {
  description = "List of HTTP listeners for the Application Gateway."
  type = list(object({
    name                           = string
    frontend_ip_configuration_name = optional(string, "public-frontend-ip")
    frontend_port_name             = string
    protocol                       = string
    host_name                      = optional(string)
    host_names                     = optional(list(string))
    ssl_certificate_name           = optional(string)
    require_sni                    = optional(bool, false)
    firewall_policy_id             = optional(string)
    custom_error_configuration = optional(list(object({
      status_code           = string
      custom_error_page_url = string
    })), [])
  }))
  default = [{ "custom_error_configuration" : [], "firewall_policy_id" : null, "frontend_ip_configuration_name" : "public-frontend-ip", "frontend_port_name" : "port-80", "host_name" : null, "host_names" : null, "name" : "default-http-listener", "protocol" : "Http", "require_sni" : false, "ssl_certificate_name" : null }]
}

variable "identity_ids" {
  description = "List of User Assigned Managed Identity IDs to assign to the Application Gateway."
  type        = list(string)
  default     = []
}

variable "identity_type" {
  description = "Type of managed identity. Required for Key Vault integration."
  type        = string
  default     = "UserAssigned"

  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "variable value does not match the validator"
  }
}

variable "location" {
  description = "Azure region where the Application Gateway will be deployed."
  type        = string
  default     = "australiaeast"

  validation {
    condition     = can(regex("^[a-z]+[a-z0-9]*$", var.location))
    error_message = "variable value does not match the validator"
  }
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace for diagnostics. Required if enable_diagnostic_settings is true."
  type        = string
  default     = null
}

variable "max_capacity" {
  description = "Maximum number of instances for autoscaling. Only used when autoscale_enabled is true."
  type        = number
  default     = 10

  validation {
    condition     = var.max_capacity >= 2 && var.max_capacity <= 125
    error_message = "variable value does not match the validator"
  }
}

variable "min_capacity" {
  description = "Minimum number of instances for autoscaling. Only used when autoscale_enabled is true."
  type        = number
  default     = 2

  validation {
    condition     = var.min_capacity >= 0 && var.min_capacity <= 100
    error_message = "variable value does not match the validator"
  }
}

variable "name" {
  description = "Name of the Application Gateway. Should follow naming convention: agw-{workload}-{region}-{instance}"
  type        = string

  validation {
    condition     = can(regex("^agw-", var.name)) && length(var.name) >= 8 && length(var.name) <= 80
    error_message = "variable value does not match the validator"
  }
}

variable "private_link_configurations" {
  description = "List of private link configurations for the Application Gateway."
  type = list(object({
    name = string
    ip_configuration = list(object({
      name                          = string
      subnet_id                     = string
      private_ip_address_allocation = string
      primary                       = bool
      private_ip_address            = optional(string)
    }))
  }))
  default = []
}

variable "public_ip_allocation_method" {
  description = "Allocation method for the Public IP. Static is required for Standard SKU."
  type        = string
  default     = "Static"

  validation {
    condition     = var.public_ip_allocation_method == "Static"
    error_message = "variable value does not match the validator"
  }
}

variable "public_ip_sku" {
  description = "SKU of the Public IP address. Standard is required for Application Gateway v2."
  type        = string
  default     = "Standard"

  validation {
    condition     = var.public_ip_sku == "Standard"
    error_message = "variable value does not match the validator"
  }
}

variable "request_routing_rules" {
  description = "List of request routing rules for the Application Gateway."
  type = list(object({
    name                        = string
    rule_type                   = string
    http_listener_name          = string
    backend_address_pool_name   = optional(string)
    backend_http_settings_name  = optional(string)
    redirect_configuration_name = optional(string)
    rewrite_rule_set_name       = optional(string)
    url_path_map_name           = optional(string)
    priority                    = number
  }))
  default = [{ "backend_address_pool_name" : "default-backend-pool", "backend_http_settings_name" : "default-http-settings", "http_listener_name" : "default-http-listener", "name" : "default-routing-rule", "priority" : 100, "redirect_configuration_name" : null, "rewrite_rule_set_name" : null, "rule_type" : "Basic", "url_path_map_name" : null }]
}

variable "resource_group_name" {
  description = "Name of the Resource Group where the Application Gateway will be deployed."
  type        = string

  validation {
    condition     = length(var.resource_group_name) >= 1 && length(var.resource_group_name) <= 90
    error_message = "variable value does not match the validator"
  }
}

variable "sku_name" {
  description = "Name of the SKU for the Application Gateway. WAF_v2 includes Web Application Firewall capabilities."
  type        = string
  default     = "WAF_v2"

  validation {
    condition     = contains(["Standard_v2", "WAF_v2"], var.sku_name)
    error_message = "variable value does not match the validator"
  }
}

variable "sku_tier" {
  description = "Tier of the SKU for the Application Gateway. Must match sku_name (WAF_v2 requires WAF_v2 tier)."
  type        = string
  default     = "WAF_v2"

  validation {
    condition     = contains(["Standard_v2", "WAF_v2"], var.sku_tier)
    error_message = "variable value does not match the validator"
  }
}

variable "ssl_certificates" {
  description = "List of SSL certificates to upload to the Application Gateway."
  type = list(object({
    name                = string
    key_vault_secret_id = optional(string)
    data                = optional(string)
    password            = optional(string)
  }))
  default   = []
  sensitive = true
}

variable "ssl_policy_name" {
  description = "Name of the predefined SSL policy. AppGwSslPolicy20220101S enforces TLS 1.2 minimum."
  type        = string
  default     = "AppGwSslPolicy20220101S"

  validation {
    condition     = contains(["AppGwSslPolicy20150501", "AppGwSslPolicy20170401", "AppGwSslPolicy20170401S", "AppGwSslPolicy20220101", "AppGwSslPolicy20220101S"], var.ssl_policy_name)
    error_message = "variable value does not match the validator"
  }
}

variable "ssl_policy_type" {
  description = "Type of SSL policy: 'Predefined' uses Microsoft policies, 'Custom' allows custom cipher suites."
  type        = string
  default     = "Predefined"

  validation {
    condition     = contains(["Predefined", "Custom", "CustomV2"], var.ssl_policy_type)
    error_message = "variable value does not match the validator"
  }
}

variable "subnet_id" {
  description = "Resource ID of the subnet where the Application Gateway will be deployed. Subnet must be named 'ApplicationGatewaySubnet' or dedicated for AppGW with minimum /27 CIDR."
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.Network/virtualNetworks/.+/subnets/.+$", var.subnet_id))
    error_message = "variable value does not match the validator"
  }
}

variable "waf_disabled_rule_groups" {
  description = "List of WAF rule groups to disable. Use for known false positives."
  type = list(object({
    rule_group_name = string
    rules           = optional(list(string), [])
  }))
  default = []
}

variable "waf_enabled" {
  description = "Enable Web Application Firewall on the Application Gateway. Requires WAF_v2 SKU."
  type        = bool
  default     = true
}

variable "waf_exclusions" {
  description = "List of WAF exclusions for specific match variables."
  type = list(object({
    match_variable          = string
    selector                = optional(string)
    selector_match_operator = optional(string, "Equals")
  }))
  default = []
}

variable "waf_file_upload_limit_mb" {
  description = "Maximum file upload size in MB allowed by WAF."
  type        = number
  default     = 100

  validation {
    condition     = var.waf_file_upload_limit_mb >= 1 && var.waf_file_upload_limit_mb <= 750
    error_message = "variable value does not match the validator"
  }
}

variable "waf_max_request_body_size_kb" {
  description = "Maximum request body size in KB inspected by WAF."
  type        = number
  default     = 128

  validation {
    condition     = var.waf_max_request_body_size_kb >= 8 && var.waf_max_request_body_size_kb <= 128
    error_message = "variable value does not match the validator"
  }
}

variable "waf_mode" {
  description = "WAF mode: 'Detection' logs threats without blocking, 'Prevention' blocks threats."
  type        = string
  default     = "Prevention"

  validation {
    condition     = contains(["Detection", "Prevention"], var.waf_mode)
    error_message = "variable value does not match the validator"
  }
}

variable "waf_rule_set_type" {
  description = "Type of the WAF rule set. OWASP is recommended for general protection."
  type        = string
  default     = "OWASP"

  validation {
    condition     = contains(["OWASP", "Microsoft_BotManagerRuleSet"], var.waf_rule_set_type)
    error_message = "variable value does not match the validator"
  }
}

variable "waf_rule_set_version" {
  description = "Version of the OWASP rule set. 3.2 is the latest stable version."
  type        = string
  default     = "3.2"

  validation {
    condition     = contains(["3.0", "3.1", "3.2"], var.waf_rule_set_version)
    error_message = "variable value does not match the validator"
  }
}

variable "zones" {
  description = "List of availability zones for the Application Gateway. Set to empty list to disable zone redundancy."
  type        = list(string)
  default     = ["1", "2", "3"]

  validation {
    condition     = alltrue([for z in var.zones : contains(["1", "2", "3"], z)])
    error_message = "variable value does not match the validator"
  }
}


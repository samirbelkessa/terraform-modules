variable "Brainboard_IP_Range_List" {
  type    = list(string)
  default = ["3.18.12.57", "3.19.117.9", "3.12.21.31", "3.140.65.244", "18.223.219.168", "3.139.254.14", "3.109.176.247", "13.235.196.228", "3.108.102.235", "35.154.77.165", "159.196.14.175/32"]
}

variable "context1" {
  description = "Primary context identifier (e.g., 'hub', 'spoke', 'mgmt', 'diag', domain name)."
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^[a-z0-9]*$", var.context1))
    error_message = "variable value does not match the validator"
  }
}

variable "context2" {
  description = "Secondary context identifier, typically instance number (e.g., '001', '01', '1')."
  type        = string
  default     = "001"

  validation {
    condition     = can(regex("^[a-z0-9]*$", var.context2))
    error_message = "variable value does not match the validator"
  }
}

variable "customer" {
  description = "Customer short code (e.g., 'tas', 'swc', 'ben'). See customer_map for valid values."
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2,10}$", var.customer))
    error_message = "variable value does not match the validator"
  }
}

variable "customer_map" {
  description = "Map of customer names to their short codes."
  type        = map(string)
  default = {
    asdistrib = "asd"
    ben       = "ben"
    intelly   = "int"
    swc       = "swc"
    tas       = "tas"
  }
}

variable "environment" {
  description = "Environment short code: p (Production), n (Non-Production), i (Isolated), l (Lab)."
  type        = string

  validation {
    condition     = contains(["p", "n", "i", "l"], var.environment)
    error_message = "variable value does not match the validator"
  }
}

variable "environment_map" {
  description = "Map of environment codes to their full names."
  type = map(object({
    code        = string
    name        = string
    description = string
  }))
  default = {
    i = {
      code        = "i"
      description = "TAS or customer testing environment with no connectivity to On-prem"
      name        = "Isolated"
    }
    l = {
      code        = "l"
      description = "Lease based Lab environment deployed for testing purposes"
      name        = "Lab"
    }
    n = {
      code        = "n"
      description = "TAS or Customer environment identical to production but no customer/critical data"
      name        = "NonProduction"
    }
    p = {
      code        = "p"
      description = "TAS or Customer production environments"
      name        = "Production"
    }
  }
}

variable "landing_zone" {
  description = "CAF Landing Zone classification: c (Corp), o (Online), sec, idt, mgt, cnt."
  type        = string
  default     = ""

  validation {
    condition     = var.landing_zone == "" || contains(["c", "o", "sec", "idt", "mgt", "cnt"], var.landing_zone)
    error_message = "variable value does not match the validator"
  }
}

variable "landing_zone_map" {
  description = "Map of landing zone codes to their descriptions (CAF aligned)."
  type = map(object({
    code        = string
    name        = string
    description = string
    type        = string # platform or application
  }))
  default = {
    c = {
      code        = "c"
      description = "Internal (private) application landing zone - not exposed to public internet"
      name        = "Corp"
      type        = "application"
    }
    cnt = {
      code        = "cnt"
      description = "Platform-level subscription for shared connectivity (Hub VNET, Firewall, DNS)"
      name        = "Connectivity"
      type        = "platform"
    }
    idt = {
      code        = "idt"
      description = "Platform-level subscription for identity services (AAD DS / Entra ID)"
      name        = "Identity"
      type        = "platform"
    }
    mgt = {
      code        = "mgt"
      description = "Platform-level subscription for management services (LA, Automation, Monitor)"
      name        = "Management"
      type        = "platform"
    }
    o = {
      code        = "o"
      description = "Internet-facing application landing zone - exposed via WAF/App Gateway/Front Door"
      name        = "Online"
      type        = "application"
    }
    sec = {
      code        = "sec"
      description = "Platform-level subscription for Sentinel, Defender, SIEM and security services"
      name        = "Security"
      type        = "platform"
    }
  }
}

variable "region" {
  description = "Region short code (e.g., 'aea' for Australia East, 'asa' for Australia Southeast)."
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2,4}$", var.region))
    error_message = "variable value does not match the validator"
  }
}

variable "region_map" {
  description = "Map of region codes to Azure region names and locations."
  type = map(object({
    code          = string
    azure_region  = string
    location      = string
    paired_region = string
  }))
  default = {
    aea = {
      azure_region  = "australiaeast"
      code          = "aea"
      location      = "Sydney"
      paired_region = "asa"
    }
    asa = {
      azure_region  = "australiasoutheast"
      code          = "asa"
      location      = "Melbourne"
      paired_region = "aea"
    }
    cus = {
      azure_region  = "centralus"
      code          = "cus"
      location      = "Central US"
      paired_region = "eus"
    }
    eus = {
      azure_region  = "eastus"
      code          = "eus"
      location      = "East US"
      paired_region = "wus"
    }
    gbl = {
      azure_region  = "global"
      code          = "gbl"
      location      = "Global"
      paired_region = "gbl"
    }
    neu = {
      azure_region  = "northeurope"
      code          = "neu"
      location      = "Dublin"
      paired_region = "weu"
    }
    weu = {
      azure_region  = "westeurope"
      code          = "weu"
      location      = "Amsterdam"
      paired_region = "neu"
    }
    wus = {
      azure_region  = "westus"
      code          = "wus"
      location      = "West US"
      paired_region = "eus"
    }
  }
}

variable "reserved_names" {
  description = "Azure reserved subnet names that cannot be changed."
  type        = map(string)
  default = {
    application_gateway_subnet = "ApplicationGatewaySubnet"
    bastion_subnet             = "AzureBastionSubnet"
    firewall_mgmt_subnet       = "AzureFirewallManagementSubnet"
    firewall_subnet            = "AzureFirewallSubnet"
    gateway_subnet             = "GatewaySubnet"
    route_server_subnet        = "RouteServerSubnet"
  }
}

variable "resource_map" {
  description = "Map of resource types with their TAS slugs, max lengths, and naming rules."
  type = map(object({
    slug            = string
    max_length      = number
    scope           = string # global, subscription, resourcegroup, resource
    allow_dashes    = bool
    allow_uppercase = bool
    regex           = string
    description     = string
  }))
  default = {
    api_management = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "API Management"
      max_length      = 50
      regex           = "^[a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9]$"
      scope           = "global"
      slug            = "apim"
    }
    app_service = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "App Service / Web App"
      max_length      = 60
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$"
      scope           = "global"
      slug            = "wapp"
    }
    app_service_environment = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "App Service Environment"
      max_length      = 36
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "ase"
    }
    app_service_plan = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "App Service Plan"
      max_length      = 40
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "asp"
    }
    application_gateway = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Application Gateway"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "appgtw"
    }
    application_insights = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Application Insights"
      max_length      = 260
      regex           = "^[a-zA-Z0-9._()-]+$"
      scope           = "resourcegroup"
      slug            = "insght"
    }
    automation_account = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Automation Account"
      max_length      = 50
      regex           = "^[a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "aa"
    }
    availability_set = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Availability Set"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "avset"
    }
    backup_policy = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Backup Policy"
      max_length      = 150
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$"
      scope           = "vault"
      slug            = "bkpol"
    }
    bastion = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Azure Bastion"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "bas"
    }
    blob = {
      allow_dashes    = true
      allow_uppercase = true
      description     = "Blob"
      max_length      = 1024
      regex           = "^.+$"
      scope           = "container"
      slug            = "blob"
    }
    container_instance = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Container Instance"
      max_length      = 63
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "conins"
    }
    container_registry = {
      allow_dashes    = false
      allow_uppercase = false
      description     = "Azure Container Registry"
      max_length      = 50
      regex           = "^[a-zA-Z0-9]+$"
      scope           = "global"
      slug            = "acr"
    }
    cosmos_db = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Cosmos DB Account"
      max_length      = 44
      regex           = "^[a-z0-9][a-z0-9-]*[a-z0-9]$"
      scope           = "global"
      slug            = "cdb"
    }
    data_collection_rule = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Data Collection Rule"
      max_length      = 64
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "dcr"
    }
    data_factory = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Azure Data Factory"
      max_length      = 63
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$"
      scope           = "global"
      slug            = "adf"
    }
    databricks_workspace = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Databricks Workspace"
      max_length      = 64
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "dbw"
    }
    dns = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "DNS Zone"
      max_length      = 63
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "dns"
    }
    event_grid = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Event Grid"
      max_length      = 50
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "evtgr"
    }
    event_hub_namespace = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Event Hub Namespace"
      max_length      = 50
      regex           = "^[a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9]$"
      scope           = "global"
      slug            = "evthub"
    }
    express_route_circuit = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "ExpressRoute Circuit"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "exprt"
    }
    express_route_gateway = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "ExpressRoute Gateway"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "exprt"
    }
    file_share = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "File Share"
      max_length      = 63
      regex           = "^[a-z0-9][a-z0-9-]*[a-z0-9]$"
      scope           = "storageaccount"
      slug            = "share"
    }
    firewall = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Azure Firewall"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "azfw"
    }
    firewall_policy = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Firewall Policy"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "azfwpol"
    }
    firewall_public_ip = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Azure Firewall Public IP"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "azfwip"
    }
    function_app = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Azure Function App"
      max_length      = 60
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$"
      scope           = "global"
      slug            = "func"
    }
    gateway = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Generic Gateway"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "gtw"
    }
    identity = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "User Assigned Managed Identity"
      max_length      = 128
      regex           = "^[a-zA-Z0-9-]+$"
      scope           = "resourcegroup"
      slug            = "idty"
    }
    image = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Image"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "img"
    }
    ip_group = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "IP Group"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "ipg"
    }
    key_vault = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Key Vault"
      max_length      = 24
      regex           = "^[a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9]$"
      scope           = "global"
      slug            = "kvt"
    }
    key_vault_certificate = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Key Vault Certificate"
      max_length      = 127
      regex           = "^[a-zA-Z0-9-]+$"
      scope           = "keyvault"
      slug            = "kvtcert"
    }
    key_vault_key = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Key Vault Key"
      max_length      = 127
      regex           = "^[a-zA-Z0-9-]+$"
      scope           = "keyvault"
      slug            = "kvtkey"
    }
    key_vault_secret = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Key Vault Secret"
      max_length      = 127
      regex           = "^[a-zA-Z0-9-]+$"
      scope           = "keyvault"
      slug            = "kvtsec"
    }
    kubernetes_cluster = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Azure Kubernetes Service"
      max_length      = 63
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9-_]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "aks"
    }
    load_balancer = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Load Balancer"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "lbs"
    }
    local_network_gateway = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Local Network Gateway"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "lgw"
    }
    log_analytics_workspace = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Log Analytics Workspace"
      max_length      = 63
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "law"
    }
    logic_app = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Logic App"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "lapp"
    }
    managed_disk = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Managed Disk"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "disk"
    }
    management_group = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Management Group"
      max_length      = 90
      regex           = "^[a-zA-Z0-9._-]+$"
      scope           = "tenant"
      slug            = "mg"
    }
    monitor_action_group = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Monitor Action Group"
      max_length      = 260
      regex           = "^[a-zA-Z0-9._-]+$"
      scope           = "resourcegroup"
      slug            = "ag"
    }
    monitor_alert = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Monitor Alert Rule"
      max_length      = 260
      regex           = "^[a-zA-Z0-9._-]+$"
      scope           = "resourcegroup"
      slug            = "alert"
    }
    nat_gateway = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "NAT Gateway"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "natgw"
    }
    network_interface = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Network Interface"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "nic"
    }
    network_security_group = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Network Security Group"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "nsg"
    }
    network_watcher_flow_log = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Network Watcher Flow Log"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "nwfl"
    }
    policy = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Azure Policy"
      max_length      = 128
      regex           = "^[a-zA-Z0-9._-]+$"
      scope           = "definition"
      slug            = "pol"
    }
    private_dns_zone = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Private DNS Zone"
      max_length      = 63
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "pdnsz"
    }
    private_endpoint = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Private Endpoint"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "pep"
    }
    private_link_service = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Private Link Service"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "pls"
    }
    public_ip = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Public IP Address"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "pip"
    }
    queue = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Storage Queue"
      max_length      = 63
      regex           = "^[a-z0-9][a-z0-9-]*[a-z0-9]$"
      scope           = "storageaccount"
      slug            = "queue"
    }
    recovery_services_vault = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Recovery Services Vault"
      max_length      = 50
      regex           = "^[a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "rsv"
    }
    resource_group = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Resource Group"
      max_length      = 90
      regex           = "^[a-zA-Z0-9._-]+$"
      scope           = "subscription"
      slug            = "rg"
    }
    route_table = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Route Table"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "rt"
    }
    route_table_default = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Default Route Table (to Azure Firewall)"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "defaultrt"
    }
    service_bus = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Service Bus Namespace"
      max_length      = 50
      regex           = "^[a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9]$"
      scope           = "global"
      slug            = "svcbus"
    }
    shared_image_gallery = {
      allow_dashes    = false
      allow_uppercase = false
      description     = "Shared Image Gallery"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "imgal"
    }
    site_recovery = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Azure Site Recovery"
      max_length      = 50
      regex           = "^[a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "asr"
    }
    sql_database = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "SQL Database"
      max_length      = 128
      regex           = "^[^<>*%&:\\/?]+$"
      scope           = "server"
      slug            = "sdb"
    }
    sql_managed_instance = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "SQL Managed Instance"
      max_length      = 63
      regex           = "^[a-z0-9][a-z0-9-]*[a-z0-9]$"
      scope           = "global"
      slug            = "sqlmi"
    }
    sql_server = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Azure SQL Server"
      max_length      = 63
      regex           = "^[a-z0-9][a-z0-9-]*[a-z0-9]$"
      scope           = "global"
      slug            = "asq"
    }
    storage_account = {
      allow_dashes    = false
      allow_uppercase = false
      description     = "Storage Account"
      max_length      = 24
      regex           = "^[a-z0-9]+$"
      scope           = "global"
      slug            = "stacc"
    }
    storage_container = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Storage Container"
      max_length      = 63
      regex           = "^[a-z0-9][a-z0-9-]*[a-z0-9]$"
      scope           = "storageaccount"
      slug            = "cont"
    }
    subnet = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Subnet"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "virtualnetwork"
      slug            = "sub"
    }
    subscription = {
      allow_dashes    = true
      allow_uppercase = true
      description     = "Subscription"
      max_length      = 256
      regex           = "^.+$"
      scope           = "account"
      slug            = "subs"
    }
    table = {
      allow_dashes    = false
      allow_uppercase = false
      description     = "Storage Table"
      max_length      = 63
      regex           = "^[a-zA-Z][a-zA-Z0-9]*$"
      scope           = "storageaccount"
      slug            = "tbl"
    }
    traffic_manager = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Traffic Manager Profile"
      max_length      = 63
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$"
      scope           = "global"
      slug            = "tman"
    }
    virtual_hub = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Virtual Hub"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "vhub"
    }
    virtual_machine = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Virtual Machine"
      max_length      = 15
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "vm"
    }
    virtual_machine_linux = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Linux Virtual Machine"
      max_length      = 64
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "vm"
    }
    virtual_machine_scale_set = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Virtual Machine Scale Set"
      max_length      = 64
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "vmss"
    }
    virtual_network = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Virtual Network"
      max_length      = 64
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "vnet"
    }
    virtual_network_gateway = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Virtual Network Gateway"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "vgtwy"
    }
    virtual_wan = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "Azure Virtual WAN"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "azwan"
    }
    vpn_gateway = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "VPN Gateway"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "vgtwy"
    }
    waf_policy = {
      allow_dashes    = true
      allow_uppercase = false
      description     = "WAF Policy"
      max_length      = 80
      regex           = "^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$"
      scope           = "resourcegroup"
      slug            = "wafpol"
    }
  }
}

variable "tier" {
  description = "Resource tier (0-3). 0=Platform shared, 1=Critical, 2=Shared dept, 3=Application."
  type        = number
  default     = 1

  validation {
    condition     = var.tier >= 0 && var.tier <= 3
    error_message = "variable value does not match the validator"
  }
}

variable "tier_map" {
  description = "Map of tier numbers to their descriptions."
  type = map(object({
    tier        = number
    name        = string
    description = string
  }))
  default = {
    "0" = {
      description = "TAS resources shared between multiple customers"
      name        = "Platform"
      tier        = 0
    }
    "1" = {
      description = "Customer tenant resources that are super critical (Express routes, DNS, DCs, Firewalls)"
      name        = "Critical"
      tier        = 1
    }
    "2" = {
      description = "Second level resources shared between applications for a specific department"
      name        = "Shared"
      tier        = 2
    }
    "3" = {
      description = "Application tier resources sharing Tier 2 resources"
      name        = "Application"
      tier        = 3
    }
  }
}

variable "unique_length" {
  description = "Length of random suffix for globally unique names (storage accounts, key vaults)."
  type        = number
  default     = 4

  validation {
    condition     = var.unique_length >= 2 && var.unique_length <= 8
    error_message = "variable value does not match the validator"
  }
}

variable "unique_seed" {
  description = "Custom seed for random string generation. Leave empty for auto-generated."
  type        = string
  default     = ""
}

variable "use_separator_for_rg" {
  description = "Use hyphen separator for Resource Groups (recommended for readability)."
  type        = bool
  default     = false
}


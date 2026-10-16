variable "Brainboard_IP_Range_List" {
  type    = list(string)
  default = ["3.18.12.57", "3.19.117.9", "3.12.21.31", "3.140.65.244", "18.223.219.168", "3.139.254.14", "3.109.176.247", "13.235.196.228", "3.108.102.235", "35.154.77.165", "159.196.14.175/32"]
}

variable "allowed_regions" {
  description = "List of allowed Azure regions for location policies."
  type        = list(string)
  default     = ["australiaeast", "australiasoutheast"]
}

variable "caf_builtin_initiative_ids" {
  description = <<EOT
Map of built-in initiative IDs for CAF assignments.
Expected keys:
  - azure_security_benchmark
  - vm_insights
  - nist_sp_800_53_r5 (optional)
  - iso_27001_2013 (optional)
EOT
  type        = map(string)
  default     = {}
}

variable "caf_initiative_ids" {
  description = <<EOT
Map of CAF initiative IDs from module G02 for automatic assignment.
Required when deploy_caf_assignments = true.
    
Expected keys match initiative names from G02:
  - caf-security-baseline
  - caf-network-baseline
  - caf-monitoring-baseline
  - caf-governance-baseline
  - caf-backup-baseline
  - caf-cost-baseline
  - caf-identity-baseline
  - caf-online-prod
  - caf-online-nonprod
  - caf-corp-prod
  - caf-corp-nonprod
  - caf-sandbox
  - caf-decommissioned
EOT
  type        = map(string)
  default     = {}
}

variable "caf_management_groups" {
  description = <<EOT
Map of CAF management group IDs for automatic assignment deployment.
Required when deploy_caf_assignments = true.
    
Expected keys:
  - root: Root management group ID
  - platform: Platform management group ID
  - connectivity: Connectivity management group ID
  - identity: Identity management group ID
  - management: Management management group ID
  - landing_zones: Landing Zones parent management group ID
  - online_prod: Online Production landing zone MG ID
  - online_nonprod: Online Non-Production landing zone MG ID
  - corp_prod: Corporate Production landing zone MG ID
  - corp_nonprod: Corporate Non-Production landing zone MG ID
  - sandbox: Sandbox landing zone MG ID
  - decommissioned: Decommissioned management group ID
EOT
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for k, v in var.caf_management_groups :
      can(regex("^/providers/Microsoft.Management/managementGroups/", v)) || v == ""
    ])
    error_message = "variable value does not match the validator"
  }
}

variable "create_role_assignments" {
  description = "Automatically create role assignments for policy assignments with managed identities (DeployIfNotExists, Modify)."
  type        = bool
  default     = true
}

variable "custom_defender_policy_ids" {
  description = "Map of custom Defender policy definition IDs (for plans without built-in DINE policies)."
  type        = map(string)
  default     = {}
}

variable "default_location" {
  description = "Default location for managed identities when not specified in assignment."
  type        = string
  default     = "australiaeast"
}

variable "default_role_definition_id" {
  description = "Default role definition ID to assign to managed identities. Defaults to Contributor."
  type        = string
  default     = "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
}

variable "defender_management_group_id" {
  description = "Management Group ID where Defender policies are assigned (typically Root MG for full coverage)."
  type        = string
  default     = ""
}

variable "defender_plans" {
  description = <<EOT
List of Defender plan keys to enable. Available plans:
CSPM:       cspm
CWPP:       servers, appsvc, storage, containers, keyvault, arm
Databases:  sqldb, sqlvm, ossdb, cosmosdb
EOT
  type        = list(string)
  default     = ["cspm", "servers", "appsvc", "storage", "containers", "keyvault", "arm", "sqldb", "sqlvm", "ossdb", "cosmosdb", "api", "ai"]

  validation {
    condition = alltrue([
      for plan in var.defender_plans :
      contains(["cspm", "servers", "appsvc", "storage", "containers", "keyvault", "arm", "sqldb", "sqlvm", "ossdb", "cosmosdb", "dns", "api", "ai"], plan)
    ])
    error_message = "variable value does not match the validator"
  }
}

variable "deny_resource_types_connectivity" {
  description = "Resource types to deny in Platform - Connectivity subscription. Prevents application workloads."
  type        = list(string)
  default     = ["Microsoft.Web/sites", "Microsoft.Web/serverfarms", "Microsoft.Compute/virtualMachines", "Microsoft.ContainerService/managedClusters", "Microsoft.Sql/servers", "Microsoft.Storage/storageAccounts", "Microsoft.KeyVault/vaults"]
}

variable "deny_resource_types_corp" {
  description = "Resource types to deny in Corp (internal) landing zones. Blocks platform connectivity/perimeter resources."
  type        = list(string)
  default     = ["Microsoft.Network/virtualWans", "Microsoft.Network/vpnGateways", "Microsoft.Network/vpnSites", "Microsoft.Network/vpnConnections", "Microsoft.Network/expressRouteGateways", "Microsoft.Network/expressRouteCircuits", "Microsoft.Network/routeServers", "Microsoft.Network/azureFirewalls", "Microsoft.Network/firewallPolicies", "Microsoft.Network/frontdoors", "Microsoft.Network/trafficManagerProfiles", "Microsoft.Cdn/profiles", "Microsoft.Network/publicIPAddresses", "Microsoft.Network/natGateways", "Microsoft.Network/networkWatchers"]
}

variable "deny_resource_types_identity" {
  description = "Resource types to deny in Platform - Identity subscription. Keeps focused on identity services."
  type        = list(string)
  default     = ["Microsoft.Network/virtualWans", "Microsoft.Network/expressRouteGateways", "Microsoft.Network/vpnGateways", "Microsoft.Network/azureFirewalls", "Microsoft.Network/frontdoors", "Microsoft.Web/sites", "Microsoft.Web/serverfarms", "Microsoft.Sql/servers", "Microsoft.Storage/storageAccounts", "Microsoft.ContainerService/managedClusters"]
}

variable "deny_resource_types_management" {
  description = "Resource types to deny in Platform - Management subscription. Keeps for monitoring/automation only."
  type        = list(string)
  default     = ["Microsoft.Compute/virtualMachines", "Microsoft.ContainerService/managedClusters", "Microsoft.Web/sites", "Microsoft.Web/serverfarms", "Microsoft.Sql/servers", "Microsoft.Network/expressRouteGateways", "Microsoft.Network/vpnGateways", "Microsoft.Network/virtualWans", "Microsoft.Network/azureFirewalls", "Microsoft.Network/frontdoors"]
}

variable "deny_resource_types_online" {
  description = "Resource types to deny in Online (internet-facing) landing zones. Blocks core connectivity components."
  type        = list(string)
  default     = ["Microsoft.Network/virtualWans", "Microsoft.Network/expressRouteGateways", "Microsoft.Network/vpnGateways", "Microsoft.Network/routeServers", "Microsoft.Network/expressRouteCircuits", "Microsoft.Network/vpnConnections", "Microsoft.Network/vpnSites", "Microsoft.Network/azureFirewalls", "Microsoft.Network/firewallPolicies", "Microsoft.Network/natGateways"]
}

variable "deny_resource_types_security" {
  description = "Resource types to deny in Platform - Security subscription. Keeps for Sentinel/Defender/SIEM only."
  type        = list(string)
  default     = ["Microsoft.Compute/virtualMachines", "Microsoft.ContainerService/managedClusters", "Microsoft.Web/sites", "Microsoft.Web/serverfarms", "Microsoft.Sql/servers", "Microsoft.Network/expressRouteGateways", "Microsoft.Network/frontdoors", "Microsoft.Network/vpnGateways", "Microsoft.Network/virtualWans", "Microsoft.Network/azureFirewalls"]
}

variable "deploy_caf_assignments" {
  description = "Deploy the pre-configured CAF Landing Zone policy assignments."
  type        = bool
  default     = false
}

variable "deploy_defender_for_cloud" {
  description = "Enable Microsoft Defender for Cloud plans via DeployIfNotExists policies at the specified management group."
  type        = bool
  default     = false
}

variable "deploy_defender_remediation" {
  description = "Create remediation tasks to apply Defender plans on existing subscriptions. Set to false on first apply if role assignments need to propagate."
  type        = bool
  default     = true
}

variable "deploy_deny_resource_types" {
  description = "Deploy the recommended CAF deny resource type assignments per management group scope."
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the central Log Analytics workspace for monitoring policies."
  type        = string
  default     = ""
}

variable "management_group_assignments" {
  description = <<EOT
Map of policy assignments at management group scope.
Each assignment can reference either a policy definition or policy set definition (initiative).
    
Key: Unique identifier for the assignment
Values:
  - management_group_id: Full resource ID of the management group
  - policy_definition_id: Resource ID of policy definition (mutually exclusive with policy_set_definition_id)
  - policy_set_definition_id: Resource ID of policy set definition/initiative (mutually exclusive with policy_definition_id)
  - display_name: Human-readable name for the assignment
  - description: Description of the assignment purpose
  - enforce: Whether to enforce the policy (true) or audit only (false)
  - parameters: JSON-encoded parameters for the policy
  - non_compliance_message: Message shown when resources are non-compliant
  - identity_type: Type of managed identity (None, SystemAssigned, UserAssigned)
  - identity_ids: List of User Assigned Managed Identity IDs (required if identity_type = UserAssigned)
  - location: Location for the managed identity (required if identity_type != None)
  - not_scopes: List of scopes to exclude from the assignment
  - metadata: Additional metadata as JSON string
EOT
  type = map(object({
    management_group_id      = string
    policy_definition_id     = optional(string)
    policy_set_definition_id = optional(string)
    display_name             = string
    description              = optional(string, "")
    enforce                  = optional(bool, true)
    parameters               = optional(string, null)
    non_compliance_message   = optional(string, null)
    identity_type            = optional(string, "None")
    identity_ids             = optional(list(string), [])
    location                 = optional(string, null)
    not_scopes               = optional(list(string), [])
    metadata                 = optional(string, null)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.management_group_assignments :
      ((v.policy_definition_id != null && v.policy_set_definition_id == null) ||
      (v.policy_definition_id == null && v.policy_set_definition_id != null)) &&
      contains(["None", "SystemAssigned", "UserAssigned"], v.identity_type) &&
      (v.identity_type != "UserAssigned" || length(v.identity_ids) > 0) &&
      (v.identity_type == "None" || v.location != null)
    ])
    error_message = "variable value does not match the validator"
  }
}

variable "required_tags" {
  description = "List of required tag names for governance policies."
  type        = list(string)
  default     = ["Environment", "Owner", "CostCenter", "Application"]
}

variable "resource_group_assignments" {
  description = <<EOT
Map of policy assignments at resource group scope.
Same structure as management_group_assignments but with resource_group_id instead of management_group_id.
EOT
  type = map(object({
    resource_group_id        = string
    policy_definition_id     = optional(string)
    policy_set_definition_id = optional(string)
    display_name             = string
    description              = optional(string, "")
    enforce                  = optional(bool, true)
    parameters               = optional(string, null)
    non_compliance_message   = optional(string, null)
    identity_type            = optional(string, "None")
    identity_ids             = optional(list(string), [])
    location                 = optional(string, null)
    not_scopes               = optional(list(string), [])
    metadata                 = optional(string, null)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.resource_group_assignments :
      (v.policy_definition_id != null && v.policy_set_definition_id == null) ||
      (v.policy_definition_id == null && v.policy_set_definition_id != null)
    ])
    error_message = "variable value does not match the validator"
  }
}

variable "role_definition_ids" {
  description = <<EOT
Map of role definition IDs to assign to policy managed identities.
Key: Policy assignment key
Value: List of role definition IDs
    
If not specified, the module will use default roles based on policy effect:
  - DeployIfNotExists: Contributor
  - Modify: Contributor
EOT
  type        = map(list(string))
  default     = {}
}

variable "subscription_assignments" {
  description = <<EOT
Map of policy assignments at subscription scope.
Same structure as management_group_assignments but with subscription_id instead of management_group_id.
EOT
  type = map(object({
    subscription_id          = string
    policy_definition_id     = optional(string)
    policy_set_definition_id = optional(string)
    display_name             = string
    description              = optional(string, "")
    enforce                  = optional(bool, true)
    parameters               = optional(string, null)
    non_compliance_message   = optional(string, null)
    identity_type            = optional(string, "None")
    identity_ids             = optional(list(string), [])
    location                 = optional(string, null)
    not_scopes               = optional(list(string), [])
    metadata                 = optional(string, null)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.subscription_assignments :
      (v.policy_definition_id != null && v.policy_set_definition_id == null) ||
      (v.policy_definition_id == null && v.policy_set_definition_id != null)
    ])
    error_message = "variable value does not match the validator"
  }
}


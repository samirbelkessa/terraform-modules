output "configuration_summary" {
  description = "Complete Sentinel configuration summary."
  value = {
    workspace_id             = var.log_analytics_workspace_id
    workspace_name           = var.log_analytics_workspace_name
    resource_group_name      = var.resource_group_name
    enabled_connectors       = keys(local.enabled_connectors)
    enabled_connectors_count = length(local.enabled_connectors)
    watchlists_count         = length(var.watchlists)
    customer_managed_key     = var.customer_managed_key_enabled
  }
}

output "connector_ids" {
  description = "Resource IDs of enabled data connectors."
  value = {
    azure_active_directory = var.data_connectors.azure_active_directory ? (
      length(azurerm_sentinel_data_connector_azure_active_directory.this) > 0 ?
      azurerm_sentinel_data_connector_azure_active_directory.this[0].id : null
    ) : null
    defender_for_cloud = var.data_connectors.defender_for_cloud ? {
      for key, connector in azurerm_sentinel_data_connector_azure_security_center.this : key => connector.id
    } : {}
    threat_intelligence = var.data_connectors.threat_intelligence ? (
      length(azurerm_sentinel_data_connector_threat_intelligence.this) > 0 ?
      azurerm_sentinel_data_connector_threat_intelligence.this[0].id : null
    ) : null
    microsoft_cloud_app_security = var.data_connectors.microsoft_cloud_app_security ? (
      length(azurerm_sentinel_data_connector_microsoft_cloud_app_security.this) > 0 ?
      azurerm_sentinel_data_connector_microsoft_cloud_app_security.this[0].id : null
    ) : null
    office_365 = var.data_connectors.office_365 ? (
      length(azurerm_sentinel_data_connector_office_365.this) > 0 ?
      azurerm_sentinel_data_connector_office_365.this[0].id : null
    ) : null
    microsoft_365_defender = var.data_connectors.microsoft_365_defender ? (
      length(azurerm_sentinel_data_connector_microsoft_defender_advanced_threat_protection.this) > 0 ?
      azurerm_sentinel_data_connector_microsoft_defender_advanced_threat_protection.this[0].id : null
    ) : null
    azure_advanced_threat_protection = var.data_connectors.azure_advanced_threat_protection ? (
      length(azurerm_sentinel_data_connector_azure_advanced_threat_protection.this) > 0 ?
      azurerm_sentinel_data_connector_azure_advanced_threat_protection.this[0].id : null
    ) : null
    microsoft_business_applications = var.data_connectors.microsoft_business_applications ? (
      length(azurerm_sentinel_data_connector_dynamics_365.this) > 0 ?
      azurerm_sentinel_data_connector_dynamics_365.this[0].id : null
    ) : null
  }
}

output "data_connectors_status" {
  description = "Status of each data connector."
  value = {
    azure_active_directory           = var.data_connectors.azure_active_directory ? "enabled" : "disabled"
    azure_activity                   = var.data_connectors.azure_activity ? "enabled" : "disabled"
    defender_for_cloud               = var.data_connectors.defender_for_cloud ? "enabled" : "disabled"
    threat_intelligence              = var.data_connectors.threat_intelligence ? "enabled" : "disabled"
    microsoft_cloud_app_security     = var.data_connectors.microsoft_cloud_app_security ? "enabled" : "disabled"
    office_365                       = var.data_connectors.office_365 ? "enabled" : "disabled"
    microsoft_365_defender           = var.data_connectors.microsoft_365_defender ? "enabled" : "disabled"
    azure_advanced_threat_protection = var.data_connectors.azure_advanced_threat_protection ? "enabled" : "disabled"
    microsoft_business_applications  = var.data_connectors.microsoft_business_applications ? "enabled" : "disabled"
    windows_security_events          = var.data_connectors.windows_security_events ? "enabled (via DCR)" : "disabled"
    syslog_via_ama                   = var.data_connectors.syslog_via_ama ? "enabled (via DCR)" : "disabled"
    entra_id_protection              = var.data_connectors.entra_id_protection ? "enabled (via azapi)" : "disabled"
    azure_sql_database               = var.data_connectors.azure_sql_database ? "enabled (via diagnostic settings)" : "disabled"
    misp2sentinel                    = var.data_connectors.misp2sentinel ? "enabled (via Logic App)" : "disabled"
    windows_server_dns               = var.data_connectors.windows_server_dns ? "enabled (via DCR)" : "disabled"
  }
}

output "enabled_connectors" {
  description = "List of enabled data connectors."
  value       = keys(local.enabled_connectors)
}

output "outputs_for_l03" {
  description = "Outputs specifically needed by L03 (Landing Zone Baseline)."
  value = {
    sentinel_workspace_id = var.log_analytics_workspace_id
    sentinel_enabled      = true
  }
}

output "sentinel_onboarding_id" {
  description = "ID of the Sentinel onboarding resource."
  value       = azurerm_sentinel_log_analytics_workspace_onboarding.this.id
}

output "watchlist_ids" {
  description = "Map of watchlist names to their resource IDs."
  value = {
    for name, watchlist in azurerm_sentinel_watchlist.this : name => watchlist.id
  }
}

output "workspace_id" {
  description = "Log Analytics Workspace ID where Sentinel is onboarded."
  value       = var.log_analytics_workspace_id
}

output "workspace_name" {
  description = "Log Analytics Workspace name."
  value       = var.log_analytics_workspace_name
}


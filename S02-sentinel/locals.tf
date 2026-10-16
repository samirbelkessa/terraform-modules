locals {
  default_tags = {
    ManagedBy = "Terraform"
    Module    = "S02-sentinel"
  }

  enabled_connectors = {
    for connector, enabled in {
      azure_active_directory           = var.data_connectors.azure_active_directory
      azure_activity                   = var.data_connectors.azure_activity
      defender_for_cloud               = var.data_connectors.defender_for_cloud
      threat_intelligence              = var.data_connectors.threat_intelligence
      microsoft_cloud_app_security     = var.data_connectors.microsoft_cloud_app_security
      office_365                       = var.data_connectors.office_365
      microsoft_365_defender           = var.data_connectors.microsoft_365_defender
      azure_advanced_threat_protection = var.data_connectors.azure_advanced_threat_protection
      microsoft_business_applications  = var.data_connectors.microsoft_business_applications
      windows_security_events          = var.data_connectors.windows_security_events
      syslog_via_ama                   = var.data_connectors.syslog_via_ama
      entra_id_protection              = var.data_connectors.entra_id_protection
      azure_sql_database               = var.data_connectors.azure_sql_database
      misp2sentinel                    = var.data_connectors.misp2sentinel
      windows_server_dns               = var.data_connectors.windows_server_dns
      network_security_groups          = var.data_connectors.network_security_groups
    } : connector => enabled if enabled
  }

  subscription_id = regex("^/subscriptions/([^/]+)/", var.log_analytics_workspace_id)[0]

  tags = merge(local.default_tags, var.tags)

}

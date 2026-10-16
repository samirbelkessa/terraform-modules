resource "azurerm_sentinel_log_analytics_workspace_onboarding" "this" {
  workspace_id                 = var.log_analytics_workspace_id
  customer_managed_key_enabled = var.customer_managed_key_enabled
}

resource "azurerm_sentinel_data_connector_azure_active_directory" "this" {
  name                       = "AzureActiveDirectory"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  count                      = var.data_connectors.azure_active_directory ? 1 : 0

  depends_on = [
    azurerm_sentinel_log_analytics_workspace_onboarding.this,
  ]
}

resource "azurerm_sentinel_data_connector_azure_security_center" "this" {
  subscription_id            = each.value
  name                       = "AzureSecurityCenter-${each.key}"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  for_each                   = var.data_connectors.defender_for_cloud ? var.defender_for_cloud_subscriptions : {}

  depends_on = [
    time_sleep.wait_for_sentinel_onboarding,
  ]
}

resource "azurerm_sentinel_data_connector_threat_intelligence" "this" {
  name                       = "ThreatIntelligence"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  count                      = var.data_connectors.threat_intelligence ? 1 : 0

  depends_on = [
    azurerm_sentinel_log_analytics_workspace_onboarding.this,
  ]
}

resource "azurerm_sentinel_data_connector_microsoft_cloud_app_security" "this" {
  name                       = "MicrosoftCloudAppSecurity"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  discovery_logs_enabled     = true
  count                      = var.data_connectors.microsoft_cloud_app_security ? 1 : 0
  alerts_enabled             = true

  depends_on = [
    azurerm_sentinel_log_analytics_workspace_onboarding.this,
  ]
}

resource "azurerm_sentinel_data_connector_office_365" "this" {
  teams_enabled              = true
  sharepoint_enabled         = true
  name                       = "Office365"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  exchange_enabled           = true
  count                      = var.data_connectors.office_365 ? 1 : 0

  depends_on = [
    azurerm_sentinel_log_analytics_workspace_onboarding.this,
  ]
}

resource "azurerm_sentinel_data_connector_microsoft_defender_advanced_threat_protection" "this" {
  name                       = "Microsoft365Defender"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  count                      = var.data_connectors.microsoft_365_defender ? 1 : 0

  depends_on = [
    azurerm_sentinel_log_analytics_workspace_onboarding.this,
  ]
}

resource "azurerm_sentinel_data_connector_azure_advanced_threat_protection" "this" {
  name                       = "AzureAdvancedThreatProtection"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  count                      = var.data_connectors.azure_advanced_threat_protection ? 1 : 0

  depends_on = [
    azurerm_sentinel_log_analytics_workspace_onboarding.this,
  ]
}

resource "azurerm_sentinel_data_connector_dynamics_365" "this" {
  name                       = "MicrosoftBusinessApplications"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  count                      = var.data_connectors.microsoft_business_applications ? 1 : 0

  depends_on = [
    azurerm_sentinel_log_analytics_workspace_onboarding.this,
  ]
}

resource "azurerm_sentinel_watchlist" "this" {
  name                       = each.key
  log_analytics_workspace_id = var.log_analytics_workspace_id
  labels                     = each.value.labels
  item_search_key            = each.value.item_search_key
  for_each                   = var.watchlists
  display_name               = each.value.display_name
  description                = each.value.description

  depends_on = [
    azurerm_sentinel_log_analytics_workspace_onboarding.this,
  ]
}

resource "time_sleep" "wait_for_sentinel_onboarding" {
  depends_on = [
    azurerm_sentinel_log_analytics_workspace_onboarding.this,
  ]
  create_duration = "120s"
}

data "azurerm_client_config" "current" {
}


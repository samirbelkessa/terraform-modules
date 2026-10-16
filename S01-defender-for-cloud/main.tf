resource "azurerm_security_center_subscription_pricing" "virtual_machines" {
  tier          = local.plan_tier_mapping["VirtualMachines"].tier
  subplan       = local.plan_tier_mapping["VirtualMachines"].tier == "Standard" ? local.plan_tier_mapping["VirtualMachines"].subplan : null
  resource_type = "VirtualMachines"
}

resource "azurerm_security_center_subscription_pricing" "storage_accounts" {
  tier          = local.plan_tier_mapping["StorageAccounts"].tier
  subplan       = local.plan_tier_mapping["StorageAccounts"].tier == "Standard" ? local.plan_tier_mapping["StorageAccounts"].subplan : null
  resource_type = "StorageAccounts"
}

resource "azurerm_security_center_subscription_pricing" "sql_servers" {
  tier          = local.plan_tier_mapping["SqlServers"].tier
  resource_type = "SqlServers"
}

resource "azurerm_security_center_subscription_pricing" "sql_server_vms" {
  tier          = local.plan_tier_mapping["SqlServerVirtualMachines"].tier
  resource_type = "SqlServerVirtualMachines"
}

resource "azurerm_security_center_subscription_pricing" "app_services" {
  tier          = local.plan_tier_mapping["AppServices"].tier
  resource_type = "AppServices"
}

resource "azurerm_security_center_subscription_pricing" "key_vaults" {
  tier          = local.plan_tier_mapping["KeyVaults"].tier
  resource_type = "KeyVaults"
}

resource "azurerm_security_center_subscription_pricing" "arm" {
  tier          = local.plan_tier_mapping["Arm"].tier
  subplan       = local.plan_tier_mapping["Arm"].tier == "Standard" ? local.plan_tier_mapping["Arm"].subplan : null
  resource_type = "Arm"
}

resource "azurerm_security_center_subscription_pricing" "dns" {
  tier          = local.plan_tier_mapping["Dns"].tier
  resource_type = "Dns"
}

resource "azurerm_security_center_subscription_pricing" "containers" {
  tier          = local.plan_tier_mapping["Containers"].tier
  resource_type = "Containers"
}

resource "azurerm_security_center_subscription_pricing" "oss_databases" {
  tier          = local.plan_tier_mapping["OpenSourceRelationalDatabases"].tier
  resource_type = "OpenSourceRelationalDatabases"
}

resource "azurerm_security_center_subscription_pricing" "cosmos_db" {
  tier          = local.plan_tier_mapping["CosmosDbs"].tier
  resource_type = "CosmosDbs"
}

resource "azurerm_security_center_subscription_pricing" "cloud_posture" {
  tier          = local.plan_tier_mapping["CloudPosture"].tier
  resource_type = "CloudPosture"
}

resource "azurerm_security_center_subscription_pricing" "api" {
  tier          = local.plan_tier_mapping["Api"].tier
  resource_type = "Api"
}

resource "azurerm_security_center_subscription_pricing" "ai_services" {
  tier          = local.plan_tier_mapping["AI"].tier
  resource_type = "AI"
}

resource "azurerm_security_center_contact" "this" {
  phone               = var.security_contact_phone
  name                = var.security_contact_name
  email               = var.security_contact_email
  alerts_to_admins    = var.alerts_to_admins_state == "On"
  alert_notifications = var.alert_notifications_state == "On"
}

resource "azurerm_security_center_workspace" "this" {
  workspace_id = var.log_analytics_workspace_id
  scope        = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
}

data "azurerm_client_config" "current" {
}


output "configuration_summary" {
  description = "Complete Defender for Cloud configuration summary."
  value = {
    subscription_id        = data.azurerm_client_config.current.subscription_id
    security_contact_email = azurerm_security_center_contact.this.email
    enabled_plans_count    = length([for plan, config in local.enabled_defender_plans : plan])
    enabled_plans          = [for plan, config in local.enabled_defender_plans : plan]
  }
}

output "defender_plans_status" {
  description = "Status of each Defender plan."
  value = {
    virtual_machines            = azurerm_security_center_subscription_pricing.virtual_machines.tier
    storage_accounts            = azurerm_security_center_subscription_pricing.storage_accounts.tier
    sql_servers                 = azurerm_security_center_subscription_pricing.sql_servers.tier
    sql_server_virtual_machines = azurerm_security_center_subscription_pricing.sql_server_vms.tier
    app_services                = azurerm_security_center_subscription_pricing.app_services.tier
    key_vaults                  = azurerm_security_center_subscription_pricing.key_vaults.tier
    arm                         = azurerm_security_center_subscription_pricing.arm.tier
    dns                         = azurerm_security_center_subscription_pricing.dns.tier
    containers                  = azurerm_security_center_subscription_pricing.containers.tier
    open_source_databases       = azurerm_security_center_subscription_pricing.oss_databases.tier
    cosmos_db                   = azurerm_security_center_subscription_pricing.cosmos_db.tier
    cloud_posture               = azurerm_security_center_subscription_pricing.cloud_posture.tier
    api                         = azurerm_security_center_subscription_pricing.api.tier
    ai_services                 = azurerm_security_center_subscription_pricing.ai_services.tier
  }
}

output "disabled_plans" {
  description = "List of disabled Defender plans."
  value       = [for plan, config in local.disabled_defender_plans : plan]
}

output "enabled_plans" {
  description = "List of enabled Defender plans."
  value       = [for plan, config in local.enabled_defender_plans : plan]
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID configured for Defender."
  value       = var.log_analytics_workspace_id
}

output "outputs_for_s02" {
  description = "Outputs specifically needed by S02 (Sentinel)."
  value = {
    defender_enabled = true
    subscription_id  = data.azurerm_client_config.current.subscription_id
    enabled_plans    = [for plan, config in local.enabled_defender_plans : plan]
  }
}

output "security_contact_email" {
  description = "Email configured for security alerts."
  value       = azurerm_security_center_contact.this.email
}

output "security_contact_id" {
  description = "ID of the security contact configuration."
  value       = azurerm_security_center_contact.this.id
}

output "subscription_id" {
  description = "Subscription ID where Defender is configured."
  value       = data.azurerm_client_config.current.subscription_id
}

output "workspace_id" {
  description = "ID of the workspace configuration."
  value       = azurerm_security_center_workspace.this.id
}


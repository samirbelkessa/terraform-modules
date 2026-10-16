output "all_resources" {
  description = "Map of all resource names with their properties."
  value = {
    for resource_key, resource_config in local.resource_names : resource_key => {
      name        = resource_config.name
      name_unique = substr("${resource_config.name}${random_string.unique.result}", 0, resource_config.max_length)
      slug        = resource_config.slug
      max_length  = resource_config.max_length
      scope       = resource_config.scope
    }
  }
}

output "app_service" {
  description = "App Service / Web App naming (GLOBAL SCOPE - use name_unique)."
  value = {
    name        = local.resource_names["app_service"].name
    name_unique = substr("${local.resource_names["app_service"].name}${random_string.unique.result}", 0, local.resource_names["app_service"].max_length)
    slug        = local.resource_names["app_service"].slug
    max_length  = local.resource_names["app_service"].max_length
    scope       = local.resource_names["app_service"].scope
    regex       = local.resource_names["app_service"].regex
  }
}

output "app_service_plan" {
  description = "App Service Plan naming."
  value = {
    name        = local.resource_names["app_service_plan"].name
    name_unique = substr("${local.resource_names["app_service_plan"].name}${random_string.unique.result}", 0, local.resource_names["app_service_plan"].max_length)
    slug        = local.resource_names["app_service_plan"].slug
    max_length  = local.resource_names["app_service_plan"].max_length
    scope       = local.resource_names["app_service_plan"].scope
    regex       = local.resource_names["app_service_plan"].regex
  }
}

output "application_gateway" {
  description = "Application Gateway naming."
  value = {
    name        = local.resource_names["application_gateway"].name
    name_unique = "${local.resource_names["application_gateway"].name}${random_string.unique.result}"
    slug        = local.resource_names["application_gateway"].slug
    max_length  = local.resource_names["application_gateway"].max_length
    scope       = local.resource_names["application_gateway"].scope
    regex       = local.resource_names["application_gateway"].regex
  }
}

output "application_insights" {
  description = "Application Insights naming."
  value = {
    name        = local.resource_names["application_insights"].name
    name_unique = "${local.resource_names["application_insights"].name}${random_string.unique.result}"
    slug        = local.resource_names["application_insights"].slug
    max_length  = local.resource_names["application_insights"].max_length
    scope       = local.resource_names["application_insights"].scope
    regex       = local.resource_names["application_insights"].regex
  }
}

output "automation_account" {
  description = "Automation Account naming."
  value = {
    name        = local.resource_names["automation_account"].name
    name_unique = substr("${local.resource_names["automation_account"].name}${random_string.unique.result}", 0, local.resource_names["automation_account"].max_length)
    slug        = local.resource_names["automation_account"].slug
    max_length  = local.resource_names["automation_account"].max_length
    scope       = local.resource_names["automation_account"].scope
    regex       = local.resource_names["automation_account"].regex
  }
}

output "availability_set" {
  description = "Availability Set naming."
  value = {
    name        = local.resource_names["availability_set"].name
    name_unique = "${local.resource_names["availability_set"].name}${random_string.unique.result}"
    slug        = local.resource_names["availability_set"].slug
    max_length  = local.resource_names["availability_set"].max_length
    scope       = local.resource_names["availability_set"].scope
    regex       = local.resource_names["availability_set"].regex
  }
}

output "backup_policy" {
  description = "Backup Policy naming."
  value = {
    name        = local.resource_names["backup_policy"].name
    name_unique = "${local.resource_names["backup_policy"].name}${random_string.unique.result}"
    slug        = local.resource_names["backup_policy"].slug
    max_length  = local.resource_names["backup_policy"].max_length
    scope       = local.resource_names["backup_policy"].scope
    regex       = local.resource_names["backup_policy"].regex
  }
}

output "base_prefix" {
  description = "Base prefix for all resources: {customer}{env}{region}{tier}"
  value       = local.base_prefix
}

output "bastion" {
  description = "Azure Bastion naming."
  value = {
    name        = local.resource_names["bastion"].name
    name_unique = "${local.resource_names["bastion"].name}${random_string.unique.result}"
    slug        = local.resource_names["bastion"].slug
    max_length  = local.resource_names["bastion"].max_length
    scope       = local.resource_names["bastion"].scope
    regex       = local.resource_names["bastion"].regex
  }
}

output "container_registry" {
  description = "Azure Container Registry naming (GLOBAL SCOPE - use name_unique)."
  value = {
    # ACR: max 50 chars, alphanumeric only, no dashes
    name        = substr(replace(local.resource_names["container_registry"].name, "-", ""), 0, local.resource_names["container_registry"].max_length)
    name_unique = substr("${replace(local.resource_names["container_registry"].name, "-", "")}${random_string.unique.result}", 0, local.resource_names["container_registry"].max_length)
    slug        = local.resource_names["container_registry"].slug
    max_length  = local.resource_names["container_registry"].max_length
    scope       = local.resource_names["container_registry"].scope
    regex       = local.resource_names["container_registry"].regex
  }
}

output "cosmos_db" {
  description = "Cosmos DB Account naming (GLOBAL SCOPE - use name_unique)."
  value = {
    name        = substr(local.resource_names["cosmos_db"].name, 0, local.resource_names["cosmos_db"].max_length)
    name_unique = substr("${local.resource_names["cosmos_db"].name}${random_string.unique.result}", 0, local.resource_names["cosmos_db"].max_length)
    slug        = local.resource_names["cosmos_db"].slug
    max_length  = local.resource_names["cosmos_db"].max_length
    scope       = local.resource_names["cosmos_db"].scope
    regex       = local.resource_names["cosmos_db"].regex
  }
}

output "data_collection_rule" {
  description = "Data Collection Rule naming."
  value = {
    name        = local.resource_names["data_collection_rule"].name
    name_unique = substr("${local.resource_names["data_collection_rule"].name}${random_string.unique.result}", 0, local.resource_names["data_collection_rule"].max_length)
    slug        = local.resource_names["data_collection_rule"].slug
    max_length  = local.resource_names["data_collection_rule"].max_length
    scope       = local.resource_names["data_collection_rule"].scope
    regex       = local.resource_names["data_collection_rule"].regex
  }
}

output "data_factory" {
  description = "Azure Data Factory naming (GLOBAL SCOPE - use name_unique)."
  value = {
    name        = local.resource_names["data_factory"].name
    name_unique = substr("${local.resource_names["data_factory"].name}${random_string.unique.result}", 0, local.resource_names["data_factory"].max_length)
    slug        = local.resource_names["data_factory"].slug
    max_length  = local.resource_names["data_factory"].max_length
    scope       = local.resource_names["data_factory"].scope
    regex       = local.resource_names["data_factory"].regex
  }
}

output "event_hub_namespace" {
  description = "Event Hub Namespace naming (GLOBAL SCOPE - use name_unique)."
  value = {
    name        = local.resource_names["event_hub_namespace"].name
    name_unique = substr("${local.resource_names["event_hub_namespace"].name}${random_string.unique.result}", 0, local.resource_names["event_hub_namespace"].max_length)
    slug        = local.resource_names["event_hub_namespace"].slug
    max_length  = local.resource_names["event_hub_namespace"].max_length
    scope       = local.resource_names["event_hub_namespace"].scope
    regex       = local.resource_names["event_hub_namespace"].regex
  }
}

output "express_route_gateway" {
  description = "ExpressRoute Gateway naming."
  value = {
    name        = local.resource_names["express_route_gateway"].name
    name_unique = "${local.resource_names["express_route_gateway"].name}${random_string.unique.result}"
    slug        = local.resource_names["express_route_gateway"].slug
    max_length  = local.resource_names["express_route_gateway"].max_length
    scope       = local.resource_names["express_route_gateway"].scope
    regex       = local.resource_names["express_route_gateway"].regex
  }
}

output "file_share" {
  description = "File Share naming."
  value = {
    name        = local.resource_names["file_share"].name
    name_unique = substr("${local.resource_names["file_share"].name}${random_string.unique.result}", 0, local.resource_names["file_share"].max_length)
    slug        = local.resource_names["file_share"].slug
    max_length  = local.resource_names["file_share"].max_length
    scope       = local.resource_names["file_share"].scope
    regex       = local.resource_names["file_share"].regex
  }
}

output "firewall" {
  description = "Azure Firewall naming."
  value = {
    name        = local.resource_names["firewall"].name
    name_unique = "${local.resource_names["firewall"].name}${random_string.unique.result}"
    slug        = local.resource_names["firewall"].slug
    max_length  = local.resource_names["firewall"].max_length
    scope       = local.resource_names["firewall"].scope
    regex       = local.resource_names["firewall"].regex
  }
}

output "firewall_policy" {
  description = "Firewall Policy naming."
  value = {
    name        = local.resource_names["firewall_policy"].name
    name_unique = "${local.resource_names["firewall_policy"].name}${random_string.unique.result}"
    slug        = local.resource_names["firewall_policy"].slug
    max_length  = local.resource_names["firewall_policy"].max_length
    scope       = local.resource_names["firewall_policy"].scope
    regex       = local.resource_names["firewall_policy"].regex
  }
}

output "firewall_public_ip" {
  description = "Azure Firewall Public IP naming."
  value = {
    name        = local.resource_names["firewall_public_ip"].name
    name_unique = "${local.resource_names["firewall_public_ip"].name}${random_string.unique.result}"
    slug        = local.resource_names["firewall_public_ip"].slug
    max_length  = local.resource_names["firewall_public_ip"].max_length
    scope       = local.resource_names["firewall_public_ip"].scope
    regex       = local.resource_names["firewall_public_ip"].regex
  }
}

output "function_app" {
  description = "Azure Function App naming (GLOBAL SCOPE - use name_unique)."
  value = {
    name        = local.resource_names["function_app"].name
    name_unique = substr("${local.resource_names["function_app"].name}${random_string.unique.result}", 0, local.resource_names["function_app"].max_length)
    slug        = local.resource_names["function_app"].slug
    max_length  = local.resource_names["function_app"].max_length
    scope       = local.resource_names["function_app"].scope
    regex       = local.resource_names["function_app"].regex
  }
}

output "identity" {
  description = "User Assigned Managed Identity naming."
  value = {
    name        = local.resource_names["identity"].name
    name_unique = "${local.resource_names["identity"].name}${random_string.unique.result}"
    slug        = local.resource_names["identity"].slug
    max_length  = local.resource_names["identity"].max_length
    scope       = local.resource_names["identity"].scope
    regex       = local.resource_names["identity"].regex
  }
}

output "ip_group" {
  description = "IP Group naming."
  value = {
    name        = local.resource_names["ip_group"].name
    name_unique = "${local.resource_names["ip_group"].name}${random_string.unique.result}"
    slug        = local.resource_names["ip_group"].slug
    max_length  = local.resource_names["ip_group"].max_length
    scope       = local.resource_names["ip_group"].scope
    regex       = local.resource_names["ip_group"].regex
  }
}

output "key_vault" {
  description = "Key Vault naming (GLOBAL SCOPE - use name_unique)."
  value = {
    # Key vaults: max 24 chars, alphanumeric and dashes, must start with letter
    name        = substr(local.resource_names["key_vault"].name, 0, local.resource_names["key_vault"].max_length)
    name_unique = substr("${local.resource_names["key_vault"].name}${random_string.unique.result}", 0, local.resource_names["key_vault"].max_length)
    slug        = local.resource_names["key_vault"].slug
    max_length  = local.resource_names["key_vault"].max_length
    scope       = local.resource_names["key_vault"].scope
    regex       = local.resource_names["key_vault"].regex
  }
}

output "key_vault_key" {
  description = "Key Vault Key naming."
  value = {
    name        = local.resource_names["key_vault_key"].name
    name_unique = "${local.resource_names["key_vault_key"].name}${random_string.unique.result}"
    slug        = local.resource_names["key_vault_key"].slug
    max_length  = local.resource_names["key_vault_key"].max_length
    scope       = local.resource_names["key_vault_key"].scope
    regex       = local.resource_names["key_vault_key"].regex
  }
}

output "key_vault_secret" {
  description = "Key Vault Secret naming."
  value = {
    name        = local.resource_names["key_vault_secret"].name
    name_unique = "${local.resource_names["key_vault_secret"].name}${random_string.unique.result}"
    slug        = local.resource_names["key_vault_secret"].slug
    max_length  = local.resource_names["key_vault_secret"].max_length
    scope       = local.resource_names["key_vault_secret"].scope
    regex       = local.resource_names["key_vault_secret"].regex
  }
}

output "kubernetes_cluster" {
  description = "Azure Kubernetes Service naming."
  value = {
    name        = local.resource_names["kubernetes_cluster"].name
    name_unique = substr("${local.resource_names["kubernetes_cluster"].name}${random_string.unique.result}", 0, local.resource_names["kubernetes_cluster"].max_length)
    slug        = local.resource_names["kubernetes_cluster"].slug
    max_length  = local.resource_names["kubernetes_cluster"].max_length
    scope       = local.resource_names["kubernetes_cluster"].scope
    regex       = local.resource_names["kubernetes_cluster"].regex
  }
}

output "load_balancer" {
  description = "Load Balancer naming."
  value = {
    name        = local.resource_names["load_balancer"].name
    name_unique = "${local.resource_names["load_balancer"].name}${random_string.unique.result}"
    slug        = local.resource_names["load_balancer"].slug
    max_length  = local.resource_names["load_balancer"].max_length
    scope       = local.resource_names["load_balancer"].scope
    regex       = local.resource_names["load_balancer"].regex
  }
}

output "local_network_gateway" {
  description = "Local Network Gateway naming."
  value = {
    name        = local.resource_names["local_network_gateway"].name
    name_unique = "${local.resource_names["local_network_gateway"].name}${random_string.unique.result}"
    slug        = local.resource_names["local_network_gateway"].slug
    max_length  = local.resource_names["local_network_gateway"].max_length
    scope       = local.resource_names["local_network_gateway"].scope
    regex       = local.resource_names["local_network_gateway"].regex
  }
}

output "log_analytics_workspace" {
  description = "Log Analytics Workspace naming."
  value = {
    name        = local.resource_names["log_analytics_workspace"].name
    name_unique = substr("${local.resource_names["log_analytics_workspace"].name}${random_string.unique.result}", 0, local.resource_names["log_analytics_workspace"].max_length)
    slug        = local.resource_names["log_analytics_workspace"].slug
    max_length  = local.resource_names["log_analytics_workspace"].max_length
    scope       = local.resource_names["log_analytics_workspace"].scope
    regex       = local.resource_names["log_analytics_workspace"].regex
  }
}

output "logic_app" {
  description = "Logic App naming."
  value = {
    name        = local.resource_names["logic_app"].name
    name_unique = "${local.resource_names["logic_app"].name}${random_string.unique.result}"
    slug        = local.resource_names["logic_app"].slug
    max_length  = local.resource_names["logic_app"].max_length
    scope       = local.resource_names["logic_app"].scope
    regex       = local.resource_names["logic_app"].regex
  }
}

output "managed_disk" {
  description = "Managed Disk naming."
  value = {
    name        = local.resource_names["managed_disk"].name
    name_unique = "${local.resource_names["managed_disk"].name}${random_string.unique.result}"
    slug        = local.resource_names["managed_disk"].slug
    max_length  = local.resource_names["managed_disk"].max_length
    scope       = local.resource_names["managed_disk"].scope
    regex       = local.resource_names["managed_disk"].regex
  }
}

output "management_group" {
  description = "Management Group naming."
  value = {
    name        = local.resource_names["management_group"].name
    name_unique = "${local.resource_names["management_group"].name}${random_string.unique.result}"
    slug        = local.resource_names["management_group"].slug
    max_length  = local.resource_names["management_group"].max_length
    scope       = local.resource_names["management_group"].scope
    regex       = local.resource_names["management_group"].regex
  }
}

output "metadata" {
  description = "Naming metadata containing all input parameters and derived values."
  value       = local.naming_metadata
}

output "monitor_action_group" {
  description = "Monitor Action Group naming."
  value = {
    name        = local.resource_names["monitor_action_group"].name
    name_unique = "${local.resource_names["monitor_action_group"].name}${random_string.unique.result}"
    slug        = local.resource_names["monitor_action_group"].slug
    max_length  = local.resource_names["monitor_action_group"].max_length
    scope       = local.resource_names["monitor_action_group"].scope
    regex       = local.resource_names["monitor_action_group"].regex
  }
}

output "nat_gateway" {
  description = "NAT Gateway naming."
  value = {
    name        = local.resource_names["nat_gateway"].name
    name_unique = "${local.resource_names["nat_gateway"].name}${random_string.unique.result}"
    slug        = local.resource_names["nat_gateway"].slug
    max_length  = local.resource_names["nat_gateway"].max_length
    scope       = local.resource_names["nat_gateway"].scope
    regex       = local.resource_names["nat_gateway"].regex
  }
}

output "network_interface" {
  description = "Network Interface naming."
  value = {
    name        = local.resource_names["network_interface"].name
    name_unique = "${local.resource_names["network_interface"].name}${random_string.unique.result}"
    slug        = local.resource_names["network_interface"].slug
    max_length  = local.resource_names["network_interface"].max_length
    scope       = local.resource_names["network_interface"].scope
    regex       = local.resource_names["network_interface"].regex
  }
}

output "network_security_group" {
  description = "Network Security Group naming."
  value = {
    name        = local.resource_names["network_security_group"].name
    name_unique = "${local.resource_names["network_security_group"].name}${random_string.unique.result}"
    slug        = local.resource_names["network_security_group"].slug
    max_length  = local.resource_names["network_security_group"].max_length
    scope       = local.resource_names["network_security_group"].scope
    regex       = local.resource_names["network_security_group"].regex
  }
}

output "network_watcher_flow_log" {
  description = "Network Watcher Flow Log naming."
  value = {
    name        = local.resource_names["network_watcher_flow_log"].name
    name_unique = "${local.resource_names["network_watcher_flow_log"].name}${random_string.unique.result}"
    slug        = local.resource_names["network_watcher_flow_log"].slug
    max_length  = local.resource_names["network_watcher_flow_log"].max_length
    scope       = local.resource_names["network_watcher_flow_log"].scope
    regex       = local.resource_names["network_watcher_flow_log"].regex
  }
}

output "policy" {
  description = "Azure Policy naming."
  value = {
    name        = local.resource_names["policy"].name
    name_unique = "${local.resource_names["policy"].name}${random_string.unique.result}"
    slug        = local.resource_names["policy"].slug
    max_length  = local.resource_names["policy"].max_length
    scope       = local.resource_names["policy"].scope
    regex       = local.resource_names["policy"].regex
  }
}

output "private_dns_zone" {
  description = "Private DNS Zone naming."
  value = {
    name        = local.resource_names["private_dns_zone"].name
    name_unique = substr("${local.resource_names["private_dns_zone"].name}${random_string.unique.result}", 0, local.resource_names["private_dns_zone"].max_length)
    slug        = local.resource_names["private_dns_zone"].slug
    max_length  = local.resource_names["private_dns_zone"].max_length
    scope       = local.resource_names["private_dns_zone"].scope
    regex       = local.resource_names["private_dns_zone"].regex
  }
}

output "private_endpoint" {
  description = "Private Endpoint naming."
  value = {
    name        = local.resource_names["private_endpoint"].name
    name_unique = "${local.resource_names["private_endpoint"].name}${random_string.unique.result}"
    slug        = local.resource_names["private_endpoint"].slug
    max_length  = local.resource_names["private_endpoint"].max_length
    scope       = local.resource_names["private_endpoint"].scope
    regex       = local.resource_names["private_endpoint"].regex
  }
}

output "private_link_service" {
  description = "Private Link Service naming."
  value = {
    name        = local.resource_names["private_link_service"].name
    name_unique = "${local.resource_names["private_link_service"].name}${random_string.unique.result}"
    slug        = local.resource_names["private_link_service"].slug
    max_length  = local.resource_names["private_link_service"].max_length
    scope       = local.resource_names["private_link_service"].scope
    regex       = local.resource_names["private_link_service"].regex
  }
}

output "public_ip" {
  description = "Public IP naming."
  value = {
    name        = local.resource_names["public_ip"].name
    name_unique = "${local.resource_names["public_ip"].name}${random_string.unique.result}"
    slug        = local.resource_names["public_ip"].slug
    max_length  = local.resource_names["public_ip"].max_length
    scope       = local.resource_names["public_ip"].scope
    regex       = local.resource_names["public_ip"].regex
  }
}

output "recovery_services_vault" {
  description = "Recovery Services Vault naming."
  value = {
    name        = local.resource_names["recovery_services_vault"].name
    name_unique = substr("${local.resource_names["recovery_services_vault"].name}${random_string.unique.result}", 0, local.resource_names["recovery_services_vault"].max_length)
    slug        = local.resource_names["recovery_services_vault"].slug
    max_length  = local.resource_names["recovery_services_vault"].max_length
    scope       = local.resource_names["recovery_services_vault"].scope
    regex       = local.resource_names["recovery_services_vault"].regex
  }
}

output "reserved_subnet_names" {
  description = "Azure reserved subnet names that cannot be customized."
  value       = var.reserved_names
}

output "resource_group" {
  description = "Resource Group naming."
  value = {
    name        = local.resource_names["resource_group"].name
    name_unique = "${local.resource_names["resource_group"].name}${random_string.unique.result}"
    slug        = local.resource_names["resource_group"].slug
    max_length  = local.resource_names["resource_group"].max_length
    scope       = local.resource_names["resource_group"].scope
    regex       = local.resource_names["resource_group"].regex
  }
}

output "route_table" {
  description = "Route Table naming."
  value = {
    name        = local.resource_names["route_table"].name
    name_unique = "${local.resource_names["route_table"].name}${random_string.unique.result}"
    slug        = local.resource_names["route_table"].slug
    max_length  = local.resource_names["route_table"].max_length
    scope       = local.resource_names["route_table"].scope
    regex       = local.resource_names["route_table"].regex
  }
}

output "route_table_default" {
  description = "Default Route Table naming (to Azure Firewall)."
  value = {
    name        = local.resource_names["route_table_default"].name
    name_unique = "${local.resource_names["route_table_default"].name}${random_string.unique.result}"
    slug        = local.resource_names["route_table_default"].slug
    max_length  = local.resource_names["route_table_default"].max_length
    scope       = local.resource_names["route_table_default"].scope
    regex       = local.resource_names["route_table_default"].regex
  }
}

output "service_bus" {
  description = "Service Bus Namespace naming (GLOBAL SCOPE - use name_unique)."
  value = {
    name        = local.resource_names["service_bus"].name
    name_unique = substr("${local.resource_names["service_bus"].name}${random_string.unique.result}", 0, local.resource_names["service_bus"].max_length)
    slug        = local.resource_names["service_bus"].slug
    max_length  = local.resource_names["service_bus"].max_length
    scope       = local.resource_names["service_bus"].scope
    regex       = local.resource_names["service_bus"].regex
  }
}

output "site_recovery" {
  description = "Azure Site Recovery naming."
  value = {
    name        = local.resource_names["site_recovery"].name
    name_unique = substr("${local.resource_names["site_recovery"].name}${random_string.unique.result}", 0, local.resource_names["site_recovery"].max_length)
    slug        = local.resource_names["site_recovery"].slug
    max_length  = local.resource_names["site_recovery"].max_length
    scope       = local.resource_names["site_recovery"].scope
    regex       = local.resource_names["site_recovery"].regex
  }
}

output "sql_database" {
  description = "SQL Database naming."
  value = {
    name        = local.resource_names["sql_database"].name
    name_unique = "${local.resource_names["sql_database"].name}${random_string.unique.result}"
    slug        = local.resource_names["sql_database"].slug
    max_length  = local.resource_names["sql_database"].max_length
    scope       = local.resource_names["sql_database"].scope
    regex       = local.resource_names["sql_database"].regex
  }
}

output "sql_server" {
  description = "Azure SQL Server naming (GLOBAL SCOPE - use name_unique)."
  value = {
    name        = local.resource_names["sql_server"].name
    name_unique = substr("${local.resource_names["sql_server"].name}${random_string.unique.result}", 0, local.resource_names["sql_server"].max_length)
    slug        = local.resource_names["sql_server"].slug
    max_length  = local.resource_names["sql_server"].max_length
    scope       = local.resource_names["sql_server"].scope
    regex       = local.resource_names["sql_server"].regex
  }
}

output "storage_account" {
  description = "Storage Account naming (GLOBAL SCOPE - use name_unique)."
  value = {
    # Storage accounts: max 24 chars, lowercase alphanumeric only, no dashes
    name        = substr(replace(local.resource_names["storage_account"].name, "-", ""), 0, local.resource_names["storage_account"].max_length)
    name_unique = substr("${replace(local.resource_names["storage_account"].name, "-", "")}${random_string.unique.result}", 0, local.resource_names["storage_account"].max_length)
    slug        = local.resource_names["storage_account"].slug
    max_length  = local.resource_names["storage_account"].max_length
    scope       = local.resource_names["storage_account"].scope
    regex       = local.resource_names["storage_account"].regex
  }
}

output "storage_container" {
  description = "Storage Container naming."
  value = {
    name        = local.resource_names["storage_container"].name
    name_unique = substr("${local.resource_names["storage_container"].name}${random_string.unique.result}", 0, local.resource_names["storage_container"].max_length)
    slug        = local.resource_names["storage_container"].slug
    max_length  = local.resource_names["storage_container"].max_length
    scope       = local.resource_names["storage_container"].scope
    regex       = local.resource_names["storage_container"].regex
  }
}

output "subnet" {
  description = "Subnet naming."
  value = {
    name        = local.resource_names["subnet"].name
    name_unique = "${local.resource_names["subnet"].name}${random_string.unique.result}"
    slug        = local.resource_names["subnet"].slug
    max_length  = local.resource_names["subnet"].max_length
    scope       = local.resource_names["subnet"].scope
    regex       = local.resource_names["subnet"].regex
  }
}

output "subscription" {
  description = "Subscription naming."
  value = {
    name        = local.resource_names["subscription"].name
    name_unique = "${local.resource_names["subscription"].name}${random_string.unique.result}"
    slug        = local.resource_names["subscription"].slug
    max_length  = local.resource_names["subscription"].max_length
    scope       = local.resource_names["subscription"].scope
    regex       = local.resource_names["subscription"].regex
  }
}

output "traffic_manager" {
  description = "Traffic Manager naming."
  value = {
    name        = local.resource_names["traffic_manager"].name
    name_unique = substr("${local.resource_names["traffic_manager"].name}${random_string.unique.result}", 0, local.resource_names["traffic_manager"].max_length)
    slug        = local.resource_names["traffic_manager"].slug
    max_length  = local.resource_names["traffic_manager"].max_length
    scope       = local.resource_names["traffic_manager"].scope
    regex       = local.resource_names["traffic_manager"].regex
  }
}

output "unique_seed" {
  description = "Seed used for unique name generation."
  value       = local.unique_seed
}

output "unique_suffix" {
  description = "Random suffix for globally unique names."
  value       = random_string.unique.result
}

output "unique_suffix_alpha" {
  description = "Random alphabetic suffix (no numbers)."
  value       = random_string.unique_alpha.result
}

output "virtual_hub" {
  description = "Virtual Hub naming."
  value = {
    name        = local.resource_names["virtual_hub"].name
    name_unique = "${local.resource_names["virtual_hub"].name}${random_string.unique.result}"
    slug        = local.resource_names["virtual_hub"].slug
    max_length  = local.resource_names["virtual_hub"].max_length
    scope       = local.resource_names["virtual_hub"].scope
    regex       = local.resource_names["virtual_hub"].regex
  }
}

output "virtual_machine" {
  description = "Virtual Machine naming (Windows - 15 char limit)."
  value = {
    name        = substr(local.resource_names["virtual_machine"].name, 0, local.resource_names["virtual_machine"].max_length)
    name_unique = substr("${local.resource_names["virtual_machine"].name}${random_string.unique.result}", 0, local.resource_names["virtual_machine"].max_length)
    slug        = local.resource_names["virtual_machine"].slug
    max_length  = local.resource_names["virtual_machine"].max_length
    scope       = local.resource_names["virtual_machine"].scope
    regex       = local.resource_names["virtual_machine"].regex
  }
}

output "virtual_machine_linux" {
  description = "Linux Virtual Machine naming (64 char limit)."
  value = {
    name        = local.resource_names["virtual_machine_linux"].name
    name_unique = "${local.resource_names["virtual_machine_linux"].name}${random_string.unique.result}"
    slug        = local.resource_names["virtual_machine_linux"].slug
    max_length  = local.resource_names["virtual_machine_linux"].max_length
    scope       = local.resource_names["virtual_machine_linux"].scope
    regex       = local.resource_names["virtual_machine_linux"].regex
  }
}

output "virtual_machine_scale_set" {
  description = "Virtual Machine Scale Set naming."
  value = {
    name        = local.resource_names["virtual_machine_scale_set"].name
    name_unique = "${local.resource_names["virtual_machine_scale_set"].name}${random_string.unique.result}"
    slug        = local.resource_names["virtual_machine_scale_set"].slug
    max_length  = local.resource_names["virtual_machine_scale_set"].max_length
    scope       = local.resource_names["virtual_machine_scale_set"].scope
    regex       = local.resource_names["virtual_machine_scale_set"].regex
  }
}

output "virtual_network" {
  description = "Virtual Network naming."
  value = {
    name        = local.resource_names["virtual_network"].name
    name_unique = "${local.resource_names["virtual_network"].name}${random_string.unique.result}"
    slug        = local.resource_names["virtual_network"].slug
    max_length  = local.resource_names["virtual_network"].max_length
    scope       = local.resource_names["virtual_network"].scope
    regex       = local.resource_names["virtual_network"].regex
  }
}

output "virtual_network_gateway" {
  description = "Virtual Network Gateway naming."
  value = {
    name        = local.resource_names["virtual_network_gateway"].name
    name_unique = "${local.resource_names["virtual_network_gateway"].name}${random_string.unique.result}"
    slug        = local.resource_names["virtual_network_gateway"].slug
    max_length  = local.resource_names["virtual_network_gateway"].max_length
    scope       = local.resource_names["virtual_network_gateway"].scope
    regex       = local.resource_names["virtual_network_gateway"].regex
  }
}

output "virtual_wan" {
  description = "Azure Virtual WAN naming."
  value = {
    name        = local.resource_names["virtual_wan"].name
    name_unique = "${local.resource_names["virtual_wan"].name}${random_string.unique.result}"
    slug        = local.resource_names["virtual_wan"].slug
    max_length  = local.resource_names["virtual_wan"].max_length
    scope       = local.resource_names["virtual_wan"].scope
    regex       = local.resource_names["virtual_wan"].regex
  }
}

output "vpn_gateway" {
  description = "VPN Gateway naming."
  value = {
    name        = local.resource_names["vpn_gateway"].name
    name_unique = "${local.resource_names["vpn_gateway"].name}${random_string.unique.result}"
    slug        = local.resource_names["vpn_gateway"].slug
    max_length  = local.resource_names["vpn_gateway"].max_length
    scope       = local.resource_names["vpn_gateway"].scope
    regex       = local.resource_names["vpn_gateway"].regex
  }
}

output "waf_policy" {
  description = "WAF Policy naming."
  value = {
    name        = local.resource_names["waf_policy"].name
    name_unique = "${local.resource_names["waf_policy"].name}${random_string.unique.result}"
    slug        = local.resource_names["waf_policy"].slug
    max_length  = local.resource_names["waf_policy"].max_length
    scope       = local.resource_names["waf_policy"].scope
    regex       = local.resource_names["waf_policy"].regex
  }
}


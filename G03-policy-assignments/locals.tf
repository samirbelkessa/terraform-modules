locals {
  all_caf_mg_assignments = merge(
    local.caf_root_assignments,
    local.caf_platform_assignments,
    local.caf_landing_zones_assignments,
    local.caf_archetype_assignments,
    local.caf_denylist_assignments
  )

  all_mg_assignments = merge(
    local.caf_transformed_assignments,
    var.management_group_assignments
  )

  builtin_not_allowed_resource_types_id = "/providers/Microsoft.Authorization/policyDefinitions/6c112d4e-5bc7-47ae-a041-ea2d9dccd749"

  caf_archetype_assignments = var.deploy_caf_assignments ? merge(
    local.has_online_prod ? {
      "online-prod-initiative" = {
        management_group_id      = var.caf_management_groups["online_prod"]
        policy_set_definition_id = lookup(var.caf_initiative_ids, "caf-online-prod", "")
        display_name             = "CAF Online Production"
        description              = "Policy initiative for Online Production Landing Zone."
        enforce                  = true
        identity_type            = "None"
        location                 = null
        parameters               = null
      }
    } : {},

    local.has_online_nonprod ? {
      "online-nonprod-init" = {
        management_group_id      = var.caf_management_groups["online_nonprod"]
        policy_set_definition_id = lookup(var.caf_initiative_ids, "caf-online-nonprod", "")
        display_name             = "CAF Online Non-Production"
        description              = "Policy initiative for Online Non-Production Landing Zone."
        enforce                  = true
        identity_type            = "None"
        location                 = null
        parameters               = null
      }
    } : {},

    local.has_corp_prod ? {
      "corp-prod-initiative" = {
        management_group_id      = var.caf_management_groups["corp_prod"]
        policy_set_definition_id = lookup(var.caf_initiative_ids, "caf-corp-prod", "")
        display_name             = "CAF Corporate Production"
        description              = "Policy initiative for Corporate Production Landing Zone."
        enforce                  = true
        identity_type            = "None"
        location                 = null
        parameters               = null
      }
    } : {},

    local.has_corp_nonprod ? {
      "corp-nonprod-initiative" = {
        management_group_id      = var.caf_management_groups["corp_nonprod"]
        policy_set_definition_id = lookup(var.caf_initiative_ids, "caf-corp-nonprod", "")
        display_name             = "CAF Corporate Non-Production"
        description              = "Policy initiative for Corporate Non-Production Landing Zone."
        enforce                  = true
        identity_type            = "None"
        location                 = null
        parameters               = null
      }
    } : {},

    local.has_sandbox ? {
      "sandbox-initiative" = {
        management_group_id      = var.caf_management_groups["sandbox"]
        policy_set_definition_id = lookup(var.caf_initiative_ids, "caf-sandbox", "")
        display_name             = "CAF Sandbox"
        description              = "Policy initiative for Sandbox Landing Zone - Audit mode with restrictions."
        enforce                  = true
        identity_type            = "None"
        location                 = null
        parameters               = null
      }
    } : {},

    local.has_decommissioned ? {
      "decom-initiative" = {
        management_group_id      = var.caf_management_groups["decommissioned"]
        policy_set_definition_id = lookup(var.caf_initiative_ids, "caf-decommissioned", "")
        display_name             = "CAF Decommissioned"
        description              = "Policy initiative for Decommissioned subscriptions - Denies all changes."
        enforce                  = true
        identity_type            = "None"
        location                 = null
        parameters               = null
      }
    } : {}
  ) : {}

  caf_denylist_assignments = merge(
    local.caf_denylist_corp,
    local.caf_denylist_online,
    local.caf_denylist_connectivity,
    local.caf_denylist_identity,
    local.caf_denylist_security,
    local.caf_denylist_management
  )

  caf_denylist_connectivity = var.deploy_caf_assignments && var.deploy_deny_resource_types && local.has_connectivity ? {
    "cnt-denylist" = {
      management_group_id  = var.caf_management_groups["connectivity"]
      policy_definition_id = local.builtin_not_allowed_resource_types_id
      display_name         = "Deny Application Workloads - Connectivity"
      description          = "Prevents application workloads from being deployed in Connectivity subscription(s)."
      enforce              = true
      identity_type        = "None"
      location             = null
      parameters = jsonencode({
        listOfResourceTypesNotAllowed = { value = var.deny_resource_types_connectivity }
      })
    }
  } : {}

  caf_denylist_corp = var.deploy_caf_assignments && var.deploy_deny_resource_types ? merge(
    local.has_corp_prod ? {
      "corp-prod-denylist" = {
        management_group_id  = var.caf_management_groups["corp_prod"]
        policy_definition_id = local.builtin_not_allowed_resource_types_id
        display_name         = "Deny Platform Resources - Corp Prod"
        description          = "Blocks connectivity/perimeter resource types from Corp Production landing zones."
        enforce              = true
        identity_type        = "None"
        location             = null
        parameters = jsonencode({
          listOfResourceTypesNotAllowed = { value = var.deny_resource_types_corp }
        })
      }
    } : {},
    local.has_corp_nonprod ? {
      "corp-np-denylist" = {
        management_group_id  = var.caf_management_groups["corp_nonprod"]
        policy_definition_id = local.builtin_not_allowed_resource_types_id
        display_name         = "Deny Platform Resources - Corp NonProd"
        description          = "Blocks connectivity/perimeter resource types from Corp Non-Production landing zones."
        enforce              = true
        identity_type        = "None"
        location             = null
        parameters = jsonencode({
          listOfResourceTypesNotAllowed = { value = var.deny_resource_types_corp }
        })
      }
    } : {}
  ) : {}

  caf_denylist_identity = var.deploy_caf_assignments && var.deploy_deny_resource_types && local.has_identity ? {
    "idt-denylist" = {
      management_group_id  = var.caf_management_groups["identity"]
      policy_definition_id = local.builtin_not_allowed_resource_types_id
      display_name         = "Deny Non-Identity Resources - Identity"
      description          = "Keeps Identity subscription focused on identity services. DC VMs/AADDS allowed."
      enforce              = true
      identity_type        = "None"
      location             = null
      parameters = jsonencode({
        listOfResourceTypesNotAllowed = { value = var.deny_resource_types_identity }
      })
    }
  } : {}

  caf_denylist_management = var.deploy_caf_assignments && var.deploy_deny_resource_types && local.has_management ? {
    "mgt-denylist" = {
      management_group_id  = var.caf_management_groups["management"]
      policy_definition_id = local.builtin_not_allowed_resource_types_id
      display_name         = "Deny Workloads - Management"
      description          = "Prevents workloads/perimeter in Management subscription. Keep for monitoring/automation."
      enforce              = true
      identity_type        = "None"
      location             = null
      parameters = jsonencode({
        listOfResourceTypesNotAllowed = { value = var.deny_resource_types_management }
      })
    }
  } : {}

  caf_denylist_online = var.deploy_caf_assignments && var.deploy_deny_resource_types ? merge(
    local.has_online_prod ? {
      "onl-prod-denylist" = {
        management_group_id  = var.caf_management_groups["online_prod"]
        policy_definition_id = local.builtin_not_allowed_resource_types_id
        display_name         = "Deny Connectivity Resources - Online Prod"
        description          = "Blocks core connectivity resource types from Online Production landing zones."
        enforce              = true
        identity_type        = "None"
        location             = null
        parameters = jsonencode({
          listOfResourceTypesNotAllowed = { value = var.deny_resource_types_online }
        })
      }
    } : {},
    local.has_online_nonprod ? {
      "onl-np-denylist" = {
        management_group_id  = var.caf_management_groups["online_nonprod"]
        policy_definition_id = local.builtin_not_allowed_resource_types_id
        display_name         = "Deny Connectivity Resources - Online NonProd"
        description          = "Blocks core connectivity resource types from Online Non-Production landing zones."
        enforce              = true
        identity_type        = "None"
        location             = null
        parameters = jsonencode({
          listOfResourceTypesNotAllowed = { value = var.deny_resource_types_online }
        })
      }
    } : {}
  ) : {}

  caf_denylist_security = var.deploy_caf_assignments && var.deploy_deny_resource_types && local.has_security ? {
    "sec-denylist" = {
      management_group_id  = var.caf_management_groups["security"]
      policy_definition_id = local.builtin_not_allowed_resource_types_id
      display_name         = "Deny Workloads - Security"
      description          = "Prevents workloads/perimeter in Security subscription. Keep for Sentinel/Defender/SIEM."
      enforce              = true
      identity_type        = "None"
      location             = null
      parameters = jsonencode({
        listOfResourceTypesNotAllowed = { value = var.deny_resource_types_security }
      })
    }
  } : {}

  caf_landing_zones_assignments = var.deploy_caf_assignments && local.has_landing_zones ? {
    "lz-backup-baseline" = {
      management_group_id      = var.caf_management_groups["landing_zones"]
      policy_set_definition_id = lookup(var.caf_initiative_ids, "caf-backup-baseline", "")
      display_name             = "CAF Backup Baseline"
      description              = "Enforces backup requirements for all Landing Zones."
      enforce                  = true
      identity_type            = "None"
      location                 = null
      parameters               = null
    }

    "lz-cost-baseline" = {
      management_group_id      = var.caf_management_groups["landing_zones"]
      policy_set_definition_id = lookup(var.caf_initiative_ids, "caf-cost-baseline", "")
      display_name             = "CAF Cost Management Baseline"
      description              = "Enforces cost management including budget requirements."
      enforce                  = true
      identity_type            = "None"
      location                 = null
      parameters               = null
    }
  } : {}

  caf_platform_assignments = var.deploy_caf_assignments ? merge(
    local.has_connectivity ? {
      "conn-net-baseline" = {
        management_group_id      = var.caf_management_groups["connectivity"]
        policy_set_definition_id = lookup(var.caf_initiative_ids, "caf-network-baseline", "")
        display_name             = "CAF Network Baseline"
        description              = "Enforces network baseline including hub validation and firewall routing."
        enforce                  = true
        identity_type            = "None"
        location                 = null
        parameters               = null
      }
    } : {},

    local.has_identity ? {
      "identity-baseline" = {
        management_group_id      = var.caf_management_groups["identity"]
        policy_set_definition_id = lookup(var.caf_initiative_ids, "caf-identity-baseline", "")
        display_name             = "CAF Identity Baseline"
        description              = "Enforces identity baseline including managed identity requirements."
        enforce                  = true
        identity_type            = "None"
        location                 = null
        parameters               = null
      }
    } : {},

    local.has_management ? {
      "mgmt-mon-baseline" = {
        management_group_id      = var.caf_management_groups["management"]
        policy_set_definition_id = lookup(var.caf_initiative_ids, "caf-monitoring-baseline", "")
        display_name             = "CAF Monitoring Baseline"
        description              = "Enforces monitoring baseline including Log Analytics retention."
        enforce                  = true
        identity_type            = "None"
        location                 = null
        parameters               = null
      }
    } : {}
  ) : {}

  caf_root_assignments = var.deploy_caf_assignments && local.has_root ? {
    "root-governance-baseline" = {
      management_group_id      = var.caf_management_groups["root"]
      policy_set_definition_id = lookup(var.caf_initiative_ids, "caf-governance-baseline", "")
      display_name             = "CAF Governance Baseline"
      description              = "Enforces governance baseline including allowed locations and required tags."
      enforce                  = true
      identity_type            = "None"
      location                 = null
      parameters               = null
    }

    "root-security-baseline" = {
      management_group_id      = var.caf_management_groups["root"]
      policy_set_definition_id = lookup(var.caf_initiative_ids, "caf-security-baseline", "")
      display_name             = "CAF Security Baseline"
      description              = "Enforces security baseline including storage security and Key Vault hardening."
      enforce                  = true
      identity_type            = "None"
      location                 = null
      parameters               = null
    }

    "root-azure-sec-bench" = {
      management_group_id      = var.caf_management_groups["root"]
      policy_set_definition_id = lookup(var.caf_builtin_initiative_ids, "azure_security_benchmark", "")
      display_name             = "Microsoft Cloud Security Benchmark"
      description              = "Azure Security Benchmark for comprehensive security coverage."
      enforce                  = false
      identity_type            = "None"
      location                 = null
      parameters               = null
    }
  } : {}

  caf_transformed_assignments = {
    for k, v in local.all_caf_mg_assignments : k => {
      management_group_id      = v.management_group_id
      policy_definition_id     = lookup(v, "policy_definition_id", null)
      policy_set_definition_id = lookup(v, "policy_set_definition_id", null)
      display_name             = v.display_name
      description              = v.description
      enforce                  = v.enforce
      parameters               = v.parameters
      non_compliance_message   = null
      identity_type            = v.identity_type
      identity_ids             = []
      location                 = v.location
      not_scopes               = []
      metadata                 = null
    }
  }

  default_non_compliance_messages = {
    governance = "This resource does not comply with the organization's governance policies. Contact the Platform Team for guidance."
    security   = "This resource does not meet security requirements. Private endpoints and encryption may be required."
    network    = "This resource does not comply with network topology requirements. Ensure hub-spoke connectivity is configured."
    backup     = "This resource does not meet backup requirements. Production resources require GRS backup."
    cost       = "This resource exceeds cost management restrictions for this environment."
  }

  defender_active_plans = {
    for k, v in local.defender_policy_catalog : k => v
    if var.deploy_defender_for_cloud && contains(var.defender_plans, k)
  }

  defender_policy_catalog = {

    # ── Cloud Security Posture Management ──────────────────────────────────
    cspm = {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/72f8cee7-2937-403d-84a1-a4e3e57f3c21"
      display_name         = "Configure Microsoft Defender CSPM plan"
      description          = "Defender CSPM — enhanced posture capabilities and cloud security graph."
    }

    # ── Cloud Workload Protection (CWPP) ──────────────────────────────────
    servers = {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/5eb6d64a-4086-4d7a-92da-ec51aed0332d"
      display_name         = "Configure Microsoft Defender for Servers plan"
      description          = "Defender for Servers — vulnerability assessment and advanced threat protection."
    }
    appsvc = {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/b40e7bcd-a1e5-47fe-b9cf-2f534d0bfb7d"
      display_name         = "Configure Defender for App Service"
      description          = "Defender for App Service — monitor for common web app attacks."
    }
    storage = {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/cfdc5972-75b3-4418-8ae1-7f5c36839390"
      display_name         = "Configure Defender for Storage"
      description          = "Defender for Storage — Activity Monitoring, Malware Scanning, Sensitive Data Detection."
    }
    containers = {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/c9ddb292-b203-4738-aead-18e2716e858f"
      display_name         = "Configure Defender for Containers"
      description          = "Defender for Containers — hardening, vulnerability assessment, runtime protections."
    }
    keyvault = {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1f725891-01c0-420a-9059-4fa46cb770b7"
      display_name         = "Configure Defender for Key Vault"
      description          = "Defender for Key Vault — detect unusual and potentially harmful access attempts."
    }
    arm = {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/b7021b2b-08fd-4dc0-9de7-3c6ece09faf9"
      display_name         = "Configure Defender for Resource Manager"
      description          = "Defender for Resource Manager — monitor management operations and detect threats."
    }

    # ── Databases (individual policies for granular control) ──────────────
    sqldb = {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/b99b73e7-074b-4089-9395-b7236f094491"
      display_name         = "Configure Defender for Azure SQL Database"
      description          = "Defender for Azure SQL — detect anomalous activities on SQL Databases."
    }
    sqlvm = {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/50ea7265-7d8c-429e-9a7d-ca1f410191c3"
      display_name         = "Configure Defender for SQL servers on machines"
      description          = "Defender for SQL on VMs — protect SQL Server on Azure and Arc machines."
    }
    ossdb = {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/44433aa3-7ec2-4002-93ea-65c65ff0310a"
      display_name         = "Configure Defender for open-source databases"
      description          = "Defender for OSS RDB — protect PostgreSQL, MySQL, MariaDB managed databases."
    }
    cosmosdb = {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/82bf5b87-728b-4a74-ba4d-6123845cf542"
      display_name         = "Configure Defender for Azure Cosmos DB"
      description          = "Defender for Cosmos DB — detect SQL injections and suspicious access patterns."
    }
    api = {
      policy_definition_id = var.custom_defender_policy_ids["api"]
      display_name         = "Deploy Microsoft Defender for APIs"
      description          = "Defender for APIs — monitor API-based attacks and security misconfigurations."
    }
    ai = {
      policy_definition_id = var.custom_defender_policy_ids["ai"]
      display_name         = "Deploy Microsoft Defender for AI Services"
      description          = "Defender for AI — detect threats on Azure AI/Cognitive Services."
    }
  }

  has_connectivity = contains(keys(var.caf_management_groups), "connectivity")

  has_corp_nonprod = contains(keys(var.caf_management_groups), "corp_nonprod")

  has_corp_prod = contains(keys(var.caf_management_groups), "corp_prod")

  has_decommissioned = contains(keys(var.caf_management_groups), "decommissioned")

  has_identity = contains(keys(var.caf_management_groups), "identity")

  has_landing_zones = contains(keys(var.caf_management_groups), "landing_zones")

  has_management = contains(keys(var.caf_management_groups), "management")

  has_online_nonprod = contains(keys(var.caf_management_groups), "online_nonprod")

  has_online_prod = contains(keys(var.caf_management_groups), "online_prod")

  has_platform = contains(keys(var.caf_management_groups), "platform")

  has_root = contains(keys(var.caf_management_groups), "root")

  has_sandbox = contains(keys(var.caf_management_groups), "sandbox")

  has_security = contains(keys(var.caf_management_groups), "security")

  mg_assignments_with_identity = {
    for k, v in local.all_mg_assignments : k => v
    if v.identity_type == "SystemAssigned" || v.identity_type == "UserAssigned"
  }

  rg_assignments_with_identity = {
    for k, v in var.resource_group_assignments : k => v
    if v.identity_type == "SystemAssigned" || v.identity_type == "UserAssigned"
  }

  standard_metadata = jsonencode({
    createdBy = "Terraform"
    project   = "Australia Landing Zone"
    source    = "CAF Landing Zone - G03 Policy Assignments"
  })

  sub_assignments_with_identity = {
    for k, v in var.subscription_assignments : k => v
    if v.identity_type == "SystemAssigned" || v.identity_type == "UserAssigned"
  }

  valid_caf_mg_assignments = local.all_caf_mg_assignments

}

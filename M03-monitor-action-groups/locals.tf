locals {
  all_action_groups = merge(local.default_action_groups, var.action_groups)

  base_name = var.custom_name != null ? var.custom_name : module.naming.name

  default_action_groups = var.create_default_action_groups ? {
    critical = {
      short_name = "Critical"
      enabled    = true
      email_receivers = [
        for receiver in var.default_email_receivers : {
          name                    = receiver.name
          email_address           = receiver.email_address
          use_common_alert_schema = true
        }
      ]
      sms_receivers = []

      webhook_receivers = var.default_webhook_url != null && var.default_webhook_url != "" ? [{
        name                    = "DefaultWebhook"
        service_uri             = var.default_webhook_url
        use_common_alert_schema = true
        aad_auth                = null
      }] : []
      azure_function_receivers     = []
      logic_app_receivers          = []
      automation_runbook_receivers = []
      voice_receivers              = []
      arm_role_receivers           = []
      event_hub_receivers          = []
      itsm_receivers               = []
    }
    warning = {
      short_name = "Warning"
      enabled    = true
      email_receivers = [
        for receiver in var.default_email_receivers : {
          name                    = receiver.name
          email_address           = receiver.email_address
          use_common_alert_schema = true
        }
      ]
      sms_receivers                = []
      webhook_receivers            = []
      azure_function_receivers     = []
      logic_app_receivers          = []
      automation_runbook_receivers = []
      voice_receivers              = []
      arm_role_receivers           = []
      event_hub_receivers          = []
      itsm_receivers               = []
    }
    info = {
      short_name = "Info"
      enabled    = true
      email_receivers = [
        for receiver in var.default_email_receivers : {
          name                    = receiver.name
          email_address           = receiver.email_address
          use_common_alert_schema = true
        }
      ]
      sms_receivers                = []
      webhook_receivers            = []
      azure_function_receivers     = []
      logic_app_receivers          = []
      automation_runbook_receivers = []
      voice_receivers              = []
      arm_role_receivers           = []
      event_hub_receivers          = []
      itsm_receivers               = []
    }
  } : {}

  tags = merge(
    var.tags,
    {
      Module = "M03-monitor-action-groups"
    }
  )

}

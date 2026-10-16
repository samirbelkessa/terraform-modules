locals {
  default_tags = {
    ManagedBy = "Terraform"
    Module    = "S01-defender-for-cloud"
  }

  disabled_defender_plans = {
    for plan, config in var.defender_plans : plan => config
    if !config.enabled
  }

  enabled_defender_plans = {
    for plan, config in var.defender_plans : plan => config
    if config.enabled
  }

  plan_tier_mapping = {
    for plan, config in var.defender_plans : plan => {
      tier    = config.enabled ? "Standard" : "Free"
      subplan = config.subplan
    }
  }

  tags = merge(local.default_tags, var.tags)

}

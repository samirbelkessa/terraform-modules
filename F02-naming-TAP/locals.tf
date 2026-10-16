locals {
  azure_region = local.region_valid ? var.region_map[var.region].azure_region : "unknown"

  base_prefix = "${local.customer_code}${local.environment_code}${local.region_code}${local.tier_code}"

  context1_code = var.context1 != "" ? lower(var.context1) : ""

  context2_code = var.context2 != "" ? lower(var.context2) : ""

  context_suffix = local.context1_code != "" ? "${local.context1_code}${local.context2_code}" : local.context2_code

  customer_code = lower(var.customer)

  environment_code = lower(var.environment)

  environment_name = contains(keys(var.environment_map), var.environment) ? var.environment_map[var.environment].name : "Unknown"

  landing_zone_name = var.landing_zone != "" && contains(keys(var.landing_zone_map), var.landing_zone) ? var.landing_zone_map[var.landing_zone].name : ""

  landing_zone_type = var.landing_zone != "" && contains(keys(var.landing_zone_map), var.landing_zone) ? var.landing_zone_map[var.landing_zone].type : ""

  lz_code = var.landing_zone != "" ? lower(var.landing_zone) : ""

  lz_suffix = local.lz_code != "" ? local.lz_code : ""

  naming_metadata = {
    customer          = local.customer_code
    environment       = local.environment_code
    environment_name  = local.environment_name
    region            = local.region_code
    azure_region      = local.azure_region
    tier              = var.tier
    tier_name         = local.tier_name
    landing_zone      = local.lz_code
    landing_zone_name = local.landing_zone_name
    context1          = local.context1_code
    context2          = local.context2_code
    base_prefix       = local.base_prefix
  }

  region_code = lower(var.region)

  region_valid = contains(keys(var.region_map), var.region)

  resource_group_name = var.use_separator_for_rg ? join("-", compact([
    local.customer_code,
    local.environment_code,
    local.region_code,
    local.tier_code,
    var.resource_map["resource_group"].slug,
    local.lz_suffix,
    local.context_suffix
  ])) : local.resource_names["resource_group"].name

  resource_names = {
    for resource_key, resource_config in var.resource_map : resource_key => {
      # Base name without trimming
      raw_name = join("", compact([
        local.base_prefix,
        resource_config.slug,
        local.lz_suffix,
        local.context_suffix
      ]))

      # Trimmed name respecting max_length
      name = substr(
        join("", compact([
          local.base_prefix,
          resource_config.slug,
          local.lz_suffix,
          local.context_suffix
        ])),
        0,
        resource_config.max_length
      )

      # Unique name with random suffix (for global scope resources)
      # Calculate available space for unique suffix
      base_for_unique = join("", compact([
        local.base_prefix,
        resource_config.slug,
        local.lz_suffix,
        local.context1_code
      ]))

      # Maximum unique suffix length considering max_length constraint
      max_unique_suffix = min(
        var.unique_length,
        resource_config.max_length - length(join("", compact([
          local.base_prefix,
          resource_config.slug,
          local.lz_suffix,
          local.context1_code
        ])))
      )

      # Resource configuration passthrough
      slug            = resource_config.slug
      max_length      = resource_config.max_length
      scope           = resource_config.scope
      allow_dashes    = resource_config.allow_dashes
      allow_uppercase = resource_config.allow_uppercase
      regex           = resource_config.regex
      description     = resource_config.description
    }
  }

  tier_code = tostring(var.tier)

  tier_name = contains(keys(var.tier_map), tostring(var.tier)) ? var.tier_map[tostring(var.tier)].name : "Unknown"

  unique_seed = var.unique_seed != "" ? var.unique_seed : "${local.base_prefix}${local.context_suffix}"

}

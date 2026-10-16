locals {
  resolved_associations = {
    for assoc_key, assoc in var.data_collection_rule_associations : assoc_key => {
      target_resource_id = assoc.target_resource_id
      data_collection_rule_id = try(
        azurerm_monitor_data_collection_rule.this[assoc.data_collection_rule_id].id,
        null
      )
      description = try(assoc.description, "Association managed by M07")
    }
  }

  tags = merge(
    var.tags,
    {
      Module = "M07-data-collection-rules"
    }
  )

  valid_associations = {
    for k, v in local.resolved_associations : k => v
    if v.data_collection_rule_id != null
  }

}

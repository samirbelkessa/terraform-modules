resource "random_string" "suffix" {
  count   = var.random_suffix_length > 0 ? 1 : 0
  upper   = !local.resource_def.lowercase
  special = false
  numeric = true
  lower   = true
  length  = var.random_suffix_length
}


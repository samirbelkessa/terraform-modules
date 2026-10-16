resource "random_string" "unique" {
  upper   = false
  special = false
  numeric = true
  lower   = true
  length  = var.unique_length
  keepers = {
    seed = local.unique_seed
  }
}

resource "random_string" "unique_alpha" {
  upper   = false
  special = false
  numeric = false
  lower   = true
  length  = var.unique_length
  keepers = {
    seed = local.unique_seed
  }
}

resource "null_resource" "validate_region" {
  count = local.region_valid ? 0 : 1
  provisioner "local-exec" {
    command = "echo 'ERROR: Region code ${var.region} is not defined in region_map' && exit 1"
  }
}


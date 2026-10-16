resource "terraform_data" "sandbox_expiration_check" {
  count = local.sandbox_expiration_error ? 1 : 0

  lifecycle {
    precondition {
      error_message = "Sandbox environment requires an expiration_date. Set expiration_date or disable enforce_sandbox_expiration."
      condition     = !local.sandbox_expiration_error
    }
  }

}

resource "terraform_data" "tag_validation" {
  lifecycle {
    precondition {
      error_message = "Owner tag cannot be empty."
      condition     = length(var.owner) > 0
    }

    precondition {
      error_message = "CostCenter tag cannot be empty."
      condition     = length(var.cost_center) > 0
    }

    precondition {
      error_message = "Application tag cannot be empty."
      condition     = length(var.application) > 0
    }
  }

}


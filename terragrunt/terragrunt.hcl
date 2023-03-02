# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = try(read_terragrunt_config(find_in_parent_folders("region.hcl")))

  # Automatically load environment-level variables
  environment_vars = try(read_terragrunt_config(find_in_parent_folders("env.hcl")))

  # Automatically load common variables
  common_vars = read_terragrunt_config(find_in_parent_folders("common_vars.hcl"))

  # Extract the variables we need for easy access
  account_id       = local.account_vars.locals.aws_account_id
  account_type     = local.account_vars.locals.account_type
  aws_region       = local.region_vars.locals.aws_region
  environment      = local.environment_vars.locals.environment
  application_name = basename(get_terragrunt_dir())
  application_id   = join("", regexall("\\b[a-z]", local.application_name)) # Make abbreviation from application_name
  customer_code    = local.common_vars.locals.customer_code
  name_prefix      = "${local.customer_code}-${local.environment}-${local.application_id}"
  default_aws_tags = {
    "Application"   = local.application_name
    "ApplicationId" = local.application_id
    "CostCenter"    = local.common_vars.locals.cost_center
    "CustomerCode"  = local.customer_code
    "Environment"   = local.environment
    "BuiltBy"       = "Terraform"
  }
  default_aws_tags_json = jsonencode(local.default_aws_tags)
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  default_tags {
    tags = ${local.default_aws_tags_json}
  }
  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${local.account_id}"]
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt               = true
    bucket                = "${local.customer_code}-shared-tf-state"
    key                   = "${path_relative_to_include()}/terraform.tfstate"
    region                = "eu-west-1"
    dynamodb_table        = "${local.customer_code}-shared-tf-state-locking"
    disable_bucket_update = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.common_vars.locals,
  local.account_vars.locals,
  local.region_vars.locals,
  local.environment_vars.locals,
)

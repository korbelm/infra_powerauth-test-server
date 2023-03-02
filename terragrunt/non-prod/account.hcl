# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  aws_account_id = ""
  account_type   = basename(get_terragrunt_dir())
}
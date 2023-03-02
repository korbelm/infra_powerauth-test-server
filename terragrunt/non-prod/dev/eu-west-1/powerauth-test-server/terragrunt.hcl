# ---------------------------------------------------------------------------------------------------------------------
# Include configurations that are common used across multiple environments.
# ---------------------------------------------------------------------------------------------------------------------

# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# components and environments, such as how to configure remote state.
include "root" {
  path   = find_in_parent_folders()
  expose = true
}

# Include the envcommon configuration for the component. The envcommon configuration contains settings that are common
# for the component across all environments.
terraform {
  source = "${get_repo_root()}/terraform//powerauth-test-server"
}

inputs = {
  name_prefix       = "${include.root.locals.name_prefix}"
  vpc_id            = "${include.root.locals.region_vars.locals.vpc_id}"
  image             = "${include.root.locals.account_id}.dkr.ecr.eu-west-1.amazonaws.com/powerauth-test-server:latest"
  db_instance_class = "db.t3.micro"
  db_storage        = 10
}

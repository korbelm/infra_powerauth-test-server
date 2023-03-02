locals {
  db_name  = "powerauth"
  db_pass  = random_password.main.result
  jdbc_url = "jdbc:postgresql://${module.rds.endpoint}/powerauth"
}
resource "random_password" "main" {
  length           = 16
  special          = true
  override_special = "_!%^"
}

module "alb" {
  source = "../modules/alb"

  vpc_id      = var.vpc_id
  name_prefix = var.name_prefix
}
module "rds" {
  source = "../modules/rds"

  vpc_id         = var.vpc_id
  name_prefix    = var.name_prefix
  instance_class = var.db_instance_class
  storage        = var.db_storage
  db_name        = local.db_name
  username       = local.db_name
  password       = local.db_pass
}
module "ecs" {
  source = "../modules/ecs"

  vpc_id           = var.vpc_id
  name_prefix      = var.name_prefix
  target_group_arn = module.alb.target_group_arn
  alb_sg_id        = module.alb.sg_id

  image        = var.image
  service_port = 8080
  app_count    = 1
  env_vars = [
    {
      "name" : "POWERAUTH_TEST_SERVER_ENROLLMENT_SERVER_URL",
      "value" : "http://localhost:8080/enrollment-server"
    },
    {
      "name" : "POWERAUTH_TEST_SERVER_DATASOURCE_URL",
      "value" : local.jdbc_url
    },
    { "name" : "POWERAUTH_TEST_SERVER_DATASOURCE_USERNAME", "value" : local.db_name },
    { "name" : "POWERAUTH_TEST_SERVER_DATASOURCE_PASSWORD", "value" : local.db_pass }
  ]
}

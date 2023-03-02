data "aws_region" "current" {}
data "aws_vpc" "default" {
  id = var.vpc_id
}
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

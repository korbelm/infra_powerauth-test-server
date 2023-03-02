# VPC Endpoint Security Group
resource "aws_security_group" "vpc_endpoint" {
  name   = "${var.name_prefix}-vpce-sg"
  vpc_id = data.aws_vpc.default.id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }
}
# VPC Endpoints
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = data.aws_vpc.default.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [data.aws_vpc.default.main_route_table_id]
  tags = {
    Name        = "s3-endpoint"
  }
}
resource "aws_vpc_endpoint" "rds" {
  vpc_id              = data.aws_vpc.default.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.rds"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]
  subnet_ids = data.aws_subnets.default.ids.*
  tags = {
    Name        = "rds-endpoint"
  }
}
resource "aws_vpc_endpoint" "rds-data" {
  vpc_id              = data.aws_vpc.default.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.rds-data"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]
  subnet_ids = data.aws_subnets.default.ids.*
  tags = {
    Name        = "rds-data-endpoint"
  }
}
resource "aws_vpc_endpoint" "dkr" {
  vpc_id              = data.aws_vpc.default.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]
  subnet_ids = data.aws_subnets.default.ids.*
  tags = {
    Name        = "dkr-endpoint"
  }
}
resource "aws_vpc_endpoint" "dkr_api" {
  vpc_id              = data.aws_vpc.default.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]
  subnet_ids = data.aws_subnets.default.ids.*
  tags = {
    Name        = "dkr-api-endpoint"
  }
}
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = data.aws_vpc.default.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]
  subnet_ids = data.aws_subnets.default.ids.*
  tags = {
    Name        = "logs-endpoint"
  }
}
# For ccnnection to container via execute command
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = data.aws_vpc.default.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]
  subnet_ids = data.aws_subnets.default.ids.*
  tags = {
    Name        = "ssmmessages-endpoint"
  }
}

module "powerauth-test-server-ecr-repo" {
  source = "../modules/ecr_repo"
  name   = "powerauth-test-server"
}
module "vpc_endpoints" {
  source      = "../modules/vpc_endpoints"
  name_prefix = "infra"
  vpc_id      = var.vpc_id
}

# MGMT EC2 for debugging purpose
#resource "aws_key_pair" "main" {
#  key_name = "default_key"
#  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOwVWTiK9TWuUff4LHm1gEwZOROoyMFG/jqgwyvPMGka"
#}
#
#resource "aws_security_group" "mgmt" {
#  name   = "${var.name_prefix}-mgmt-ssh"
#  vpc_id = var.vpc_id
#
#  ingress {
#    protocol        = "tcp"
#    from_port       = 22
#    to_port         = 22
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  egress {
#    protocol    = "-1"
#    from_port   = 0
#    to_port     = 0
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#}
#
#resource "aws_instance" "mgmt" {
#  ami           = "ami-065793e81b1869261"
#  instance_type = "t3.micro"
#  key_name = aws_key_pair.main.key_name
#  associate_public_ip_address = true
#  vpc_security_group_ids = [aws_security_group.mgmt.id]
#}

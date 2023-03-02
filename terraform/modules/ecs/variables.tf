variable "vpc_id" {
  type = string
}
variable "name_prefix" {
  type = string
}
variable "app_count" {
  type = number
  default = 1
}
variable "target_group_arn" {
  type = string
}
variable "alb_sg_id" {
  type = string
}
variable "image" {
  type = string
}
variable "service_port" {
  type = number
}
variable "env_vars" {
  type = list
}

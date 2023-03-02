output "dns_name" {
  value = aws_lb.default.dns_name
}
output "target_group_arn" {
  value = aws_lb_target_group.http.arn
}
output "sg_id" {
  value = aws_security_group.lb.id
}

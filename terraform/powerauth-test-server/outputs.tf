output "app_url" {
  value = "http://${module.alb.dns_name}/powerauth-test-server"
}
output "db_url" {
  value = local.jdbc_url
}
output "db_name" {
  value = local.db_name
}
output "db_user" {
  value = local.db_name
}
output "db_pass" {
  value     = local.db_pass
  sensitive = true
}

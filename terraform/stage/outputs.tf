# output "app_external_ip" {
#   value = "${google_compute_instance.app.*.network_interface.0.access_config.0.nat_ip}"
# }

# output "lb_ip_address" {
#   value = "${google_compute_forwarding_rule.http.ip_address}"
# }

output "app_external_ip" {
  value = "${module.app.app_external_ip}"
}

output "db_internal_ip" {
  value = "${module.db.db_internal_ip}"
}

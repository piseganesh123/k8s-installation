output "server_public_ip" {
  value = google_compute_instance.linux_master_server_1.network_interface.0.access_config.0.nat_ip
}
output "server_public_ip" {
  value = google_compute_instance.docker_master_server.network_interface.0.access_config.0.nat_ip
}
resource "google_service_account" "default" {
  account_id   = "tf-service-account-for-demo"
  display_name = "tf-service-account created for demo"
}

resource "google_compute_instance" "default" {
  name         = "test"
  machine_type = "e2-medium"
  zone         = "asia-south1-c"

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-jammy-v20230616"
      labels = {
        my_label = "value"
      }
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    foo = "bar"
  }

  scheduling {
    preemptible = "true"
    provisioning_model = "SPOT"
    automatic_restart = "false"
  }
  metadata_startup_script = "sudo apt install git -y && git clone https://github.com/piseganesh123/k8s-installation.git && cd k8s-installation/k8s-on-gcp-vm && sudo sh ./k8s-bootstrap-tool-config.sh && sudo sh ./k8s-mst-config.sh"
     
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}
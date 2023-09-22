# GCP infrastructure resources

resource "tls_private_key" "global_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_sensitive_file" "ssh_private_key_pem" {
  filename        = "${path.module}/id_rsa_${formatdate("MM-DD", timestamp())}"
  content         = tls_private_key.global_key.private_key_pem
  file_permission = "0600"
}

resource "local_file" "ssh_public_key_openssh" {
  filename = "${path.module}/id_rsa.pub"
  content  = tls_private_key.global_key.public_key_openssh
}

# Firewall Rule to allow all traffic
resource "google_compute_firewall" "k8s_trn_fw_allowall" {
  name    = "${var.prefix}-k8s-fw-allowall"
  network = "default"

  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}

# GCP Compute Instance for creating a single node RKE cluster and installing the Rancher server
resource "google_compute_instance" "k8s_master_server" {
  depends_on = [
    google_compute_firewall.k8s_trn_fw_allowall,
  ]

  scheduling {
    preemptible = "true"
    provisioning_model = "SPOT"
    automatic_restart = "false"
  }
  
  name         = "${var.prefix}-k8s-mst-server"
  machine_type = var.machine_type
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-jammy-v20230727"
      size = "15"
    }
  }

  network_interface {
    network = "default"
    access_config {
//      nat_ip = google_compute_address.rancher_server_address.address
    }
  }

  metadata = {
    ssh-keys       = "${local.node_username}:${tls_private_key.global_key.public_key_openssh}"
    enable-oslogin = "FALSE"
  }

  metadata_startup_script = "sudo apt install git -y && git clone https://github.com/piseganesh123/k8s-installation.git && cd k8s-installation/k8s-on-gcp-vm && sudo sh ./k8s-bootstrap-tool-config.sh && sudo sh ./k8s-mst-config.sh"

  provisioner "remote-exec" {
    inline = [
      "echo 'SSH connection worked'",
//      "sudo apt install git -y && git clone https://github.com/piseganesh123/k8s-installation.git && cd k8s-installation/k8s-on-gcp-vm && sudo sh ./k8s-bootstrap-tool-config.sh && sudo sh ./k8s-mst-config.sh",
    ]

    connection {
      type        = "ssh"
      host        = self.network_interface.0.access_config.0.nat_ip
      user        = local.node_username
      private_key = tls_private_key.global_key.private_key_pem
    }
  }
}
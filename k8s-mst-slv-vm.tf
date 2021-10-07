// Create VM for Ansible client
// Configure the Google Cloud provider

variable "project_id" {
  type = string
  default = "vast-pad-319812"
}
variable "region" {
  type = string
  default = "asia-south1"
}
provider "google" {
 credentials = file("/home/piseg432/keys/gce-creator.json")
// credentials =  $(GOOGLE_CLOUD_KEYFILE_JSON)
 //project     = "vast-pad-31912"
 project     = var.project_id
  region      = var.region
}

# We create a public IP address for our google compute instance to utilize
resource "google_compute_address" "static" {
  name = "vm-public-address"
  project = var.project_id
  region = var.region
//  depends_on = [ google_compute_firewall.firewall ]
}
// A single Compute Engine instance
resource "google_compute_instance" "k8s-mast-instance" {
 // name         = "prografana-poc-vm-${random_id.instance_id.hex}"
 name = "k8s-mst-tf"
 machine_type = "e2-medium"
 zone         = "asia-south1-c"
 tags = ["allow-all-kube-ingress"]
  labels = {
    "purpose" = "poc"
    "preserve" = "no"
  }
  boot_disk {
    initialize_params {
      image = "ubuntu-1804-bionic-v20210720"
    }
  }
  metadata_startup_script = file("k8s-mst-config.sh")

 network_interface {
   network = "default"

   access_config {
     nat_ip = google_compute_address.static.address
       }
  }
  metadata = {
//   ssh-keys = "piseg432_gmail_com:${file("~/.ssh/id_rsa.pub")}"
   ssh-keys = "piseg432:${file("~/.ssh/id_rsa.pub")}"
   // enable-oslogin = "TRUE"
  }
  
}

output "instance_ip_addr" {
  value = "${google_compute_instance.k8s-mast-instance.hostname}"
}

resource "google_compute_instance" "k8s-wrk-instance" {
 name = "k8s-wrk-tf"
 machine_type = "e2-medium"
 zone         = "asia-south1-c"
 tags = ["allow-all-kube-ingress"]
  labels = {
    "purpose" = "poc"
    "preserve" = "no"
  }
  boot_disk {
    initialize_params {
      image = "ubuntu-1804-bionic-v20210720"
    }
  }
  metadata_startup_script = file("k8s-slv-config.sh")
 network_interface {
   network = "default"

   access_config {
     ////nat_ip = google_compute_address.static.address
     }
  }
  metadata = {
//   ssh-keys = "piseg432_gmail_com:${file("~/.ssh/id_rsa.pub")}"
//   enable-oslogin = "TRUE"
   ssh-keys = "piseg432:${file("~/.ssh/id_rsa.pub")}"
  }
}

module "firewall_rules" {
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  project_id   = var.project_id
//  network_name = google_compute_network.default.name
  network_name = "default"
  rules = [{
    name                    = "allow-mst-slv-ingress-kube"
    description             = "accepts master to slave traffic"
    direction               = "INGRESS"
    priority                = null
    ranges                  = ["0.0.0.0/0"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = ["allow-all-kube-ingress"]
    target_service_accounts = null
    allow = [{
      protocol = "tcp"
      ports    = [""]
    }]
    deny = []
    log_config = {
      metadata = "EXCLUDE_ALL_METADATA"
    }
  }]
}
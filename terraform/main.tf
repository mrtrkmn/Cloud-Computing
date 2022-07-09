provider "google" {
  project     = var.project
  region      = var.region
  credentials = file(var.access_file)
}

resource "google_compute_firewall" "firewall" {
  name    = "kubernetes-the-hard-way-allow-external"
  network = "default"

  allow {
    protocol = "tcp" # ssh, http, https and kubernetes communication
    ports    = ["22","80","443", "6443"]
  }
  allow {
    protocol = "tcp"
    ports    = ["4243"]
  }

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }
  allow {  # kubernetes node port range
    protocol = "tcp"
    ports   = ["30000-32767"] 
  }


  source_ranges = ["0.0.0.0/0"] # Not So Secure. Limit the Source Range
  target_tags   = ["firewall-rules"]
}



# We create a public IP address for our google compute instance to utilize
resource "google_compute_address" "static" {
  name       = "vm-public-address"
  project    = var.project
  region     = var.region
  depends_on = [google_compute_firewall.firewall]
}


resource "google_compute_instance" "dev" {
  name         = "kube-master"                  # name of the server
  machine_type = "n1-standard-2"              # machine type refer google machine types
  zone         = "${var.region}-a"            # `a` zone of the selected region in our case us-central-1a
  tags         = ["firewall-rules", "kubernetes"] # selecting the vm instances with tags

  # to create a startup disk with an Image/ISO. 
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  # We can create our own network or use the default one like we did here
  network_interface {
    network = "default"

    # assigning the reserved public IP to this instance
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  # This is copy the the SSH public Key to enable the SSH Key based authentication
  metadata = {
    ssh-keys = "${var.user}:${file(var.publickeypath)}"
  }


  # Ensure firewall rule is provisioned before server, so that SSH doesn't fail.
  depends_on = [google_compute_firewall.firewall]

  # Defining what service account should be used for creating the VM
  service_account {
    email  = var.email
    scopes = ["compute-ro"]
  }


}

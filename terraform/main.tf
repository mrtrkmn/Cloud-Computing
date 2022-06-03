provider "google" {
  project     = var.project
  region      = var.region
  credentials = file(var.access_file)
}

resource "google_compute_firewall" "firewall" {
  name    = "gritfy-firewall-externalssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  allow {
    protocol = "tcp"
    ports    = ["4243"]
  }

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }

  source_ranges = ["0.0.0.0/0"] # Not So Secure. Limit the Source Range
  target_tags   = ["externalssh"]
}


resource "google_compute_firewall" "webserverrule" {
  name    = "gritfy-webserver"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"] # Not So Secure. Limit the Source Range
  target_tags   = ["webserver"]
}

# We create a public IP address for our google compute instance to utilize
resource "google_compute_address" "static" {
  name       = "vm-public-address"
  project    = var.project
  region     = var.region
  depends_on = [google_compute_firewall.firewall]
}


resource "google_compute_instance" "dev" {
  name         = "devserver"                  # name of the server
  machine_type = "e2-standard-2"              # machine type refer google machine types
  zone         = "${var.region}-a"            # `a` zone of the selected region in our case us-central-1a
  tags         = ["externalssh", "webserver"] # selecting the vm instances with tags

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


  provisioner "file" {
    connection {
      host = google_compute_address.static.address
      type = "ssh"
      # username of the instance would vary for each account refer the OS Login in GCP documentation
      user    = var.user
      timeout = "500s"
      # private_key being used to connect to the VM. ( the public key was copied earlier using metadata )
      private_key = file(var.privatekeypath)
    }

    source      = "scripts/install-tools.sh"
    destination = "/tmp/install-tools.sh"
  }

  provisioner "file" {
    connection {
      host = google_compute_address.static.address
      type = "ssh"
      # username of the instance would vary for each account refer the OS Login in GCP documentation
      user    = var.user
      timeout = "500s"
      # private_key being used to connect to the VM. ( the public key was copied earlier using metadata )
      private_key = file(var.privatekeypath)
    }

    source      = "../exercise-2/docker-compose.yml"
    destination = "/home/${var.user}/docker-compose.yml"
  }

  provisioner "file" {
    connection {
      host = google_compute_address.static.address
      type = "ssh"
      # username of the instance would vary for each account refer the OS Login in GCP documentation
      user    = var.user
      timeout = "500s"
      # private_key being used to connect to the VM. ( the public key was copied earlier using metadata )
      private_key = file(var.privatekeypath)
    }
    source      = "configs/docker.service"
    destination = "/tmp/docker.service"
  }



  # to connect to the instance after the creation and execute few commands for provisioning
  # here you can execute a custom Shell script or Ansible playbook
  provisioner "remote-exec" {
    connection {
      host = google_compute_address.static.address
      type = "ssh"
      # username of the instance would vary for each account refer the OS Login in GCP documentation
      user    = var.user
      timeout = "500s"
      # private_key being used to connect to the VM. ( the public key was copied earlier using metadata )
      private_key = file(var.privatekeypath)
    }

    # Commands to be executed as the instance gets ready.
    # installing mongoDB
    inline = [
      "chmod +x /tmp/install-tools.sh",
      "sudo bash /tmp/install-tools.sh"
    ]
  }

  # Ensure firewall rule is provisioned before server, so that SSH doesn't fail.
  depends_on = [google_compute_firewall.firewall, google_compute_firewall.webserverrule]

  # Defining what service account should be used for creating the VM
  service_account {
    email  = var.email
    scopes = ["compute-ro"]
  }


}

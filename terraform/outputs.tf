output "public_ip_address" {
  value = google_compute_address.static.address
}

output "instance_username" {
  value = var.user
}


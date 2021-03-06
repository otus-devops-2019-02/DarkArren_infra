resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"
  tags         = ["reddit-app"]

  boot_disk {
    initialize_params {
      image = "${var.app_disk_image}"
    }
  }

  network_interface {
    network = "default"

    access_config = {
      nat_ip = "${google_compute_address.app_ip.address}"
    }
  }

  metadata {
    ssh-keys = "${var.ssh_user}:${file(var.public_key_path)}"
  }

  connection {
    type        = "ssh"
    user        = "${var.ssh_user}"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }

  # provisioner "file" {
  #   source      = "${path.module}/files/puma.service"
  #   destination = "/tmp/puma.service"
  # }
  # provisioner "remote-exec" {
  #   inline = ["echo '[Unit]\nDescription=Puma HTTP Server\nAfter=network.target\n\n[Service]\nType=simple\nUser=${var.ssh_user}\nWorkingDirectory=/home/${var.ssh_user}/reddit\nExecStart=/bin/bash -lc 'puma'\nRestart=always\n\n[Install]\nWantedBy=multi-user.target' >> /tmp/puma.service"]
  # }

  # provisioner "remote-exec" {
  #   script = "${path.module}/files/deploy.sh"
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "echo 'export DATABASE_URL=${var.db_internal_address}' >> ~/.profile",
  #     "export DATABASE_URL=${var.db_internal_address}",
  #     "sudo systemctl restart puma.service",
  #   ]
  # }
}

resource "google_compute_address" "app_ip" {
  name = "reddit-app-ip"
}

resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = "default"

  allow {
    protocol = "tcp"

    ports = ["9292"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}

resource "google_compute_firewall" "firewall_nginx" {
  name    = "allow-nginx-default"
  network = "default"

  allow {
    protocol = "tcp"

    ports = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}

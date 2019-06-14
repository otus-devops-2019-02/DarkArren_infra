provider "google" {
  # Версия провайдера
  version = "2.0.0"

  # ID проекта
  project = "${var.project}"
  region  = "${var.region}"

  # project = "infra-242917"
  # region = "europe-west-1"
}

resource "google_compute_project_metadata" "default" {
  metadata {
    ssh-keys = "appuser1:${file(var.public_key_path)} appuser2:${file(var.public_key_path)} appuser3:${file(var.public_key_path)} appuser4:${file(var.public_key_path)} appuser5:${file(var.public_key_path)}"
  }
}

resource "google_compute_instance" "app" {
  count        = "${var.count}"
  name         = "reddit-app${count.index}"
  machine_type = "g1-small"

  # zone = "europe-west1-b"
  zone = "${var.zone}"
  tags = ["reddit-app"]

  metadata {
    # путь до публичного ключа
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  # определение загрузочного диска
  boot_disk {
    initialize_params {
      # image = "reddit-base"
      image = "${var.disk_image}"
    }
  }

  # определение сетевого интерфейса
  network_interface {
    # сеть, к которой присоединить данный интерфейс
    network = "default"

    # использовать ephemeral IP для доступа из Интернет
    access_config {}
  }

  connection {
    type  = "ssh"
    user  = "appuser"
    agent = false

    # путь до приватного ключа
    private_key = "${file(var.private_key_path)}"

    # private_key = "${file(var.public_key_path)}"
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}

resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"

  # Название сети, в которой действует правило
  network = "default"

  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]

  # Правило применимо для инстансов с перечисленными тэгами
  target_tags = ["reddit-app"]
}

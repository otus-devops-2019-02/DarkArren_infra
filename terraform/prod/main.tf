provider "google" {
  # Версия провайдера
  version = "2.0.0"

  # ID проекта
  project = "${var.project}"
  region  = "${var.region}"
}

module "db" {
  source           = "../modules/db"
  public_key_path  = "${var.public_key_path}"
  zone             = "${var.zone}"
  db_disk_image    = "${var.db_disk_image}"
  private_key_path = "${var.private_key_path}"
}

module "app" {
  source              = "../modules/app"
  public_key_path     = "${var.public_key_path}"
  zone                = "${var.zone}"
  app_disk_image      = "${var.app_disk_image}"
  db_internal_address = "${module.db.db_internal_ip}"
  private_key_path    = "${var.private_key_path}"
}

module "vpc" {
  source        = "../modules/vpc"
  source_ranges = ["79.98.8.3/32"]
}

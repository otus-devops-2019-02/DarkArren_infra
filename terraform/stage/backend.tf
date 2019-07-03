terraform {
  backend "gcs" {
    bucket = "storage-bucket-staging"
    prefix = "stage"
  }
}

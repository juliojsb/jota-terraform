terraform {
  backend "gcs" {
    bucket = "<your-bucket>"
    prefix = "terraform/state"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.74.0"
    }
  }
  required_version = ">= 0.14"
}

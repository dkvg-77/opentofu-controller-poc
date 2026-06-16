terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # Remote state in GCS so a cluster loss never loses the record of what we manage.
  # tofu-bootstrap GSA (via Workload Identity) owns this bucket.
  backend "gcs" {
    bucket = "dev-infra-test-497417-tofu-state"
    prefix = "opentofu-controller-poc"
  }
}

provider "google" {
  project = "dev-infra-test-497417"
  region  = "us-central1"
}

# Random suffix keeps the demo bucket name globally unique.
resource "random_id" "suffix" {
  byte_length = 3
}

# The hello-world resource: a real GCS bucket.
# Labels are deliberately included so we can demo DRIFT — change a label out-of-band
# in the console / via gsutil and watch tofu-controller revert it.
resource "google_storage_bucket" "hello" {
  name          = "tofu-controller-poc-${random_id.suffix.hex}"
  location      = "US-CENTRAL1"
  force_destroy = true

  uniform_bucket_level_access = true

  labels = {
    managed-by = "tofu-controller"
    poc        = "opentofu-controller"
    env        = "dev"
  }
}

output "bucket_name" {
  value = google_storage_bucket.hello.name
}

output "bucket_url" {
  value = google_storage_bucket.hello.url
}

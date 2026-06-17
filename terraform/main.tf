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

  # NOTE: no `backend` block here on purpose.
  # tofu-controller INJECTS the backend itself. By default it injects a Kubernetes
  # backend (state in an in-cluster Secret), and a backend block here would collide
  # with that on `tofu init` ("Duplicate backend configuration").
  # We select the remote GCS backend via spec.backendConfig.customConfiguration on
  # the Terraform CR instead — see hello-world/02-terraform-plan-approve.yaml.
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
    env        = "staging"
    owner      = "branch-planner-demo"
  }
}

output "bucket_name" {
  value = google_storage_bucket.hello.name
}

output "bucket_url" {
  value = google_storage_bucket.hello.url
}

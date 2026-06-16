terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  # backend injected by the controller via spec.backendConfig.customConfiguration
}

provider "google" {
  project = "dev-infra-test-497417"
  region  = "us-central1"
}

# bucket_name is supplied via spec.varsFrom (the hello-bucket-outputs Secret),
# proving cross-Terraform output consumption + ordering (spec.dependsOn).
variable "bucket_name" {
  type = string
}

resource "google_storage_bucket_object" "hello" {
  name    = "hello-from-tofu-controller.txt"
  bucket  = var.bucket_name
  content = "Uploaded by a second Terraform object that dependsOn hello-bucket and read its output."
}

output "object_path" {
  value = "gs://${var.bucket_name}/${google_storage_bucket_object.hello.name}"
}


provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

terraform {
  backend "gcs" {
    bucket = "gcp-practice-project-aman-terraform-state-bucket"
    prefix = "cloud-function/create-dataflow-job"
  }
}

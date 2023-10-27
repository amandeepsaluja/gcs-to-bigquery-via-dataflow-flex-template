provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_project_region
}

terraform {
  backend "gcs" {
    bucket = "terraform-state-bucket-gcp-practice-project-aman"
    prefix = "dataflow/gcs-to-bigquery-via-dataflow-flex-template"
  }
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

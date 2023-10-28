# Private Artifact Registry authentication
provider "docker" {
  alias = "gcr_provider"
  registry_auth {
    address  = var.docker_address
    username = var.docker_username
    password = var.gcp_auth_token # comes from GitHub Actions
  }
}

# Build the Docker image
resource "docker_image" "image" {
  provider = docker.gcr_provider
  name     = "${var.docker_address}/${var.gcp_project_id}/${var.docker_registry_path}/${var.docker_image_name}:${var.docker_image_tag}"
  build {
    context    = "${path.module}/${var.python_source_location}"
    dockerfile = "${path.module}/${var.dockerfile_location}}"
  }
}

# Push the Docker image to the registry
resource "docker_registry_image" "dataflow_image" {
  provider      = docker.gcr_provider
  name          = docker_image.image.name
  keep_remotely = true
}

# Building the Flex Template
locals {
  template_content = jsonencode({
    image = "${var.docker_address}/${var.gcp_project_id}/${var.docker_registry_path}/${var.docker_image_name}:${var.docker_image_tag}",
    metadata = {
      "name" : "Python flex template for GCS to BigQuery",
      "description" : "Flex template to process excel file from GCS and load into BigQuery.",
      "parameters" : [
        {
          "name" : "gcs_file_path",
          "label" : "Excel file path.",
          "helpText" : "GCS file path of the excel file to be processed.",
          "isOptional" : false,
          "regexes" : [
            "gs://.+"
          ]
        },
        {
          "name" : "custom_gcs_temp_location",
          "label" : "GCS Temp Location.",
          "helpText" : "Location of GCS for temp location.",
          "isOptional" : false,
          "regexes" : [
            "gs://.+"
          ]
        },
        {
          "name" : "output_table",
          "label" : "BigQuery dataset and table name.",
          "helpText" : "Name of the BigQuery output table name.",
          "isOptional" : false,
          "regexes" : [
            "([^:]+:)?[^.]+[.].+"
          ]
        }
      ]
    }
    sdk_info = {
      language = "${var.sdk_type}"
    },
    defaultEnvironment = {
      stagingLocation       = "gs://${var.dataflow_bucket_name}/staging",
      tempLocation          = "gs://${var.dataflow_bucket_name}/temp",
      serviceAccountEmail   = "test",
      enableStreamingEngine = false
    }
  })
}

# Loading the Flex Template to GCS
resource "google_storage_bucket_object" "custom_json" {
  name         = "templates/${var.docker_image_name}-${var.docker_image_tag}.json"
  bucket       = var.dataflow_bucket_name
  content      = local.template_content
  content_type = "application/json"
}


resource "google_cloudfunctions2_function" "this" {
  name        = var.name
  location    = var.gcp_region
  description = var.description
  project     = var.gcp_project_id

  build_config {
    runtime     = var.runtime
    entry_point = var.entry_point

    source {
      storage_source {
        bucket = var.bucket_name
        object = google_storage_bucket_object.this.name
      }
    }
  }

  service_config {
    max_instance_count    = var.max_instance_count
    timeout_seconds       = var.timeout_seconds
    service_account_email = var.service_account_email
  }

  event_trigger {
    trigger_region        = "global"
    event_type            = "google.cloud.audit.log.v1.written"
    service_account_email = var.service_account_email

    event_filters {
      attribute = "serviceName"
      value     = "storage.googleapis.com"
    }
    event_filters {
      attribute = "methodName"
      value     = "storage.objects.create"
    }
    event_filters {
      attribute = "resourceName"
      value     = var.cf_trigger_bucket_path
      operator  = "match-path-pattern" # This allows path patterns to be used in the value field
    }
  }
}

# creating the zip file
data "archive_file" "this" {
  type        = "zip"
  output_path = "/tmp/${var.name}.zip"
  source_dir  = "../src"
}

# uploading the zip file to the bucket
resource "google_storage_bucket_object" "this" {
  name   = "${var.name}/${data.archive_file.this.output_sha}.zip"
  bucket = var.bucket_name
  source = data.archive_file.this.output_path
}

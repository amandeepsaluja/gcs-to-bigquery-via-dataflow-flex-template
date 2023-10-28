variable "gcp_project_id" {
  type        = string
  description = "Google project ID"
  default     = "gcp-practice-project-aman"
}

variable "gcp_project_region" {
  type        = string
  description = "Google project region"
  default     = "us-central1"
}

variable "docker_address" {
  type        = string
  description = "Docker registry address"
  default     = "us-central1-docker.pkg.dev"
}

variable "docker_username" {
  type        = string
  description = "Docker registry username"
  default     = "oauth2accesstoken"
}

variable "docker_registry_path" {
  type        = string
  description = "Docker registry path"
  default     = "dataflow-custom-template-artifact-registry-repo"
}

variable "docker_image_name" {
  type        = string
  description = "Docker image name"
  default     = "excel-in-gcs-to-bq"
}

variable "docker_image_tag" {
  type        = string
  description = "Docker image tag"
  default     = "v1"
}

variable "python_source_location" {
  type        = string
  description = "Python source location"
  default     = "../src"
}

variable "dockerfile_location" {
  type        = string
  description = "Dockerfile location"
  default     = "../docker/Dockerfile"
}

variable "dataflow_bucket_name" {
  type        = string
  description = "Dataflow GCS bucket"
  default     = "dataflow-bucket-gcp-practice-project-aman"
}

variable "sdk_type" {
  type        = string
  description = "SDK type"
  default     = "PYTHON"
}

variable "gcp_auth_token" {
}

variable "service_account_email" {
}

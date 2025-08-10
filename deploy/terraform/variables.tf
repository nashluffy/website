variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "app_image" {
  description = "Docker image for your app (image that serves traffic on INTERNAL_PORT)"
  type        = string
}


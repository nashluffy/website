variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "domain" {
  description = "Fully qualified domain name for the site (example: example.com)"
  type        = string
}

variable "app_image" {
  description = "Docker image for your app (image that serves traffic on INTERNAL_PORT)"
  type        = string
}

variable "internal_port" {
  description = "Port your app listens on inside the container"
  type        = number
  default     = 8080
}

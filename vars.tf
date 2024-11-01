variable "project_id" {
  type = string
}

variable "project_nmr" {
  type = number
}

variable "project_default_region" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "public_bucket_name" {
  type    = string
  default = "static-content"
}

variable "default_run_image" {
  type    = string
  default = "nginx:latest"
}
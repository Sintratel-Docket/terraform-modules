variable "repositories" {
  description = "ECR repositories to create"
  type = map(object({
    image_tag_mutability = string
    scan_on_push         = bool
    encryption_type      = string
  }))
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}
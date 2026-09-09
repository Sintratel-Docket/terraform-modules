variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version used by EKS"
  type        = string
}

variable "vpc_id" {
  description = "VPC where EKS will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets used by the EKS nodes"
  type        = list(string)
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "instance_types" {
  description = "EC2 instance types for the EKS managed node group"
  type        = list(string)
  default     = ["t3.small"]
}

variable "min_size" {
  description = "Minimum number of EKS nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of EKS nodes"
  type        = number
  default     = 2
}

variable "desired_size" {
  description = "Desired number of EKS nodes"
  type        = number
  default     = 1
}

variable "github_actions_role_arn" {
  description = "IAM role used by GitHub Actions"
  type        = string
}

variable "cluster_admin_user_arn" {
  description = "IAM user that administers the EKS cluster"
  type        = string
}
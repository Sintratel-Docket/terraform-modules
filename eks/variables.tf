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

variable "additional_cluster_admin_principals" {
  description = "Additional IAM principals granted EKS cluster administrator access"
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for name in keys(var.additional_cluster_admin_principals) :
      !contains(["juanp", "github_actions"], name)
    ])
    error_message = "Additional cluster admin principals must not use the reserved keys juanp or github_actions."
  }
}

variable "coredns_addon_version" {
  description = "Pinned CoreDNS EKS add-on version; null selects the latest compatible version"
  type        = string
  default     = null
}

variable "kube_proxy_addon_version" {
  description = "Pinned kube-proxy EKS add-on version; null selects the latest compatible version"
  type        = string
  default     = null
}

variable "vpc_cni_addon_version" {
  description = "Pinned VPC CNI EKS add-on version; null selects the latest compatible version"
  type        = string
  default     = null
}

variable "node_ami_release_version" {
  description = "Pinned EKS managed node AMI release; null selects the latest compatible release"
  type        = string
  default     = null
}

variable "enable_prefix_delegation" {
  description = "Enable VPC CNI prefix delegation to raise the max pods per node (needed on small instance types like t3.small, whose default ENI-based limit is only 11 pods)."
  type        = bool
  default     = false
}

variable "node_max_pods" {
  description = "Kubelet --max-pods to configure on the nodes when prefix delegation is enabled (AL2023 nodeadm). 110 is the AWS-recommended cap for prefix delegation."
  type        = number
  default     = 110
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.25.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  endpoint_public_access  = true
  endpoint_private_access = true

  # IMPORTANTE:
  # No usamos el caller actual como administrador porque
  # cambia dependiendo de si Terraform corre localmente
  # o desde GitHub Actions.
  enable_cluster_creator_admin_permissions = false

  access_entries = {

    juanp = {
      principal_arn = var.cluster_admin_user_arn

      policy_associations = {
        cluster_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

          access_scope = {
            type = "cluster"
          }
        }
      }
    }

    github_actions = {
      principal_arn = var.github_actions_role_arn

      policy_associations = {
        cluster_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  # Evita que el administrador de KMS cambie dependiendo
  # de quién ejecute Terraform.
  kms_key_administrators = [
    var.cluster_admin_user_arn,
    var.github_actions_role_arn
  ]

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  addons = {
    coredns = {}

    kube-proxy = {}

    vpc-cni = {
      before_compute = true
    }
  }

  eks_managed_node_groups = {
    dev = {
      instance_types = var.instance_types

      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size

      capacity_type = "ON_DEMAND"

      labels = {
        Environment = var.environment
      }
    }
  }

  tags = {
    Environment = var.environment
    Project     = "Sintratel-Docket"
    ManagedBy   = "Terraform"
  }
}
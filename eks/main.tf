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

  access_entries = merge(
    {
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
    },
    {
      for name, principal_arn in var.additional_cluster_admin_principals : name => {
        principal_arn = principal_arn

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
  )

  # Evita que el administrador de KMS cambie dependiendo
  # de quién ejecute Terraform.
  kms_key_administrators = [
    var.cluster_admin_user_arn,
    var.github_actions_role_arn
  ]

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  addons = {
    coredns = {
      addon_version = var.coredns_addon_version
    }

    kube-proxy = {
      addon_version = var.kube_proxy_addon_version
    }

    vpc-cni = {
      before_compute = true
      addon_version  = var.vpc_cni_addon_version

      # Prefix delegation lets each ENI hand out /28 prefixes, raising the
      # usable pods per node well above the small ENI-based default.
      configuration_values = var.enable_prefix_delegation ? jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      }) : null
    }
  }

  eks_managed_node_groups = {
    (var.environment) = {
      instance_types = var.instance_types

      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size

      ami_release_version            = var.node_ami_release_version
      use_latest_ami_release_version = var.node_ami_release_version == null

      capacity_type = "ON_DEMAND"

      labels = {
        Environment = var.environment
      }

      # Prefix delegation only raises capacity if the kubelet --max-pods is
      # also raised. On AL2023 that is done through a nodeadm NodeConfig
      # merged into the node bootstrap.
      cloudinit_pre_nodeadm = var.enable_prefix_delegation ? [
        {
          content_type = "application/node.eks.aws"
          content      = <<-EOT
            apiVersion: node.eks.aws/v1alpha1
            kind: NodeConfig
            spec:
              kubelet:
                config:
                  maxPods: ${var.node_max_pods}
          EOT
        }
      ] : []
    }
  }

  tags = {
    Environment = var.environment
    Project     = "Sintratel-Docket"
    ManagedBy   = "Terraform"
  }
}

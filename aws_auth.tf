data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster" "cluster2" {
  name = module.eks2.cluster_id
}

data "aws_eks_cluster_auth" "cluster2" {
  name = module.eks2.cluster_id
}

provider "kubernetes" {
  alias                  = "c1"
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  config_path            = module.eks.kubeconfig_filename
  load_config_file       = true

  version = "~> 1.11"
}

provider "kubernetes" {
  alias                  = "c2"
  host                   = data.aws_eks_cluster.cluster2.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster2.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster2.token
  config_path            = module.eks.kubeconfig_filename
  load_config_file       = true
  version = "~> 1.11"
}


locals {
  eksmasterrole = [
    {
      rolearn  = aws_iam_role.eksmasterrole.arn
      username = aws_iam_role.eksmasterrole.arn
      groups   = ["system:masters"]
    },
  ]
}

resource "kubernetes_config_map" "aws_auth1" {
  depends_on = [module.eks]

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode(
      distinct(concat(
        [{
          rolearn  = module.eks.worker_iam_role_arn
          username = "system:node:{{EC2PrivateDNSName}}"
          groups   = ["system:masters"]
          }

        ],
        local.eksmasterrole,
      ))
    )
    //mapUsers    = yamlencode(var.map_users)
    //mapAccounts = yamlencode(var.map_accounts)
  }
  provider = kubernetes.c1
}

resource "kubernetes_config_map" "aws_auth2" {
  depends_on = [module.eks2]

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode(
      distinct(concat(
        [{
          rolearn  = module.eks2.worker_iam_role_arn
          username = "system:node:{{EC2PrivateDNSName}}"
          groups   = ["system:masters"]
          }

        ],
        local.eksmasterrole,
      ))
    )
    //mapUsers    = yamlencode(var.map_users)
    //mapAccounts = yamlencode(var.map_accounts)
  }
  provider = kubernetes.c2
}

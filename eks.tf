locals {
  cluster_name  = "test-eks-${random_string.suffix.result}"
  cluster2_name = "test-eks2-${random_string.suffix.result}"
}



#module.eks.local_file.kubeconfig[0]
#module.eks2.local_file.kubeconfig[0]

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "12.2.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.14"
  subnets         = module.vpc.private_subnets

  tags = {
    Environment = "test"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  vpc_id = module.vpc.vpc_id

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.small"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
    {
      name                          = "worker-group-2"
      instance_type                 = "t2.medium"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = 1
    },
  ]

  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  manage_aws_auth                      = false
  //  map_roles                            = var.map_roles
  //  map_users                            = var.map_users
  //  map_accounts                         = var.map_accounts
  kubeconfig_aws_authenticator_command = "aws"
  kubeconfig_aws_authenticator_command_args = [
    "--region",
    var.region,
    "eks",
    "get-token",
    "--cluster-name",
    local.cluster_name,
  ]
}

module "eks2" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "12.2.0"
  cluster_name    = local.cluster2_name
  cluster_version = "1.17"
  subnets         = module.vpc.private_subnets

  tags = {
    Environment = "test"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  vpc_id = module.vpc.vpc_id

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.small"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
    {
      name                          = "worker-group-2"
      instance_type                 = "t2.medium"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = 1
    },
  ]
  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  manage_aws_auth                      = false
  //  map_roles                            = var.map_roles
  //  map_users                            = var.map_users
  //  map_accounts                         = var.map_accounts
  kubeconfig_aws_authenticator_command = "aws"
  kubeconfig_aws_authenticator_command_args = [
    "--region",
    var.region,
    "eks",
    "get-token",
    "--cluster-name",
    local.cluster2_name,
  ]


}


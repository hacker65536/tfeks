output eksworkrole {
  value = module.eks.worker_iam_role_arn
}
output eks2workrole {
  value = module.eks2.worker_iam_role_arn
}
output subnets {
  value = module.vpc.public_subnets
}
output zs {
  value = data.aws_availability_zones.available.names
}

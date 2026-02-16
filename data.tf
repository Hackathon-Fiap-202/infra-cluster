# Data source do infra-core (único remote state mantido)
data "terraform_remote_state" "infra_core" {
  backend = "s3"
  config = {
    bucket = var.state_bucket
    key    = "infra-core/infra.tfstate"
    region = var.region
  }
}

# Auth token para Kubernetes
data "aws_eks_cluster_auth" "this" {
  name = module.cluster.cluster_name
}

# Caller identity para uso nos módulos
data "aws_caller_identity" "current" {}

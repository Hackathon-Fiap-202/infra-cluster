data "terraform_remote_state" "infra_core" {
  backend = "s3"
  config = {
    bucket = "nextime-frame-state-bucket"
    key    = "infra-core/infra.tfstate"
    region = "us-east-1"
  }
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

data "aws_iam_openid_connect_provider" "this" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

data "aws_caller_identity" "current" {}






terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.9"
    }
  }
}

# -----------------------------------------------------------------------------
# Provider AWS
# -----------------------------------------------------------------------------
provider "aws" {
  region = var.region

  default_tags {
    tags = merge(
      {
        Environment = var.environment
        Project     = var.project
        ManagedBy   = "Terraform"
      },
      var.tags
    )
  }
}

# -----------------------------------------------------------------------------
# Provider Kubernetes
# -----------------------------------------------------------------------------
provider "kubernetes" {
  host                   = module.cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.cluster.cluster_ca)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.cluster.cluster_name,
      "--region",
      var.region
    ]
  }
}

# -----------------------------------------------------------------------------
# Provider Helm
# -----------------------------------------------------------------------------
# Conecta ao cluster EKS usando outputs do módulo cluster
provider "helm" {
  kubernetes {
    host                   = module.cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.cluster.cluster_ca)
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.cluster.cluster_name,
        "--region",
        var.region
      ]
    }
  }
}


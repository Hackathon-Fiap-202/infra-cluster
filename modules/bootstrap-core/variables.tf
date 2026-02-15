variable "region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type = string
}

variable "project" {
  type = string
}

# Recebe outputs do módulo cluster
variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint do cluster EKS"
  type        = string
}

variable "cluster_ca" {
  description = "Certificate Authority do cluster (base64)"
  type        = string
  sensitive   = true
}

variable "cluster_oidc_provider_arn" {
  description = "ARN do OIDC Provider"
  type        = string
}

variable "cluster_oidc_provider_url" {
  description = "URL do OIDC Provider"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID do infra-core"
  type        = string
}
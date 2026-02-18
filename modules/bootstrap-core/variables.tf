variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

# Outputs do cluster passados como variáveis (elimina remote_state)
variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint do cluster EKS"
  type        = string
}

variable "cluster_ca" {
  description = "Certificate authority do cluster"
  type        = string
}

variable "cluster_oidc_provider_arn" {
  description = "ARN do OIDC provider do cluster"
  type        = string
}

variable "cluster_oidc_provider_url" {
  description = "URL do OIDC provider (sem https://)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

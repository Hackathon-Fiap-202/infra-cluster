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

# Recebe output do módulo cluster
variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}
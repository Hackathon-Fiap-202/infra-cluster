# -------------------------------------------------
# External Secret Store (ClusterSecretStore)
# -------------------------------------------------
resource "kubernetes_manifest" "aws_ssm_cluster_secretstore" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"

    metadata = {
      name = "aws-ssm"
    }

    spec = {
      provider = {
        aws = {
          service = "ParameterStore"
          region  = var.region

          auth = {
            jwt = {
              serviceAccountRef = {
                name      = "external-secrets-sa"
                namespace = "external-secrets"
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    data.aws_eks_cluster.this
  ]
}

# -------------------------------------------------
# External Secret para Datadog API Key
# -------------------------------------------------
resource "kubernetes_manifest" "datadog_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"

    metadata = {
      name      = "datadog-api-key"
      namespace = "default"
    }

    spec = {
      refreshInterval = "1h"

      secretStoreRef = {
        name = "aws-ssm"
        kind = "ClusterSecretStore"
      }

      target = {
        name           = "datadog-secret"
        creationPolicy = "Owner"
      }

      data = [
        {
          secretKey = "api-key"
          remoteRef = {
            key = "/datadog/api-key"
          }
        }
      ]
    }
  }

  depends_on = [
    kubernetes_manifest.aws_ssm_cluster_secretstore
  ]
}

# -------------------------------------------------
# LimitRange para default
# -------------------------------------------------
resource "kubernetes_manifest" "limit_range" {
  manifest = {
    apiVersion = "v1"
    kind       = "LimitRange"
    metadata = {
      name      = "default-limits"
      namespace = "default"
    }
    spec = {
      limits = [
        {
          default = {
            cpu    = "600m"
            memory = "800Mi"
          }
          defaultRequest = {
            cpu    = "250m"
            memory = "400Mi"
          }
          type = "Container"
        }
      ]
    }
  }

  depends_on = [
    data.aws_eks_cluster.this
  ]
}

# -------------------------------------------------
# ResourceQuota para default
# -------------------------------------------------
resource "kubernetes_manifest" "resource_quota" {
  manifest = {
    apiVersion = "v1"
    kind       = "ResourceQuota"
    metadata = {
      name      = "default-quota"
      namespace = "default"
    }
    spec = {
      hard = {
        "requests.cpu"    = "3000m"
        "limits.cpu"      = "3500m"
        "requests.memory" = "8Gi"
        "limits.memory"   = "10Gi"
      }
    }
  }

  depends_on = [
    data.aws_eks_cluster.this
  ]
}

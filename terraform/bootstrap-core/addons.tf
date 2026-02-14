# ==========================================
# Helm Releases - Addons que criam CRDs
# ==========================================

# ----------------------
# ArgoCD
# ----------------------
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.6.0"
  namespace        = "argocd"
  create_namespace = true

  wait    = true
  timeout = 600

  values = [yamlencode({
    server = {
      resources = {
        requests = {
          cpu    = "200m"
          memory = "400Mi"
        }
        limits = {
          cpu    = "400m"
          memory = "700Mi"
        }
      }
    }
  })]

  depends_on = [
    data.aws_eks_cluster.this
  ]
}

# ----------------------
# AWS Load Balancer Controller
# ----------------------
resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.7.2"

  values = [yamlencode({
    clusterName = var.cluster_name
    region      = "us-east-1"
    vpcId       = data.terraform_remote_state.infra_core.outputs.vpc_id

    serviceAccount = {
      create = true
      name   = "aws-load-balancer-controller"
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.aws_lb_controller.arn
      }
    }

    controller = {
      resources = {
        requests = {
          cpu    = "150m"
          memory = "250Mi"
        }
        limits = {
          cpu    = "300m"
          memory = "400Mi"
        }
      }
    }
  })]

  wait    = true
  timeout = 600

  depends_on = [
    aws_iam_role.aws_lb_controller
  ]
}

# ----------------------
# External Secrets
# ----------------------
resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  namespace  = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = "0.9.20"

  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  values = [yamlencode({
    serviceAccount = {
      create = true
      name   = "external-secrets-sa"
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.external_secrets.arn
      }
    }

    controller = {
      resources = {
        requests = {
          cpu    = "100m"
          memory = "200Mi"
        }
        limits = {
          cpu    = "200m"
          memory = "300Mi"
        }
      }
    }
  })]

  wait    = true
  timeout = 600

  depends_on = [
    aws_iam_role.external_secrets,
    helm_release.aws_lb_controller
  ]
}

# ----------------------
# AWS EBS CSI Driver
# ----------------------
resource "helm_release" "ebs_csi" {
  name       = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  namespace  = "kube-system"

  values = [yamlencode({
    controller = {
      serviceAccount = {
        create = true
        name   = "ebs-csi-controller-sa"
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.ebs_csi.arn
        }
      }

      resources = {
        requests = {
          cpu    = "150m"
          memory = "250Mi"
        }
        limits = {
          cpu    = "300m"
          memory = "400Mi"
        }
      }
    }

    node = {
      resources = {
        requests = {
          cpu    = "100m"
          memory = "200Mi"
        }
        limits = {
          cpu    = "200m"
          memory = "300Mi"
        }
      }
    }
  })]

  wait    = true
  timeout = 600

  depends_on = [
    aws_iam_role.ebs_csi
  ]
}

# ----------------------
# Metrics Server
# ----------------------
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"

  values = [yamlencode({
    args = [
      "--kubelet-insecure-tls"
    ]
    resources = {
      requests = {
        cpu    = "80m"
        memory = "150Mi"
      }
      limits = {
        cpu    = "150m"
        memory = "250Mi"
      }
    }
  })]

  wait    = true
  timeout = 300

  depends_on = [
    data.aws_eks_cluster.this
  ]
}

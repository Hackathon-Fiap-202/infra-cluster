resource "helm_release" "datadog" {
  name       = "datadog"
  namespace  = "default"
  repository = "https://helm.datadoghq.com"
  chart      = "datadog"

  create_namespace = false
  timeout          = 600
  wait             = true

  # ========================
  # Core
  # ========================

  set {
    name  = "datadog.apiKeyExistingSecret"
    value = "datadog-secret"
  }

  set {
    name  = "datadog.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "datadog.site"
    value = "datadoghq.com"
  }

  # ========================
  # Logs
  # ========================

  set {
    name  = "datadog.logs.enabled"
    value = "true"
  }

  set {
    name  = "datadog.logs.containerCollectAll"
    value = "true"
  }

  # ========================
  # APM
  # ========================

  set {
    name  = "datadog.apm.enabled"
    value = "true"
  }

  set {
    name  = "datadog.apm.portEnabled"
    value = "true"
  }

  set {
    name  = "datadog.admissionController.enabled"
    value = "true"
  }

  set {
    name  = "datadog.clusterChecks.enabled"
    value = "true"
  }

  # ========================
  # Process Agent
  # ========================

  set {
    name  = "datadog.processAgent.enabled"
    value = "true"
  }

  # ========================
  # Agent (DaemonSet)
  # ========================

  set {
    name  = "agents.resources.requests.cpu"
    value = "150m"
  }

  set {
    name  = "agents.resources.requests.memory"
    value = "350Mi"
  }

  set {
    name  = "agents.resources.limits.cpu"
    value = "300m"
  }

  set {
    name  = "agents.resources.limits.memory"
    value = "600Mi"
  }

  # ========================
  # Cluster Agent
  # ========================

  set {
    name  = "clusterAgent.resources.requests.cpu"
    value = "150m"
  }

  set {
    name  = "clusterAgent.resources.requests.memory"
    value = "256Mi"
  }

  set {
    name  = "clusterAgent.resources.limits.cpu"
    value = "300m"
  }

  set {
    name  = "clusterAgent.resources.limits.memory"
    value = "400Mi"
  }

  depends_on = [
    kubernetes_manifest.datadog_external_secret
  ]
}

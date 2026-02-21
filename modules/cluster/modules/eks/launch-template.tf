# -----------------------------------------------------------------------------
# Launch Template para Node Group
# -----------------------------------------------------------------------------

resource "aws_launch_template" "eks_nodes" {
  name_prefix = "${var.cluster_name}-node-"
  description = "Launch template for EKS nodes with custom security group"

  vpc_security_group_ids = [
    var.node_security_group_id,
    aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  ]

  # Configurações de monitoramento
  monitoring {
    enabled = true
  }

  # Metadados da instância
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # IMDSv2 obrigatório (best practice)
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.cluster_name}-node"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "${var.cluster_name}-node-volume"
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_eks_cluster.this]
}


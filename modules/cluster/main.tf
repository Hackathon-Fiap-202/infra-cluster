module "eks" {
  source      = "./modules/eks"
  environment = var.environment

  cluster_name     = var.cluster_name
  cluster_version  = var.cluster_version
  cluster_role_arn = aws_iam_role.eks_cluster.arn

  subnet_ids = var.public_subnet_ids

  cluster_security_group_id = aws_security_group.eks_cluster_sg.id
  node_security_group_id    = aws_security_group.eks_nodes_sg.id

  ami_type = var.ami_type

  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access  = var.endpoint_public_access
  public_access_cidrs     = var.public_access_cidrs

  node_role_arn       = aws_iam_role.eks_node.arn
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  node_desired_size   = var.node_desired_size
  node_instance_types = var.node_instance_types

  tags = var.tags
}

resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "EKS Cluster Security Group"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      Name = "${var.cluster_name}-cluster-sg"
    },
    var.tags
  )
}

resource "aws_security_group_rule" "cluster_ingress_nodes_https" {
  description              = "Allow nodes to communicate with cluster API"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes_sg.id
  security_group_id        = aws_security_group.eks_cluster_sg.id
}

resource "aws_security_group_rule" "cluster_egress_nodes" {
  description              = "Allow cluster to communicate with nodes"
  type                     = "egress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes_sg.id
  security_group_id        = aws_security_group.eks_cluster_sg.id
}

resource "aws_security_group_rule" "cluster_egress_nodes_kubelet" {
  description              = "Allow cluster to communicate with kubelet on nodes"
  type                     = "egress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes_sg.id
  security_group_id        = aws_security_group.eks_cluster_sg.id
}

resource "aws_security_group_rule" "cluster_egress_internet" {
  description       = "Allow cluster to communicate with internet"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_cluster_sg.id
}

resource "aws_security_group" "eks_nodes_sg" {
  name        = "${var.cluster_name}-nodes-sg"
  description = "EKS Worker Nodes Security Group"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      Name = "${var.cluster_name}-nodes-sg"
    },
    var.tags
  )
}

resource "aws_security_group_rule" "nodes_ingress_self" {
  description       = "Allow nodes to communicate with each other"
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.eks_nodes_sg.id
}

resource "aws_security_group_rule" "nodes_ingress_cluster" {
  description              = "Allow cluster to communicate with nodes"
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  security_group_id        = aws_security_group.eks_nodes_sg.id
}

resource "aws_security_group_rule" "nodes_ingress_cluster_kubelet" {
  description              = "Allow cluster to communicate with kubelet on nodes"
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  security_group_id        = aws_security_group.eks_nodes_sg.id
}

resource "aws_security_group_rule" "nodes_ingress_cluster_https" {
  description              = "Allow nodes to receive HTTPS traffic from cluster"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  security_group_id        = aws_security_group.eks_nodes_sg.id
}

resource "aws_security_group_rule" "nodes_egress_internet" {
  description       = "Allow nodes to communicate with internet"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "- 1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_nodes_sg.id
}

resource "aws_security_group_rule" "nodes_ingress_managed_cluster_sg" {
  description              = "Allow managed cluster SG to communicate with nodes"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = module.eks.cluster_security_group_id
  security_group_id        = aws_security_group.eks_nodes_sg.id
}

resource "aws_security_group_rule" "managed_cluster_sg_egress_nodes" {
  description              = "Allow managed cluster SG to communicate with nodes"
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes_sg.id
  security_group_id        = module.eks.cluster_security_group_id
}

resource "aws_security_group_rule" "nodes_egress_managed_cluster_sg" {
  description              = "Allow nodes to communicate with managed cluster SG"
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = module.eks.cluster_security_group_id
  security_group_id        = aws_security_group.eks_nodes_sg.id
}

resource "aws_security_group_rule" "managed_cluster_sg_ingress_nodes" {
  description              = "Allow nodes to communicate with managed cluster SG"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes_sg.id
  security_group_id        = module.eks.cluster_security_group_id
}


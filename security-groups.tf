resource "aws_security_group" "vault_server" {
  name        = "vault-server-sg"
  description = "Security Group for Vault Server Instances"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name         = "Vault Server (${var.cluster_name})"
    VaultCluster = "${replace(var.cluster_name, " ", "")}"
  }

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Vault Client Traffic
  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Vault Cluster Traffic
  ingress {
    from_port = 8201
    to_port   = 8201
    protocol  = "tcp"
    self      = true
  }

  # All Traffic - Egress
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

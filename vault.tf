terraform {
  required_version = ">= 0.9.3"
}

provider "aws" {
  region = "${var.region}"
}

data "aws_ami" "vault" {
  most_recent = true
  owners      = ["362381645759"] # hc-se-demos Hashicorp Demos New Account

  filter {
    name   = "tag:System"
    values = ["Vault"]
  }

  filter {
    name   = "tag:Environment"
    values = ["${var.environment}"]
  }

  filter {
    name   = "tag:Product-Version"
    values = ["${var.vault_version}"]
  }

  filter {
    name   = "tag:OS"
    values = ["${var.os}"]
  }

  filter {
    name   = "tag:OS-Version"
    values = ["${var.os_version}"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_role" "vault_server" {
  name               = "${var.cluster_name}-Vault-Server"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}

resource "aws_iam_role_policy" "vault_server" {
  name   = "SelfAssembly"
  role   = "${aws_iam_role.vault_server.id}"
  policy = "${data.aws_iam_policy_document.vault_server.json}"
}

resource "aws_iam_instance_profile" "vault_server" {
  name = "${var.cluster_name}-Vault-Server"
  role = "${aws_iam_role.vault_server.name}"
}

data "template_file" "init" {
  template = "${file("${path.module}/init-cluster.tpl")}"

  vars = {
    cluster_size     = "${var.cluster_size}"
    consul_as_server = "${var.consul_as_server}"
    environment_name = "${var.environment_name}"
    vault_use_tls    = "${var.vault_use_tls}"
  }
}

resource "aws_launch_configuration" "vault_server" {
  associate_public_ip_address = false
  ebs_optimized               = false
  iam_instance_profile        = "${aws_iam_instance_profile.vault_server.id}"
  image_id                    = "${data.aws_ami.vault.id}"
  instance_type               = "${var.instance_type}"
  user_data                   = "${data.template_file.init.rendered}"
  key_name                    = "${var.ssh_key_name}"

  security_groups = [
    "${aws_security_group.vault_server.id}",
    "${var.consul_server_sg_id}",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "vault_server" {
  launch_configuration = "${aws_launch_configuration.vault_server.id}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]
  name                 = "${var.cluster_name} Vault Servers"
  max_size             = "${var.cluster_size}"
  min_size             = "${var.cluster_size}"
  desired_capacity     = "${var.cluster_size}"
  default_cooldown     = 30
  force_delete         = true

  tag {
    key                 = "Name"
    value               = "${format("%s Vault Server", var.cluster_name)}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Cluster-Name"
    value               = "${var.cluster_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment-Name"
    value               = "${var.environment_name}"
    propagate_at_launch = true
  }
}

terraform {
  required_version = ">= 0.9.3"
}

module "consul_auto_join_instance_role" {
  source = "git@github.com:hashicorp-modules/consul-auto-join-instance-role-aws?ref=f-refactor"

  name = "${var.name}"
}

data "aws_ami" "vault" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:System"
    values = ["Vault"]
  }

  filter {
    name   = "tag:Product"
    values = ["Vault"]
  }

  filter {
    name   = "tag:Release-Version"
    values = ["${var.release_version}"]
  }

  filter {
    name   = "tag:Vault-Version"
    values = ["${var.vault_version}"]
  }

  filter {
    name   = "tag:OS"
    values = ["${lower(var.os)}"]
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

data "template_file" "vault_init" {
  template = "${file("${path.module}/templates/init-systemd.sh.tpl")}"

  vars = {
    name      = "${var.name}"
    count     = "${var.count != "-1" ? var.count : length(var.subnet_ids)}"
    user_data = "${var.user_data != "" ? var.user_data : "echo 'No custom user_data'"}"
  }
}

module "vault_server_sg" {
  source = "git@github.com:hashicorp-modules/vault-server-ports-aws?ref=f-refactor"

  name        = "${var.name}-vault-server"
  vpc_id      = "${var.vpc_id}"
  cidr_blocks = ["${var.public_ip != "false" ? "0.0.0.0/0" : var.vpc_cidr}"] # If there's a public IP, open Vault ports for public access - DO NOT DO THIS IN PROD
}

module "consul_client_sg" {
  source = "git@github.com:hashicorp-modules/consul-client-ports-aws?ref=f-refactor"

  name        = "${var.name}-vault-consul-client"
  vpc_id      = "${var.vpc_id}"
  cidr_blocks = ["${var.public_ip != "false" ? "0.0.0.0/0" : var.vpc_cidr}"] # If there's a public IP, open Consul ports for public access - DO NOT DO THIS IN PROD
}

resource "aws_security_group_rule" "ssh" {
  security_group_id = "${element(module.vault_server_sg.vault_server_sg_id, 0)}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["${var.public_ip != "false" ? "0.0.0.0/0" : var.vpc_cidr}"] # If there's a public IP, open port 22 for public access - DO NOT DO THIS IN PROD
}

resource "aws_launch_configuration" "vault" {
  associate_public_ip_address = "${var.public_ip != "false" ? true : false}"
  ebs_optimized               = false
  iam_instance_profile        = "${var.instance_profile != "" ? var.instance_profile : element(module.consul_auto_join_instance_role.instance_profile_id, 0)}"
  image_id                    = "${var.image_id != "" ? var.image_id : data.aws_ami.vault.id}"
  instance_type               = "${var.instance_type}"
  user_data                   = "${data.template_file.vault_init.rendered}"
  key_name                    = "${var.ssh_key_name}"

  security_groups = [
    "${element(module.vault_server_sg.vault_server_sg_id, 0)}",
    "${element(module.consul_client_sg.consul_client_sg_id, 0)}",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "vault" {
  launch_configuration = "${aws_launch_configuration.vault.id}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]
  name                 = "${var.name}-vault"
  max_size             = "${var.count != "-1" ? var.count : length(var.subnet_ids)}"
  min_size             = "${var.count != "-1" ? var.count : length(var.subnet_ids)}"
  desired_capacity     = "${var.count != "-1" ? var.count : length(var.subnet_ids)}"
  default_cooldown     = 30
  force_delete         = true

  tags = ["${concat(
    list(
      map("key", "Name", "value", format("%s-vault-node", var.name), "propagate_at_launch", true),
      map("key", "Consul-Auto-Join", "value", var.name, "propagate_at_launch", true)
    ),
    var.tags
  )}"]
}

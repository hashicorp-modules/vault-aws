module "images-aws" {
  source        = "git@github.com:hashicorp-modules/images-aws.git?ref=dan-refactor"
  vault_version = "${var.vault_version}"
  os            = "${var.os}"
  os_version    = "${var.os_version}"
}

resource "aws_iam_role" "vault_server" {
  name               = "${var.cluster_name}-VaultServer"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}

resource "aws_iam_role_policy" "vault_server" {
  name   = "SelfAssembly"
  role   = "${aws_iam_role.vault_server.id}"
  policy = "${data.aws_iam_policy_document.vault_server.json}"
}

resource "aws_iam_instance_profile" "vault_server" {
  name = "${var.cluster_name}-VaultServer"
  role = "${aws_iam_role.vault_server.name}"
}

data "template_file" "init" {
  template = "${file("${path.module}/init-cluster.tpl")}"

  vars = {
    consul_as_server = "${var.consul_as_server}"
  }
}

resource "aws_launch_configuration" "vault_server" {
  image_id      = "${module.images-aws.vault_image}"
  instance_type = "${var.instance_type}"
  user_data     = "${data.template_file.init.rendered}"
  key_name      = "${var.ssh_key_name}"

  security_groups = [
    "${aws_security_group.vault_server.id}",
    "${var.consul_server_sg_id}",
  ]

  associate_public_ip_address = false
  ebs_optimized               = false
  iam_instance_profile        = "${aws_iam_instance_profile.vault_server.id}"

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
}

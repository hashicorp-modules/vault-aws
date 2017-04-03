module "images-aws" {
  source = "git@github.com:hashicorp-modules/images-aws.git//terraform?ref=f-image-filters"

  OS = "${var.OS}"
  OS-Version = "${var.OS-Version}"
  Vault-Version = "${var.Vault-Version}"

}

data "template_file" "init" {
  template = "${file("${path.module}/init-cluster.tpl")}"

  vars = {
        consul_host  = "${var.consul_host}"
        cluster_name = "${var.cluster_name}"
  }
}

resource "aws_instance" "vault_server" {
  count = "${var.cluster_size}"

  ami = "${module.images-aws.vault_image}"
  instance_type = "${var.instance_type}"
  user_data = "${data.template_file.init.rendered}"
  subnet_id = "${element(var.subnets, count.index)}"
  associate_public_ip_address = false
  vpc_security_group_ids = [
    "${aws_security_group.vault_instance.id}",
    "${var.consul_sg_id}"
  ]

  iam_instance_profile = "${aws_iam_instance_profile.vault_server.name}"
  monitoring = true

  tags {
    Name = "${title(var.cluster_name)} Vault Server"
  }
}

resource "aws_elb" "vault_server" {
  name               = "${title(var.cluster_name)}-Vault-elb"
  availability_zones = ["${var.region}"]
  security_groups    = ["${aws_security_group.vault_instance.id}"]
  listener {
    instance_port     = 8200
    instance_protocol = "tcp"
    lb_port           = 8200
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTPS:8200/v1/status"
    interval            = 10
  }

  instances                   = ["${aws_instance.vault_server.*.id}"]
  depends_on                  = ["aws_instance.vault_server"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "${title(var.cluster_name)}-Vault-elb"
  }
}

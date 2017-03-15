resource "aws_instance" "vault_server" {
	count = "${var.instance_count}"

	ami = "${var.ami}"
	instance_type = "${var.instance_type}"

	subnet_id = "${element(var.private_subnet_ids, count.index)}"
	associate_public_ip_address = false
	vpc_security_group_ids = [
		"${aws_security_group.vault_instance.id}",
		"${var.consul_sg_id}"
	]

	iam_instance_profile = "${aws_iam_instance_profile.vault_server.name}"
	monitoring = true

	tags {
		Name = "${title(var.name)} Vault Server"
	}
}

resource "aws_security_group" "vault_instance" {
	name = "vault-instance"
	description = "Allow traffic to Vault Servers"
	vpc_id = "${var.vpc_id}"

	# SSH
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	# Vault Client Traffic
	ingress {
		from_port = 8200
		to_port = 8200
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	# Vault Cluster Traffic
	ingress {
		from_port = 8201
		to_port = 8201
		protocol = "tcp"
		self = true
	}

	# All Traffic - Egress
	egress {
		from_port = 0
		to_port = 65535
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags {
		Name = "Vault Instance"
	}
}

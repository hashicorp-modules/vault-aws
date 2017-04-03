data "aws_iam_policy_document" "assume_role" {
	statement {
		effect = "Allow"
		actions = [
			"sts:AssumeRole",
		]
		principals {
			type = "Service"
			identifiers = ["ec2.amazonaws.com"]
		}
	}
}

data "aws_iam_policy_document" "vault_server" {
	statement {
		sid = "AllowDiscovery"
		effect = "Allow"
		resources = [
			"*"
		]
		actions = [
			"ec2:DescribeTags",
			"ec2:DescribeVpcs",
			"ec2:DescribeInstances"
		]
	}
}

resource "aws_iam_role" "vault_server" {
	name = "VaultServer"
	assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}

resource "aws_iam_role_policy" "vault_server" {
	name = "SelfAssembly"
	role = "${aws_iam_role.vault_server.id}"
	policy = "${data.aws_iam_policy_document.vault_server.json}"
}

resource "aws_iam_instance_profile" "vault_server" {
	name = "VaultServer"
	roles = ["${aws_iam_role.vault_server.name}"]
}

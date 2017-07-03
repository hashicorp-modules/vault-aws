# vault-aws

Provisions resources for a Vault auto-scaling group in AWS.

## Requirements

This module requires a pre-existing AWS key pair, VPC and subnet be available to
deploy the auto-scaling group within. It's recommended you combine this module
with [network-aws](https://github.com/hashicorp-modules/network-aws/) which
provisions a VPC and a private and public subnet per AZ. See the usage section
for further guidance.

Consider using [hashicorp-guides/vault](https://github.com/hashicorp-guides/vault/blob/master/terraform-aws/)
if you need a fully functioning example.

### Environment Variables

- `AWS_DEFAULT_REGION`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### Terraform Variables

You can pass Terraform variables during `terraform apply` or in a
`terraform.tfvars` file. For example:

- `cluster_name` = "vault-test"
- `os` = "RHEL"
- `os_version` = "7.3"
- `ssh_key_name` = "test_aws"
- `subnet_ids` = ["subnet-57392f0f"]
- `vpc_id` = "vpc-7b28a11f"

## Outputs

- `asg_id`
- `vault_server_sg_id`

## Images

- [vault.json Packer template](https://github.com/hashicorp-modules/packer-templates/blob/master/vault/vault.json)

## Usage

When combined with [network-aws](https://github.com/hashicorp-modules/network-aws/)
the `vpc_id` and `subnet_ids` variables are output from that module so you should
not supply them. Replace the `cluster_name` variable with `environment_name`.

An example is available in [hashicorp-guides/vault](https://github.com/hashicorp-guides/vault/blob/master/terraform-aws/main.tf).

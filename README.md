# AWS Vault Terraform Module

Provisions resources for a Vault auto-scaling group in AWS.

- A Vault cluster with one node in each private subnet

## Requirements

This module requires a pre-existing AWS key pair, VPC and subnet be available to deploy the auto-scaling group within. It's recommended you combine this module with [network-aws](https://github.com/hashicorp-modules/network-aws/) which provisions a VPC and a private and public subnet per AZ. See the usage section for further guidance.

Consider using [hashicorp-guides/vault](https://github.com/hashicorp-guides/vault/blob/master/terraform-aws/) or checkout [examples](./examples) for fully functioning examples.

### Environment Variables

- `AWS_DEFAULT_REGION`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## Input Variables

- `name`: [Optional] Name for resources, defaults to "vault-aws".
- `release_version`: [Optional] Release version tag to use (e.g. 0.1.0, 0.1.0-rc1, 0.1.0-beta1, 0.1.0-dev1), defaults to "0.1.0-dev1".
- `vault_version`: [Optional] Vault version tag to use (e.g. 0.8.1 or 0.8.1-ent), defaults to "0.8.1".
- `os`: [Optional] Operating System to use (e.g. RHEL or Ubuntu), defaults to "RHEL".
- `os_version`: [Optional] Operating System version to use (e.g. 7.3 for RHEL or 16.04 for Ubuntu), defaults to "7.3".
- `vpc_id`: [Required] VPC ID to provision resources in.
- `vpc_cidr`: [Optional] VPC CIDR block to provision resources in.
- `subnet_ids`: [Optional] Subnet ID(s) to provision resources in.
- `count`: [Optional] Number of Vault nodes to provision across private subnets, defaults to private subnet count.
- `public_ip`: [Optional] Associate a public IP address to the Vault nodes, defaults to "false".
- `instance_profile`: [Optional] AWS instance profile to use.
- `instance_type`: [Optional] AWS instance type for Consul node (e.g. "m4.large"), defaults to "t2.small".
- `user_data`: [Optional] user_data script to pass in at runtime.
- `ssh_key_name`: [Required] Name of AWS keypair that will be created.

## Outputs

- `vault_asg_id`: Vault autoscaling group ID.
- `vault_sg_id`: Vault security group ID.
- `consul_sg_id`: Consul security group ID.

## Module Dependencies

- [AWS SSH Keypair Terraform Module](https://github.com/hashicorp-modules/ssh-keypair-aws)
  - [TLS Private Key Terraform Module](https://github.com/hashicorp-modules/tls-private-key)
- [AWS Network Terraform Module](https://github.com/hashicorp-modules/network-aws/)
- [AWS Vault Server Ports Terraform Module](https://github.com/hashicorp-modules/vault-server-ports-aws)

## Image Dependencies

- [vault.json Packer template](https://github.com/hashicorp-modules/packer-templates/blob/master/vault/vault.json)

## Authors

HashiCorp Solutions Engineering Team.

## License

Mozilla Public License Version 2.0. See LICENSE for full details.

output "zREADME" {
  value = <<README
# ------------------------------------------------------------------------------
# ${var.name} Vault Dev Guide Setup
# ------------------------------------------------------------------------------

If you're following the "Dev Guide" with the provided defaults, Vault is
running in -dev mode and using the in-memory storage backend.

The Root token for your Vault -dev instance has been set to "root" and placed in
`/srv/vault/.vault-token`, the `VAULT_TOKEN` environment variable has already
been set by default.

  $ echo $${VAULT_TOKEN} # Vault Token being used to authenticate to Vault
  $ sudo cat /srv/vault/.vault-token # Vault Token has also been placed here

If you're using a storage backend other than in-mem (-dev mode), you will need
to initialize Vault using steps 2 & 3 below.

# ------------------------------------------------------------------------------
# ${var.name} Vault Quick Start/Best Practices Guide Setup
# ------------------------------------------------------------------------------

If you're following the "Quick Start Guide" or "Best Practices" guide, you won't
be able to start interacting with Vault from the Bastion host yet as the Vault
server has not been initialized & unsealed. Follow the below steps to set this
up.

1.) SSH into one of the Vault servers registered with Consul, you can use the
below command to accomplish this automatically (we'll use Consul DNS moving
forward once Vault is unsealed).

  $ ssh -A ${lookup(var.users, var.os)}@$(curl http://127.0.0.1:8500/v1/agent/members | jq -M -r \
      '[.[] | select(.Name | contains ("${var.name}-vault")) | .Addr][0]')

2.) Initialize Vault

  $ vault operator init

3.) Unseal Vault using the "Unseal Keys" output from the `vault init` command
and check the seal status.

  $ vault operator unseal <UNSEAL_KEY_1>
  $ vault operator unseal <UNSEAL_KEY_2>
  $ vault operator unseal <UNSEAL_KEY_3>
  $ vault status

Repeat steps 1.) and 3.) to unseal the other "standby" Vault servers as well to
achieve high availablity.

4.) Logout of the Vault server (ctrl+d) and check Vault's seal status from the
Bastion host to verify you can interact with the Vault cluster from the Bastion
host Vault CLI.

  $ vault status

# ------------------------------------------------------------------------------
# ${var.name} Vault Getting Started Instructions
# ------------------------------------------------------------------------------

You can interact with Vault using any of the
CLI (https://www.vaultproject.io/docs/commands/index.html) or
API (https://www.vaultproject.io/api/index.html) commands.
${__builtin_StringToFloat(replace(replace(var.vault_version, "-ent", ""), ".", "")) >= 0100 || replace(var.vault_version, "-ent", "") != var.vault_version ? format("\nVault UI: %s%s %s\n\n%s", var.use_lb_cert ? "https://" : "http://", module.vault_lb_aws.vault_lb_dns, var.public ? "(Public)" : "(Internal)", var.public ? "The Vault nodes are in a public subnet with UI & SSH access open from the\ninternet. WARNING - DO NOT DO THIS IN PRODUCTION!\n" : "The Vault node(s) are in a private subnet, UI access can only be achieved inside\nthe network through a VPN.\n") : ""}
To start interacting with Vault, set your Vault token to authenticate requests.

If using the "Vault Dev Guide", Vault is running in -dev mode & this has been set
to "root" for you. Otherwise we will use the "Initial Root Token" that was output
from the `vault operator init` command.

  $ echo $${VAULT_ADDR} # Address you will be using to interact with Vault
  $ echo $${VAULT_TOKEN} # Vault Token being used to authenticate to Vault
  $ export VAULT_TOKEN=<ROOT_TOKEN> # If Vault token has not been set

Use the CLI to write and read a generic secret.

  $ vault kv put secret/cli foo=bar
  $ vault kv get secret/cli

Use the HTTP API with Consul DNS to write and read a generic secret with
Vault's KV secret engine.

${!var.use_lb_cert ?
"If you're making HTTP API requests to Vault from the Bastion host,
the below env var has been set for you.

  $ export VAULT_ADDR=http://vault.service.vault:${var.vault_port}

  $ curl \\
      -H \"X-Vault-Token: $${VAULT_TOKEN}\" \\
      -X POST \\
      -d '{\"data\": {\"foo\":\"bar\"}}' \\
      $${VAULT_ADDR}/v1/secret/data/api | jq '.' # Write a KV secret
  $ curl \\
      -H \"X-Vault-Token: $${VAULT_TOKEN}\" \\
      $${VAULT_ADDR}/v1/secret/data/api | jq '.' # Read a KV secret"
:
"If you're making HTTPS API requests to Vault from the Bastion host,
the below env vars have been set for you.

  $ export VAULT_ADDR=https://vault.service.vault:${var.vault_port}
  $ export VAULT_CACERT=/opt/vault/tls/vault-ca.crt
  $ export VAULT_CLIENT_CERT=/opt/vault/tls/vault.crt
  $ export VAULT_CLIENT_KEY=/opt/vault/tls/vault.key

  $ curl \\
      -H \"X-Vault-Token: $VAULT_TOKEN\" \\
      -X POST \\
      -d '{\"data\": {\"foo\":\"bar\"}}' \\
      -k --cacert $${VAULT_CACERT} --cert $${VAULT_CLIENT_CERT} --key $${VAULT_CLIENT_KEY} \\
      $${VAULT_ADDR}/v1/secret/data/api | jq '.' # Write a KV secret
  $ curl \\
      -H \"X-Vault-Token: $VAULT_TOKEN\" \\
      -k --cacert $${VAULT_CACERT} --cert $${VAULT_CLIENT_CERT} --key $${VAULT_CLIENT_KEY} \\
      $${VAULT_ADDR}/v1/secret/data/api | jq '.' # Read a KV secret"
}
README
}

output "consul_sg_id" {
  value = "${module.consul_client_sg.consul_client_sg_id}"
}

output "vault_sg_id" {
  value = "${module.vault_server_sg.vault_server_sg_id}"
}

output "vault_lb_sg_id" {
  value = "${module.vault_lb_aws.vault_lb_sg_id}"
}

output "vault_tg_http_8200_arn" {
  value = "${module.vault_lb_aws.vault_tg_http_8200_arn}"
}

output "vault_tg_https_8200_arn" {
  value = "${module.vault_lb_aws.vault_tg_https_8200_arn}"
}

output "vault_lb_dns" {
  value = "${module.vault_lb_aws.vault_lb_dns}"
}

output "vault_asg_id" {
  value = "${element(concat(aws_autoscaling_group.vault.*.id, list("")), 0)}"
}

output "vault_username" {
  value = "${lookup(var.users, var.os)}"
}

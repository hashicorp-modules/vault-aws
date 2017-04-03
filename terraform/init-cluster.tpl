#!/bin/bash

service vault stop
hostname=$(hostname)

cat <<'EOF' >> /etc/vault/config.hcl
backend "consul" {
  address = "${consul_host}:8500"
  path = "${cluster_name}"
  redirect_addr = "https://$${hostname}:8200"
}
listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = 0
  tls_cert_file = "/etc/ssl/vault/vault.crt"
  tls_key_file = "/etc/ssl/vault/vault.key"
}
cluster_name = ${cluster_name}

chmod 750 /etc/vault
chown -R vault.vault /etc/vault
rm -f /tmp/instances

service vault start
chkconfig vault on

#!/bin/bash

instance_id="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
new_hostname="vault-$${instance_id}"

# set the hostname (before starting consul and vault)
hostnamectl set-hostname "$${new_hostname}"

# add the consul group to the config with jq
jq ".retry_join_ec2 += {\"tag_key\": \"Environment-Name\", \"tag_value\": \"${environment_name}\"}" < /etc/consul.d/consul-default.json.example > /etc/consul.d/consul-default.json
chown consul:consul /etc/consul.d/consul-default.json

# add default vault config to use consul
cp /etc/vault.d/vault-consul.hcl.example /etc/vault.d/vault-consul.hcl
chown vault:vault /etc/vault.d/vault-consul.hcl

if [[ "${consul_as_server}" = "true" ]]; then
  # add the cluster instance count to the config with jq
  jq ".bootstrap_expect = ${cluster_size}" < /etc/consul.d/consul-server.json.example > /etc/consul.d/consul-server.json
  chown consul:consul /etc/consul.d/consul-server.json
fi

if [[ "${vault_use_tls}" = "true" ]]; then
  cp /etc/vault.d/vault-tls.hcl.example /etc/vault.d/vault-tls.hcl
  chown vault:vault /etc/vault.d/vault-tls.hcl
  echo "export VAULT_ADDR=https://127.0.0.1:8200" | tee -a /etc/profile.d/vault.sh
else
  cp /etc/vault.d/vault-no-tls.hcl.example /etc/vault.d/vault-no-tls.hcl
  chown vault:vault /etc/vault.d/vault-no-tls.hcl
  echo "export VAULT_ADDR=http://127.0.0.1:8200" | tee -a /etc/profile.d/vault.sh
fi

# consul agent exists on all instances in client or server configuration
systemctl enable consul
systemctl start consul

# enable and start vault once it is configured correctly
systemctl enable vault
systemctl start vault

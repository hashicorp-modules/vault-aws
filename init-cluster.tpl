#!/bin/bash

instance_id="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
new_hostname="vault-$${instance_id}"

# stop consul and vault so they can be configured correctly
systemctl stop vault
systemctl stop consul

# clear the consul and vault data directory ready for a fresh start
rm -rf /opt/consul/data/*
rm -rf /opt/vault/data/*

# set the hostname (before starting consul and vault)
hostnamectl set-hostname "$${new_hostname}"

# seeing failed nodes listed  in consul members with their solo config
# try a 2 min sleep to see if it helps with all instances wiping data
# in a similar time window
sleep 120

# add the consul group to the config with jq
jq ".retry_join_ec2 += {\"tag_key\": \"Environment-Name\", \"tag_value\": \"${environment_name}\"}" < /etc/consul.d/consul-default.json > /tmp/consul-default.json.tmp
sed -i -e "s/127.0.0.1/$${local_ipv4}/" /tmp/consul-default.json.tmp
mv /tmp/consul-default.json.tmp /etc/consul.d/consul-default.json
chown consul:consul /etc/consul.d/consul-default.json

if [[ "${consul_as_server}" = "true" ]]; then
  # add the cluster instance count to the config with jq
  jq ".bootstrap_expect = ${cluster_size}" < /etc/consul.d/consul-server.json > /tmp/consul-server.json.tmp
  mv /tmp/consul-server.json.tmp /etc/consul.d/consul-server.json
  chown consul:consul /etc/consul.d/consul-server.json
else
  # remove the consul as server config
  rm /etc/consul.d/consul-server.json
fi

if [[ "${vault_use_tls}" = "true" ]]; then
  mv /etc/vault.d/vault-tls.hcl.example /etc/vault.d/vault-tls.hcl
  chown vault:vault /etc/vault.d/vault-tls.hcl
  mv /etc/vault.d/vault-no-tls.hcl /etc/vault.d/vault-no-tls.hcl.example
  echo "export VAULT_ADDR=https://127.0.0.1:8200" | tee /etc/profile.d/vault.sh
else
  echo "export VAULT_ADDR=http://127.0.0.1:8200" | tee /etc/profile.d/vault.sh
fi

# start consul and vault once they are configured correctly
systemctl start consul
systemctl start vault

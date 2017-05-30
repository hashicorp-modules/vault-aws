#!/bin/bash

instance_id="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
new_hostname="vault-$${instance_id}"

# set the hostname (before starting consul and vault)
hostnamectl set-hostname "$${new_hostname}"

# add the consul group to the config with jq
jq ".retry_join_ec2 += {\"tag_key\": \"Environment-Name\", \"tag_value\": \"${environment_name}\"}" < /etc/consul.d/consul-default.json.example > /etc/consul.d/consul-default.json
chown consul:consul /etc/consul.d/consul-default.json

# configure vault defaults

if [[ "${consul_as_server}" = "true" ]]; then
  # add the cluster instance count to the config with jq
  jq ".bootstrap_expect = ${cluster_size}" < /etc/consul.d/consul-server.json.example > /etc/consul.d/consul-server.json
  chown consul:consul /etc/consul.d/consul-server.json
fi

# configure vault tls or no-tls

# consul agent exists on all instances in client or server configuration
systemctl enable consul
systemctl start consul

# enable and start vault once it is configured correctly
systemctl enable vault
systemctl start vault

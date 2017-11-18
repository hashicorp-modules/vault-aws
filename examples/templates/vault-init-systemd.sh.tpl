#!/bin/bash

echo "user_data overriden"
echo "Set variables"
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"

echo "Configure Vault Consul client"
cat <<CONFIG >/etc/consul.d/consul-client.json
{
  "datacenter": "${name}",
  "advertise_addr": "$${local_ipv4}",
  "data_dir": "/opt/consul/data",
  "client_addr": "0.0.0.0",
  "log_level": "INFO",
  "ui": true,
  "retry_join": ["provider=aws tag_key=Consul-Auto-Join tag_value=${name}"]
}
CONFIG

echo "Update Consul configuration file permissions"
chown -R consul:consul /etc/consul.d
chmod -R 0644 /etc/consul.d/*

echo "Don't start Consul in -dev mode"
echo '' | sudo tee /etc/consul.d/consul.conf

echo "Restart Consul"
systemctl restart consul

echo "Custom Vault configuration"
${vault_config}

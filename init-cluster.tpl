#!/bin/bash

local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
instance_id="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
new_hostname="vault-$${instance_id}"

# set the hostname (before starting consul and vault)
hostnamectl set-hostname "$${new_hostname}"

if [[ "${consul_as_server}" != "true" ]]; then
  # remove consul-server.json from /etc/consul.d/
  # todo:
  #   Use environment variable for consul config directory so this rm isn't
  #   hardcoded (which would fail if the config dir changed). This requires
  #   the config directory value to be set as an environment variable early
  #   on in the build process, so needs proper testing once implemented.
  rm /etc/consul.d/consul-server.json
fi

# consul agent exists on all instances in client or server configuration
systemctl enable consul
systemctl start consul

# enable and start vault once it is configured correctly
systemctl enable vault
systemctl start vault

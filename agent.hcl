# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

# Full configuration options can be found at https://developer.hashicorp.com/nomad/docs/configuration

data_dir   = "/etc/nomad/data"
plugin_dir = "/etc/nomad/plugins"

bind_addr  = "0.0.0.0"

server {
  # license_path is required for Nomad Enterprise as of Nomad v1.1.1+
  #license_path = "/etc/nomad.d/license.hclic"
  enabled          = true
  bootstrap_expect = 1
}

client {
  enabled = true
  servers = ["127.0.0.1"]
  # options = {
  #   "driver.allowlist" = "docker"
  # }
}

ports {
  http = 4646
  rpc  = 4647
  serf = 4648
}

plugin "nomad-device-nvidia" {
  config {
    enabled            = true
    fingerprint_period = "1m"
  }
}

plugin "raw_exec" {
  config {
    enabled = true
  }
}

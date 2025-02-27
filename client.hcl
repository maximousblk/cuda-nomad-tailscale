client {
  enabled = true
  server_join {
    retry_join     = [ "100.64.0.5", "exec=/etc/tailscale.d/tsaddr.sh" ]
    retry_interval = "5s"
  }
}

plugin "raw_exec" {
  config {
    enabled = true
  }
}

plugin "nomad-device-nvidia" {
  config {
    enabled            = true
    fingerprint_period = "1m"
  }
}

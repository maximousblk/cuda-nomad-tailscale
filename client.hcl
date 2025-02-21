client {
  enabled = true
  server_join {
    retry_join     = ["exec=/tailscale/tsaddr.sh"]
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

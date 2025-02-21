#!/bin/sh
tailscale status --peers --self=false --json | jq -r '[.Peer[].TailscaleIPs[0]] | join(" ")'
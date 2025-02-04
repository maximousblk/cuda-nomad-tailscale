#!/bin/sh

# Start SSH
echo "Starting SSH..."
sshd -D &

# Start Tailscale in the background
mkdir -p /var/run/tailscale
echo "Starting tailscale daemon..."
./tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock --tun=userspace-networking --socks5-server=localhost:1055 --outbound-http-proxy-listen=localhost:1055 &

# Wait until Tailscale is up
echo "Waiting for tailscale to be up..."
until ./tailscale up --authkey=${TAILSCALE_AUTHKEY} --hostname=${TAILSCALE_HOSTNAME} --advertise-exit-node ${TAILSCALE_ADDITIONAL_ARGS}; do
  sleep 0.1
done

nomad agent -client -config /etc/nomad/agent.config.hcl &

# Execute the command specified by CMD
exec "$@"

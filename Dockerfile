FROM nvidia/cuda:12.8.0-base-ubuntu24.04

ENV TAILSCALE_VERSION="latest"
ENV TAILSCALE_HOSTNAME="runpod-app"
ENV TAILSCALE_ADDITIONAL_ARGS=""

# Install dependencies
RUN apt-get update
RUN apt-get install -y sudo
RUN apt-get install -y wget curl
RUN apt-get install -y gnupg2
RUN apt-get install -y lsb-release
RUN apt-get install -y zip unzip
RUN apt-get install -y ca-certificates net-tools iputils-ping iproute2 iptables

# Install SSH
RUN apt-get install -y openssh-server
RUN sudo ssh-keygen -A
RUN sudo chmod 755 /etc/ssh
RUN sudo chmod 600 /etc/ssh/ssh_host_*

COPY entrypoint.sh /entrypoint.sh
RUN sudo chmod +x /entrypoint.sh

# Install Nomad
RUN adduser --system --group --shell /bin/bash --home /home/root nomad
RUN usermod -aG root nomad
RUN usermod -aG root nomad
RUN echo "nomad ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers
RUN echo "nomad:nomad" | chpasswd

RUN wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
RUN sudo apt update && sudo apt install -y nomad

COPY agent.hcl /etc/nomad/agent.config.hcl

RUN sudo mkdir -p /nomad/data
RUN sudo mkdir -p /etc/nomad
RUN sudo mkdir -p /etc/nomad/data
RUN sudo mkdir -p /etc/nomad/plugins
RUN sudo chown -R nomad:nomad /nomad /etc/nomad
RUN sudo chmod -R 777 /nomad /etc/nomad

RUN wget https://releases.hashicorp.com/nomad-device-nvidia/1.0.0/nomad-device-nvidia_1.0.0_linux_amd64.zip -O /tmp/nomad-device-nvidia_1.0.0_linux_amd64.zip
RUN unzip /tmp/nomad-device-nvidia_1.0.0_linux_amd64.zip -d /tmp
RUN sudo cp /tmp/nomad-device-nvidia /etc/nomad/plugins/nomad-device-nvidia
RUN sudo chmod +x /etc/nomad/plugins/nomad-device-nvidia

# Install Tailscale
RUN mkdir -p /tailscale
RUN chown -R nomad:nomad /tailscale
RUN chmod -R 777 /tailscale
WORKDIR /tailscale

RUN wget https://pkgs.tailscale.com/stable/tailscale_${TAILSCALE_VERSION}_amd64.tgz
RUN tar xzf tailscale_${TAILSCALE_VERSION}_amd64.tgz --strip-components=1
RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale
RUN chown -R nomad:nomad /var/run/tailscale /var/cache/tailscale /var/lib/tailscale
RUN chmod -R 777 /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

USER nomad

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "sleep", "5000" ]

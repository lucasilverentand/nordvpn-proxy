FROM debian:stable-slim

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl dante-server supervisor iproute2 iptables apt-utils net-tools gettext \
    && apt-get clean all && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install NordVPN
# Download script from https://downloads.nordcdn.com/apps/linux/install.sh
# and run it with -n option
RUN curl -sSfL https://downloads.nordcdn.com/apps/linux/install.sh | sh -s -- -n

# Create user and group
RUN addgroup --system vpn && useradd -lNms /bin/bash -u "${NUID:-1000}" -G nordvpn,vpn nordclient

# Install scripts and make them executable
COPY scripts/ /scripts/
RUN chmod +x /scripts/*.sh

COPY etc/ /etc/

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
HEALTHCHECK --interval=5m --timeout=1m --start-period=1m CMD /scripts/healthcheck.sh
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
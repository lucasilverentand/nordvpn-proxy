#!/bin/bash

enforce_proxies_iptables() {
  log "proxies: allow ports 1080"
  nordvpn whitelist add port 1080 protocol TCP || true
  nordvpn whitelist add port 1080 protocol UDP || true
  iptables -L
}

setup_dns() {
  log "INFO: setting up DNS"
  echo "nameserver 193.110.81.0" >/etc/resolv.conf
  # add fallback
  echo "nameserver 185.253.5.0" >>/etc/resolv.conf 
}
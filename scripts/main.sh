#!/bin/bash

set -u -o pipefail

source /scripts/vars.sh
source /scripts/utils.sh
source /scripts/iptables.sh
source /scripts/nordvpn.sh
source /scripts/dante.sh

print_settings
set_timezone

# In case no server or nordvpn token is provided, exit with error
if [[ -z ${SERVER} ]] || [[ -z ${NORDVPN_TOKEN} ]]; then
  log "ERROR: No server and/or nordvpn token provided"
  exit 1
fi

RDIR=/run/nordvpn
[[ ! -d ${RDIR} ]] && mkdir -p ${RDIR}

# Setup NordVPN
start_nordvpn
create_tun
setup_nordvpn

# Setup iptables
enforce_proxies_iptables
setup_dns

# Connect to NordVPN
login_nordvpn
connect_nordvpn
check_nordvpn_connection

# # Start Dante
setup_dante
start_dante
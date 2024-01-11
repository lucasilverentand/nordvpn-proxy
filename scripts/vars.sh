#!/bin/bash

TZ=${TZ:-'UTC'}

# Dante Settings
SOCK_PORT=${SOCK_PORT:-"1080"}

# NordVPN Settings
TECHNOLOGY=${TECHNOLOGY:-'nordlynx'}
ANALYTICS=${ANALYTICS:-'off'}
PROTOCOL=${PROTOCOL:-'udp'}
OBFUSCATE=${OBFUSCATE:-'off'}
CYBERSEC=${CYBERSEC:-'off'}
KILLSWITCH=${KILLSWITCH:-'on'}
IPV6=${IPV6:-'off'}
DNS=${DNS:-'193.110.81.0,185.253.5.0'} # Default DNS0.EU

# Server selection
COUNTRY=${COUNTRY:-""}
GROUP=${GROUP:-""}
SERVER=${SERVER:-""}
[[ -n ${COUNTRY} && -z ${SERVER} ]] && export SERVER=${COUNTRY}
[[ "${GROUPID:-''}" =~ ^[0-9]+$ ]] && groupmod -g $GROUPID -o vpn
[[ -n ${GROUP} ]] && GROUP="--group ${GROUP}"

# Networks
DOCKER_NET=${DOCKER_NET:-''}
LOCAL_SUBNETS=${LOCAL_SUBNETS:-'192.168.0.0/16,172.16.0.0/12,10.0.0.0/8'}
LOCALNET=$(hostname -i | grep -Eom1 "(^[0-9]{1,3}\.[0-9]{1,3})")

# autofill docker network if not provided
if [[ -z ${DOCKER_NET} ]]; then
  DOCKER_NET="$(hostname -i | grep -Eom1 "^[0-9]{1,3}\.[0-9]{1,3}").0.0/12"
fi

NORDVPN_TOKEN_FILE=${NORDVPN_TOKEN_FILE:-'/run/secrets/nordvpn_token'}
NORDVPN_TOKEN=${NORDVPN_TOKEN:-''}

# If no token is provided, check for a token file
if [[ -z ${NORDVPN_TOKEN} ]] && [[ -f ${NORDVPN_TOKEN_FILE} ]]; then
  NORDVPN_TOKEN=$(cat ${NORDVPN_TOKEN_FILE})
fi

print_settings() {
  log "INFO: Settings:"
  log "INFO: TZ: ${TZ}"
  log "INFO: SOCK_PORT: ${SOCK_PORT}"
  log "INFO: TECHNOLOGY: ${TECHNOLOGY}"
  log "INFO: ANALYTICS: ${ANALYTICS}"
  log "INFO: PROTOCOL: ${PROTOCOL}"
  log "INFO: OBFUSCATE: ${OBFUSCATE}"
  log "INFO: CYBERSEC: ${CYBERSEC}"
  log "INFO: KILLSWITCH: ${KILLSWITCH}"
  log "INFO: IPV6: ${IPV6}"
  log "INFO: DNS: ${DNS}"
  log "INFO: COUNTRY: ${COUNTRY}"
  log "INFO: GROUP: ${GROUP}"
  log "INFO: SERVER: ${SERVER}"
  log "INFO: DOCKER_NET: ${DOCKER_NET}"
  log "INFO: LOCAL_SUBNETS: ${LOCAL_SUBNETS}"
  log "INFO: LOCALNET: ${LOCALNET}"
  log "INFO: NORDVPN_TOKEN_FILE: ${NORDVPN_TOKEN_FILE}"
  log "INFO: NORDVPN_TOKEN: ${NORDVPN_TOKEN}"
}
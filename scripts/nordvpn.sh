#!/bin/bash

setup_nordvpn() {
  nordvpn set analytics ${ANALYTICS}
  nordvpn set technology ${TECHNOLOGY}
  nordvpn set killswitch ${KILLSWITCH}
  nordvpn set cybersec ${CYBERSEC}
  nordvpn set ipv6 ${IPV6}

  # If technology is NordLynx, then set protocol to UDP
  if [[ ${TECHNOLOGY} == "nordlynx" ]]; then
    nordvpn set protocol udp
  else
    nordvpn set protocol ${PROTOCOL}
  fi

  # Obfuscate is not supported by NordLynx
  if [[ ${TECHNOLOGY} != "nordlynx" ]]; then
    nordvpn set obfuscate ${OBFUSCATE}
  fi

  # Set DNS if provided
  if [[ -n ${DNS} ]]; then
    nordvpn set dns ${DNS//,/ }
  fi

  # Setup docker net
  nordvpn whitelist add subnet ${DOCKER_NET}

  # Setup local net
  nordvpn whitelist add subnet ${LOCALNET}.0.0/16
  if [[ -n ${LOCAL_SUBNETS:-''} ]]; then
    eval $(/sbin/ip route list match 0.0.0.0 | awk '{if($5!="tun0"){print "GW="$3"\nINT="$5; exit}}')
    log "LOCAL_SUBNETS: ${LOCAL_SUBNETS}, Gateway: ${GW}, device ${INT}"
    if [[ -n ${GW:-""} ]] && [[ -n ${INT:-""} ]]; then
      for localNet in ${LOCAL_SUBNETS//,/ }; do
        log "INFO: NORDVPN: whitelisting network ${localNet}"
        nordvpn whitelist add subnet ${localNet}  || true
        log "INFO: NORDVPN: adding route to local network ${localNet} via ${GW} dev ${INT}"
        /sbin/ip route add "${localNet}" via "${GW}" dev "${INT}"
      done
    fi
  fi
  
}

create_tun() {
  if [ ! -c /dev/net/tun ]; then
    log "INFO: OVPN: Creating tun interface /dev/net/tun"
    mkdir -p /dev/net
    mknod /dev/net/tun c 10 200
    chmod 600 /dev/net/tun
  fi
}

start_nordvpn() {
  log "INFO: NORDVPN: starting nordvpn daemon"
  action=start
  isRunning=$(supervisorctl status nordvpnd | grep -c RUNNING) || true
  [[ 0 -le ${isRunning} ]] && action=restart
  [[ -e ${RDIR}/nordvpnd.sock ]] && rm -f ${RDIR}/nordvpnd.sock
  supervisorctl ${action} nordvpnd
  sleep 4
  #start nordvpn daemon
  while [ ! -S ${RDIR}/nordvpnd.sock ]; do
    log "WARNING: NORDVPN: restart nordvpn daemon as no socket was found"
    supervisorctl restart nordvpnd
    sleep 4
  done
}

login_nordvpn() {
  log "INFO: NORDVPN: logging in using token"
  nordvpn login --token ${NORDVPN_TOKEN}
}

connect_nordvpn() {
  log "INFO: NORDVPN: connecting to ${GROUP} ${SERVER}"
  nordvpn connect ${GROUP} ${SERVER}
}

check_nordvpn_connection() {
  N=10
  while [[ $(nordvpn status | grep -ic "connected") -eq 0 ]]; do
    sleep 3
    N--
    [[ ${N} -eq 0 ]] && log "ERROR: NORDVPN: cannot connect" && exit 1
  done
  log "INFO: NORDVPN: connected"
}
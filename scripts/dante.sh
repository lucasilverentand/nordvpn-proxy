#!/bin/bash

DANTE_CONFIG_TEMPLATE="/etc/sockd.conf.tmpl"
DANTE_CONFIG="/etc/sockd.conf"

setup_dante() {
  # overwrite config file with template
  log "INFO: DANTE: setting up config"
  

  INTERFACE=$(ifconfig | grep -oE "(nordtun|nordlynx)")
  LOCAL_NETWORK_CONFIGS=""
  if [[ -n ${LOCAL_SUBNETS:-''} ]]; then
    aln=(${LOCAL_SUBNETS//,/ })
    msg=""
    for l in ${aln[*]}; do
      # add to local networks var
      LOCAL_NETWORK_CONFIGS="${LOCAL_NETWORK_CONFIGS} 
     
client pass {
  from: ${l} to: 0.0.0.0/0
  log: error
}" 
    done
  fi

  # create config file from template replace variables in ${VAR} format
  export INTERFACE=${INTERFACE}
  export SOCK_PORT=${SOCK_PORT}
  export LOCAL_NETWORK_CONFIGS=${LOCAL_NETWORK_CONFIGS}
  cat ${DANTE_CONFIG_TEMPLATE} | envsubst > ${DANTE_CONFIG} 

  # Print config
  log "INFO: DANTE: config"
  cat ${DANTE_CONFIG}

  # verify config
  danted -Vf ${DANTE_CONFIG}

}

start_dante() {
  log "INFO: DANTE: starting"
  supervisorctl start dante
}


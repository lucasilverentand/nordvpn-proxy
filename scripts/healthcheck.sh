#!/bin/bash

set -e -u -o pipefail

# exit 1 if nordvpnd is not running.
if ! pgrep -x nordvpnd >/dev/null; then
  exit 1
fi

# exit 1 if danted is not running.
if ! pgrep -x danted >/dev/null; then
  exit 1
fi

source /scripts/vars.sh
source /scripts/nordvpn.sh

# use the nordvpn api to check if we are protected.
if test "$(curl -m 10 -s https://api.nordvpn.com/vpn/check/full | jq -r '.["status"]')" = "Protected"; then
  exit 0
fi

# fallback in case the api is down.
status=$(nordvpn status | grep -oP "Status: \K\w+")
if [ "connected" == ${status,,} ]; then
  exit 0
fi

# try to connect to the vpn, retry 3 times.
N=3
while ${N} -gt 0; do
  connect_nordvpn
  sleep 10 # wait for the connection to be established.
  status=$(nordvpn status | grep -oP "Status: \K\w+")
  # if we are connected, exit with success.
  [[ "connected" == ${status,,} ]] && exit 0
  N--
done


# exit with error since we failed to connect.
exit 1
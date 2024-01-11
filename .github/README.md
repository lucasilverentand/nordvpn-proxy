# NordVPN + SOCKS5 Proxy

This is a docker image that runs the NordVPN client in a container and exposes a SOCKS5 proxy on port 1080. It also includes a healthcheck to ensure that the VPN is always connected. This is useful for running applications that don't support connecting to a VPN directly. For example, you can use this to run a browser with all traffic routed through the VPN while the rest of your system uses your normal connection.

## Usage

```bash
docker run --cap-add NET_ADMIN -p 1080:1080 -e NORDVPN_TOKEN="<YOUR_TOKEN>" -e COUNTRY="nl" -d lucasilverentand/nordvpn-proxy
```

## Docker Compose

```yaml
version: "3.8"

services:
  nordvpn:
    image: lucasilverentand/nordvpn-proxy
    container_name: nordvpn
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
    environment:
      - NORDVPN_TOKEN=<YOUR_TOKEN>
      - COUNTRY=nl
    ports:
      - 1080:1080
```

## Configuration

The following environment variables can be used to configure the container:

| Variable             | Description                             | Default                                   |
| -------------------- | --------------------------------------- | ----------------------------------------- |
| ' `TZ``              | The timezone to use in the container    | `UTC`                                     |
| `SOCK_PORT`          | The port to expose the SOCKS5 proxy on  | `1080`                                    |
| `TECHNOLOGY`         | The VPN technology to use               | `nordlynx`                                |
| `ANALYTICS`          | Enable or disable analytics             | `off`                                     |
| `PROTOCOL`           | The VPN protocol to use                 | `udp`                                     |
| `OBFUSCATE`          | Enable or disable obfuscation           | `off`                                     |
| `CYBERSEC`           | Enable or disable CyberSec feature      | `off`                                     |
| `KILLSWITCH`         | Enable or disable kill switch           | `on`                                      |
| `IPV6`               | Enable or disable IPv6                  | `off`                                     |
| `DNS`                | The DNS servers to use                  | `193.110.81.0,185.253.5.0`                |
| `COUNTRY`            | The country to connect to               | ``                                        |
| `GROUP`              | The group to connect to                 | ``                                        |
| `SERVER`             | The server to connect to                | auto-generated from country + group       |
| `DOCKER_NET`         | The docker network to                   | auto-detected if left empty               |
| `LOCAL_SUBNETS`      | The local subnets to allow              | `192.168.0.0/16,172.16.0.0/12,10.0.0.0/8` |
| `NORDVPN_TOKEN_FILE` | The file to read the NordVPN token from | `/run/secrets/nordvpn_token`              |
| `NORDVPN_TOKEN`      | The NordVPN token to use                | ``                                        |

> `NORDVPN_TOKEN` takes precedence over `NORDVPN_TOKEN_FILE`

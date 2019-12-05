# Omada Controller Docker

## TP-Link Omada Controller bundled in a Docker image

| Image size | RAM usage | CPU usage |
| --- | --- | --- |
| 360MB | 350MB | Low |

It is based on:

- [Quentin McGaw Omada docker image](https://github.com/qdm12/omada)
- [Bebef Omada docker image](https://bitbucket.org/bebef/omada-controller-in-docker)
- [Debian Buster Slim](https://hub.docker.com/_/debian)
- [Omada controller software](https://www.tp-link.com/us/support/download/eap-controller/#Controller_Software)

## Setup

1. Create directories and set their permissions:

    ```sh
    mkdir -p volumenes/{logs,data,work}
    chown -R 1000 volumenes
    chmod 700 volumenes
    ```

1. Run using the following command:

    ```sh
    docker run -d --rm \
    --name omada-controller-example \
    -e TZ=Europe/Madrid \
    --network host \
    -v $(pwd)/volumenes/logs:/omada/logs \
    -v $(pwd)/volumenes/data:/omada/data \
    -v $(pwd)/volumenes/data:/omada/work \
    pcaro/omada-controller
    ```

    or use [docker-compose.yml](https://github.com/pcaro/omada-controller/blob/master/docker-compose.yml) with:

    ```sh
    docker-compose up -d
    ```

### Environment variables

| Environment variable | Default | Possible values | Description |
| --- | --- | --- | --- |
| HTTPPORT | `8080` | Port from `1025` to `65535` | Internal HTTP port, useful for redirection |
| HTTPSPORT | `8043` | Port from `1025` to `65535` | Internal HTTPS port, useful for redirection |

### Notes

- The Omada Controller Software will only be able to find EAPs in the same network as itself.
To make it work you need to use docker "host" networking _and_ have the docker host
in the same network as the EAPs. Standard network configuration with exposed ports,
which creates a new network the container runs in,
will _not_ work because the controller runs in a different broadcast domain in that case.
- You only need to set the `TZ` environment variable when your traffic/client graph has an offset.
- It is useful to change the HTTPSPORT as Omada redirects you to its internal `HTTPSPORT`.
So if you want to run the container with `-p 8000:8000` for the HTTPS port, you need to set `HTTPSPORT=8000`.
- From [TP Link Omada's FAQ](https://www.tp-link.com/us/support/faq/865), Omada controller uses the ports:
  - 8043 (TCP) for https
  - 8088 (TCP) for http
  - 27001 (UDP) for controller discovery
  - 27002 (TCP) for controller searching
  - ~27017 (TCP) for mongo DB server~ (internally)
  - 29810 (UDP) for EAP discovery
  - 29811 (TCP) for EAP management
  - 29812 (TCP) for EAP adoption
  - 29813 (TCP) for EAP upgrading

## TODOs

- [ ] Allow set user/group for running
- [ ] Instructions with proxy and port redirection

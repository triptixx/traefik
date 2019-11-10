[hub]: https://hub.docker.com/r/loxoo/traefik
[mbdg]: https://microbadger.com/images/loxoo/traefik
[git]: https://github.com/triptixx/traefik
[actions]: https://github.com/triptixx/traefik/actions

# [loxoo/traefik][hub]
[![Layers](https://images.microbadger.com/badges/image/loxoo/traefik.svg)][mbdg]
[![Latest Version](https://images.microbadger.com/badges/version/loxoo/traefik.svg)][hub]
[![Git Commit](https://images.microbadger.com/badges/commit/loxoo/traefik.svg)][git]
[![Docker Stars](https://img.shields.io/docker/stars/loxoo/traefik.svg)][hub]
[![Docker Pulls](https://img.shields.io/docker/pulls/loxoo/traefik.svg)][hub]
[![Build Status](https://github.com/triptixx/traefik/workflows/docker%20build/badge.svg)][actions]

## Usage

```shell
docker run -d \
    --name=srvtraefik \
    --restart=unless-stopped \
    --hostname=srvtraefik \
    -p 80:80 \
    -p 443:443 \
    -e ACME_MAIL=test@example.com \
    -e DOCKER_ENDPOINT=unix:///var/run/docker.sock \
    -v $PWD/config:/config \
    -v $PWD/acme:/acme \
    loxoo/traefik
```

## Environment

- `$ACME_MAIL`          - Email address used for Let's Encrypt registration. _required_
- `$DOCKER_ENDPOINT`    - Docker server endpoint. Can be a tcp or a unix socket endpoint. _optional_
- `$ACME_TEST`          - Use Let's Encrypt's staging server. _default: `false`_
- `$LOG_LEVEL`          - Logging severity levels. _default: `info`_
- `$TZ`                 - Timezone. _optional_

## Volume

- `/acme`               - The storage option sets the location where your ACME certificates are saved to.
- `/config`             - Server configuration file location.

## Network

- `80/tcp`              - Http port tcp.
- `443/tcp`             - Https port tcp.

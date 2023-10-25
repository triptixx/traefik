[hub]: https://hub.docker.com/r/loxoo/traefik
[git]: https://github.com/triptixx/traefik/tree/master
[actions]: https://github.com/triptixx/traefik/actions/workflows/main.yml

# [loxoo/traefik][hub]
[![Git Commit](https://img.shields.io/github/last-commit/triptixx/traefik/master)][git]
[![Build Status](https://github.com/triptixx/traefik/actions/workflows/main.yml/badge.svg?branch=master)][actions]
[![Latest Version](https://img.shields.io/docker/v/loxoo/traefik/latest)][hub]
[![Size](https://img.shields.io/docker/image-size/loxoo/traefik/latest)][hub]
[![Docker Stars](https://img.shields.io/docker/stars/loxoo/traefik.svg)][hub]
[![Docker Pulls](https://img.shields.io/docker/pulls/loxoo/traefik.svg)][hub]

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

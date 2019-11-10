#!/bin/sh
set -eo pipefail

# ANSI colour escape sequences
RED='\033[0;31m'
RESET='\033[0m'
error() { >&2 echo -e "${RED}Error: $@${RESET}"; exit 1; }

CONF_TRAEFIK='/config/traefik.yml'
CONF_DYNAMIC='/config/dynamic/defaultdynamic.yml'

if [ ! -e "$CONF_TRAEFIK" ]; then

    if [ -z "$ACME_MAIL" ]; then
        error "Missing 'ACME_MAIL' arguments required for auto configuration"
    fi

    cat > "$CONF_TRAEFIK" <<EOL
################################################################
# Main Section Configuration
################################################################
global:
  checknewversion: false
  sendAnonymousUsage: false

log:
  level: ${LOG_LEVEL:-INFO}
accessLog:
  fields:
    names:
      StartUTC: drop

################################################################
# Entry-points Configuration
################################################################
entryPoints:
  http:
    address: :80
  https:
    address: :443

################################################################
# Let's encrypt Configuration
################################################################
certificatesResolvers:
  letsencrypt:
    acme:
      email: ${ACME_MAIL}
      storage: /acme/acme.json
      tlsChallenge: {}

################################################################
# Web Configuration Backend
################################################################
api:
  insecure: true
ping: {}

################################################################
# Configuration Backend
################################################################
providers:
  file:
    directory: $(dirname $CONF_DYNAMIC)
EOL

fi

if [ -n "$DOCKER_ENDPOINT" ]; then
    if [ ! -e "$CONF_TRAEFIK" ]; then
        error "Missing file $CONF_TRAEFIK required for auto configuration providers Docker"
    else
        if [ ! $(awk '/^providers:/' "$CONF_TRAEFIK") ]; then
            cat >> "$CONF_TRAEFIK" <<EOL

################################################################
# Docker Configuration Backend
################################################################
providers:
EOL
        fi

        if [ ! $(awk '/^providers:/{flag=1} flag && /docker:/{print $NF;flag=""}' "$CONF_TRAEFIK") ]; then
            ENDPOINT="$(cat <<EOL
  docker:
    endpoint: ${DOCKER_ENDPOINT}
    exposedByDefault: false
EOL
)"
            ENDPOINT=$(printf '%s\n' "$ENDPOINT" | sed 's/\\/&&/g;s/^[[:blank:]]/\\&/;s/$/\\/')
            sed -i -e "/^providers:/a\\${ENDPOINT%?}" "$CONF_TRAEFIK"
        fi
    fi
fi

if [ ! -e "$CONF_DYNAMIC" ]; then
    if [ ! -d "$(dirname $CONF_DYNAMIC)" ];then
        mkdir -p "$(dirname $CONF_DYNAMIC)"
    fi

    cat > "$CONF_DYNAMIC" <<EOL
http:
  middlewares:
    redirect:
      redirectScheme:
        scheme: https
    defaultHeader:
      headers:
        stsSeconds: 63072000
        stsIncludeSubdomains: true
        stsPreload: true
        forceSTSHeader: true
        frameDeny: true
        contentTypeNosniff: true
        browserXssFilter: true
        contentSecurityPolicy: 'upgrade-insecure-requests;'
        referrerPolicy: no-referrer
        featurePolicy: "ambient-light-sensor 'none'; accelerometer 'none'; battery 'none'; camera 'none'; \
geolocation 'none'; gyroscope 'none'; magnetometer 'none'; microphone 'none'; payment 'none'; usb 'none';"

tls:
  options:
    defaultTls:
      sniStrict: true
      minVersion: VersionTLS12
      cipherSuites:
        - TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
        - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
        - TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
        - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
        - TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305
        - TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305
EOL

fi

if [ "$ACME_TEST" == true ]; then
    if ! $(grep -iq 'caServer' "$CONF_TRAEFIK"); then
        sed -i '/acme:/a\      caServer: https://acme-staging-v02.api.letsencrypt.org/directory' "$CONF_TRAEFIK"
    fi
else
    sed -i '/\s*caServer:.*/d' "$CONF_TRAEFIK"
fi

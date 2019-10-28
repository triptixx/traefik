#!/bin/sh
set -eo pipefail

# ANSI colour escape sequences
RED='\033[0;31m'
RESET='\033[0m'
error() { >&2 echo -e "${RED}Error: $@${RESET}"; exit 1; }

if [ ! -e /config/traefik.yml ]; then

    if [ -z "$ACME_MAIL" ]; then
        error "Missing 'ACME_MAIL' arguments required for auto configuration"
    fi

    cat > /config/traefik.yml <<EOL
################################################################
# Main Section Configuration
################################################################
global:
  checknewversion: false
  sendAnonymousUsage: false

log:
  level: ${LOG_LEVEL:-INFO}
accessLog: {}

ping: {}

################################################################
# Entry-points Configuration
################################################################
entryPoints:
  http:
    address: :80
  https:
    address: :443

tls:
  options:
    default:
      sniStrict: true
      minVersion: VersionTLS13
      cipherSuites:
        - TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305
        - TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305
        - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
        - TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
        - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
        - TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
        - TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256
        - TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256

################################################################
# Let's encrypt Configuration
################################################################
certificatesResolvers:
  default:
    acme:
      email: ${ACME_MAIL}
      storage: /config/acme.json
      tlsChallenge: {}

################################################################
# Web Configuration Backend
################################################################
api: {}

################################################################
# Docker Configuration Backend
################################################################
providers:
  docker:
    exposedByDefault: false
EOL

else
    if []; then
        printf -v spc %5s
        sed -i "/acme:/a\ ${spc}caServer: https://acme-staging.api.letsencrypt.org/directory" /config/traefik.yml
    fi
fi

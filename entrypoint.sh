#!/bin/sh
set -eo pipefail

source /usr/local/bin/gen-config.sh

exec "$@"

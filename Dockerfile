ARG ALPINE_TAG=3.15
ARG TRAEFIK_VER=2.6.3

FROM loxoo/alpine:${ALPINE_TAG} AS builder

ARG TRAEFIK_VER

WORKDIR /output/traefik
RUN apk add --no-cache upx; \
    wget -O- https://github.com/containous/traefik/releases/download/v${TRAEFIK_VER}/traefik_v${TRAEFIK_VER}_linux_amd64.tar.gz \
        | tar xz; \
    chmod +x traefik; \
    upx traefik

COPY *.sh /output/usr/local/bin/
RUN chmod +x /output/usr/local/bin/*.sh

#=============================================================

FROM loxoo/alpine:${ALPINE_TAG}

ARG TRAEFIK_VER
ENV XDG_CONFIG_HOME="/config"

LABEL org.label-schema.name="traefik" \
      org.label-schema.description="A Docker image for the cloud native edge router" \
      org.label-schema.url="https://traefik.io" \
      org.label-schema.version=${TRAEFIK_VER}

COPY --from=builder /output/ /

VOLUME ["/config", "/acme"]

EXPOSE 80/TCP 443/TCP 8080/TCP

HEALTHCHECK --start-period=10s --timeout=5s \
    CMD /traefik/traefik healthcheck

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["/traefik/traefik"]

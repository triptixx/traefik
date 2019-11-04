ARG ALPINE_TAG=3.10
ARG TRAEFIK_VER=2.0.4

FROM loxoo/alpine:${ALPINE_TAG} AS builder

ARG TRAEFIK_VER

WORKDIR /output/traefik
RUN apk add --no-cache upx; \
    wget https://github.com/containous/traefik/releases/download/v${TRAEFIK_VER}/traefik_v${TRAEFIK_VER}_linux_amd64.tar.gz \
    -O traefik.tar.gz; \
    tar xvzf traefik.tar.gz traefik; \
    rm -f traefik.tar.gz; \
    chmod +x traefik

COPY *.sh /output/usr/local/bin/
RUN chmod +x /output/usr/local/bin/*.sh

#=============================================================

FROM loxoo/alpine:${ALPINE_TAG}

ARG TRAEFIK_VER

LABEL org.label-schema.name="traefik" \
      org.label-schema.description="A Docker image for the cloud native edge router" \
      org.label-schema.url="https://traefik.io" \
      org.label-schema.version=${TRAEFIK_VER}
      
COPY --from=builder /output/ /

VOLUME ["/config"]

EXPOSE 80/TCP 443/TCP 8080/TCP

#HEALTHCHECK --start-period=10s --timeout=5s \
#    CMD /traefik/traefik healthcheck

ENTRYPOINT ["/traefik/traefik"]

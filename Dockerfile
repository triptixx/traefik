ARG TRAEFIK_VER="2.0.2"

FROM alpine:3.10

ARG TRAEFIK_VER
ENV SUID=900 SGID=900

LABEL org.label-schema.name="traefik" \
      org.label-schema.description="A Docker image for the cloud native edge router" \
      org.label-schema.url="https://traefik.io" \
      org.label-schema.version=${KNOT_VER}
      
COPY *.sh /output/usr/local/bin/

WORKDIR /knot-src
RUN wget "https://github.com/containous/traefik/releases/download/${TRAEFIK_VER}/traefik_linux-amd64" -O "/opt/traefik/traefik"; \
chmod +x /output/usr/local/bin/*.sh

VOLUME ["/config"]

EXPOSE 80/TCP 443/TCP

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["/traefik/traefik", "-c", "/traefik/traefik.yml"]

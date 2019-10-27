ARG TRAEFIK_VER="2.0.2"

FROM golang:alpine AS builder

ARG TRAEFIK_VER

RUN apk add --no-cache git upx; \
    go get -u github.com/containous/go-bindata/...; \
    go get -d -u github.com/containous/traefik; \
    cd ${GOPATH}/src/github.com/containous/traefik; \
    git checkout v${TRAEFIK_VER}; \
    go generate; \
    go build -ldflags "-s -w" -o /output/traefik/traefik ./cmd/traefik; \
    upx /output/traefik/traefik

#=============================================================

FROM alpine:3.10

ARG TRAEFIK_VER

LABEL org.label-schema.name="traefik" \
      org.label-schema.description="A Docker image for the cloud native edge router" \
      org.label-schema.url="https://traefik.io" \
      org.label-schema.version=${KNOT_VER}
      
COPY --from=builder /output/ /

VOLUME ["/config"]

EXPOSE 80/TCP 443/TCP 8080/TCP

HEALTHCHECK --start-period=10s --timeout=5s \
    CMD /traefik/traefik healthcheck

CMD ["/traefik/traefik", "--configfile", "/traefik/traefik.yml"]

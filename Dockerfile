FROM alpine:3.13 AS certs
RUN apk --update add ca-certificates

FROM alpine:3.13 AS collector-build
COPY ./otelcol-dev /otelcol-dev
RUN chmod 755 /otelcol-dev

FROM ubuntu:latest

ARG USER_UID=10001
USER ${USER_UID}

COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=collector-build /otelcol-dev /

ENTRYPOINT ["/otelcol-dev"]

EXPOSE 4317 55678 55679
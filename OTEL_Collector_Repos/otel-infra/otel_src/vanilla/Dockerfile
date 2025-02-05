# Default OpenTelemetry Collector Dockerfile
FROM otel/opentelemetry-collector:latest

COPY config.yaml /etc/otelcol/config.yaml


# EXPOSE map[4317/tcp:{} 4318/tcp:{} 55678/tcp:{} 55679/tcp:{}]
# EXPOSE map[4317/tcp:{} 4318/tcp:{}]
# ENTRYPOINT ["/otelcol"]
# CMD ["--config", "/etc/otelcol/config.yaml"]  
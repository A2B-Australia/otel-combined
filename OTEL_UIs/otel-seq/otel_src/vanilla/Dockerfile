# Default OpenTelemetry Collector Dockerfile
FROM otel/opentelemetry-collector:latest

COPY config.yaml /etc/otelcol/config.yaml

EXPOSE 4317        
EXPOSE 4318        
EXPOSE 8888        
EXPOSE 13133                

CMD ["--config", "/etc/otelcol/config.yaml"]
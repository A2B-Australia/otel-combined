# New Relic OpenTelemetry Collector Dockerfile
FROM otel/opentelemetry-collector-contrib:latest

# Environment variables for New Relic configuration
ENV NEW_RELIC_LICENSE_KEY="1006462664:c3ff00fd-1e35-4419-a9f1-5ef8f38912ec"
ENV NEW_RELIC_OTLP_ENDPOINT="otlp.nr-data.net:4317"

COPY config.yaml /etc/otelcol/config.yaml

EXPOSE 4317        
EXPOSE 4318        
EXPOSE 8888        
EXPOSE 13133        

CMD ["--config", "/etc/otelcol/config.yaml"]
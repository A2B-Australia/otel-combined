FROM jaegertracing/all-in-one:latest

WORKDIR /etc/jaeger

# Set environment variables
ENV SPAN_STORAGE_TYPE=memory
ENV MEMORY_MAX_TRACES=50000
ENV QUERY_BASE_PATH=/
ENV COLLECTOR_OTLP_ENABLED=true

# Copy local files into the container
COPY config/jaeger.yaml config.yaml
COPY config/jaeger-ui-config.yaml ui.yaml 
COPY config/sampling_strategies.json sampling_strategies.json

# Jaeger UI
EXPOSE 16686      

# Jaeger UI Admin
EXPOSE 16687      

# OTLP gRPC
EXPOSE 4317       

# OTLP HTTP
EXPOSE 4318       

# Model/collector gRPC
EXPOSE 14250      

# Jaeger collector HTTP
EXPOSE 14268      

# Admin port
# EXPOSE 14269      

# Jaeger thrift compact protocol (agent)
# EXPOSE 6831/udp   

# Jaeger thrift binary protocol (agent)
# EXPOSE 6832/udp   

# Jaeger configuration server
# EXPOSE 5778       


ENTRYPOINT ["/go/bin/all-in-one-linux"]
CMD ["--config-file=/etc/jaeger/config.yaml"]
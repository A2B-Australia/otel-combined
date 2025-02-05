# OpenTelemetry Node.js Test Application

This application demonstrates OpenTelemetry trace instrumentation in Node.js by generating synthetic traces that simulate an e-commerce order processing system.

## Overview

The application creates artificial traces using the OpenTelemetry SDK, simulating a typical order processing flow with database operations and payment processing. It generates new traces every 5 seconds and sends them to an OpenTelemetry collector.

## Dependencies

- `@opentelemetry/exporter-trace-otlp-grpc`: OTLP gRPC exporter for sending traces
- `@opentelemetry/resources`: Resource management for telemetry data
- `@opentelemetry/semantic-conventions`: Standard semantic conventions
- `@opentelemetry/sdk-trace-node`: Node.js tracer implementation
- `@opentelemetry/api`: OpenTelemetry core API
- `@faker-js/faker`: Generates realistic fake data

## Configuration

The application is configured with:
- Service name: 'fake-service'
- Service version: '1.0.0'
- OTLP endpoint: 'http://localhost:4317'

## Main Components

### Trace Provider Setup
```javascript
const provider = new NodeTracerProvider({
    resource: new Resource({
        [SemanticResourceAttributes.SERVICE_NAME]: 'fake-service',
        [SemanticResourceAttributes.SERVICE_VERSION]: '1.0.0',
    }),
});
```
Initializes the trace provider with service identification attributes.

### Span Generation

The application generates three types of spans:

1. **Parent Span: processOrder**
   - Represents the overall order processing operation
   - Attributes include:
     - order.id
     - customer.id
     - order.amount
     - order.items
     - customer.country
     - customer.city

2. **Child Span: database.query**
   - Simulates database operations
   - Attributes include:
     - db.system
     - db.operation
     - db.statement

3. **Child Span: payment.process**
   - Simulates payment processing
   - Attributes include:
     - payment.provider
     - payment.status
     - payment.amount
   - Includes error simulation (10% chance of failure)

## Error Handling

- The application implements comprehensive error handling at each span level
- Errors are properly recorded using `recordException`
- Span status is set to ERROR when exceptions occur
- All spans are properly ended in finally blocks

## Trace Generation

- Traces are generated every 5 seconds via the `startGenerating` function
- Each trace simulates a complete order processing flow
- Random delays are introduced using `simulateApiCall` to mimic real-world latency
- Failed operations are logged to the console

## Usage

The application automatically starts generating traces when executed. It will continue to generate traces until terminated.

Monitor the console output to see when new traces are generated:
```
Starting to generate fake traces...
Generated new trace at: [timestamp]
```

## Integration

This application is designed to work with an OpenTelemetry collector running on localhost:4317. Ensure your collector is properly configured to receive gRPC OTLP traces before running the application.

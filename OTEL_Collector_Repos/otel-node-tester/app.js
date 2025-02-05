// const OTEL_GRPC = ":4317";
const OTEL_HTML = "http://otel-infra--l6ggj98.kindbeach-7f68249c.australiaeast.azurecontainerapps.io/";

import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-grpc';
import { Resource } from '@opentelemetry/resources';
import { SemanticResourceAttributes } from '@opentelemetry/semantic-conventions';
import { NodeTracerProvider } from '@opentelemetry/sdk-trace-node';
import traceAPI from '@opentelemetry/sdk-trace-base';
const { SimpleSpanProcessor } = traceAPI;
import { trace, context, SpanStatusCode } from '@opentelemetry/api';
import { faker } from '@faker-js/faker';

// Initialize the trace provider
const provider = new NodeTracerProvider({
    resource: new Resource({
        [SemanticResourceAttributes.SERVICE_NAME]: 'fake-service',
        [SemanticResourceAttributes.SERVICE_VERSION]: '1.0.0',
    }),
});

// Configure the OTLP exporter
const otlpExporter = new OTLPTraceExporter({
    url: OTEL_HTML, 
});



// Add the OTLP exporter to the provider
provider.addSpanProcessor(new SimpleSpanProcessor(otlpExporter));
provider.register();

// Get a tracer
const tracer = trace.getTracer('fake-service-tracer');

// Function to simulate an API call
async function simulateApiCall() {
    return new Promise((resolve) => {
        setTimeout(resolve, Math.random() * 1000);
    });
}

// Generate fake spans
async function generateFakeData() {
    return await context.with(context.active(), async (ctx) => {
        const parentSpan = tracer.startSpan('processOrder', undefined, ctx);
        
        try {
            parentSpan.setAttributes({
                'order.id': faker.string.uuid(),
                'customer.id': faker.string.uuid(),
                'order.amount': faker.number.float({ min: 10, max: 1000, precision: 2 }),
                'order.items': faker.number.int({ min: 1, max: 10 }),
                'customer.country': faker.location.country(),
                'customer.city': faker.location.city(),
            });

            // Simulate database operation
            await context.with(trace.setSpan(ctx, parentSpan), async (innerCtx) => {
                const dbSpan = tracer.startSpan('database.query', undefined, innerCtx);
                try {
                    await simulateApiCall();
                    dbSpan.setAttributes({
                        'db.system': 'postgresql',
                        'db.operation': 'INSERT',
                        'db.statement': 'INSERT INTO orders...',
                    });
                } finally {
                    dbSpan.end();
                }
            });

            // Simulate payment processing
            await context.with(trace.setSpan(ctx, parentSpan), async (innerCtx) => {
                const paymentSpan = tracer.startSpan('payment.process', undefined, innerCtx);
                try {
                    await simulateApiCall();
                    paymentSpan.setAttributes({
                        'payment.provider': faker.helpers.arrayElement(['stripe', 'paypal', 'square']),
                        'payment.status': faker.helpers.arrayElement(['success', 'success', 'failed']),
                        'payment.amount': faker.number.float({ min: 10, max: 1000, precision: 2 }),
                    });

                    // Simulate some payment errors
                    if (faker.number.int({ min: 1, max: 10 }) === 1) {
                        throw new Error('Payment processing failed');
                    }
                } catch (error) {
                    paymentSpan.recordException(error);
                    paymentSpan.setStatus({ code: SpanStatusCode.ERROR });
                    throw error;
                } finally {
                    paymentSpan.end();
                }
            });

        }
        catch (error) {
            parentSpan.recordException(error);
            parentSpan.setStatus({ code: SpanStatusCode.ERROR });
        } finally {
            parentSpan.end();
        }
    });
}

// Generate traces every few seconds
async function startGenerating() {
    console.log('Starting to generate fake traces...');
    
    setInterval(async () => {
        try {
            await generateFakeData();
            console.log('Generated new trace at:', new Date().toISOString());
        }
        catch (error) {
            console.error('Error generating trace:', error);
        }
    }, 5000); // Generate a new trace every 5 seconds
}

startGenerating();
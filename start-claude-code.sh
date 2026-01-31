#!/bin/bash
# Claude Code with OpenTelemetry Monitoring
# This script starts Claude Code with telemetry enabled

# Enable telemetry
export CLAUDE_CODE_ENABLE_TELEMETRY=1

# Configure OTLP exporter for both metrics and logs
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp

# Use gRPC protocol
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc

# Point to local OTEL collector
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317

# Faster export intervals for debugging (optional - comment out for production)
export OTEL_METRIC_EXPORT_INTERVAL=10000  # 10 seconds
export OTEL_LOGS_EXPORT_INTERVAL=5000     # 5 seconds

# Optional: Enable user prompt logging (disabled by default for privacy)
# export OTEL_LOG_USER_PROMPTS=1

# Optional: Add custom resource attributes for team/project identification
# export OTEL_RESOURCE_ATTRIBUTES="team=data-engineering,project=log-ingestion"

echo "Starting Claude Code with telemetry enabled..."
echo "  - Metrics: OTLP -> localhost:4317"
echo "  - Logs:    OTLP -> localhost:4317"
echo ""

# Run Claude Code with all arguments passed through
claude "$@"

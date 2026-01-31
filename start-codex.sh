#!/bin/bash
# OpenAI Codex with OpenTelemetry Monitoring
# This script starts Codex CLI with telemetry enabled via environment variables
#
# Note: For persistent configuration, add the [otel] section to ~/.codex/config.toml instead

# Enable telemetry via environment variables (alternative to config.toml)
export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4317"
export OTEL_EXPORTER_OTLP_PROTOCOL="grpc"

# Export intervals for debugging (optional - comment out for production)
export OTEL_METRIC_EXPORT_INTERVAL=10000  # 10 seconds

# Optional: Enable user prompt logging (disabled by default for privacy)
# export CODEX_OTEL_LOG_USER_PROMPT=1

# Optional: Add custom resource attributes for team/project identification
# export OTEL_RESOURCE_ATTRIBUTES="team=data-engineering,project=log-ingestion"

echo "Starting OpenAI Codex with telemetry enabled..."
echo "  - Endpoint: localhost:4317 (gRPC)"
echo ""
echo "Note: Ensure [otel] is configured in ~/.codex/config.toml:"
echo "  [otel]"
echo "  environment = \"dev\""
echo "  log_user_prompt = false"
echo ""
echo "  [otel.exporter.\"otlp-grpc\"]"
echo "  endpoint = \"http://localhost:4317\""
echo ""

# Run Codex with all arguments passed through
codex "$@"

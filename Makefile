# AI Coding Assistant with OpenTelemetry Monitoring
# Usage: make claude [ARGS="your args here"]
#        make codex [ARGS="your args here"]

# Common OTEL configuration
export OTEL_EXPORTER_OTLP_PROTOCOL := grpc
export OTEL_EXPORTER_OTLP_ENDPOINT := http://localhost:4317
export OTEL_METRIC_EXPORT_INTERVAL := 10000
export OTEL_LOGS_EXPORT_INTERVAL := 5000

# Claude Code specific
export CLAUDE_CODE_ENABLE_TELEMETRY := 1
export OTEL_METRICS_EXPORTER := otlp
export OTEL_LOGS_EXPORTER := otlp

# Optional: Enable user prompt logging (disabled by default for privacy)
# export OTEL_LOG_USER_PROMPTS := 1
# export CODEX_OTEL_LOG_USER_PROMPT := 1

# Optional: Add custom resource attributes for team/project identification
# export OTEL_RESOURCE_ATTRIBUTES := team=data-engineering,project=log-ingestion

.PHONY: claude codex up down logs help

claude:
	@echo "Starting Claude Code with telemetry enabled..."
	@echo "  - Endpoint: localhost:4317 (gRPC)"
	@echo ""
	claude $(ARGS)

codex:
	@echo "Starting OpenAI Codex with telemetry enabled..."
	@echo "  - Endpoint: localhost:4317 (gRPC)"
	@echo ""
	@echo "Note: Ensure [otel] is configured in ~/.codex/config.toml"
	@echo ""
	codex $(ARGS)

up:
	docker-compose up -d

down:
	docker-compose down

logs:
	docker-compose logs -f otel-collector

help:
	@echo "Usage:"
	@echo "  make up               - Start monitoring stack (docker-compose)"
	@echo "  make down             - Stop monitoring stack"
	@echo "  make logs             - View OTEL collector logs"
	@echo ""
	@echo "  make claude           - Start Claude Code with telemetry"
	@echo "  make claude ARGS='...' - Start Claude Code with arguments"
	@echo ""
	@echo "  make codex            - Start OpenAI Codex with telemetry"
	@echo "  make codex ARGS='...' - Start Codex with arguments"
	@echo ""
	@echo "  make help             - Show this help message"

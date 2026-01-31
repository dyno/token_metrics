# AI Coding Assistant Monitoring Stack

Local observability stack for monitoring **Claude Code** and **OpenAI Codex** usage, costs, and performance.

## Architecture

```
┌─────────────────┐     ┌──────────────────────┐     ┌─────────────────┐
│  Claude Code    │────▶│  OTEL Collector      │────▶│   Prometheus    │
│  or Codex CLI   │     │  (localhost:4317)    │     │   (Metrics)     │
└─────────────────┘     └──────────────────────┘     └─────────────────┘
                               │                            │
                               │                            ▼
                               │                    ┌─────────────────┐
                               └───────────────────▶│   Grafana       │
                                                    │   (Dashboard)   │
                               ┌─────────────────┐  └─────────────────┘
                               │  VictoriaLogs   │          ▲
                               │   (Events)      │──────────┘
                               └─────────────────┘
```

## Quick Start

### 1. Start the monitoring stack

```bash
cd token_metrics
docker-compose up -d
```

Persistent data is stored under `./data/` (Prometheus, VictoriaMetrics, VictoriaLogs, Grafana).

### 2. Verify services are running

```bash
docker-compose ps
```

All services should show as "Up":
- `otel-collector` - Receives telemetry from Claude Code / Codex
- `prometheus` - Stores metrics
- `victorialogs` - Stores events/logs
- `grafana` - Visualization

### 3. Run your AI coding assistant with telemetry

#### Option A: Claude Code

Use the provided script:
```bash
./start-claude-code.sh
```

Or set environment variables manually:
```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
claude
```

#### Option B: OpenAI Codex

First, configure `~/.codex/config.toml`:
```toml
[otel]
environment = "dev"
log_user_prompt = false

[otel.exporter."otlp-grpc"]
endpoint = "http://localhost:4317"
```

Then run Codex:
```bash
./start-codex.sh
```

Or start directly:
```bash
export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4317"
codex
```

### 4. View dashboards

Open Grafana: http://localhost:3000
- Username: `admin`
- Password: `admin`

Pre-provisioned dashboards (log‑derived):
- **Claude Code - Basic Metrics (Logs)** - Token usage, requests, latency
- **OpenAI Codex - Basic Metrics (Logs)** - Token usage, requests, latency

Dashboards are provisioned under the **Token Usage** folder in Grafana.

## Service URLs

| Service | URL | Purpose |
|---------|-----|---------|
| Grafana | http://localhost:3000 | Dashboards & visualization |
| Prometheus | http://localhost:9090 | Metrics queries |
| VictoriaLogs | http://localhost:9428 | Log queries |
| OTEL Collector | localhost:4317 (gRPC) | Telemetry receiver |

## Telemetry Available

This stack ingests OTLP **logs/events** from Claude Code and Codex. The basic dashboards are built from VictoriaLogs queries (log‑derived).

### Claude Code Metrics (if emitted)

| Metric | Description |
|--------|-------------|
| `claude_code_session_count` | Number of CLI sessions |
| `claude_code_cost_usage` | Cost in USD |
| `claude_code_token_usage` | Tokens used (by type: input/output/cache) |
| `claude_code_active_time_total` | Active usage time |
| `claude_code_lines_of_code_count` | Lines added/removed |
| `claude_code_commit_count` | Git commits created |
| `claude_code_pull_request_count` | PRs created |

### OpenAI Codex Metrics (if emitted)

| Metric | Description |
|--------|-------------|
| `codex_api_request` | API request count and duration |
| `codex_token_count` | Tokens used (by type: input/output) |
| `codex_tool_decision` | Tool approvals/denials |
| `codex_tool_result` | Tool execution duration and success |
| `codex_sse_event` | Streaming event metrics |
| `codex_user_prompt` | Prompt length (content redacted by default) |

## Events Logged

### Claude Code Events

| Event | Description |
|-------|-------------|
| `claude_code.user_prompt` | User prompts (content redacted by default) |
| `claude_code.api_request` | API calls with model, cost, tokens |
| `claude_code.tool_decision` | Tool accept/reject decisions |
| `claude_code.tool_result` | Tool execution results |
| `claude_code.api_error` | API errors |

### OpenAI Codex Events

| Event | Description |
|-------|-------------|
| `codex.user_prompt` | User prompts (content redacted by default) |
| `codex.api_request` | API calls with model and tokens |
| `codex.tool_decision` | Tool accept/reject decisions |
| `codex.tool_result` | Tool execution results |
| `codex.sse_event` | Streaming events |

## Configuration

### Claude Code Configuration

#### Enable user prompt logging (optional)
```bash
export OTEL_LOG_USER_PROMPTS=1
```

#### Add team/project tags
```bash
export OTEL_RESOURCE_ATTRIBUTES="team=data-engineering,project=log-ingestion"
```

#### Persist telemetry settings

Add to your shell profile (`~/.bashrc` or `~/.zshrc`):
```bash
# Claude Code Telemetry
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

### OpenAI Codex Configuration

#### Full config.toml example

Create/edit `~/.codex/config.toml`:
```toml
[otel]
environment = "dev"          # dev | staging | prod
log_user_prompt = false      # set true to log prompt content

# OTLP/gRPC exporter (the section name sets the exporter type)
[otel.exporter."otlp-grpc"]
endpoint = "http://localhost:4317"

# For OTLP/HTTP instead, replace the above with:
# [otel.exporter."otlp-http"]
# endpoint = "http://localhost:4318/v1/logs"
# protocol = "binary"        # or "json"

[analytics]
enabled = false              # disable anonymous metrics to OpenAI
```

#### Add team/project tags
```bash
export OTEL_RESOURCE_ATTRIBUTES="team=data-engineering,project=log-ingestion"
```

## Importing Advanced Dashboards

### Pigsty Dashboard (Claude Code)

The Pigsty dashboard provides advanced features including session tracking, event timelines, and detailed tool usage analysis.

```bash
curl -sL https://raw.githubusercontent.com/pgsty/pigsty/main/files/grafana/node/claude-code.json \
  -o grafana/dashboards/claude-code-pigsty.json
```

The dashboard will auto-load (Grafana watches the dashboards folder).

## Troubleshooting

### Check OTEL Collector logs
```bash
docker-compose logs -f otel-collector
```

### Verify logs are being received (VictoriaLogs)
```bash
# Claude Code events
curl 'http://localhost:9428/select/logsql/query?query=event.name:claude_code.api_request'

# Codex events
curl 'http://localhost:9428/select/logsql/query?query=event.name:codex.api_request'
```

### Query VictoriaLogs directly
```bash
# Claude Code events
curl 'http://localhost:9428/select/logsql/query?query=event.name:claude_code.api_request'

# Codex events
curl 'http://localhost:9428/select/logsql/query?query=event.name:codex.sse_event'
```

### Restart services
```bash
docker-compose restart
```

## Stopping the Stack

```bash
docker-compose down
```

To also remove volumes (data):
```bash
docker-compose down -v
```

## References

### Claude Code
- [Claude Code Monitoring Docs](https://code.claude.com/docs/en/monitoring-usage)
- [Anthropic Monitoring Guide](https://github.com/anthropics/claude-code-monitoring-guide)
- [Pigsty Claude Code Dashboard](https://github.com/pgsty/pigsty/blob/main/files/grafana/node/claude-code.json)

### OpenAI Codex
- [Codex Advanced Configuration](https://developers.openai.com/codex/config-advanced/)
- [Codex Security & Telemetry](https://developers.openai.com/codex/security/)

### General
- [OpenTelemetry Configuration](https://opentelemetry.io/docs/collector/configuration/)

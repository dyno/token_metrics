# Claude Code Monitoring Stack

Local observability stack for monitoring Claude Code usage, costs, and performance.

## Architecture

```
┌─────────────────┐     ┌──────────────────────┐     ┌─────────────────┐
│   Claude Code   │────▶│  OTEL Collector      │────▶│   Prometheus    │
│   (Terminal)    │     │  (localhost:4317)    │     │   (Metrics)     │
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
cd claude_code_metrics
docker-compose up -d
```

### 2. Verify services are running

```bash
docker-compose ps
```

All services should show as "Up":
- `otel-collector` - Receives telemetry from Claude Code
- `prometheus` - Stores metrics
- `victorialogs` - Stores events/logs
- `grafana` - Visualization

### 3. Run Claude Code with telemetry

Option A: Use the provided script:
```bash
./start-claude-code.sh
```

Option B: Set environment variables manually:
```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
claude
```

### 4. View dashboards

Open Grafana: http://localhost:3000
- Username: `admin`
- Password: `admin`

A basic dashboard is pre-provisioned. For the full-featured Pigsty dashboard, see below.

## Service URLs

| Service | URL | Purpose |
|---------|-----|---------|
| Grafana | http://localhost:3000 | Dashboards & visualization |
| Prometheus | http://localhost:9090 | Metrics queries |
| VictoriaLogs | http://localhost:9428 | Log queries |
| OTEL Collector | localhost:4317 (gRPC) | Telemetry receiver |

## Importing the Pigsty Dashboard

The Pigsty dashboard provides advanced features including session tracking, event timelines, and detailed tool usage analysis.

### Steps:

1. Download the dashboard JSON:
   ```bash
   curl -sL https://raw.githubusercontent.com/pgsty/pigsty/main/files/grafana/node/claude-code.json \
     -o grafana/dashboards/claude-code-pigsty.json
   ```

2. The dashboard will auto-load (Grafana watches the dashboards folder)

3. Or manually import:
   - Go to Grafana → Dashboards → Import
   - Upload the JSON file
   - Select data sources:
     - `ds-prometheus` → Prometheus
     - `ds-vlogs` → VictoriaLogs

## Metrics Available

| Metric | Description |
|--------|-------------|
| `claude_code_session_count` | Number of CLI sessions |
| `claude_code_cost_usage` | Cost in USD |
| `claude_code_token_usage` | Tokens used (by type: input/output/cache) |
| `claude_code_active_time_total` | Active usage time |
| `claude_code_lines_of_code_count` | Lines added/removed |
| `claude_code_commit_count` | Git commits created |
| `claude_code_pull_request_count` | PRs created |

## Events Logged

| Event | Description |
|-------|-------------|
| `claude_code.user_prompt` | User prompts (content redacted by default) |
| `claude_code.api_request` | API calls with model, cost, tokens |
| `claude_code.tool_decision` | Tool accept/reject decisions |
| `claude_code.tool_result` | Tool execution results |
| `claude_code.api_error` | API errors |

## Configuration

### Enable user prompt logging (optional)

By default, prompt content is redacted. To enable:
```bash
export OTEL_LOG_USER_PROMPTS=1
```

### Add team/project tags

```bash
export OTEL_RESOURCE_ATTRIBUTES="team=data-engineering,project=log-ingestion"
```

### Persist telemetry settings

Add to your shell profile (`~/.bashrc` or `~/.zshrc`):
```bash
# Claude Code Telemetry
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

## Troubleshooting

### Check OTEL Collector logs
```bash
docker-compose logs -f otel-collector
```

### Verify metrics are being received
```bash
curl http://localhost:8889/metrics | grep claude
```

### Query VictoriaLogs directly
```bash
curl 'http://localhost:9428/select/logsql/query?query=_msg:claude_code'
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

- [Claude Code Monitoring Docs](https://code.claude.com/docs/en/monitoring-usage)
- [Anthropic Monitoring Guide](https://github.com/anthropics/claude-code-monitoring-guide)
- [Pigsty Claude Code Dashboard](https://github.com/pgsty/pigsty/blob/main/files/grafana/node/claude-code.json)
- [OpenTelemetry Configuration](https://opentelemetry.io/docs/collector/configuration/)

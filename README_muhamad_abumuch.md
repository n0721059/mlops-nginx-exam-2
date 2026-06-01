# MLOps — Nginx API Gateway for Sentiment Analysis

An Nginx API Gateway serving a scikit-learn sentiment model through FastAPI,
with load balancing, HTTPS, authentication, rate limiting, A/B testing, and a
Prometheus + Grafana monitoring stack — all orchestrated with Docker Compose.

## Architecture

```
                          HTTPS (443)
        Client ──────────────�────────────► Nginx Gateway ──┬── api-v1 ×3  (standard)
          │  HTTP (80) ─► 301 redirect ─────────┘           └── api-v2     (debug)
          │
          └─ Nginx :8080 /stub_status ─► nginx-exporter ─► Prometheus ─► Grafana
```

Nginx is the single entry point. It terminates TLS, enforces basic auth and a
rate limit on `/predict`, load-balances across three `api-v1` replicas, and
routes to `api-v2` when the request carries `X-Experiment-Group: debug`.

## Features

| Feature | How |
|---|---|
| Reverse proxy | Nginx fronts all API traffic |
| Load balancing | 3 `api-v1` replicas, per-request Docker DNS resolution |
| HTTPS | Self-signed cert; HTTP `:80` → 301 → HTTPS `:443` |
| Access control | HTTP basic auth (`.htpasswd`) on `/predict` |
| Rate limiting | 10 req/s per IP (`limit_req`), returns `429` when exceeded |
| A/B testing | `X-Experiment-Group: debug` header → `api-v2`, else `api-v1` |
| Monitoring | `stub_status` → nginx-exporter → Prometheus → Grafana |

## Usage

```bash
make start-project   # generate certs, build images, launch the stack
make test            # run the automated validation suite (6 tests)
make stop-project    # tear everything down
```

Endpoints:
- API:        `https://localhost/predict` (basic auth `admin:admin`)
- Prometheus: `http://localhost:9090`
- Grafana:    `http://localhost:3000` (`admin` / `admin`)

### Example requests

```bash
# Standard prediction (api-v1)
curl -X POST https://localhost/predict \
  -H "Content-Type: application/json" \
  -d '{"sentence": "I love this!"}' \
  --user admin:admin --cacert deployments/nginx/certs/nginx.crt

# Debug variant (api-v2) — returns full class probabilities
curl -X POST https://localhost/predict \
  -H "Content-Type: application/json" \
  -H "X-Experiment-Group: debug" \
  -d '{"sentence": "I love this!"}' \
  --user admin:admin --cacert deployments/nginx/certs/nginx.crt
```

## Project structure

```
deployments/nginx/      Dockerfile, nginx.conf, certs/, .htpasswd
deployments/prometheus/ prometheus.yml
src/api/v1, v2/         FastAPI apps + Dockerfiles
model/model.joblib      pre-trained scikit-learn pipeline
docker-compose.yml      service orchestration
Makefile                start-project / stop-project / test
tests/run_tests.sh      automated validation
```

## Requirements

Docker with Compose v2 (`docker compose`). All other dependencies are
containerized.

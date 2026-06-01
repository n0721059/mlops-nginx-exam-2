# ====================================================================
# MLOps Nginx exam — project control panel
# Usage:  make start-project | make stop-project | make test
# ( lines MUST be indented with TABS, TABS TABS not spaces.)
# ====================================================================

COMPOSE  = docker compose
CERT_DIR = deployments/nginx/certs

.PHONY: start-project stop-project test certs logs

## Generate self-signed TLS certs — only if they don't already exist.
certs:
	@if [ ! -f $(CERT_DIR)/nginx.crt ]; then \
	echo "Generating self-signed certificate..."; \
	mkdir -p $(CERT_DIR); \
	openssl req -x509 -nodes -newkey rsa:2048 \
	-keyout $(CERT_DIR)/nginx.key \
	-out    $(CERT_DIR)/nginx.crt \
	-days 365 -subj "/CN=localhost" \
	-addext "subjectAltName=DNS:localhost,IP:127.0.0.1"; \
	else \
	echo "Certificate already present, skipping."; \
	fi

## Build all images and start the full stack in the background.
start-project: certs
	$(COMPOSE) up -d --build
	@echo "Waiting for Grafana to finish booting..."
	@for i in $$(seq 1 30); do \
	if curl -sf http://localhost:3000/api/health >/dev/null 2>&1; then \
	echo "All services ready."; break; \
	fi; \
	sleep 2; \
	done
	@echo "-----------------------------------------------"
	@echo "  HTTPS API : https://localhost/predict"
	@echo "  Prometheus: http://localhost:9090"
	@echo "  Grafana   : http://localhost:3000  (admin/admin)"
	@echo "-----------------------------------------------"

## Stop and remove containers + network (named volumes are kept).
stop-project:
	$(COMPOSE) down

## Run the automated validation suite (stack must already be running).
test:
	@bash tests/run_tests.sh

## Tail logs from every service — handy for debugging.
logs:
	$(COMPOSE) logs -f

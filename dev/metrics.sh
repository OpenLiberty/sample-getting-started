#!/usr/bin/env bash
# dev/metrics.sh — fetch the mpMetrics endpoint from the getting-started pod
#
# Usage:
#   ./dev/metrics.sh                      # all metrics (default)
#   ./dev/metrics.sh /metrics/base        # base metrics
#   ./dev/metrics.sh /metrics/application # application metrics

set -uo pipefail  # no -e: port-forward drops are handled explicitly

METRICS_PATH="${1:-/metrics}"
LABEL="app.kubernetes.io/name=getting-started"
LIBERTY_PORT=9443
KEYCLOAK_PORT=8080
PF_PID=""

cleanup() { [[ -n "$PF_PID" ]] && kill "$PF_PID" 2>/dev/null; }
trap cleanup EXIT

start_portforward() {
  [[ -n "$PF_PID" ]] && kill "$PF_PID" 2>/dev/null
  oc port-forward "$POD" "${LIBERTY_PORT}:${LIBERTY_PORT}" "${KEYCLOAK_PORT}:${KEYCLOAK_PORT}" \
    2>/dev/null &
  PF_PID=$!
}

# ── 1. Resolve pod name ──────────────────────────────────────────────────────
POD=$(oc get pod -l "$LABEL" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [[ -z "$POD" ]]; then
  echo "ERROR: no pod found with label $LABEL" >&2
  exit 1
fi
echo "Using pod: $POD"

# ── 2. Wait for Keycloak container to be ready ───────────────────────────────
echo "Waiting for Keycloak container to be ready..."
oc wait pod "$POD" --for=condition=Ready --timeout=300s 2>/dev/null || true

# ── 3. Port-forward and wait for Keycloak OIDC endpoint ─────────────────────
echo "Waiting for Keycloak realm..."
start_portforward
for i in $(seq 1 90); do
  # Restart port-forward if it died
  if ! kill -0 "$PF_PID" 2>/dev/null; then
    sleep 3
    start_portforward
  fi
  curl -sf "http://localhost:${KEYCLOAK_PORT}/realms/liberty/.well-known/openid-configuration" \
    -o /dev/null 2>/dev/null && break
  sleep 3
done

# ── 4. Obtain JWT from Keycloak ──────────────────────────────────────────────
echo "Obtaining token..."
TOKEN=$(curl -sf -X POST \
  "http://localhost:${KEYCLOAK_PORT}/realms/liberty/protocol/openid-connect/token" \
  -d "grant_type=password&client_id=metrics-client&client_secret=metrics-secret&username=metrics&password=metrics" \
  | jq -r .access_token)

if [[ -z "$TOKEN" ]] || [[ "$TOKEN" == "null" ]]; then
  echo "ERROR: failed to obtain token — check Keycloak logs with:" >&2
  echo "  oc logs $POD -c keycloak | grep -i error" >&2
  exit 1
fi
echo "Token obtained."

# ── 5. Fetch metrics ─────────────────────────────────────────────────────────
echo ""
echo "GET https://localhost:${LIBERTY_PORT}${METRICS_PATH}"
echo "────────────────────────────────────────────────────"
HTTP_CODE=$(curl -sk -o /tmp/metrics_response.txt -w "%{http_code}" \
  -H "Authorization: Bearer $TOKEN" \
  "https://localhost:${LIBERTY_PORT}${METRICS_PATH}")
echo "HTTP $HTTP_CODE"
cat /tmp/metrics_response.txt

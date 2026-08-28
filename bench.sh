#!/bin/bash
# ---------------------------------------------------------------------------
# OnlineOrder endpoint latency benchmark
#
# Prerequisite: Postgres is running + the app is running on localhost:8080
# Usage: ./bench.sh [requests per endpoint, default 100]
#
# Measures end-to-end HTTP latency: TCP connection setup + full Spring stack
# + SQL + JSON serialization.
# This is not the same as "database query time" — use EXPLAIN ANALYZE if you
# want pure SQL timing.
#
# Note --noproxy '*': if a proxy like Clash/Surge is running locally, the
# http_proxy env var will hijack requests to localhost too, so it must be
# bypassed explicitly.
# ---------------------------------------------------------------------------
set -e

N=${1:-100}
BASE="http://localhost:8080"
USER_EMAIL="foo@mail.com"
USER_PASS="123456"
CURL=(curl -s --noproxy '*')

# ---- Health check: must get a real HTTP status code, not just whether curl errored ----------
CODE=$("${CURL[@]}" -o /dev/null -w "%{http_code}" --max-time 5 "$BASE/restaurants/menu" || echo "000")
if [ "$CODE" = "000" ]; then
  echo "Error: cannot connect to $BASE. Start the app (./gradlew bootRun) before running this script."
  exit 1
fi
if [ "$CODE" != "200" ]; then
  echo "Error: $BASE/restaurants/menu returned HTTP $CODE, expected 200."
  echo "       502/504 usually means a proxy is intercepting it; for other codes, check the app logs."
  exit 1
fi

TMPDIR_BENCH=$(mktemp -d)
COOKIE="$TMPDIR_BENCH/cookie.txt"
trap 'rm -rf "$TMPDIR_BENCH"' EXIT

# ---- Stats function: reads a column of millisecond values, prints avg / p50 / p95 / p99 / max ----------------
stats() {
  python3 - "$1" "$2" <<'PY'
import sys, statistics
label, path = sys.argv[1], sys.argv[2]
ms = sorted(float(l) * 1000 for l in open(path) if l.strip())
pct = lambda p: ms[min(len(ms) - 1, int(len(ms) * p / 100))]
print(f"{label:<36} n={len(ms):<4} avg={statistics.mean(ms):6.2f}  "
      f"p50={pct(50):6.2f}  p95={pct(95):6.2f}  p99={pct(99):6.2f}  max={max(ms):6.2f}")
PY
}

measure() {
  local label="$1" method="$2" path="$3" body="$4"
  local out="$TMPDIR_BENCH/$(echo "$label" | md5).txt"
  : > "$out"
  for _ in $(seq 1 "$N"); do
    if [ "$method" = "GET" ]; then
      "${CURL[@]}" -b "$COOKIE" -o /dev/null -w "%{time_total}\n" "$BASE$path" >> "$out"
    else
      "${CURL[@]}" -b "$COOKIE" -o /dev/null -w "%{time_total}\n" -X "$method" \
        "$BASE$path" -H "Content-Type: application/json" -d "$body" >> "$out"
    fi
  done
  stats "$label" "$out"
}

# ---- 1. Log in to get a session (DevRunner recreates this account on every startup) -----------------
LOGIN_CODE=$("${CURL[@]}" -c "$COOKIE" -o /dev/null -w "%{http_code}" \
  -X POST "$BASE/login?username=$USER_EMAIL&password=$USER_PASS")
if ! grep -q JSESSIONID "$COOKIE"; then
  echo "Error: login returned HTTP $LOGIN_CODE, no JSESSIONID received."
  echo "       Confirm the account DevRunner creates is $USER_EMAIL / $USER_PASS, and check the app logs."
  exit 1
fi

echo
echo "======================================================================================="
echo " Unit: milliseconds (ms)    $N requests per endpoint"
echo "======================================================================================="
echo

# ---- 2. Cold start: the first call while the cache is empty --------------------------------------
COLD=$("${CURL[@]}" -b "$COOKIE" -o /dev/null -w "%{time_total}" "$BASE/restaurants/menu")
printf "%-36s %8.2f ms   <- cache miss, actually hit the database\n" \
  "GET /restaurants/menu [first/cold]" "$(echo "$COLD * 1000" | bc)"
echo

# ---- 3. Add 3 items to the cart so GET /cart has real data ------------------------
for id in 1 2 3; do
  "${CURL[@]}" -b "$COOKIE" -o /dev/null -X POST "$BASE/cart" \
    -H "Content-Type: application/json" -d "{\"menu_id\": $id}"
done

# ---- 4. Actual measurements -----------------------------------------------------------
measure "GET /restaurant/1/menu [no cache]" GET  "/restaurant/1/menu"
measure "GET /restaurants/menu  [cached]"   GET  "/restaurants/menu"
measure "GET /cart              [cached]"   GET  "/cart"
measure "POST /cart             [write path]" POST "/cart" '{"menu_id": 5}'

echo
echo "Notes:"
echo "  * [no cache] Every call actually hits Postgres — this is the most honest number"
echo "  * [cached] Hits the in-memory Caffeine cache (expireAfterWrite=60s), doesn't touch the database"
echo "  * [write path] Includes transaction commit + cache eviction, naturally slower than reads"
echo "  * avg gets pulled up by a few slow requests; p50 is the 'typical user experience', p95/p99 are tail latency"
echo

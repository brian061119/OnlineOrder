#!/bin/bash
# ---------------------------------------------------------------------------
# OnlineOrder 端点延迟压测
#
# 前置：Postgres 已启动 + 应用已在 localhost:8080 运行
# 用法：./bench.sh [每个端点的请求次数，默认 100]
#
# 测的是端到端 HTTP 延迟：TCP 建连 + Spring 全链路 + SQL + JSON 序列化。
# 这不等于"数据库查询时间"——想看纯 SQL 时间要用 EXPLAIN ANALYZE。
#
# 注意 --noproxy '*'：本机如果开着 Clash/Surge 之类的代理，
# http_proxy 环境变量会把 localhost 的请求也劫走，必须显式绕过。
# ---------------------------------------------------------------------------
set -e

N=${1:-100}
BASE="http://localhost:8080"
USER_EMAIL="foo@mail.com"
USER_PASS="123456"
CURL=(curl -s --noproxy '*')

# ---- 健康检查：必须拿到真实的 HTTP 状态码，不能只看 curl 有没有报错 ----------
CODE=$("${CURL[@]}" -o /dev/null -w "%{http_code}" --max-time 5 "$BASE/restaurants/menu" || echo "000")
if [ "$CODE" = "000" ]; then
  echo "错误：$BASE 连不上。先启动应用（./gradlew bootRun）再跑这个脚本。"
  exit 1
fi
if [ "$CODE" != "200" ]; then
  echo "错误：$BASE/restaurants/menu 返回 HTTP $CODE，期望 200。"
  echo "      502/504 通常是代理拦截；其他状态码检查应用日志。"
  exit 1
fi

TMPDIR_BENCH=$(mktemp -d)
COOKIE="$TMPDIR_BENCH/cookie.txt"
trap 'rm -rf "$TMPDIR_BENCH"' EXIT

# ---- 统计函数：读一列毫秒数，输出 avg / p50 / p95 / p99 / max ----------------
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

# ---- 1. 登录拿 session（DevRunner 每次启动都会重建这个账号）-----------------
LOGIN_CODE=$("${CURL[@]}" -c "$COOKIE" -o /dev/null -w "%{http_code}" \
  -X POST "$BASE/login?username=$USER_EMAIL&password=$USER_PASS")
if ! grep -q JSESSIONID "$COOKIE"; then
  echo "错误：登录返回 HTTP $LOGIN_CODE，没拿到 JSESSIONID。"
  echo "      确认 DevRunner 建的账号是 $USER_EMAIL / $USER_PASS，并检查应用日志。"
  exit 1
fi

echo
echo "======================================================================================="
echo " 单位：毫秒 (ms)    每个端点 $N 次请求"
echo "======================================================================================="
echo

# ---- 2. 冷启动：缓存为空时的第一次调用 --------------------------------------
COLD=$("${CURL[@]}" -b "$COOKIE" -o /dev/null -w "%{time_total}" "$BASE/restaurants/menu")
printf "%-36s %8.2f ms   <- 缓存未命中，真正查了数据库\n" \
  "GET /restaurants/menu [首次/冷]" "$(echo "$COLD * 1000" | bc)"
echo

# ---- 3. 往购物车放 3 个菜品，让 GET /cart 有真实数据 ------------------------
for id in 1 2 3; do
  "${CURL[@]}" -b "$COOKIE" -o /dev/null -X POST "$BASE/cart" \
    -H "Content-Type: application/json" -d "{\"menu_id\": $id}"
done

# ---- 4. 正式测量 -----------------------------------------------------------
measure "GET /restaurant/1/menu [无缓存]" GET  "/restaurant/1/menu"
measure "GET /restaurants/menu  [有缓存]" GET  "/restaurants/menu"
measure "GET /cart              [有缓存]" GET  "/cart"
measure "POST /cart             [写路径]" POST "/cart" '{"menu_id": 5}'

echo
echo "说明："
echo "  * [无缓存] 每次都真的走一趟 Postgres —— 这是最诚实的数字"
echo "  * [有缓存] 命中 Caffeine 内存缓存（expireAfterWrite=60s），不碰数据库"
echo "  * [写路径] 含事务提交 + 缓存逐出，天然比读慢"
echo "  * avg 会被少数慢请求拉高，p50 才是'典型用户的体感'，p95/p99 是尾部延迟"
echo

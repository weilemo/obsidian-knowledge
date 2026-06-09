#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DB_PATH="$PROJECT_DIR/db/lab_reservation.db"

if [[ ! -f "$DB_PATH" ]]; then
  echo "数据库不存在，请先执行: bash scripts/build_db.sh"
  exit 1
fi

run_case() {
  local name="$1"
  local sql="$2"
  local out_file err_file
  out_file="$(mktemp)"
  err_file="$(mktemp)"

  if sqlite3 "$DB_PATH" "$sql" >"$out_file" 2>"$err_file"; then
    echo "[失败] $name: 这条本应被拦截，但执行成功了"
    cat "$out_file"
  else
    echo "[通过] $name: 已被数据库拒绝"
    cat "$err_file"
  fi

  rm -f "$out_file" "$err_file"
}

echo "开始校验触发器规则..."
run_case "Case A 时间冲突" "INSERT INTO reservations (user_id, device_id, start_time, end_time, status, purpose) VALUES (2, 1, '2026-06-03 10:00:00', '2026-06-03 10:30:00', 'approved', '冲突测试');"
run_case "Case B 资质不足" "INSERT INTO reservations (user_id, device_id, start_time, end_time, status, purpose) VALUES (3, 1, '2026-06-05 09:00:00', '2026-06-05 11:00:00', 'approved', '资质测试');"
run_case "Case C 维护/设备不可用冲突" "INSERT INTO reservations (user_id, device_id, start_time, end_time, status, purpose) VALUES (2, 2, '2026-06-04 14:00:00', '2026-06-04 15:00:00', 'approved', '维护冲突测试');"

echo "校验完成。"

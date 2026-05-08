#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DB_PATH="$PROJECT_DIR/db/lab_reservation.db"

if [[ ! -f "$DB_PATH" ]]; then
  echo "数据库不存在，请先执行: bash scripts/build_db.sh"
  exit 1
fi

sqlite3 "$DB_PATH" < "$PROJECT_DIR/sql/05_demo_queries.sql"

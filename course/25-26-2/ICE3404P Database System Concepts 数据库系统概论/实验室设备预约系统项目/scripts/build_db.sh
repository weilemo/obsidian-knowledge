#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DB_PATH="$PROJECT_DIR/db/lab_reservation.db"

mkdir -p "$PROJECT_DIR/db"

echo "[1/5] 重置数据库..."
rm -f "$DB_PATH"

# 先创建空库再执行 drop，确保脚本可重复运行
sqlite3 "$DB_PATH" 'SELECT 1;' >/dev/null
sqlite3 "$DB_PATH" < "$PROJECT_DIR/sql/99_drop_all.sql"

echo "[2/5] 创建表与索引..."
sqlite3 "$DB_PATH" < "$PROJECT_DIR/sql/01_schema.sql"

echo "[3/5] 创建视图..."
sqlite3 "$DB_PATH" < "$PROJECT_DIR/sql/02_views.sql"

echo "[4/5] 创建触发器..."
sqlite3 "$DB_PATH" < "$PROJECT_DIR/sql/03_triggers.sql"

echo "[5/5] 导入样例数据..."
sqlite3 "$DB_PATH" < "$PROJECT_DIR/sql/04_seed_data.sql"

echo "完成：$DB_PATH"

#!/usr/bin/env python3
"""SQLite UDF 演示：注册一个时间区间冲突函数并在 SQL 中使用。"""

import sqlite3
from pathlib import Path


def overlap(start1: str, end1: str, start2: str, end2: str) -> int:
    # 时间字符串是 YYYY-MM-DD HH:MM:SS，按字典序可比较
    if end1 <= start2 or start1 >= end2:
        return 0
    return 1


def main() -> None:
    project_dir = Path(__file__).resolve().parent.parent
    db_path = project_dir / "db" / "lab_reservation.db"
    if not db_path.exists():
        raise SystemExit("数据库不存在，请先运行: bash scripts/build_db.sh")

    conn = sqlite3.connect(db_path)
    conn.create_function("fn_overlap", 4, overlap)

    sql = """
    SELECT reservation_id, user_id, device_id, start_time, end_time
    FROM reservations
    WHERE device_id = 1
      AND fn_overlap(start_time, end_time, '2026-04-01 10:00:00', '2026-04-01 10:30:00') = 1
    ORDER BY reservation_id;
    """

    rows = conn.execute(sql).fetchall()
    print("命中冲突的预约记录:")
    for row in rows:
        print(row)

    conn.close()


if __name__ == "__main__":
    main()

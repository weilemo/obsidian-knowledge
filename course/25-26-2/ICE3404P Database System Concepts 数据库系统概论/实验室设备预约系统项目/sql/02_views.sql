-- ============================================================
-- 术语对照（View 层）
-- [视图 VIEW]
--   vw_device_available_now: 当前可用设备
--   vw_user_reservation_summary: 用户预约统计
--   vw_upcoming_reservations: 未来预约明细
-- ============================================================

-- [视图] 当前时刻可用设备视图：设备在线且无维护冲突且无占用预约
CREATE VIEW vw_device_available_now AS
SELECT
    d.device_id,
    d.device_name,
    d.device_type,
    l.lab_name,
    l.location
FROM devices d
JOIN labs l ON d.lab_id = l.lab_id
WHERE d.status = 'available'
  AND NOT EXISTS (
      SELECT 1
      FROM maintenance_orders m
      WHERE m.device_id = d.device_id
        AND m.status IN ('open', 'in_progress')
        AND datetime('now') < m.end_time
  )
  AND NOT EXISTS (
      SELECT 1
      FROM reservations r
      WHERE r.device_id = d.device_id
        AND r.status IN ('pending', 'approved')
        AND datetime('now') >= r.start_time
        AND datetime('now') < r.end_time
  );

-- [视图] 用户预约统计视图
CREATE VIEW vw_user_reservation_summary AS
SELECT
    u.user_id,
    u.name,
    u.role,
    COUNT(r.reservation_id) AS total_reservations,
    SUM(CASE WHEN r.status IN ('pending', 'approved') THEN 1 ELSE 0 END) AS active_reservations,
    SUM(CASE WHEN r.status = 'completed' THEN 1 ELSE 0 END) AS completed_reservations,
    SUM(CASE WHEN r.status = 'no_show' THEN 1 ELSE 0 END) AS no_show_reservations
FROM users u
LEFT JOIN reservations r ON u.user_id = r.user_id
GROUP BY u.user_id, u.name, u.role;

-- [视图] 未来预约详情视图
CREATE VIEW vw_upcoming_reservations AS
SELECT
    r.reservation_id,
    u.name AS user_name,
    d.device_name,
    l.lab_name,
    r.start_time,
    r.end_time,
    r.status,
    r.purpose
FROM reservations r
JOIN users u ON r.user_id = u.user_id
JOIN devices d ON r.device_id = d.device_id
JOIN labs l ON d.lab_id = l.lab_id
WHERE r.end_time > datetime('now')
ORDER BY r.start_time;

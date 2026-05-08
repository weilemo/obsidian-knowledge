.headers on
.mode column

SELECT '1) 当前可用设备' AS section;
SELECT * FROM vw_device_available_now;

SELECT '2) 用户预约统计' AS section;
SELECT * FROM vw_user_reservation_summary ORDER BY user_id;

SELECT '3) 未来预约详情' AS section;
SELECT * FROM vw_upcoming_reservations;

SELECT '4) 违约记录（由 no_show 触发器自动生成）' AS section;
SELECT violation_id, user_id, reservation_id, violation_type, penalty_points, created_at
FROM violation_records
ORDER BY violation_id;

SELECT '5) 设备状态（可看到维护工单把设备 2 自动切为 maintenance）' AS section;
SELECT device_id, device_name, status FROM devices ORDER BY device_id;

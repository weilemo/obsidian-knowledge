-- 这个文件用于课堂演示“错误数据会被数据库拒绝”。
-- 建议在 sqlite3 里逐条执行并观察报错信息。

-- Case A: 设备时间冲突（应失败）
INSERT INTO reservations (user_id, device_id, start_time, end_time, status, purpose)
VALUES (2, 1, '2026-04-01 10:00:00', '2026-04-01 10:30:00', 'approved', '冲突测试');

-- Case B: 无资质预约需要资质的设备（应失败，用户 3 对设备 2 没资质）
INSERT INTO reservations (user_id, device_id, start_time, end_time, status, purpose)
VALUES (3, 2, '2026-04-03 09:00:00', '2026-04-03 11:00:00', 'approved', '资质测试');

-- Case C: 维护时间冲突（应失败）
INSERT INTO reservations (user_id, device_id, start_time, end_time, status, purpose)
VALUES (2, 2, '2026-04-02 14:00:00', '2026-04-02 15:00:00', 'approved', '维护冲突测试');

-- Case D: 单用户超过 2 条有效预约（第三条应失败）
INSERT INTO reservations (user_id, device_id, start_time, end_time, status, purpose)
VALUES (2, 3, '2026-04-05 09:00:00', '2026-04-05 10:00:00', 'approved', '上限测试1');

INSERT INTO reservations (user_id, device_id, start_time, end_time, status, purpose)
VALUES (2, 3, '2026-04-06 09:00:00', '2026-04-06 10:00:00', 'approved', '上限测试2');

INSERT INTO reservations (user_id, device_id, start_time, end_time, status, purpose)
VALUES (2, 3, '2026-04-07 09:00:00', '2026-04-07 10:00:00', 'approved', '上限测试3');

PRAGMA foreign_keys = ON;

-- 用户
INSERT INTO users (user_id, name, role, email, phone) VALUES
(1, '王老师', 'admin',   'admin_lab@example.com', '13800000001'),
(2, '李同学', 'student', 'li_student@example.com', '13800000002'),
(3, '赵同学', 'student', 'zhao_student@example.com', '13800000003'),
(4, '陈老师', 'teacher', 'chen_teacher@example.com', '13800000004');

-- 实验室
INSERT INTO labs (lab_id, lab_name, location) VALUES
(1, '计算机系统实验室', 'A楼 301'),
(2, '智能硬件实验室', 'B楼 205');

-- 设备
INSERT INTO devices (device_id, lab_id, device_name, device_type, status, requires_cert) VALUES
(1, 1, 'GPU 服务器 A100', 'server', 'available', 1),
(2, 2, '高精度示波器', 'instrument', 'available', 1),
(3, 2, '3D 打印机', 'printer', 'available', 0),
(4, 1, '激光切割机', 'cutter', 'offline', 1);

-- 资质（用户-设备）
INSERT INTO user_device_certifications (cert_id, user_id, device_id, cert_level, certified_at, expires_at) VALUES
(1, 2, 1, 'A', '2026-01-01 00:00:00', '2026-12-31 23:59:59'),
(2, 2, 2, 'B', '2026-01-01 00:00:00', '2026-12-31 23:59:59'),
(3, 4, 2, 'A', '2026-01-01 00:00:00', '2026-12-31 23:59:59');

-- 预约
INSERT INTO reservations (reservation_id, user_id, device_id, start_time, end_time, status, purpose) VALUES
(1, 2, 1, '2026-04-01 09:00:00', '2026-04-01 11:00:00', 'approved', '深度学习训练实验'),
(2, 3, 3, '2026-04-01 13:00:00', '2026-04-01 15:00:00', 'pending',  '课程作业原型打印'),
(3, 2, 1, '2026-03-10 09:00:00', '2026-03-10 10:00:00', 'completed', '历史实验记录'),
(4, 3, 3, '2026-03-11 10:00:00', '2026-03-11 12:00:00', 'approved',  '历史实验记录');

-- 签到签退
INSERT INTO checkin_logs (checkin_id, reservation_id, checkin_time, checkout_time, result) VALUES
(1, 3, '2026-03-10 08:58:00', '2026-03-10 10:01:00', 'on_time');

-- 维护工单：会自动把设备 2 状态改成 maintenance
INSERT INTO maintenance_orders (order_id, device_id, created_by, start_time, end_time, status, note) VALUES
(1, 2, 1, '2026-04-02 13:00:00', '2026-04-02 17:00:00', 'open', '例行校准');

-- 演示 no_show 违约触发
UPDATE reservations
SET status = 'no_show'
WHERE reservation_id = 4;

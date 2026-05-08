PRAGMA foreign_keys = ON;

-- ============================================================
-- 术语对照（Schema 层）
-- [主键 PRIMARY KEY]
--   users.user_id, labs.lab_id, devices.device_id,
--   user_device_certifications.cert_id, reservations.reservation_id,
--   checkin_logs.checkin_id, maintenance_orders.order_id, violation_records.violation_id
-- [外键 FOREIGN KEY]
--   devices.lab_id -> labs.lab_id
--   user_device_certifications.user_id -> users.user_id
--   user_device_certifications.device_id -> devices.device_id
--   reservations.user_id -> users.user_id
--   reservations.device_id -> devices.device_id
--   checkin_logs.reservation_id -> reservations.reservation_id
--   maintenance_orders.device_id -> devices.device_id
--   maintenance_orders.created_by -> users.user_id
--   violation_records.user_id -> users.user_id
--   violation_records.reservation_id -> reservations.reservation_id
-- [检查约束 CHECK]
--   users.role, devices.status, devices.requires_cert,
--   reservations.status, checkin_logs.result, maintenance_orders.status
-- ============================================================

-- 用户表
CREATE TABLE users (
    user_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    name         TEXT NOT NULL,
    role         TEXT NOT NULL CHECK (role IN ('student', 'teacher', 'admin')),
    email        TEXT NOT NULL UNIQUE,
    phone        TEXT,
    created_at   TEXT NOT NULL DEFAULT (datetime('now'))
);

-- 实验室表
CREATE TABLE labs (
    lab_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    lab_name     TEXT NOT NULL UNIQUE,
    location     TEXT NOT NULL
);

-- 设备表
CREATE TABLE devices (
    device_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    lab_id         INTEGER NOT NULL,
    device_name    TEXT NOT NULL,
    device_type    TEXT NOT NULL,
    status         TEXT NOT NULL CHECK (status IN ('available', 'occupied', 'maintenance', 'offline')),
    requires_cert  INTEGER NOT NULL DEFAULT 0 CHECK (requires_cert IN (0, 1)),
    created_at     TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (lab_id) REFERENCES labs(lab_id)
);

-- 用户设备资质表（用户-设备 N:M 桥接）
CREATE TABLE user_device_certifications (
    cert_id        INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id        INTEGER NOT NULL,
    device_id      INTEGER NOT NULL,
    cert_level     TEXT NOT NULL,
    certified_at   TEXT NOT NULL,
    expires_at     TEXT,
    UNIQUE (user_id, device_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (device_id) REFERENCES devices(device_id)
);

-- 预约表
CREATE TABLE reservations (
    reservation_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id        INTEGER NOT NULL,
    device_id      INTEGER NOT NULL,
    start_time     TEXT NOT NULL,
    end_time       TEXT NOT NULL,
    status         TEXT NOT NULL DEFAULT 'pending'
                   CHECK (status IN ('pending', 'approved', 'cancelled', 'completed', 'no_show')),
    purpose        TEXT,
    created_at     TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (device_id) REFERENCES devices(device_id)
);

-- 签到签退日志
CREATE TABLE checkin_logs (
    checkin_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    reservation_id   INTEGER NOT NULL UNIQUE,
    checkin_time     TEXT NOT NULL,
    checkout_time    TEXT,
    result           TEXT NOT NULL CHECK (result IN ('on_time', 'late', 'no_show')),
    FOREIGN KEY (reservation_id) REFERENCES reservations(reservation_id)
);

-- 维护工单
CREATE TABLE maintenance_orders (
    order_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    device_id      INTEGER NOT NULL,
    created_by     INTEGER NOT NULL,
    start_time     TEXT NOT NULL,
    end_time       TEXT NOT NULL,
    status         TEXT NOT NULL CHECK (status IN ('open', 'in_progress', 'closed')),
    note           TEXT,
    created_at     TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (device_id) REFERENCES devices(device_id),
    FOREIGN KEY (created_by) REFERENCES users(user_id)
);

-- 违约记录
CREATE TABLE violation_records (
    violation_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id          INTEGER NOT NULL,
    reservation_id   INTEGER NOT NULL,
    violation_type   TEXT NOT NULL,
    penalty_points   INTEGER NOT NULL DEFAULT 1,
    created_at       TEXT NOT NULL DEFAULT (datetime('now')),
    UNIQUE (reservation_id, violation_type),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (reservation_id) REFERENCES reservations(reservation_id)
);

-- 索引：按查询与校验路径设计
CREATE INDEX idx_devices_lab_status ON devices(lab_id, status);
CREATE INDEX idx_reservations_device_time_status ON reservations(device_id, start_time, end_time, status);
CREATE INDEX idx_reservations_user_status_start ON reservations(user_id, status, start_time);
CREATE INDEX idx_maintenance_device_time_status ON maintenance_orders(device_id, start_time, end_time, status);
CREATE INDEX idx_cert_user_device ON user_device_certifications(user_id, device_id);

PRAGMA foreign_keys = ON;

-- ============================================================
-- 术语对照（Trigger 层）
-- [触发器 TRIGGER]
--   trg_reservation_time_valid_*: 预约时间合法性
--   trg_reservation_device_status_*: 设备状态可预约性
--   trg_reservation_cert_check_*: 用户设备资质校验
--   trg_reservation_user_limit_*: 用户同时有效预约上限
--   trg_reservation_overlap_*: 同设备时间冲突校验
--   trg_reservation_maintenance_overlap_*: 预约与维护冲突校验
--   trg_maintenance_time_valid_*: 维护时间合法性
--   trg_maintenance_reservation_overlap_*: 维护与预约冲突校验
--   trg_maintenance_device_status_after_*: 工单驱动设备状态同步
--   trg_checkin_complete_reservation: 签退后完成预约
--   trg_reservation_no_show_violation: no_show 自动记违约
-- ============================================================

-- ========== reservations: 基础合法性 ==========
CREATE TRIGGER trg_reservation_time_valid_ins
BEFORE INSERT ON reservations
BEGIN
    SELECT CASE
        WHEN NEW.start_time >= NEW.end_time
        THEN RAISE(ABORT, '预约失败：start_time 必须早于 end_time')
    END;
END;

CREATE TRIGGER trg_reservation_time_valid_upd
BEFORE UPDATE OF start_time, end_time ON reservations
BEGIN
    SELECT CASE
        WHEN NEW.start_time >= NEW.end_time
        THEN RAISE(ABORT, '更新失败：start_time 必须早于 end_time')
    END;
END;

-- ========== reservations: 设备状态校验 ==========
CREATE TRIGGER trg_reservation_device_status_ins
BEFORE INSERT ON reservations
WHEN NEW.status IN ('pending', 'approved')
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1 FROM devices d
            WHERE d.device_id = NEW.device_id
              AND d.status IN ('maintenance', 'offline')
        )
        THEN RAISE(ABORT, '预约失败：设备当前不可预约（维护或离线）')
    END;
END;

CREATE TRIGGER trg_reservation_device_status_upd
BEFORE UPDATE OF device_id, status ON reservations
WHEN NEW.status IN ('pending', 'approved')
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1 FROM devices d
            WHERE d.device_id = NEW.device_id
              AND d.status IN ('maintenance', 'offline')
        )
        THEN RAISE(ABORT, '更新失败：设备当前不可预约（维护或离线）')
    END;
END;

-- ========== reservations: 用户资质校验 ==========
CREATE TRIGGER trg_reservation_cert_check_ins
BEFORE INSERT ON reservations
WHEN NEW.status IN ('pending', 'approved')
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1 FROM devices d
            WHERE d.device_id = NEW.device_id AND d.requires_cert = 1
        )
        AND NOT EXISTS (
            SELECT 1
            FROM user_device_certifications c
            WHERE c.user_id = NEW.user_id
              AND c.device_id = NEW.device_id
              AND c.certified_at <= NEW.start_time
              AND (c.expires_at IS NULL OR c.expires_at >= NEW.end_time)
        )
        THEN RAISE(ABORT, '预约失败：该设备需要资质，用户资质不足或已过期')
    END;
END;

CREATE TRIGGER trg_reservation_cert_check_upd
BEFORE UPDATE OF user_id, device_id, start_time, end_time, status ON reservations
WHEN NEW.status IN ('pending', 'approved')
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1 FROM devices d
            WHERE d.device_id = NEW.device_id AND d.requires_cert = 1
        )
        AND NOT EXISTS (
            SELECT 1
            FROM user_device_certifications c
            WHERE c.user_id = NEW.user_id
              AND c.device_id = NEW.device_id
              AND c.certified_at <= NEW.start_time
              AND (c.expires_at IS NULL OR c.expires_at >= NEW.end_time)
        )
        THEN RAISE(ABORT, '更新失败：该设备需要资质，用户资质不足或已过期')
    END;
END;

-- ========== reservations: 用户并发预约上限（最多 2 条有效预约） ==========
CREATE TRIGGER trg_reservation_user_limit_ins
BEFORE INSERT ON reservations
WHEN NEW.status IN ('pending', 'approved')
BEGIN
    SELECT CASE
        WHEN (
            SELECT COUNT(1)
            FROM reservations r
            WHERE r.user_id = NEW.user_id
              AND r.status IN ('pending', 'approved')
              AND r.end_time > datetime('now')
        ) >= 2
        THEN RAISE(ABORT, '预约失败：用户同时有效预约数已达上限（2）')
    END;
END;

CREATE TRIGGER trg_reservation_user_limit_upd
BEFORE UPDATE OF user_id, status ON reservations
WHEN NEW.status IN ('pending', 'approved')
BEGIN
    SELECT CASE
        WHEN (
            SELECT COUNT(1)
            FROM reservations r
            WHERE r.user_id = NEW.user_id
              AND r.status IN ('pending', 'approved')
              AND r.end_time > datetime('now')
              AND r.reservation_id <> OLD.reservation_id
        ) >= 2
        THEN RAISE(ABORT, '更新失败：用户同时有效预约数已达上限（2）')
    END;
END;

-- ========== reservations: 同设备时间冲突校验 ==========
CREATE TRIGGER trg_reservation_overlap_ins
BEFORE INSERT ON reservations
WHEN NEW.status IN ('pending', 'approved')
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1
            FROM reservations r
            WHERE r.device_id = NEW.device_id
              AND r.status IN ('pending', 'approved')
              AND NOT (NEW.end_time <= r.start_time OR NEW.start_time >= r.end_time)
        )
        THEN RAISE(ABORT, '预约失败：该时间段设备已被预约')
    END;
END;

CREATE TRIGGER trg_reservation_overlap_upd
BEFORE UPDATE OF device_id, start_time, end_time, status ON reservations
WHEN NEW.status IN ('pending', 'approved')
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1
            FROM reservations r
            WHERE r.device_id = NEW.device_id
              AND r.status IN ('pending', 'approved')
              AND r.reservation_id <> OLD.reservation_id
              AND NOT (NEW.end_time <= r.start_time OR NEW.start_time >= r.end_time)
        )
        THEN RAISE(ABORT, '更新失败：该时间段设备已被预约')
    END;
END;

-- ========== reservations: 与维护时间冲突校验 ==========
CREATE TRIGGER trg_reservation_maintenance_overlap_ins
BEFORE INSERT ON reservations
WHEN NEW.status IN ('pending', 'approved')
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1
            FROM maintenance_orders m
            WHERE m.device_id = NEW.device_id
              AND m.status IN ('open', 'in_progress')
              AND NOT (NEW.end_time <= m.start_time OR NEW.start_time >= m.end_time)
        )
        THEN RAISE(ABORT, '预约失败：该时间段设备有维护工单')
    END;
END;

CREATE TRIGGER trg_reservation_maintenance_overlap_upd
BEFORE UPDATE OF device_id, start_time, end_time, status ON reservations
WHEN NEW.status IN ('pending', 'approved')
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1
            FROM maintenance_orders m
            WHERE m.device_id = NEW.device_id
              AND m.status IN ('open', 'in_progress')
              AND NOT (NEW.end_time <= m.start_time OR NEW.start_time >= m.end_time)
        )
        THEN RAISE(ABORT, '更新失败：该时间段设备有维护工单')
    END;
END;

-- ========== maintenance_orders: 基础合法性 ==========
CREATE TRIGGER trg_maintenance_time_valid_ins
BEFORE INSERT ON maintenance_orders
BEGIN
    SELECT CASE
        WHEN NEW.start_time >= NEW.end_time
        THEN RAISE(ABORT, '工单失败：维护开始时间必须早于结束时间')
    END;
END;

CREATE TRIGGER trg_maintenance_time_valid_upd
BEFORE UPDATE OF start_time, end_time ON maintenance_orders
BEGIN
    SELECT CASE
        WHEN NEW.start_time >= NEW.end_time
        THEN RAISE(ABORT, '工单更新失败：维护开始时间必须早于结束时间')
    END;
END;

-- ========== maintenance_orders: 与有效预约冲突校验 ==========
CREATE TRIGGER trg_maintenance_reservation_overlap_ins
BEFORE INSERT ON maintenance_orders
WHEN NEW.status IN ('open', 'in_progress')
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1
            FROM reservations r
            WHERE r.device_id = NEW.device_id
              AND r.status IN ('pending', 'approved')
              AND NOT (NEW.end_time <= r.start_time OR NEW.start_time >= r.end_time)
        )
        THEN RAISE(ABORT, '工单失败：维护时间与有效预约冲突')
    END;
END;

CREATE TRIGGER trg_maintenance_reservation_overlap_upd
BEFORE UPDATE OF device_id, start_time, end_time, status ON maintenance_orders
WHEN NEW.status IN ('open', 'in_progress')
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1
            FROM reservations r
            WHERE r.device_id = NEW.device_id
              AND r.status IN ('pending', 'approved')
              AND NOT (NEW.end_time <= r.start_time OR NEW.start_time >= r.end_time)
        )
        THEN RAISE(ABORT, '工单更新失败：维护时间与有效预约冲突')
    END;
END;

-- ========== maintenance_orders: 同步设备状态 ==========
CREATE TRIGGER trg_maintenance_device_status_after_ins
AFTER INSERT ON maintenance_orders
WHEN NEW.status IN ('open', 'in_progress')
BEGIN
    UPDATE devices
    SET status = 'maintenance'
    WHERE device_id = NEW.device_id;
END;

CREATE TRIGGER trg_maintenance_device_status_after_upd
AFTER UPDATE OF status ON maintenance_orders
BEGIN
    -- 工单进入执行中/打开状态，设备标记为维护
    UPDATE devices
    SET status = 'maintenance'
    WHERE device_id = NEW.device_id
      AND NEW.status IN ('open', 'in_progress');

    -- 工单关闭时，如果没有其他打开工单，设备恢复可用
    UPDATE devices
    SET status = 'available'
    WHERE device_id = NEW.device_id
      AND NEW.status = 'closed'
      AND NOT EXISTS (
          SELECT 1 FROM maintenance_orders m
          WHERE m.device_id = NEW.device_id
            AND m.status IN ('open', 'in_progress')
      );
END;

-- ========== checkin_logs: 签退后自动完成预约 ==========
CREATE TRIGGER trg_checkin_complete_reservation
AFTER UPDATE OF checkout_time ON checkin_logs
WHEN NEW.checkout_time IS NOT NULL
BEGIN
    UPDATE reservations
    SET status = 'completed'
    WHERE reservation_id = NEW.reservation_id
      AND status IN ('pending', 'approved');
END;

-- ========== reservations: no_show 自动记违约 ==========
CREATE TRIGGER trg_reservation_no_show_violation
AFTER UPDATE OF status ON reservations
WHEN NEW.status = 'no_show'
BEGIN
    INSERT OR IGNORE INTO violation_records (user_id, reservation_id, violation_type, penalty_points)
    VALUES (NEW.user_id, NEW.reservation_id, 'no_show', 2);
END;

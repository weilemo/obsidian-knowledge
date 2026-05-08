PRAGMA foreign_keys = OFF;

DROP VIEW IF EXISTS vw_upcoming_reservations;
DROP VIEW IF EXISTS vw_user_reservation_summary;
DROP VIEW IF EXISTS vw_device_available_now;

DROP TABLE IF EXISTS violation_records;
DROP TABLE IF EXISTS checkin_logs;
DROP TABLE IF EXISTS maintenance_orders;
DROP TABLE IF EXISTS reservations;
DROP TABLE IF EXISTS user_device_certifications;
DROP TABLE IF EXISTS devices;
DROP TABLE IF EXISTS labs;
DROP TABLE IF EXISTS users;

PRAGMA foreign_keys = ON;

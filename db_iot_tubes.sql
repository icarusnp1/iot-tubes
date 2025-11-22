-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               8.0.30 - MySQL Community Server - GPL
-- Server OS:                    Win64
-- HeidiSQL Version:             12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for heart_monitoring
CREATE DATABASE IF NOT EXISTS `heart_monitoring` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `heart_monitoring`;

-- Dumping structure for table heart_monitoring.sensor_readings
CREATE TABLE IF NOT EXISTS `sensor_readings` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `recorded_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ir_value` bigint DEFAULT NULL,
  `red_value` bigint DEFAULT NULL,
  `temp_c` decimal(5,2) DEFAULT NULL,
  `humidity` decimal(5,2) DEFAULT NULL,
  `accel_x` decimal(8,4) DEFAULT NULL,
  `accel_y` decimal(8,4) DEFAULT NULL,
  `accel_z` decimal(8,4) DEFAULT NULL,
  `bpm` decimal(6,2) DEFAULT NULL,
  `spo2` decimal(5,2) DEFAULT NULL,
  `steps` int unsigned DEFAULT NULL,
  `speed_mps` decimal(6,3) DEFAULT NULL,
  `activity` enum('idle','walking','jogging','running') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('normal','warning','danger') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_time` (`user_id`,`recorded_at`),
  CONSTRAINT `fk_sensor_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table heart_monitoring.sensor_readings: ~0 rows (approximately)
REPLACE INTO `sensor_readings` (`id`, `user_id`, `recorded_at`, `ir_value`, `red_value`, `temp_c`, `humidity`, `accel_x`, `accel_y`, `accel_z`, `bpm`, `spo2`, `steps`, `speed_mps`, `activity`, `status`, `created_at`) VALUES
	(1, 2, '2025-11-21 19:06:52', 123456, 120000, 30.50, 60.10, 0.0100, 0.0200, 0.9800, NULL, NULL, 0, 0.000, 'walking', 'warning', '2025-11-21 19:06:52'),
	(2, 2, '2025-11-21 19:10:12', 1759, 1548, 29.80, 73.00, -0.0009, 0.0004, 1.0000, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:12'),
	(3, 2, '2025-11-21 19:10:13', 1688, 1638, 29.80, 73.00, -0.0007, -0.0002, 1.0005, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:13'),
	(4, 2, '2025-11-21 19:10:14', 1724, 1616, 29.80, 73.00, -0.0005, -0.0002, 0.9996, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:14'),
	(5, 2, '2025-11-21 19:10:15', 1726, 1583, 29.80, 73.00, 0.0005, 0.0001, 0.9994, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:15'),
	(6, 2, '2025-11-21 19:10:16', 1711, 1566, 29.80, 73.00, -0.0001, -0.0004, 1.0001, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:16'),
	(7, 2, '2025-11-21 19:10:17', 1754, 1557, 29.80, 73.00, 0.0003, 0.0000, 1.0001, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:17'),
	(8, 2, '2025-11-21 19:10:18', 1752, 1551, 29.90, 73.00, 0.0004, 0.0003, 1.0006, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:18'),
	(9, 2, '2025-11-21 19:10:20', 1671, 1620, 29.90, 73.00, 0.0003, -0.0006, 1.0005, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:20'),
	(10, 2, '2025-11-21 19:10:21', 1691, 1611, 30.00, 72.00, 0.0000, 0.0000, 1.0001, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:21'),
	(11, 2, '2025-11-21 19:10:22', 1744, 1578, 30.00, 72.00, -0.0006, 0.0001, 0.9996, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:22'),
	(12, 2, '2025-11-21 19:10:23', 1681, 1578, 30.10, 72.00, 0.0002, 0.0001, 1.0001, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:23'),
	(13, 2, '2025-11-21 19:10:24', 1775, 1553, 30.10, 72.00, 0.0004, -0.0005, 0.9998, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:24'),
	(14, 2, '2025-11-21 19:10:25', 1784, 1565, 30.20, 72.00, -0.0010, 0.0005, 0.9992, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:25'),
	(15, 2, '2025-11-21 19:10:26', 1699, 1627, 30.20, 72.00, -0.0003, 0.0001, 1.0006, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:26'),
	(16, 2, '2025-11-21 19:10:28', 1681, 1610, 30.20, 73.00, 0.0008, -0.0005, 1.0014, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:28'),
	(17, 2, '2025-11-21 19:10:29', 1737, 1558, 30.20, 73.00, 0.0002, -0.0004, 1.0002, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:29'),
	(18, 2, '2025-11-21 19:10:30', 1751, 1568, 30.20, 73.00, 0.0002, 0.0004, 1.0004, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:30'),
	(19, 2, '2025-11-21 19:10:31', 1739, 1545, 30.20, 73.00, -0.0007, 0.0000, 0.9996, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:31'),
	(20, 2, '2025-11-21 19:10:32', 1798, 1563, 30.20, 73.00, 0.0003, -0.0001, 1.0006, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:32'),
	(21, 2, '2025-11-21 19:10:33', 1717, 1626, 30.20, 73.00, 0.0005, -0.0002, 1.0003, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:33'),
	(22, 2, '2025-11-21 19:10:34', 1697, 1600, 30.20, 73.00, 0.0004, 0.0002, 0.9996, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:34'),
	(23, 2, '2025-11-21 19:10:36', 1707, 1577, 30.20, 73.00, -0.0004, 0.0002, 1.0004, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:36'),
	(24, 2, '2025-11-21 19:10:37', 1696, 1607, 30.20, 73.00, -0.0003, -0.0002, 0.9999, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:37'),
	(25, 2, '2025-11-21 19:10:38', 1733, 1553, 30.20, 73.00, 0.0000, 0.0000, 0.9996, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:38'),
	(26, 2, '2025-11-21 19:10:39', 1722, 1526, 30.20, 73.00, 0.0007, -0.0006, 0.9993, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:39'),
	(27, 2, '2025-11-21 19:10:40', 1708, 1571, 30.20, 73.00, 0.0001, -0.0002, 1.0002, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:40'),
	(28, 2, '2025-11-21 19:10:41', 1759, 1565, 30.20, 72.00, 0.0005, -0.0009, 1.0001, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:41'),
	(29, 2, '2025-11-21 19:10:42', 1670, 1641, 30.20, 72.00, 0.0002, 0.0004, 0.9996, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:42'),
	(30, 2, '2025-11-21 19:10:43', 1696, 1602, 30.20, 72.00, 0.0001, 0.0001, 1.0000, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:43'),
	(31, 2, '2025-11-21 19:10:45', 1746, 1560, 30.20, 72.00, 0.0000, 0.0001, 1.0011, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:45'),
	(32, 2, '2025-11-21 19:10:46', 1728, 1582, 30.20, 72.00, -0.0004, -0.0007, 0.9993, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:46'),
	(33, 2, '2025-11-21 19:10:47', 1752, 1556, 30.20, 72.00, 0.0004, -0.0002, 1.0004, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:47'),
	(34, 2, '2025-11-21 19:10:48', 1743, 1548, 30.20, 72.00, 0.0007, 0.0000, 0.9995, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:48'),
	(35, 2, '2025-11-21 19:10:49', 1703, 1611, 30.20, 72.00, -0.0001, -0.0005, 1.0007, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:49'),
	(36, 2, '2025-11-21 19:10:50', 1703, 1610, 30.20, 72.00, 0.0007, -0.0003, 0.9993, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:50'),
	(37, 2, '2025-11-21 19:10:51', 1721, 1580, 30.20, 72.00, -0.0006, 0.0000, 0.9989, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:51'),
	(38, 2, '2025-11-21 19:10:53', 1683, 1584, 30.20, 72.00, 0.0001, -0.0002, 1.0007, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:53'),
	(39, 2, '2025-11-21 19:10:54', 1769, 1550, 30.20, 72.00, 0.0007, 0.0001, 1.0001, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:54'),
	(40, 2, '2025-11-21 19:10:55', 1763, 1554, 30.20, 72.00, -0.0003, -0.0001, 1.0000, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:55'),
	(41, 2, '2025-11-21 19:10:56', 1664, 1632, 30.20, 72.00, -0.0001, 0.0001, 0.9990, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:56'),
	(42, 2, '2025-11-21 19:10:57', 1700, 1601, 30.20, 72.00, 0.0012, -0.0002, 0.9991, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:57'),
	(43, 2, '2025-11-21 19:10:58', 1681, 1606, 30.20, 72.00, 0.0007, 0.0003, 1.0001, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:58'),
	(44, 2, '2025-11-21 19:10:59', 1689, 1622, 30.20, 73.00, -0.0008, -0.0004, 0.9993, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:10:59'),
	(45, 2, '2025-11-21 19:11:00', 1773, 1519, 30.20, 73.00, 0.0006, 0.0004, 0.9993, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:00'),
	(46, 2, '2025-11-21 19:11:02', 1782, 1580, 30.20, 73.00, 0.0002, -0.0002, 1.0004, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:02'),
	(47, 2, '2025-11-21 19:11:03', 1749, 1577, 30.20, 73.00, -0.0001, 0.0006, 0.9992, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:03'),
	(48, 2, '2025-11-21 19:11:04', 1751, 1551, 30.20, 73.00, 0.0005, 0.0001, 1.0009, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:04'),
	(49, 2, '2025-11-21 19:11:05', 1691, 1611, 30.20, 73.00, -0.0004, -0.0002, 1.0007, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:05'),
	(50, 2, '2025-11-21 19:11:06', 1679, 1615, 30.20, 73.00, -0.0006, 0.0001, 0.9995, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:06'),
	(51, 2, '2025-11-21 19:11:07', 1777, 1566, 30.20, 73.00, 0.0000, 0.0009, 0.9991, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:07'),
	(52, 2, '2025-11-21 19:11:08', 1735, 1543, 30.20, 73.00, -0.0004, -0.0003, 0.9996, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:08'),
	(53, 2, '2025-11-21 19:11:10', 1719, 1608, 30.20, 73.00, 0.0009, 0.0009, 1.0000, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:10'),
	(54, 2, '2025-11-21 19:11:11', 1724, 1626, 30.20, 72.00, -0.0011, -0.0002, 1.0000, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:11'),
	(55, 2, '2025-11-21 19:11:12', 1731, 1560, 30.20, 72.00, -0.0003, 0.0002, 0.9997, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:12'),
	(56, 2, '2025-11-21 19:11:13', 1717, 1572, 30.20, 72.00, -0.0003, 0.0002, 0.9989, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:13'),
	(57, 2, '2025-11-21 19:11:14', 1746, 1598, 30.20, 72.00, 0.0003, 0.0005, 1.0002, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:14'),
	(58, 2, '2025-11-21 19:11:15', 1720, 1563, 30.20, 72.00, -0.0007, 0.0004, 0.9997, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:15'),
	(59, 2, '2025-11-21 19:11:16', 1711, 1598, 30.20, 72.00, -0.0001, 0.0009, 1.0001, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:16'),
	(60, 2, '2025-11-21 19:11:18', 1691, 1619, 30.20, 72.00, 0.0006, -0.0005, 1.0003, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:18'),
	(61, 2, '2025-11-21 19:11:19', 1751, 1569, 30.20, 72.00, 0.0003, 0.0004, 1.0004, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:19'),
	(62, 2, '2025-11-21 19:11:20', 1781, 1543, 30.20, 72.00, 0.0001, 0.0002, 1.0001, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:20'),
	(63, 2, '2025-11-21 19:11:21', 1675, 1593, 30.20, 72.00, -0.0011, -0.0004, 0.9996, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:21'),
	(64, 2, '2025-11-21 19:11:22', 1685, 1597, 30.20, 72.00, -0.0004, 0.0002, 0.9992, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:22'),
	(65, 2, '2025-11-21 19:11:23', 1693, 1590, 30.20, 72.00, 0.0007, -0.0007, 0.9975, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:23'),
	(66, 2, '2025-11-21 19:11:24', 1683, 1586, 30.20, 72.00, 0.0000, 0.0001, 0.9993, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:24'),
	(67, 2, '2025-11-21 19:11:25', 1743, 1541, 30.20, 72.00, -0.0004, -0.0001, 0.9993, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:25'),
	(68, 2, '2025-11-21 19:11:27', 1761, 1551, 30.20, 72.00, -0.0003, 0.0001, 0.9990, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:27'),
	(69, 2, '2025-11-21 19:11:28', 1693, 1605, 30.20, 72.00, -0.0001, -0.0001, 0.9994, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:28'),
	(70, 2, '2025-11-21 19:11:29', 1724, 1597, 30.20, 72.00, -0.0001, -0.0004, 0.9995, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:29'),
	(71, 2, '2025-11-21 19:11:30', 1675, 1638, 30.20, 72.00, -0.0005, -0.0006, 0.9999, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:30'),
	(72, 2, '2025-11-21 19:11:31', 1695, 1611, 30.20, 72.00, 0.0001, 0.0002, 0.9995, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:31'),
	(73, 2, '2025-11-21 19:11:32', 1779, 1530, 30.20, 72.00, 0.0000, 0.0006, 0.9990, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:32'),
	(74, 2, '2025-11-21 19:11:33', 1753, 1605, 30.20, 72.00, -0.0005, 0.0007, 1.0004, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:33'),
	(75, 2, '2025-11-21 19:11:35', 1771, 1562, 30.20, 72.00, 0.0008, -0.0001, 1.0004, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:35'),
	(76, 2, '2025-11-21 19:11:36', 1740, 1527, 30.20, 72.00, -0.0004, -0.0002, 1.0011, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:36'),
	(77, 2, '2025-11-21 19:11:37', 1696, 1606, 30.20, 72.00, -0.0009, 0.0003, 1.0008, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:37'),
	(78, 2, '2025-11-21 19:11:38', 1706, 1603, 30.20, 72.00, -0.0015, -0.0002, 0.9995, NULL, NULL, 0, 0.000, NULL, 'warning', '2025-11-21 19:11:38');

-- Dumping structure for table heart_monitoring.users
CREATE TABLE IF NOT EXISTS `users` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `date_of_birth` date DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table heart_monitoring.users: ~0 rows (approximately)
REPLACE INTO `users` (`id`, `name`, `email`, `password_hash`, `date_of_birth`, `created_at`, `updated_at`) VALUES
	(1, 'ragis', 'ragis@gmail.com', '', '2025-11-22', '2025-11-22 01:47:28', '2025-11-22 01:53:25'),
	(2, 'ragis2', 'ragis2@gmail.com', 'scrypt:32768:8:1$9PQVU0fpRw4PfAqh$40df26cdeaf9d39b1390e37c0b872ca6ab5f79fcda62ec1ffb68dbc9d7ecd0d2cc097a0880417be540fa53076b032f8693e6d84c5492d628f7f1b6fb41dce279', '2000-01-01', '2025-11-21 18:56:33', '2025-11-21 18:56:33');

-- Dumping structure for table heart_monitoring.user_health
CREATE TABLE IF NOT EXISTS `user_health` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `blood_type` varchar(3) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `height_cm` decimal(5,2) DEFAULT NULL,
  `weight_kg` decimal(5,2) DEFAULT NULL,
  `bmi` decimal(5,2) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_user_health_user` (`user_id`),
  CONSTRAINT `fk_user_health_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table heart_monitoring.user_health: ~1 rows (approximately)
REPLACE INTO `user_health` (`id`, `user_id`, `blood_type`, `height_cm`, `weight_kg`, `bmi`, `created_at`, `updated_at`) VALUES
	(1, 2, NULL, NULL, NULL, NULL, '2025-11-21 18:56:33', '2025-11-21 18:56:33');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;

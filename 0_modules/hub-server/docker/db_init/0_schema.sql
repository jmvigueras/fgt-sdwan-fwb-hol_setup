SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+01:00";

CREATE DATABASE IF NOT EXISTS students;
USE students;
DROP TABLE IF EXISTS students;
CREATE TABLE `students` (
  `email` varchar(255) COLLATE latin1_spanish_ci NOT NULL,
  `aws_user_id` varchar(255) COLLATE latin1_spanish_ci DEFAULT NULL,
  `accountid` varchar(255) COLLATE latin1_spanish_ci DEFAULT NULL,
  `forticloud_user` varchar(255) COLLATE latin1_spanish_ci DEFAULT NULL,
  `forticloud_password` varchar(255) COLLATE latin1_spanish_ci DEFAULT NULL,
  `fgt_ip` varchar(255) COLLATE latin1_spanish_ci DEFAULT NULL,
  `fgt_user` varchar(255) COLLATE latin1_spanish_ci DEFAULT NULL,
  `fgt_password` varchar(255) COLLATE latin1_spanish_ci DEFAULT NULL,
  `fgt_api_key` varchar(255) COLLATE latin1_spanish_ci DEFAULT NULL,
  `server_ip` varchar(255) COLLATE latin1_spanish_ci DEFAULT NULL,
  PRIMARY KEY (email)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;
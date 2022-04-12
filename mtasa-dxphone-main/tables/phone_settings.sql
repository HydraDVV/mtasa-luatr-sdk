/*
Navicat MySQL Data Transfer

Source Server         : database
Source Server Version : 80017
Source Host           : localhost:3306
Source Database       : new

Target Server Type    : MYSQL
Target Server Version : 80017
File Encoding         : 65001

Date: 2022-03-19 21:42:55
*/

SET FOREIGN_KEY_CHECKS=0;
-- ----------------------------
-- Table structure for `phone_settings`
-- ----------------------------
DROP TABLE IF EXISTS `phone_settings`;
CREATE TABLE `phone_settings` (
  `phone` bigint(20) NOT NULL,
  `password` varchar(50) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of phone_settings
-- ----------------------------
INSERT INTO `phone_settings` VALUES ('5371783580', '252525');
INSERT INTO `phone_settings` VALUES ('244', '252525');

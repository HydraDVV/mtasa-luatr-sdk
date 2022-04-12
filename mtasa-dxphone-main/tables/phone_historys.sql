/*
Navicat MySQL Data Transfer

Source Server         : database
Source Server Version : 80017
Source Host           : localhost:3306
Source Database       : new

Target Server Type    : MYSQL
Target Server Version : 80017
File Encoding         : 65001

Date: 2022-03-19 21:42:47
*/

SET FOREIGN_KEY_CHECKS=0;
-- ----------------------------
-- Table structure for `phone_historys`
-- ----------------------------
DROP TABLE IF EXISTS `phone_historys`;
CREATE TABLE `phone_historys` (
  `id` int(11) NOT NULL,
  `phone` bigint(20) NOT NULL,
  `number` bigint(20) NOT NULL,
  `hour` varchar(50) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `minute` varchar(50) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of phone_historys
-- ----------------------------

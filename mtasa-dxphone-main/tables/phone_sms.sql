/*
Navicat MySQL Data Transfer

Source Server         : database
Source Server Version : 80017
Source Host           : localhost:3306
Source Database       : new

Target Server Type    : MYSQL
Target Server Version : 80017
File Encoding         : 65001

Date: 2022-03-19 21:43:01
*/

SET FOREIGN_KEY_CHECKS=0;
-- ----------------------------
-- Table structure for `phone_sms`
-- ----------------------------
DROP TABLE IF EXISTS `phone_sms`;
CREATE TABLE `phone_sms` (
  `id` int(11) NOT NULL,
  `phone` bigint(20) NOT NULL,
  `number` bigint(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of phone_sms
-- ----------------------------
INSERT INTO `phone_sms` VALUES ('1', '244', '25');
INSERT INTO `phone_sms` VALUES ('2', '5371783580', '2424');

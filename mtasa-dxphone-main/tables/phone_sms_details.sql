/*
Navicat MySQL Data Transfer

Source Server         : database
Source Server Version : 80017
Source Host           : localhost:3306
Source Database       : new

Target Server Type    : MYSQL
Target Server Version : 80017
File Encoding         : 65001

Date: 2022-03-19 21:43:06
*/

SET FOREIGN_KEY_CHECKS=0;
-- ----------------------------
-- Table structure for `phone_sms_details`
-- ----------------------------
DROP TABLE IF EXISTS `phone_sms_details`;
CREATE TABLE `phone_sms_details` (
  `id` int(11) NOT NULL,
  `phone` bigint(20) NOT NULL,
  `number` bigint(20) NOT NULL,
  `message` varchar(50) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `hour` varchar(50) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `minute` varchar(50) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `viewed` int(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of phone_sms_details
-- ----------------------------
INSERT INTO `phone_sms_details` VALUES ('1', '244', '25', 'frmr', '21', '16', '1');
INSERT INTO `phone_sms_details` VALUES ('2', '244', '25', 'sa', '21', '16', '1');
INSERT INTO `phone_sms_details` VALUES ('3', '5371783580', '2424', 'sdgd', '21', '38', '1');
INSERT INTO `phone_sms_details` VALUES ('4', '5371783580', '2424', 'ggg', '21', '38', '1');

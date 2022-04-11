/*
Navicat MySQL Data Transfer

Source Server         : sss
Source Server Version : 80017
Source Host           : localhost:3306
Source Database       : mta

Target Server Type    : MYSQL
Target Server Version : 80017
File Encoding         : 65001

Date: 2022-04-11 11:23:01
*/

SET FOREIGN_KEY_CHECKS=0;
-- ----------------------------
-- Table structure for `mdc_accounts`
-- ----------------------------
DROP TABLE IF EXISTS `mdc_accounts`;
CREATE TABLE `mdc_accounts` (
  `username` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of mdc_accounts
-- ----------------------------
INSERT INTO `mdc_accounts` VALUES ('egm', 'egm103582');

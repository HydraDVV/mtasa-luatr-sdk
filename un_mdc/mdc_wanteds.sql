/*
Navicat MySQL Data Transfer

Source Server         : sss
Source Server Version : 80017
Source Host           : localhost:3306
Source Database       : mta

Target Server Type    : MYSQL
Target Server Version : 80017
File Encoding         : 65001

Date: 2022-04-11 11:23:14
*/

SET FOREIGN_KEY_CHECKS=0;
-- ----------------------------
-- Table structure for `mdc_wanteds`
-- ----------------------------
DROP TABLE IF EXISTS `mdc_wanteds`;
CREATE TABLE `mdc_wanteds` (
  `id` int(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `plate` varchar(255) DEFAULT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `date` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `author` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of mdc_wanteds
-- ----------------------------

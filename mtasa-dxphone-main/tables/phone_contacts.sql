/*
Navicat MySQL Data Transfer

Source Server         : database
Source Server Version : 80017
Source Host           : localhost:3306
Source Database       : new

Target Server Type    : MYSQL
Target Server Version : 80017
File Encoding         : 65001

Date: 2022-03-19 21:42:39
*/

SET FOREIGN_KEY_CHECKS=0;
-- ----------------------------
-- Table structure for `phone_contacts`
-- ----------------------------
DROP TABLE IF EXISTS `phone_contacts`;
CREATE TABLE `phone_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `phone` bigint(20) NOT NULL,
  `name` varchar(50) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `number` bigint(20) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `id_UNIQUE` (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of phone_contacts
-- ----------------------------
INSERT INTO `phone_contacts` VALUES ('1', '5371783580', 'denemem', '2424');
INSERT INTO `phone_contacts` VALUES ('2', '5371783580', 'denemem', '2424');
INSERT INTO `phone_contacts` VALUES ('3', '5371783580', 'denemem', '2424');
INSERT INTO `phone_contacts` VALUES ('4', '5371783580', 'asfasf', '2424');

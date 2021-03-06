/*
 Navicat Premium Data Transfer

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 50720
 Source Host           : localhost:3306
 Source Schema         : yz_demo

 Target Server Type    : MySQL
 Target Server Version : 50720
 File Encoding         : 65001

 Date: 25/04/2022 14:38:51
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for oauth_client_details
-- ----------------------------
DROP TABLE IF EXISTS `oauth_client_details`;
CREATE TABLE `oauth_client_details`  (
  `client_id` varchar(48) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `resource_ids` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `client_secret` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `scope` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `authorized_grant_types` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `web_server_redirect_uri` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `authorities` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `access_token_validity` int(11) NULL DEFAULT NULL,
  `refresh_token_validity` int(11) NULL DEFAULT NULL,
  `additional_information` varchar(4096) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `autoapprove` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`client_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of oauth_client_details
-- ----------------------------
INSERT INTO `oauth_client_details` VALUES ('binbin', NULL, '$2a$10$RpFJjxYiXdEsAGnWp/8fsOetMuOON96Ntk/Ym2M/RKRyU0GZseaDC', 'all', 'password', 'http://localhost:8083/login', 'ROLE_ADMIN', 3600, NULL, NULL, 'true');
INSERT INTO `oauth_client_details` VALUES ('noname', NULL, '$2a$10$RpFJjxYiXdEsAGnWp/8fsOetMuOON96Ntk/Ym2M/RKRyU0GZseaDC', 'all', 'authorization_code', 'http://localhost:8083/login', 'ROLE_ADMIN', 3600, NULL, NULL, 'true');

-- ----------------------------
-- Table structure for permissions
-- ----------------------------
DROP TABLE IF EXISTS `permissions`;
CREATE TABLE `permissions`  (
  `role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `resource` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `action` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  UNIQUE INDEX `uk_role_permission`(`role`, `resource`, `action`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of permissions
-- ----------------------------
INSERT INTO `permissions` VALUES ('1', '/demo/get', '1');
INSERT INTO `permissions` VALUES ('2', '/demo/get', 'GET');

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu`  (
  `menu_id` bigint(20) NOT NULL,
  `name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '????????????',
  `permission` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '??????????????????',
  `path` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '??????URL',
  `parent_id` bigint(20) NULL DEFAULT NULL COMMENT '?????????ID',
  `icon` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '??????',
  `sort_order` int(11) NOT NULL DEFAULT 0 COMMENT '?????????',
  `keep_alive` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '0-?????????1- ??????',
  `type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '???????????? ???0?????? 1?????????',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '??????????????????(0--?????? 1--??????)',
  `create_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '?????????',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '????????????',
  `update_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '?????????',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '????????????',
  `service_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '????????????',
  PRIMARY KEY (`menu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '???????????????' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` VALUES (1000, '????????????', NULL, '/admin', -1, 'jiaosequanxian', 1, '0', '0', '0', ' ', '2018-09-28 08:29:53', 'System', '2022-04-01 05:21:00', NULL);
INSERT INTO `sys_menu` VALUES (1100, '????????????', NULL, '/admin/user/index', 1000, 'yonghu', 0, '0', '0', '0', ' ', '2017-11-02 22:24:37', ' ', '2020-03-12 00:12:57', NULL);
INSERT INTO `sys_menu` VALUES (1101, '????????????', 'sys_user_add', NULL, 1100, NULL, 0, '0', '1', '0', ' ', '2017-11-08 09:52:09', 'System', '2022-04-05 09:54:55', '4433');
INSERT INTO `sys_menu` VALUES (1102, '????????????', 'sys_user_edit', NULL, 1100, NULL, 0, '0', '1', '0', ' ', '2017-11-08 09:52:48', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (1103, '????????????', 'sys_user_del', NULL, 1100, NULL, 0, '0', '1', '0', ' ', '2017-11-08 09:54:01', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (1104, '????????????', 'sys_user_import_export', NULL, 1100, NULL, 0, '0', '1', '1', ' ', '2017-11-08 09:54:01', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (1200, '????????????', NULL, '/admin/menu/index', 1000, 'caidan', 0, '0', '0', '0', ' ', '2017-11-08 09:57:27', ' ', '2020-03-12 00:13:52', NULL);
INSERT INTO `sys_menu` VALUES (1201, '????????????', 'sys_menu_add', NULL, 1200, NULL, 0, '0', '1', '0', ' ', '2017-11-08 10:15:53', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (1202, '????????????', 'sys_menu_edit', NULL, 1200, NULL, 0, '0', '1', '0', ' ', '2017-11-08 10:16:23', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (1203, '????????????', 'sys_menu_del', NULL, 1200, NULL, 0, '0', '1', '0', ' ', '2017-11-08 10:16:43', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (1300, '????????????', NULL, '/admin/role/index', 1000, 'jiaoseqiehuan', 0, '0', '0', '0', ' ', '2017-11-08 10:13:37', ' ', '2020-03-12 00:15:40', NULL);
INSERT INTO `sys_menu` VALUES (1301, '????????????', 'sys_role_add', NULL, 1300, NULL, 0, '0', '1', '0', ' ', '2017-11-08 10:14:18', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (1302, '????????????', 'sys_role_edit', NULL, 1300, NULL, 0, '0', '1', '0', ' ', '2017-11-08 10:14:41', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (1303, '????????????', 'sys_role_del', NULL, 1300, NULL, 0, '0', '1', '0', ' ', '2017-11-08 10:14:59', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (1304, '????????????', 'sys_role_perm', NULL, 1300, NULL, 0, '0', '1', '0', ' ', '2018-04-20 07:22:55', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (1400, '????????????', NULL, '/admin/dept/index', 1000, 'icon-web-icon-', 0, '0', '0', '1', ' ', '2018-01-20 13:17:19', ' ', '2020-03-12 00:15:44', NULL);
INSERT INTO `sys_menu` VALUES (1401, '????????????', 'sys_dept_add', NULL, 1400, NULL, 0, '0', '1', '1', ' ', '2018-01-20 14:56:16', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (1402, '????????????', 'sys_dept_edit', NULL, 1400, NULL, 0, '0', '1', '1', ' ', '2018-01-20 14:56:59', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (1403, '????????????', 'sys_dept_del', NULL, 1400, NULL, 0, '0', '1', '1', ' ', '2018-01-20 14:57:28', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (2000, '????????????', NULL, '/setting', -1, 'icon-xitongguanli', 2, '0', '0', '1', ' ', '2017-11-07 20:56:00', ' ', '2020-03-11 23:52:53', NULL);
INSERT INTO `sys_menu` VALUES (2100, '????????????', NULL, '/admin/log/index', 2000, 'icon-rizhiguanli', 0, '0', '0', '1', ' ', '2017-11-20 14:06:22', ' ', '2020-03-12 00:15:49', NULL);
INSERT INTO `sys_menu` VALUES (2101, '????????????', 'sys_log_del', NULL, 2100, NULL, 0, '0', '1', '1', ' ', '2017-11-20 20:37:37', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (2102, '????????????', 'sys_log_import_export', NULL, 2100, NULL, 0, '0', '1', '1', ' ', '2017-11-08 09:54:01', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (2200, '????????????', NULL, '/admin/dict/index', 2000, 'icon-navicon-zdgl', 0, '0', '0', '1', ' ', '2017-11-29 11:30:52', ' ', '2020-03-12 00:15:58', NULL);
INSERT INTO `sys_menu` VALUES (2201, '????????????', 'sys_dict_del', NULL, 2200, NULL, 0, '0', '1', '1', ' ', '2017-11-29 11:30:11', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (2202, '????????????', 'sys_dict_add', NULL, 2200, NULL, 0, '0', '1', '1', ' ', '2018-05-11 22:34:55', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (2203, '????????????', 'sys_dict_edit', NULL, 2200, NULL, 0, '0', '1', '1', ' ', '2018-05-11 22:36:03', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (2300, '????????????', NULL, '/admin/token/index', 2000, 'icon-denglvlingpai', 0, '0', '0', '1', ' ', '2018-09-04 05:58:41', ' ', '2020-03-13 12:57:25', NULL);
INSERT INTO `sys_menu` VALUES (2301, '????????????', 'sys_token_del', NULL, 2300, NULL, 0, '0', '1', '1', ' ', '2018-09-04 05:59:50', ' ', '2020-03-13 12:57:34', NULL);
INSERT INTO `sys_menu` VALUES (2400, '????????????', '', '/admin/client/index', 2000, 'icon-shouji', 0, '0', '0', '1', ' ', '2018-01-20 13:17:19', ' ', '2020-03-12 00:15:54', NULL);
INSERT INTO `sys_menu` VALUES (2401, '???????????????', 'sys_client_add', NULL, 2400, '1', 0, '0', '1', '1', ' ', '2018-05-15 21:35:18', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (2402, '???????????????', 'sys_client_edit', NULL, 2400, NULL, 0, '0', '1', '1', ' ', '2018-05-15 21:37:06', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (2403, '???????????????', 'sys_client_del', NULL, 2400, NULL, 0, '0', '1', '1', ' ', '2018-05-15 21:39:16', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (2500, '????????????', NULL, 'http://localhost:5001', 2000, 'icon-server', 0, '0', '0', '1', ' ', '2018-06-26 10:50:32', ' ', '2019-02-01 20:41:30', NULL);
INSERT INTO `sys_menu` VALUES (2600, '????????????', NULL, '/admin/file/index', 2000, 'icon-wenjianguanli', 0, '0', '0', '1', ' ', '2018-06-26 10:50:32', ' ', '2019-02-01 20:41:30', NULL);
INSERT INTO `sys_menu` VALUES (2601, '????????????', 'sys_file_del', NULL, 2600, NULL, 0, '0', '1', '1', ' ', '2017-11-29 11:30:11', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (2602, '????????????', 'sys_file_add', NULL, 2600, NULL, 0, '0', '1', '1', ' ', '2018-05-11 22:34:55', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (2603, '????????????', 'sys_file_edit', NULL, 2600, NULL, 0, '0', '1', '1', ' ', '2018-05-11 22:36:03', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (3000, '????????????', NULL, '/gen', -1, 'icon-shejiyukaifa-', 3, '1', '0', '1', ' ', '2020-03-11 22:15:40', ' ', '2020-03-11 23:52:54', NULL);
INSERT INTO `sys_menu` VALUES (3100, '???????????????', NULL, '/gen/datasource', 3000, 'icon-mysql', 0, '1', '0', '1', ' ', '2020-03-11 22:17:05', ' ', '2020-03-12 00:16:09', NULL);
INSERT INTO `sys_menu` VALUES (3200, '????????????', NULL, '/gen/index', 3000, 'icon-weibiaoti46', 0, '0', '0', '1', ' ', '2020-03-11 22:23:42', ' ', '2020-03-12 00:16:14', NULL);
INSERT INTO `sys_menu` VALUES (3300, '????????????', NULL, '/gen/form', 3000, 'icon-record', 0, '1', '0', '1', ' ', '2020-03-11 22:19:32', ' ', '2020-03-12 00:16:18', NULL);
INSERT INTO `sys_menu` VALUES (3301, '????????????', 'gen_form_add', NULL, 3300, '', 0, '0', '1', '1', ' ', '2018-05-15 21:35:18', ' ', '2020-03-11 22:39:08', NULL);
INSERT INTO `sys_menu` VALUES (3302, '????????????', 'gen_form_edit', NULL, 3300, '', 0, '0', '1', '1', ' ', '2018-05-15 21:35:18', ' ', '2020-03-11 22:39:09', NULL);
INSERT INTO `sys_menu` VALUES (3303, '????????????', 'gen_form_del', NULL, 3300, '', 0, '0', '1', '1', ' ', '2018-05-15 21:35:18', ' ', '2020-03-11 22:39:11', NULL);
INSERT INTO `sys_menu` VALUES (3400, '????????????', NULL, '/gen/design', 3000, 'icon-biaodanbiaoqian', 0, '1', '0', '1', ' ', '2020-03-11 22:18:05', ' ', '2020-03-12 00:16:25', NULL);
INSERT INTO `sys_menu` VALUES (9999, '????????????', NULL, 'https://pig4cloud.com/#/', -1, 'icon-guanwangfangwen', 999, '0', '0', '1', ' ', '2019-01-17 17:05:19', 'admin', '2020-03-11 23:52:57', NULL);
INSERT INTO `sys_menu` VALUES (1644822612033, 'demo ?????????', '', '/demo/demo/index', -1, 'icon-bangzhushouji', 8, '0', '0', '1', NULL, '2018-01-20 13:17:19', NULL, '2018-07-29 13:38:19', NULL);
INSERT INTO `sys_menu` VALUES (1644822612034, 'demo ?????????', 'demo_demo_get', '', 1644822612033, '1', 0, '0', '1', '1', NULL, '2018-05-15 21:35:18', NULL, '2018-07-29 13:38:59', NULL);
INSERT INTO `sys_menu` VALUES (1644822612035, 'demo ?????????', 'demo_demo_add', NULL, 1644822612033, '1', 1, '0', '1', '1', NULL, '2018-05-15 21:35:18', NULL, '2018-07-29 13:38:59', NULL);
INSERT INTO `sys_menu` VALUES (1644822612036, 'demo ?????????', 'demo_demo_edit', NULL, 1644822612033, '1', 2, '0', '1', '1', NULL, '2018-05-15 21:35:18', NULL, '2018-07-29 13:38:59', NULL);
INSERT INTO `sys_menu` VALUES (1644822612037, 'demo ?????????', 'demo_demo_del', NULL, 1644822612033, '1', 3, '0', '1', '1', NULL, '2018-05-15 21:35:18', NULL, '2018-07-29 13:38:59', NULL);
INSERT INTO `sys_menu` VALUES (1516339024434958336, '????????????', '', '/ceshi', -1, NULL, 2, '0', '0', '0', 'System', '2022-04-19 08:52:50', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1516342954648801280, '???????????????', '', '/demo', 1516339024434958336, NULL, 995, '0', '0', '0', 'System', '2022-04-19 09:08:27', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1516343053999280128, '??????????????????', '', '/demo/demo', 1516342954648801280, NULL, 999, '0', '0', '0', 'System', '2022-04-19 09:08:51', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1516343133145796608, '???????????????2', '', '/demo2', 1516339024434958336, NULL, 991, '0', '0', '0', 'System', '2022-04-19 09:09:10', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1516343479914074112, '??????1', '', '', 1516343053999280128, NULL, 999, '0', '1', '0', 'System', '2022-04-19 09:10:33', NULL, NULL, NULL);

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `role_id` bigint(20) NOT NULL,
  `role_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `role_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `role_desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '???????????????0-??????,1-?????????',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '????????????',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '????????????',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '?????????',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '?????????',
  PRIMARY KEY (`role_id`) USING BTREE,
  UNIQUE INDEX `role_idx1_role_code`(`role_code`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '???????????????' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '?????????', 'ROLE_ADMIN', '?????????', '0', '2017-10-27 15:45:51', '2022-04-08 06:00:58', 'System', NULL);
INSERT INTO `sys_role` VALUES (2, '??????1', 'ROLE_??????1', '??????1', '0', '2017-10-29 15:45:51', '2018-12-26 14:09:11', NULL, NULL);
INSERT INTO `sys_role` VALUES (3, '??????2', 'ROLE_??????2', '??????2', '0', '2017-10-29 15:45:51', '2018-12-26 14:09:11', NULL, NULL);
INSERT INTO `sys_role` VALUES (1516342395631964160, '000', '000', '000', '0', '2022-04-19 09:06:14', NULL, NULL, 'System');

-- ----------------------------
-- Table structure for sys_role_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu`  (
  `role_id` bigint(20) NOT NULL,
  `menu_id` bigint(20) NOT NULL,
  PRIMARY KEY (`role_id`, `menu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '???????????????' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role_menu
-- ----------------------------
INSERT INTO `sys_role_menu` VALUES (1, 1000);
INSERT INTO `sys_role_menu` VALUES (1, 1100);
INSERT INTO `sys_role_menu` VALUES (1, 1101);
INSERT INTO `sys_role_menu` VALUES (1, 1200);
INSERT INTO `sys_role_menu` VALUES (1, 1201);
INSERT INTO `sys_role_menu` VALUES (1, 1202);
INSERT INTO `sys_role_menu` VALUES (1, 1203);
INSERT INTO `sys_role_menu` VALUES (1, 1300);
INSERT INTO `sys_role_menu` VALUES (1, 1301);
INSERT INTO `sys_role_menu` VALUES (1, 1302);
INSERT INTO `sys_role_menu` VALUES (1, 1303);
INSERT INTO `sys_role_menu` VALUES (1, 1304);
INSERT INTO `sys_role_menu` VALUES (1, 1516339024434958336);
INSERT INTO `sys_role_menu` VALUES (1, 1516342954648801280);
INSERT INTO `sys_role_menu` VALUES (1, 1516343053999280128);
INSERT INTO `sys_role_menu` VALUES (1, 1516343133145796608);
INSERT INTO `sys_role_menu` VALUES (1, 1516343479914074112);
INSERT INTO `sys_role_menu` VALUES (3, 1000);
INSERT INTO `sys_role_menu` VALUES (3, 1100);
INSERT INTO `sys_role_menu` VALUES (3, 1103);
INSERT INTO `sys_role_menu` VALUES (3, 1516339024434958336);
INSERT INTO `sys_role_menu` VALUES (3, 1516343133145796608);
INSERT INTO `sys_role_menu` VALUES (1511559331915632640, 1200);
INSERT INTO `sys_role_menu` VALUES (1511559331915632640, 1300);
INSERT INTO `sys_role_menu` VALUES (1511559331915632640, 1516339024434958336);
INSERT INTO `sys_role_menu` VALUES (1516342395631964160, 1516339024434958336);
INSERT INTO `sys_role_menu` VALUES (1516342395631964160, 1516342954648801280);
INSERT INTO `sys_role_menu` VALUES (1516342395631964160, 1516343053999280128);
INSERT INTO `sys_role_menu` VALUES (1516342395631964160, 1516343133145796608);
INSERT INTO `sys_role_menu` VALUES (1516342395631964160, 1516343479914074112);

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `user_id` bigint(20) NOT NULL,
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '?????????',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '??????',
  `salt` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '?????????',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '??????',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '??????',
  `dept_id` bigint(20) NULL DEFAULT NULL COMMENT '??????ID',
  `lock_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '0-?????????9-??????',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '0-?????????1-??????',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '????????????',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '????????????',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '?????????',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '?????????',
  PRIMARY KEY (`user_id`) USING BTREE,
  INDEX `user_idx1_username`(`username`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '?????????' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 'admin', '$2a$10$RpFJjxYiXdEsAGnWp/8fsOetMuOON96Ntk/Ym2M/RKRyU0GZseaDC', NULL, '17034642444', '', 1, '0', '0', '2018-04-02 23:15:18', '2022-04-25 05:25:56', NULL, 'System');
INSERT INTO `sys_user` VALUES (1517365102132457473, 'maqiulei', '$2a$10$RpFJjxYiXdEsAGnWp/8fsOetMuOON96Ntk/Ym2M/RKRyU0GZseaDC', NULL, '15021633464', NULL, NULL, '0', '0', '2022-04-22 04:50:06', '2022-04-22 05:09:30', 'System', 'System');
INSERT INTO `sys_user` VALUES (1518467275079561218, '????????????', '$2a$10$RpFJjxYiXdEsAGnWp/8fsOetMuOON96Ntk/Ym2M/RKRyU0GZseaDC', NULL, '11111', NULL, NULL, '0', '0', '2022-04-25 05:49:45', NULL, 'System', NULL);

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
  `user_id` bigint(20) NOT NULL,
  `role_id` bigint(20) NOT NULL,
  PRIMARY KEY (`user_id`, `role_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '???????????????' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO `sys_user_role` VALUES (1, 1);
INSERT INTO `sys_user_role` VALUES (1517365102132457473, 1);
INSERT INTO `sys_user_role` VALUES (1517365102132457473, 1516342395631964160);

SET FOREIGN_KEY_CHECKS = 1;

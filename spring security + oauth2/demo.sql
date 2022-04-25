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
  `name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '菜单名称',
  `permission` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单权限标识',
  `path` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '前端URL',
  `parent_id` bigint(20) NULL DEFAULT NULL COMMENT '父菜单ID',
  `icon` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '图标',
  `sort_order` int(11) NOT NULL DEFAULT 0 COMMENT '排序值',
  `keep_alive` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '0-开启，1- 关闭',
  `type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单类型 （0菜单 1按钮）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '逻辑删除标记(0--正常 1--删除)',
  `create_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '修改人',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  `service_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '后端路径',
  PRIMARY KEY (`menu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '菜单权限表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` VALUES (1000, '权限管理', NULL, '/admin', -1, 'jiaosequanxian', 1, '0', '0', '0', ' ', '2018-09-28 08:29:53', 'System', '2022-04-01 05:21:00', NULL);
INSERT INTO `sys_menu` VALUES (1100, '用户管理', NULL, '/admin/user/index', 1000, 'yonghu', 0, '0', '0', '0', ' ', '2017-11-02 22:24:37', ' ', '2020-03-12 00:12:57', NULL);
INSERT INTO `sys_menu` VALUES (1101, '用户新增', 'sys_user_add', NULL, 1100, NULL, 0, '0', '1', '0', ' ', '2017-11-08 09:52:09', 'System', '2022-04-05 09:54:55', '4433');
INSERT INTO `sys_menu` VALUES (1102, '用户修改', 'sys_user_edit', NULL, 1100, NULL, 0, '0', '1', '0', ' ', '2017-11-08 09:52:48', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (1103, '用户删除', 'sys_user_del', NULL, 1100, NULL, 0, '0', '1', '0', ' ', '2017-11-08 09:54:01', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (1104, '导入导出', 'sys_user_import_export', NULL, 1100, NULL, 0, '0', '1', '1', ' ', '2017-11-08 09:54:01', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (1200, '菜单管理', NULL, '/admin/menu/index', 1000, 'caidan', 0, '0', '0', '0', ' ', '2017-11-08 09:57:27', ' ', '2020-03-12 00:13:52', NULL);
INSERT INTO `sys_menu` VALUES (1201, '菜单新增', 'sys_menu_add', NULL, 1200, NULL, 0, '0', '1', '0', ' ', '2017-11-08 10:15:53', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (1202, '菜单修改', 'sys_menu_edit', NULL, 1200, NULL, 0, '0', '1', '0', ' ', '2017-11-08 10:16:23', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (1203, '菜单删除', 'sys_menu_del', NULL, 1200, NULL, 0, '0', '1', '0', ' ', '2017-11-08 10:16:43', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (1300, '角色管理', NULL, '/admin/role/index', 1000, 'jiaoseqiehuan', 0, '0', '0', '0', ' ', '2017-11-08 10:13:37', ' ', '2020-03-12 00:15:40', NULL);
INSERT INTO `sys_menu` VALUES (1301, '角色新增', 'sys_role_add', NULL, 1300, NULL, 0, '0', '1', '0', ' ', '2017-11-08 10:14:18', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (1302, '角色修改', 'sys_role_edit', NULL, 1300, NULL, 0, '0', '1', '0', ' ', '2017-11-08 10:14:41', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (1303, '角色删除', 'sys_role_del', NULL, 1300, NULL, 0, '0', '1', '0', ' ', '2017-11-08 10:14:59', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (1304, '分配权限', 'sys_role_perm', NULL, 1300, NULL, 0, '0', '1', '0', ' ', '2018-04-20 07:22:55', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (1400, '部门管理', NULL, '/admin/dept/index', 1000, 'icon-web-icon-', 0, '0', '0', '1', ' ', '2018-01-20 13:17:19', ' ', '2020-03-12 00:15:44', NULL);
INSERT INTO `sys_menu` VALUES (1401, '部门新增', 'sys_dept_add', NULL, 1400, NULL, 0, '0', '1', '1', ' ', '2018-01-20 14:56:16', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (1402, '部门修改', 'sys_dept_edit', NULL, 1400, NULL, 0, '0', '1', '1', ' ', '2018-01-20 14:56:59', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (1403, '部门删除', 'sys_dept_del', NULL, 1400, NULL, 0, '0', '1', '1', ' ', '2018-01-20 14:57:28', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (2000, '系统管理', NULL, '/setting', -1, 'icon-xitongguanli', 2, '0', '0', '1', ' ', '2017-11-07 20:56:00', ' ', '2020-03-11 23:52:53', NULL);
INSERT INTO `sys_menu` VALUES (2100, '日志管理', NULL, '/admin/log/index', 2000, 'icon-rizhiguanli', 0, '0', '0', '1', ' ', '2017-11-20 14:06:22', ' ', '2020-03-12 00:15:49', NULL);
INSERT INTO `sys_menu` VALUES (2101, '日志删除', 'sys_log_del', NULL, 2100, NULL, 0, '0', '1', '1', ' ', '2017-11-20 20:37:37', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (2102, '导入导出', 'sys_log_import_export', NULL, 2100, NULL, 0, '0', '1', '1', ' ', '2017-11-08 09:54:01', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (2200, '字典管理', NULL, '/admin/dict/index', 2000, 'icon-navicon-zdgl', 0, '0', '0', '1', ' ', '2017-11-29 11:30:52', ' ', '2020-03-12 00:15:58', NULL);
INSERT INTO `sys_menu` VALUES (2201, '字典删除', 'sys_dict_del', NULL, 2200, NULL, 0, '0', '1', '1', ' ', '2017-11-29 11:30:11', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (2202, '字典新增', 'sys_dict_add', NULL, 2200, NULL, 0, '0', '1', '1', ' ', '2018-05-11 22:34:55', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (2203, '字典修改', 'sys_dict_edit', NULL, 2200, NULL, 0, '0', '1', '1', ' ', '2018-05-11 22:36:03', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (2300, '令牌管理', NULL, '/admin/token/index', 2000, 'icon-denglvlingpai', 0, '0', '0', '1', ' ', '2018-09-04 05:58:41', ' ', '2020-03-13 12:57:25', NULL);
INSERT INTO `sys_menu` VALUES (2301, '令牌删除', 'sys_token_del', NULL, 2300, NULL, 0, '0', '1', '1', ' ', '2018-09-04 05:59:50', ' ', '2020-03-13 12:57:34', NULL);
INSERT INTO `sys_menu` VALUES (2400, '终端管理', '', '/admin/client/index', 2000, 'icon-shouji', 0, '0', '0', '1', ' ', '2018-01-20 13:17:19', ' ', '2020-03-12 00:15:54', NULL);
INSERT INTO `sys_menu` VALUES (2401, '客户端新增', 'sys_client_add', NULL, 2400, '1', 0, '0', '1', '1', ' ', '2018-05-15 21:35:18', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (2402, '客户端修改', 'sys_client_edit', NULL, 2400, NULL, 0, '0', '1', '1', ' ', '2018-05-15 21:37:06', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (2403, '客户端删除', 'sys_client_del', NULL, 2400, NULL, 0, '0', '1', '1', ' ', '2018-05-15 21:39:16', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (2500, '服务监控', NULL, 'http://localhost:5001', 2000, 'icon-server', 0, '0', '0', '1', ' ', '2018-06-26 10:50:32', ' ', '2019-02-01 20:41:30', NULL);
INSERT INTO `sys_menu` VALUES (2600, '文件管理', NULL, '/admin/file/index', 2000, 'icon-wenjianguanli', 0, '0', '0', '1', ' ', '2018-06-26 10:50:32', ' ', '2019-02-01 20:41:30', NULL);
INSERT INTO `sys_menu` VALUES (2601, '文件删除', 'sys_file_del', NULL, 2600, NULL, 0, '0', '1', '1', ' ', '2017-11-29 11:30:11', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (2602, '文件新增', 'sys_file_add', NULL, 2600, NULL, 0, '0', '1', '1', ' ', '2018-05-11 22:34:55', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (2603, '文件修改', 'sys_file_edit', NULL, 2600, NULL, 0, '0', '1', '1', ' ', '2018-05-11 22:36:03', ' ', '2021-05-25 06:48:34', NULL);
INSERT INTO `sys_menu` VALUES (3000, '开发平台', NULL, '/gen', -1, 'icon-shejiyukaifa-', 3, '1', '0', '1', ' ', '2020-03-11 22:15:40', ' ', '2020-03-11 23:52:54', NULL);
INSERT INTO `sys_menu` VALUES (3100, '数据源管理', NULL, '/gen/datasource', 3000, 'icon-mysql', 0, '1', '0', '1', ' ', '2020-03-11 22:17:05', ' ', '2020-03-12 00:16:09', NULL);
INSERT INTO `sys_menu` VALUES (3200, '代码生成', NULL, '/gen/index', 3000, 'icon-weibiaoti46', 0, '0', '0', '1', ' ', '2020-03-11 22:23:42', ' ', '2020-03-12 00:16:14', NULL);
INSERT INTO `sys_menu` VALUES (3300, '表单管理', NULL, '/gen/form', 3000, 'icon-record', 0, '1', '0', '1', ' ', '2020-03-11 22:19:32', ' ', '2020-03-12 00:16:18', NULL);
INSERT INTO `sys_menu` VALUES (3301, '表单新增', 'gen_form_add', NULL, 3300, '', 0, '0', '1', '1', ' ', '2018-05-15 21:35:18', ' ', '2020-03-11 22:39:08', NULL);
INSERT INTO `sys_menu` VALUES (3302, '表单修改', 'gen_form_edit', NULL, 3300, '', 0, '0', '1', '1', ' ', '2018-05-15 21:35:18', ' ', '2020-03-11 22:39:09', NULL);
INSERT INTO `sys_menu` VALUES (3303, '表单删除', 'gen_form_del', NULL, 3300, '', 0, '0', '1', '1', ' ', '2018-05-15 21:35:18', ' ', '2020-03-11 22:39:11', NULL);
INSERT INTO `sys_menu` VALUES (3400, '表单设计', NULL, '/gen/design', 3000, 'icon-biaodanbiaoqian', 0, '1', '0', '1', ' ', '2020-03-11 22:18:05', ' ', '2020-03-12 00:16:25', NULL);
INSERT INTO `sys_menu` VALUES (9999, '系统官网', NULL, 'https://pig4cloud.com/#/', -1, 'icon-guanwangfangwen', 999, '0', '0', '1', ' ', '2019-01-17 17:05:19', 'admin', '2020-03-11 23:52:57', NULL);
INSERT INTO `sys_menu` VALUES (1644822612033, 'demo 表管理', '', '/demo/demo/index', -1, 'icon-bangzhushouji', 8, '0', '0', '1', NULL, '2018-01-20 13:17:19', NULL, '2018-07-29 13:38:19', NULL);
INSERT INTO `sys_menu` VALUES (1644822612034, 'demo 表查看', 'demo_demo_get', '', 1644822612033, '1', 0, '0', '1', '1', NULL, '2018-05-15 21:35:18', NULL, '2018-07-29 13:38:59', NULL);
INSERT INTO `sys_menu` VALUES (1644822612035, 'demo 表新增', 'demo_demo_add', NULL, 1644822612033, '1', 1, '0', '1', '1', NULL, '2018-05-15 21:35:18', NULL, '2018-07-29 13:38:59', NULL);
INSERT INTO `sys_menu` VALUES (1644822612036, 'demo 表修改', 'demo_demo_edit', NULL, 1644822612033, '1', 2, '0', '1', '1', NULL, '2018-05-15 21:35:18', NULL, '2018-07-29 13:38:59', NULL);
INSERT INTO `sys_menu` VALUES (1644822612037, 'demo 表删除', 'demo_demo_del', NULL, 1644822612033, '1', 3, '0', '1', '1', NULL, '2018-05-15 21:35:18', NULL, '2018-07-29 13:38:59', NULL);
INSERT INTO `sys_menu` VALUES (1516339024434958336, '测试菜单', '', '/ceshi', -1, NULL, 2, '0', '0', '0', 'System', '2022-04-19 08:52:50', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1516342954648801280, '测试子菜单', '', '/demo', 1516339024434958336, NULL, 995, '0', '0', '0', 'System', '2022-04-19 09:08:27', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1516343053999280128, '测试子子菜单', '', '/demo/demo', 1516342954648801280, NULL, 999, '0', '0', '0', 'System', '2022-04-19 09:08:51', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1516343133145796608, '测试子菜单2', '', '/demo2', 1516339024434958336, NULL, 991, '0', '0', '0', 'System', '2022-04-19 09:09:10', NULL, NULL, NULL);
INSERT INTO `sys_menu` VALUES (1516343479914074112, '按钮1', '', '', 1516343053999280128, NULL, 999, '0', '1', '0', 'System', '2022-04-19 09:10:33', NULL, NULL, NULL);

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `role_id` bigint(20) NOT NULL,
  `role_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `role_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `role_desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '删除标识（0-正常,1-删除）',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '修改时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '修改人',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  PRIMARY KEY (`role_id`) USING BTREE,
  UNIQUE INDEX `role_idx1_role_code`(`role_code`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '系统角色表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '管理员', 'ROLE_ADMIN', '管理员', '0', '2017-10-27 15:45:51', '2022-04-08 06:00:58', 'System', NULL);
INSERT INTO `sys_role` VALUES (2, '测试1', 'ROLE_测试1', '测试1', '0', '2017-10-29 15:45:51', '2018-12-26 14:09:11', NULL, NULL);
INSERT INTO `sys_role` VALUES (3, '测试2', 'ROLE_测试2', '测试2', '0', '2017-10-29 15:45:51', '2018-12-26 14:09:11', NULL, NULL);
INSERT INTO `sys_role` VALUES (1516342395631964160, '000', '000', '000', '0', '2022-04-19 09:06:14', NULL, NULL, 'System');

-- ----------------------------
-- Table structure for sys_role_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu`  (
  `role_id` bigint(20) NOT NULL,
  `menu_id` bigint(20) NOT NULL,
  PRIMARY KEY (`role_id`, `menu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色菜单表' ROW_FORMAT = Dynamic;

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
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户名',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '密码',
  `salt` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '随机盐',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '简介',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '头像',
  `dept_id` bigint(20) NULL DEFAULT NULL COMMENT '部门ID',
  `lock_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '0-正常，9-锁定',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '0-正常，1-删除',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '修改时间',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建者',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`user_id`) USING BTREE,
  INDEX `user_idx1_username`(`username`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 'admin', '$2a$10$RpFJjxYiXdEsAGnWp/8fsOetMuOON96Ntk/Ym2M/RKRyU0GZseaDC', NULL, '17034642444', '', 1, '0', '0', '2018-04-02 23:15:18', '2022-04-25 05:25:56', NULL, 'System');
INSERT INTO `sys_user` VALUES (1517365102132457473, 'maqiulei', '$2a$10$RpFJjxYiXdEsAGnWp/8fsOetMuOON96Ntk/Ym2M/RKRyU0GZseaDC', NULL, '15021633464', NULL, NULL, '0', '0', '2022-04-22 04:50:06', '2022-04-22 05:09:30', 'System', 'System');
INSERT INTO `sys_user` VALUES (1518467275079561218, '测试用户', '$2a$10$RpFJjxYiXdEsAGnWp/8fsOetMuOON96Ntk/Ym2M/RKRyU0GZseaDC', NULL, '11111', NULL, NULL, '0', '0', '2022-04-25 05:49:45', NULL, 'System', NULL);

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
  `user_id` bigint(20) NOT NULL,
  `role_id` bigint(20) NOT NULL,
  PRIMARY KEY (`user_id`, `role_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户角色表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO `sys_user_role` VALUES (1, 1);
INSERT INTO `sys_user_role` VALUES (1517365102132457473, 1);
INSERT INTO `sys_user_role` VALUES (1517365102132457473, 1516342395631964160);

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================
-- 一程随行（along-trip）T5：菜单 + 业务字典 SQL
-- 执行库：ry
-- 权限标识统一为 trip:{资源}:{操作}
-- =============================================================

-- ---------------- 1. 菜单 ----------------

-- 顶级目录「行程规划」
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('行程规划', 0, 5, 'trip', null, 1, 0, 'M', '0', '0', '', 'guide', 'admin', sysdate(), '', null, '行程规划目录');
SELECT @tripMenu := LAST_INSERT_ID();

-- 1.1 我的行程
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('我的行程', @tripMenu, 1, 'index', 'trip/index', 1, 0, 'C', '0', '0', 'trip:trip:list', 'list', 'admin', sysdate(), '', null, '我的行程菜单');
SELECT @pid := LAST_INSERT_ID();
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('行程查询', @pid, 1, '', '', 1, 0, 'F', '0', '0', 'trip:trip:query', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('行程新增', @pid, 2, '', '', 1, 0, 'F', '0', '0', 'trip:trip:add', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('行程修改', @pid, 3, '', '', 1, 0, 'F', '0', '0', 'trip:trip:edit', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('行程删除', @pid, 4, '', '', 1, 0, 'F', '0', '0', 'trip:trip:remove', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('行程导出', @pid, 5, '', '', 1, 0, 'F', '0', '0', 'trip:trip:export', '#', 'admin', sysdate(), '', null, '');

-- 1.2 日程编排
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('日程编排', @tripMenu, 2, 'day', 'trip/day', 1, 0, 'C', '0', '0', 'trip:day:list', 'calendar', 'admin', sysdate(), '', null, '日程编排菜单');
SELECT @pid := LAST_INSERT_ID();
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('日程查询', @pid, 1, '', '', 1, 0, 'F', '0', '0', 'trip:day:query', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('日程新增', @pid, 2, '', '', 1, 0, 'F', '0', '0', 'trip:day:add', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('日程修改', @pid, 3, '', '', 1, 0, 'F', '0', '0', 'trip:day:edit', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('日程删除', @pid, 4, '', '', 1, 0, 'F', '0', '0', 'trip:day:remove', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('日程导出', @pid, 5, '', '', 1, 0, 'F', '0', '0', 'trip:day:export', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('日程项查询', @pid, 6, '', '', 1, 0, 'F', '0', '0', 'trip:item:query', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('日程项新增', @pid, 7, '', '', 1, 0, 'F', '0', '0', 'trip:item:add', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('日程项修改', @pid, 8, '', '', 1, 0, 'F', '0', '0', 'trip:item:edit', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('日程项删除', @pid, 9, '', '', 1, 0, 'F', '0', '0', 'trip:item:remove', '#', 'admin', sysdate(), '', null, '');

-- 1.3 景点库
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('景点库', @tripMenu, 3, 'spot', 'trip/spot', 1, 0, 'C', '0', '0', 'trip:spot:list', 'location', 'admin', sysdate(), '', null, '景点库菜单');
SELECT @pid := LAST_INSERT_ID();
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('景点查询', @pid, 1, '', '', 1, 0, 'F', '0', '0', 'trip:spot:query', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('景点新增', @pid, 2, '', '', 1, 0, 'F', '0', '0', 'trip:spot:add', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('景点修改', @pid, 3, '', '', 1, 0, 'F', '0', '0', 'trip:spot:edit', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('景点删除', @pid, 4, '', '', 1, 0, 'F', '0', '0', 'trip:spot:remove', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('景点导出', @pid, 5, '', '', 1, 0, 'F', '0', '0', 'trip:spot:export', '#', 'admin', sysdate(), '', null, '');

-- 1.4 预算管理
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('预算管理', @tripMenu, 4, 'budget', 'trip/budget', 1, 0, 'C', '0', '0', 'trip:budget:list', 'money', 'admin', sysdate(), '', null, '预算管理菜单');
SELECT @pid := LAST_INSERT_ID();
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('预算查询', @pid, 1, '', '', 1, 0, 'F', '0', '0', 'trip:budget:query', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('预算新增', @pid, 2, '', '', 1, 0, 'F', '0', '0', 'trip:budget:add', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('预算修改', @pid, 3, '', '', 1, 0, 'F', '0', '0', 'trip:budget:edit', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('预算删除', @pid, 4, '', '', 1, 0, 'F', '0', '0', 'trip:budget:remove', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('预算导出', @pid, 5, '', '', 1, 0, 'F', '0', '0', 'trip:budget:export', '#', 'admin', sysdate(), '', null, '');

-- 1.5 成员管理
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('成员管理', @tripMenu, 5, 'member', 'trip/member', 1, 0, 'C', '0', '0', 'trip:member:list', 'people', 'admin', sysdate(), '', null, '成员管理菜单');
SELECT @pid := LAST_INSERT_ID();
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('成员查询', @pid, 1, '', '', 1, 0, 'F', '0', '0', 'trip:member:query', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('成员新增', @pid, 2, '', '', 1, 0, 'F', '0', '0', 'trip:member:add', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('成员修改', @pid, 3, '', '', 1, 0, 'F', '0', '0', 'trip:member:edit', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('成员删除', @pid, 4, '', '', 1, 0, 'F', '0', '0', 'trip:member:remove', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) values('成员导出', @pid, 5, '', '', 1, 0, 'F', '0', '0', 'trip:member:export', '#', 'admin', sysdate(), '', null, '');

-- ---------------- 2. 业务字典 ----------------

-- 2.1 行程状态
insert into sys_dict_type (dict_name, dict_type, status, create_by, create_time, update_by, update_time, remark)
values('行程状态', 'trip_status', '0', 'admin', sysdate(), '', null, '行程状态列表');
SELECT @dictId := LAST_INSERT_ID();
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark) values(1, '草稿', '0', 'trip_status', '', 'info', 'Y', '0', 'admin', sysdate(), '', null, '行程状态：草稿');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark) values(2, '进行中', '1', 'trip_status', '', 'primary', 'N', '0', 'admin', sysdate(), '', null, '行程状态：进行中');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark) values(3, '已完成', '2', 'trip_status', '', 'success', 'N', '0', 'admin', sysdate(), '', null, '行程状态：已完成');

-- 2.2 日程项类型
insert into sys_dict_type (dict_name, dict_type, status, create_by, create_time, update_by, update_time, remark)
values('日程项类型', 'trip_item_type', '0', 'admin', sysdate(), '', null, '日程项类型列表');
SELECT @dictId := LAST_INSERT_ID();
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark) values(1, '景点', '1', 'trip_item_type', '', 'primary', 'Y', '0', 'admin', sysdate(), '', null, '日程项类型：景点');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark) values(2, '交通', '2', 'trip_item_type', '', 'success', 'N', '0', 'admin', sysdate(), '', null, '日程项类型：交通');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark) values(3, '住宿', '3', 'trip_item_type', '', 'warning', 'N', '0', 'admin', sysdate(), '', null, '日程项类型：住宿');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark) values(4, '餐饮', '4', 'trip_item_type', '', 'danger', 'N', '0', 'admin', sysdate(), '', null, '日程项类型：餐饮');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark) values(5, '其他', '5', 'trip_item_type', '', 'info', 'N', '0', 'admin', sysdate(), '', null, '日程项类型：其他');

-- 2.3 协作角色
insert into sys_dict_type (dict_name, dict_type, status, create_by, create_time, update_by, update_time, remark)
values('协作角色', 'trip_role', '0', 'admin', sysdate(), '', null, '协作角色列表');
SELECT @dictId := LAST_INSERT_ID();
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark) values(1, '所有者', '1', 'trip_role', '', 'primary', 'Y', '0', 'admin', sysdate(), '', null, '协作角色：所有者');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark) values(2, '编辑者', '2', 'trip_role', '', 'warning', 'N', '0', 'admin', sysdate(), '', null, '协作角色：编辑者');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark) values(3, '浏览者', '3', 'trip_role', '', 'info', 'N', '0', 'admin', sysdate(), '', null, '协作角色：浏览者');

-- 2.4 预算分类
insert into sys_dict_type (dict_name, dict_type, status, create_by, create_time, update_by, update_time, remark)
values('预算分类', 'budget_category', '0', 'admin', sysdate(), '', null, '预算分类列表');
SELECT @dictId := LAST_INSERT_ID();
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark) values(1, '交通', '1', 'budget_category', '', 'primary', 'Y', '0', 'admin', sysdate(), '', null, '预算分类：交通');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark) values(2, '住宿', '2', 'budget_category', '', 'success', 'N', '0', 'admin', sysdate(), '', null, '预算分类：住宿');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark) values(3, '餐饮', '3', 'budget_category', '', 'warning', 'N', '0', 'admin', sysdate(), '', null, '预算分类：餐饮');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark) values(4, '门票', '4', 'budget_category', '', 'danger', 'N', '0', 'admin', sysdate(), '', null, '预算分类：门票');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark) values(5, '其他', '5', 'budget_category', '', 'info', 'N', '0', 'admin', sysdate(), '', null, '预算分类：其他');

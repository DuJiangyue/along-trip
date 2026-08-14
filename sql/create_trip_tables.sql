-- =============================================================
-- 一程随行（along-trip）行程规划业务表
-- 遵循若依规范字段：id / create_by / create_time / update_by / update_time / remark
-- 对应方案书 §6 数据库表设计（6 张核心表）
-- 执行库：ry
-- =============================================================

-- 6.1 行程表
create table trip (
  id            bigint(20)      not null auto_increment    comment '行程ID',
  trip_name     varchar(100)    not null                   comment '行程名称',
  destination   varchar(100)    default null               comment '目的地',
  start_date    date                                       comment '开始日期',
  end_date      date                                       comment '结束日期',
  theme_color   varchar(20)     default null               comment '封面主题色',
  status        char(1)         default '0'                comment '状态（0草稿 1进行中 2已完成）',
  owner_id      bigint(20)      not null                   comment '行程所有者用户ID',
  create_by     varchar(64)     default ''                 comment '创建者',
  create_time   datetime                                   comment '创建时间',
  update_by     varchar(64)     default ''                 comment '更新者',
  update_time   datetime                                   comment '更新时间',
  remark        varchar(500)    default null               comment '备注',
  primary key (id),
  key idx_trip_owner (owner_id)
) engine=innodb auto_increment=1 comment = '行程表';

-- 6.2 行程日程表（按天）
create table trip_day (
  id            bigint(20)      not null auto_increment    comment '日程ID',
  trip_id       bigint(20)      not null                   comment '所属行程ID',
  day_no        int             not null                   comment '第N天（1起）',
  trip_date     date                                       comment '当天日期',
  create_by     varchar(64)     default ''                 comment '创建者',
  create_time   datetime                                   comment '创建时间',
  update_by     varchar(64)     default ''                 comment '更新者',
  update_time   datetime                                   comment '更新时间',
  remark        varchar(500)    default null               comment '备注',
  primary key (id),
  unique key uk_trip_day (trip_id, day_no)
) engine=innodb auto_increment=1 comment = '行程日程表';

-- 6.3 行程日程项表
create table trip_item (
  id            bigint(20)      not null auto_increment    comment '日程项ID',
  day_id        bigint(20)      not null                   comment '所属日程ID',
  item_name     varchar(200)    not null                   comment '名称（景点/车次/酒店等）',
  item_type     char(1)         default '1'                comment '类型（1景点 2交通 3住宿 4餐饮 5其他）',
  start_time    varchar(10)     default null               comment '开始时间（HH:mm）',
  end_time      varchar(10)     default null               comment '结束时间（HH:mm）',
  spot_id       bigint(20)      default null               comment '关联景点ID（仅类型=景点时）',
  note          varchar(500)    default null               comment '备注',
  sort_order    int             default 0                  comment '当日排序',
  create_by     varchar(64)     default ''                 comment '创建者',
  create_time   datetime                                   comment '创建时间',
  update_by     varchar(64)     default ''                 comment '更新者',
  update_time   datetime                                   comment '更新时间',
  remark        varchar(500)    default null               comment '备注',
  primary key (id),
  key idx_trip_item_day (day_id),
  key idx_trip_item_spot (spot_id)
) engine=innodb auto_increment=1 comment = '行程日程项表';

-- 6.4 景点库表
create table trip_spot (
  id            bigint(20)      not null auto_increment    comment '景点ID',
  spot_name     varchar(100)    not null                   comment '景点名称',
  city          varchar(50)     default null               comment '城市',
  address       varchar(200)    default null               comment '地址',
  lng           decimal(10,6)   default null               comment '经度',
  lat           decimal(10,6)   default null               comment '纬度',
  rating        decimal(2,1)    default null               comment '评分',
  intro         text                                       comment '简介',
  image_url     varchar(200)    default null               comment '图片',
  create_by     varchar(64)     default ''                 comment '创建者',
  create_time   datetime                                   comment '创建时间',
  update_by     varchar(64)     default ''                 comment '更新者',
  update_time   datetime                                   comment '更新时间',
  remark        varchar(500)    default null               comment '备注',
  primary key (id),
  key idx_trip_spot_city (city)
) engine=innodb auto_increment=1 comment = '景点库表';

-- 6.5 行程成员表
create table trip_member (
  id            bigint(20)      not null auto_increment    comment '成员ID',
  trip_id       bigint(20)      not null                   comment '所属行程ID',
  user_id       bigint(20)      not null                   comment '成员用户ID',
  `role`        char(1)         default '3'                comment '角色（1owner 2editor 3viewer）',
  create_by     varchar(64)     default ''                 comment '创建者',
  create_time   datetime                                   comment '创建时间',
  update_by     varchar(64)     default ''                 comment '更新者',
  update_time   datetime                                   comment '更新时间',
  remark        varchar(500)    default null               comment '备注',
  primary key (id),
  unique key uk_trip_member (trip_id, user_id)
) engine=innodb auto_increment=1 comment = '行程成员表';

-- 6.6 预算项表
create table trip_budget (
  id            bigint(20)      not null auto_increment    comment '预算项ID',
  trip_id       bigint(20)      not null                   comment '所属行程ID',
  category      char(1)         not null                   comment '分类（1交通 2住宿 3餐饮 4门票 5其他）',
  budget_amount decimal(10,2)   default 0.00               comment '预算金额',
  actual_amount decimal(10,2)   default 0.00               comment '实际花费',
  create_by     varchar(64)     default ''                 comment '创建者',
  create_time   datetime                                   comment '创建时间',
  update_by     varchar(64)     default ''                 comment '更新者',
  update_time   datetime                                   comment '更新时间',
  remark        varchar(500)    default null               comment '备注',
  primary key (id),
  unique key uk_trip_budget (trip_id, category)
) engine=innodb auto_increment=1 comment = '预算项表';

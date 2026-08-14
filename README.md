# 一程随行（along-trip）

行程规划类 App —— 单人规划 + 多人协作，基于 RuoYi-Vue3 二开。

## 技术栈

- 前端：Vue 3 + Vite 6 + Element Plus + Pinia + Vue Router 4 + ECharts + vuedraggable
- 后端：RuoYi-Vue 3.9.2（Spring Boot + MyBatis + MySQL + Redis）
- 地图：高德地图 JS API（需申请 key）

## 功能清单

| 模块 | 说明 |
|---|---|
| 我的行程工作台 | 登录落地页，卡片流展示我参与的行程 |
| 行程管理 | 行程增删改查（目的地、起止日期、主题色、状态） |
| 日程编排 | 按天 Tab + 日程项时间轴 + vuedraggable 拖拽排序 |
| 景点库 | 景点增删改查 + 高德地图选点回填经纬度 |
| 预算管理 | 分类预算 vs 实际花费 + 饼图占比 |
| 协作成员 | owner/editor/viewer 三角色，仅 owner 可管理成员 |
| 行程分享 | 生成只读分享口令，匿名只读视图 |

## 目录结构

```
/usr/along-trip/                 # 项目根
├── RuoYi-Vue3-master/           # 前端
│   └── src/
│       ├── api/trip/            # 行程模块接口（trip/day/item/spot/member/budget/share）
│       ├── views/trip/          # 行程模块页面
│       ├── views/share/         # 匿名只读分享页
│       ├── components/MapPicker.vue  # 高德地图选点组件
│       └── layout/              # 移动端布局（内容区限宽 480px）
├── sql/
│   ├── create_trip_tables.sql   # 6 张业务表建表脚本
│   └── trip_menu_dict.sql       # 菜单 + 业务字典 SQL
└── docs/
    ├── 行程规划项目改造方案.md
    └── 任务执行情况.md
```

后端在 `/usr/RuoYi-Vue`（ruoyi-system / ruoyi-admin 模块，包 `com.ruoyi.system`）。

## 快速启动

```bash
# 后端（端口 8080）
cd /usr/RuoYi-Vue
JAVA_HOME=/usr/lib/jvm/java-17-openjdk bash start.sh

# 前端（端口 80）
cd /usr/along-trip/RuoYi-Vue3-master
npm run dev
```

访问：
- 前端：http://10.0.0.132/
- 后端 Swagger：http://10.0.0.132:8080/swagger-ui/index.html
- 账号：admin / admin123

## 地图配置

高德地图选点组件（`src/components/MapPicker.vue`）需在高德开放平台 https://lbs.amap.com 申请「Web 端(JS API)」key 与安全密钥，替换文件中的 `AMAP_KEY` / `AMAP_SECURITY_CODE` 占位符。

## 任务进度

T1~T17 已完成，详见 `docs/任务执行情况.md`。二期：T18 行程地图总览视图。

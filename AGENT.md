# RuoYi-Vue3 二开项目 AI 协作规范

## 项目概述
- 基于 RuoYi-Vue3（Vue 3 + Vite + Element Plus + Pinia + Vue Router 4）
- 使用 JavaScript（非 TypeScript），所有代码必须用 JS 编写
- 后端为 Spring Boot，前端通过 /dev-api 代理访问后端接口

## 技术约束
- Vue 版本：Vue 3.x，使用 Composition API（<script setup>）
- UI 框架：Element Plus，组件按需引入，全局已注册
- 状态管理：Pinia，不使用 Vuex
- 路由：Vue Router 4，动态路由由后端返回菜单生成
- HTTP：项目已封装 src/utils/request.js，禁止直接使用 axios
- 构建：Vite，别名 @ 指向 src/

## 编码规范
1. 页面组件放在 src/views/{模块名}/ 下，文件名用 kebab-case
2. API 接口文件放在 src/api/{模块名}/ 下，导出函数命名：list/get/add/update/del + 资源名
3. 所有列表页必须使用 <pagination> 组件，配合 queryParams.pageNum/pageSize
4. 字典值使用 <dict-tag> 组件展示，字典数据通过 useDict() 或 getDicts() 获取
5. 权限控制使用 v-hasPermi 指令，如 v-hasPermi="['system:user:add']"
6. 弹窗使用 el-dialog，表单验证使用 el-form 的 rules 属性
7. 消息提示使用 ElMessage / ElMessageBox（已全局注册）
8. 日期格式统一使用 YYYY-MM-DD HH:mm:ss

## 文件组织规则
- 新增业务模块时：
  - src/api/{module}/xxx.js    → 接口定义
  - src/views/{module}/xxx/    → 页面组件
  - 路由由后端菜单配置，前端不需要手动添加动态路由

## 禁止事项
- ❌ 不要使用 TypeScript 语法
- ❌ 不要引入新的 UI 框架（如 Ant Design）
- ❌ 不要修改 src/utils/request.js 的核心拦截逻辑
- ❌ 不要使用 Options API，统一用 <script setup>
- ❌ 不要硬编码后端地址，统一走 request.js
- ❌ 不要删除或修改 permission.js 中已有的路由守卫逻辑

## 参考模板
新增 CRUD 页面时，请参考 src/views/system/user/index.vue 的代码结构和风格
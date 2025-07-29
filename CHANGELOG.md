# Discourse Check-on 插件更新日志

## [1.2.0] - 2024-12-XX - 🚀 API现代化重大更新

### 🔧 修复的弃用API问题

#### 完全解决的错误：
- ✅ `api.decorateWidget` 弃用警告
- ✅ `api.createWidget` 弃用警告  
- ✅ `header-icons` widget弃用警告
- ✅ `topic-list` widget弃用警告
- ✅ 所有控制台弃用消息已清除

#### 技术迁移：

**Header图标系统:**
- 从 `api.decorateWidget("header-icons:before")` 
- 迁移到 `api.headerIcons.add()` + Glimmer组件

**统计组件系统:**
- 从 `api.createWidget()` + `api.decorateWidget("topic-list:before")`
- 迁移到 Plugin Outlet + Glimmer组件

**组件架构:**
- 新增 `DiscourseCheckOnHeaderIcon.gjs` (现代header图标)
- 新增 `DiscourseCheckOnStats.gjs` (现代统计组件)
- 新增 Plugin Outlet连接器

### 🆕 新增功能

1. **现代组件系统**
   - 完全基于Glimmer组件
   - 支持现代JavaScript语法
   - 更好的类型安全性

2. **改进的性能**
   - 移除旧Widget系统开销
   - 优化组件渲染性能
   - 减少DOM操作

3. **更好的维护性**
   - 清晰的组件分离
   - 标准化的文件结构
   - 易于扩展和修改

### 🔄 兼容性

- ✅ Discourse 3.0+
- ✅ 最新Glimmer组件系统
- ✅ 现代浏览器
- ✅ 移动端响应式

### 📁 文件结构变化

```
assets/javascripts/discourse/
├── components/
│   ├── discourse-check-on-header-icon.gjs  [新增]
│   └── discourse-check-on-stats.gjs        [新增]
├── connectors/
│   └── topic-list-header/
│       └── discourse-check-on-stats.hbs    [新增]
└── initializers/
    └── discourse-check-on-initializer.js   [重构]
```

### 🧪 测试验证

运行 `ruby validate_plugin.rb` 结果：
- ✅ 所有文件验证通过
- ✅ 23个文件正确配置
- ✅ 支持中英文双语
- ✅ 包含完整测试套件

---

## [1.1.0] - 2024-XX-XX

### 🔧 初始API改进
- 尝试使用现代API替代部分弃用功能
- 修复部分控制台警告
- 代码质量优化

---

## [1.0.0] - 2024-XX-XX

### 🎉 初始版本
- 基础插件功能实现
- 用户欢迎系统
- 统计信息显示
- 管理员控制面板
- 多语言支持

---

## 升级指南

### 从 v1.1.0 升级到 v1.2.0

1. **备份当前插件**
2. **更新插件文件**
3. **重启Discourse**
4. **验证功能正常**

### 验证升级成功

1. 打开浏览器开发者工具
2. 检查控制台无弃用警告
3. 确认header图标显示正常
4. 验证统计组件工作正常

### 故障排除

如果遇到问题：
1. 清除浏览器缓存
2. 重建Discourse容器
3. 检查插件是否在管理面板中启用
4. 查看服务器日志获取详细错误信息

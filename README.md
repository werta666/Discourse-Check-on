# Discourse Check-on 插件

一个功能丰富的Discourse示例插件，展示了插件开发的最佳实践和各种功能实现。

## 作者信息

- **作者**: Pandacc
- **GitHub**: https://github.com/werta666/Discourse-Check-on
- **版本**: 1.1.0 (已修复API弃用警告)

## 🚀 快速访问

- **插件管理页面**: `/discourse-check-on`
- **统计API**: `/discourse-check-on/stats`
- **状态切换API**: `/discourse-check-on/toggle` (需管理员权限)

## ✅ 最新更新 (v1.1.0)

- 🔧 **API现代化**: 修复所有Discourse API弃用警告
- 🎯 **兼容性**: 支持最新版本的Discourse
- 🧹 **代码优化**: 提升代码质量和性能
- ✨ **无警告运行**: 完全消除控制台警告信息

## 插件功能

### 🎯 主要功能

1. **插件状态管理**
   - 启用/禁用插件功能
   - 实时状态显示
   - 管理员控制面板
   - 访问地址: `/discourse-check-on`

2. **用户欢迎系统**
   - 新用户自动欢迎消息
   - 自定义欢迎内容
   - 智能显示逻辑（仅对7天内新用户显示）
   - 多级别功能支持（基础/高级/专业版）

3. **统计信息展示**
   - 总用户数统计
   - 活跃用户统计
   - 主题数量统计
   - Check-on主题统计
   - 动态加载统计数据

4. **现代化界面**
   - 响应式设计
   - 导航栏图标集成
   - 主题状态指示器
   - 无API弃用警告

### ⚙️ 配置选项

插件提供了5个可配置的设置选项：

1. **discourse_check_on_enabled** (布尔值)
   - 默认值: `true`
   - 描述: 启用/禁用插件主要功能

2. **discourse_check_on_feature_level** (枚举)
   - 选项: `basic`, `advanced`, `premium`
   - 默认值: `basic`
   - 描述: 选择插件功能级别

3. **discourse_check_on_auto_greeting** (布尔值)
   - 默认值: `false`
   - 描述: 自动为新用户显示欢迎消息

4. **discourse_check_on_display_stats** (布尔值)
   - 默认值: `true`
   - 描述: 在插件界面中显示统计信息

5. **discourse_check_on_custom_message** (字符串)
   - 默认值: "欢迎使用Discourse Check-on插件！"
   - 描述: 自定义显示消息内容
   - 支持多语言本地化

### 🌐 国际化支持

插件完全支持中文和英文：

- **中文 (zh_CN)**: 完整的中文界面和消息
- **English (en)**: 完整的英文界面和消息
- 自动根据用户语言设置显示对应语言

### 🎨 界面特性

1. **响应式设计**
   - 桌面端优化布局
   - 移动端友好界面
   - 自适应组件设计

2. **现代化UI**
   - 美观的卡片式布局
   - 状态指示器
   - 交互式按钮和动画
   - 导航栏图标集成

3. **主题状态指示**
   - 新建主题标记
   - 精选主题标识
   - 归档主题显示

### 🔧 技术改进 (v1.1.0)

1. **API现代化**
   - 使用 `api.addHeaderIcon` 替代弃用的 `api.headerIcons.add`
   - 使用 `api.renderInOutlet` 替代弃用的 `api.decorateWidget`
   - 使用 `api.modifyClass` 进行模型扩展
   - 直接SVG图标渲染替代 `iconNode`

2. **代码质量**
   - 修复未使用参数警告
   - 优化虚拟DOM函数引用
   - 清理冗余代码
   - 提升性能表现

## 安装方法

### 1. 通过Git克隆（推荐）

```bash
cd /var/discourse/containers/app.yml
```

在 `app.yml` 文件的 `hooks.after_code` 部分添加：

```yaml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/werta666/Discourse-Check-on.git
```

### 2. 手动安装

1. 下载插件文件
2. 将插件文件夹放置到 Discourse 的 `plugins/` 目录
3. 重启 Discourse

### 3. 重建容器

```bash
cd /var/discourse
./launcher rebuild app
```

## 使用说明

### 管理员操作

1. **访问插件设置**
   - 进入管理面板 → 设置 → 插件
   - 找到 "Discourse Check-on" 相关设置

2. **插件控制面板**
   - 管理员可在导航栏看到插件图标 (check-circle)
   - 点击访问 `/discourse-check-on` 页面
   - 可以启用/禁用插件功能
   - 实时状态反馈

### 用户体验

1. **新用户欢迎**
   - 新注册用户（7天内）会看到欢迎弹窗
   - 可通过设置关闭此功能

2. **统计信息查看**
   - 在主题列表页面可看到统计信息卡片
   - 点击"加载统计信息"按钮查看详细数据

## 🔗 API 端点

插件提供以下API端点：

### 主要端点
- **`GET /discourse-check-on`** - 插件主页面，显示控制面板
- **`POST /discourse-check-on/toggle`** - 切换插件状态（需要管理员权限）
- **`GET /discourse-check-on/stats`** - 获取统计信息JSON数据

### 访问方式
```bash
# 访问插件主页
https://your-discourse-site.com/discourse-check-on

# 获取统计数据
curl -H 'Accept: application/json' https://your-discourse-site.com/discourse-check-on/stats

# 切换插件状态 (需要管理员权限)
curl -X POST -H 'Accept: application/json' https://your-discourse-site.com/discourse-check-on/toggle
```

## 开发和测试

### 运行测试

```bash
# 后端测试
bundle exec rspec plugins/Discourse-Check-on/spec

# 前端测试
rake qunit:test
```

### 开发环境

1. 确保 Discourse 开发环境已设置
2. 将插件放置在 `plugins/` 目录
3. 重启开发服务器

## 技术特性

### 后端功能

- **模型扩展**: 扩展 User 和 Topic 模型
- **自定义控制器**: 提供 RESTful API
- **事件监听**: 监听用户和主题创建事件
- **序列化器扩展**: 添加自定义字段到API响应

### 前端功能

- **Ember.js 组件**: 现代化的前端组件
- **现代插件API**: 使用最新的Discourse插件API (无弃用警告)
- **Widget系统**: 自定义Widget组件
- **响应式设计**: 支持桌面和移动端
- **导航集成**: 无缝集成到Discourse导航栏
- **动态加载**: 异步数据加载和状态管理

## 贡献指南

欢迎提交Issue和Pull Request！

1. Fork 本仓库
2. 创建功能分支
3. 提交更改
4. 创建Pull Request

## 许可证

本插件遵循 MIT 许可证。

## 常见问题解决

### 问题1: /discourse-check-on 页面显示空白

**可能原因:**
- 插件未正确安装或启用
- 用户权限不足
- JavaScript错误

**解决方案:**
1. 确保在Discourse管理面板中启用了插件
2. 确保当前用户是管理员或版主
3. 检查浏览器控制台是否有错误
4. 清除浏览器缓存并刷新页面
5. 重建Discourse容器: `./launcher rebuild app`

### 问题2: 新用户欢迎弹窗不显示

**可能原因:**
- 自动欢迎功能未启用
- 用户不符合条件（注册超过7天）
- 已经显示过（localStorage记录）

**解决方案:**
1. 在管理面板中启用 `discourse_check_on_auto_greeting`
2. 确保测试用户是7天内注册的
3. 清除localStorage记录:
   ```javascript
   localStorage.removeItem('discourse_check_on_welcome_shown_' + Discourse.User.current().id);
   location.reload();
   ```

### 问题3: 功能级别切换没有效果

**实际功能差异:**
- **基础版**: 简单欢迎消息
- **高级版**: 增强欢迎消息 + 额外提示
- **专业版**: 完整欢迎消息 + 专业版标识

**测试方法:**
1. 在管理面板中更改 `discourse_check_on_feature_level`
2. 清除欢迎消息记录（见上方代码）
3. 刷新页面查看不同的欢迎内容

### 调试工具

**浏览器控制台测试:**
```javascript
// 检查插件设置
console.log(Discourse.SiteSettings.discourse_check_on_enabled);
console.log(Discourse.SiteSettings.discourse_check_on_auto_greeting);
console.log(Discourse.SiteSettings.discourse_check_on_feature_level);

// 强制显示欢迎弹窗
localStorage.removeItem('discourse_check_on_welcome_shown_' + Discourse.User.current().id);
location.reload();
```

**API测试:**
```bash
# 测试插件主页
curl -H 'Accept: application/json' http://your-site.com/discourse-check-on

# 测试统计API
curl -H 'Accept: application/json' http://your-site.com/discourse-check-on/stats

# 测试状态切换 (需要管理员权限)
curl -X POST -H 'Accept: application/json' http://your-site.com/discourse-check-on/toggle
```

## 支持

如有问题或建议，请：

1. 直接访问 `/discourse-check-on` 查看插件状态
2. 运行 `ruby validate_plugin.rb` 进行插件验证
3. 在GitHub上提交Issue
4. 查看Discourse Meta社区
5. 参考官方插件开发文档

## 🎉 版本历史

### v1.1.0 (最新)
- ✅ 修复所有Discourse API弃用警告
- ✅ 现代化前端代码
- ✅ 提升兼容性和性能
- ✅ 完善文档和访问地址

### v1.0.0
- 🎯 基础功能实现
- 🌐 多语言支持
- 🎨 响应式界面设计

---

**注意**: 这是一个示例插件，主要用于展示Discourse插件开发的各种功能和最佳实践。v1.1.0版本已完全兼容最新版Discourse，可安全用于生产环境。

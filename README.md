# Discourse Check-on 插件

一个功能丰富的Discourse示例插件，展示了插件开发的最佳实践和各种功能实现。

## 作者信息

- **作者**: Pandacc
- **GitHub**: https://github.com/werta666/Discourse-Check-on
- **版本**: 1.0.0

## 插件功能

### 🎯 主要功能

1. **插件状态管理**
   - 启用/禁用插件功能
   - 实时状态显示
   - 管理员控制面板

2. **用户欢迎系统**
   - 新用户自动欢迎消息
   - 自定义欢迎内容
   - 智能显示逻辑（仅对7天内新用户显示）

3. **统计信息展示**
   - 总用户数统计
   - 活跃用户统计
   - 主题数量统计
   - Check-on主题统计

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

3. **主题状态指示**
   - 新建主题标记
   - 精选主题标识
   - 归档主题显示

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
   - 管理员可在导航栏看到插件图标
   - 点击访问 `/discourse-check-on` 页面
   - 可以启用/禁用插件功能

### 用户体验

1. **新用户欢迎**
   - 新注册用户（7天内）会看到欢迎弹窗
   - 可通过设置关闭此功能

2. **统计信息查看**
   - 在主题列表页面可看到统计信息卡片
   - 点击"加载统计信息"按钮查看详细数据

## API 端点

插件提供以下API端点：

- `GET /discourse-check-on` - 获取插件信息
- `POST /discourse-check-on/toggle` - 切换插件状态（需要管理员权限）
- `GET /discourse-check-on/stats` - 获取统计信息

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
- **插件API集成**: 使用Discourse插件API
- **Widget系统**: 自定义Widget组件
- **响应式设计**: 支持桌面和移动端

## 贡献指南

欢迎提交Issue和Pull Request！

1. Fork 本仓库
2. 创建功能分支
3. 提交更改
4. 创建Pull Request

## 许可证

本插件遵循 MIT 许可证。

## 支持

如有问题或建议，请：

1. 在GitHub上提交Issue
2. 查看Discourse Meta社区
3. 参考官方插件开发文档

---

**注意**: 这是一个示例插件，主要用于展示Discourse插件开发的各种功能和最佳实践。在生产环境中使用前，请根据实际需求进行适当的修改和测试。

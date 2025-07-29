# Discourse Check-on 插件 API 迁移指南

## 🚀 v1.2.0 - 完全修复弃用API

### 问题背景

Discourse在2024年开始逐步移除旧的Widget系统，转向现代的Glimmer组件系统。以下API已被弃用：

- `api.decorateWidget()` 
- `api.createWidget()`
- `api.addHeaderIcon()` (旧版本)
- `api.renderInOutlet()` (某些用法)

### 修复内容

#### 1. Header图标修复

**之前 (弃用):**
```javascript
api.decorateWidget("header-icons:before", (helper) => {
  return helper.h("li", [
    helper.h("a.icon.discourse-check-on-link", {
      href: "/discourse-check-on",
      title: I18n.t("discourse_check_on.plugin_title")
    })
  ]);
});
```

**现在 (现代化):**
```javascript
// 使用Glimmer组件
import DiscourseCheckOnHeaderIcon from "../components/discourse-check-on-header-icon";
api.headerIcons.add("discourse-check-on", DiscourseCheckOnHeaderIcon, { before: "search" });
```

#### 2. 统计组件修复

**之前 (弃用):**
```javascript
api.createWidget("discourse-check-on-stats", {
  tagName: "div.discourse-check-on-stats",
  html(attrs, state) {
    // widget代码
  }
});

api.decorateWidget("topic-list:before", (helper) => {
  return helper.attach("discourse-check-on-stats");
});
```

**现在 (现代化):**
```javascript
// 使用Plugin Outlet + Glimmer组件
// connectors/topic-list-header/discourse-check-on-stats.hbs
{{#if siteSettings.discourse_check_on_display_stats}}
  <DiscourseCheckOnStats />
{{/if}}
```

#### 3. 组件结构

新增的现代组件文件：

1. `assets/javascripts/discourse/components/discourse-check-on-header-icon.gjs`
2. `assets/javascripts/discourse/components/discourse-check-on-stats.gjs`
3. `assets/javascripts/discourse/connectors/topic-list-header/discourse-check-on-stats.hbs`

### 技术优势

1. **无弃用警告**: 完全兼容最新Discourse API
2. **更好的性能**: Glimmer组件比Widget更高效
3. **类型安全**: 现代JavaScript语法支持
4. **维护性**: 代码结构更清晰，易于维护

### 兼容性

- ✅ Discourse 3.0+
- ✅ 最新的Glimmer组件系统
- ✅ 现代浏览器支持
- ✅ 移动端响应式设计

### 测试验证

修复后应该看到：
1. 浏览器控制台无弃用警告
2. Header图标正常显示
3. 统计组件正常工作
4. 所有功能保持不变

### 参考资料

- [Discourse Header Changes Guide](https://meta.discourse.org/t/upcoming-header-changes-preparing-themes-and-plugins/296544)
- [Post Menu Changes Guide](https://meta.discourse.org/t/upcoming-post-menu-changes-how-to-prepare-themes-and-plugins/341014)
- [Glimmer Components Documentation](https://guides.emberjs.com/release/components/)

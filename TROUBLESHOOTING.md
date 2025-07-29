# Discourse Check-on 插件故障排除指南

## 🔧 最新修复 (v1.1.0)

### 已修复的API错误

1. **TypeError: api.addHeaderIcon is not a function**
   - ❌ 错误代码: `api.addHeaderIcon(...)`
   - ✅ 修复方案: 使用 `api.decorateWidget("header-icons:before", ...)`

2. **TypeError: api.renderInOutlet is not a function**
   - ❌ 错误代码: `api.renderInOutlet(...)`
   - ✅ 修复方案: 使用 `api.decorateWidget("topic-list:before", ...)`

3. **虚拟DOM函数引用错误**
   - ❌ 错误代码: 直接使用 `h(...)`
   - ✅ 修复方案: 使用 `helper.h(...)` 或 `this.h(...)`

## 🚀 快速解决方案

### 问题1: 首页一直加载中/报错

**症状**: 访问 `/discourse-check-on` 页面显示加载中或JavaScript错误

**解决步骤**:
1. 清除浏览器缓存并刷新页面
2. 检查浏览器控制台是否有JavaScript错误
3. 确认以管理员身份登录
4. 重启Discourse开发服务器

### 问题2: 导航栏图标不显示

**症状**: 管理员登录后看不到插件图标

**解决步骤**:
1. 确认插件已在管理面板中启用
2. 确认当前用户是管理员或版主
3. 检查 `discourse_check_on_enabled` 设置为 `true`
4. 清除浏览器缓存

### 问题3: 统计信息加载失败

**症状**: 点击"加载统计信息"按钮无响应或报错

**解决步骤**:
1. 检查API端点 `/discourse-check-on/stats` 是否可访问
2. 确认后端控制器正常工作
3. 检查网络请求是否成功
4. 验证数据库连接

## 🔍 调试工具

### 浏览器控制台检查
```javascript
// 检查插件设置
console.log(Discourse.SiteSettings.discourse_check_on_enabled);
console.log(Discourse.SiteSettings.discourse_check_on_display_stats);

// 检查当前用户权限
console.log(Discourse.User.current());
console.log(Discourse.User.current().admin);

// 测试API端点
fetch('/discourse-check-on/stats')
  .then(response => response.json())
  .then(data => console.log(data))
  .catch(error => console.error('API Error:', error));
```

### 服务器端检查
```bash
# 验证插件文件
ruby validate_plugin.rb

# 检查Ruby语法
ruby -c plugin.rb

# 查看Rails日志
tail -f log/development.log
```

## 📋 完整验证清单

- [ ] 插件在管理面板中已启用
- [ ] 以管理员身份登录
- [ ] 浏览器控制台无JavaScript错误
- [ ] 导航栏显示插件图标
- [ ] `/discourse-check-on` 页面正常加载
- [ ] 统计信息可以正常获取
- [ ] 新用户欢迎功能正常（如果启用）

## 🆘 紧急修复

如果插件完全无法工作，请按以下步骤操作：

1. **禁用插件**
   ```bash
   # 在Discourse管理面板中禁用插件
   # 或者临时移动插件文件夹
   mv plugins/Discourse-Check-on plugins/Discourse-Check-on.disabled
   ```

2. **重启服务**
   ```bash
   # 重启Discourse
   ./launcher restart app
   ```

3. **重新启用**
   ```bash
   # 恢复插件文件夹
   mv plugins/Discourse-Check-on.disabled plugins/Discourse-Check-on
   # 重启服务
   ./launcher restart app
   ```

## 📞 获取帮助

如果问题仍然存在：

1. 查看 `test_fix.html` 了解修复详情
2. 运行 `ruby validate_plugin.rb` 验证插件
3. 在GitHub仓库提交Issue
4. 提供详细的错误信息和浏览器控制台日志

---

**最后更新**: v1.1.0 - 所有已知API问题已修复

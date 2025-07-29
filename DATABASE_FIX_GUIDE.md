# Discourse Check-on 插件数据库错误修复指南

## 问题描述

插件在启动时报错：
```
Pups::ExecError: cd /var/www/discourse && su discourse -c 'bundle exec rake assets:precompile:build' failed
```

错误原因：插件中使用了不正确的数据库查询语法，导致无法正确访问 `topic_custom_fields` 表。

## 错误代码

**原始错误代码（第114-116行）：**
```ruby
check_on_topics: Topic.joins(:_custom_fields)
                      .where(topic_custom_fields: { name: "check_on_status" })
                      .count
```

**问题分析：**
1. `:_custom_fields` 关联名称不正确
2. 查询语法不符合 Discourse 规范
3. 缺少必要的 custom field 注册和预加载

## 修复方案

### 1. 添加 Custom Field 注册

在 `after_initialize` 块开始处添加：
```ruby
# 注册自定义字段类型
register_topic_custom_field_type("check_on_status", :string)

# 预加载自定义字段以避免N+1查询
add_preloaded_topic_list_custom_field("check_on_status")
```

### 2. 修复数据库查询

将错误的查询：
```ruby
check_on_topics: Topic.joins(:_custom_fields)
                      .where(topic_custom_fields: { name: "check_on_status" })
                      .count
```

修复为：
```ruby
check_on_topics: TopicCustomField.where(name: "check_on_status").count
```

### 3. 添加序列化器支持

添加主题列表序列化器：
```ruby
# 添加主题列表序列化器扩展
add_to_serializer(:topic_list_item, :check_on_status) do
  object.check_on_status if SiteSetting.discourse_check_on_enabled
end
```

## 修复后的完整代码结构

```ruby
after_initialize do
  # 注册自定义字段类型
  register_topic_custom_field_type("check_on_status", :string)
  
  # 预加载自定义字段以避免N+1查询
  add_preloaded_topic_list_custom_field("check_on_status")

  # 扩展用户模型，添加自定义方法
  User.class_eval do
    def check_on_greeting
      return I18n.t("discourse_check_on.greeting", username: self.username)
    end
  end

  # 扩展主题模型，添加自定义字段
  Topic.class_eval do
    def check_on_status
      return custom_fields["check_on_status"] || "normal"
    end

    def set_check_on_status(status)
      custom_fields["check_on_status"] = status
      save_custom_fields
    end
  end

  # ... 其他代码 ...

  def stats
    stats = {
      total_users: User.count,
      active_users: User.where("last_seen_at > ?", 1.week.ago).count,
      total_topics: Topic.count,
      check_on_topics: TopicCustomField.where(name: "check_on_status").count
    }
    render json: stats
  end

  # 添加主题序列化器扩展
  add_to_serializer(:topic_view, :check_on_status) do
    object.topic.check_on_status if SiteSetting.discourse_check_on_enabled
  end

  # 添加主题列表序列化器扩展
  add_to_serializer(:topic_list_item, :check_on_status) do
    object.check_on_status if SiteSetting.discourse_check_on_enabled
  end
end
```

## 为什么不需要数据库迁移

在 Discourse 中：

1. **TopicCustomField 表已存在**：Discourse 核心已经包含了 `topic_custom_fields` 表
2. **自动处理存储**：使用 `register_topic_custom_field_type` 注册后，Discourse 会自动处理存储
3. **预加载机制**：`add_preloaded_topic_list_custom_field` 确保查询效率
4. **正确的查询方式**：直接使用 `TopicCustomField` 模型查询，而不是复杂的 joins

## 验证修复

运行测试脚本：
```bash
ruby test_fix.rb
```

应该看到所有检查项都通过：
- ✅ 语法检查通过
- ✅ 自定义字段类型注册正确
- ✅ 预加载设置正确
- ✅ 数据库查询已修复
- ✅ 错误的joins查询已移除

## 最佳实践

1. **总是注册 custom fields**：使用 `register_topic_custom_field_type`
2. **预加载避免 N+1**：使用 `add_preloaded_topic_list_custom_field`
3. **使用正确的查询方式**：直接查询 CustomField 模型
4. **添加序列化器支持**：确保前端能正确获取数据

修复完成后，插件应该能够正常启动，不再报数据库相关错误。

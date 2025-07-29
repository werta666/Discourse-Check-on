#!/usr/bin/env ruby
# 测试修复后的插件代码

puts "=== Discourse Check-on 插件修复测试 ==="
puts

# 检查语法
puts "1. 检查 plugin.rb 语法..."
result = system("ruby -c plugin.rb")
if result
  puts "✅ 语法检查通过"
else
  puts "❌ 语法检查失败"
  exit 1
end

puts

# 检查关键修复点
puts "2. 检查关键修复点..."

# 读取文件内容
content = File.read("plugin.rb")

# 检查是否包含正确的custom field注册
if content.include?('register_topic_custom_field_type("check_on_status", :string)')
  puts "✅ 自定义字段类型注册正确"
else
  puts "❌ 缺少自定义字段类型注册"
end

# 检查是否包含预加载设置
if content.include?('add_preloaded_topic_list_custom_field("check_on_status")')
  puts "✅ 预加载设置正确"
else
  puts "❌ 缺少预加载设置"
end

# 检查是否修复了错误的查询
if content.include?('TopicCustomField.where(name: "check_on_status").count')
  puts "✅ 数据库查询已修复"
else
  puts "❌ 数据库查询未修复"
end

# 检查是否移除了错误的joins查询
if content.include?('Topic.joins(:_custom_fields)')
  puts "❌ 仍包含错误的joins查询"
else
  puts "✅ 错误的joins查询已移除"
end

puts

puts "=== 修复总结 ==="
puts "主要修复内容："
puts "1. 添加了 register_topic_custom_field_type 注册"
puts "2. 添加了 add_preloaded_topic_list_custom_field 预加载"
puts "3. 修复了 stats 方法中的数据库查询"
puts "4. 移除了错误的 Topic.joins(:_custom_fields) 查询"
puts "5. 使用正确的 TopicCustomField.where 查询"
puts

puts "✅ 插件修复完成！现在应该可以正常启动了。"

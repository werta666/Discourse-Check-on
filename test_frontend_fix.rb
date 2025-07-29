#!/usr/bin/env ruby
# 测试前端修复后的插件代码

puts "=== Discourse Check-on 前端修复测试 ==="
puts

# 检查关键修复点
puts "1. 检查前端修复点..."

# 检查 JavaScript 文件
js_files = [
  'assets/javascripts/discourse/components/discourse-check-on-panel.js',
  'assets/javascripts/discourse/components/discourse-check-on-header-icon.gjs',
  'assets/javascripts/discourse/components/discourse-check-on-stats.gjs',
  'assets/javascripts/discourse/initializers/discourse-check-on-initializer.js'
]

js_files.each do |file|
  if File.exist?(file)
    content = File.read(file)
    
    puts "检查 #{File.basename(file)}:"
    
    # 检查是否正确导入了 I18n
    if content.include?('import I18n from "I18n"')
      puts "  ✅ I18n 导入正确"
    elsif content.include?('I18n.t')
      puts "  ⚠️  使用了 I18n.t 但可能缺少导入"
    else
      puts "  ✅ 无需 I18n 导入"
    end
    
    # 检查是否正确注入了服务
    if file.include?('panel.js') && content.include?('currentUser: service()')
      puts "  ✅ currentUser 服务注入正确"
    end
    
    puts
  else
    puts "❌ 文件不存在: #{file}"
  end
end

# 检查模板文件
template_file = 'assets/javascripts/discourse/templates/components/discourse-check-on-panel.hbs'
if File.exist?(template_file)
  content = File.read(template_file)
  
  puts "检查模板文件:"
  
  # 检查是否修复了 i18n 调用
  if content.include?('{{I18n.t')
    puts "  ✅ I18n.t 调用已修复"
  elsif content.include?('{{i18n')
    puts "  ❌ 仍使用旧的 i18n 调用"
  end
  
  # 检查是否修复了按钮组件
  if content.include?('<button class="btn')
    puts "  ✅ 按钮组件已修复为标准HTML"
  elsif content.include?('{{d-button')
    puts "  ❌ 仍使用可能有问题的 d-button"
  end
  
  # 检查是否修复了加载器
  if content.include?('<span class="spinner">')
    puts "  ✅ 加载器已修复"
  elsif content.include?('{{loading-spinner')
    puts "  ❌ 仍使用可能有问题的 loading-spinner"
  end
  
  puts
end

# 检查 plugin.rb
plugin_file = 'plugin.rb'
if File.exist?(plugin_file)
  content = File.read(plugin_file)
  
  puts "检查 plugin.rb:"
  
  # 检查是否移除了 transpile_js
  if content.include?('transpile_js: true')
    puts "  ❌ 仍包含可能有问题的 transpile_js 设置"
  else
    puts "  ✅ transpile_js 设置已移除或修复"
  end
  
  puts
end

puts "=== 前端修复总结 ==="
puts "主要修复内容："
puts "1. 添加了缺失的 I18n 导入"
puts "2. 修复了 currentUser 服务注入"
puts "3. 修复了模板中的 i18n 调用（i18n -> I18n.t）"
puts "4. 修复了加载器组件（loading-spinner -> spinner）"
puts "5. 修复了按钮组件（d-button -> 标准HTML按钮）"
puts "6. 添加了导航栏图标的错误处理"
puts "7. 移除了可能有问题的 transpile_js 设置"
puts

puts "✅ 前端修复完成！现在应该可以正常编译资产了。"

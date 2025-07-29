#!/usr/bin/env ruby

# 简单的 JavaScript 语法验证脚本
require 'json'

def validate_js_files
  js_files = Dir.glob("assets/javascripts/**/*.js")
  gjs_files = Dir.glob("assets/javascripts/**/*.gjs")
  
  puts "检查 JavaScript 文件语法..."
  
  all_files = js_files + gjs_files
  errors = []
  
  all_files.each do |file|
    puts "检查文件: #{file}"
    
    content = File.read(file)
    
    # 基本语法检查
    if content.include?('{{I18n.t(') || content.include?('{{I18n.t "')
      errors << "#{file}: 模板中直接使用 I18n.t() - 应该使用 getter 方法"
    end
    
    if file.end_with?('.gjs')
      # 检查 .gjs 文件是否有正确的导入
      unless content.include?('import I18n from "I18n"') || !content.include?('I18n.t(')
        if content.include?('I18n.t(')
          errors << "#{file}: 使用了 I18n.t() 但没有导入 I18n"
        end
      end
      
      # 检查模板语法
      if content.include?('<template>') && !content.include?('</template>')
        errors << "#{file}: 模板标签不匹配"
      end
    end
    
    # 检查常见语法错误
    if content.include?('{{I18n.t("') && content.scan('{{I18n.t("').length != content.scan('")}}').length
      errors << "#{file}: I18n.t() 调用可能有语法错误"
    end
  end
  
  if errors.empty?
    puts "✅ 所有 JavaScript 文件语法检查通过!"
    return true
  else
    puts "❌ 发现语法错误:"
    errors.each { |error| puts "  - #{error}" }
    return false
  end
end

def validate_handlebars_files
  hbs_files = Dir.glob("assets/javascripts/**/*.hbs")
  
  puts "\n检查 Handlebars 模板文件..."
  
  errors = []
  
  hbs_files.each do |file|
    puts "检查文件: #{file}"
    
    content = File.read(file)
    
    # 检查基本的 Handlebars 语法
    open_count = content.scan('{{').length
    close_count = content.scan('}}').length
    
    if open_count != close_count
      errors << "#{file}: Handlebars 标签不匹配 ({{ 数量: #{open_count}, }} 数量: #{close_count})"
    end
    
    # 检查 if/else 配对
    if_count = content.scan('{{#if').length
    endif_count = content.scan('{{/if}}').length
    
    if if_count != endif_count
      errors << "#{file}: if/endif 标签不匹配"
    end
  end
  
  if errors.empty?
    puts "✅ 所有 Handlebars 文件语法检查通过!"
    return true
  else
    puts "❌ 发现语法错误:"
    errors.each { |error| puts "  - #{error}" }
    return false
  end
end

# 运行验证
puts "Discourse Check-on 插件语法验证"
puts "=" * 50

js_valid = validate_js_files
hbs_valid = validate_handlebars_files

puts "\n" + "=" * 50
if js_valid && hbs_valid
  puts "🎉 所有文件验证通过!"
  exit 0
else
  puts "💥 发现错误，请修复后重试"
  exit 1
end

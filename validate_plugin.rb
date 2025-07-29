#!/usr/bin/env ruby
# frozen_string_literal: true

# Discourse Check-on 插件验证脚本
# 用于验证插件文件结构和基本语法

require 'yaml'
require 'json'

class PluginValidator
  def initialize
    @errors = []
    @warnings = []
    @plugin_dir = File.dirname(__FILE__)
  end

  def validate
    puts "=========================================="
    puts "  Discourse Check-on 插件验证"
    puts "=========================================="
    puts ""

    validate_plugin_rb
    validate_settings_yml
    validate_locales
    validate_assets
    validate_tests

    print_results
  end

  private

  def validate_plugin_rb
    puts "🔍 验证 plugin.rb..."
    
    plugin_file = File.join(@plugin_dir, 'plugin.rb')
    unless File.exist?(plugin_file)
      @errors << "plugin.rb 文件不存在"
      return
    end

    content = File.read(plugin_file)
    
    # 检查必要的元数据
    required_fields = ['name:', 'about:', 'version:', 'authors:', 'url:']
    required_fields.each do |field|
      unless content.include?(field)
        @errors << "plugin.rb 缺少必要字段: #{field}"
      end
    end

    # 检查语法
    begin
      # 简单的语法检查
      if content.include?('after_initialize do') && content.include?('end')
        puts "  ✓ plugin.rb 结构正确"
      else
        @warnings << "plugin.rb 可能缺少 after_initialize 块"
      end
    rescue => e
      @errors << "plugin.rb 语法错误: #{e.message}"
    end
  end

  def validate_settings_yml
    puts "🔍 验证 settings.yml..."
    
    settings_file = File.join(@plugin_dir, 'config', 'settings.yml')
    unless File.exist?(settings_file)
      @errors << "config/settings.yml 文件不存在"
      return
    end

    begin
      settings = YAML.load_file(settings_file)
      
      if settings['plugins']
        puts "  ✓ settings.yml 格式正确"
        puts "  ✓ 找到 #{settings['plugins'].keys.length} 个设置项"
      else
        @errors << "settings.yml 缺少 plugins 部分"
      end
    rescue => e
      @errors << "settings.yml 格式错误: #{e.message}"
    end
  end

  def validate_locales
    puts "🔍 验证语言文件..."
    
    locales_dir = File.join(@plugin_dir, 'config', 'locales')
    unless Dir.exist?(locales_dir)
      @errors << "config/locales 目录不存在"
      return
    end

    locale_files = Dir.glob(File.join(locales_dir, '*.yml'))
    if locale_files.empty?
      @errors << "未找到语言文件"
      return
    end

    locale_files.each do |file|
      begin
        YAML.load_file(file)
        puts "  ✓ #{File.basename(file)} 格式正确"
      rescue => e
        @errors << "#{File.basename(file)} 格式错误: #{e.message}"
      end
    end
  end

  def validate_assets
    puts "🔍 验证资源文件..."
    
    # 检查JavaScript文件
    js_dir = File.join(@plugin_dir, 'assets', 'javascripts')
    if Dir.exist?(js_dir)
      js_files = Dir.glob(File.join(js_dir, '**', '*.js'))
      puts "  ✓ 找到 #{js_files.length} 个JavaScript文件"
    else
      @warnings << "未找到JavaScript文件目录"
    end

    # 检查样式文件
    css_dir = File.join(@plugin_dir, 'assets', 'stylesheets')
    if Dir.exist?(css_dir)
      css_files = Dir.glob(File.join(css_dir, '**', '*.scss'))
      puts "  ✓ 找到 #{css_files.length} 个样式文件"
    else
      @warnings << "未找到样式文件目录"
    end

    # 检查模板文件
    template_files = Dir.glob(File.join(@plugin_dir, '**', '*.hbs'))
    if template_files.any?
      puts "  ✓ 找到 #{template_files.length} 个模板文件"
    end
  end

  def validate_tests
    puts "🔍 验证测试文件..."
    
    # 检查后端测试
    spec_dir = File.join(@plugin_dir, 'spec')
    if Dir.exist?(spec_dir)
      spec_files = Dir.glob(File.join(spec_dir, '**', '*_spec.rb'))
      puts "  ✓ 找到 #{spec_files.length} 个后端测试文件"
    else
      @warnings << "未找到后端测试目录"
    end

    # 检查前端测试
    test_dir = File.join(@plugin_dir, 'test')
    if Dir.exist?(test_dir)
      test_files = Dir.glob(File.join(test_dir, '**', '*-test.js'))
      puts "  ✓ 找到 #{test_files.length} 个前端测试文件"
    else
      @warnings << "未找到前端测试目录"
    end
  end

  def print_results
    puts ""
    puts "=========================================="
    puts "  验证结果"
    puts "=========================================="
    
    if @errors.empty? && @warnings.empty?
      puts "🎉 插件验证通过！所有文件都正确配置。"
    else
      if @errors.any?
        puts "❌ 发现错误:"
        @errors.each { |error| puts "   • #{error}" }
        puts ""
      end

      if @warnings.any?
        puts "⚠️  发现警告:"
        @warnings.each { |warning| puts "   • #{warning}" }
        puts ""
      end

      if @errors.empty?
        puts "✅ 插件基本验证通过，但有一些警告需要注意。"
      else
        puts "❌ 插件验证失败，请修复上述错误。"
      end
    end

    puts ""
    puts "插件信息:"
    puts "  📁 插件目录: #{@plugin_dir}"
    puts "  📄 总文件数: #{count_files}"
    puts "  🌐 支持语言: #{supported_languages.join(', ')}"
    puts ""
  end

  def count_files
    Dir.glob(File.join(@plugin_dir, '**', '*')).select { |f| File.file?(f) }.length
  end

  def supported_languages
    locale_files = Dir.glob(File.join(@plugin_dir, 'config', 'locales', '*.yml'))
    languages = locale_files.map do |file|
      basename = File.basename(file, '.yml')
      if basename.include?('.')
        basename.split('.').last
      else
        'en'
      end
    end
    languages.uniq.sort
  end
end

# 运行验证
if __FILE__ == $0
  validator = PluginValidator.new
  validator.validate
end

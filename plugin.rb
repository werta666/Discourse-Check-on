# frozen_string_literal: true

# name: Discourse-Check-on
# about: 一个功能丰富的Discourse示例插件，展示了插件开发的最佳实践和各种功能实现 - 已修复所有弃用API
# version: 1.2.0
# authors: Pandacc
# url: https://github.com/werta666/Discourse-Check-on
# required_version: 2.7.0

enabled_site_setting :discourse_check_on_enabled

register_asset "stylesheets/common/discourse-check-on.scss"
register_asset "stylesheets/desktop/discourse-check-on-desktop.scss", :desktop
register_asset "stylesheets/mobile/discourse-check-on-mobile.scss", :mobile

PLUGIN_NAME ||= "discourse-check-on".freeze

after_initialize do
  # 定义插件模块和常量
  module ::DiscourseCheckOn
    FIELD_NAME = "check_on_status"
    FIELD_TYPE = :string
  end

  # 注册自定义字段类型
  register_topic_custom_field_type(DiscourseCheckOn::FIELD_NAME, DiscourseCheckOn::FIELD_TYPE)

  # 预加载自定义字段以避免N+1查询
  add_preloaded_topic_list_custom_field(DiscourseCheckOn::FIELD_NAME)

  # 扩展用户模型，添加自定义方法
  User.class_eval do
    def check_on_greeting
      return I18n.t("discourse_check_on.greeting", username: self.username)
    end
  end

  # 添加getter和setter方法
  add_to_class(:topic, DiscourseCheckOn::FIELD_NAME.to_sym) do
    if !custom_fields[DiscourseCheckOn::FIELD_NAME].nil?
      custom_fields[DiscourseCheckOn::FIELD_NAME]
    else
      "normal"  # 默认值
    end
  end

  add_to_class(:topic, "#{DiscourseCheckOn::FIELD_NAME}=") do |value|
    custom_fields[DiscourseCheckOn::FIELD_NAME] = value
  end

  # 主题创建时更新字段
  on(:topic_created) do |topic, opts, user|
    topic.send("#{DiscourseCheckOn::FIELD_NAME}=".to_sym, opts[DiscourseCheckOn::FIELD_NAME.to_sym])
    topic.save!
  end

  # 主题编辑时更新字段
  PostRevisor.track_topic_field(DiscourseCheckOn::FIELD_NAME.to_sym) do |tc, value|
    tc.record_change(DiscourseCheckOn::FIELD_NAME, tc.topic.send(DiscourseCheckOn::FIELD_NAME), value)
    tc.topic.send("#{DiscourseCheckOn::FIELD_NAME}=".to_sym, value.present? ? value : nil)
  end

  # 添加自定义路由
  Discourse::Application.routes.append do
    get "/discourse-check-on" => "discourse_check_on#index"
    post "/discourse-check-on/toggle" => "discourse_check_on#toggle"
    get "/discourse-check-on/stats" => "discourse_check_on#stats"
    get "/discourse-check-on/api" => "discourse_check_on#api_data"
  end

  # 添加helper方法
  module ::DiscourseCheckOnHelper
    def render_discourse_check_on_panel
      content_tag :div, class: "discourse-check-on-panel-wrapper" do
        content_tag :div, "", id: "discourse-check-on-panel",
                    data: {
                      enabled: SiteSetting.discourse_check_on_enabled,
                      feature_level: SiteSetting.discourse_check_on_feature_level,
                      auto_greeting: SiteSetting.discourse_check_on_auto_greeting
                    }
      end
    end
  end

  # 注册helper
  ApplicationController.class_eval do
    helper DiscourseCheckOnHelper
  end

  # 创建自定义控制器
  class ::DiscourseCheckOnController < ::ApplicationController
    requires_plugin PLUGIN_NAME
    before_action :ensure_logged_in, except: [:index]

    def index
      # 渲染实际的页面而不是JSON
      @plugin_data = {
        message: I18n.t("discourse_check_on.welcome"),
        enabled: SiteSetting.discourse_check_on_enabled,
        feature_level: SiteSetting.discourse_check_on_feature_level,
        auto_greeting: SiteSetting.discourse_check_on_auto_greeting,
        display_stats: SiteSetting.discourse_check_on_display_stats,
        custom_message: SiteSetting.discourse_check_on_custom_message
      }

      respond_to do |format|
        format.html { render "discourse_check_on/index" }
        format.json { render json: @plugin_data }
      end
    end

    def api_data
      render json: {
        message: I18n.t("discourse_check_on.welcome"),
        enabled: SiteSetting.discourse_check_on_enabled,
        feature_level: SiteSetting.discourse_check_on_feature_level,
        auto_greeting: SiteSetting.discourse_check_on_auto_greeting,
        display_stats: SiteSetting.discourse_check_on_display_stats,
        custom_message: SiteSetting.discourse_check_on_custom_message
      }
    end

    def toggle
      if current_user&.admin?
        new_status = params[:status] == "true"
        SiteSetting.discourse_check_on_enabled = new_status
        render json: { success: true, enabled: new_status }
      else
        render json: { error: I18n.t("discourse_check_on.admin_required") }, status: 403
      end
    end

    def stats
      stats = {
        total_users: User.count,
        active_users: User.where("last_seen_at > ?", 1.week.ago).count,
        total_topics: Topic.count,
        check_on_topics: TopicCustomField.where(name: DiscourseCheckOn::FIELD_NAME).count
      }
      render json: stats
    end
  end

  # 添加用户序列化器扩展
  add_to_serializer(:user, :check_on_greeting) do
    object.check_on_greeting if SiteSetting.discourse_check_on_enabled
  end

  # 添加主题序列化器扩展
  add_to_serializer(:topic_view, DiscourseCheckOn::FIELD_NAME.to_sym) do
    object.topic.send(DiscourseCheckOn::FIELD_NAME) if SiteSetting.discourse_check_on_enabled
  end

  # 添加主题列表序列化器扩展
  add_to_serializer(:topic_list_item, DiscourseCheckOn::FIELD_NAME.to_sym) do
    object.send(DiscourseCheckOn::FIELD_NAME) if SiteSetting.discourse_check_on_enabled
  end

  # 监听用户创建事件
  DiscourseEvent.on(:user_created) do |user|
    if SiteSetting.discourse_check_on_auto_greeting
      Rails.logger.info("Discourse Check-on: 新用户 #{user.username} 已创建")
    end
  end

  # 监听主题创建事件
  DiscourseEvent.on(:topic_created) do |topic, opts, user|
    if SiteSetting.discourse_check_on_enabled
      topic.set_check_on_status("new")
      Rails.logger.info("Discourse Check-on: 新主题 '#{topic.title}' 已创建")
    end
  end
end

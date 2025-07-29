# frozen_string_literal: true

# name: Discourse-Check-on
# about: 一个简单的Discourse示例插件，展示基本功能和设置选项
# version: 1.0.0
# authors: Pandacc
# url: https://github.com/werta666/Discourse-Check-on
# required_version: 2.7.0
# transpile_js: true

enabled_site_setting :discourse_check_on_enabled

register_asset "stylesheets/common/discourse-check-on.scss"
register_asset "stylesheets/desktop/discourse-check-on-desktop.scss", :desktop
register_asset "stylesheets/mobile/discourse-check-on-mobile.scss", :mobile

PLUGIN_NAME ||= "discourse-check-on".freeze

after_initialize do
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

  # 添加自定义路由
  Discourse::Application.routes.append do
    get "/discourse-check-on" => "discourse_check_on#index"
    post "/discourse-check-on/toggle" => "discourse_check_on#toggle"
    get "/discourse-check-on/stats" => "discourse_check_on#stats"
  end

  # 创建自定义控制器
  class ::DiscourseCheckOnController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    def index
      render json: {
        message: I18n.t("discourse_check_on.welcome"),
        enabled: SiteSetting.discourse_check_on_enabled,
        feature_level: SiteSetting.discourse_check_on_feature_level,
        auto_greeting: SiteSetting.discourse_check_on_auto_greeting
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
        check_on_topics: Topic.joins(:_custom_fields)
                              .where(topic_custom_fields: { name: "check_on_status" })
                              .count
      }
      render json: stats
    end
  end

  # 添加用户序列化器扩展
  add_to_serializer(:user, :check_on_greeting) do
    object.check_on_greeting if SiteSetting.discourse_check_on_enabled
  end

  # 添加主题序列化器扩展
  add_to_serializer(:topic_view, :check_on_status) do
    object.topic.check_on_status if SiteSetting.discourse_check_on_enabled
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

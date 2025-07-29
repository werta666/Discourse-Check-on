import { withPluginApi } from "discourse/lib/plugin-api";
import DiscourseCheckOnHeaderIcon from "../components/discourse-check-on-header-icon";
import I18n from "I18n";

export default {
  name: "discourse-check-on-initializer",

  initialize() {
    withPluginApi("1.34.0", (api) => {
      // 检查插件是否启用
      if (!api.container.lookup("site-settings:main").discourse_check_on_enabled) {
        return;
      }

      console.log("Discourse Check-on 插件已初始化");

      // 添加导航栏链接 - 使用兼容的API
      try {
        if (api.headerIcons && api.headerIcons.add) {
          api.headerIcons.add("discourse-check-on", DiscourseCheckOnHeaderIcon, { before: "search" });
        } else {
          // 回退到旧的API
          api.decorateWidget("header-icons:before", helper => {
            return helper.h(DiscourseCheckOnHeaderIcon);
          });
        }
      } catch (error) {
        console.warn("Discourse Check-on: 无法添加导航栏图标", error);
      }

      // 为新用户显示欢迎消息
      const currentUser = api.getCurrentUser();
      const siteSettings = api.container.lookup("site-settings:main");

      if (currentUser && siteSettings.discourse_check_on_enabled && siteSettings.discourse_check_on_auto_greeting) {
        // 检查是否已经显示过欢迎消息
        const welcomeShownKey = `discourse_check_on_welcome_shown_${currentUser.id}`;
        const hasShownWelcome = localStorage.getItem(welcomeShownKey);

        if (!hasShownWelcome && currentUser.created_at) {
          const createdDate = new Date(currentUser.created_at);
          const now = new Date();
          const daysSinceCreation = (now - createdDate) / (1000 * 60 * 60 * 24);

          // 如果用户注册不到7天，显示欢迎消息
          if (daysSinceCreation <= 7) {
            setTimeout(() => {
              const customMessage = siteSettings.discourse_check_on_custom_message;
              const message = customMessage || I18n.t("discourse_check_on.welcome_message", { username: currentUser.username });

              // 根据功能级别显示不同的欢迎内容
              let welcomeContent = message;
              const featureLevel = siteSettings.discourse_check_on_feature_level;

              if (featureLevel === 'advanced') {
                welcomeContent += "<br><br>" + I18n.t("discourse_check_on.advanced_welcome_bonus");
              } else if (featureLevel === 'premium') {
                welcomeContent += "<br><br>" + I18n.t("discourse_check_on.premium_welcome_bonus");
              }

              if (window.bootbox) {
                bootbox.alert({
                  title: I18n.t("discourse_check_on.welcome_title"),
                  message: welcomeContent,
                  className: "discourse-check-on-welcome-modal",
                  callback: function() {
                    // 标记已显示过欢迎消息
                    localStorage.setItem(welcomeShownKey, 'true');
                  }
                });
              }
            }, 3000);
          }
        }
      }
    });
  }
};

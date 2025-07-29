import { withPluginApi } from "discourse/lib/plugin-api";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default {
  name: "discourse-check-on-initializer",

  initialize() {
    withPluginApi("0.8.31", (api) => {
      // 检查插件是否启用
      if (!api.container.lookup("site-settings:main").discourse_check_on_enabled) {
        return;
      }

      console.log("Discourse Check-on 插件已初始化");

      // 添加导航栏链接 - 使用现代API
      api.addHeaderIcon("discourse-check-on", {
        href: "/discourse-check-on",
        icon: "check-circle",
        title: I18n.t("discourse_check_on.plugin_title"),
        classNames: "discourse-check-on-header-link"
      });

      // 在主题列表前添加插件信息 - 使用现代API
      api.renderInOutlet("topic-list-before", "discourse-check-on-stats");

      // 添加自定义组件
      api.createWidget("discourse-check-on-stats", {
        tagName: "div.discourse-check-on-stats",
        
        buildKey: () => "discourse-check-on-stats",
        
        defaultState() {
          return {
            loading: true,
            stats: null,
            error: null
          };
        },

        buildClasses() {
          return ["discourse-check-on-widget"];
        },

        html(_attrs, state) {
          const h = this.h;

          if (state.loading) {
            return [
              this.attach("button", {
                className: "btn-primary discourse-check-on-load-btn",
                label: "discourse_check_on.load_stats",
                action: "loadStats"
              })
            ];
          }

          if (state.error) {
            return [
              h("div.discourse-check-on-error", [
                h("p", I18n.t("discourse_check_on.error_loading")),
                this.attach("button", {
                  className: "btn-default",
                  label: "discourse_check_on.retry",
                  action: "loadStats"
                })
              ])
            ];
          }

          if (state.stats) {
            return [
              h("div.discourse-check-on-info", [
                h("h3", I18n.t("discourse_check_on.plugin_stats")),
                h("div.stats-grid", [
                  h("div.stat-item", [
                    h("span.stat-number", state.stats.total_users),
                    h("span.stat-label", I18n.t("discourse_check_on.total_users"))
                  ]),
                  h("div.stat-item", [
                    h("span.stat-number", state.stats.active_users),
                    h("span.stat-label", I18n.t("discourse_check_on.active_users"))
                  ]),
                  h("div.stat-item", [
                    h("span.stat-number", state.stats.total_topics),
                    h("span.stat-label", I18n.t("discourse_check_on.total_topics"))
                  ]),
                  h("div.stat-item", [
                    h("span.stat-number", state.stats.check_on_topics),
                    h("span.stat-label", I18n.t("discourse_check_on.check_on_topics"))
                  ])
                ])
              ])
            ];
          }
        },

        loadStats() {
          this.state.loading = true;
          this.state.error = null;
          this.scheduleRerender();

          ajax("/discourse-check-on/stats")
            .then((result) => {
              this.state.stats = result;
              this.state.loading = false;
              this.scheduleRerender();
            })
            .catch((error) => {
              this.state.error = error;
              this.state.loading = false;
              this.scheduleRerender();
              popupAjaxError(error);
            });
        }
      });

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

              bootbox.alert({
                title: I18n.t("discourse_check_on.welcome_title"),
                message: welcomeContent,
                className: "discourse-check-on-welcome-modal",
                callback: function() {
                  // 标记已显示过欢迎消息
                  localStorage.setItem(welcomeShownKey, 'true');
                }
              });
            }, 3000);
          }
        }
      }

      // 添加主题状态指示器 - 使用现代API
      api.modifyClass("model:topic", {
        pluginId: "discourse-check-on",

        checkOnStatusIcon() {
          if (this.check_on_status && this.check_on_status !== "normal") {
            return this.check_on_status;
          }
          return null;
        }
      });

      // 主题状态组件
      api.createWidget("discourse-check-on-topic-status", {
        tagName: "span.discourse-check-on-topic-status",
        
        buildClasses(attrs) {
          return [`status-${attrs.status}`];
        },

        html(attrs) {
          const h = this.h;
          const statusText = I18n.t(`discourse_check_on.topic_status.${attrs.status}`);
          return [
            h("svg.fa.d-icon.d-icon-info-circle", {
              attributes: { "aria-hidden": "true" }
            }),
            h("span.status-text", statusText)
          ];
        }
      });
    });
  }
};

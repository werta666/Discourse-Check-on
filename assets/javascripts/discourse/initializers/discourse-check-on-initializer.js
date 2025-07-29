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

      // 添加导航栏链接
      api.decorateWidget("header-icons:before", (helper) => {
        const currentUser = api.getCurrentUser();
        if (currentUser && currentUser.admin) {
          return helper.attach("link", {
            href: "/discourse-check-on",
            className: "discourse-check-on-link",
            icon: "check-circle",
            title: "Discourse Check-on"
          });
        }
      });

      // 在主题列表前添加插件信息
      api.decorateWidget("topic-list:before", (helper) => {
        const siteSettings = api.container.lookup("site-settings:main");
        
        if (siteSettings.discourse_check_on_display_stats) {
          return helper.attach("discourse-check-on-stats");
        }
      });

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

        html(attrs, state) {
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
      if (api.getCurrentUser() && api.container.lookup("site-settings:main").discourse_check_on_auto_greeting) {
        const currentUser = api.getCurrentUser();
        if (currentUser.created_at) {
          const createdDate = new Date(currentUser.created_at);
          const now = new Date();
          const daysSinceCreation = (now - createdDate) / (1000 * 60 * 60 * 24);
          
          // 如果用户注册不到7天，显示欢迎消息
          if (daysSinceCreation <= 7) {
            setTimeout(() => {
              const customMessage = api.container.lookup("site-settings:main").discourse_check_on_custom_message;
              bootbox.alert({
                title: I18n.t("discourse_check_on.welcome_title"),
                message: customMessage || I18n.t("discourse_check_on.welcome_message", { username: currentUser.username }),
                className: "discourse-check-on-welcome-modal"
              });
            }, 2000);
          }
        }
      }

      // 添加主题状态指示器
      api.decorateWidget("topic-list-item:after", (helper) => {
        const topic = helper.getModel();
        if (topic && topic.check_on_status && topic.check_on_status !== "normal") {
          return helper.attach("discourse-check-on-topic-status", {
            status: topic.check_on_status
          });
        }
      });

      // 主题状态组件
      api.createWidget("discourse-check-on-topic-status", {
        tagName: "span.discourse-check-on-topic-status",
        
        buildClasses(attrs) {
          return [`status-${attrs.status}`];
        },

        html(attrs) {
          const statusText = I18n.t(`discourse_check_on.topic_status.${attrs.status}`);
          return [
            iconNode("info-circle"),
            h("span.status-text", statusText)
          ];
        }
      });
    });
  }
};

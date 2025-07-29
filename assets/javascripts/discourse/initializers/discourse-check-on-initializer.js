import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "discourse-check-on-initializer",

  initialize() {
    withPluginApi("0.8.31", (api) => {
      console.log("Discourse Check-on 插件已初始化");

      // 简化的初始化，暂时移除复杂功能
      const siteSettings = api.container.lookup("site-settings:main");
      if (siteSettings && siteSettings.discourse_check_on_enabled) {
        console.log("Discourse Check-on 插件已启用");
      }
    });
  }
};

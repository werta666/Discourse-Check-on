import Component from "@ember/component";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default Component.extend({
  classNames: ["discourse-check-on-panel"],
  
  init() {
    this._super(...arguments);
    this.set("isLoading", false);
    this.set("pluginData", null);
    this.loadPluginData();
  },

  @action
  loadPluginData() {
    this.set("isLoading", true);

    ajax("/discourse-check-on/api")
      .then((result) => {
        this.set("pluginData", result);
        this.set("isLoading", false);
      })
      .catch((error) => {
        this.set("isLoading", false);
        popupAjaxError(error);
      });
  },

  @action
  togglePlugin() {
    if (!this.currentUser || !this.currentUser.admin) {
      bootbox.alert(I18n.t("discourse_check_on.admin_required"));
      return;
    }

    const newStatus = !this.pluginData.enabled;
    this.set("isLoading", true);

    ajax("/discourse-check-on/toggle", {
      type: "POST",
      data: { status: newStatus }
    })
      .then((result) => {
        this.set("pluginData.enabled", result.enabled);
        this.set("isLoading", false);
        
        const message = result.enabled 
          ? I18n.t("discourse_check_on.plugin_enabled")
          : I18n.t("discourse_check_on.plugin_disabled");
        
        bootbox.alert(message);
      })
      .catch((error) => {
        this.set("isLoading", false);
        popupAjaxError(error);
      });
  },

  @action
  refreshData() {
    this.loadPluginData();
  }
});

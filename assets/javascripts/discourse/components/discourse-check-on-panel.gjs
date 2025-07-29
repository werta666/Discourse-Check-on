import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import DButton from "discourse/components/d-button";
import icon from "discourse-common/helpers/d-icon";
import I18n from "I18n";

export default class DiscourseCheckOnPanel extends Component {
  @service currentUser;
  @tracked isLoading = false;
  @tracked pluginData = null;

  constructor() {
    super(...arguments);
    this.loadPluginData();
  }

  get loadingText() {
    return I18n.t("discourse_check_on.loading");
  }

  get pluginTitle() {
    return I18n.t("discourse_check_on.plugin_title");
  }

  get statusEnabledText() {
    return I18n.t("discourse_check_on.status_enabled");
  }

  get statusDisabledText() {
    return I18n.t("discourse_check_on.status_disabled");
  }

  get currentSettingsText() {
    return I18n.t("discourse_check_on.current_settings");
  }

  get featureLevelText() {
    return I18n.t("discourse_check_on.feature_level");
  }

  get autoGreetingText() {
    return I18n.t("discourse_check_on.auto_greeting");
  }

  get enabledText() {
    return I18n.t("discourse_check_on.enabled");
  }

  get disabledText() {
    return I18n.t("discourse_check_on.disabled");
  }

  get adminActionsText() {
    return I18n.t("discourse_check_on.admin_actions");
  }

  get aboutPluginText() {
    return I18n.t("discourse_check_on.about_plugin");
  }

  get pluginDescriptionText() {
    return I18n.t("discourse_check_on.plugin_description");
  }

  get versionText() {
    return I18n.t("discourse_check_on.version");
  }

  get authorText() {
    return I18n.t("discourse_check_on.author");
  }

  get githubRepoText() {
    return I18n.t("discourse_check_on.github_repo");
  }

  get refreshText() {
    return I18n.t("discourse_check_on.refresh");
  }

  get retryText() {
    return I18n.t("discourse_check_on.retry");
  }

  get failedToLoadText() {
    return I18n.t("discourse_check_on.failed_to_load");
  }

  get featureLevelDisplayText() {
    if (!this.pluginData?.feature_level) return "";
    return I18n.t(`discourse_check_on.feature_levels.${this.pluginData.feature_level}`);
  }

  get toggleButtonText() {
    if (!this.pluginData) return "";
    return this.pluginData.enabled
      ? I18n.t("discourse_check_on.disable_plugin")
      : I18n.t("discourse_check_on.enable_plugin");
  }

  get toggleButtonIcon() {
    if (!this.pluginData) return "check";
    return this.pluginData.enabled ? "times" : "check";
  }

  @action
  async loadPluginData() {
    this.isLoading = true;

    try {
      const result = await ajax("/discourse-check-on/api");
      this.pluginData = result;
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.isLoading = false;
    }
  }

  @action
  async togglePlugin() {
    if (!this.currentUser || !this.currentUser.admin) {
      bootbox.alert(I18n.t("discourse_check_on.admin_required"));
      return;
    }

    const newStatus = !this.pluginData.enabled;
    this.isLoading = true;

    try {
      const result = await ajax("/discourse-check-on/toggle", {
        type: "POST",
        data: { status: newStatus }
      });

      this.pluginData.enabled = result.enabled;

      const message = result.enabled
        ? I18n.t("discourse_check_on.plugin_enabled")
        : I18n.t("discourse_check_on.plugin_disabled");

      bootbox.alert(message);
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.isLoading = false;
    }
  }

  @action
  refreshData() {
    this.loadPluginData();
  }

  <template>
    <div class="discourse-check-on-panel">
      {{#if this.isLoading}}
        <div class="discourse-check-on-loading">
          <span class="spinner"></span>
          <span>{{this.loadingText}}</span>
        </div>
      {{else}}
        {{#if this.pluginData}}
          <div class="discourse-check-on-content">
            <div class="plugin-header">
              <h2>{{this.pluginTitle}}</h2>
              <div class="plugin-status {{if this.pluginData.enabled 'enabled' 'disabled'}}">
                {{#if this.pluginData.enabled}}
                  {{icon "check-circle"}}
                  <span>{{this.statusEnabledText}}</span>
                {{else}}
                  {{icon "times-circle"}}
                  <span>{{this.statusDisabledText}}</span>
                {{/if}}
              </div>
            </div>

            <div class="plugin-message">
              <p>{{this.pluginData.message}}</p>
            </div>

            <div class="plugin-settings">
              <h3>{{this.currentSettingsText}}</h3>
              <ul class="settings-list">
                <li>
                  <strong>{{this.featureLevelText}}:</strong>
                  <span class="feature-level-{{this.pluginData.feature_level}}">
                    {{this.featureLevelDisplayText}}
                  </span>
                </li>
                <li>
                  <strong>{{this.autoGreetingText}}:</strong>
                  {{#if this.pluginData.auto_greeting}}
                    {{icon "check"}} {{this.enabledText}}
                  {{else}}
                    {{icon "times"}} {{this.disabledText}}
                  {{/if}}
                </li>
              </ul>
            </div>

            {{#if this.currentUser.admin}}
              <div class="plugin-actions">
                <h3>{{this.adminActionsText}}</h3>
                <div class="action-buttons">
                  <DButton
                    class="btn-primary"
                    @action={{this.togglePlugin}}
                    @icon={{this.toggleButtonIcon}}
                  >
                    {{this.toggleButtonText}}
                  </DButton>

                  <DButton
                    class="btn-default"
                    @action={{this.refreshData}}
                    @icon="sync"
                  >
                    {{this.refreshText}}
                  </DButton>
                </div>
              </div>
            {{/if}}

            <div class="plugin-info">
              <h3>{{this.aboutPluginText}}</h3>
              <p>{{this.pluginDescriptionText}}</p>
              <div class="plugin-meta">
                <span class="version">{{this.versionText}}: 1.0.0</span>
                <span class="author">{{this.authorText}}: Pandacc</span>
                <a href="https://github.com/werta666/Discourse-Check-on" target="_blank" class="github-link">
                  {{icon "fab-github"}} {{this.githubRepoText}}
                </a>
              </div>
            </div>
          </div>
        {{else}}
          <div class="discourse-check-on-error">
            <p>{{this.failedToLoadText}}</p>
            <DButton
              class="btn-default"
              @action={{this.refreshData}}
              @icon="sync"
            >
              {{this.retryText}}
            </DButton>
          </div>
        {{/if}}
      {{/if}}
    </div>
  </template>
}

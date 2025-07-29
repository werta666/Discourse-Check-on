import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import DButton from "discourse/components/d-button";
import I18n from "I18n";

export default class DiscourseCheckOnStats extends Component {
  @service siteSettings;
  @tracked loading = false;
  @tracked stats = null;
  @tracked error = null;

  get shouldShow() {
    return this.siteSettings.discourse_check_on_display_stats;
  }

  get loadingText() {
    return I18n.t("discourse_check_on.loading");
  }

  get errorText() {
    return I18n.t("discourse_check_on.error_loading");
  }

  get pluginStatsTitle() {
    return I18n.t("discourse_check_on.plugin_stats");
  }

  get totalUsersLabel() {
    return I18n.t("discourse_check_on.total_users");
  }

  get activeUsersLabel() {
    return I18n.t("discourse_check_on.active_users");
  }

  get totalTopicsLabel() {
    return I18n.t("discourse_check_on.total_topics");
  }

  get checkOnTopicsLabel() {
    return I18n.t("discourse_check_on.check_on_topics");
  }

  @action
  async loadStats() {
    this.loading = true;
    this.error = null;

    try {
      const result = await ajax("/discourse-check-on/stats");
      this.stats = result;
    } catch (error) {
      this.error = error;
      popupAjaxError(error);
    } finally {
      this.loading = false;
    }
  }

  <template>
    {{#if this.shouldShow}}
      <div class="discourse-check-on-stats">
        <div class="discourse-check-on-widget">
          {{#if this.loading}}
            <div class="discourse-check-on-loading">
              <span class="spinner"></span>
              {{this.loadingText}}
            </div>
          {{else if this.error}}
            <div class="discourse-check-on-error">
              <span class="error-message">{{this.errorText}}</span>
              <DButton
                class="btn-small discourse-check-on-retry-btn"
                @action={{this.loadStats}}
                @label="discourse_check_on.retry"
              />
            </div>
          {{else if this.stats}}
            <div class="discourse-check-on-info">
              <h3>{{this.pluginStatsTitle}}</h3>
              <div class="stats-grid">
                <div class="stat-item">
                  <span class="stat-number">{{this.stats.total_users}}</span>
                  <span class="stat-label">{{this.totalUsersLabel}}</span>
                </div>
                <div class="stat-item">
                  <span class="stat-number">{{this.stats.active_users}}</span>
                  <span class="stat-label">{{this.activeUsersLabel}}</span>
                </div>
                <div class="stat-item">
                  <span class="stat-number">{{this.stats.total_topics}}</span>
                  <span class="stat-label">{{this.totalTopicsLabel}}</span>
                </div>
                <div class="stat-item">
                  <span class="stat-number">{{this.stats.check_on_topics}}</span>
                  <span class="stat-label">{{this.checkOnTopicsLabel}}</span>
                </div>
              </div>
              <DButton
                class="btn-small discourse-check-on-refresh-btn"
                @action={{this.loadStats}}
                @label="discourse_check_on.refresh"
              />
            </div>
          {{else}}
            <div class="discourse-check-on-load">
              <DButton
                class="btn-primary discourse-check-on-load-btn"
                @action={{this.loadStats}}
                @label="discourse_check_on.load_stats"
              />
            </div>
          {{/if}}
        </div>
      </div>
    {{/if}}
  </template>
}

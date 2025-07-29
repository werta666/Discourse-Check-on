import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import DButton from "discourse/components/d-button";

export default class DiscourseCheckOnHeaderIcon extends Component {
  @service currentUser;
  @service siteSettings;

  get shouldShow() {
    return (
      this.siteSettings.discourse_check_on_enabled &&
      this.currentUser &&
      (this.currentUser.admin || this.currentUser.moderator)
    );
  }

  <template>
    {{#if this.shouldShow}}
      <li>
        <DButton
          class="icon btn-flat discourse-check-on-link"
          @href="/discourse-check-on"
          @icon="check-circle"
          @title={{I18n.t("discourse_check_on.plugin_title")}}
        />
      </li>
    {{/if}}
  </template>
}

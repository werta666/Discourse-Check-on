import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import DButton from "discourse/components/d-button";
import I18n from "I18n";

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

  get buttonTitle() {
    return I18n.t("discourse_check_on.plugin_title");
  }

  <template>
    {{#if this.shouldShow}}
      <li>
        <DButton
          class="icon btn-flat discourse-check-on-link"
          @href="/discourse-check-on"
          @icon="check-circle"
          @title={{this.buttonTitle}}
        />
      </li>
    {{/if}}
  </template>
}

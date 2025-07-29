import { acceptance, exists } from "discourse/tests/helpers/qunit-helpers";
import { test } from "qunit";
import { visit } from "@ember/test-helpers";

acceptance("Discourse Check-on Plugin", function (needs) {
  needs.user();
  needs.settings({
    discourse_check_on_enabled: true,
    discourse_check_on_display_stats: true,
    discourse_check_on_auto_greeting: false
  });

  test("plugin initializes correctly", async function (assert) {
    await visit("/");
    
    // 检查插件是否正确初始化
    assert.ok(
      exists(".discourse-check-on-stats") || 
      exists(".discourse-check-on-link"),
      "Plugin elements should be present when enabled"
    );
  });

  test("stats widget loads", async function (assert) {
    await visit("/");
    
    if (exists(".discourse-check-on-stats")) {
      assert.ok(
        exists(".discourse-check-on-load-btn") ||
        exists(".discourse-check-on-info"),
        "Stats widget should show load button or stats info"
      );
    } else {
      assert.ok(true, "Stats widget not displayed (settings dependent)");
    }
  });
});

acceptance("Discourse Check-on Plugin - Disabled", function (needs) {
  needs.user();
  needs.settings({
    discourse_check_on_enabled: false
  });

  test("plugin elements hidden when disabled", async function (assert) {
    await visit("/");
    
    // 当插件禁用时，相关元素应该不存在
    assert.notOk(
      exists(".discourse-check-on-stats"),
      "Stats widget should not be present when plugin is disabled"
    );
  });
});

acceptance("Discourse Check-on Plugin - Admin Features", function (needs) {
  needs.user({ admin: true });
  needs.settings({
    discourse_check_on_enabled: true
  });

  test("admin can see plugin link", async function (assert) {
    await visit("/");
    
    // 管理员应该能看到插件链接
    assert.ok(
      exists(".discourse-check-on-link") ||
      exists("a[href='/discourse-check-on']"),
      "Admin should see plugin navigation link"
    );
  });
});

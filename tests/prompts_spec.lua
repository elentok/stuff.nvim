describe("prompts target selection", function()
  it("prefers targets in the active scope when that scope has AI agents", function()
    local prompts = require("stuff.prompts")

    local targets = prompts._test.prefer_active_scope_targets({
      { id = "%1", scope_id = "@1", scope_active = false },
      { id = "%2", scope_id = "@2", scope_active = true },
      { id = "%3", scope_id = "@2", scope_active = true },
    })

    assert.same({
      { id = "%2", scope_id = "@2", scope_active = true },
      { id = "%3", scope_id = "@2", scope_active = true },
    }, targets)
  end)

  it("falls back to all targets when the active scope has no AI agents", function()
    local prompts = require("stuff.prompts")

    local targets = {
      { id = "%1", scope_id = "@1", scope_active = false },
      { id = "%2", scope_id = "@3", scope_active = false },
    }

    assert.same(targets, prompts._test.prefer_active_scope_targets(targets))
  end)

  it("keeps a single active-scope target so callers can auto-send directly", function()
    local prompts = require("stuff.prompts")

    local targets = prompts._test.prefer_active_scope_targets({
      { id = "%1", scope_id = "@1", scope_active = false },
      { id = "%2", scope_id = "@2", scope_active = true },
    })

    assert.same({
      { id = "%2", scope_id = "@2", scope_active = true },
    }, targets)
  end)
end)

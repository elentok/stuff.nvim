describe("find-agent", function()
  local find_agent = require("stuff.prompts.find-agent")

  it("prefers targets in the active scope when that scope has AI agents", function()
    local targets = find_agent.prefer_active_scope_targets({
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
    local targets = {
      { id = "%1", scope_id = "@1", scope_active = false },
      { id = "%2", scope_id = "@3", scope_active = false },
    }

    assert.same(targets, find_agent.prefer_active_scope_targets(targets))
  end)

  it("keeps a single active-scope target so callers can auto-send directly", function()
    local targets = find_agent.prefer_active_scope_targets({
      { id = "%1", scope_id = "@1", scope_active = false },
      { id = "%2", scope_id = "@2", scope_active = true },
    })

    assert.same({
      { id = "%2", scope_id = "@2", scope_active = true },
    }, targets)
  end)

  it("detects kitty targets from metadata without loading previews", function()
    local preview_calls = 0

    local targets = find_agent.collect_kitty_agent_targets({
      {
        window_id = "12",
        tab_id = "3",
        window_title = "shell",
        window_current_command = "codex",
        window_start_command = "codex",
        window_current_path = "/tmp",
        window_active = true,
        tab_active = true,
        window_agent_marker = "",
      },
    }, function()
      preview_calls = preview_calls + 1
      return "unused"
    end)

    assert.equal(0, preview_calls)
    assert.equal(1, #targets)
    assert.equal("codex", targets[1].agent)
  end)

  it("falls back to kitty previews only when metadata finds no agent", function()
    local preview_calls = 0

    local targets = find_agent.collect_kitty_agent_targets({
      {
        window_id = "12",
        tab_id = "3",
        window_title = "shell",
        window_current_command = "bash",
        window_start_command = "bash",
        window_current_path = "/tmp",
        window_active = true,
        tab_active = true,
        window_agent_marker = "",
      },
    }, function()
      preview_calls = preview_calls + 1
      return "codex is running here"
    end)

    assert.equal(1, preview_calls)
    assert.equal(1, #targets)
    assert.equal("codex", targets[1].agent)
    assert.equal("codex is running here", targets[1].preview_text)
  end)

  it("prefers active kitty targets found via preview over inactive metadata matches", function()
    local preview_calls = 0

    local targets = find_agent.collect_kitty_agent_targets({
      {
        window_id = "12",
        tab_id = "1",
        window_title = "codex",
        window_current_command = "codex",
        window_start_command = "codex",
        window_current_path = "/tmp/inactive",
        window_active = false,
        tab_active = false,
        window_agent_marker = "",
      },
      {
        window_id = "22",
        tab_id = "2",
        window_title = "shell",
        window_current_command = "bash",
        window_start_command = "bash",
        window_current_path = "/tmp/active",
        window_active = true,
        tab_active = true,
        window_agent_marker = "",
      },
    }, function(window_id)
      preview_calls = preview_calls + 1
      if window_id == "22" then return "claude is running here" end
      return "no agent"
    end)

    assert.equal(1, preview_calls)
    assert.equal(1, #targets)
    assert.equal("22", targets[1].id)
    assert.equal("claude", targets[1].agent)
  end)
end)

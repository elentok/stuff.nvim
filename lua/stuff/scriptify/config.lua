---@class ScriptifyConfig
---@field hashtags { [string]: string|string[] }

---@type ScriptifyConfig
local config = {
  hashtags = {
    python = "#!/usr/bin/env python3",
    ruby = "#!/usr/bin/env ruby",
    bash = { "#!/usr/bin/env bash", "", "set -euo pipefail" },
    node = "#!/usr/bin/env node",
    tsnode = "#!/usr/bin/env -S ts-node --swc",
    deno = "#!/usr/bin/env -S deno run --allow-env --allow-read --allow-run",
    fish = "#!/usr/bin/env fish",
  },
}

return config

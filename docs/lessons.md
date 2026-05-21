# Lessons

- 2026-04-28: For insert-mode mappings that should both insert text and trigger UI, prefer `expr = true` and return the literal text. Avoid `nvim_feedkeys()` from the same mapping because it can recurse or stall.
- 2026-04-29: For visual selections used from mappings, prefer the persisted `'<` and `'>` marks over `line("v")` and cursor state. Mapping callbacks can lose the live visual context and collapse multiline ranges to one line.
- 2026-04-29: For async UI callbacks that edit a visual selection, capture `bufnr` and exact line indexes before opening the prompt. Using buffer `0` or recomputing context inside the callback makes behavior depend on the focused buffer after the prompt closes.

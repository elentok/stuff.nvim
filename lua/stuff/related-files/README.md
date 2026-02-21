# related-files

Jump between a source file and its related files (test, style, etc.).

## How it works

Given the current buffer, the module finds all project files that share the same **core name** and **qualifier**, then lets you jump to them — directly if there's one match, or via a picker if there are several.

### Core name

The core name is extracted from the filename by stripping test/style affixes:

| File                     | Core name       |
| ------------------------ | --------------- |
| `MyComponent.test.tsx`   | `MyComponent`   |
| `MyComponent.module.css` | `MyComponent`   |
| `test_utils.py`          | `utils`         |
| `handler_test.go`        | `handler`       |
| `related-files_spec.lua` | `related-files` |

Index files (`init.lua`, `index.tsx`, `__init__.py`) use their parent directory name instead:

| File                               | Core name       |
| ---------------------------------- | --------------- |
| `lua/stuff/related-files/init.lua` | `related-files` |
| `src/components/Button/index.tsx`  | `Button`        |

### Qualifier

Files with the same core name in different parts of the tree (e.g.
`lua/stuff/git/util.lua` vs `lua/stuff/util/init.lua`) are disambiguated by a
**qualifier** — the first semantically meaningful directory segment above the
file.

The qualifier is found by walking upward from the file's parent directory,
skipping:

1. Directories whose name matches the core name (e.g. `util/` for
   `util/init.lua`)
2. **Structural directories** that organize the project but don't carry
   semantic meaning: `src`, `lib`, `lua`, `tests`, `test`, `spec`, `__tests__`,
   `app`
3. **Lua package directories** — any directory whose parent is `lua/` (e.g.
   `lua/stuff/`)

The first directory that isn't skipped becomes the qualifier. If none is found, the qualifier is empty.

| File                              | Core name | Qualifier    |
| --------------------------------- | --------- | ------------ |
| `lua/stuff/git/util.lua`          | `util`    | `git`        |
| `tests/git/util_spec.lua`         | `util`    | `git`        |
| `lua/stuff/util/init.lua`         | `util`    | _(empty)_    |
| `tests/util_spec.lua`             | `util`    | _(empty)_    |
| `src/components/Button/index.tsx` | `Button`  | `components` |

Two files are considered related only when both their core name and qualifier match.

### File classification

Each related file is classified as one of:

- **test** — `_test`, `_spec`, `test_` in the stem, or `.test.`/`.spec.` in the filename
- **style** — `.css`, `.scss`, `.sass`, `.less` extension
- **code** — everything else

### Jumping

`jump_to_related(type_filter)` is the main entry point:

- With no filter, it shows all related files.
- With a filter (e.g. `"test"`), it shows only files of that type.
- One match: opens it directly. Multiple matches: opens a Snacks picker.

Results are cached per buffer in `vim.b.related_files`.

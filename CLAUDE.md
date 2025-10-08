# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture

This is a **single-file Neovim 0.11.4 configuration** (`init.lua`) that uses:
- **Custom plugin bootstrap**: Simple `ensure_plugin()` function that clones plugins to `~/.local/share/nvim/site/pack/vendor/start/`
- **Mini.nvim modules**: 18 modules including basics, completion, snippets, git, notify, trailspace, tabline
- **Neovim 0.11 built-in LSP**: Uses `vim.lsp.config()` and `vim.lsp.enable()` (NO lspconfig plugin needed)
- **mini.completion**: Replaces built-in completion with Tab-to-confirm workflow
- **Catppuccin theme**: Mocha flavor

## Key Design Principles

1. **No plugin manager** - Plugins are git cloned directly using native Neovim package loading
2. **Everything in init.lua** - No split config files, no `lua/` directory
3. **LSP servers configured inline** - Uses Neovim 0.11's built-in LSP configuration (lua_ls, rust_analyzer, ts_ls)
4. **Mini.nvim for everything** - Fuzzy finding, file explorer, statusline, completion, git, notifications

## Active Mini.nvim Modules

**Text Editing**: basics, comment, surround, pairs, snippets, ai
**Workflow**: bracketed, pick, files, git
**Completion**: completion (with Tab-to-confirm)
**Appearance**: indentscope, icons, statusline, notify, trailspace, tabline

## Plugin Management

### Install/Update plugins
```vim
:PluginUpdate
```

This command:
- Git pulls all plugins in `~/.local/share/nvim/site/pack/vendor/start/`
- Runs `packloadall!` and `helptags ALL`

### Add a new plugin
Edit `init.lua` and add to `bootstrap_plugins()`:
```lua
if ensure_plugin('username', 'plugin-name') then
  installed_any = true
end
```

### Plugin locations
- Install path: `~/.local/share/nvim/site/pack/vendor/start/`
- Currently installed: `mini.nvim`, `catppuccin/nvim`

## LSP Configuration

LSP servers are configured using **Neovim 0.11's built-in LSP** (not nvim-lspconfig):

```lua
vim.lsp.config('server_name', {
  cmd = {'command'},
  filetypes = {'filetype'},
  root_markers = {'.git'},
  settings = {}
})
vim.lsp.enable({'server_name'})
```

### Currently configured LSP servers
- `lua_ls` - Lua (requires `lua-language-server` binary)
- `rust_analyzer` - Rust (requires `rust-analyzer` binary)
- `ts_ls` - TypeScript/JavaScript (requires `typescript-language-server` binary)

**Note**: LSP binaries must be installed separately (e.g., via Mason, homebrew, cargo, npm)

## Completion Workflow

Uses **mini.completion** with custom keybindings:
- **Ctrl-n** / **Ctrl-p** - Navigate completion menu (down/up)
- **Tab** - Confirm/select completion
- Auto-triggers as you type in LSP-enabled buffers
- First item is pre-selected by default (`completeopt` without 'noselect')

## Key Bindings

Leader key: `<Space>`

### Essential mappings
- `-` - Open file explorer (mini.files) at current buffer location
- `<leader>p` - Find files (mini.pick)
- `<leader>b` - Find buffers (mini.pick)
- `<leader>gg` - Live grep (mini.pick)
- `<leader>*` - Grep word under cursor (mini.pick)
- `<leader>1-9` - Jump to buffer by position in tabline
- `<leader>ts` - Trim trailing whitespace
- `<leader>ev` - Edit vim config (`~/.config/nvim/init.lua`)

### Window navigation (from mini.basics)
- `Ctrl-h/j/k/l` - Move between windows

### LSP mappings (when attached)
- `gd` - Go to definition
- `gr` - Show references
- `K` - Hover documentation
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code action

## Testing/Validation

No automated tests or linting for this config. To verify:
1. Open Neovim: `nvim`
2. Check for errors: `:messages`
3. Verify plugins loaded: `:scriptnames`
4. Test LSP: Open a Lua/Rust/TS file and check `:LspInfo`

## Common Modifications

### Add mini.nvim module
Insert setup call in the MINI.NVIM MODULES section (~line 190-300):
```lua
require('mini.MODULE_NAME').setup()
```

### Change theme flavor
Find `catppuccin.setup()` in CATPPUCCIN THEME section:
```lua
flavour = 'mocha',  -- or 'latte', 'frappe', 'macchiato'
```

### Adjust LSP settings
Modify the `settings` table in `vim.lsp.config()` calls in NEOVIM 0.11 BUILT-IN LSP section

## Important Implementation Notes

- **mini.basics** provides window navigation (Ctrl-hjkl) and highlight-on-yank - don't duplicate these
- **mini.completion** uses Tab-to-confirm, NOT Tab-to-navigate - this is intentional
- Buffer switching (`<leader>1-9`) matches tabline order (sorted by buffer number)
- LSP uses Neovim 0.11 built-in APIs - do NOT add nvim-lspconfig
- No separate config files - everything stays in `init.lua`

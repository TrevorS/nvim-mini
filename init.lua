-- ABOUTME: Minimal Neovim 0.11.4 config with custom plugin bootstrap
-- Single-file configuration using mini.nvim modules and catppuccin theme

-- ============================================================================
-- PLUGIN BOOTSTRAP
-- ============================================================================

local function ensure_plugin(user, repo)
  local install_path = vim.fn.stdpath('data') .. '/site/pack/vendor/start/' .. repo

  if vim.fn.isdirectory(install_path) == 0 then
    vim.notify('Installing ' .. repo .. '...', vim.log.levels.INFO)
    local url = string.format('https://github.com/%s/%s.git', user, repo)
    vim.fn.system({ 'git', 'clone', '--depth=1', url, install_path })
    vim.notify('Installed ' .. repo, vim.log.levels.INFO)
    return true
  end
  return false
end

local function bootstrap_plugins()
  local installed_any = false

  -- Install mini.nvim
  if ensure_plugin('nvim-mini', 'mini.nvim') then
    installed_any = true
  end

  -- Install catppuccin
  if ensure_plugin('catppuccin', 'nvim') then
    installed_any = true
  end

  if installed_any then
    vim.notify('Run :PluginUpdate to update plugins', vim.log.levels.INFO)
    vim.cmd('packloadall! | helptags ALL')
  end
end

-- Bootstrap on first run
bootstrap_plugins()

-- Create update command
vim.api.nvim_create_user_command('PluginUpdate', function()
  local data_path = vim.fn.stdpath('data') .. '/site/pack/vendor/start/'
  local plugins = vim.fn.readdir(data_path)

  for _, plugin in ipairs(plugins) do
    local plugin_path = data_path .. plugin
    vim.notify('Updating ' .. plugin .. '...', vim.log.levels.INFO)
    vim.fn.system({ 'git', '-C', plugin_path, 'pull' })
  end

  vim.cmd('packloadall! | helptags ALL')
  vim.notify('Plugins updated!', vim.log.levels.INFO)
end, {})

-- ============================================================================
-- CORE SETTINGS
-- ============================================================================

-- Leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Disable unused providers
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

-- Settings not covered by mini.basics
vim.opt.termguicolors = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.inccommand = 'nosplit'
vim.opt.completeopt = { 'menuone', 'noinsert' } -- Different from mini.basics 'noselect'
vim.opt.shortmess:append('c')
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.virtualedit = 'onemore' -- Different from mini.basics 'block'
vim.opt.wildmode = { 'longest', 'list:longest' }

-- Custom fillchars (overrides mini.basics default)
vim.opt.fillchars = {
  horiz = '━',
  horizup = '┻',
  horizdown = '┳',
  vert = '┃',
  vertleft = '┫',
  vertright = '┣',
  verthoriz = '╋',
}

-- ============================================================================
-- NEOVIM 0.11 BUILT-IN LSP
-- ============================================================================

-- Configure LSP servers (examples - install servers separately)
-- lua_ls
vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME }
      }
    }
  }
})

-- rust-analyzer
vim.lsp.config('rust_analyzer', {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', 'Cargo.lock', 'rust-project.json' },
  settings = {
    ['rust-analyzer'] = {
      cargo = {
        allFeatures = true,
      },
      check = {
        command = 'clippy',
      },
    }
  }
})

-- vtsls (TypeScript)
vim.lsp.config('vtsls', {
  cmd = { 'vtsls', '--stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
})

-- Enable LSP servers
vim.lsp.enable({ 'lua_ls', 'rust_analyzer', 'vtsls' })

-- LSP keymaps (using 0.11 defaults, customize as needed)
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = { buffer = args.buf }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  end
})

-- Global format keymap (works in any buffer)
vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format() end, { desc = 'Format buffer' })

-- Format on save (optional - comment out if not desired)
vim.api.nvim_create_autocmd('BufWritePre', {
  callback = function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients > 0 then
      vim.lsp.buf.format()
    end
  end
})

-- ============================================================================
-- MINI.NVIM MODULES
-- ============================================================================

-- mini.basics - Sensible defaults, window navigation, autocommands
require('mini.basics').setup({
  options = {
    basic = true,
    extra_ui = false,
  },
  mappings = {
    basic = true,
    option_toggle_prefix = [[\]],
    windows = true,
    move_with_alt = false,
  },
  autocommands = {
    basic = true,
    relnum_in_visual_mode = false,
  },
})

-- mini.comment - Toggle comments with 'gc'
require('mini.comment').setup()

-- mini.surround - Surround actions (sa, sd, sr)
require('mini.surround').setup()

-- mini.pairs - Auto-close brackets/quotes
require('mini.pairs').setup()

-- mini.snippets - Snippet support (required for mini.completion LSP snippets)
require('mini.snippets').setup()

-- mini.ai - Enhanced text objects
require('mini.ai').setup()

-- mini.completion - LSP completion with signature help
require('mini.completion').setup({
  lsp_completion = {
    source_func = 'omnifunc',
    auto_setup = true,
  },
  window = {
    info = { height = 25, width = 80, border = 'none' },
    signature = { height = 25, width = 80, border = 'none' },
  },
})

-- Tab to select/confirm completion
vim.keymap.set('i', '<Tab>', function()
  if vim.fn.pumvisible() == 1 then
    return '<C-y>'
  else
    return '<Tab>'
  end
end, { expr = true, desc = 'Confirm completion or insert tab' })

-- mini.bracketed - Navigate with [ and ]
require('mini.bracketed').setup()

-- mini.indentscope - Visualize indent scope
require('mini.indentscope').setup({
  symbol = '│',
  options = { try_as_border = true }
})

-- mini.icons - Icon provider
require('mini.icons').setup()

-- mini.statusline - Minimal statusline
require('mini.statusline').setup({
  content = {
    active = function()
      local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
      local git = MiniStatusline.section_git({ trunc_width = 75 })
      local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
      local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })
      local filename = MiniStatusline.section_filename({ trunc_width = 140 })

      return MiniStatusline.combine_groups({
        { hl = mode_hl,                  strings = { mode } },
        { hl = 'MiniStatuslineFilename', strings = { filename } },
        '%<', -- Truncation point
        { hl = 'MiniStatuslineDevinfo', strings = { git, lsp, diagnostics } },
        '%=', -- End left alignment
      })
    end,
  },
  use_icons = true,
})

-- mini.pick - Fuzzy finder
require('mini.pick').setup()

-- mini.files - File explorer
require('mini.files').setup({
  windows = {
    max_number = 3,
    preview = true,
    width_focus = 30,
    width_nofocus = 15,
    width_preview = 50
  }
})

-- Close mini.files when opening a file
vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniFilesBufferCreate',
  callback = function(args)
    local buf_id = args.data.buf_id
    -- Remap 'l' and Enter to close explorer when opening file
    vim.keymap.set('n', 'l', function()
      require('mini.files').go_in({ close_on_file = true })
    end, { buffer = buf_id, desc = 'Open file and close explorer' })
    vim.keymap.set('n', '<CR>', function()
      require('mini.files').go_in({ close_on_file = true })
    end, { buffer = buf_id, desc = 'Open file and close explorer' })
    -- Esc to close explorer
    vim.keymap.set('n', '<Esc>', function()
      require('mini.files').close()
    end, { buffer = buf_id, desc = 'Close explorer' })
  end,
})

-- mini.git - Git integration for hunks, blame, and diff overlays
require('mini.git').setup()

-- mini.notify - Show notifications
require('mini.notify').setup()
vim.notify = require('mini.notify').make_notify()

-- mini.trailspace - Highlight and remove trailing whitespace
require('mini.trailspace').setup()

-- mini.tabline - Buffer/tab line (like bufferline.nvim)
require('mini.tabline').setup()

-- mini.clue - which-key style hints
require('mini.clue').setup({
  triggers = {
    { mode = 'n', keys = '<Leader>' },
    { mode = 'x', keys = '<Leader>' },
    { mode = 'n', keys = 'g' },
    { mode = 'x', keys = 'g' },
    { mode = 'n', keys = '[' },
    { mode = 'n', keys = ']' },
  },
  clues = {
    require('mini.clue').gen_clues.builtin_completion(),
    require('mini.clue').gen_clues.g(),
    require('mini.clue').gen_clues.marks(),
    require('mini.clue').gen_clues.registers(),
    require('mini.clue').gen_clues.windows(),
    require('mini.clue').gen_clues.z(),
  },
  window = {
    delay = 500, -- Increase delay so quick keypresses work
  },
})

-- mini.move - move lines/blocks with Alt+hjkl
require('mini.move').setup()

-- mini.extra - additional pickers
require('mini.extra').setup()

-- mini.visits - track frecent files
require('mini.visits').setup()

-- Auto-hide tabline when only one buffer exists
local function update_tabline_visibility()
  local buffers = vim.tbl_filter(function(b)
    return vim.fn.buflisted(b) == 1
  end, vim.api.nvim_list_bufs())
  vim.o.showtabline = #buffers > 1 and 2 or 0
end

-- Set initial state
update_tabline_visibility()

-- Update on buffer changes
vim.api.nvim_create_autocmd({ 'BufAdd', 'BufDelete' }, {
  callback = function()
    vim.schedule(update_tabline_visibility)
  end,
})

-- ============================================================================
-- CATPPUCCIN THEME
-- ============================================================================

require('catppuccin').setup({
  flavour = 'mocha',
  transparent_background = false,
  integrations = {
    mini = {
      enabled = true,
      indentscope_color = ''
    }
  }
})

vim.cmd.colorscheme('catppuccin')

-- ============================================================================
-- KEYMAPS
-- ============================================================================

-- Splits
vim.keymap.set('n', '<leader>v', '<cmd>vsplit<cr><c-w>l', { desc = 'Vertical split' })
vim.keymap.set('n', '<leader>h', '<cmd>split<cr><c-w>j', { desc = 'Horizontal split' })

-- Edit config files
vim.keymap.set('n', '<leader>ev', function()
  vim.cmd.edit(vim.fn.stdpath('config') .. '/init.lua')
end, { desc = 'Edit vim config' })
vim.keymap.set('n', '<leader>ez', '<cmd>edit $HOME/.zshrc<cr>', { desc = 'Edit zshrc' })
vim.keymap.set('n', '<leader>ew', '<cmd>edit $HOME/.wezterm.lua<cr>', { desc = 'Edit wezterm config' })

-- Redraw and clear highlights
vim.keymap.set('n', '<leader>l', '<cmd>redraw!<cr><cmd>nohl<cr><esc>', { desc = 'Redraw and clear highlights' })

-- System clipboard yank in visual mode
vim.keymap.set('v', '<leader>y', '"+y', { desc = 'Yank to system clipboard' })

-- mini.files (like oil.nvim)
vim.keymap.set('n', '-', function()
  local MiniFiles = require('mini.files')
  local bufname = vim.api.nvim_buf_get_name(0)

  -- Check if we're already in mini.files by looking at buffer name
  if bufname:match('^minifiles://') then
    -- We're in mini.files, go up a directory
    MiniFiles.go_out()
  else
    -- We're in a regular buffer, open mini.files
    -- If buffer is empty/unnamed, use current working directory
    local path = bufname ~= '' and bufname or vim.fn.getcwd()
    MiniFiles.open(path)
  end
end, { desc = 'Open file explorer or go up' })

-- mini.pick (adapted from telescope bindings)
vim.keymap.set('n', '<leader>p', function()
  require('mini.pick').builtin.files()
end, { desc = 'Find files' })

vim.keymap.set('n', '<leader>b', function()
  require('mini.pick').builtin.buffers()
end, { desc = 'Find buffers' })

vim.keymap.set('n', '<leader>gg', function()
  require('mini.pick').builtin.grep_live()
end, { desc = 'Live grep' })

vim.keymap.set('n', '<leader>*', function()
  require('mini.pick').builtin.grep({ pattern = vim.fn.expand('<cword>') })
end, { desc = 'Grep word under cursor' })

-- Navigate wrapped lines
vim.keymap.set('n', 'j', 'gj', { desc = 'Move down (wrapped)' })
vim.keymap.set('n', 'k', 'gk', { desc = 'Move up (wrapped)' })

-- Buffer navigation
vim.keymap.set('n', '<TAB>', '<cmd>bnext<cr>', { desc = 'Next buffer' })
vim.keymap.set('n', '<S-TAB>', '<cmd>bprevious<cr>', { desc = 'Previous buffer' })

-- Buffer switching by position
for i = 1, 9 do
  vim.keymap.set('n', '<leader>' .. i, function()
    local buffers = vim.tbl_filter(function(b) return vim.fn.buflisted(b) == 1 end, vim.api.nvim_list_bufs())
    table.sort(buffers)
    if buffers[i] then vim.api.nvim_set_current_buf(buffers[i]) end
  end, { desc = 'Go to buffer ' .. i })
end

-- Format JSON with jq
vim.keymap.set('n', '<leader>jf', '<cmd>%!jq .<cr>', { desc = 'Format JSON with jq' })

-- Format SQL with sleek
vim.keymap.set('n', '<leader>sf', '<cmd>%!sleek<cr>', { desc = 'Format SQL with sleek' })

-- Copy buffer path to system clipboard
vim.keymap.set('n', '<leader>xp', function()
  local path = vim.api.nvim_buf_get_name(0)
  vim.fn.setreg('+', path)
  vim.notify('Copied path: ' .. path, vim.log.levels.INFO)
end, { desc = 'Copy buffer path to clipboard' })

-- Trim trailing whitespace
vim.keymap.set('n', '<leader>ts', function()
  require('mini.trailspace').trim()
  vim.notify('Trimmed trailing whitespace', vim.log.levels.INFO)
end, { desc = 'Trim trailing whitespace' })

-- Better indenting
vim.keymap.set('v', '<', '<gv', { desc = 'Indent left' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent right' })

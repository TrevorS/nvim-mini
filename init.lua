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
    vim.fn.system({'git', 'clone', '--depth=1', url, install_path})
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
    vim.fn.system({'git', '-C', plugin_path, 'pull'})
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

-- Visual
vim.opt.number = true
vim.opt.signcolumn = 'yes'
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.showmode = false

-- Editing
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.smartindent = true
vim.opt.wrap = false

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = 'nosplit'

-- Undo and backup
vim.opt.undofile = true
vim.opt.backup = false
vim.opt.writebackup = false

-- Completion
vim.opt.completeopt = {'menuone', 'noinsert', 'noselect'}
vim.opt.shortmess:append('c')

-- Behavior
vim.opt.mouse = 'a'
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.virtualedit = 'onemore'
vim.opt.wildmode = {'longest', 'list:longest'}

-- Fillchars
vim.opt.fillchars = {
  horiz = '━',
  horizup = '┻',
  horizdown = '┳',
  vert = '┃',
  vertleft = '┫',
  vertright = '┣',
  verthoriz = '╋',
}

-- Spell check
vim.opt.spelllang = 'en_us'
vim.opt.spell = true

-- ============================================================================
-- NEOVIM 0.11 BUILT-IN LSP
-- ============================================================================

-- Configure LSP servers (examples - install servers separately)
-- lua_ls
vim.lsp.config('lua_ls', {
  cmd = {'lua-language-server'},
  filetypes = {'lua'},
  root_markers = {'.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git'},
  settings = {
    Lua = {
      runtime = {version = 'LuaJIT'},
      workspace = {
        checkThirdParty = false,
        library = {vim.env.VIMRUNTIME}
      }
    }
  }
})

-- rust-analyzer
vim.lsp.config('rust_analyzer', {
  cmd = {'rust-analyzer'},
  filetypes = {'rust'},
  root_markers = {'Cargo.toml', 'Cargo.lock', 'rust-project.json'},
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

-- ts_ls (TypeScript)
vim.lsp.config('ts_ls', {
  cmd = {'typescript-language-server', '--stdio'},
  filetypes = {'javascript', 'javascriptreact', 'typescript', 'typescriptreact'},
  root_markers = {'package.json', 'tsconfig.json', 'jsconfig.json', '.git'},
})

-- Enable LSP servers
vim.lsp.enable({'lua_ls', 'rust_analyzer', 'ts_ls'})

-- Enable built-in completion for buffers with LSP
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    vim.lsp.completion.enable(true, args.data.client_id, args.buf, {autotrigger = true})
  end
})

-- LSP keymaps (using 0.11 defaults, customize as needed)
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = {buffer = args.buf}
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  end
})

-- ============================================================================
-- MINI.NVIM MODULES
-- ============================================================================

-- mini.comment - Toggle comments with 'gc'
require('mini.comment').setup()

-- mini.surround - Surround actions (sa, sd, sr)
require('mini.surround').setup()

-- mini.pairs - Auto-close brackets/quotes
require('mini.pairs').setup()

-- mini.ai - Enhanced text objects
require('mini.ai').setup()

-- mini.bracketed - Navigate with [ and ]
require('mini.bracketed').setup()

-- mini.indentscope - Visualize indent scope
require('mini.indentscope').setup({
  symbol = '│',
  options = {try_as_border = true}
})

-- mini.icons - Icon provider
require('mini.icons').setup()

-- mini.statusline - Minimal statusline
require('mini.statusline').setup()

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
      require('mini.files').go_in({close_on_file = true})
    end, {buffer = buf_id, desc = 'Open file and close explorer'})
    vim.keymap.set('n', '<CR>', function()
      require('mini.files').go_in({close_on_file = true})
    end, {buffer = buf_id, desc = 'Open file and close explorer'})
    -- Esc to close explorer
    vim.keymap.set('n', '<Esc>', function()
      require('mini.files').close()
    end, {buffer = buf_id, desc = 'Close explorer'})
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

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', {desc = 'Move to left window'})
vim.keymap.set('n', '<C-j>', '<C-w>j', {desc = 'Move to bottom window'})
vim.keymap.set('n', '<C-k>', '<C-w>k', {desc = 'Move to top window'})
vim.keymap.set('n', '<C-l>', '<C-w>l', {desc = 'Move to right window'})

-- Splits
vim.keymap.set('n', '<leader>v', '<cmd>vsplit<cr><c-w>l', {desc = 'Vertical split'})
vim.keymap.set('n', '<leader>h', '<cmd>split<cr><c-w>j', {desc = 'Horizontal split'})

-- Edit config files
vim.keymap.set('n', '<leader>ev', '<cmd>edit $HOME/.config/nvim/init.lua<cr>', {desc = 'Edit vim config'})
vim.keymap.set('n', '<leader>ez', '<cmd>edit $HOME/.zshrc<cr>', {desc = 'Edit zshrc'})
vim.keymap.set('n', '<leader>ew', '<cmd>edit $HOME/.wezterm.lua<cr>', {desc = 'Edit wezterm config'})

-- Redraw and clear highlights
vim.keymap.set('n', '<leader>l', '<cmd>redraw!<cr><cmd>nohl<cr><esc>', {desc = 'Redraw and clear highlights'})

-- System clipboard yank in visual mode
vim.keymap.set('v', '<leader>y', '"+y', {desc = 'Yank to system clipboard'})

-- mini.files (like oil.nvim)
vim.keymap.set('n', '-', function()
  require('mini.files').open(vim.api.nvim_buf_get_name(0))
end, {desc = 'Open file explorer'})

-- mini.pick (adapted from telescope bindings)
vim.keymap.set('n', '<leader>p', function()
  require('mini.pick').builtin.files()
end, {desc = 'Find files'})

vim.keymap.set('n', '<leader>b', function()
  require('mini.pick').builtin.buffers()
end, {desc = 'Find buffers'})

vim.keymap.set('n', '<leader>gg', function()
  require('mini.pick').builtin.grep_live()
end, {desc = 'Live grep'})

vim.keymap.set('n', '<leader>*', function()
  require('mini.pick').builtin.grep({pattern = vim.fn.expand('<cword>')})
end, {desc = 'Grep word under cursor'})

vim.keymap.set('n', '<leader>fh', function()
  require('mini.pick').builtin.help()
end, {desc = 'Find help'})

-- Navigate wrapped lines
vim.keymap.set('n', 'j', 'gj', {desc = 'Move down (wrapped)'})
vim.keymap.set('n', 'k', 'gk', {desc = 'Move up (wrapped)'})

-- Buffer navigation
vim.keymap.set('n', '<TAB>', '<cmd>bnext<cr>', {desc = 'Next buffer'})
vim.keymap.set('n', '<S-TAB>', '<cmd>bprevious<cr>', {desc = 'Previous buffer'})

-- Buffer switching by number
for i = 1, 9 do
  vim.keymap.set('n', '<leader>' .. i, function()
    vim.cmd('buffer ' .. i)
  end, {desc = 'Go to buffer ' .. i})
end

-- Format JSON with jq
vim.keymap.set('n', '<leader>jf', '<cmd>%!jq .<cr>', {desc = 'Format JSON with jq'})

-- Format SQL with sleek
vim.keymap.set('n', '<leader>sf', '<cmd>%!sleek<cr>', {desc = 'Format SQL with sleek'})

-- Copy buffer path to system clipboard
vim.keymap.set('n', '<leader>xp', function()
  local path = vim.api.nvim_buf_get_name(0)
  vim.fn.setreg('+', path)
  vim.notify('Copied path: ' .. path, vim.log.levels.INFO)
end, {desc = 'Copy buffer path to clipboard'})

-- Better indenting
vim.keymap.set('v', '<', '<gv', {desc = 'Indent left'})
vim.keymap.set('v', '>', '>gv', {desc = 'Indent right'})

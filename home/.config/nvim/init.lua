-- 1. Plugin Management (Packer Bootstrap)
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'tpope/vim-surround'
  use 'justinmk/vim-sneak'
  use 'mg979/vim-visual-multi'
  
  use {
    'numToStr/Comment.nvim',
    config = function() require('Comment').setup() end
  }
  
  use {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function() require('nvim-autopairs').setup({}) end
  }

  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- 2. General Options
vim.g.mapleader = ' '
vim.cmd.colorscheme('lunaperche')

local opt = vim.opt
opt.timeoutlen = 300
opt.expandtab = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.number = true
opt.ignorecase = true
opt.smartcase = true
opt.wrap = false
opt.foldmethod = "indent"
opt.foldlevel = 99

-- 3. Clipboard Configuration (Consolidated Logic)
local function has_cmd(cmd) return vim.fn.executable(cmd) == 1 end

if os.getenv("XDG_SESSION_TYPE") == "wayland" and has_cmd("wl-copy") then
  vim.g.clipboard = {
    name = "wl-clipboard",
    copy = {
      ['+'] = { 'wl-copy', '--trim-newline' },
      ['*'] = { 'wl-copy', '--primary', '--trim-newline' },
    },
    paste = {
      ['+'] = { 'wl-paste', '--no-newline' },
      ['*'] = { 'wl-paste', '--primary', '--no-newline' },
    },
    cache_enabled = 1,
  }
  opt.clipboard = 'unnamedplus'
elseif has_cmd("xclip") then
  vim.g.clipboard = {
    name = "xclip",
    copy = {
      ["+"] = "xclip -selection clipboard",
      ["*"] = "xclip -selection primary",
    },
    paste = {
      ["+"] = "xclip -selection clipboard -o",
      ["*"] = "xclip -selection primary -o",
    },
    cache_enabled = 0,
  }
  opt.clipboard = 'unnamedplus'
else
  opt.clipboard = "" -- Fallback
end

-- 4. Plugin Variables
vim.g['sneak#use_ic_scs'] = 1
vim.g.VM_silent_exit = 1
vim.g.VM_maps = {
  -- ['Find Under'] = 'w',
  -- ['Find Subword Under'] = 'w',
  ['Select All'] = 'ga',
}

-- 5. Keymaps (Using modern vim.keymap.set)
local map = vim.keymap.set
local silent = { silent = true }

-- Insert Mode
map('i', 'jk', '<Esc>', silent)
map('i', '<C-BS>', '<C-w>')
map('i', '<C-Del>', '<C-O>dw', silent)

-- Normal Mode
map('n', 'vie', 'ggVG', silent)
map('n', 'gh', '0', silent)
map('n', 'gl', '$', silent)
map('n', '<Esc><Esc>', ':noh<CR>', silent)
map('n', 'vv', 'V', silent)
map('n', '<C-l>', 'V', silent)
map('n', 'w', 'viw', silent)
map('n', '<leader>jq', ':%!jq .<CR>', silent)

-- Visual Mode
map('v', 'gh', '0', silent)
map('v', 'gl', '$', silent)
map('v', '<', '<gv', silent)
map('v', '>', '>gv', silent)
map('v', '<C-l>', 'j', silent)

-- Commenting & Plugin Overrides (remap = true to trigger Comment.nvim)
map('n', 'g/', 'gcc', { remap = true })
map('v', 'g/', 'gc', { remap = true })
map('n', '<C-_>', 'gcc', { remap = true })
map('v', '<C-_>', 'gc', { remap = true })
map('v', '/', 'gcgv', { remap = true })

-- UUID Search Helper
local uuid_pattern = [[\v[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}]]
map('n', 'gu', '/' .. uuid_pattern .. '<CR>:noh<CR>v35l', silent)
map('v', 'u', '<Esc>/' .. uuid_pattern .. '<CR>:noh<CR>v35l', silent)

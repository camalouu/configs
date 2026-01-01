-- Packer bootstrap
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
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
  use {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end
  }
  use {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      require('nvim-autopairs').setup {}
    end
  }
  use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  
  if packer_bootstrap then
    require('packer').sync()
  end 
end)

-- Options
vim.g.mapleader = ' '
vim.opt.timeoutlen = 300
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.number = true
vim.opt.clipboard = 'unnamedplus'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrap = false

-- Sneak
vim.g['sneak#use_ic_scs'] = 1

-- Keymaps
local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

keymap('i', 'jk', '<Esc>', opts)
keymap('i', '<C-BS>', '<C-w>', { noremap = true })
keymap('i', '<C-Del>', '<C-O>dw', opts)
keymap('n', 'vie', 'ggVG', opts)
keymap('n', 'gj', 'viw', opts)
keymap('n', 'gh', '0', opts)
keymap('n', 'gl', '$', opts)
keymap('v', 'gh', '0', opts)
keymap('v', 'gl', '$', opts)
keymap('n', '<Esc><Esc>', ':noh<CR>', opts)
keymap('v', '<', '<gv', opts)
keymap('v', '>', '>gv', opts)
keymap('n', 'g/', 'gcc', { noremap = false })
keymap('v', 'g/', 'gc', { noremap = false })
keymap('n', 'vv', 'V', opts)

keymap('n', '<C-l>', 'V', opts)
keymap('v', '<C-l>', 'j', opts)

keymap('n', '<C-_>', 'gcc', { noremap = false })
keymap('v', '<C-_>', 'gc', { noremap = false })

-- Telescope keymaps
local telescope = require('telescope.builtin')
keymap('n', '<leader>rg', '', {
  noremap = true,
  silent = true,
  callback = function()
    telescope.live_grep({
      additional_args = function() return {"--hidden"} end
    })
  end
})
keymap('n', '<C-f>', '', {
  noremap = true,
  silent = true,
  callback = function()
    telescope.find_files({
      hidden = true
    })
  end
})

-- Clipboard configuration with silent fallback
local function has_command(cmd)
  return vim.fn.executable(cmd) == 1
end

local session = os.getenv("XDG_SESSION_TYPE")
if session == "wayland" and has_command("wl-copy") and has_command("wl-paste") then
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
elseif has_command("xclip") then
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
else
  -- Fallback: disable system clipboard if no tool available
  vim.opt.clipboard = ""
end

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
  use 'tpope/vim-surround'
  use 'justinmk/vim-sneak'
  use {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
        require("nvim-autopairs").setup {}
    end
  }
  if packer_bootstrap then
    require('packer').sync()
  end 
end)

vim.api.nvim_set_keymap('i', 'jk', '<Esc>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'vie', 'ggVG', { noremap = true })
vim.api.nvim_set_keymap('n', 'gb', 'viw', { noremap = true })
vim.api.nvim_set_keymap('n', 'gh', '0', { noremap = true })
vim.api.nvim_set_keymap('n', 'gl', '$', { noremap = true })
vim.api.nvim_set_keymap('v', 'gh', '0', { noremap = true })
vim.api.nvim_set_keymap('v', 'gl', '$', { noremap = true })

vim.opt.timeoutlen = 300
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.number = true
vim.opt.clipboard = 'unnamedplus'
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.g['sneak#use_ic_scs'] = 1
vim.g.mapleader = ' '
vim.g.clipboard = {
    name = 'xclip',
    copy = {
        ['+'] = 'xclip -selection clipboard',
        ['*'] = 'xclip -selection primary',
    },
    paste = {
        ['+'] = 'xclip -selection clipboard -o',
        ['*'] = 'xclip -selection primary -o',
    },
    cache_enabled = 0,
}

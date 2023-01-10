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

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  -- My plugins here
  use 'bluz71/vim-nightfly-colors' -- preferred colorscheme
  use {
    'numToStr/Comment.nvim',
    config = function()
        require('Comment').setup()
    end
  }
  use { 
    'nvim-tree/nvim-tree.lua',
    config = function()
      require("nvim-tree").setup()
    end
  }
  use 'neovim/nvim-lspconfig' -- Configurations for Nvim LSP
  use 'feline-nvim/feline.nvim'

  -- Autocompletition
  use("hrsh7th/nvim-cmp")

  -- Icons
  use 'nvim-tree/nvim-web-devicons'

  -- Telescope
  use {
  'nvim-telescope/telescope.nvim', branch = '0.1.x',
  requires = { {'nvim-lua/plenary.nvim'} }
  }
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

  -- Signs
  use {
  'lewis6991/gitsigns.nvim',
  }

  -- Whichkey
  use {
    "folke/which-key.nvim",
    config = function()
      vim.o.timeoutlen = 300
      require("which-key").setup {
      }
    end
  }



  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)

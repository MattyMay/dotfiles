-- Load plugins FIRST
require('plugins')

-- Load core settings
require('settings')
require('keymaps')

-- Load plugin configurations (with pcall to handle missing plugins gracefully)
local function safe_require(module)
  local ok, err = pcall(require, module)
  if not ok then
    vim.notify("Failed to load " .. module, vim.log.levels.WARN)
    vim.notify(err, vim.log.levels.WARN)
  end
end

safe_require('plugin-configs.treesitter')
safe_require('plugin-configs.lualine')
safe_require('plugin-configs.indent-blankline')
safe_require('plugin-configs.vimwiki')
safe_require('plugin-configs.misc')
safe_require('plugin-configs.coc')


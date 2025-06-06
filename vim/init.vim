set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vimrc

"""""""""" INDENT BLANK LINE STUFF
let g:indent_blankline_show_trailing_blankline_indent = v:false
let g:indent_blankline_use_treesitter = v:true
let g:indent_blankline_show_current_context = v:true


"""""""""" TREE SITTER STUFF
lua <<EOF
require("ibl").setup {
    indent = {char = "│", tab_char="│"},
    scope = {show_start = false, show_end = false},
}

require'nvim-treesitter.configs'.setup {
  ensure_installed = "all", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  highlight = {
    enable = true,              -- false will disable the whole extension
    disable = {},  -- list of language that will be disabled
  },
}

-- lualine for vim
require('lualine').setup {
  options = {
    icons_enabled = false,
    theme = 'tokyonight',
    section_separators = '',
    component_separators = '',
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}

-- Open buffers while navigating qflist
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'qf',
  callback = function(event)
    local opts = { buffer = event.buf, silent = true }
    local init_bufnr = vim.fn.bufnr('#')
    vim.keymap.set('n', '<C-n>', function()
      if vim.fn.line('.') == vim.fn.line('$') then
        vim.notify('E553: No more items', vim.log.levels.ERROR)
        return
      end
      vim.cmd('wincmd p') -- jump to current displayed file
      vim.cmd(
        (vim.fn.bufnr('%') ~= init_bufnr and vim.bo.filetype ~= 'qf')
            and ('bd | wincmd p | cn | res %d'):format(
              math.floor(
                (vim.o.lines - vim.o.cmdheight - (vim.o.laststatus == 0 and 0 or 1) - (vim.o.tabline == '' and 0 or 1))
                    / 3
                    * 2
                  + 0.5
              ) - 1
            )
          or 'cn'
      )
      vim.cmd('execute "normal! zz"')
      if vim.bo.filetype ~= 'qf' then
        vim.cmd('wincmd p')
      end
    end, opts)

    vim.keymap.set('n', '<C-p>', function()
      if vim.fn.line('.') == 1 then
        vim.notify('E553: No more items', vim.log.levels.ERROR)
        return
      end
      vim.cmd('wincmd p') -- jump to current displayed file
      vim.cmd(
        (vim.fn.bufnr('%') ~= init_bufnr and vim.bo.filetype ~= 'qf')
            and ('bd | wincmd p | cN | res %d'):format(
              math.floor(
                (vim.o.lines - vim.o.cmdheight - (vim.o.laststatus == 0 and 0 or 1) - (vim.o.tabline == '' and 0 or 1))
                    / 3
                    * 2
                  + 0.5
              ) - 1
            )
          or 'cN'
      )
      vim.cmd('execute "normal! zz"')
      if vim.bo.filetype ~= 'qf' then
        vim.cmd('wincmd p')
      end
    end, opts)
  end,
})
EOF

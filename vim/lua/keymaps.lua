local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Disable Q (Ex mode)
map('n', 'Q', '<Nop>', opts)

-- Vim-tmux navigator
vim.g.tmux_navigator_no_mappings = 1
map('n', '<C-h>', ':TmuxNavigateLeft<CR>', opts)
map('n', '<C-j>', ':TmuxNavigateDown<CR>', opts)
map('n', '<C-k>', ':TmuxNavigateUp<CR>', opts)
map('n', '<C-l>', ':TmuxNavigateRight<CR>', opts)

-- NERDTree toggle
map('n', '<C-\\>', ':NERDTreeToggle<CR>', opts)
vim.g.NERDTreeWinPos = "right"

-- Copilot accept
map('i', '<leader><tab>', 'copilot#Accept("")', { expr = true, silent = true })
vim.g.copilot_no_tab_map = 1

-- Terminal mode escape
map('t', '<Esc>', '<C-\\><C-n>', opts)

-- Emmet
vim.g.user_emmet_expandabbr_key = '<tab>'


-- quickfix list navigation
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
      vim.cmd('wincmd p')
      local height = math.floor((vim.o.lines - vim.o.cmdheight - 
                     (vim.o.laststatus == 0 and 0 or 1) - 
                     (vim.o.tabline == '' and 0 or 1)) / 3 * 2 + 0.5) - 1
      if vim.fn.bufnr('%') ~= init_bufnr and vim.bo.filetype ~= 'qf' then
        vim.cmd(string.format('bd | wincmd p | cn | res %d', height))
      else
        vim.cmd('cn')
      end
      vim.cmd('normal! zz')
      if vim.bo.filetype ~= 'qf' then
        vim.cmd('wincmd p')
      end
    end, opts)

    vim.keymap.set('n', '<C-p>', function()
      if vim.fn.line('.') == 1 then
        vim.notify('E553: No more items', vim.log.levels.ERROR)
        return
      end
      vim.cmd('wincmd p')
      local height = math.floor((vim.o.lines - vim.o.cmdheight - 
                     (vim.o.laststatus == 0 and 0 or 1) - 
                     (vim.o.tabline == '' and 0 or 1)) / 3 * 2 + 0.5) - 1
      if vim.fn.bufnr('%') ~= init_bufnr and vim.bo.filetype ~= 'qf' then
        vim.cmd(string.format('bd | wincmd p | cN | res %d', height))
      else
        vim.cmd('cN')
      end
      vim.cmd('normal! zz')
      if vim.bo.filetype ~= 'qf' then
        vim.cmd('wincmd p')
      end
    end, opts)
  end,
})

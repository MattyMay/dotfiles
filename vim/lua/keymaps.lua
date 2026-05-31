local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Plugin-specific keymaps live in their specs under lua/plugins/.

-- Disable Q (Ex mode)
map('n', 'Q', '<Nop>', opts)

-- Terminal mode escape
map('t', '<Esc>', '<C-\\><C-n>', opts)

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

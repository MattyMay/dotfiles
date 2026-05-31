return {
  "neoclide/coc.nvim",
  branch = "release",

  init = function()
    -- Extensions are read at startup, so this must be set before coc loads.
    vim.g.coc_global_extensions = {
      "coc-prettier",
      "coc-json",
      "coc-git",
      "coc-clangd",
      "coc-css",
      "coc-html",
      "coc-java",
      "coc-pyright",
      "coc-sh",
      "coc-vimlsp",
      "coc-tsserver",
      "coc-eslint",
      "coc-lua",
    }
  end,

  config = function()
    local map = vim.keymap.set
    local opts = { silent = true, noremap = true }
    local plug_opts = { silent = true, remap = true }

    -- Tab completion
    map("i", "<TAB>", [[coc#pum#visible() ? coc#pum#next(1) : v:lua.check_backspace() ? "\<Tab>" : coc#refresh()]], { expr = true, silent = true })
    map("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], { expr = true, silent = true })

    -- Enter to confirm
    map("i", "<CR>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], { expr = true, silent = true })

    -- Helper function for tab (must be global for the v:lua expression mapping above)
    function _G.check_backspace()
      local col = vim.fn.col(".") - 1
      return col == 0 or vim.fn.getline("."):sub(col, col):match("%s") ~= nil
    end

    -- Trigger completion
    map("i", "<C-space>", "coc#refresh()", { expr = true, silent = true })

    -- Navigation
    map("n", "[g", "<Plug>(coc-diagnostic-prev)", plug_opts)
    map("n", "]g", "<Plug>(coc-diagnostic-next)", plug_opts)

    -- GoTo code navigation
    map("n", "gd", "<Plug>(coc-definition)", plug_opts)
    map("n", "gy", "<Plug>(coc-type-definition)", plug_opts)
    map("n", "gi", "<Plug>(coc-implementation)", plug_opts)
    map("n", "gr", "<Plug>(coc-references)", plug_opts)

    -- Show documentation
    local function show_docs()
      local cw = vim.fn.expand("<cword>")
      if vim.fn.index({ "vim", "help" }, vim.bo.filetype) >= 0 then
        vim.api.nvim_command("h " .. cw)
      elseif vim.api.nvim_eval("coc#rpc#ready()") then
        vim.fn.CocActionAsync("doHover")
      else
        vim.api.nvim_command("!" .. vim.o.keywordprg .. " " .. cw)
      end
    end
    map("n", "K", show_docs, opts)

    -- Highlight symbol under cursor
    vim.api.nvim_create_autocmd("CursorHold", {
      pattern = "*",
      callback = function()
        vim.fn.CocActionAsync("highlight")
      end,
    })

    -- Rename
    map("n", "<leader>rn", "<Plug>(coc-rename)", plug_opts)

    -- Format
    map("x", "<leader>f", "<Plug>(coc-format-selected)", plug_opts)
    map("n", "<leader>f", "<Plug>(coc-format-selected)", plug_opts)

    -- Code actions
    map("x", "<leader>a", "<Plug>(coc-codeaction-selected)", plug_opts)
    map("n", "<leader>a", "<Plug>(coc-codeaction-selected)", plug_opts)
    map("n", "<leader>ac", "<Plug>(coc-codeaction)", plug_opts)
    map("n", "<leader>qf", "<Plug>(coc-fix-current)", plug_opts)
    map("n", "<leader>cl", "<Plug>(coc-codelens-action)", plug_opts)

    -- Text objects
    map("x", "if", "<Plug>(coc-funcobj-i)", plug_opts)
    map("o", "if", "<Plug>(coc-funcobj-i)", plug_opts)
    map("x", "af", "<Plug>(coc-funcobj-a)", plug_opts)
    map("o", "af", "<Plug>(coc-funcobj-a)", plug_opts)
    map("x", "ic", "<Plug>(coc-classobj-i)", plug_opts)
    map("o", "ic", "<Plug>(coc-classobj-i)", plug_opts)
    map("x", "ac", "<Plug>(coc-classobj-a)", plug_opts)
    map("o", "ac", "<Plug>(coc-classobj-a)", plug_opts)

    -- Scroll in floating windows
    map("n", "<C-f>", [[coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"]], { expr = true, silent = true, nowait = true })
    map("n", "<C-b>", [[coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"]], { expr = true, silent = true, nowait = true })
    map("i", "<C-f>", [[coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"]], { expr = true, silent = true, nowait = true })
    map("i", "<C-b>", [[coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"]], { expr = true, silent = true, nowait = true })
    map("v", "<C-f>", [[coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"]], { expr = true, silent = true, nowait = true })
    map("v", "<C-b>", [[coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"]], { expr = true, silent = true, nowait = true })

    -- Selection ranges
    map("n", "<C-s>", "<Plug>(coc-range-select)", plug_opts)
    map("x", "<C-s>", "<Plug>(coc-range-select)", plug_opts)

    -- Commands
    vim.api.nvim_create_user_command("Format", 'call CocActionAsync("format")', {})
    vim.api.nvim_create_user_command("Fold", 'call CocAction("fold", <f-args>)', { nargs = "?" })
    vim.api.nvim_create_user_command("OR", 'call CocActionAsync("runCommand", "editor.action.organizeImport")', {})
    vim.api.nvim_create_user_command("Prettier", "CocCommand prettier.formatFile", {})
    vim.api.nvim_create_user_command("Spellcheck", "CocCommand cSpell.toggleEnableSpellChecker", {})

    -- CoCList mappings
    map("n", "<space>a", ":<C-u>CocList diagnostics<cr>", opts)
    map("n", "<space>e", ":<C-u>CocList extensions<cr>", opts)
    map("n", "<space>c", ":<C-u>CocList commands<cr>", opts)
    map("n", "<space>o", ":<C-u>CocList outline<cr>", opts)
    map("n", "<space>s", ":<C-u>CocList -I symbols<cr>", opts)
    map("n", "<space>j", ":<C-u>CocNext<CR>", opts)
    map("n", "<space>k", ":<C-u>CocPrev<CR>", opts)
    map("n", "<space>p", ":<C-u>CocListResume<CR>", opts)

    -- Custom split function. Jumps to an existing split if the file is open.
    local function split_if_not_open(...)
      local args = { ... }
      local fname = args[1]
      local call = ""

      if #args == 2 then
        fname = args[2]
        call = args[1]
      end

      local bufnum = vim.fn.bufnr(vim.fn.expand(fname))
      local winnum = vim.fn.bufwinnr(bufnum)

      if winnum ~= -1 then
        vim.cmd(winnum .. "wincmd w")
      else
        vim.cmd("vsplit " .. fname)
      end

      if call ~= "" then
        vim.cmd(call)
      end
    end

    vim.api.nvim_create_user_command("CocSplitIfNotOpen", function(cmd)
      split_if_not_open(unpack(cmd.fargs))
    end, { nargs = "+" })

    -- Statusline
    vim.opt.statusline = "%{coc#status()}%{get(b:,'coc_current_function','')}"
  end,
}

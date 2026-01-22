local status_ok, treesitter = pcall(require, 'nvim-treesitter.configs')
if not status_ok then
  return
end

treesitter.setup({
  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,
  
  -- Automatically install missing parsers when entering buffer
  auto_install = true,
  
  -- List of parsers to install (or "all")
  ensure_installed = "all",
  
  highlight = {
    enable = true,
    disable = {},
  },
  
  indent = {
    enable = true
  },
})
